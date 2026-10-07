/** Teste unitário (sem banco) do detetor de viés das alternativas (BE-003, P9). */
const { detectBias, summarizeBias } = require('../src/modules/quiz/validation/biasDetector');

const mk = (labels, correctIdx, group = 'T | easy', id = 'q') => ({
  id,
  group,
  alternatives: labels.map((label, i) => ({ label, is_correct: i === correctIdx })),
});

describe('detetor de viés (P9)', () => {
  test('bloqueia "todas/nenhuma das anteriores"', () => {
    const r = detectBias(mk(['Juros', 'Multa', 'Taxa', 'Todas as anteriores'], 3));
    expect(r.blockers).toContain('todas_ou_nenhuma_das_anteriores');
    expect(detectBias(mk(['Juros', 'Multa', 'Taxa', 'Nenhuma das opções acima'], 0)).blockers).toContain('todas_ou_nenhuma_das_anteriores');
  });

  test('avisa absolutos só nas erradas', () => {
    const r = detectBias(mk(['Nunca gastar mais', 'Sempre pedir emprestado', 'Apenas poupar', 'Guardar parte do que ganha'], 3));
    expect(r.warnings).toContain('pista_absoluta_so_nas_erradas');
  });

  test('não avisa absolutos se a correta também tem', () => {
    const r2 = detectBias(mk(['Nunca gastar mais', 'Sempre pedir emprestado', 'Sempre guardar parte do que ganha', 'Nunca poupar nada'], 2));
    expect(r2.warnings).not.toContain('pista_absoluta_so_nas_erradas');
  });

  test('avisa cautela só na correta', () => {
    const r = detectBias(mk(['Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento', 'Geralmente guardar uma parte'], 3));
    expect(r.warnings).toContain('pista_cautela_so_na_correta');
  });

  test('avisa estrutura só na correta e início diferente', () => {
    const r = detectBias(mk(['Perda de valor', 'Perda de tempo', 'Perda de clientes', 'Aumento dos preços, em geral'], 3));
    expect(r.warnings).toEqual(expect.arrayContaining(['estrutura_so_na_correta', 'inicio_diferente_so_na_correta']));
  });

  test('avisa palavras desequilibradas só com opções de 4+ palavras', () => {
    const r = detectBias(mk(['Gastar tudo o que se ganha todos os meses sem controlo', 'Poupar', 'Pedir', 'Vender'], 0));
    expect(r.warnings).toContain('palavras_desequilibradas');
    expect(detectBias(mk(['Juros', 'Multa', 'Taxa de uso', 'Imposto'], 0)).warnings).not.toContain('palavras_desequilibradas');
  });

  test('avisa opção contida noutra, mas ignora siglas de uma palavra', () => {
    expect(detectBias(mk(['Juros compostos', 'Juros compostos anuais', 'Multa fixa', 'Taxa de uso'], 0)).warnings).toContain('opcao_contida_noutra');
    expect(detectBias(mk(['IVA', 'IVA reduzido', 'Multa', 'Taxa'], 0)).warnings).not.toContain('opcao_contida_noutra');
  });

  test('pergunta equilibrada não tem nenhum achado', () => {
    const r = detectBias(mk(['Guardar dinheiro', 'Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento'], 0));
    expect(r.flags).toEqual([]);
    expect(r.hasBias).toBe(false);
  });

  test('summarizeBias agrega por grupo e por tipo', () => {
    const s = summarizeBias([
      mk(['Juros', 'Multa', 'Taxa', 'Todas as anteriores'], 3, 'A | easy', '1'),
      mk(['Guardar dinheiro', 'Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento'], 0, 'A | easy', '2'),
    ]);
    expect(s.total).toBe(2);
    expect(s.flaggedCount).toBe(1);
    expect(s.groups['A | easy'].withBias).toBe(1);
    expect(s.groups['A | easy'].byCode.todas_ou_nenhuma_das_anteriores).toBe(1);
  });
});
