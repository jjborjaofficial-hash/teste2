/**
 * Teste de integração (PostgreSQL com migrations): TODOS os lotes de explicações de Produtividade
 * (migrations *_explicacoes_produtividade_*.sql, BE-004) foram aplicados por inteiro: cada pergunta do lote
 * tem o "Por quê?" escrito no ficheiro, com tamanho razoável, e a pergunta continua com 4 alternativas e 1 correta.
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');

const dir = path.join(__dirname, '../database/migrations');
const files = fs.readdirSync(dir).filter((f) => /^\d+_explicacoes_produtividade_.*\.sql$/.test(f)).sort();
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");

const lots = files.map((f) => {
  const sql = fs.readFileSync(path.join(dir, f), 'utf8');
  const expected = Number(/esperado: (\d+)/.exec(sql)[1]);
  const rows = [...sql.matchAll(re)].map((m) => ({ source: m[1], statement: un(m[2]), explanation: un(m[3]) }));
  return { f, expected, rows };
});

afterAll(async () => {
  await db.pool.end();
});

test('existe pelo menos um lote de explicações de Produtividade', () => {
  expect(lots.length).toBeGreaterThan(0);
});

describe.each(lots)('lote $f', ({ expected, rows }) => {
  test('traz o número de explicações anunciado, sem perguntas repetidas', () => {
    expect(rows.length).toBe(expected);
    expect(new Set(rows.map((r) => `${r.source}|${r.statement}`)).size).toBe(rows.length);
  });

  test('cada explicação tem tamanho razoável e termina em ponto', () => {
    for (const r of rows) {
      expect(r.explanation.length).toBeGreaterThanOrEqual(80);
      expect(r.explanation.length).toBeLessThanOrEqual(420);
      expect(r.explanation.trim().endsWith('.')).toBe(true);
    }
  });

  test('todas as explicações estão no banco, na pergunta certa', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        `SELECT explanation FROM questions WHERE source = $1 AND statement = $2`,
        [r.source, r.statement]
      );
      expect(found).toHaveLength(1);
      expect(found[0].explanation).toBe(r.explanation);
    }
  });

  test('as perguntas continuam com 4 alternativas e exatamente 1 correta', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        `SELECT COUNT(*)::int AS n, COUNT(*) FILTER (WHERE a.is_correct)::int AS corretas
           FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2`,
        [r.source, r.statement]
      );
      expect(found[0].n).toBe(4);
      expect(found[0].corretas).toBe(1);
    }
  });
});
