const { pickRoundQuestions } = require('../src/modules/quiz/services/roundQuestionPicker');

const NOW = Date.UTC(2026, 9, 4);
const daysAgo = (d) => new Date(NOW - d * 24 * 60 * 60 * 1000);

/** Gerador pseudoaleatório determinístico (para testes repetíveis). */
function seeded(seed) {
  let s = seed;
  return () => {
    s = (s * 1664525 + 1013904223) % 4294967296;
    return s / 4294967296;
  };
}

function pool({ easy = 0, medium = 0, hard = 0, seen = {} } = {}) {
  const out = [];
  const make = (difficulty, n) => {
    for (let i = 0; i < n; i += 1) {
      const id = `${difficulty}-${i}`;
      out.push({ id, difficulty, lastSeenAt: seen[id] ?? null });
    }
  };
  make('easy', easy); make('medium', medium); make('hard', hard);
  return out;
}
const byId = (list) => new Map(list.map((c) => [c.id, c]));
const pick = (list, opts = {}) => pickRoundQuestions(list, { now: NOW, random: seeded(7), ...opts });

describe('pickRoundQuestions', () => {
  it('escolhe 10 perguntas únicas com a mistura 4 fáceis, 4 médias e 2 difíceis', () => {
    const list = pool({ easy: 30, medium: 30, hard: 30 });
    const ids = pick(list);
    expect(ids).toHaveLength(10);
    expect(new Set(ids).size).toBe(10);
    const m = byId(list);
    const count = (d) => ids.filter((id) => m.get(id).difficulty === d).length;
    expect([count('easy'), count('medium'), count('hard')]).toEqual([4, 4, 2]);
  });

  it('ordem de jogo: das mais fáceis para as mais difíceis', () => {
    const list = pool({ easy: 20, medium: 20, hard: 20 });
    const m = byId(list);
    const ranks = pick(list).map((id) => ['easy', 'medium', 'hard'].indexOf(m.get(id).difficulty));
    expect(ranks).toEqual([...ranks].sort((a, b) => a - b));
  });

  it('prefere perguntas não vistas recentemente', () => {
    const seen = {};
    for (let i = 0; i < 15; i += 1) { seen[`easy-${i}`] = daysAgo(2); seen[`medium-${i}`] = daysAgo(2); seen[`hard-${i}`] = daysAgo(2); }
    const list = pool({ easy: 30, medium: 30, hard: 30, seen });
    const ids = pick(list);
    const m = byId(list);
    expect(ids.every((id) => m.get(id).lastSeenAt === null)).toBe(true);
  });

  it('perguntas vistas há mais de 14 dias voltam a contar como novas', () => {
    const seen = {};
    for (let i = 0; i < 30; i += 1) seen[`easy-${i}`] = daysAgo(40);
    const list = pool({ easy: 30, medium: 0, hard: 0, seen });
    expect(pick(list)).toHaveLength(10);
  });

  it('se faltam novas, usa primeiro as vistas há mais tempo', () => {
    const seen = {};
    // só 3 fáceis novas; as outras 7 foram vistas (mais recente = menor número de dias)
    for (let i = 3; i < 10; i += 1) seen[`easy-${i}`] = daysAgo(i); // easy-9 é a mais antiga (9 dias)
    const list = pool({ easy: 10, medium: 0, hard: 0, seen });
    const ids = pickRoundQuestions(list, { now: NOW, random: seeded(1), count: 6, mix: { easy: 6, medium: 0, hard: 0 } });
    expect(ids).toHaveLength(6);
    for (const fresh of ['easy-0', 'easy-1', 'easy-2']) expect(ids).toContain(fresh);
    // as 3 restantes são as vistas há mais tempo: easy-9, easy-8, easy-7
    for (const old of ['easy-9', 'easy-8', 'easy-7']) expect(ids).toContain(old);
  });

  it('dificuldade com poucas perguntas é completada com as outras (sempre 10)', () => {
    const list = pool({ easy: 2, medium: 30, hard: 0 });
    const ids = pick(list);
    expect(ids).toHaveLength(10);
    expect(new Set(ids).size).toBe(10);
  });

  it('banco pequeno: devolve tudo o que existe, sem repetir', () => {
    const list = pool({ easy: 3, medium: 2, hard: 1 });
    const ids = pick(list);
    expect(ids).toHaveLength(6);
    expect(new Set(ids).size).toBe(6);
  });

  it('candidatas duplicadas na entrada nunca geram perguntas duplicadas', () => {
    const list = pool({ easy: 12, medium: 12, hard: 12 });
    const ids = pick([...list, ...list]);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it('é repetível com o mesmo gerador e varia com outro', () => {
    const list = pool({ easy: 40, medium: 40, hard: 40 });
    expect(pick(list)).toEqual(pick(list));
    const other = pickRoundQuestions(list, { now: NOW, random: seeded(99) });
    expect(other).not.toEqual(pick(list));
  });

  it('sem candidatas devolve lista vazia', () => {
    expect(pick([])).toEqual([]);
  });
});
