/**
 * Quiz: fluxo completo de rodadas contra Postgres e Redis REAIS.
 *
 * Fica desligado por padrão (a suíte normal não exige banco). Para correr:
 *   RUN_DB_TESTS=1 DATABASE_URL=... REDIS_URL=... npx jest --runInBand tests/quiz-rounds.integration.test.js
 * O banco precisa ter as migrations aplicadas. USE UM BANCO DESCARTÁVEL DE TESTE, nunca o
 * de produção: o teste cria um utilizador próprio e, como audit_logs é append-only (não
 * permite apagar o utilizador), no fim só apaga as rodadas e tentativas que criou.
 */
const maybe = process.env.RUN_DB_TESTS ? describe : describe.skip;

maybe('quiz: rodadas com banco real', () => {
  const db = require('../src/config/database');
  const redis = require('../src/config/redis');
  const quizService = require('../src/modules/quiz/services/quizService');
  let userId; let categoryId;

  beforeAll(async () => {
    const u = await db.query(
      `INSERT INTO users (name, phone, phone_provider) VALUES ('Teste Rodada', $1, 'mpesa') RETURNING id`,
      [`+2588${Date.now().toString().slice(-8)}`]
    );
    userId = u.rows[0].id;
    // o cadastro real também cria a linha de ofensiva (authService.register)
    await db.query(`INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`, [userId]);
    categoryId = (await db.query(`SELECT id FROM categories WHERE slug = 'financas'`)).rows[0].id;
  });

  afterAll(async () => {
    await db.query(`DELETE FROM quiz_attempts WHERE user_id = $1`, [userId]);
    await db.query(`DELETE FROM quiz_rounds WHERE user_id = $1`, [userId]);
    await redis.quit();
    await db.pool.end();
  });

  async function correctAltOf(questionId) {
    return (await db.query(`SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct`, [questionId])).rows[0].id;
  }
  async function wrongAltOf(questionId) {
    return (await db.query(`SELECT id FROM question_alternatives WHERE question_id = $1 AND NOT is_correct LIMIT 1`, [questionId])).rows[0].id;
  }

  it('rodada completa: contador, sem repetição, checkpoint aos 5, conclusão aos 10 e resumo', async () => {
    const seen = new Set();
    let lastResult;
    for (let i = 0; i < 10; i += 1) {
      const q = await quizService.getNextQuestion(categoryId, userId);
      expect(q.round).toMatchObject({ answered: i, target: 10 });
      // a pergunta enviada ao cliente não traz a resposta
      expect(JSON.stringify(q)).not.toMatch(/is_correct|explanation/);
      expect(seen.has(q.id)).toBe(false); // nunca repete dentro da rodada
      seen.add(q.id);

      // errar as perguntas 3 e 8 (índices 2 e 7); acertar o resto
      const wrong = i === 2 || i === 7;
      const alt = wrong ? await wrongAltOf(q.id) : await correctAltOf(q.id);
      // espera >400ms para não acionar o antifraude de resposta rápida
      await new Promise((r) => setTimeout(r, 450));
      lastResult = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: alt });

      expect(lastResult.isCorrect).toBe(!wrong);
      expect(lastResult.correctAlternative.id).toBe(await correctAltOf(q.id));
      expect(lastResult.round.answered).toBe(i + 1);
      expect(lastResult.round.checkpoint).toBe(i + 1 === 5); // checkpoint técnico só aos 5
      expect(lastResult.round.completed).toBe(i + 1 === 10); // fim da rodada só aos 10
    }

    const row = (await db.query(`SELECT * FROM quiz_rounds WHERE id = $1`, [lastResult.round.id])).rows[0];
    expect(row.status).toBe('completed');
    expect(row.checkpoint_at).not.toBeNull();
    expect(row.completed_at).not.toBeNull();

    const summary = await quizService.getRoundSummary({ userId, roundId: lastResult.round.id });
    expect(summary).toMatchObject({ answered: 10, correct: 8, wrong: 2, accuracyPercent: 80 });
    expect(summary.toReview).toHaveLength(2);
    expect(summary.xpEarned).toBeGreaterThan(0);

    // a seguir à conclusão, pedir pergunta abre uma NOVA rodada
    const next = await quizService.getNextQuestion(categoryId, userId);
    expect(next.round.answered).toBe(0);
    expect(next.round.id).not.toBe(lastResult.round.id);
  }, 60000);

  it('recarregar a meio: a rodada retoma com o progresso certo', async () => {
    const q1 = await quizService.getNextQuestion(categoryId, userId);
    await new Promise((r) => setTimeout(r, 450));
    await quizService.submitAnswer({ userId, questionId: q1.id, alternativeId: await correctAltOf(q1.id) });
    const afterReload = await quizService.getNextQuestion(categoryId, userId);
    expect(afterReload.round).toMatchObject({ answered: 1, correct: 1 });
  }, 30000);

  it('resumo de rodada em andamento é recusado e de outro utilizador dá 404', async () => {
    const q = await quizService.getNextQuestion(categoryId, userId);
    const inProgress = (await db.query(`SELECT id FROM quiz_rounds WHERE user_id = $1 AND status = 'in_progress'`, [userId])).rows[0];
    await expect(quizService.getRoundSummary({ userId, roundId: inProgress.id })).rejects.toThrow(/ainda não foi concluída/);
    await expect(
      quizService.getRoundSummary({ userId: '00000000-0000-4000-8000-000000000000', roundId: inProgress.id })
    ).rejects.toMatchObject({ statusCode: 404 });
    expect(q.id).toBeTruthy();
  });

  it('responder sem a pergunta ter sido entregue não revela a correta nem entra na rodada', async () => {
    const q = (await db.query(`SELECT id FROM questions WHERE category_id = $1 AND is_active LIMIT 1 OFFSET 500`, [categoryId])).rows[0]
      || (await db.query(`SELECT id FROM questions WHERE category_id = $1 AND is_active LIMIT 1`, [categoryId])).rows[0];
    const res = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: await wrongAltOf(q.id) });
    expect(res.correctAlternative).toBeNull();
    expect(res.round).toBeNull();
    const att = (await db.query(`SELECT round_id FROM quiz_attempts WHERE user_id = $1 AND question_id = $2 ORDER BY created_at DESC LIMIT 1`, [userId, q.id])).rows[0];
    expect(att.round_id).toBeNull();
  });

  it('quiz_round_questions: posição única e a mesma pergunta nunca duas vezes na rodada', async () => {
    const q = await quizService.getNextQuestion(categoryId, userId);
    const roundId = q.round.id;
    const ids = (await db.query(`SELECT id FROM questions WHERE category_id = $1 AND is_active LIMIT 3`, [categoryId])).rows.map((r) => r.id);
    await db.query(`DELETE FROM quiz_round_questions WHERE round_id = $1`, [roundId]);
    await db.query(`INSERT INTO quiz_round_questions (round_id, position, question_id) VALUES ($1, 1, $2), ($1, 2, $3)`, [roundId, ids[0], ids[1]]);
    await expect(
      db.query(`INSERT INTO quiz_round_questions (round_id, position, question_id) VALUES ($1, 1, $2)`, [roundId, ids[2]])
    ).rejects.toThrow(/duplicate key|unique/i); // posição repetida
    await expect(
      db.query(`INSERT INTO quiz_round_questions (round_id, position, question_id) VALUES ($1, 3, $2)`, [roundId, ids[0]])
    ).rejects.toThrow(/uq_quiz_round_question|duplicate key/i); // pergunta repetida
    await expect(
      db.query(`INSERT INTO quiz_round_questions (round_id, position, question_id) VALUES ($1, 0, $2)`, [roundId, ids[2]])
    ).rejects.toThrow(/check/i); // posição tem de ser > 0
    await db.query(`DELETE FROM quiz_round_questions WHERE round_id = $1`, [roundId]);
  });
});
