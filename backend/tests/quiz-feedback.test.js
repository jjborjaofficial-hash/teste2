/**
 * Teste de integração (precisa de PostgreSQL + Redis com as migrations e os seeds de perguntas
 * aplicados): feedback pedagógico devolvido DEPOIS de responder (BE-004). Garante que a resposta
 * certa e a explicação só chegam depois do envio, que batem com o banco, e que perguntas nunca
 * entregues ao utilizador não revelam a resposta (senão dava para colher respostas por id).
 * O utilizador de teste NÃO é apagado no fim (audit_logs é append-only); só rodadas e tentativas.
 */
const db = require('../src/config/database');
const quizService = require('../src/modules/quiz/services/quizService');
const quizTimerService = require('../src/modules/quiz/services/quizTimerService');

let userId;
let categories;

async function correctAlternative(questionId) {
  const { rows } = await db.query(
    'SELECT id, label FROM question_alternatives WHERE question_id = $1 AND is_correct = TRUE LIMIT 1',
    [questionId]
  );
  return rows[0];
}

async function wrongAlternativeId(questionId) {
  const { rows } = await db.query(
    'SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct = FALSE LIMIT 1',
    [questionId]
  );
  return rows[0].id;
}

async function explanationOf(questionId) {
  const { rows } = await db.query('SELECT explanation FROM questions WHERE id = $1', [questionId]);
  return rows[0].explanation;
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Feedback', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
  categories = (await db.query('SELECT id FROM categories WHERE is_active ORDER BY name')).rows;
});

afterAll(async () => {
  await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('Feedback pedagógico depois de responder (BE-004)', () => {
  it('na rodada, o erro devolve a resposta correta e a explicação do banco', async () => {
    const round = await quizService.startRound({ userId, categoryId: categories[0].id });
    const question = await quizService.getRoundQuestion({ userId, roundId: round.id });
    // a pergunta servida nunca traz o feedback
    expect(question.feedback).toBeUndefined();
    expect(question.explanation).toBeUndefined();

    const correct = await correctAlternative(question.id);
    const result = await quizService.submitAnswer({
      userId,
      questionId: question.id,
      alternativeId: await wrongAlternativeId(question.id),
      roundId: round.id,
    });

    expect(result.isCorrect).toBe(false);
    expect(result.feedback).toEqual({
      correctAlternativeId: correct.id,
      correctAlternativeLabel: correct.label,
      explanation: (await explanationOf(question.id)) || null,
    });
  });

  it('na rodada, o acerto também devolve o feedback', async () => {
    const question = await quizService.getRoundQuestion({
      userId,
      roundId: (await quizService.getActiveRoundState(userId)).id,
    });
    const correct = await correctAlternative(question.id);
    const result = await quizService.submitAnswer({
      userId,
      questionId: question.id,
      alternativeId: correct.id,
      roundId: (await quizService.getActiveRoundState(userId)).id,
    });

    expect(result.isCorrect).toBe(true);
    expect(result.feedback.correctAlternativeId).toBe(correct.id);
    expect(result.feedback.correctAlternativeLabel).toBe(correct.label);
  });

  it('devolve o texto da explicação quando a pergunta já tem uma escrita', async () => {
    const { rows } = await db.query(
      'SELECT id, time_limit_seconds FROM questions WHERE explanation IS NOT NULL AND is_active LIMIT 1'
    );
    if (rows.length === 0) return; // banco sem explicações escritas: nada a verificar aqui
    const [q] = rows;
    // fora da rodada, o feedback exige que a pergunta tenha sido entregue (registro do cronómetro)
    await quizTimerService.markQuestionIssued(userId, q.id, q.time_limit_seconds);
    const result = await quizService.submitAnswer({
      userId,
      questionId: q.id,
      alternativeId: await wrongAlternativeId(q.id),
    });
    expect(typeof result.feedback.explanation).toBe('string');
    expect(result.feedback.explanation.length).toBeGreaterThan(20);
  });

  it('pergunta nunca entregue ao utilizador não revela a resposta correta', async () => {
    const { rows } = await db.query('SELECT id FROM questions WHERE is_active ORDER BY random() LIMIT 1');
    const questionId = rows[0].id;
    const result = await quizService.submitAnswer({
      userId,
      questionId,
      alternativeId: await wrongAlternativeId(questionId),
    });
    expect(result.timeExpired).toBe(true);
    expect(result.feedback).toBeNull();
  });
});
