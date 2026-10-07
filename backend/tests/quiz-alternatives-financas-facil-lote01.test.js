/**
 * Teste de integração (PostgreSQL com migrations): o lote 1 de alternativas de Finanças fácil (migration 141)
 * aplicou todas as trocas, não mexeu na resposta certa e deixou as perguntas com 4 alternativas e 1 correta.
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');

const sql = fs.readFileSync(
  path.join(__dirname, '../database/migrations/141_alternativas_financas_facil_lote01.sql'),
  'utf8'
);
const rows = [...sql.matchAll(/^\s+\('seed_financas_facil_v1', '((?:[^']|'')+)', (\d), '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm)].map(
  (m) => ({ statement: m[1].replace(/''/g, "'"), pos: Number(m[2]), oldLabel: m[3].replace(/''/g, "'"), newLabel: m[4].replace(/''/g, "'") })
);

afterAll(async () => {
  await db.pool.end();
});

test('a migration traz as 56 trocas esperadas', () => {
  expect(rows.length).toBe(56);
});

test('todas as alternativas erradas novas estão no banco, na mesma posição', async () => {
  for (const r of rows) {
    const { rows: found } = await db.query(
      `SELECT a.label, a.is_correct
         FROM questions q JOIN question_alternatives a ON a.question_id = q.id
        WHERE q.source = 'seed_financas_facil_v1' AND q.statement = $1 AND a.display_order = $2`,
      [r.statement, r.pos]
    );
    expect(found).toHaveLength(1);
    expect(found[0].label).toBe(r.newLabel);
    expect(found[0].is_correct).toBe(false);
  }
});

test('as perguntas mexidas continuam com 4 alternativas e exatamente 1 correta', async () => {
  const statements = [...new Set(rows.map((r) => r.statement))];
  for (const s of statements) {
    const { rows: found } = await db.query(
      `SELECT COUNT(*)::int AS n, COUNT(*) FILTER (WHERE a.is_correct)::int AS corretas
         FROM questions q JOIN question_alternatives a ON a.question_id = q.id
        WHERE q.source = 'seed_financas_facil_v1' AND q.statement = $1`,
      [s]
    );
    expect(found[0].n).toBe(4);
    expect(found[0].corretas).toBe(1);
  }
});
