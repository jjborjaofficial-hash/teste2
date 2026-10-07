/**
 * Validador das alternativas do quiz (BE-003). SÓ LEITURA: mede, não altera nada.
 * Problema que combate: a alternativa correta denuncia-se pelo tamanho/detalhe
 * (medido: a mais longa em ~90,8% das perguntas; ao acaso seria ~25%).
 *
 * Função pura (sem banco), por isso é testável em qualquer lugar. O script
 * `npm run quiz:validate` busca os dados no banco e usa estas funções.
 */

// Critérios (o dono pode ajustar aqui, em um só lugar).
const CRITERIA = {
  // Reprova se a correta é a mais longa E passa esta razão sobre a média das erradas.
  longestRatio: 1.3,
  // Simétrico: reprova se a correta é a mais CURTA E fica abaixo desta razão da média das
  // erradas (o jogador passaria a acertar escolhendo sempre a mais curta; sobretudo ao
  // "enxugar" as corretas nos lotes de correção, para não trocar um padrão por outro).
  shortestRatio: 0.75,
  // Meta por categoria + dificuldade: correta mais longa em no máximo esta fração.
  targetLongestShare: 0.35,
  // "Quase igual": semelhança mínima entre duas alternativas para serem consideradas duplicadas.
  nearDuplicateSimilarity: 0.9,
};

const normalize = (s) =>
  String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const wordCount = (s) => (String(s || '').trim() ? String(s).trim().split(/\s+/).length : 0);

// Semelhança 0..1 por palavras (Jaccard); suficiente para apanhar duplicadas e quase iguais.
function similarity(a, b) {
  const A = new Set(normalize(a).split(' ').filter(Boolean));
  const B = new Set(normalize(b).split(' ').filter(Boolean));
  if (!A.size && !B.size) return 1;
  let inter = 0;
  A.forEach((w) => B.has(w) && (inter += 1));
  return inter / (A.size + B.size - inter);
}

// Explicação embutida na correta: parênteses, travessão/dois-pontos ou "porque/pois/ou seja".
function hasEmbeddedExplanation(label) {
  // Um "Porque" no INÍCIO da alternativa é a resposta natural a uma pergunta "Por que…?" e não conta como
  // explicação embutida; só conta quando aparece no meio ("X, porque Y"). Corrigido após a auditoria de Finanças
  // (9 falsos alarmes em perguntas "Por que…?"): o portão de perguntas novas recusaria qualquer "Por que…?" bem escrita.
  const text = String(label || '').replace(/^\s*porque\s+/i, '');
  return /\(|\s[—–-]\s|:|\b(porque|pois|ou seja|isto e|isto é)\b/i.test(text);
}

/**
 * @param {{id:string, statement?:string, alternatives:{label:string, is_correct:boolean}[]}} q
 * @returns {object} medidas e motivos de reprovação da pergunta
 */
function analyzeQuestion(q, criteria = CRITERIA) {
  const alts = q.alternatives || [];
  const correct = alts.filter((a) => a.is_correct);
  const wrong = alts.filter((a) => !a.is_correct);
  const reasons = [];

  if (alts.length < 2) reasons.push('menos_de_2_alternativas');
  if (correct.length !== 1) reasons.push(`corretas_${correct.length}`);

  const correctLen = correct[0] ? String(correct[0].label).length : 0;
  const wrongLens = wrong.map((a) => String(a.label).length);
  const wrongAvg = wrongLens.length ? wrongLens.reduce((x, y) => x + y, 0) / wrongLens.length : 0;
  const maxWrong = wrongLens.length ? Math.max(...wrongLens) : 0;
  const minWrong = wrongLens.length ? Math.min(...wrongLens) : 0;

  const correctIsLongest = correct.length === 1 && correctLen > maxWrong;
  const correctIsShortest = correct.length === 1 && wrongLens.length > 0 && correctLen < minWrong;
  const ratio = wrongAvg ? correctLen / wrongAvg : 0;

  if (correctIsLongest && ratio >= criteria.longestRatio) reasons.push('correta_mais_longa_destacada');
  if (correctIsShortest && ratio <= criteria.shortestRatio) reasons.push('correta_muito_mais_curta');
  if (correct[0] && hasEmbeddedExplanation(correct[0].label)) reasons.push('explicacao_embutida_na_correta');

  for (let i = 0; i < alts.length; i += 1) {
    for (let j = i + 1; j < alts.length; j += 1) {
      if (similarity(alts[i].label, alts[j].label) >= criteria.nearDuplicateSimilarity) {
        reasons.push('alternativas_duplicadas_ou_quase_iguais');
        i = alts.length;
        break;
      }
    }
  }

  const position = alts.findIndex((a) => a.is_correct); // 0-based na ordem recebida

  return {
    id: q.id,
    alternativesCount: alts.length,
    correctCount: correct.length,
    correctChars: correctLen,
    correctWords: correct[0] ? wordCount(correct[0].label) : 0,
    wrongAvgChars: Math.round(wrongAvg * 10) / 10,
    ratio: Math.round(ratio * 100) / 100,
    correctIsLongest,
    correctIsShortest,
    correctPosition: position,
    reasons,
    passes: reasons.length === 0,
  };
}

/**
 * Agrega por grupo (ex.: "Finanças | easy"). `questions` traz `group` já preenchido.
 */
function summarize(questions, criteria = CRITERIA) {
  const groups = {};
  const failing = [];
  questions.forEach((q) => {
    const r = analyzeQuestion(q, criteria);
    const key = q.group || 'geral';
    const g = (groups[key] = groups[key] || { total: 0, longest: 0, shortest: 0, failing: 0, positions: {} });
    g.total += 1;
    if (r.correctIsLongest) g.longest += 1;
    if (r.correctIsShortest) g.shortest += 1;
    if (!r.passes) {
      g.failing += 1;
      failing.push({ ...r, group: key });
    }
    g.positions[r.correctPosition] = (g.positions[r.correctPosition] || 0) + 1;
  });
  Object.values(groups).forEach((g) => {
    g.longestShare = g.total ? Math.round((g.longest / g.total) * 1000) / 10 : 0; // %
    g.meetsTarget = g.total ? g.longest / g.total <= criteria.targetLongestShare : true;
  });
  const total = questions.length;
  const longest = Object.values(groups).reduce((n, g) => n + g.longest, 0);
  return {
    total,
    longest,
    longestSharePct: total ? Math.round((longest / total) * 1000) / 10 : 0,
    failingCount: failing.length,
    groups,
    failing,
  };
}

module.exports = { CRITERIA, analyzeQuestion, summarize, similarity, hasEmbeddedExplanation };
