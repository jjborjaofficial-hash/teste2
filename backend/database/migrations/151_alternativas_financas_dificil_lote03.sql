-- Alternativas (BE-003, regularização) — Finanças difícil lote 3: 073#20-35 e 074#1-9.
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
    ('seed_financas_dificil_v2', 'O que é planejamento sucessório?', 0, 'Criação de dívidas', 'Planejamento das compras da família para o ano seguinte'),
    ('seed_financas_dificil_v2', 'O que é planejamento sucessório?', 1, 'Planejamento de compras', 'Criação de dívidas para financiar os estudos dos filhos'),
    ('seed_financas_dificil_v2', 'O que é planejamento sucessório?', 2, 'Controle de salário', 'Controle do salário recebido pelos membros da família'),
    ('seed_financas_dificil_v2', 'O que é taxa interna de retorno (TIR)?', 0, 'Custo operacional', 'Taxa cobrada pelo banco sobre o saldo devedor do empréstimo'),
    ('seed_financas_dificil_v2', 'O que é taxa interna de retorno (TIR)?', 2, 'Preço de mercado', 'Custo operacional médio gasto pela empresa em cada período contábil'),
    ('seed_financas_dificil_v2', 'O que é taxa interna de retorno (TIR)?', 3, 'Valor de uma dívida', 'Preço de mercado atual do ativo na bolsa de valores'),
    ('seed_financas_dificil_v2', 'O que é valor presente líquido (VPL)?', 0, 'Soma simples de despesas', 'Soma simples das despesas do projeto, sem considerar o momento em que cada uma delas acontece durante o período analisado'),
    ('seed_financas_dificil_v2', 'O que é valor presente líquido (VPL)?', 2, 'Valor do salário', 'Cálculo do salário médio pago aos funcionários envolvidos no investimento ao longo do tempo'),
    ('seed_financas_dificil_v2', 'O que é valor presente líquido (VPL)?', 3, 'Quantidade de clientes', 'Contagem da quantidade de clientes que o investimento vai atrair nos primeiros anos'),
    ('seed_financas_dificil_v2', 'O que significa valor do dinheiro no tempo?', 1, 'Dinheiro nunca muda de valor', 'Um valor recebido no futuro geralmente rende mais do que o mesmo valor recebido hoje'),
    ('seed_financas_dificil_v2', 'O que significa valor do dinheiro no tempo?', 2, 'O futuro sempre vale mais', 'O dinheiro mantém sempre o mesmo valor, independentemente do momento em que é recebido'),
    ('seed_financas_dificil_v2', 'O que significa valor do dinheiro no tempo?', 3, 'Juros não existem', 'Os juros deixam de existir quando o dinheiro é aplicado por um período mais longo'),
    ('seed_financas_dificil_v2', 'O que é custo de capital?', 0, 'Imposto de consumo', 'Imposto cobrado sobre o consumo de bens e serviços pela empresa'),
    ('seed_financas_dificil_v2', 'O que é custo de capital?', 1, 'Salário dos trabalhadores', 'Salário pago aos trabalhadores que cuidam do caixa da empresa'),
    ('seed_financas_dificil_v2', 'O que é custo de capital?', 2, 'Valor do produto final', 'Valor do produto final vendido pela empresa aos seus clientes'),
    ('seed_financas_dificil_v2', 'O que é estrutura de capital?', 1, 'Total de vendas', 'Total das vendas realizadas pela empresa durante o último ano fiscal'),
    ('seed_financas_dificil_v2', 'O que é estrutura de capital?', 2, 'Número de funcionários', 'Número de funcionários contratados pela empresa em cada departamento'),
    ('seed_financas_dificil_v2', 'O que é estrutura de capital?', 3, 'Apenas dinheiro em caixa', 'Apenas o dinheiro que a empresa mantém disponível no caixa e nas contas bancárias'),
    ('seed_financas_dificil_v2', 'O que é alavancagem financeira?', 0, 'Eliminação de investimentos', 'Eliminação dos investimentos que apresentam menor rentabilidade no período'),
    ('seed_financas_dificil_v2', 'O que é alavancagem financeira?', 1, 'Controle de despesas pessoais', 'Controle das despesas pessoais com o dinheiro do próprio salário'),
    ('seed_financas_dificil_v2', 'O que é alavancagem financeira?', 3, 'Redução de vendas', 'Redução das vendas para diminuir o risco do negócio da empresa'),
    ('seed_financas_dificil_v2', 'Qual é um risco da alavancagem financeira?', 0, 'Garantia de lucro', 'Garantia de que o lucro será maior do que o previsto no projeto'),
    ('seed_financas_dificil_v2', 'Qual é um risco da alavancagem financeira?', 1, 'Redução automática de custos', 'Redução automática dos custos fixos e variáveis da empresa'),
    ('seed_financas_dificil_v2', 'Qual é um risco da alavancagem financeira?', 2, 'Eliminação de dívidas', 'Eliminação imediata de todas as dívidas assumidas pela empresa'),
    ('seed_financas_dificil_v2', 'O que é fusão empresarial?', 0, 'Venda de produtos', 'Venda dos produtos de duas empresas pelo mesmo canal'),
    ('seed_financas_dificil_v2', 'O que é fusão empresarial?', 1, 'Fechamento de uma empresa', 'Fechamento de uma empresa por causa de dívidas elevadas'),
    ('seed_financas_dificil_v2', 'O que é fusão empresarial?', 2, 'Redução de impostos', 'Redução dos impostos pagos pelas empresas que atuam no mesmo setor'),
    ('seed_financas_dificil_v2', 'O que é aquisição empresarial?', 1, 'Criação de uma dívida pessoal', 'Criação de uma dívida pessoal para comprar bens'),
    ('seed_financas_dificil_v2', 'O que é aquisição empresarial?', 2, 'Pagamento de salário', 'Pagamento do salário aos funcionários da empresa'),
    ('seed_financas_dificil_v2', 'O que é aquisição empresarial?', 3, 'Controle bancário', 'Controle das contas bancárias de um cliente'),
    ('seed_financas_dificil_v2', 'O que é auditoria financeira?', 0, 'Controle de marketing', 'Controle das campanhas de marketing para aumentar as vendas'),
    ('seed_financas_dificil_v2', 'O que é auditoria financeira?', 1, 'Criação de investimentos', 'Criação de novos investimentos para os sócios da empresa'),
    ('seed_financas_dificil_v2', 'O que é auditoria financeira?', 3, 'Venda de ações', 'Venda de ações da empresa a novos investidores no mercado de capitais'),
    ('seed_financas_dificil_v2', 'O que é demonstração financeira?', 0, 'Plano de vendas', 'Plano com as metas de vendas para o próximo ano da empresa'),
    ('seed_financas_dificil_v2', 'O que é demonstração financeira?', 1, 'Contrato de empréstimo', 'Contrato que define as condições de um empréstimo bancário'),
    ('seed_financas_dificil_v2', 'O que é demonstração financeira?', 3, 'Documento de publicidade', 'Documento de publicidade que apresenta ao público a imagem e os produtos da empresa'),
    ('seed_financas_dificil_v2', 'O que é balanço patrimonial?', 0, 'Controle de funcionários', 'Controle dos funcionários contratados e dos salários pagos'),
    ('seed_financas_dificil_v2', 'O que é balanço patrimonial?', 1, 'Plano de marketing', 'Plano de marketing com as ações para atrair novos clientes'),
    ('seed_financas_dificil_v2', 'O que é balanço patrimonial?', 3, 'Lista de clientes', 'Lista com os clientes que compraram mais produtos durante o ano passado'),
    ('seed_financas_dificil_v2', 'O que é demonstração de resultados?', 0, 'Documento de identidade', 'Documento que identifica a empresa e os seus sócios perante o Estado'),
    ('seed_financas_dificil_v2', 'O que é demonstração de resultados?', 1, 'Contrato bancário', 'Contrato bancário que define juros e prazos de um empréstimo'),
    ('seed_financas_dificil_v2', 'O que é demonstração de resultados?', 2, 'Lista de investimentos pessoais', 'Lista dos investimentos pessoais feitos pelos sócios ao longo da vida'),
    ('seed_financas_dificil_v2', 'O que é liquidez financeira de uma empresa?', 0, 'Número de produtos', 'Número total de produtos que a empresa tem para vender'),
    ('seed_financas_dificil_v2', 'O que é liquidez financeira de uma empresa?', 1, 'Valor da publicidade', 'Valor gasto pela empresa em publicidade durante o mês'),
    ('seed_financas_dificil_v2', 'O que é liquidez financeira de uma empresa?', 2, 'Quantidade de funcionários', 'Quantidade de funcionários contratados pela empresa'),
    ('seed_financas_dificil_v2', 'O que é solvência empresarial?', 0, 'Capacidade de vender mais produtos apenas', 'Capacidade de vender mais produtos do que a concorrência durante um ano'),
    ('seed_financas_dificil_v2', 'O que é solvência empresarial?', 2, 'Número de clientes', 'Quantidade de clientes que a empresa atende em cada mês do ano'),
    ('seed_financas_dificil_v2', 'O que é solvência empresarial?', 3, 'Quantidade de anúncios', 'Número de anúncios que a empresa publica por ano nos meios de comunicação'),
    ('seed_financas_dificil_v3', 'O que é análise de crédito?', 0, 'Venda de produtos financeiros', 'Venda de produtos financeiros a clientes interessados em investir'),
    ('seed_financas_dificil_v3', 'O que é análise de crédito?', 1, 'Processo de criação de dinheiro', 'Processo de criação de dinheiro novo pelo banco central para pagar dívidas do país'),
    ('seed_financas_dificil_v3', 'O que é análise de crédito?', 3, 'Redução automática de juros', 'Redução automática dos juros cobrados em qualquer empréstimo'),
    ('seed_financas_dificil_v3', 'O que é política monetária?', 0, 'Estratégia de vendas de empresas', 'Estratégia de vendas usada pelas empresas para atrair novos clientes'),
    ('seed_financas_dificil_v3', 'O que é política monetária?', 2, 'Controle de salários', 'Conjunto de impostos e despesas decididos pelo governo para financiar os serviços públicos do país'),
    ('seed_financas_dificil_v3', 'O que é política monetária?', 3, 'Planejamento pessoal de gastos', 'Planejamento dos gastos pessoais feito pelas famílias a cada mês'),
    ('seed_financas_dificil_v3', 'Qual é uma ferramenta de política monetária?', 0, 'Criação de anúncios', 'Criação de campanhas de anúncios'),
    ('seed_financas_dificil_v3', 'Qual é uma ferramenta de política monetária?', 1, 'Venda de produtos', 'Venda de produtos aos clientes'),
    ('seed_financas_dificil_v3', 'Qual é uma ferramenta de política monetária?', 3, 'Redução de funcionários', 'Redução do número de funcionários'),
    ('seed_financas_dificil_v3', 'O que é política fiscal?', 0, 'Controle de investimentos pessoais', 'Controle dos investimentos pessoais de cada cidadão do país'),
    ('seed_financas_dificil_v3', 'O que é política fiscal?', 2, 'Gestão de cartões bancários', 'Gestão dos cartões bancários emitidos pelos bancos comerciais'),
    ('seed_financas_dificil_v3', 'O que é política fiscal?', 3, 'Estratégia empresarial de marketing', 'Estratégia empresarial de marketing para vender mais produtos no mercado interno'),
    ('seed_financas_dificil_v3', 'O que é taxa básica de juros?', 0, 'Salário mínimo', 'Salário mínimo definido pelo governo para os trabalhadores do país'),
    ('seed_financas_dificil_v3', 'O que é taxa básica de juros?', 1, 'Valor de uma ação', 'Valor de mercado de uma ação negociada na bolsa de valores'),
    ('seed_financas_dificil_v3', 'O que é taxa básica de juros?', 3, 'Preço de um produto', 'Preço de um produto fixado pela empresa que o vende'),
    ('seed_financas_dificil_v3', 'O que é câmbio?', 0, 'Sistema de impostos', 'Sistema de impostos cobrados sobre as importações'),
    ('seed_financas_dificil_v3', 'O que é câmbio?', 1, 'Tipo de investimento', 'Tipo de investimento em ações de empresas do exterior'),
    ('seed_financas_dificil_v3', 'O que é câmbio?', 3, 'Valor de um imóvel', 'Valor de mercado de um imóvel vendido numa cidade'),
    ('seed_financas_dificil_v3', 'O que é risco cambial?', 1, 'Redução de despesas', 'Redução das despesas de uma empresa ao longo do ano'),
    ('seed_financas_dificil_v3', 'O que é risco cambial?', 2, 'Garantia de lucro internacional', 'Garantia de lucro nas operações feitas com outros países'),
    ('seed_financas_dificil_v3', 'O que é risco cambial?', 3, 'Aumento de salário', 'Aumento do salário de quem trabalha com moeda estrangeira'),
    ('seed_financas_dificil_v3', 'O que é mercado de capitais?', 0, 'Sistema de pagamentos digitais', 'Sistema de pagamentos digitais usado por bancos e comerciantes'),
    ('seed_financas_dificil_v3', 'O que é mercado de capitais?', 1, 'Mercado de produtos alimentares', 'Mercado onde se vendem produtos alimentares aos consumidores'),
    ('seed_financas_dificil_v3', 'O que é mercado de capitais?', 2, 'Mercado de trabalho', 'Mercado onde os trabalhadores procuram emprego nas empresas'),
    ('seed_financas_dificil_v3', 'O que são títulos de dívida?', 0, 'Contas pessoais', 'Contas pessoais abertas por clientes nos bancos comerciais'),
    ('seed_financas_dificil_v3', 'O que são títulos de dívida?', 2, 'Cartões bancários', 'Cartões bancários usados para pagar compras nas lojas'),
    ('seed_financas_dificil_v3', 'O que são títulos de dívida?', 3, 'Produtos sem valor financeiro', 'Produtos que não têm qualquer valor financeiro no mercado')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças difícil lote 3: 073#20-35 e 074#1-9: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_dificil_v2', 'O que é planejamento sucessório?', 'Planejamento sucessório é organizar a transferência do patrimônio para as futuras gerações, definindo antecipadamente quem recebe o quê. Evita conflitos e reduz custos e atrasos depois. Não é criar dívidas, planejar compras nem controlar salário.', 'Planejamento sucessório é organizar a transferência do patrimônio para as futuras gerações, definindo antecipadamente quem recebe o quê. Evita conflitos e reduz custos e atrasos depois. Não é planejar compras, criar dívidas nem controlar salários.'),
    ('seed_financas_dificil_v2', 'O que é taxa interna de retorno (TIR)?', 'A TIR é a taxa que mostra a rentabilidade esperada de um investimento, considerando o dinheiro que entra e sai ao longo do tempo. Compara-se com o custo de capital: se a TIR for maior, o projeto tende a compensar. Não é custo operacional, preço de mercado nem valor de uma dívida.', 'A TIR é a taxa que mostra a rentabilidade esperada de um investimento, considerando o dinheiro que entra e sai ao longo do tempo. Compara-se com o custo de capital: se a TIR for maior, o projeto tende a compensar. Não é taxa de empréstimo, custo operacional nem preço de mercado.'),
    ('seed_financas_dificil_v2', 'O que é valor presente líquido (VPL)?', 'O VPL traz para o valor de hoje os fluxos de caixa futuros de um investimento e subtrai o que foi investido, considerando o valor do dinheiro no tempo. Se for positivo, o projeto tende a ser viável. Não é uma soma simples de despesas, salário nem número de clientes.', 'O VPL traz para o valor de hoje os fluxos de caixa futuros de um investimento e subtrai o que foi investido, considerando o valor do dinheiro no tempo. Se for positivo, o projeto tende a ser viável. Não é uma soma simples de despesas, um cálculo de salários nem uma contagem de clientes.'),
    ('seed_financas_dificil_v2', 'O que significa valor do dinheiro no tempo?', 'Uma quantia recebida hoje pode ser aplicada e render, por isso tem maior capacidade de gerar retorno do que a mesma quantia no futuro. É a base dos juros e de métodos como o VPL. O dinheiro muda de valor, o futuro não vale sempre mais e os juros existem.', 'Uma quantia recebida hoje pode ser aplicada e render, por isso tem maior capacidade de gerar retorno do que a mesma quantia no futuro. É a base dos juros e de métodos como o VPL. O dinheiro muda de valor com o tempo e os juros existem.'),
    ('seed_financas_dificil_v2', 'O que é custo de capital?', 'Custo de capital é o que uma empresa paga para obter recursos financeiros, seja em juros de dívidas, seja no retorno esperado pelos sócios. Um projeto só compensa se render mais do que esse custo. Não é imposto de consumo, salário dos trabalhadores nem valor do produto final.', 'Custo de capital é o que uma empresa paga para obter recursos financeiros, seja em juros de dívidas, seja no retorno esperado pelos sócios. Um projeto só compensa se render mais do que esse custo. Não é imposto de consumo, salário nem valor do produto vendido.'),
    ('seed_financas_dificil_v2', 'O que é estrutura de capital?', 'Estrutura de capital é a combinação de recursos próprios (dos sócios) e de financiamentos (dívidas) que a empresa usa para funcionar. A proporção entre os dois afeta o custo de capital e o risco da empresa. Não é total de vendas, número de funcionários nem apenas o dinheiro em caixa.', 'Estrutura de capital é a combinação de recursos próprios (dos sócios) e de financiamentos (dívidas) que a empresa usa para funcionar. A proporção entre os dois afeta o custo de capital e o risco da empresa. Não é total de vendas, número de funcionários nem só o dinheiro em caixa.'),
    ('seed_financas_dificil_v3', 'O que é análise de crédito?', 'Análise de crédito é o processo de avaliar a capacidade de pagamento de uma pessoa ou empresa antes de emprestar. Quem empresta usa esse resultado para decidir se concede o crédito, o limite e os juros: quanto maior o risco, mais caro tende a ser. Não é venda de produtos financeiros, criação de dinheiro nem redução automática de juros.', 'Análise de crédito é o processo de avaliar a capacidade de pagamento de uma pessoa ou empresa antes de emprestar. Quem empresta usa esse resultado para decidir se concede o crédito, o limite e os juros: quanto maior o risco, mais caro tende a ser. Não é venda de produtos financeiros, criação de dinheiro nem redução de juros.'),
    ('seed_financas_dificil_v3', 'O que é política monetária?', 'Política monetária é o conjunto de medidas que o banco central usa para controlar a moeda e a inflação, por exemplo, mexendo nos juros e na quantidade de dinheiro em circulação. Atua sobre toda a economia, ao contrário da política fiscal, que usa receitas e gastos públicos. Não é estratégia de vendas, controle de salários nem planejamento pessoal.', 'Política monetária é o conjunto de medidas que o banco central usa para controlar a moeda e a inflação, por exemplo, mexendo nos juros e na quantidade de dinheiro em circulação. Atua sobre toda a economia, ao contrário da política fiscal, que usa receitas e gastos públicos. Não é estratégia de vendas nem planejamento de gastos das famílias.'),
    ('seed_financas_dificil_v3', 'Qual é uma ferramenta de política monetária?', 'A alteração das taxas de juros é uma das principais ferramentas da política monetária. Juros mais altos encarecem o crédito e tendem a esfriar a procura e a inflação; juros mais baixos têm o efeito contrário. Criar anúncios, vender produtos ou reduzir funcionários não são ferramentas de política monetária.', 'A alteração das taxas de juros é uma das principais ferramentas da política monetária. Juros mais altos encarecem o crédito e tendem a esfriar a procura e a inflação; juros mais baixos têm o efeito contrário. Campanhas de anúncios, venda de produtos ou redução de funcionários não são ferramentas de política monetária.'),
    ('seed_financas_dificil_v3', 'O que é risco cambial?', 'Risco cambial é a possibilidade de perdas devido à variação das taxas de câmbio. Atinge quem tem dívidas, receitas ou investimentos em outra moeda: se a moeda estrangeira sobe, a dívida em dólares, por exemplo, fica mais cara. Não é redução de despesas, garantia de lucro internacional nem aumento de salário.', 'Risco cambial é a possibilidade de perdas devido à variação das taxas de câmbio. Atinge quem tem dívidas, receitas ou investimentos em outra moeda: se a moeda estrangeira sobe, a dívida em dólares, por exemplo, fica mais cara. Não é redução de despesas, garantia de lucro nem aumento de salário.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças difícil lote 3: 073#20-35 e 074#1-9): % atualizada(s) (previstas: 10).', v_updated;
END $$;
