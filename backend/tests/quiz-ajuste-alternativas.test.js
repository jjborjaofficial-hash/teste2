/**
 * Teste de integração (PostgreSQL com migrations): ajustes de alternativas posteriores aos lotes
 * (migrations *_ajuste_alternativas_*.sql, BE-003). Garante que o texto novo está no banco, que a CERTA e a EXPLICAÇÃO não
 * mudaram, que as perguntas continuam com 4 alternativas e 1 correta, e que o validador já não as assinala.
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');
const { analyzeQuestion } = require('../src/modules/quiz/validation/alternativesValidator');
const { detectBias } = require('../src/modules/quiz/validation/biasDetector');

const dir = path.join(__dirname, '../database/migrations');
const files = fs.readdirSync(dir).filter((f) => /^\d+_ajuste_alternativas_.*\.sql$/.test(f)).sort();
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', (\d), '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");
const adjustments = files.map((f) => {
  const sql = fs.readFileSync(path.join(dir, f), 'utf8');
  const expected = Number(/esperado: (\d+)/.exec(sql)[1]);
  const rows = [...sql.matchAll(re)].map((m) => ({ source: m[1], statement: un(m[2]), pos: Number(m[3]), oldLabel: un(m[4]), newLabel: un(m[5]) }));
  return { f, expected, rows };
});

// Certas e explicações que NÃO podem mudar (regra do dono), conferidas por texto.
const CORRECT = {
  'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?': 'A margem de lucro pode diminuir',
  'O que é inflação esperada?': 'Previsão de aumento dos preços no futuro',
  'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?': 'Pode diminuir',
  'Como uma taxa de juros alta pode afetar empréstimos?': 'Pode tornar o crédito mais caro',
  'O que é um conjunto de validação em Machine Learning?': 'Dados utilizados para avaliar e ajustar escolhas do modelo durante o desenvolvimento',
  'Em criptografia assimétrica, qual característica é correta?': 'Utiliza um par de chaves relacionadas, normalmente uma pública e uma privada',
  'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?': 'Regularização',
  'O que é computação em nuvem híbrida?': 'Modelo que combina infraestrutura local com serviços de nuvem',
  'O que é consistência eventual?': 'Modelo em que réplicas podem ficar temporariamente diferentes, mas tendem a convergir',
  'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?': 'A simétrica utiliza uma chave compartilhada para cifrar e decifrar, enquanto a assimétrica utiliza um par de chaves',
  'Qual é a principal finalidade de uma arquitetura de microsserviços?': 'Dividir uma aplicação grande em pequenos serviços independentes que comunicam entre si',
};

afterAll(async () => {
  await db.pool.end();
});

test('existe pelo menos um ajuste', () => {
  expect(adjustments.length).toBeGreaterThan(0);
});

describe.each(adjustments)('ajuste $f', ({ expected, rows }) => {
  test('traz o número de trocas anunciado', () => {
    expect(rows.length).toBe(expected);
  });

  test('o texto novo está no banco, em alternativas erradas, na mesma posição', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        `SELECT a.label, a.is_correct FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 AND a.display_order = $3`,
        [r.source, r.statement, r.pos]
      );
      expect(found).toHaveLength(1);
      expect(found[0].label).toBe(r.newLabel);
      expect(found[0].is_correct).toBe(false);
    }
  });

  test('a certa não mudou, as perguntas mantêm 4 alternativas e 1 correta, e a explicação continua preenchida', async () => {
    const keys = [...new Set(rows.map((r) => `${r.source}|${r.statement}`))];
    for (const k of keys) {
      const [source, statement] = k.split('|');
      const { rows: alts } = await db.query(
        `SELECT a.label, a.is_correct, q.explanation FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 ORDER BY a.display_order`,
        [source, statement]
      );
      expect(alts).toHaveLength(4);
      expect(alts.filter((a) => a.is_correct)).toHaveLength(1);
      expect(alts.find((a) => a.is_correct).label).toBe(CORRECT[statement]);
      expect(alts[0].explanation).toBeTruthy();
    }
  });

  test('o validador já não assinala estas perguntas e não há bloqueio de viés', async () => {
    const keys = [...new Set(rows.map((r) => `${r.source}|${r.statement}`))];
    for (const k of keys) {
      const [source, statement] = k.split('|');
      const { rows: alts } = await db.query(
        `SELECT a.label, a.is_correct FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 ORDER BY a.display_order`,
        [source, statement]
      );
      const q = { id: k, alternatives: alts };
      expect(analyzeQuestion(q).reasons).toEqual([]);
      expect(detectBias(q).blockers).toEqual([]);
    }
  });
});
