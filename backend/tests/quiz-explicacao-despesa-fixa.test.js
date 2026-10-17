/** Migration 704: a explicação da pergunta "despesa fixa" deixa de citar a alternativa antiga; a certa não muda. */
const db = require('../src/config/database');

afterAll(async () => { await db.pool.end(); });

test('explicação atualizada e resposta certa intacta', async () => {
  const { rows } = await db.query(
    `SELECT q.explanation, a.label, a.is_correct FROM questions q JOIN question_alternatives a ON a.question_id = q.id
      WHERE q.source = 'seed_financas_facil_v1' AND q.statement = 'Qual destes é um exemplo de despesa fixa?'`
  );
  expect(rows).toHaveLength(4);
  expect(rows[0].explanation).toContain('compra de roupa');
  expect(rows[0].explanation).not.toContain('compra ocasional de roupa');
  const correct = rows.filter((r) => r.is_correct);
  expect(correct).toHaveLength(1);
  expect(correct[0].label).toBe('Aluguel');
  expect(rows.map((r) => r.label)).toContain('Compra de roupa');
});
