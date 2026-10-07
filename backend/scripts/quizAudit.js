/**
 * npm run quiz:audit                -> relatório completo (tamanho, viés, duplicadas, posição, integridade)
 * npm run quiz:audit -- --list      -> também lista ids (duplicadas, viés, integridade)
 * npm run quiz:audit -- --json      -> saída em JSON
 * npm run quiz:audit -- --strict    -> termina com código 1 se houver DEFEITOS GRAVES
 *                                      (integridade, enunciados duplicados exatos, "todas/nenhuma das anteriores")
 * SÓ LEITURA: não altera o banco. Usa DATABASE_URL como o resto do backend.
 * A sequência de posições usa a ordem de criação aproximada (created_at, depois a ordem física);
 * o teste de distribuição (qui²) não depende da ordem.
 */
require('dotenv').config();
const db = require('../src/config/database');
const { buildAudit, formatAuditText } = require('../src/modules/quiz/validation/auditReport');

async function loadQuestions() {
  const { rows } = await db.query(
    `SELECT q.id, q.statement, q.difficulty, c.name AS category, a.label, a.is_correct, a.display_order
       FROM questions q
       JOIN categories c ON c.id = q.category_id
       JOIN question_alternatives a ON a.question_id = q.id
      WHERE q.is_active
      ORDER BY q.created_at, q.ctid, a.display_order`
  );
  const map = new Map();
  rows.forEach((r) => {
    if (!map.has(r.id)) map.set(r.id, { id: r.id, statement: r.statement, group: `${r.category} | ${r.difficulty}`, alternatives: [] });
    map.get(r.id).alternatives.push({ label: r.label, is_correct: r.is_correct });
  });
  return [...map.values()];
}

async function main() {
  const args = process.argv.slice(2);
  const audit = buildAudit(await loadQuestions());
  if (args.includes('--json')) console.log(JSON.stringify(audit, null, 2));
  else console.log(formatAuditText(audit, { list: args.includes('--list') }));
  await db.pool.end();
  if (args.includes('--strict') && audit.strictFailures > 0) process.exit(1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
