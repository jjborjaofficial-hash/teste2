-- Explicações pedagógicas (BE-004) — Finanças médio, lote 22 (10 perguntas): fecha o seed 065
-- (as 7 últimas, source 'seed_financas_medio_v2') e o seed 069 inteiro (3, source
-- 'seed_financas_medio_v3'). Mesmo critério das migrations 109 a 128: só preenche
-- questions.explanation das perguntas que ainda não têm explicação (idempotente, nunca
-- sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'O que é renda variável?',
     'Renda variável é o investimento cujo retorno pode mudar conforme o mercado, como as ações. Pode render mais ou menos do que o esperado. Não é conta mensal, imposto nem salário fixo.'),
    ('seed_financas_medio_v2', 'O que é análise fundamentalista?',
     'Análise fundamentalista é avaliar os dados financeiros e econômicos de uma empresa para decidir se vale investir nela. Não é escolha aleatória, controle de despesas pessoais nem criação de cartões.'),
    ('seed_financas_medio_v2', 'O que é planejamento financeiro empresarial?',
     'Planejamento financeiro empresarial é organizar os recursos financeiros de uma empresa para atingir seus objetivos. Publicidade, criação de produtos e controle de vendas, sozinhos, não são planejamento financeiro.'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?',
     'Orçamento empresarial é o planejamento das receitas, despesas e investimentos de uma empresa. Não é lista de funcionários, documento de identidade nem contrato bancário.'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?',
     'Sustentabilidade financeira é a capacidade de manter o equilíbrio financeiro ao longo do tempo. Gastar todos os recursos, ter dívidas constantes ou não planejar põe isso em risco.'),
    ('seed_financas_medio_v2', 'O que é independência financeira pessoal?',
     'Independência financeira pessoal é conseguir manter o padrão de vida com os próprios recursos. Depender de empréstimos, não ter renda ou ignorar despesas não é independência.'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?',
     'Uma boa prática é controlar os gastos, criar reservas e planejar objetivos. Gastar sem acompanhamento, evitar organização ou fazer dívidas constantes piora a saúde financeira.'),
    ('seed_financas_medio_v3', 'O que é uma taxa de retorno de investimento?',
     'Taxa de retorno é o percentual de ganho ou perda obtido numa aplicação financeira, em relação ao valor investido. Não é o valor da conta bancária, o número de clientes nem o dinheiro gasto.'),
    ('seed_financas_medio_v3', 'Qual é a vantagem de criar uma carteira de investimentos diversificada?',
     'Uma carteira diversificada reduz riscos, ao distribuir os recursos em diferentes ativos. Não garante lucro em todos os investimentos, não dispensa análise e não elimina custos.'),
    ('seed_financas_medio_v3', 'O que significa viver abaixo das próprias possibilidades financeiras?',
     'É gastar menos do que se recebe e conseguir guardar recursos. Gastar todo o salário, evitar planejamento ou fazer mais dívidas é o contrário.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 22: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
