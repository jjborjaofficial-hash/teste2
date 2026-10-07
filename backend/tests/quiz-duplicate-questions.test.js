/** Teste unitário (sem banco) da deteção de perguntas duplicadas (BE-003, P10). */
const { findDuplicateOf, findDuplicateGroups } = require('../src/modules/quiz/validation/duplicateQuestions');

const existing = [
  { id: '1', statement: 'O que é inflação?' },
  { id: '2', statement: 'Qual é a função principal de um orçamento pessoal?' },
  { id: '3', statement: 'Para que serve o juro composto numa poupança de longo prazo?' },
];

describe('perguntas duplicadas (P10)', () => {
  test('apanha enunciado igual ignorando acentos, maiúsculas e pontuação', () => {
    const d = findDuplicateOf('o que e INFLACAO', existing);
    expect(d).toMatchObject({ id: '1', exact: true, similarity: 1 });
  });

  test('apanha enunciado quase igual (palavras de ligação trocadas)', () => {
    const d = findDuplicateOf('Qual a função principal do orçamento pessoal', existing);
    expect(d).toMatchObject({ id: '2', exact: false });
    expect(d.similarity).toBeGreaterThanOrEqual(0.85);
  });

  test('não confunde perguntas diferentes sobre o mesmo tema', () => {
    expect(findDuplicateOf('O que é deflação?', existing)).toBeNull();
    expect(findDuplicateOf('Como o juro composto cresce com o tempo?', existing)).toBeNull();
  });

  test('ao editar, ignora a própria pergunta (excludeId)', () => {
    expect(findDuplicateOf('O que é inflação?', existing, { excludeId: '1' })).toBeNull();
  });

  test('findDuplicateGroups separa exatas de quase iguais', () => {
    const qs = [
      ...existing,
      { id: '4', statement: 'o que e inflacao' },
      { id: '5', statement: 'Qual a função principal do orçamento pessoal' },
      { id: '6', statement: 'Quem criou o Bitcoin?' },
    ];
    const r = findDuplicateGroups(qs);
    expect(r.total).toBe(6);
    expect(r.exactGroups).toEqual([['1', '4']]);
    expect(r.nearPairs.map((p) => [p.a, p.b])).toEqual([['2', '5']]);
  });

  test('banco sem duplicadas devolve listas vazias', () => {
    const r = findDuplicateGroups(existing);
    expect(r.exactGroups).toEqual([]);
    expect(r.nearPairs).toEqual([]);
  });
});
