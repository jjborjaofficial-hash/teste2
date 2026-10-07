/**
 * Teste de integração (PostgreSQL com migrations): depois da migration 390 não sobra nenhum par de perguntas
 * ativas duplicadas ou quase iguais (BE-003, P10), nada foi apagado e cada par ficou com uma versão ativa.
 * Falha se alguém voltar a semear uma pergunta repetida.
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');
const { findDuplicateGroups } = require('../src/modules/quiz/validation/duplicateQuestions');

const sql = fs.readFileSync(path.join(__dirname, '../database/migrations/390_desativar_perguntas_duplicadas.sql'), 'utf8');
const rowRe = /^\s+\('((?:[^']|'')+)', '(\w+)', '((?:[^']|'')+)', '((?:[^']|'')+)', '(\w+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");
const pairs = [...sql.matchAll(rowRe)].map((m) => ({ dropCat: un(m[1]), dropDiff: m[2], dropStmt: un(m[3]), keepCat: un(m[4]), keepDiff: m[5], keepStmt: un(m[6]) }));
const expected = Number(/esperado: (\d+)/.exec(sql)[1]);

afterAll(async () => {
  await db.pool.end();
});

test('a migration lista o número esperado de pares', () => {
  expect(pairs).toHaveLength(expected);
});

test('nenhum par de perguntas ativas duplicadas ou quase iguais', async () => {
  const { rows } = await db.query(`SELECT id, statement FROM questions WHERE is_active`);
  const d = findDuplicateGroups(rows);
  expect(d.exactGroups).toEqual([]);
  expect(d.nearPairs).toEqual([]);
});

test.each(pairs)('par "$dropStmt": versão desativada, versão mantida ativa, nada apagado', async (p) => {
  const get = async (cat, diff, stmt) =>
    (await db.query(
      `SELECT q.is_active FROM questions q JOIN categories c ON c.id = q.category_id
        WHERE c.name = $1 AND q.difficulty = $2 AND q.statement = $3`,
      [cat, diff, stmt]
    )).rows;
  const dropped = await get(p.dropCat, p.dropDiff, p.dropStmt);
  const kept = await get(p.keepCat, p.keepDiff, p.keepStmt);
  expect(dropped).toHaveLength(1); // continua no banco (nada apagado)
  expect(dropped[0].is_active).toBe(false);
  expect(kept).toHaveLength(1);
  expect(kept[0].is_active).toBe(true);
});
