/**
 * Teste de integração (PostgreSQL com migrations): as explicações reescritas junto com cada lote de alternativas
 * (regra 9 do padrão: explicações que citavam as erradas antigas) estão no banco com o texto novo, e as perguntas
 * continuam ativas (exceto as desativadas de propósito por duplicadas, migration 390). Cada migration *_alternativas_*.sql que reescreve explicações traz, num segundo bloco, a
 * lista (fonte, pergunta, texto antigo, texto novo) e o total em "previstas: N".
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');

const dir = path.join(__dirname, '../database/migrations');
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");

// Perguntas desativadas DE PROPÓSITO por serem duplicadas (migration 390, BE-003 P10): continuam no banco com a
// explicação nova, mas inativas. Qualquer outra pergunta de um lote tem de continuar ativa.
const dedupSql = fs.readFileSync(path.join(dir, '390_desativar_perguntas_duplicadas.sql'), 'utf8');
const dedupRe = /^\s+\('(?:[^']|'')+', '(\w+)', '((?:[^']|'')+)', '(?:[^']|'')+', '\w+', '(?:[^']|'')+'\),?$/gm;
const deactivatedOnPurpose = new Set([...dedupSql.matchAll(dedupRe)].map((m) => `${m[1]}|${un(m[2])}`));

const lots = fs
  .readdirSync(dir)
  .filter((f) => /^\d+_alternativas_.*\.sql$/.test(f))
  .sort()
  .map((f) => {
    const sql = fs.readFileSync(path.join(dir, f), 'utf8');
    const m = /previstas: (\d+)/.exec(sql);
    if (!m) return null; // lote que só mexeu em alternativas
    const rows = [...sql.matchAll(re)].map((x) => ({ source: x[1], statement: un(x[2]), oldText: un(x[3]), newText: un(x[4]) }));
    return { f, announced: Number(m[1]), rows };
  })
  .filter(Boolean);

afterAll(async () => {
  await db.pool.end();
});

test('existe pelo menos um lote que reescreveu explicações', () => {
  expect(lots.length).toBeGreaterThan(0);
});

describe.each(lots)('lote $f', ({ announced, rows }) => {
  test('traz o número de explicações anunciado', () => {
    expect(rows.length).toBe(announced);
  });

  test('cada explicação reescrita está no banco com o texto novo, e a pergunta continua ativa', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        'SELECT explanation, is_active, difficulty FROM questions WHERE source = $1 AND statement = $2',
        [r.source, r.statement]
      );
      expect(found).toHaveLength(1);
      expect(found[0].explanation).toBe(r.newText);
      expect(found[0].is_active).toBe(!deactivatedOnPurpose.has(`${found[0].difficulty}|${r.statement}`));
    }
  });

  test('o texto novo nunca é igual ao antigo (houve mesmo reescrita)', () => {
    for (const r of rows) expect(r.newText).not.toBe(r.oldText);
  });
});
