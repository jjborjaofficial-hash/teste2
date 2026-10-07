/**
 * Teste de integração (PostgreSQL com migrations): as explicações reescritas junto com o lote 4 de alternativas
 * de Finanças fácil (migration 144, regra 9 do padrão) estão no banco com o texto novo, e nenhuma delas cita
 * mais as alternativas erradas antigas. A migration traz, no segundo bloco, a lista (fonte, pergunta, texto
 * antigo, texto novo).
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');

const sql = fs.readFileSync(
  path.join(__dirname, '../database/migrations/144_alternativas_financas_facil_lote04.sql'),
  'utf8'
);
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");
const rows = [...sql.matchAll(re)].map((m) => ({ source: m[1], statement: un(m[2]), oldText: un(m[3]), newText: un(m[4]) }));
const announced = Number(/previstas: (\d+)/.exec(sql)[1]);

afterAll(async () => {
  await db.pool.end();
});

test('a migration traz o número de explicações anunciado', () => {
  expect(rows.length).toBe(announced);
  expect(rows.length).toBeGreaterThan(0);
});

test('cada explicação reescrita está no banco com o texto novo, e a pergunta continua ativa', async () => {
  for (const r of rows) {
    const { rows: found } = await db.query(
      'SELECT explanation, is_active FROM questions WHERE source = $1 AND statement = $2',
      [r.source, r.statement]
    );
    expect(found).toHaveLength(1);
    expect(found[0].explanation).toBe(r.newText);
    expect(found[0].is_active).toBe(true);
  }
});

test('o texto novo nunca é igual ao antigo (houve mesmo reescrita)', () => {
  for (const r of rows) expect(r.newText).not.toBe(r.oldText);
});
