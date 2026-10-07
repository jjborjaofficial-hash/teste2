-- Alternativas (BE-003, regularização) — Finanças difícil lote 1: as 25 primeiras do seed 047.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda;
-- só o texto das alternativas ERRADAS é ajustado para ter tamanho parecido ao da certa.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order nem perguntas. O runner já envolve o ficheiro numa transação.
-- Regra 9 do padrão: as explicações que citavam as alternativas erradas antigas são reescritas no segundo bloco,
-- também só se o texto atual ainda for exatamente o original.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?', 0, 'Dinheiro futuro sempre vale mais', 'Dinheiro futuro vale mais do que o dinheiro disponível hoje por causa da inflação e do risco'),
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?', 2, 'Dinheiro presente nunca pode ser investido', 'Dinheiro presente não pode ser investido porque só rende depois de um período longo'),
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?', 3, 'Todo dinheiro mantém exatamente o mesmo valor em qualquer momento', 'Todo dinheiro mantém o mesmo valor em qualquer momento porque a moeda não muda'),
    ('seed_financas_dificil_v1', 'O que é juros compostos?', 1, 'Um desconto comercial', 'Descontos comerciais calculados sobre o preço de venda'),
    ('seed_financas_dificil_v1', 'O que é juros compostos?', 2, 'Juros calculados apenas uma vez', 'Juros calculados uma só vez sobre o capital inicial do empréstimo'),
    ('seed_financas_dificil_v1', 'O que é juros compostos?', 3, 'Um imposto sobre compras', 'Imposto cobrado sobre os juros que os bancos pagam aos clientes'),
    ('seed_financas_dificil_v1', 'Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 0, 'O capital necessariamente diminui', 'O capital cresce mas os rendimentos deixam de gerar valor'),
    ('seed_financas_dificil_v1', 'Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 1, 'Os rendimentos desaparecem', 'Os rendimentos ficam fixos e não aumentam com o tempo'),
    ('seed_financas_dificil_v1', 'Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 3, 'O investimento deixa de existir', 'O investimento passa a render menos por causa dos juros'),
    ('seed_financas_dificil_v1', 'O que é retorno real de um investimento?', 0, 'Apenas os impostos pagos', 'Retorno obtido depois de pagar os impostos sobre os rendimentos'),
    ('seed_financas_dificil_v1', 'O que é retorno real de um investimento?', 2, 'Apenas o valor nominal recebido', 'Retorno expresso em valor nominal, sem considerar a inflação do período'),
    ('seed_financas_dificil_v1', 'O que é retorno real de um investimento?', 3, 'O valor inicialmente investido', 'Valor inicialmente investido mais os custos de abertura da conta'),
    ('seed_financas_dificil_v1', 'Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 0, 'O retorno nominal e o retorno real são exatamente iguais', 'O retorno real é igual ao retorno nominal porque a inflação já está incluída'),
    ('seed_financas_dificil_v1', 'Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 1, 'A inflação não interfere', 'A inflação não interfere no rendimento, porque os preços já estão no cálculo da taxa'),
    ('seed_financas_dificil_v1', 'Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 3, 'O investimento perdeu necessariamente 12%', 'O investimento perdeu poder de compra, porque a inflação foi maior do que o rendimento'),
    ('seed_financas_dificil_v1', 'O que é custo de oportunidade de manter dinheiro parado?', 0, 'É sempre uma multa', 'Multa cobrada pelo banco a quem mantém dinheiro parado numa conta sem movimento'),
    ('seed_financas_dificil_v1', 'O que é custo de oportunidade de manter dinheiro parado?', 2, 'É o mesmo que inflação', 'Taxa que mede o aumento geral dos preços durante o período em que o dinheiro fica parado'),
    ('seed_financas_dificil_v1', 'O que é custo de oportunidade de manter dinheiro parado?', 3, 'É uma taxa bancária obrigatória', 'Taxa bancária cobrada sobre o saldo mantido numa conta de poupança por muito tempo'),
    ('seed_financas_dificil_v1', 'O que é alocação de ativos?', 1, 'Pagamento de uma dívida', 'Pagamento de uma dívida com o dinheiro obtido da venda de ativos'),
    ('seed_financas_dificil_v1', 'O que é alocação de ativos?', 2, 'Registro de despesas', 'Registro das despesas e receitas de uma carteira de investimentos'),
    ('seed_financas_dificil_v1', 'O que é alocação de ativos?', 3, 'Retirada de todo o dinheiro do banco', 'Retirada do dinheiro aplicado em ativos para guardar em conta'),
    ('seed_financas_dificil_v1', 'Por que correlação entre ativos pode ser relevante na diversificação?', 0, 'Porque garante rendimento positivo', 'Porque ativos que se movem na mesma direção garantem rendimento positivo para toda a carteira'),
    ('seed_financas_dificil_v1', 'Por que correlação entre ativos pode ser relevante na diversificação?', 1, 'Porque impede qualquer oscilação', 'Porque ativos com comportamentos diferentes impedem qualquer oscilação no valor da carteira'),
    ('seed_financas_dificil_v1', 'Por que correlação entre ativos pode ser relevante na diversificação?', 3, 'Porque elimina completamente perdas', 'Porque ativos com comportamentos diferentes eliminam completamente as perdas da carteira'),
    ('seed_financas_dificil_v1', 'O que significa volatilidade?', 0, 'Taxa de imposto', 'Taxa cobrada pelo governo sobre os lucros obtidos com a venda de ativos'),
    ('seed_financas_dificil_v1', 'O que significa volatilidade?', 1, 'Valor fixo de um ativo', 'Valor fixo que um ativo mantém ao longo do tempo, sem variações no preço'),
    ('seed_financas_dificil_v1', 'O que significa volatilidade?', 3, 'Garantia de lucro', 'Garantia de que o investidor terá lucro quando o preço do ativo subir'),
    ('seed_financas_dificil_v1', 'Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 1, 'Garantir que nenhum ativo perderá valor', 'Garantir que nenhum ativo da carteira vai perder valor'),
    ('seed_financas_dificil_v1', 'Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 2, 'Eliminar a necessidade de acompanhamento', 'Eliminar a necessidade de acompanhar os investimentos'),
    ('seed_financas_dificil_v1', 'Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 3, 'Garantir rendimento fixo', 'Garantir um rendimento fixo e igual para toda a carteira'),
    ('seed_financas_dificil_v1', 'O que é liquidez de um investimento?', 0, 'Taxa de juros', 'Taxa de juros que o banco cobra para transformar o investimento em dinheiro, e que varia conforme o mercado'),
    ('seed_financas_dificil_v1', 'O que é liquidez de um investimento?', 2, 'Valor do investimento inicial', 'Valor do investimento inicial somado aos rendimentos obtidos até o momento da venda, que depende do mercado'),
    ('seed_financas_dificil_v1', 'O que é liquidez de um investimento?', 3, 'Garantia de lucro', 'Garantia de que o investidor terá lucro ao vender o investimento, seja qual for a situação do mercado'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 0, 'Todo investimento possui liquidez máxima', 'Todo investimento oferece liquidez máxima e rentabilidade máxima ao mesmo tempo, em qualquer mercado'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 1, 'Investimentos líquidos nunca rendem', 'Investimentos líquidos não rendem nada, e só os investimentos de longo prazo dão retorno'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 3, 'Rentabilidade e liquidez são sempre iguais', 'Rentabilidade e liquidez medem exatamente a mesma coisa e por isso não entram em conflito'),
    ('seed_financas_dificil_v1', 'O que é risco de crédito?', 0, 'Aumento da inflação', 'Possibilidade de a inflação subir e reduzir o valor do dinheiro emprestado'),
    ('seed_financas_dificil_v1', 'O que é risco de crédito?', 2, 'Aumento de salário', 'Possibilidade de o salário do devedor aumentar durante o prazo do empréstimo'),
    ('seed_financas_dificil_v1', 'O que é risco de crédito?', 3, 'Possibilidade de um produto ficar barato', 'Possibilidade de o preço de um produto ficar mais barato do que o esperado'),
    ('seed_financas_dificil_v1', 'O que é risco de mercado?', 0, 'Apenas risco de atraso salarial', 'Possibilidade de o salário de um trabalhador atrasar por problemas na empresa'),
    ('seed_financas_dificil_v1', 'O que é risco de mercado?', 1, 'Apenas risco de roubo físico', 'Possibilidade de ocorrer roubo físico do dinheiro guardado na carteira ou em casa'),
    ('seed_financas_dificil_v1', 'O que é risco de mercado?', 2, 'Risco de esquecer uma senha', 'Possibilidade de esquecer a senha de acesso à conta bancária ou à corretora'),
    ('seed_financas_dificil_v1', 'O que é risco de liquidez?', 0, 'Risco de receber salário', 'Risco de o salário atrasar e a pessoa não conseguir pagar as contas do mês corrente'),
    ('seed_financas_dificil_v1', 'O que é risco de liquidez?', 1, 'Risco de pagar uma conta', 'Risco de não conseguir pagar uma conta no prazo por falta de dinheiro disponível na conta'),
    ('seed_financas_dificil_v1', 'O que é risco de liquidez?', 2, 'Risco de inflação exclusivamente', 'Risco de a inflação reduzir o valor do ativo e do dinheiro guardado ao longo do tempo'),
    ('seed_financas_dificil_v1', 'Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 1, 'Porque sempre aumenta o poder de compra', 'Porque aumenta o poder de compra das quantias ao longo do tempo'),
    ('seed_financas_dificil_v1', 'Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 2, 'Porque não afeta preços', 'Porque não afeta os preços dos produtos e serviços ao longo do tempo'),
    ('seed_financas_dificil_v1', 'Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 3, 'Porque elimina os juros', 'Porque elimina os juros cobrados nos empréstimos de longo prazo'),
    ('seed_financas_dificil_v1', 'O que é taxa nominal?', 0, 'Taxa que sempre representa ganho real', 'Taxa que já representa o ganho real, depois de descontar a inflação'),
    ('seed_financas_dificil_v1', 'O que é taxa nominal?', 1, 'Taxa que não pode mudar', 'Taxa fixa que não pode mudar durante todo o prazo do contrato'),
    ('seed_financas_dificil_v1', 'O que é taxa nominal?', 3, 'Taxa exclusivamente de impostos', 'Taxa composta apenas pelos impostos cobrados sobre o rendimento'),
    ('seed_financas_dificil_v1', 'Qual é a relação entre risco e retorno em investimentos?', 0, 'Risco e retorno não possuem qualquer relação', 'Risco e retorno não possuem qualquer relação entre si em nenhum tipo de investimento'),
    ('seed_financas_dificil_v1', 'Qual é a relação entre risco e retorno em investimentos?', 1, 'Menor risco sempre significa maior retorno', 'Menor risco significa maior retorno, porque o investidor fica protegido de perdas'),
    ('seed_financas_dificil_v1', 'Qual é a relação entre risco e retorno em investimentos?', 3, 'Maior risco sempre significa maior lucro', 'Maior risco garante maior lucro, porque o investidor assume mais responsabilidade'),
    ('seed_financas_dificil_v1', 'O que significa liquidação de uma dívida?', 0, 'Criação de uma nova dívida', 'Transferência da dívida para outro credor'),
    ('seed_financas_dificil_v1', 'O que significa liquidação de uma dívida?', 1, 'Aumento do prazo', 'Renegociação do prazo da dívida'),
    ('seed_financas_dificil_v1', 'O que significa liquidação de uma dívida?', 2, 'Suspensão do pagamento', 'Pagamento de apenas uma parte da dívida'),
    ('seed_financas_dificil_v1', 'O que é solvência?', 0, 'Quantidade de dinheiro em espécie', 'Quantidade de dinheiro que a empresa tem disponível em notas e moedas'),
    ('seed_financas_dificil_v1', 'O que é solvência?', 1, 'Capacidade de fazer uma compra', 'Capacidade de pagar uma compra imediata com o dinheiro disponível'),
    ('seed_financas_dificil_v1', 'O que é solvência?', 2, 'Valor de um produto', 'Valor de mercado de um produto ou serviço vendido pela empresa'),
    ('seed_financas_dificil_v1', 'Qual é a diferença entre liquidez e solvência?', 0, 'Liquidez mede apenas lucro', 'Liquidez mede o lucro obtido pela empresa num ano; solvência mede a quantidade de vendas feitas em cada período do ano'),
    ('seed_financas_dificil_v1', 'Qual é a diferença entre liquidez e solvência?', 1, 'São exatamente a mesma coisa', 'São a mesma coisa, porque ambas medem a capacidade de pagar dívidas, e só mudam de nome conforme o país'),
    ('seed_financas_dificil_v1', 'Qual é a diferença entre liquidez e solvência?', 2, 'Solvência mede apenas inflação', 'Solvência está relacionada à capacidade de cumprir obrigações de curto prazo; liquidez está relacionada à capacidade financeira de longo prazo'),
    ('seed_financas_dificil_v1', 'O que significa análise de fluxo de caixa?', 0, 'Análise apenas das vendas', 'Análise das vendas feitas pela empresa em determinado período'),
    ('seed_financas_dificil_v1', 'O que significa análise de fluxo de caixa?', 2, 'Cálculo apenas dos impostos', 'Cálculo dos impostos que a empresa deve pagar em determinado período'),
    ('seed_financas_dificil_v1', 'O que significa análise de fluxo de caixa?', 3, 'Avaliação apenas do patrimônio', 'Avaliação do patrimônio total da empresa em determinado período de tempo'),
    ('seed_financas_dificil_v1', 'Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 1, 'Inflação', 'Diferença entre receita e despesa'),
    ('seed_financas_dificil_v1', 'Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 2, 'Diversificação', 'Diferença entre ativos e passivos'),
    ('seed_financas_dificil_v1', 'Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 3, 'Patrimônio líquido', 'Diferença entre custo fixo e variável'),
    ('seed_financas_dificil_v1', 'O que é capital de giro?', 0, 'Apenas patrimônio pessoal do proprietário', 'Patrimônio pessoal do proprietário usado para abrir a empresa'),
    ('seed_financas_dificil_v1', 'O que é capital de giro?', 2, 'Somente dinheiro em caixa físico', 'Dinheiro em caixa físico que a empresa guarda para pequenos gastos diários'),
    ('seed_financas_dificil_v1', 'O que é capital de giro?', 3, 'Apenas dinheiro destinado a investimentos de longo prazo', 'Dinheiro destinado a investimentos de longo prazo, como compra de imóveis'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?', 1, 'Quantidade de funcionários', 'Relação entre o número de funcionários e a receita total da empresa'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?', 2, 'Valor total dos ativos', 'Relação entre o valor total dos ativos e o patrimônio líquido da empresa'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?', 3, 'Soma de todas as dívidas', 'Relação entre a soma das dívidas e o valor total dos ativos da empresa')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças difícil lote 1: as 25 primeiras do seed 047: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_dificil_v1', 'Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 'O rendimento de 12% é nominal. Descontada a inflação de 8%, o ganho real em poder de compra é de cerca de 4% (3,7% pelo cálculo exato). Por isso é preciso analisar a inflação: sem ela, não se sabe quanto o dinheiro realmente rendeu. O investimento não perdeu 12%, e a inflação interfere, sim.', 'O rendimento de 12% é nominal. Descontada a inflação de 8%, o ganho real em poder de compra é de cerca de 4% (3,7% pelo cálculo exato). Por isso é preciso analisar a inflação: sem ela, não se sabe quanto o dinheiro realmente rendeu. O retorno real não é igual ao nominal e o investimento não perdeu poder de compra, porque 12% é maior do que 8%.'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 'Em geral, quem aceita prender o dinheiro por mais tempo ou abrir mão de resgate fácil pode receber um retorno maior, como compensação. Já o investimento de resgate imediato costuma render menos. Assim, é preciso equilibrar quanto se precisa do dinheiro e quanto se quer render. Não é verdade que investimentos líquidos nunca rendem.', 'Em geral, quem aceita prender o dinheiro por mais tempo ou abrir mão de resgate fácil pode receber um retorno maior, como compensação. Já o investimento de resgate imediato costuma render menos, mas não rende zero. Assim, é preciso equilibrar quanto se precisa do dinheiro e quanto se quer render. Liquidez e rentabilidade não medem a mesma coisa nem se combinam no máximo ao mesmo tempo.'),
    ('seed_financas_dificil_v1', 'O que significa liquidação de uma dívida?', 'Liquidar uma dívida é pagar toda a obrigação, de modo que ela deixa de existir. Difere da amortização, que reduz a dívida aos poucos. Não é criar nova dívida, aumentar o prazo nem suspender o pagamento.', 'Liquidar uma dívida é pagar toda a obrigação, de modo que ela deixa de existir. Difere da amortização, que reduz a dívida aos poucos. Não é passar a dívida a outro credor, renegociar o prazo nem pagar só uma parte.'),
    ('seed_financas_dificil_v1', 'Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 'O lucro contábil registra as vendas quando acontecem, mas o dinheiro pode entrar só depois, se o cliente pagar a prazo. Enquanto isso, as contas vencem. Por isso lucro e fluxo de caixa são coisas diferentes: uma empresa pode ter lucro e faltar dinheiro. Inflação, diversificação e patrimônio líquido não explicam esse caso.', 'O lucro contábil registra as vendas quando acontecem, mas o dinheiro pode entrar só depois, se o cliente pagar a prazo. Enquanto isso, as contas vencem. Por isso lucro e fluxo de caixa são coisas diferentes: uma empresa pode ter lucro e faltar dinheiro. A diferença entre receita e despesa, entre ativos e passivos ou entre custo fixo e variável não explica esse caso.'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?', 'Margem de lucro é a relação entre o lucro e a receita, em geral em percentual. Por exemplo, lucro de 20 sobre receita de 100 dá margem de 20%. Permite comparar a rentabilidade de negócios de tamanhos diferentes. Não é número de funcionários, total de ativos nem soma das dívidas.', 'Margem de lucro é a relação entre o lucro e a receita, em geral em percentual. Por exemplo, lucro de 20 sobre receita de 100 dá margem de 20%. Permite comparar a rentabilidade de negócios de tamanhos diferentes. Não é uma relação entre funcionários e receita, entre ativos e patrimônio nem entre dívidas e ativos.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças difícil lote 1: as 25 primeiras do seed 047): % atualizada(s) (previstas: 5).', v_updated;
END $$;
