-- Explicações pedagógicas (BE-004) — Finanças difícil lote 27, perguntas 5 a 14 do seed 073 (10 perguntas). Mesmo critério das migrations 109 a
-- 133: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v2', 'O que representa o índice de Sharpe?',
     'O índice de Sharpe relaciona o retorno obtido com o risco assumido para obtê-lo. Serve para comparar investimentos: entre dois com o mesmo retorno, o de maior índice o conseguiu com menos risco. Não mede o valor de uma empresa, o número de investidores nem a inflação.'),
    ('seed_financas_dificil_v2', 'O que é análise fundamentalista de empresas?',
     'Análise fundamentalista avalia os indicadores financeiros, os resultados e as perspectivas de uma empresa para estimar se vale o preço pedido. Olha para o negócio, e não só para o preço do dia. Não é análise de publicidade, escolha por sorte nem observação apenas do preço diário.'),
    ('seed_financas_dificil_v2', 'O que é análise técnica?',
     'Análise técnica estuda gráficos e movimentos históricos de preços para identificar tendências. Ao contrário da fundamentalista, que olha para o negócio, a técnica olha para o comportamento do preço. Não é controle de despesas, análise de funcionários nem avaliação de impostos.'),
    ('seed_financas_dificil_v2', 'O que é valuation?',
     'Valuation é o processo de estimar o valor de uma empresa ou ativo, normalmente com base em seus resultados, fluxo de caixa e perspectivas. Comparar esse valor com o preço de mercado ajuda a ver se o ativo está caro ou barato. Não é controle de salário, criação de dívida nem redução de impostos.'),
    ('seed_financas_dificil_v2', 'O que é valor intrínseco de uma empresa?',
     'Valor intrínseco é a estimativa do valor real de uma empresa com base nos seus fundamentos financeiros, independentemente do preço de mercado do dia. Se o preço de mercado está abaixo, o ativo pode estar barato; se está acima, pode estar caro. Não é só o preço de mercado, o total de despesas nem os salários.'),
    ('seed_financas_dificil_v2', 'O que é uma bolha financeira?',
     'Bolha financeira é a situação em que os preços de ativos sobem muito acima do seu valor real por causa da especulação: compra-se na esperança de vender mais caro, e não pelo valor do ativo. Quando a confiança acaba, os preços caem rápido. Não é crescimento garantido nem queda normal de preços.'),
    ('seed_financas_dificil_v2', 'O que é especulação financeira?',
     'Especulação é comprar ou vender buscando lucro com as variações de preço no mercado, em geral no curto prazo. Pode render ganhos, mas tem risco alto de perdas. Não é controlar o orçamento, guardar dinheiro sem objetivo nem pagar impostos.'),
    ('seed_financas_dificil_v2', 'O que é arbitragem financeira?',
     'Arbitragem é aproveitar diferenças de preço do mesmo ativo em mercados diferentes: compra-se onde está mais barato e vende-se onde está mais caro, ganhando a diferença. Com o tempo, essa prática tende a igualar os preços. Não é criar dinheiro, reduzir salários nem cancelar investimentos.'),
    ('seed_financas_dificil_v2', 'O que é derivativo financeiro?',
     'Derivativo é um instrumento financeiro cujo valor depende de outro ativo de referência, como uma ação, uma moeda ou uma mercadoria. Pode servir para proteção contra variações de preço ou para especulação. Não é conta bancária comum, cartão de crédito nem salário.'),
    ('seed_financas_dificil_v2', 'O que é contrato futuro?',
     'Contrato futuro é um acordo para comprar ou vender um ativo numa data futura, por um preço definido hoje. Protege quem quer travar o preço, como um produtor que fixa o valor da colheita, e também é usado para especular. É um tipo de derivativo. Não é empréstimo pessoal nem conta de poupança.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 27, perguntas 5 a 14 do seed 073: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
