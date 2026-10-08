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

describe('falsos alarmes encontrados com as perguntas aprovadas pelo dono', () => {
  const { hasEmbeddedExplanation, isMirror, analyzeQuestion } = require('../src/modules/quiz/validation/alternativesValidator');
  const mk = (labels, c) => ({ id: 'x', alternatives: labels.map((label, i) => ({ label, is_correct: i === c })) });

  test('sigla entre parênteses não é explicação embutida; explicação entre parênteses continua a ser', () => {
    expect(hasEmbeddedExplanation('Processador (CPU)')).toBe(false);
    expect(hasEmbeddedExplanation('Memória (RAM)')).toBe(false);
    expect(hasEmbeddedExplanation('Linguagem de marcação (HTML5)')).toBe(false);
    expect(hasEmbeddedExplanation('Juros (taxa cobrada pelo banco)')).toBe(true);
    expect(hasEmbeddedExplanation('Processador (o cérebro)')).toBe(true);
  });

  test('o caso real do "cérebro do computador" já não é assinalado', () => {
    const q = mk(['Memória (RAM)', 'Processador (CPU)', 'Disco rígido (HD)', 'Placa de vídeo (GPU)'], 1);
    expect(analyzeQuestion(q).reasons).not.toContain('explicacao_embutida_na_correta');
  });

  test('os 3 espelhos aceites pelo dono (lados trocados) já não são "quase iguais"', () => {
    expect(isMirror('Necessidade é essencial; desejo é algo opcional', 'Necessidade é algo opcional; desejo é essencial')).toBe(true);
    expect(isMirror(
      'Financiamento geralmente está ligado a uma finalidade específica; empréstimo pode ter uso mais livre',
      'Empréstimo geralmente está ligado a uma finalidade específica; financiamento pode ter uso mais livre')).toBe(true);
    expect(isMirror(
      'Liquidez está relacionada à capacidade de cumprir obrigações de curto prazo; solvência está relacionada à capacidade financeira de longo prazo',
      'Solvência está relacionada à capacidade de cumprir obrigações de curto prazo; liquidez está relacionada à capacidade financeira de longo prazo')).toBe(true);
    const q = mk(['Necessidade é essencial; desejo é algo opcional', 'Necessidade é algo opcional; desejo é essencial', 'Necessidade custa mais do que o desejo', 'Não existe diferença entre as duas coisas'], 0);
    expect(analyzeQuestion(q).reasons).not.toContain('alternativas_duplicadas_ou_quase_iguais');
  });

  test('duplicadas verdadeiras continuam a ser apanhadas (mesmo texto, pontuação ou maiúsculas diferentes)', () => {
    const a = 'Poupar parte do dinheiro todos os meses para criar reserva';
    expect(isMirror(a, `${a}.`)).toBe(false);
    expect(isMirror(a, a.toUpperCase())).toBe(false);
    const q = mk([a, `${a}.`, 'Gastar tudo o que se ganha logo no início', 'Pedir dinheiro emprestado a cada semana'], 0);
    expect(analyzeQuestion(q).reasons).toContain('alternativas_duplicadas_ou_quase_iguais');
  });

  test('uma palavra a mais ou a menos NÃO é espelho: continua a contar como quase igual', () => {
    const a = 'Poupar parte do dinheiro todos os meses para criar reserva';
    expect(isMirror(a, 'Poupar parte do dinheiro todos os meses para criar uma reserva')).toBe(false);
    expect(isMirror(a, 'Poupar parte do dinheiro todos os meses para criar')).toBe(false);
    const q = mk([a, 'Poupar parte do dinheiro todos os meses para criar uma reserva', 'Gastar tudo o que se ganha logo no início', 'Pedir dinheiro emprestado a cada semana'], 0);
    expect(analyzeQuestion(q).reasons).toContain('alternativas_duplicadas_ou_quase_iguais');
  });

  test('opções curtas trocadas de ordem não ganham a isenção de espelho (menos de 5 palavras)', () => {
    expect(isMirror('Juros compostos', 'Compostos juros')).toBe(false);
  });
});

