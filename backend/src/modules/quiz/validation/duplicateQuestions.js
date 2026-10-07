/**
 * Deteção de perguntas duplicadas ou quase iguais (BE-003, pedaço P10). SÓ LEITURA, função pura.
 *
 * Duas perguntas com o mesmo enunciado (ou quase) deixam o jogador ver a mesma coisa duas vezes
 * e, pior, deixam quem já viu a resposta acertar de graça. Compara o ENUNCIADO (normalizado, sem
 * acentos nem pontuação) e ignora palavras de ligação ("de", "que", "qual"…), que enchem a
 * semelhança sem dizer nada.
 */

const DEFAULT_THRESHOLD = 0.85;

const STOPWORDS = new Set([
  'a', 'o', 'as', 'os', 'um', 'uma', 'uns', 'umas', 'de', 'da', 'do', 'das', 'dos', 'em', 'no', 'na', 'nos', 'nas',
  'e', 'ou', 'que', 'qual', 'quais', 'para', 'por', 'com', 'se', 'ao', 'aos', 'como', 'e', 'sao', 'ser', 'mais', 'ja',
]);

const normalize = (s) =>
  String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const keyTokens = (s) => normalize(s).split(' ').filter((w) => w && !STOPWORDS.has(w));

function jaccard(A, B) {
  if (!A.size && !B.size) return 1;
  let inter = 0;
  A.forEach((w) => B.has(w) && (inter += 1));
  return inter / (A.size + B.size - inter);
}

/**
 * Para validar UMA pergunta nova/editada contra as existentes.
 * @param {string} statement
 * @param {{id:string, statement:string}[]} existing
 * @param {{threshold?:number, excludeId?:string}} [opts]
 * @returns {{id:string, similarity:number, exact:boolean}|null} o duplicado mais parecido, ou null
 */
function findDuplicateOf(statement, existing, opts = {}) {
  const threshold = opts.threshold ?? DEFAULT_THRESHOLD;
  const norm = normalize(statement);
  const A = new Set(keyTokens(statement));
  if (!norm) return null;
  let best = null;
  (existing || []).forEach((e) => {
    if (opts.excludeId && String(e.id) === String(opts.excludeId)) return;
    const en = normalize(e.statement);
    if (!en) return;
    const exact = en === norm;
    const sim = exact ? 1 : jaccard(A, new Set(keyTokens(e.statement)));
    if ((exact || sim >= threshold) && (!best || sim > best.similarity)) {
      best = { id: e.id, similarity: Math.round(sim * 100) / 100, exact };
    }
  });
  return best;
}

/**
 * Para auditar o banco inteiro. Usa um índice por palavra para não comparar tudo com tudo
 * (só compara pares que partilham palavras), por isso aguenta dezenas de milhares de perguntas.
 * @param {{id:string, statement:string, group?:string}[]} questions
 * @returns {{exactGroups:string[][], nearPairs:{a:string,b:string,similarity:number}[], total:number}}
 */
function findDuplicateGroups(questions, opts = {}) {
  const threshold = opts.threshold ?? DEFAULT_THRESHOLD;
  const items = questions.map((q) => ({ id: q.id, norm: normalize(q.statement), tokens: new Set(keyTokens(q.statement)) }));

  // 1) Exatas: mesmo enunciado normalizado.
  const byNorm = new Map();
  items.forEach((it) => {
    if (!it.norm) return;
    if (!byNorm.has(it.norm)) byNorm.set(it.norm, []);
    byNorm.get(it.norm).push(it.id);
  });
  const exactGroups = [...byNorm.values()].filter((ids) => ids.length > 1);
  const inExact = new Set(exactGroups.flat().map(String));

  // 2) Quase iguais: candidatos = pares que partilham pelo menos 2 palavras-chave (ou 1 se só há 1).
  const index = new Map();
  items.forEach((it, i) => it.tokens.forEach((t) => {
    if (!index.has(t)) index.set(t, []);
    index.get(t).push(i);
  }));
  const nearPairs = [];
  const seen = new Set();
  items.forEach((it, i) => {
    const counts = new Map();
    it.tokens.forEach((t) => (index.get(t) || []).forEach((j) => {
      if (j > i) counts.set(j, (counts.get(j) || 0) + 1);
    }));
    counts.forEach((shared, j) => {
      const need = Math.min(2, it.tokens.size, items[j].tokens.size);
      if (shared < need) return;
      const other = items[j];
      if (it.norm === other.norm) return; // já nas exatas
      const sim = jaccard(it.tokens, other.tokens);
      const k = `${i}-${j}`;
      if (sim >= threshold && !seen.has(k)) {
        seen.add(k);
        nearPairs.push({ a: it.id, b: other.id, similarity: Math.round(sim * 100) / 100 });
      }
    });
  });
  nearPairs.sort((x, y) => y.similarity - x.similarity);

  return { total: questions.length, exactGroups, nearPairs, exactQuestionCount: inExact.size };
}

module.exports = { DEFAULT_THRESHOLD, findDuplicateOf, findDuplicateGroups, normalize, keyTokens };
