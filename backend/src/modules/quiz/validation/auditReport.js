/**
 * Auditoria completa do banco de perguntas (BE-003, pedaço P12). SÓ LEITURA, função pura.
 *
 * Junta os validadores num relatório só:
 *   1. alternativesValidator  — tamanho da correta, explicação embutida, quase-iguais (P0, já existia)
 *   2. biasDetector           — pistas de linguagem e estrutura (P9)
 *   3. duplicateQuestions     — perguntas duplicadas ou quase iguais (P10)
 *   4. positionAnalysis       — posição previsível da correta (P11)
 *   5. integridade            — nº de alternativas, uma só correta, opções vazias
 *
 * `strictFailures` conta só os defeitos GRAVES (integridade, enunciados duplicados exatos,
 * "todas/nenhuma das anteriores"). O resto (tamanho, avisos de viés) é meta de qualidade
 * em andamento: continua informativo, como decidido em BE-003 passo 5.
 */
const { summarize } = require('./alternativesValidator');
const { summarizeBias } = require('./biasDetector');
const { findDuplicateGroups } = require('./duplicateQuestions');
const { analyzePositions } = require('./positionAnalysis');

function checkIntegrity(questions) {
  const problems = [];
  questions.forEach((q) => {
    const alts = q.alternatives || [];
    const correct = alts.filter((a) => a.is_correct).length;
    const codes = [];
    if (alts.length < 2) codes.push('menos_de_2_alternativas');
    if (correct !== 1) codes.push(`corretas_${correct}`);
    if (alts.some((a) => !String(a.label || '').trim())) codes.push('alternativa_vazia');
    if (!String(q.statement || '').trim()) codes.push('enunciado_vazio');
    if (codes.length) problems.push({ id: q.id, group: q.group || 'geral', codes });
  });
  return problems;
}

/**
 * @param {{id:any, group?:string, statement?:string, alternatives:{label:string,is_correct:boolean}[]}[]} questions
 *   Na ordem de criação (a análise de sequência usa a ordem do array).
 */
function buildAudit(questions) {
  const validator = summarize(questions);
  const bias = summarizeBias(questions);
  const duplicates = findDuplicateGroups(questions);
  const positions = analyzePositions(questions);
  const integrity = checkIntegrity(questions);

  const blockerBias = bias.flagged.filter((f) => f.codes.includes('todas_ou_nenhuma_das_anteriores'));
  const strictFailures = integrity.length + duplicates.exactGroups.length + blockerBias.length;

  return {
    total: questions.length,
    validator,
    bias,
    duplicates,
    positions,
    integrity,
    strictFailures,
    strictBreakdown: {
      integridade: integrity.length,
      enunciadosDuplicadosExatos: duplicates.exactGroups.length,
      todasOuNenhumaDasAnteriores: blockerBias.length,
    },
  };
}

const pad = (s, n) => String(s).padEnd(n);
const padL = (s, n) => String(s).padStart(n);

/** Relatório em texto (o mesmo que o CI mostra). `list` acrescenta as listas de ids. */
function formatAuditText(a, { list = false } = {}) {
  const L = [];
  L.push(`AUDITORIA DO BANCO DE PERGUNTAS — ${a.total} perguntas ativas`);
  L.push('');
  L.push('1) Tamanho da correta (validador)');
  L.push(`   Correta é a mais longa em ${a.validator.longestSharePct}% (ao acaso ~25%; meta por grupo <= 35%). Reprovam: ${a.validator.failingCount}`);
  L.push('');
  L.push('2) Viés de linguagem e estrutura (P9)');
  L.push(`   Perguntas com pelo menos uma pista: ${a.bias.flaggedCount} de ${a.total}`);
  const totals = {};
  Object.values(a.bias.groups).forEach((g) => Object.entries(g.byCode).forEach(([c, n]) => (totals[c] = (totals[c] || 0) + n)));
  Object.entries(totals).sort((x, y) => y[1] - x[1]).forEach(([c, n]) => L.push(`   ${pad(c, 36)} ${padL(n, 5)}`));
  L.push('');
  L.push('3) Perguntas duplicadas (P10)');
  L.push(`   Enunciados idênticos: ${a.duplicates.exactGroups.length} grupos (${a.duplicates.exactQuestionCount} perguntas). Quase iguais: ${a.duplicates.nearPairs.length} pares.`);
  L.push('');
  L.push('4) Posição da correta (P11) — ordem guardada; o servidor embaralha ao servir');
  const o = a.positions.overall;
  L.push(`   Geral: ${o.sharePct.map((p, i) => `${String.fromCharCode(65 + i)} ${p}%`).join('  ')}  qui² ${o.chi2} (limite 1%: ${o.chi2Critical1pct})  maior sequência ${o.longestRun}`);
  L.push(`   Grupos com posição previsível: ${a.positions.flaggedGroups.length}`);
  Object.entries(a.positions.groups)
    .filter(([, g]) => g.predictable)
    .forEach(([k, g]) => L.push(`   XX ${pad(k, 32)} n ${padL(g.n, 4)}  ${g.flags.join(', ')}`));
  L.push('');
  L.push('5) Integridade');
  L.push(`   Perguntas com defeito estrutural: ${a.integrity.length}`);
  L.push('');
  L.push(`DEFEITOS GRAVES (--strict falha se > 0): ${a.strictFailures}`);
  L.push(`   integridade ${a.strictBreakdown.integridade} | enunciados duplicados exatos ${a.strictBreakdown.enunciadosDuplicadosExatos} | "todas/nenhuma das anteriores" ${a.strictBreakdown.todasOuNenhumaDasAnteriores}`);

  if (list) {
    L.push('');
    if (a.integrity.length) {
      L.push('Integridade:');
      a.integrity.forEach((p) => L.push(`  ${p.id}  ${p.group}  ${p.codes.join(',')}`));
    }
    if (a.duplicates.exactGroups.length) {
      L.push('Enunciados idênticos (ids por grupo):');
      a.duplicates.exactGroups.forEach((g) => L.push(`  ${g.join(' = ')}`));
    }
    if (a.duplicates.nearPairs.length) {
      L.push('Quase iguais (mais parecidos primeiro, até 50):');
      a.duplicates.nearPairs.slice(0, 50).forEach((p) => L.push(`  ${p.a} ~ ${p.b}  ${p.similarity}`));
    }
    if (a.bias.flagged.length) {
      L.push('Viés (até 100 perguntas):');
      a.bias.flagged.slice(0, 100).forEach((f) => L.push(`  ${f.id}  ${f.group}  ${f.codes.join(',')}`));
    }
  }
  return L.join('\n');
}

module.exports = { buildAudit, formatAuditText, checkIntegrity };
