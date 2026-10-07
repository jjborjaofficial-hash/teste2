/**
 * Detetor de viés nas alternativas (BE-003, pedaço P9). SÓ LEITURA, função pura (sem banco).
 *
 * Complementa `alternativesValidator.js` (que mede tamanho, explicação embutida e quase-iguais).
 * Aqui entram as pistas de LINGUAGEM e de ESTRUTURA do padrão `docs/quiz-v2-alternativas-padrao.md`
 * (regras 1, 3, 6 e 7) que denunciam a correta sem exigir conhecimento.
 *
 * Cada achado tem `severity`:
 *   - 'block': defeito claro; uma pergunta NOVA com isto não entra (ver P13).
 *   - 'warn' : sinal a rever; não bloqueia, só avisa.
 *
 * Importante: NÃO altera `analyzeQuestion`/`summarize`, para não mudar a medição histórica do
 * validador (1.457 reprovadas em 2026-10-07).
 */

const ABSOLUTE_WORDS = ['sempre', 'nunca', 'jamais', 'apenas', 'somente', 'so', 'unicamente', 'exclusivamente', 'todos', 'todas', 'nenhum', 'nenhuma', 'qualquer'];
const HEDGE_WORDS = ['geralmente', 'normalmente', 'costuma', 'costumam', 'pode', 'podem', 'podera', 'poderao', 'frequentemente', 'tipicamente'];
const HEDGE_PHRASES = ['em geral', 'na maioria', 'as vezes', 'em regra'];

// Mesma normalização do validador (minúsculas, sem acentos, sem pontuação).
const normalize = (s) =>
  String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const tokens = (s) => normalize(s).split(' ').filter(Boolean);
const wordCount = (s) => tokens(s).length;

const hasAny = (label, words, phrases = []) => {
  const t = new Set(tokens(label));
  const n = ` ${normalize(label)} `;
  return words.some((w) => t.has(w)) || phrases.some((p) => n.includes(` ${p} `));
};

// "Todas/nenhuma das anteriores" e variantes ("todas as opções", "nenhuma das opções acima").
const ALL_NONE_RE = /\b(todas|todos|nenhuma|nenhum|ambas|ambos)\s+(as|os|das|dos)?\s*(anteriores|acima|opcoes|alternativas|respostas|outras)\b/;

// Pontuação "de estrutura": vírgula, ponto e vírgula, parênteses, aspas, " e/ou ", barra.
const hasStructure = (label) => /[,;()"“”/]|\be\/ou\b/i.test(String(label || ''));

const firstWord = (label) => tokens(label)[0] || '';

/**
 * @param {{id?:string, alternatives:{label:string, is_correct:boolean}[]}} q
 * @returns {{id:any, flags:{code:string, severity:'block'|'warn', message:string}[], blockers:string[], warnings:string[], hasBias:boolean}}
 */
function detectBias(q) {
  const alts = q.alternatives || [];
  const correct = alts.filter((a) => a.is_correct);
  const wrong = alts.filter((a) => !a.is_correct);
  const flags = [];
  const add = (code, severity, message) => flags.push({ code, severity, message });

  // Regra 7: "todas/nenhuma das anteriores".
  if (alts.some((a) => ALL_NONE_RE.test(normalize(a.label)))) {
    add('todas_ou_nenhuma_das_anteriores', 'block', 'Não use "todas/nenhuma das anteriores": a posição e o formato denunciam a resposta.');
  }

  if (correct.length === 1 && wrong.length >= 2) {
    const c = correct[0].label;

    // Regra 6: absolutos só nas erradas.
    const wrongAbs = wrong.filter((a) => hasAny(a.label, ABSOLUTE_WORDS)).length;
    if (!hasAny(c, ABSOLUTE_WORDS) && wrongAbs >= 1 && wrongAbs >= Math.ceil(wrong.length / 2)) {
      add('pista_absoluta_so_nas_erradas', 'warn', 'Palavras absolutas (sempre, nunca, apenas…) aparecem só nas erradas: quem as evita acerta. Use em todas ou em nenhuma.');
    }

    // Regra 6: cautela ("geralmente", "pode") só na correta.
    if (hasAny(c, HEDGE_WORDS, HEDGE_PHRASES) && !wrong.some((a) => hasAny(a.label, HEDGE_WORDS, HEDGE_PHRASES))) {
      add('pista_cautela_so_na_correta', 'warn', 'Palavras de cautela (geralmente, pode…) aparecem só na correta. Use em todas ou em nenhuma.');
    }

    // Regra 3: estrutura (pontuação) só na correta.
    if (hasStructure(c) && !wrong.some((a) => hasStructure(a.label))) {
      add('estrutura_so_na_correta', 'warn', 'Só a correta tem vírgula, parênteses, aspas ou "e/ou". As opções devem ter a mesma forma.');
    }

    // Regra 3: todas as erradas começam igual e a correta começa diferente.
    const fw = wrong.map((a) => firstWord(a.label));
    if (wrong.length >= 2 && fw[0] && fw.every((w) => w === fw[0]) && firstWord(c) !== fw[0]) {
      add('inicio_diferente_so_na_correta', 'warn', 'As erradas começam todas igual e a correta começa de outro jeito. Use o mesmo início nas quatro.');
    }

    // Regra 1: equilíbrio de palavras (maior vs menor diferença acima de ~30%).
    const counts = alts.map((a) => wordCount(a.label));
    const max = Math.max(...counts);
    const min = Math.min(...counts);
    if (max >= 4 && (max - min) / max > 0.5) {
      add('palavras_desequilibradas', 'warn', 'A diferença de palavras entre a maior e a menor opção é grande (padrão pede até ~30%).');
    }
  }

  // Regra 7: uma opção contida noutra (só quando a menor tem 2+ palavras, para não punir siglas).
  outer: for (let i = 0; i < alts.length; i += 1) {
    for (let j = 0; j < alts.length; j += 1) {
      if (i === j) continue;
      const a = normalize(alts[i].label);
      const b = normalize(alts[j].label);
      if (a && b && a !== b && wordCount(alts[i].label) >= 2 && ` ${b} `.includes(` ${a} `)) {
        add('opcao_contida_noutra', 'warn', 'Uma opção está contida noutra; o padrão pede opções independentes.');
        break outer;
      }
    }
  }

  return {
    id: q.id,
    flags,
    blockers: flags.filter((f) => f.severity === 'block').map((f) => f.code),
    warnings: flags.filter((f) => f.severity === 'warn').map((f) => f.code),
    hasBias: flags.length > 0,
  };
}

/** Agrega por grupo: quantas perguntas têm cada tipo de pista. */
function summarizeBias(questions) {
  const groups = {};
  const flagged = [];
  questions.forEach((q) => {
    const r = detectBias(q);
    const key = q.group || 'geral';
    const g = (groups[key] = groups[key] || { total: 0, withBias: 0, byCode: {} });
    g.total += 1;
    if (r.hasBias) {
      g.withBias += 1;
      flagged.push({ id: q.id, group: key, codes: r.flags.map((f) => f.code) });
    }
    r.flags.forEach((f) => {
      g.byCode[f.code] = (g.byCode[f.code] || 0) + 1;
    });
  });
  return { total: questions.length, flaggedCount: flagged.length, groups, flagged };
}

module.exports = { detectBias, summarizeBias, ABSOLUTE_WORDS, HEDGE_WORDS };
