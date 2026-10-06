/**
 * npm run quiz:validate            -> relatório por categoria e dificuldade
 * npm run quiz:validate -- --list  -> também lista as perguntas que reprovam
 * npm run quiz:validate -- --json  -> saída em JSON
 * SÓ LEITURA: não altera o banco. Usa DATABASE_URL como o resto do backend.
 */
require('dotenv').config();
const db = require('../src/config/database');
const { summarize } = require('../src/modules/quiz/validation/alternativesValidator');

async function main() {
  const args = process.argv.slice(2);
  const { rows } = await db.query(
    `SELECT q.id, q.difficulty, c.name AS category, a.label, a.is_correct, a.display_order
       FROM questions q
       JOIN categories c ON c.id = q.category_id
       JOIN question_alternatives a ON a.question_id = q.id
      WHERE q.is_active
      ORDER BY q.id, a.display_order`
  );
  const map = new Map();
  rows.forEach((r) => {
    if (!map.has(r.id)) map.set(r.id, { id: r.id, group: `${r.category} | ${r.difficulty}`, alternatives: [] });
    map.get(r.id).alternatives.push({ label: r.label, is_correct: r.is_correct });
  });
  const report = summarize([...map.values()]);

  if (args.includes('--json')) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`Perguntas ativas: ${report.total}`);
    console.log(`Correta é a MAIS LONGA em ${report.longestSharePct}% (ao acaso ~25%; meta por grupo <= 35%)`);
    console.log(`Reprovam no validador: ${report.failingCount}\n`);
    Object.entries(report.groups)
      .sort(([a], [b]) => a.localeCompare(b))
      .forEach(([k, g]) =>
        console.log(`${g.meetsTarget ? 'OK ' : 'XX '} ${k.padEnd(34)} total ${String(g.total).padStart(4)}  mais longa ${String(g.longestShare).padStart(5)}%  reprovam ${g.failing}`)
      );
    if (args.includes('--list')) {
      console.log('\nReprovadas:');
      report.failing.forEach((f) => console.log(`${f.id}  ${f.group}  ${f.reasons.join(',')}`));
    }
  }
  await db.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
