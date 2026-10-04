/**
 * Teste unitário (sem banco) da escolha das 10 perguntas de uma rodada.
 */
const { pickRoundQuestions } = require('../src/modules/quiz/services/roundSelection');

function makePool({ easy = 0, medium = 0, hard = 0 }) {
  const pool = [];
  let n = 0;
  for (const [difficulty, count] of Object.entries({ easy, medium, hard })) {
    for (let i = 0; i < count; i += 1) {
      n += 1;
      pool.push({ id: `q${n}`, difficulty });
    }
  }
  return pool;
}

describe('pickRoundQuestions', () => {
  it('devolve 10 perguntas distintas com mistura 4 fáceis / 4 médias / 2 difíceis', () => {
    const picked = pickRoundQuestions(makePool({ easy: 30, medium: 30, hard: 30 }), 10);
    expect(picked).toHaveLength(10);
    expect(new Set(picked.map((q) => q.id)).size).toBe(10);
    const count = (d) => picked.filter((q) => q.difficulty === d).length;
    expect([count('easy'), count('medium'), count('hard')]).toEqual([4, 4, 2]);
  });

  it('apresenta em curva suave: fáceis, depois médias, depois difíceis', () => {
    const picked = pickRoundQuestions(makePool({ easy: 30, medium: 30, hard: 30 }), 10);
    const rank = { easy: 0, medium: 1, hard: 2 };
    const ranks = picked.map((q) => rank[q.difficulty]);
    expect(ranks).toEqual([...ranks].sort((a, b) => a - b));
  });

  it('respeita a ordem de preferência do pool dentro de cada dificuldade', () => {
    const pool = makePool({ easy: 10, medium: 10, hard: 10 });
    const picked = pickRoundQuestions(pool, 10);
    // as 4 fáceis escolhidas são as 4 primeiras fáceis do pool (as "menos vistas")
    expect(picked.filter((q) => q.difficulty === 'easy').map((q) => q.id)).toEqual(['q1', 'q2', 'q3', 'q4']);
  });

  it('completa com outras dificuldades quando falta de uma', () => {
    const picked = pickRoundQuestions(makePool({ easy: 3, medium: 20, hard: 0 }), 10);
    expect(picked).toHaveLength(10);
    expect(new Set(picked.map((q) => q.id)).size).toBe(10);
    expect(picked.filter((q) => q.difficulty === 'easy')).toHaveLength(3);
  });

  it('não repete perguntas duplicadas no pool', () => {
    const pool = makePool({ easy: 5, medium: 5, hard: 5 });
    const picked = pickRoundQuestions([...pool, ...pool], 10);
    expect(new Set(picked.map((q) => q.id)).size).toBe(picked.length);
  });

  it('com menos perguntas que o tamanho devolve todas', () => {
    expect(pickRoundQuestions(makePool({ easy: 2, medium: 1 }), 10)).toHaveLength(3);
  });
});
