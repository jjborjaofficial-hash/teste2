/**
 * Teste de integração (PostgreSQL com migrations e seeds): a ordem das alternativas entregues ao
 * jogador é aleatória a cada apresentação e nunca perde nem troca alternativas (BE-003).
 */
const db = require('../src/config/database');
const quizRepository = require('../src/modules/quiz/repositories/quizRepository');

afterAll(async () => {
  await db.pool.end();
});

test('a ordem das alternativas varia entre apresentações, com o mesmo conjunto de ids', async () => {
  const { rows } = await db.query(
    `SELECT q.id, q.category_id FROM questions q
      WHERE q.is_active AND (SELECT COUNT(*) FROM question_alternatives a WHERE a.question_id = q.id) = 4
      LIMIT 1`
  );
  expect(rows[0]).toBeDefined();
  const orders = new Set();
  let ids;
  for (let i = 0; i < 40; i += 1) {
    const q = await quizRepository.getQuestionById(rows[0].id, rows[0].category_id);
    const list = q.alternatives.map((a) => a.id);
    ids = ids || [...list].sort().join();
    expect([...list].sort().join()).toBe(ids); // mesmas alternativas, só muda a ordem
    orders.add(list.join());
  }
  // 4 opções = 24 ordens possíveis; em 40 sorteios, ver só 1 ordem é praticamente impossível.
  expect(orders.size).toBeGreaterThan(5);
});

test('a posição da correta é distribuída pelas 4 posições', async () => {
  const { rows } = await db.query(
    `SELECT q.id, q.category_id FROM questions q
      WHERE q.is_active AND (SELECT COUNT(*) FROM question_alternatives a WHERE a.question_id = q.id) = 4
      LIMIT 1`
  );
  const correct = (
    await db.query('SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct', [rows[0].id])
  ).rows[0].id;
  const positions = new Set();
  for (let i = 0; i < 60; i += 1) {
    const q = await quizRepository.getQuestionById(rows[0].id, rows[0].category_id);
    positions.add(q.alternatives.findIndex((a) => a.id === correct));
  }
  expect(positions.size).toBe(4);
});
