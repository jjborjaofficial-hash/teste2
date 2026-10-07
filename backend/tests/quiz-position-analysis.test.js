/** Teste unitário (sem banco) da análise de posição da correta (BE-003, P11). */
const { analyzePositions, analyzeSequence, chi2Critical } = require('../src/modules/quiz/validation/positionAnalysis');

const mkQ = (pos, group = 'G | easy', k = 4) => ({
  id: `${group}-${Math.random()}`,
  group,
  alternatives: Array.from({ length: k }, (_, i) => ({ label: `opt${i}`, is_correct: i === pos })),
});

// Gerador determinístico (LCG) para não depender de Math.random nos testes.
const rng = (seed) => () => {
  seed = (seed * 1664525 + 1013904223) % 4294967296;
  return seed / 4294967296;
};
const randomSeq = (n, k, seed = 7) => {
  const r = rng(seed);
  return Array.from({ length: n }, () => Math.floor(r() * k));
};

describe('posição da correta (P11)', () => {
  test('distribuição ao acaso não acusa nada', () => {
    const r = analyzeSequence(randomSeq(400, 4), 4);
    expect(r.flags).toEqual([]);
    expect(r.predictable).toBe(false);
  });

  test('correta quase sempre na mesma posição acusa distribuição desigual e sequência longa', () => {
    const seq = Array.from({ length: 100 }, (_, i) => (i % 10 === 0 ? 2 : 0));
    const r = analyzeSequence(seq, 4);
    expect(r.flags).toEqual(expect.arrayContaining(['distribuicao_desigual']));
    expect(r.mostCommonPosition).toBe(0);
    expect(r.mostCommonSharePct).toBe(90);
  });

  test('sequência longa na mesma posição, mesmo com distribuição equilibrada', () => {
    const seq = [...randomSeq(80, 4, 3), 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...randomSeq(80, 4, 9)];
    const r = analyzeSequence(seq, 4);
    expect(r.longestRun).toBeGreaterThanOrEqual(10);
    expect(r.flags).toContain('sequencia_longa_na_mesma_posicao');
  });

  test('padrão cíclico A,B,C,D repetido é apanhado com distribuição perfeitamente equilibrada', () => {
    const seq = Array.from({ length: 200 }, (_, i) => i % 4);
    const r = analyzeSequence(seq, 4);
    expect(r.chi2).toBe(0);
    expect(r.flags).toContain('padrao_ciclico');
    expect(r.bestLag.lag).toBe(4);
    expect(r.bestLag.matchRate).toBe(1);
  });

  test('amostra pequena não gera falso alarme', () => {
    const r = analyzeSequence([0, 0, 0, 0, 0, 0, 0, 0], 4);
    expect(r.flags).toEqual(['amostra_pequena']);
    expect(r.predictable).toBe(false);
  });

  test('analyzePositions separa por grupo e lista os grupos suspeitos', () => {
    const qs = [
      ...randomSeq(120, 4, 11).map((p) => mkQ(p, 'Boa | easy')),
      ...Array.from({ length: 60 }, () => mkQ(3, 'Ruim | hard')),
    ];
    const r = analyzePositions(qs);
    expect(r.flaggedGroups).toEqual(['Ruim | hard']);
    expect(r.groups['Boa | easy'].predictable).toBe(false);
    expect(r.groups['Ruim | hard'].mostCommonPosition).toBe(3);
    expect(r.overall.n).toBe(180);
  });

  test('ignora perguntas mal formadas (sem correta única)', () => {
    const bad = { id: 'x', group: 'G', alternatives: [{ label: 'a', is_correct: false }, { label: 'b', is_correct: false }] };
    const r = analyzePositions([bad]);
    expect(r.groups).toEqual({});
  });

  test('valor crítico do qui-quadrado', () => {
    expect(chi2Critical(3)).toBe(11.345);
    expect(chi2Critical(9)).toBeGreaterThan(20);
    expect(chi2Critical(9)).toBeLessThan(22);
  });
});
