/**
 * Teste de integração (PostgreSQL + Redis com as migrations e os seeds): conceitos errados por rodada (BE-005 c).
 * Os conceitos errados já ficam em quiz_attempts (round_id + question_id + is_correct), então aqui se testa a
 * EXPOSIÇÃO deles: lista completa no resumo, resumo reaberto depois de a rodada acabar e recomendações de revisão.
 * Os utilizadores de teste NÃO são apagados no fim (audit_logs é append-only); só as rodadas/tentativas deles.
 */
const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const db = require('../src/config/database');
const quizService = require('../src/modules/quiz/services/quizService');
const { roundIdParamSchema, recommendationsQuerySchema } = require('../src/modules/quiz/validators/quizValidators');

let userId;
let otherUserId;
let categories;
let round;
let finalAnswer;
const wrongIds = [];

async function newUser(name) {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status) VALUES ($1, $2, 'x', 'mpesa', 'active') RETURNING id`,
    [name, phone]
  );
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [rows[0].id]);
  return rows[0].id;
}

async function alternativeId(questionId, correct) {
  const { rows } = await db.query('SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct = $2 LIMIT 1', [questionId, correct]);
  return rows[0].id;
}

beforeAll(async () => {
  userId = await newUser('Teste Revisao A');
  otherUserId = await newUser('Teste Revisao B');
  categories = (await db.query('SELECT id, name FROM categories WHERE is_active ORDER BY name')).rows;

  round = await quizService.startRound({ userId, categoryId: categories[0].id });
  for (let i = 0; i < 10; i += 1) {
    const q = await quizService.getRoundQuestion({ userId, roundId: round.id });
    const correct = (i + 1) % 3 !== 0; // erra a 3.ª, 6.ª e 9.ª
    if (!correct) wrongIds.push(q.id);
    finalAnswer = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: await alternativeId(q.id, correct), roundId: round.id });
  }
});

afterAll(async () => {
  for (const id of [userId, otherUserId]) {
    await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [id]);
    await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [id]);
  }
  await db.pool.end();
});

describe('conceitos errados por rodada (BE-005 c)', () => {
  it('o resumo final traz TODOS os conceitos errados com o "Por quê?", e mantém reviewStatements', () => {
    const s = finalAnswer.roundSummary;
    expect(s).toMatchObject({ total: 10, correct: 7, wrong: 3 });
    expect(s.mistakes.map((m) => m.questionId)).toEqual(wrongIds);
    s.mistakes.forEach((m) => {
      expect(typeof m.statement).toBe('string');
      expect(['easy', 'medium', 'hard']).toContain(m.difficulty);
      expect(m.explanation === null || typeof m.explanation === 'string').toBe(true);
    });
    expect(s.reviewStatements).toHaveLength(3); // compatível com o frontend atual
  });

  it('o resumo não revela qual era a alternativa certa nem o que o utilizador escolheu', () => {
    expect(JSON.stringify(finalAnswer.roundSummary)).not.toMatch(/is_correct|isCorrect|alternativeId|correctAnswer/i);
  });

  it('reabre o resumo da rodada depois de terminar, igual ao da última resposta', async () => {
    const again = await quizService.getRoundSummary({ userId, roundId: round.id });
    expect(again).toEqual(finalAnswer.roundSummary);
  });

  it('recusa o resumo de uma rodada ainda em andamento, de outro utilizador e inexistente', async () => {
    await expect(quizService.getRoundSummary({ userId: otherUserId, roundId: round.id })).rejects.toMatchObject({ statusCode: 404 });
    await expect(quizService.getRoundSummary({ userId, roundId: '00000000-0000-4000-8000-000000000000' })).rejects.toMatchObject({ statusCode: 404 });
    const open = await quizService.startRound({ userId: otherUserId, categoryId: categories[0].id });
    await expect(quizService.getRoundSummary({ userId: otherUserId, roundId: open.id })).rejects.toMatchObject({ statusCode: 422 });
  });

  it('valida os parâmetros: roundId inválido e limite fora de 1 a 20 não chegam ao banco', () => {
    expect(roundIdParamSchema.safeParse({ roundId: 'abc' }).success).toBe(false);
    expect(recommendationsQuerySchema.safeParse({}).data.limit).toBe(10);
    expect(recommendationsQuerySchema.safeParse({ limit: '5' }).data.limit).toBe(5);
    expect(recommendationsQuerySchema.safeParse({ limit: '0' }).success).toBe(false);
    expect(recommendationsQuerySchema.safeParse({ limit: '21' }).success).toBe(false);
    expect(recommendationsQuerySchema.safeParse({ categoryId: 'x' }).success).toBe(false);
  });

  it('recomenda rever as 3 perguntas erradas, a mais recente primeiro, com categoria e vezes que errou', async () => {
    const rec = await quizService.getReviewRecommendations({ userId });
    expect(rec.map((r) => r.questionId)).toEqual([...wrongIds].reverse());
    rec.forEach((r) => {
      expect(r).toMatchObject({ categoryId: categories[0].id, categoryName: categories[0].name, timesMissed: 1 });
      expect(r.lastMissedAt).toBeTruthy();
    });
  });

  it('filtra por categoria e respeita o limite', async () => {
    expect(await quizService.getReviewRecommendations({ userId, categoryId: categories[1].id })).toEqual([]);
    expect(await quizService.getReviewRecommendations({ userId, categoryId: categories[0].id, limit: 2 })).toHaveLength(2);
  });

  it('cada utilizador só vê os seus próprios erros', async () => {
    expect(await quizService.getReviewRecommendations({ userId: otherUserId })).toEqual([]);
  });

  it('depois de acertar uma delas numa rodada posterior, deixa de ser sugerida', async () => {
    const solved = wrongIds[0];
    const { rows } = await db.query(
      `INSERT INTO quiz_rounds (user_id, category_id, status, total_questions, question_ids, answered_count, correct_count)
       VALUES ($1, $2, 'completed', 1, ARRAY[$3::uuid], 1, 1) RETURNING id`,
      [userId, categories[0].id, solved]
    );
    await db.query(
      `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, round_id)
       VALUES ($1, $2, $3, true, 5000, $4)`,
      [userId, solved, await alternativeId(solved, true), rows[0].id]
    );
    const rec = await quizService.getReviewRecommendations({ userId });
    expect(rec.map((r) => r.questionId)).not.toContain(solved);
    expect(rec).toHaveLength(2);
  });

  it('errar a mesma pergunta outra vez soma em timesMissed', async () => {
    const again = wrongIds[1];
    const { rows } = await db.query(
      `INSERT INTO quiz_rounds (user_id, category_id, status, total_questions, question_ids, answered_count, correct_count)
       VALUES ($1, $2, 'completed', 1, ARRAY[$3::uuid], 1, 0) RETURNING id`,
      [userId, categories[0].id, again]
    );
    await db.query(
      `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, round_id)
       VALUES ($1, $2, $3, false, 5000, $4)`,
      [userId, again, await alternativeId(again, false), rows[0].id]
    );
    const rec = await quizService.getReviewRecommendations({ userId });
    expect(rec.find((r) => r.questionId === again).timesMissed).toBe(2);
    expect(rec[0].questionId).toBe(again); // errada mais recentemente -> primeiro
  });
});

describe('rotas HTTP de revisão (BE-005 c)', () => {
  const token = () => jwt.sign({ sub: userId, trustScore: 100, status: 'active' }, process.env.JWT_ACCESS_SECRET, { expiresIn: '5m' });
  const auth = () => ({ Authorization: `Bearer ${token()}` });

  it('exigem login (401 sem token)', async () => {
    expect((await request(app).get(`/api/v1/quiz/rounds/${round.id}/summary`)).status).toBe(401);
    expect((await request(app).get('/api/v1/quiz/review/recommendations')).status).toBe(401);
  });

  it('GET /quiz/rounds/:roundId/summary devolve o resumo; id inválido dá 400; de outro utilizador dá 404', async () => {
    const ok = await request(app).get(`/api/v1/quiz/rounds/${round.id}/summary`).set(auth());
    expect(ok.status).toBe(200);
    expect(ok.body.data).toMatchObject({ total: 10, correct: 7, wrong: 3 });
    expect(ok.body.data.mistakes).toHaveLength(3);

    expect((await request(app).get('/api/v1/quiz/rounds/abc/summary').set(auth())).status).toBe(400);

    const otherToken = jwt.sign({ sub: otherUserId, trustScore: 100, status: 'active' }, process.env.JWT_ACCESS_SECRET, { expiresIn: '5m' });
    const foreign = await request(app).get(`/api/v1/quiz/rounds/${round.id}/summary`).set({ Authorization: `Bearer ${otherToken}` });
    expect(foreign.status).toBe(404);
  });

  it('GET /quiz/review/recommendations devolve a lista; limite ou categoria inválidos dão 400', async () => {
    const ok = await request(app).get('/api/v1/quiz/review/recommendations?limit=2').set(auth());
    expect(ok.status).toBe(200);
    expect(Array.isArray(ok.body.data)).toBe(true);
    expect(ok.body.data.length).toBeLessThanOrEqual(2);
    expect((await request(app).get('/api/v1/quiz/review/recommendations?limit=99').set(auth())).status).toBe(400);
    expect((await request(app).get('/api/v1/quiz/review/recommendations?categoryId=nao-e-uuid').set(auth())).status).toBe(400);
  });
});
