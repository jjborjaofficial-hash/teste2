-- Explicações pedagógicas (BE-004) — Finanças difícil lote 29, perguntas 25 a 34 do seed 073 (10 perguntas). Mesmo critério das migrations 109 a
-- 135: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v2', 'O que é estrutura de capital?',
     'Estrutura de capital é a combinação de recursos próprios (dos sócios) e de financiamentos (dívidas) que a empresa usa para funcionar. A proporção entre os dois afeta o custo de capital e o risco da empresa. Não é total de vendas, número de funcionários nem apenas o dinheiro em caixa.'),
    ('seed_financas_dificil_v2', 'O que é alavancagem financeira?',
     'Alavancagem financeira é usar recursos de terceiros, como empréstimos, para aumentar o potencial de retorno: se o investimento render mais do que o custo da dívida, o ganho sobre o capital próprio cresce. Mas o risco também cresce. Não é eliminar investimentos, controlar despesas pessoais nem reduzir vendas.'),
    ('seed_financas_dificil_v2', 'Qual é um risco da alavancagem financeira?',
     'A alavancagem amplia os resultados nos dois sentidos: se os resultados esperados não acontecem, as perdas aumentam, e as dívidas continuam a ter de ser pagas. Por isso não garante lucro, não reduz custos automaticamente e não elimina dívidas.'),
    ('seed_financas_dificil_v2', 'O que é fusão empresarial?',
     'Fusão é a união de duas ou mais empresas que formam uma nova estrutura. Difere da aquisição, em que uma empresa compra outra. Em geral, busca ganhar escala, reduzir custos ou crescer no mercado. Não é venda de produtos, fechamento de empresa nem redução de impostos.'),
    ('seed_financas_dificil_v2', 'O que é aquisição empresarial?',
     'Aquisição é a compra de uma empresa por outra organização, que passa a controlá-la. Difere da fusão, em que as empresas se unem numa nova estrutura. Não é criar dívida pessoal, pagar salário nem controle bancário.'),
    ('seed_financas_dificil_v2', 'O que é auditoria financeira?',
     'Auditoria financeira é o exame das informações financeiras de uma organização para verificar se são precisas e estão em conformidade com as normas. Dá mais confiança a sócios, bancos e investidores nos números apresentados. Não é controle de marketing, criação de investimentos nem venda de ações.'),
    ('seed_financas_dificil_v2', 'O que é demonstração financeira?',
     'Demonstração financeira é o relatório que apresenta as informações econômicas e financeiras de uma organização, como o balanço patrimonial e a demonstração de resultados. É a partir delas que sócios, bancos e investidores analisam a empresa. Não é plano de vendas, contrato de empréstimo nem publicidade.'),
    ('seed_financas_dificil_v2', 'O que é balanço patrimonial?',
     'Balanço patrimonial é o relatório que mostra, num momento, os ativos (o que a empresa tem), os passivos (o que deve) e o patrimônio líquido (a diferença). É uma fotografia da situação financeira. Não é controle de funcionários, plano de marketing nem lista de clientes.'),
    ('seed_financas_dificil_v2', 'O que é demonstração de resultados?',
     'Demonstração de resultados é o relatório que mostra as receitas, os custos e o lucro ou prejuízo de uma empresa num período. Enquanto o balanço é uma fotografia num momento, ela mostra o desempenho ao longo do tempo. Não é documento de identidade, contrato bancário nem lista de investimentos pessoais.'),
    ('seed_financas_dificil_v2', 'O que é liquidez financeira de uma empresa?',
     'Liquidez de uma empresa é a capacidade de cumprir as obrigações de curto prazo, como salários e fornecedores, com o dinheiro ou os ativos de fácil conversão que tem. Uma empresa lucrativa pode ter pouca liquidez se o dinheiro estiver preso. Não é número de produtos, valor da publicidade nem quantidade de funcionários.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 29, perguntas 25 a 34 do seed 073: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
