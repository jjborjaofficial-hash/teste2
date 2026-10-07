/** Teste unitário (sem banco) do validador de alternativas (BE-003). */
const { analyzeQuestion, summarize, hasEmbeddedExplanation } = require('../src/modules/quiz/validation/alternativesValidator');

const mk = (id, labels, correctIdx, group = 'T | easy') => ({
  id,
  group,
  alternatives: labels.map((label, i) => ({ label, is_correct: i === correctIdx })),
});

describe('validador de alternativas', () => {
  test('reprova correta bem mais longa que as erradas', () => {
    const r = analyzeQuestion(mk('1', ['Poupança de longo prazo para a reforma', 'Gasto', 'Dívida', 'Lucro'], 0));
    expect(r.correctIsLongest).toBe(true);
    expect(r.reasons).toContain('correta_mais_longa_destacada');
    expect(r.passes).toBe(false);
  });

  test('passa quando os tamanhos são equilibrados', () => {
    const r = analyzeQuestion(mk('2', ['Guardar dinheiro', 'Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento'], 0));
    expect(r.passes).toBe(true);
    expect(r.correctIsLongest).toBe(false);
  });

  test('apanha explicação embutida e alternativas duplicadas', () => {
    expect(hasEmbeddedExplanation('Juros (o custo do dinheiro)')).toBe(true);
    expect(hasEmbeddedExplanation('Juros')).toBe(false);
    const r = analyzeQuestion(mk('3', ['Gastar menos que ganha', 'Gastar menos que ganha!', 'Poupar nada', 'Dívida'], 0));
    expect(r.reasons).toContain('alternativas_duplicadas_ou_quase_iguais');
  });

  test('exige exatamente uma correta', () => {
    const q = mk('4', ['a1', 'b2', 'c3'], 0);
    q.alternatives[1].is_correct = true;
    expect(analyzeQuestion(q).reasons).toContain('corretas_2');
  });

  test('summarize agrega por grupo e calcula a % da mais longa', () => {
    const qs = [
      mk('a', ['Resposta bem comprida e detalhada aqui', 'No', 'Ok', 'Sim'], 0),
      mk('b', ['Guardar dinheiro', 'Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento'], 0),
    ];
    const s = summarize(qs);
    expect(s.total).toBe(2);
    expect(s.groups['T | easy'].longestShare).toBe(50);
    expect(s.groups['T | easy'].meetsTarget).toBe(false);
    expect(s.failingCount).toBe(1);
  });
});

describe('correta muito mais curta que as erradas (teste 12 da especificação)', () => {
  const make = (correct, wrongs) => ({
    id: 'q',
    alternatives: [{ label: correct, is_correct: true }, ...wrongs.map((label) => ({ label, is_correct: false }))],
  });

  it('reprova quando a correta é a mais curta e bem abaixo da média das erradas', () => {
    const r = analyzeQuestion(
      make('Um banco', [
        'Uma instituição que guarda dinheiro e concede crédito aos clientes',
        'Uma empresa que vende seguros e investimentos de longo prazo',
        'Um órgão público que fiscaliza os preços praticados no mercado',
      ])
    );
    expect(r.correctIsShortest).toBe(true);
    expect(r.reasons).toContain('correta_muito_mais_curta');
    expect(r.passes).toBe(false);
  });

  it('não reprova quando a correta é a mais curta por pouco (sem padrão evidente)', () => {
    const r = analyzeQuestion(
      make('Taxa de juro fixa anual', ['Taxa de juro variável mensal', 'Taxa de câmbio oficial diária', 'Taxa de inflação média anual'])
    );
    expect(r.reasons).not.toContain('correta_muito_mais_curta');
  });
});

describe('explicação embutida: "Porque" no início não conta (respostas a "Por que…?")', () => {
  const { hasEmbeddedExplanation } = require('../src/modules/quiz/validation/alternativesValidator');

  test('"Porque …" no início da alternativa não é explicação embutida', () => {
    expect(hasEmbeddedExplanation('Porque pode ser necessária para despesas inesperadas')).toBe(false);
    expect(hasEmbeddedExplanation('  porque a perda dessa fonte afeta os recursos')).toBe(false);
  });

  test('continua a apanhar explicação de verdade (porque no meio, parênteses, dois-pontos, ou seja)', () => {
    expect(hasEmbeddedExplanation('Poupar dinheiro, porque assim sobra mais')).toBe(true);
    expect(hasEmbeddedExplanation('Porque sobe, pois o custo aumenta')).toBe(true);
    expect(hasEmbeddedExplanation('Juros (taxa cobrada)')).toBe(true);
    expect(hasEmbeddedExplanation('Inflação: subida dos preços')).toBe(true);
    expect(hasEmbeddedExplanation('Reserva, ou seja, dinheiro guardado')).toBe(true);
  });
});

