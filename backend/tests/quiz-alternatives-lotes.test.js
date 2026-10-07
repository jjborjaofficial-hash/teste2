/**
 * Teste de integração (PostgreSQL com migrations): TODOS os lotes de alternativas (migrations *_alternativas_*.sql,
 * BE-003) foram aplicados por inteiro, sem mexer na resposta certa, e as perguntas mexidas continuam com
 * 4 alternativas e exatamente 1 correta. Cada migration traz a lista (fonte, pergunta, posição, texto antigo, texto novo).
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');

const dir = path.join(__dirname, '../database/migrations');
const files = fs.readdirSync(dir).filter((f) => /^\d+_alternativas_.*\.sql$/.test(f)).sort();
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', (\d), '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");

const lots = files.map((f) => {
  const sql = fs.readFileSync(path.join(dir, f), 'utf8');
  const expected = Number(/esperado: (\d+)/.exec(sql)[1]);
  const rows = [...sql.matchAll(re)].map((m) => ({ source: m[1], statement: un(m[2]), pos: Number(m[3]), newLabel: un(m[5]) }));
  return { f, expected, rows };
});

afterAll(async () => {
  await db.pool.end();
});

test('existe pelo menos um lote de alternativas', () => {
  expect(lots.length).toBeGreaterThan(0);
});

describe.each(lots)('lote $f', ({ expected, rows }) => {
  test('traz o número de trocas anunciado', () => {
    expect(rows.length).toBe(expected);
  });

  test('todas as alternativas erradas novas estão no banco, na mesma posição', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        `SELECT a.label, a.is_correct
           FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 AND a.display_order = $3`,
        [r.source, r.statement, r.pos]
      );
      expect(found).toHaveLength(1);
      expect(found[0].label).toBe(r.newLabel);
      expect(found[0].is_correct).toBe(false);
    }
  });

  test('as perguntas mexidas continuam com 4 alternativas e 1 correta', async () => {
    const keys = [...new Set(rows.map((r) => `${r.source}|${r.statement}`))];
    for (const k of keys) {
      const [source, statement] = k.split('|');
      const { rows: found } = await db.query(
        `SELECT COUNT(*)::int AS n, COUNT(*) FILTER (WHERE a.is_correct)::int AS corretas
           FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2`,
        [source, statement]
      );
      expect(found[0].n).toBe(4);
      expect(found[0].corretas).toBe(1);
    }
  });
});
