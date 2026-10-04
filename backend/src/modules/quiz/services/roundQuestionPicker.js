/**
 * Seleção das perguntas de uma rodada (instrução mestre, secção 3).
 *
 * Lógica pura (sem banco), para ser fácil de testar. Recebe as perguntas candidatas da
 * categoria e devolve os IDs das `count` escolhidas, já na ordem em que serão servidas.
 *
 * Regras:
 *  - nunca repete uma pergunta na mesma seleção;
 *  - mistura de dificuldades (por defeito 4 fáceis, 4 médias, 2 difíceis);
 *  - prefere perguntas que o utilizador NÃO viu recentemente; se faltarem, usa as vistas
 *    há mais tempo primeiro (nunca devolve menos do que o banco permite);
 *  - se uma dificuldade não tem perguntas suficientes, completa com as outras;
 *  - ordem de jogo: das mais fáceis para as mais difíceis, aleatória dentro de cada nível.
 */

const DIFFICULTY_ORDER = ['easy', 'medium', 'hard'];
const DEFAULT_MIX = { easy: 4, medium: 4, hard: 2 };
const DEFAULT_RECENT_DAYS = 14;
const DAY_MS = 24 * 60 * 60 * 1000;

function shuffle(items, random) {
  const a = items.slice();
  for (let i = a.length - 1; i > 0; i -= 1) {
    const j = Math.floor(random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/**
 * @param {{id: string, difficulty: string, lastSeenAt?: Date|string|null}[]} candidates
 * @param {{count?: number, mix?: object, recentDays?: number, now?: number, random?: () => number}} options
 * @returns {string[]} IDs na ordem de jogo
 */
function pickRoundQuestions(candidates, options = {}) {
  const {
    count = 10,
    mix = DEFAULT_MIX,
    recentDays = DEFAULT_RECENT_DAYS,
    now = Date.now(),
    random = Math.random,
  } = options;

  const cutoff = now - recentDays * DAY_MS;
  const seenAt = (c) => (c.lastSeenAt ? new Date(c.lastSeenAt).getTime() : null);

  // Mesma pergunta duas vezes na lista de candidatas nunca pode acontecer.
  const unique = [...new Map(candidates.map((c) => [c.id, c])).values()];
  if (unique.length <= count) {
    return orderForPlay(unique, random);
  }

  const isFresh = (c) => seenAt(c) === null || seenAt(c) < cutoff;
  const chosen = new Map();

  // Passo 1: cumprir a mistura por dificuldade (frescas primeiro; depois as vistas há mais tempo).
  for (const difficulty of DIFFICULTY_ORDER) {
    const want = mix[difficulty] || 0;
    const pool = unique.filter((c) => c.difficulty === difficulty);
    const fresh = shuffle(pool.filter(isFresh), random);
    const recent = pool.filter((c) => !isFresh(c)).sort((a, b) => seenAt(a) - seenAt(b));
    for (const c of [...fresh, ...recent].slice(0, want)) chosen.set(c.id, c);
  }

  // Passo 2: se faltam (dificuldade com poucas perguntas), completar com o resto do banco.
  if (chosen.size < count) {
    const rest = unique.filter((c) => !chosen.has(c.id));
    const fresh = shuffle(rest.filter(isFresh), random);
    const recent = rest.filter((c) => !isFresh(c)).sort((a, b) => seenAt(a) - seenAt(b));
    for (const c of [...fresh, ...recent]) {
      if (chosen.size >= count) break;
      chosen.set(c.id, c);
    }
  }

  // Passo 3: se a mistura pedida somava mais do que `count`, cortar sem favorecer ninguém.
  const final = [...chosen.values()].slice(0, count);
  return orderForPlay(final, random);
}

function orderForPlay(questions, random) {
  const rank = (c) => {
    const i = DIFFICULTY_ORDER.indexOf(c.difficulty);
    return i === -1 ? DIFFICULTY_ORDER.length : i;
  };
  return shuffle(questions, random)
    .sort((a, b) => rank(a) - rank(b)) // sort estável: mantém o embaralhamento dentro de cada nível
    .map((c) => c.id);
}

module.exports = { pickRoundQuestions, DEFAULT_MIX, DEFAULT_RECENT_DAYS, DIFFICULTY_ORDER };
