/**
 * Análise da posição da alternativa correta (BE-003, pedaço P11). SÓ LEITURA, função pura.
 *
 * Mede se a posição guardada da correta (display_order) é previsível: distribuição desigual
 * (teste do qui-quadrado), sequências longas na mesma posição e padrões que se repetem
 * (A, B, C, D, A, B, C, D…). O servidor já embaralha a ordem a cada apresentação
 * (`ORDER BY random()`), então isto protege o que está GUARDADO: o que o autor escreveu, a
 * ordem original dos seeds e qualquer dia em que o embaralhamento seja removido ou contornado.
 */

const MIN_SAMPLE = 20; // abaixo disto não há estatística que se aproveite
const MAX_LAG = 8; // padrões cíclicos de período 1 a 8
const Z_LIMIT = 4; // desvios-padrão acima do acaso para acusar padrão
const RUN_LIMIT_FACTOR = 3; // sequência longa = 3x o esperado (log) — ver longestRunLimit

// Valor crítico do qui-quadrado a 1% (tabela para df 1..5; aproximação de Wilson–Hilferty acima).
const CHI2_CRIT_1PCT = { 1: 6.635, 2: 9.21, 3: 11.345, 4: 13.277, 5: 15.086 };
function chi2Critical(df) {
  if (CHI2_CRIT_1PCT[df]) return CHI2_CRIT_1PCT[df];
  const a = 2 / (9 * df);
  return df * (1 - a + 2.326 * Math.sqrt(a)) ** 3;
}

// Sequência de uma mesma posição que seria estranha por acaso: ~ log_k(n) + folga.
function longestRunLimit(n, k) {
  return Math.ceil(Math.log(Math.max(n, 2)) / Math.log(k)) + RUN_LIMIT_FACTOR;
}

function longestRun(seq) {
  let best = 0;
  let cur = 0;
  let prev = null;
  seq.forEach((p) => {
    cur = p === prev ? cur + 1 : 1;
    prev = p;
    if (cur > best) best = cur;
  });
  return best;
}

// Melhor "repetição com atraso": proporção de vezes que seq[i] == seq[i-lag], com o z-score.
function bestLag(seq, k) {
  const p = 1 / k;
  let best = { lag: 0, matchRate: 0, z: -Infinity };
  for (let lag = 1; lag <= MAX_LAG; lag += 1) {
    const m = seq.length - lag;
    if (m < MIN_SAMPLE) break;
    let match = 0;
    for (let i = lag; i < seq.length; i += 1) if (seq[i] === seq[i - lag]) match += 1;
    const z = (match - m * p) / Math.sqrt(m * p * (1 - p));
    if (z > best.z) best = { lag, matchRate: Math.round((match / m) * 1000) / 1000, z: Math.round(z * 10) / 10 };
  }
  return best;
}

/**
 * Analisa um grupo de posições (0-based, na ordem em que as perguntas foram criadas).
 * @param {number[]} seq posições da correta
 * @param {number} k número de alternativas por pergunta neste grupo
 */
function analyzeSequence(seq, k) {
  const n = seq.length;
  const counts = Array.from({ length: k }, () => 0);
  seq.forEach((p) => {
    if (p >= 0 && p < k) counts[p] += 1;
  });
  const expected = n / k;
  const chi2 = expected ? counts.reduce((s, c) => s + (c - expected) ** 2 / expected, 0) : 0;
  const critical = chi2Critical(k - 1);
  const top = Math.max(...counts);
  const run = longestRun(seq);
  const lag = bestLag(seq, k);
  const flags = [];
  if (n < MIN_SAMPLE) {
    flags.push('amostra_pequena');
  } else {
    if (chi2 > critical) flags.push('distribuicao_desigual');
    if (run > longestRunLimit(n, k)) flags.push('sequencia_longa_na_mesma_posicao');
    if (lag.z >= Z_LIMIT) flags.push('padrao_ciclico');
  }
  return {
    n,
    k,
    counts,
    sharePct: counts.map((c) => (n ? Math.round((c / n) * 1000) / 10 : 0)),
    mostCommonPosition: counts.indexOf(top),
    mostCommonSharePct: n ? Math.round((top / n) * 1000) / 10 : 0,
    chi2: Math.round(chi2 * 100) / 100,
    chi2Critical1pct: Math.round(critical * 1000) / 1000,
    longestRun: run,
    longestRunLimit: longestRunLimit(Math.max(n, 2), k),
    bestLag: lag,
    flags,
    predictable: flags.some((f) => f !== 'amostra_pequena'),
  };
}

/**
 * @param {{id:any, group?:string, alternatives:{label:string,is_correct:boolean}[]}[]} questions
 *   Na ordem de criação (a ordem do array é a sequência analisada).
 * @returns {{overall:object, groups:Object<string,object>, flaggedGroups:string[]}}
 */
function analyzePositions(questions) {
  const byGroup = {};
  questions.forEach((q) => {
    const alts = q.alternatives || [];
    const idx = alts.findIndex((a) => a.is_correct);
    const onlyOne = alts.filter((a) => a.is_correct).length === 1;
    if (!onlyOne || idx < 0) return; // perguntas mal formadas ficam para o validador
    const key = q.group || 'geral';
    (byGroup[key] = byGroup[key] || { k: 0, seq: [] });
    byGroup[key].seq.push({ pos: idx, k: alts.length });
  });

  const groups = {};
  const flaggedGroups = [];
  const all = [];
  Object.entries(byGroup).forEach(([key, g]) => {
    // k = número de alternativas mais comum no grupo; ignora perguntas com outro k.
    const freq = {};
    g.seq.forEach((s) => (freq[s.k] = (freq[s.k] || 0) + 1));
    const k = Number(Object.entries(freq).sort((a, b) => b[1] - a[1])[0][0]);
    const seq = g.seq.filter((s) => s.k === k).map((s) => s.pos);
    groups[key] = { ...analyzeSequence(seq, k), ignoredDifferentK: g.seq.length - seq.length };
    if (groups[key].predictable) flaggedGroups.push(key);
    seq.forEach((p) => all.push({ p, k }));
  });

  const k4 = all.filter((x) => x.k === 4).map((x) => x.p);
  const overall = analyzeSequence(k4.length ? k4 : all.map((x) => x.p), k4.length ? 4 : Math.max(2, ...all.map((x) => x.k), 2));
  return { overall, groups, flaggedGroups };
}

module.exports = { analyzePositions, analyzeSequence, chi2Critical, MIN_SAMPLE };
