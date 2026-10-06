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

  async function startFreshRound() {
    await db.query(`UPDATE quiz_rounds SET status = 'abandoned' WHERE user_id = $1 AND status = 'in_progress'`, [userId]);
    const q = await quizService.getNextQuestion(categoryId, userId);
    const rows = (await db.query(
      `SELECT rq.position, rq.question_id, qu.difficulty
       FROM quiz_round_questions rq JOIN questions qu ON qu.id = rq.question_id
       WHERE rq.round_id = $1 ORDER BY rq.position`, [q.round.id]
    )).rows;
    return { roundId: q.round.id, rows };
  }

  it('ao iniciar a rodada, as 10 perguntas ficam escolhidas: posições 1..10, mistura 4/4/2, do fácil ao difícil', async () => {
    const { rows } = await startFreshRound();
    expect(rows.map((r) => r.position)).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(new Set(rows.map((r) => r.question_id)).size).toBe(10);
    const count = (d) => rows.filter((r) => r.difficulty === d).length;
    expect([count('easy'), count('medium'), count('hard')]).toEqual([4, 4, 2]);
    const rank = rows.map((r) => ['easy', 'medium', 'hard'].indexOf(r.difficulty));
    expect(rank).toEqual([...rank].sort((a, b) => a - b));
  });

  it('chamar next-question outra vez (recarregar) não troca as perguntas da rodada', async () => {
    const first = await startFreshRound();
    await quizService.getNextQuestion(categoryId, userId);
    await quizService.getNextQuestion(categoryId, userId);
    const after = (await db.query(`SELECT question_id FROM quiz_round_questions WHERE round_id = $1 ORDER BY position`, [first.roundId])).rows.map((r) => r.question_id);
    expect(after).toEqual(first.rows.map((r) => r.question_id));
  });

  it('duas chamadas simultâneas na rodada nova guardam um único conjunto de 10', async () => {
    await db.query(`UPDATE quiz_rounds SET status = 'abandoned' WHERE user_id = $1 AND status = 'in_progress'`, [userId]);
    const [a, b] = await Promise.all([
      quizService.getNextQuestion(categoryId, userId),
      quizService.getNextQuestion(categoryId, userId),
    ]);
    expect(a.round.id).toBe(b.round.id);
    const n = (await db.query(`SELECT COUNT(*)::int AS n FROM quiz_round_questions WHERE round_id = $1`, [a.round.id])).rows[0].n;
    expect(n).toBe(10);
  });

  it('a 2.ª rodada prefere perguntas que o utilizador não viu na 1.ª', async () => {
    const first = await startFreshRound();
    for (const r of first.rows) {
      const alt = (await db.query(`SELECT id FROM question_alternatives WHERE question_id = $1 LIMIT 1`, [r.question_id])).rows[0].id;
      await db.query(
        `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, xp_awarded, points_awarded, round_id)
         VALUES ($1, $2, $3, FALSE, 5000, 0, 0, $4)`, [userId, r.question_id, alt, first.roundId]
      );
    }
    await db.query(`UPDATE quiz_rounds SET status = 'completed', completed_at = now() WHERE id = $1`, [first.roundId]);
    const second = await startFreshRound();
    const seen = new Set(first.rows.map((r) => r.question_id));
    expect(second.rows.filter((r) => seen.has(r.question_id))).toHaveLength(0);
  });

  // ---- P6b: servir pela posição guardada, recarregar e relógio original ----

  it('P6b: serve as perguntas pela posição guardada, uma de cada vez', async () => {
    const { rows } = await startFreshRound(); // já serviu (e marcou) a posição 1
    for (let i = 0; i < 3; i += 1) {
      const q = await quizService.getNextQuestion(categoryId, userId);
      expect(q.id).toBe(rows[i].question_id);
      expect(q.round.answered).toBe(i);
      await new Promise((r) => setTimeout(r, 450)); // evita o antifraude de resposta rápida
      await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: await correctAltOf(q.id) });
    }
    const next = await quizService.getNextQuestion(categoryId, userId);
    expect(next.id).toBe(rows[3].question_id);
  });

  it('P6b: recarregar devolve a MESMA pergunta, mantém o relógio original e não duplica respostas', async () => {
    const { roundId } = await startFreshRound();
    const q1 = await quizService.getNextQuestion(categoryId, userId);
    expect(q1.time_remaining_seconds).toBeGreaterThanOrEqual(q1.time_limit_seconds - 1);

    // simula 20 s já gastos desde a primeira entrega
    await redis.set(`quiz:issued:${userId}:${q1.id}`, String(Date.now() - 20000), 'EX', 600);
    const q2 = await quizService.getNextQuestion(categoryId, userId);

    expect(q2.id).toBe(q1.id);
    // o relógio NÃO reiniciou: só resta o que sobrava (limite - 20 s)
    expect(q2.time_remaining_seconds).toBeLessThanOrEqual(q1.time_limit_seconds - 20);
    expect(q2.time_remaining_seconds).toBeGreaterThanOrEqual(q1.time_limit_seconds - 22);
    const attempts = (await db.query(`SELECT COUNT(*)::int AS n FROM quiz_attempts WHERE round_id = $1`, [roundId])).rows[0].n;
    expect(attempts).toBe(0);
  });

  it('P6b: se o tempo já esgotou ao recarregar, restam 0 s e a resposta conta como tempo esgotado', async () => {
    await startFreshRound();
    const q1 = await quizService.getNextQuestion(categoryId, userId);
    await redis.set(`quiz:issued:${userId}:${q1.id}`, String(Date.now() - (q1.time_limit_seconds + 5) * 1000), 'EX', 600);

    const q2 = await quizService.getNextQuestion(categoryId, userId);
    expect(q2.id).toBe(q1.id);
    expect(q2.time_remaining_seconds).toBe(0);

    const result = await quizService.submitAnswer({ userId, questionId: q2.id, alternativeId: await correctAltOf(q2.id) });
    expect(result.timeExpired).toBe(true);
    expect(result.isCorrect).toBe(false); // recarregar não dá tempo grátis
  });

  it('P6b: rodada antiga sem perguntas guardadas continua pelo caminho anterior (aleatória)', async () => {
    await db.query(`UPDATE quiz_rounds SET status = 'abandoned' WHERE user_id = $1 AND status = 'in_progress'`, [userId]);
    const round = (await db.query(
      `INSERT INTO quiz_rounds (user_id, category_id, target_questions) VALUES ($1, $2, 10) RETURNING id`, [userId, categoryId]
    )).rows[0];
    // uma resposta já dada: rodada começada antes da funcionalidade (não escolhe perguntas)
    const someQ = (await db.query(`SELECT id FROM questions WHERE category_id = $1 AND is_active LIMIT 1`, [categoryId])).rows[0].id;
    const alt = (await db.query(`SELECT id FROM question_alternatives WHERE question_id = $1 LIMIT 1`, [someQ])).rows[0].id;
    await db.query(
      `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, xp_awarded, points_awarded, round_id)
       VALUES ($1, $2, $3, FALSE, 5000, 0, 0, $4)`, [userId, someQ, alt, round.id]
    );
    const q = await quizService.getNextQuestion(categoryId, userId);
    expect(q.round.id).toBe(round.id);
    expect(q.id).not.toBe(someQ);
    const stored = (await db.query(`SELECT COUNT(*)::int AS n FROM quiz_round_questions WHERE round_id = $1`, [round.id])).rows[0].n;
    expect(stored).toBe(0);
  });

  // ---- P7: totais guardados na rodada ao concluí-la ----

  async function playFullRound(wrongIdx = []) {
    // começa de uma rodada nova (testes anteriores podem ter deixado uma em andamento)
    await db.query(`UPDATE quiz_rounds SET status = 'abandoned' WHERE user_id = $1 AND status = 'in_progress'`, [userId]);
    let last;
    for (let i = 0; i < 10; i += 1) {
      const q = await quizService.getNextQuestion(categoryId, userId);
      const alt = wrongIdx.includes(i) ? await wrongAltOf(q.id) : await correctAltOf(q.id);
      await new Promise((r) => setTimeout(r, 450));
      last = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: alt });
    }
    return last.round.id;
  }

  it('P7: ao concluir, a rodada guarda respostas certas, tempo total, XP e pontos (= soma das tentativas)', async () => {
    const roundId = await playFullRound([2, 7]);
    const row = (await db.query(`SELECT * FROM quiz_rounds WHERE id = $1`, [roundId])).rows[0];
    const sums = (await db.query(
      `SELECT COUNT(*) FILTER (WHERE is_correct)::int AS c, SUM(response_time_ms)::int AS t,
              SUM(xp_awarded)::int AS xp, SUM(points_awarded)::int AS pts
       FROM quiz_attempts WHERE round_id = $1`, [roundId]
    )).rows[0];
    expect(row.correct_count).toBe(8);
    expect(row.correct_count).toBe(sums.c);
    expect(row.total_response_ms).toBe(sums.t);
    expect(row.xp_total).toBe(sums.xp);
    expect(row.points_total).toBe(sums.pts);
    expect(row.xp_total).toBeGreaterThan(0);
  });

  it('P7: o resumo usa os totais guardados e traz o tempo total', async () => {
    const roundId = await playFullRound([0]);
    const row = (await db.query(`SELECT * FROM quiz_rounds WHERE id = $1`, [roundId])).rows[0];
    const summary = await quizService.getRoundSummary({ userId, roundId });
    expect(summary.xpEarned).toBe(row.xp_total);
    expect(summary.pointsEarned).toBe(row.points_total);
    expect(summary.totalSeconds).toBeCloseTo(row.total_response_ms / 1000, 1);
    expect(summary.averageResponseSeconds).toBeCloseTo(row.total_response_ms / 1000 / 10, 1);
  });

  it('P7: rodada antiga já concluída (sem totais guardados) continua a ser calculada pelas tentativas', async () => {
    const roundId = await playFullRound([1]);
    const before = await quizService.getRoundSummary({ userId, roundId });
    await db.query(
      `UPDATE quiz_rounds SET correct_count = NULL, total_response_ms = NULL, xp_total = NULL, points_total = NULL WHERE id = $1`,
      [roundId]
    );
    const legacy = await quizService.getRoundSummary({ userId, roundId });
    expect(legacy.xpEarned).toBe(before.xpEarned);
    expect(legacy.pointsEarned).toBe(before.pointsEarned);
    expect(legacy.totalSeconds).toBe(before.totalSeconds);
  });
});
