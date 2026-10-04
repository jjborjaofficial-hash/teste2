/**
 * Escolha das perguntas de uma rodada (função pura, sem banco — fácil de testar).
 *
 * Recebe o "pool" já ordenado por preferência pelo repositório (nunca vistas primeiro,
 * depois as vistas há mais tempo; empates aleatórios) e devolve `size` perguntas:
 *  - com diversidade de dificuldade (≈40% fáceis, 40% médias, 20% difíceis);
 *  - sem repetir nenhuma dentro da rodada;
 *  - se faltar de uma dificuldade, completa com as outras pela mesma ordem de preferência;
 *  - apresentadas em curva suave (fáceis -> médias -> difíceis), o que também ajuda a
 *    aprendizagem; a ordem DENTRO de cada dificuldade segue a preferência já aleatória.
 */
const DIFFICULTY_ORDER = ['easy', 'medium', 'hard'];
const DIFFICULTY_SHARE = { easy: 0.4, medium: 0.4, hard: 0.2 };

function pickRoundQuestions(pool, size) {
  const unique = [];
  const seen = new Set();
  for (const q of pool) {
    if (!seen.has(q.id)) {
      seen.add(q.id);
      unique.push(q);
    }
  }
  if (unique.length <= size) return sortByDifficulty(unique);

  const byDifficulty = Object.fromEntries(DIFFICULTY_ORDER.map((d) => [d, []]));
  for (const q of unique) (byDifficulty[q.difficulty] || byDifficulty.medium).push(q);

  const chosen = [];
  const chosenIds = new Set();
  const take = (q) => {
    chosen.push(q);
    chosenIds.add(q.id);
  };

  // 1) cota por dificuldade (arredondando; o resto completa abaixo)
  for (const d of DIFFICULTY_ORDER) {
    const quota = Math.round(size * DIFFICULTY_SHARE[d]);
    for (const q of byDifficulty[d].slice(0, quota)) {
      if (chosen.length < size) take(q);
    }
  }
  // 2) o que faltar sai do pool inteiro pela ordem de preferência
  for (const q of unique) {
    if (chosen.length >= size) break;
    if (!chosenIds.has(q.id)) take(q);
  }

  return sortByDifficulty(chosen);
}

function sortByDifficulty(list) {
  const rank = (q) => {
    const i = DIFFICULTY_ORDER.indexOf(q.difficulty);
    return i === -1 ? 1 : i;
  };
  // sort estável: dentro da mesma dificuldade mantém a ordem de preferência
  return list
    .map((q, index) => ({ q, index }))
    .sort((a, b) => rank(a.q) - rank(b.q) || a.index - b.index)
    .map(({ q }) => q);
}

module.exports = { pickRoundQuestions, DIFFICULTY_ORDER };
