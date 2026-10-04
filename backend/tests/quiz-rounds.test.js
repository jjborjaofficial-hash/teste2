/**
 * Teste de integração (precisa de PostgreSQL + Redis com as migrations e os seeds de perguntas
 * aplicados, como os outros testes com banco): rodada de 10 perguntas do quiz v2.
 * O utilizador de teste NÃO é apagado no fim (audit_logs é append-only e bloqueia o DELETE em
 * cascata); só as rodadas e tentativas dele são removidas.
 */
const db = require('../src/config/database');
const quizService = require('../src/modules/quiz/services/quizService');

let userId;
let categories;

async function alternativeId(questionId, correct) {
  const { rows } = await db.query(
    'SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct = $2 LIMIT 1',
    [questionId, correct]
  );
  return rows[0].id;
}

async function roundQuestionIds(roundId) {
  const { rows } = await db.query('SELECT question_ids FROM quiz_rounds WHERE id = $1', [roundId]);
  return rows[0].question_ids;
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Rodada', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
  categories = (await db.query('SELECT id, name FROM categories WHERE is_active ORDER BY name')).rows;
});

afterAll(async () => {
  await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('Rodada de 10 perguntas (quiz v2)', () => {
  let round;
  let questionIds;

  it('inicia a rodada com 10 perguntas distintas e contador 1/10', async () => {
    round = await quizService.startRound({ userId, categoryId: categories[0].id });
    questionIds = await roundQuestionIds(round.id);
    expect(round).toMatchObject({ total: 10, answered: 0, current: 1, finished: false });
    expect(new Set(questionIds).size).toBe(10);
  });

  it('abrir a mesma categoria de novo retoma a rodada (recarregar não cria outra)', async () => {
    const again = await quizService.startRound({ userId, categoryId: categories[0].id });
    expect(again.id).toBe(round.id);
  });

  it('serve a pergunta atual sem revelar a correta e a mesma ao recarregar', async () => {
    const first = await quizService.getRoundQuestion({ userId, roundId: round.id });
    expect(first.id).toBe(questionIds[0]);
    expect(JSON.stringify(first)).not.toMatch(/is_correct|isCorrect|correctAnswer|correctOption/i);
    const reloaded = await quizService.getRoundQuestion({ userId, roundId: round.id });
    expect(reloaded.id).toBe(first.id);
  });

  it('recusa responder uma pergunta que não é a atual', async () => {
    await expect(
      quizService.submitAnswer({
        userId,
        questionId: questionIds[3],
        alternativeId: await alternativeId(questionIds[3], true),
        roundId: round.id,
      })
    ).rejects.toThrow(/atual/);
  });

  it('percorre as 10: sem resumo antes da 10.ª, recusa reenvio, resumo só da rodada', async () => {
    let last;
    for (let i = 0; i < 10; i += 1) {
      const question = await quizService.getRoundQuestion({ userId, roundId: round.id });
      expect(question.id).toBe(questionIds[i]);
      expect(question.round.current).toBe(i + 1);
      const alt = await alternativeId(question.id, i % 3 !== 2); // erra a 3.ª, 6.ª e 9.ª
      last = await quizService.submitAnswer({ userId, questionId: question.id, alternativeId: alt, roundId: round.id });
      if (i === 4) {
        expect(last.round.finished).toBe(false);
        expect(last.roundSummary).toBeUndefined();
        expect(last.round.current).toBe(6);
      }
      if (i === 3) {
        await expect(
          quizService.submitAnswer({ userId, questionId: question.id, alternativeId: alt, roundId: round.id })
        ).rejects.toThrow();
      }
    }
    expect(last.round).toMatchObject({ finished: true, answered: 10, current: 10 });
    expect(last.roundSummary).toMatchObject({ total: 10, correct: 7, wrong: 3, accuracyPercent: 70 });
    expect(last.roundSummary.reviewStatements).toHaveLength(3);
  });

  it('depois da 10.ª não há mais perguntas nem rodada em andamento', async () => {
    await expect(quizService.getRoundQuestion({ userId, roundId: round.id })).rejects.toThrow();
    expect(await quizService.getActiveRoundState(userId)).toBeNull();
  });

  it('a nova rodada traz 10 perguntas novas e outra categoria abandona a anterior', async () => {
    const second = await quizService.startRound({ userId, categoryId: categories[0].id });
    const secondIds = await roundQuestionIds(second.id);
    expect(second.id).not.toBe(round.id);
    expect(secondIds.every((id) => !questionIds.includes(id))).toBe(true);

    const third = await quizService.startRound({ userId, categoryId: categories[1].id });
    const { rows } = await db.query('SELECT status FROM quiz_rounds WHERE id = $1', [second.id]);
    expect(third.id).not.toBe(second.id);
    expect(rows[0].status).toBe('abandoned');
  });
});
