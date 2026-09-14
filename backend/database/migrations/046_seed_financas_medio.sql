-- Migration/seed: conteúdo Finanças, nível Médio (38 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 38 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (55 — distinta das seeds 42 a
-- 54 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Finanças" (slug: financas) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_medio_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_medio_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_medio AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_financas_medio_v1'
    FROM (VALUES
      ('Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?'),
      ('Qual é a principal diferença entre poupança e investimento?'),
      ('O que é liquidez?'),
      ('Por que uma reserva de emergência deve ser relativamente acessível?'),
      ('Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?'),
      ('O que é crédito?'),
      ('Por que o prazo de um empréstimo influencia seu custo?'),
      ('O que significa capacidade de pagamento?'),
      ('O que é orçamento deficitário?'),
      ('Por que registrar pequenos gastos pode ser importante?'),
      ('O que significa risco financeiro?'),
      ('Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?'),
      ('O que é custo total de uma compra financiada?'),
      ('Qual fator deve ser considerado ao comparar dois empréstimos?'),
      ('O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?'),
      ('O que é uma meta financeira de curto prazo?'),
      ('Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?'),
      ('O que é renda ativa?'),
      ('O que é renda passiva?'),
      ('Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?'),
      ('O que é margem de segurança financeira?'),
      ('Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?'),
      ('Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?'),
      ('O que é patrimônio líquido?'),
      ('Por que diversificar pode reduzir a concentração de risco?'),
      ('O que significa investir de acordo com o próprio perfil de risco?'),
      ('Qual é o efeito de uma taxa de juros sobre uma dívida?'),
      ('O que significa pagar uma dívida antecipadamente?'),
      ('Por que é importante guardar comprovativos de pagamentos relevantes?'),
      ('O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?'),
      ('O que é inflação?'),
      ('O que significa diversificar investimentos?'),
      ('O que é juros?'),
      ('Qual é um possível risco de um investimento?'),
      ('Antes de contratar um empréstimo, é importante verificar:'),
      ('O que é patrimônio?'),
      ('O que pode acontecer com o poder de compra quando os preços aumentam significativamente?'),
      ('Por que é importante verificar a origem de uma oportunidade de investimento?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_medio q
    JOIN (VALUES
      ('Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', '3.000 MZN', FALSE, 0),
      ('Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', '3.500 MZN', TRUE, 1),
      ('Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', '4.500 MZN', FALSE, 2),
      ('Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', '2.500 MZN', FALSE, 3),
      ('Qual é a principal diferença entre poupança e investimento?', 'Poupança normalmente prioriza reserva e liquidez, enquanto investimento busca rendimento assumindo determinados riscos', TRUE, 0),
      ('Qual é a principal diferença entre poupança e investimento?', 'Poupança sempre gera mais rendimento', FALSE, 1),
      ('Qual é a principal diferença entre poupança e investimento?', 'Investimento nunca envolve risco', FALSE, 2),
      ('Qual é a principal diferença entre poupança e investimento?', 'São exatamente a mesma coisa', FALSE, 3),
      ('O que é liquidez?', 'Taxa de inflação', FALSE, 0),
      ('O que é liquidez?', 'Quantidade de dívidas', FALSE, 1),
      ('O que é liquidez?', 'Facilidade de transformar um ativo em dinheiro', TRUE, 2),
      ('O que é liquidez?', 'Valor de um imposto', FALSE, 3),
      ('Por que uma reserva de emergência deve ser relativamente acessível?', 'Porque elimina a necessidade de orçamento', FALSE, 0),
      ('Por que uma reserva de emergência deve ser relativamente acessível?', 'Porque deve ser usada para compras de luxo', FALSE, 1),
      ('Por que uma reserva de emergência deve ser relativamente acessível?', 'Porque pode ser necessária para despesas inesperadas', TRUE, 2),
      ('Por que uma reserva de emergência deve ser relativamente acessível?', 'Porque precisa ser investida em ativos de alto risco', FALSE, 3),
      ('Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', '2.500 MZN', FALSE, 0),
      ('Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', '1.500 MZN', FALSE, 1),
      ('Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', '2.000 MZN', TRUE, 2),
      ('Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', '1.000 MZN', FALSE, 3),
      ('O que é crédito?', 'Possibilidade de utilizar recursos com obrigação de pagamento conforme as condições acordadas', TRUE, 0),
      ('O que é crédito?', 'Dinheiro sempre gratuito', FALSE, 1),
      ('O que é crédito?', 'Um tipo de imposto', FALSE, 2),
      ('O que é crédito?', 'Uma forma de salário', FALSE, 3),
      ('Por que o prazo de um empréstimo influencia seu custo?', 'Porque transforma dívida em renda', FALSE, 0),
      ('Por que o prazo de um empréstimo influencia seu custo?', 'Porque o prazo não influencia nada', FALSE, 1),
      ('Por que o prazo de um empréstimo influencia seu custo?', 'Porque elimina os juros', FALSE, 2),
      ('Por que o prazo de um empréstimo influencia seu custo?', 'Porque pode alterar o período durante o qual juros e outros encargos são pagos', TRUE, 3),
      ('O que significa capacidade de pagamento?', 'Valor de uma promoção', FALSE, 0),
      ('O que significa capacidade de pagamento?', 'Número de contas bancárias', FALSE, 1),
      ('O que significa capacidade de pagamento?', 'Capacidade de cumprir obrigações financeiras com os recursos disponíveis', TRUE, 2),
      ('O que significa capacidade de pagamento?', 'Quantidade de produtos comprados', FALSE, 3),
      ('O que é orçamento deficitário?', 'Situação sem despesas', FALSE, 0),
      ('O que é orçamento deficitário?', 'Situação sem receitas', FALSE, 1),
      ('O que é orçamento deficitário?', 'Situação em que receitas superam despesas', FALSE, 2),
      ('O que é orçamento deficitário?', 'Situação em que as despesas planejadas superam as receitas', TRUE, 3),
      ('Por que registrar pequenos gastos pode ser importante?', 'Porque aumenta automaticamente a poupança', FALSE, 0),
      ('Por que registrar pequenos gastos pode ser importante?', 'Porque elimina a necessidade de renda', FALSE, 1),
      ('Por que registrar pequenos gastos pode ser importante?', 'Porque pequenos gastos nunca importam', FALSE, 2),
      ('Por que registrar pequenos gastos pode ser importante?', 'Porque vários gastos pequenos podem representar uma parcela significativa do orçamento', TRUE, 3),
      ('O que significa risco financeiro?', 'Garantia de retorno', FALSE, 0),
      ('O que significa risco financeiro?', 'Garantia de lucro', FALSE, 1),
      ('O que significa risco financeiro?', 'Possibilidade de ocorrer uma perda ou resultado diferente do esperado', TRUE, 2),
      ('O que significa risco financeiro?', 'Ausência completa de incerteza', FALSE, 3),
      ('Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 'Porque bancos não existem', FALSE, 0),
      ('Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 'Porque promessas desse tipo podem indicar risco elevado ou fraude', TRUE, 1),
      ('Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 'Porque todo investimento é ilegal', FALSE, 2),
      ('Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 'Porque investimentos nunca geram retorno', FALSE, 3),
      ('O que é custo total de uma compra financiada?', 'Apenas o imposto', FALSE, 0),
      ('O que é custo total de uma compra financiada?', 'Valor principal somado aos juros e outros encargos aplicáveis', TRUE, 1),
      ('O que é custo total de uma compra financiada?', 'Apenas o valor anunciado inicialmente', FALSE, 2),
      ('O que é custo total de uma compra financiada?', 'Apenas o primeiro pagamento', FALSE, 3),
      ('Qual fator deve ser considerado ao comparar dois empréstimos?', 'Apenas a cor do cartão', FALSE, 0),
      ('Qual fator deve ser considerado ao comparar dois empréstimos?', 'Apenas o nome da instituição', FALSE, 1),
      ('Qual fator deve ser considerado ao comparar dois empréstimos?', 'Apenas a publicidade', FALSE, 2),
      ('Qual fator deve ser considerado ao comparar dois empréstimos?', 'Taxas, encargos, prazo e custo total', TRUE, 3),
      ('O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 'Pode aumentar a capacidade de poupar', TRUE, 0),
      ('O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 'Reduz automaticamente seu salário', FALSE, 1),
      ('O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 'Sempre aumenta as dívidas', FALSE, 2),
      ('O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 'Elimina sua renda', FALSE, 3),
      ('O que é uma meta financeira de curto prazo?', 'Objetivo que pode ser alcançado em um período relativamente próximo', TRUE, 0),
      ('O que é uma meta financeira de curto prazo?', 'Uma despesa inesperada', FALSE, 1),
      ('O que é uma meta financeira de curto prazo?', 'Objetivo que obrigatoriamente demora décadas', FALSE, 2),
      ('O que é uma meta financeira de curto prazo?', 'Uma dívida permanente', FALSE, 3),
      ('Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 'Garante lucro', FALSE, 0),
      ('Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 'Facilita acompanhar quanto já foi reservado para cada objetivo', TRUE, 1),
      ('Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 'Impede qualquer gasto', FALSE, 2),
      ('Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 'Elimina riscos', FALSE, 3),
      ('O que é renda ativa?', 'Renda normalmente obtida em troca de trabalho ou prestação de serviços', TRUE, 0),
      ('O que é renda ativa?', 'Apenas juros bancários', FALSE, 1),
      ('O que é renda ativa?', 'Apenas dividendos', FALSE, 2),
      ('O que é renda ativa?', 'Dinheiro encontrado', FALSE, 3),
      ('O que é renda passiva?', 'Salário mensal obrigatório', FALSE, 0),
      ('O que é renda passiva?', 'Renda que pode ser recebida de ativos ou atividades que não exigem a mesma troca direta de tempo por dinheiro em cada recebimento', TRUE, 1),
      ('O que é renda passiva?', 'Uma despesa', FALSE, 2),
      ('O que é renda passiva?', 'Apenas dinheiro emprestado', FALSE, 3),
      ('Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 'Porque garante prejuízo', FALSE, 0),
      ('Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 'Porque aumenta automaticamente os investimentos', FALSE, 1),
      ('Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 'Porque a perda dessa fonte pode afetar significativamente os recursos disponíveis', TRUE, 2),
      ('Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 'Porque elimina despesas', FALSE, 3),
      ('O que é margem de segurança financeira?', 'Valor de um imposto', FALSE, 0),
      ('O que é margem de segurança financeira?', 'Quantidade de empréstimos', FALSE, 1),
      ('O que é margem de segurança financeira?', 'Espaço entre os recursos disponíveis e as obrigações ou gastos necessários', TRUE, 2),
      ('O que é margem de segurança financeira?', 'Valor de uma multa', FALSE, 3),
      ('Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', '80%', TRUE, 0),
      ('Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', '60%', FALSE, 1),
      ('Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', '90%', FALSE, 2),
      ('Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', '70%', FALSE, 3),
      ('Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?', '3.750 MZN', TRUE, 0),
      ('Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?', '4.250 MZN', FALSE, 1),
      ('Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?', '3.250 MZN', FALSE, 2),
      ('Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?', '3.500 MZN', FALSE, 3),
      ('O que é patrimônio líquido?', 'Diferença entre ativos e obrigações', TRUE, 0),
      ('O que é patrimônio líquido?', 'Soma de todas as despesas mensais', FALSE, 1),
      ('O que é patrimônio líquido?', 'Apenas salário', FALSE, 2),
      ('O que é patrimônio líquido?', 'Apenas dinheiro em espécie', FALSE, 3),
      ('Por que diversificar pode reduzir a concentração de risco?', 'Porque elimina todos os riscos', FALSE, 0),
      ('Por que diversificar pode reduzir a concentração de risco?', 'Porque os recursos não ficam totalmente dependentes do desempenho de um único ativo ou categoria', TRUE, 1),
      ('Por que diversificar pode reduzir a concentração de risco?', 'Porque garante lucro', FALSE, 2),
      ('Por que diversificar pode reduzir a concentração de risco?', 'Porque impede perdas em qualquer situação', FALSE, 3),
      ('O que significa investir de acordo com o próprio perfil de risco?', 'Investir apenas por recomendação de desconhecidos', FALSE, 0),
      ('O que significa investir de acordo com o próprio perfil de risco?', 'Evitar analisar investimentos', FALSE, 1),
      ('O que significa investir de acordo com o próprio perfil de risco?', 'Escolher sempre o investimento de maior risco', FALSE, 2),
      ('O que significa investir de acordo com o próprio perfil de risco?', 'Escolher investimentos compatíveis com sua capacidade e disposição para lidar com perdas e oscilações', TRUE, 3),
      ('Qual é o efeito de uma taxa de juros sobre uma dívida?', 'Transforma a dívida em poupança', FALSE, 0),
      ('Qual é o efeito de uma taxa de juros sobre uma dívida?', 'Pode aumentar o custo total do empréstimo', TRUE, 1),
      ('Qual é o efeito de uma taxa de juros sobre uma dívida?', 'Elimina a dívida', FALSE, 2),
      ('Qual é o efeito de uma taxa de juros sobre uma dívida?', 'Sempre reduz o valor devido', FALSE, 3),
      ('O que significa pagar uma dívida antecipadamente?', 'Aumentar automaticamente a dívida', FALSE, 0),
      ('O que significa pagar uma dívida antecipadamente?', 'Contrair outro empréstimo', FALSE, 1),
      ('O que significa pagar uma dívida antecipadamente?', 'Cancelar uma compra futura', FALSE, 2),
      ('O que significa pagar uma dívida antecipadamente?', 'Liquidar total ou parcialmente a obrigação antes do prazo originalmente previsto', TRUE, 3),
      ('Por que é importante guardar comprovativos de pagamentos relevantes?', 'Garantem lucro', FALSE, 0),
      ('Por que é importante guardar comprovativos de pagamentos relevantes?', 'Aumentam automaticamente o saldo', FALSE, 1),
      ('Por que é importante guardar comprovativos de pagamentos relevantes?', 'Eliminam impostos', FALSE, 2),
      ('Por que é importante guardar comprovativos de pagamentos relevantes?', 'Podem servir como evidência da transação', TRUE, 3),
      ('O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 'Pode acumular encargos, atrasos e outros problemas financeiros', TRUE, 0),
      ('O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 'A dívida desaparece automaticamente', FALSE, 1),
      ('O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 'O dinheiro aumenta', FALSE, 2),
      ('O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 'O credor paga a dívida', FALSE, 3),
      ('O que é inflação?', 'Aumento automático dos salários', FALSE, 0),
      ('O que é inflação?', 'Redução da quantidade de dinheiro', FALSE, 1),
      ('O que é inflação?', 'Aumento geral dos preços ao longo do tempo', TRUE, 2),
      ('O que é inflação?', 'Redução geral dos preços', FALSE, 3),
      ('O que significa diversificar investimentos?', 'Colocar todo o dinheiro em um único ativo', FALSE, 0),
      ('O que significa diversificar investimentos?', 'Não investir nunca', FALSE, 1),
      ('O que significa diversificar investimentos?', 'Distribuir recursos entre diferentes investimentos', TRUE, 2),
      ('O que significa diversificar investimentos?', 'Investir apenas em dinheiro físico', FALSE, 3),
      ('O que é juros?', 'Um imposto obrigatório sobre qualquer compra', FALSE, 0),
      ('O que é juros?', 'Um salário adicional garantido', FALSE, 1),
      ('O que é juros?', 'Um desconto permanente', FALSE, 2),
      ('O que é juros?', 'Um valor relacionado ao uso ou rendimento de dinheiro ao longo do tempo', TRUE, 3),
      ('Qual é um possível risco de um investimento?', 'Ganhar sempre', FALSE, 0),
      ('Qual é um possível risco de um investimento?', 'Perder parte ou todo o capital investido', TRUE, 1),
      ('Qual é um possível risco de um investimento?', 'Nunca sofrer variação', FALSE, 2),
      ('Qual é um possível risco de um investimento?', 'Ter lucro garantido', FALSE, 3),
      ('Antes de contratar um empréstimo, é importante verificar:', 'Apenas o nome do funcionário', FALSE, 0),
      ('Antes de contratar um empréstimo, é importante verificar:', 'Apenas a aparência do banco', FALSE, 1),
      ('Antes de contratar um empréstimo, é importante verificar:', 'Somente a publicidade', FALSE, 2),
      ('Antes de contratar um empréstimo, é importante verificar:', 'Taxas, prazo e custo total', TRUE, 3),
      ('O que é patrimônio?', 'Apenas salário mensal', FALSE, 0),
      ('O que é patrimônio?', 'Conjunto de bens, direitos e obrigações de uma pessoa ou entidade', TRUE, 1),
      ('O que é patrimônio?', 'Apenas dívidas', FALSE, 2),
      ('O que é patrimônio?', 'Apenas dinheiro disponível na carteira', FALSE, 3),
      ('O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 'Pode diminuir', TRUE, 0),
      ('O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 'Nunca muda', FALSE, 1),
      ('O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 'Sempre aumenta', FALSE, 2),
      ('O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 'Duplica automaticamente', FALSE, 3),
      ('Por que é importante verificar a origem de uma oportunidade de investimento?', 'Para garantir lucro de 100%', FALSE, 0),
      ('Por que é importante verificar a origem de uma oportunidade de investimento?', 'Para reduzir o risco de cair em fraude', TRUE, 1),
      ('Por que é importante verificar a origem de uma oportunidade de investimento?', 'Para aumentar automaticamente o investimento', FALSE, 2),
      ('Por que é importante verificar a origem de uma oportunidade de investimento?', 'Para evitar qualquer imposto', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_medio;

    RAISE NOTICE '38 perguntas inseridas com sucesso (source=seed_financas_medio_v1).';
  END IF;
END $$;

COMMIT;
