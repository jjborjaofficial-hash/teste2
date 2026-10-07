-- Alternativas (BE-003, regularização) — Finanças difícil lote 4: 074#10-33 e 075#1.
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
    ('seed_financas_dificil_v3', 'O que é uma debênture?', 0, 'Imposto empresarial', 'Imposto cobrado às empresas sobre os lucros do exercício'),
    ('seed_financas_dificil_v3', 'O que é uma debênture?', 1, 'Conta corrente empresarial', 'Conta corrente aberta pela empresa num banco comercial'),
    ('seed_financas_dificil_v3', 'O que é uma debênture?', 3, 'Cartão de crédito', 'Cartão de crédito usado pela empresa para pagar as despesas diárias com fornecedores'),
    ('seed_financas_dificil_v3', 'O que é um título público?', 0, 'Ação de uma empresa privada', 'Ação emitida por uma empresa privada para vender capital'),
    ('seed_financas_dificil_v3', 'O que é um título público?', 2, 'Salário público', 'Salário pago pelo governo aos funcionários públicos do país'),
    ('seed_financas_dificil_v3', 'O que é um título público?', 3, 'Conta bancária', 'Conta bancária do Estado aberta no banco central do país para guardar as receitas'),
    ('seed_financas_dificil_v3', 'O que é duration de um título?', 1, 'Número de investidores', 'Número de investidores que compraram o título durante a emissão no mercado'),
    ('seed_financas_dificil_v3', 'O que é duration de um título?', 2, 'Valor inicial investido', 'Valor inicial investido pelo comprador ao adquirir o título no mercado'),
    ('seed_financas_dificil_v3', 'O que é duration de um título?', 3, 'Quantidade de ações', 'Quantidade de ações emitidas pela empresa que vendeu o título ao público'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 1, 'Quantidade de dinheiro guardado', 'Quantidade de dinheiro que as famílias guardam no banco'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 2, 'Valor atual do salário', 'Valor atual do salário pago aos trabalhadores no país'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 3, 'Lucro empresarial', 'Lucro obtido pelas empresas no último ano de atividade'),
    ('seed_financas_dificil_v3', 'O que é crescimento econômico?', 0, 'Apenas aumento dos preços', 'Aumento apenas dos preços dos produtos vendidos no mercado'),
    ('seed_financas_dificil_v3', 'O que é crescimento econômico?', 1, 'Diminuição da produção', 'Diminuição da produção de bens e serviços do país'),
    ('seed_financas_dificil_v3', 'O que é crescimento econômico?', 2, 'Redução dos investimentos', 'Redução dos investimentos feitos pelas empresas do setor'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?', 1, 'Aumento garantido dos lucros', 'Aumento garantido dos lucros das empresas em todos os setores'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?', 2, 'Redução dos impostos sempre', 'Redução dos impostos em todos os períodos de crise'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?', 3, 'Crescimento acelerado da economia', 'Crescimento acelerado da economia com aumento do emprego'),
    ('seed_financas_dificil_v3', 'O que é ciclo econômico?', 0, 'Movimento de uma conta bancária', 'Movimento de entradas e saídas de dinheiro numa conta bancária'),
    ('seed_financas_dificil_v3', 'O que é ciclo econômico?', 1, 'Tipo de investimento', 'Tipo de investimento feito por quem aplica no longo prazo'),
    ('seed_financas_dificil_v3', 'O que é ciclo econômico?', 3, 'Processo de pagamento', 'Processo de pagamento das dívidas de uma empresa ao banco'),
    ('seed_financas_dificil_v3', 'O que é produtividade financeira empresarial?', 0, 'Eliminação de investimentos', 'Eliminação dos investimentos que não dão resultado no curto prazo'),
    ('seed_financas_dificil_v3', 'O que é produtividade financeira empresarial?', 2, 'Redução de clientes', 'Redução do número de clientes para diminuir os custos de atendimento da empresa'),
    ('seed_financas_dificil_v3', 'O que é produtividade financeira empresarial?', 3, 'Aumento de despesas', 'Aumento das despesas da empresa para produzir cada vez mais'),
    ('seed_financas_dificil_v3', 'O que é margem operacional?', 0, 'Quantidade de funcionários', 'Quantidade de funcionários que trabalham na área operacional da empresa no ano'),
    ('seed_financas_dificil_v3', 'O que é margem operacional?', 1, 'Valor dos impostos apenas', 'Valor total dos impostos pagos pela empresa no ano'),
    ('seed_financas_dificil_v3', 'O que é margem operacional?', 2, 'Valor total das vendas', 'Valor total das vendas obtidas pela atividade da empresa'),
    ('seed_financas_dificil_v3', 'O que é margem líquida?', 0, 'Valor do estoque', 'Valor do estoque guardado nos armazéns da empresa'),
    ('seed_financas_dificil_v3', 'O que é margem líquida?', 2, 'Total de despesas', 'Total das despesas pagas pela empresa durante o ano'),
    ('seed_financas_dificil_v3', 'O que é margem líquida?', 3, 'Valor do investimento inicial', 'Valor do investimento inicial feito pelos sócios'),
    ('seed_financas_dificil_v3', 'O que é EBITDA?', 0, 'Taxa de cartão', 'Taxa cobrada pelas operadoras de cartão sobre cada venda feita pela empresa durante o período'),
    ('seed_financas_dificil_v3', 'O que é EBITDA?', 1, 'Valor de uma dívida pessoal', 'Valor de uma dívida pessoal contraída pelo dono para comprar bens'),
    ('seed_financas_dificil_v3', 'O que é EBITDA?', 2, 'Salário empresarial', 'Salário empresarial pago aos administradores e diretores da empresa'),
    ('seed_financas_dificil_v3', 'O que é depreciação?', 0, 'Receita extra', 'Receita extra obtida com a venda de um bem usado'),
    ('seed_financas_dificil_v3', 'O que é depreciação?', 1, 'Lucro financeiro', 'Lucro financeiro obtido com a aplicação do dinheiro'),
    ('seed_financas_dificil_v3', 'O que é depreciação?', 2, 'Aumento automático do valor', 'Aumento automático do valor de um bem com o tempo'),
    ('seed_financas_dificil_v3', 'O que é amortização contábil?', 0, 'Criação de novos ativos', 'Criação de novos ativos para substituir os que se desgastam com o uso'),
    ('seed_financas_dificil_v3', 'O que é amortização contábil?', 2, 'Venda de produtos', 'Venda dos produtos fabricados com ativos que já estão desgastados'),
    ('seed_financas_dificil_v3', 'O que é amortização contábil?', 3, 'Aumento de impostos', 'Aumento dos impostos cobrados sobre o uso dos ativos da empresa em cada ano'),
    ('seed_financas_dificil_v3', 'O que é capital próprio?', 1, 'Dinheiro emprestado pelo banco', 'Dinheiro emprestado à empresa por um banco comercial'),
    ('seed_financas_dificil_v3', 'O que é capital próprio?', 2, 'Imposto pago', 'Imposto pago pela empresa sobre o lucro do ano passado'),
    ('seed_financas_dificil_v3', 'O que é capital próprio?', 3, 'Dívida de clientes', 'Dívida dos clientes que compraram a prazo na empresa'),
    ('seed_financas_dificil_v3', 'O que é capital de terceiros?', 0, 'Dinheiro pessoal guardado', 'Dinheiro pessoal guardado pelo dono em casa há anos'),
    ('seed_financas_dificil_v3', 'O que é capital de terceiros?', 1, 'Lucro distribuído', 'Lucro distribuído pela empresa aos sócios no fim de cada ano'),
    ('seed_financas_dificil_v3', 'O que é capital de terceiros?', 3, 'Receita de vendas', 'Receita de vendas obtida com os produtos da empresa'),
    ('seed_financas_dificil_v3', 'O que é análise de viabilidade financeira?', 1, 'Criação de despesas', 'Criação de despesas novas para a empresa investir mais'),
    ('seed_financas_dificil_v3', 'O que é análise de viabilidade financeira?', 2, 'Controle de funcionários', 'Controle dos funcionários que trabalham no projeto da empresa em cada setor'),
    ('seed_financas_dificil_v3', 'O que é análise de viabilidade financeira?', 3, 'Publicidade empresarial', 'Publicidade empresarial feita para apresentar o projeto'),
    ('seed_financas_dificil_v3', 'O que é orçamento de capital?', 0, 'Lista de clientes', 'Lista dos clientes que mais compram produtos da empresa'),
    ('seed_financas_dificil_v3', 'O que é orçamento de capital?', 1, 'Controle de salários', 'Controle dos salários pagos aos funcionários da empresa'),
    ('seed_financas_dificil_v3', 'O que é orçamento de capital?', 3, 'Plano de vendas', 'Plano de vendas elaborado para o próximo ano da empresa e para os seus clientes'),
    ('seed_financas_dificil_v3', 'O que é custo fixo?', 0, 'Custo que muda sempre', 'Custo que muda sempre que a empresa aumenta o preço de venda'),
    ('seed_financas_dificil_v3', 'O que é custo fixo?', 1, 'Receita extra', 'Receita extra obtida pela empresa com vendas fora do normal'),
    ('seed_financas_dificil_v3', 'O que é custo fixo?', 2, 'Lucro líquido', 'Lucro líquido que sobra depois de pagar todas as despesas'),
    ('seed_financas_dificil_v3', 'O que é custo variável?', 1, 'Investimento financeiro', 'Investimento financeiro feito pela empresa a longo prazo'),
    ('seed_financas_dificil_v3', 'O que é custo variável?', 2, 'Custo sempre igual', 'Custo que se mantém igual em qualquer nível de produção'),
    ('seed_financas_dificil_v3', 'O que é custo variável?', 3, 'Receita garantida', 'Receita garantida mesmo quando a empresa não vende nada'),
    ('seed_financas_dificil_v3', 'O que é eficiência financeira?', 0, 'Gastar mais recursos', 'Gastar mais recursos do que o necessário para atingir metas'),
    ('seed_financas_dificil_v3', 'O que é eficiência financeira?', 2, 'Evitar planejamento', 'Evitar planejamento para ganhar tempo nas decisões da empresa e dos seus sócios'),
    ('seed_financas_dificil_v3', 'O que é eficiência financeira?', 3, 'Aumentar dívidas', 'Aumentar as dívidas para financiar todas as despesas diárias'),
    ('seed_financas_dificil_v3', 'O que é estratégia financeira empresarial?', 1, 'Apenas vender produtos', 'Apenas vender produtos para aumentar o volume das vendas'),
    ('seed_financas_dificil_v3', 'O que é estratégia financeira empresarial?', 2, 'Contratar funcionários', 'Contratar funcionários para ampliar a equipe da empresa'),
    ('seed_financas_dificil_v3', 'O que é estratégia financeira empresarial?', 3, 'Criar publicidade', 'Criar publicidade para divulgar os produtos da empresa nos meios de comunicação'),
    ('seed_financas_dificil_v3', 'O que é previsão financeira?', 1, 'Controle de estoque', 'Controle do estoque de produtos guardados no armazém'),
    ('seed_financas_dificil_v3', 'O que é previsão financeira?', 2, 'Registro de despesas passadas apenas', 'Registro apenas das despesas passadas da empresa no ano'),
    ('seed_financas_dificil_v3', 'O que é previsão financeira?', 3, 'Lista de clientes', 'Lista dos clientes que compram regularmente da empresa'),
    ('seed_financas_dificil_v3', 'O que é controle interno financeiro?', 0, 'Estratégia de marketing', 'Estratégia de marketing para atrair mais clientes à empresa'),
    ('seed_financas_dificil_v3', 'O que é controle interno financeiro?', 1, 'Campanha publicitária', 'Campanha publicitária para divulgar os produtos da empresa'),
    ('seed_financas_dificil_v3', 'O que é controle interno financeiro?', 2, 'Sistema de vendas', 'Sistema de vendas usado para registar os pedidos dos clientes e emitir as faturas'),
    ('seed_financas_dificil_v3', 'O que é inteligência financeira?', 0, 'Ignorar informações financeiras', 'Hábito de ignorar as informações financeiras disponíveis na hora de tomar decisões'),
    ('seed_financas_dificil_v3', 'O que é inteligência financeira?', 1, 'Evitar investimentos', 'Atitude de evitar qualquer tipo de investimento por medo de perdas'),
    ('seed_financas_dificil_v3', 'O que é inteligência financeira?', 2, 'Gastar sem planejamento', 'Costume de gastar o dinheiro sem planejamento nem controle dos gastos'),
    ('seed_financas_dificil_v4', 'O que é due diligence financeira?', 0, 'Processo de criação de uma campanha publicitária', 'Processo de preparação de uma campanha publicitária feita antes de uma decisão importante, como o lançamento de um produto novo no mercado'),
    ('seed_financas_dificil_v4', 'O que é due diligence financeira?', 1, 'Sistema usado apenas para controlar funcionários', 'Sistema usado para controlar os funcionários de uma empresa depois de uma decisão importante, como a fusão com outra organização'),
    ('seed_financas_dificil_v4', 'O que é due diligence financeira?', 3, 'Método utilizado para aumentar preços automaticamente', 'Método utilizado para aumentar os preços de forma automática antes de uma decisão importante, como a aquisição de uma empresa')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças difícil lote 4: 074#10-33 e 075#1: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_dificil_v3', 'O que é uma debênture?', 'Debênture é um título de dívida emitido por uma empresa para captar recursos: quem a compra empresta dinheiro à empresa e recebe juros. É uma alternativa ao empréstimo bancário e, ao contrário da ação, não dá participação na empresa. Não é imposto empresarial, conta corrente nem cartão de crédito.', 'Debênture é um título de dívida emitido por uma empresa para captar recursos: quem a compra empresta dinheiro à empresa e recebe juros. É uma alternativa ao empréstimo bancário e, ao contrário da ação, não dá participação na empresa. Não é imposto, conta corrente nem cartão de crédito.'),
    ('seed_financas_dificil_v3', 'O que é um título público?', 'Título público é um instrumento de dívida emitido pelo governo para captar recursos: quem o compra empresta dinheiro ao Estado, que paga juros e devolve o valor no vencimento. Costuma ser visto como de menor risco de crédito, porque quem deve é o governo. Não é ação de empresa privada, salário público nem conta bancária.', 'Título público é um instrumento de dívida emitido pelo governo para captar recursos: quem o compra empresta dinheiro ao Estado, que paga juros e devolve o valor no vencimento. Costuma ser visto como de menor risco de crédito, porque quem deve é o governo. Não é ação de empresa privada, salário público nem conta bancária do Estado.'),
    ('seed_financas_dificil_v3', 'O que é ciclo econômico?', 'Ciclo econômico é a alternância entre períodos de crescimento e de redução da atividade econômica: expansão, pico, recessão e recuperação. Entender o ciclo ajuda a ver por que juros, emprego e lucros mudam ao longo do tempo. Não é movimento de uma conta bancária, tipo de investimento nem processo de pagamento.', 'Ciclo econômico é a alternância entre períodos de crescimento e de redução da atividade econômica: expansão, pico, recessão e recuperação. Entender o ciclo ajuda a ver por que juros, emprego e lucros mudam ao longo do tempo. Não é movimento de uma conta, tipo de investimento nem pagamento de dívidas.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças difícil lote 4: 074#10-33 e 075#1): % atualizada(s) (previstas: 3).', v_updated;
END $$;
