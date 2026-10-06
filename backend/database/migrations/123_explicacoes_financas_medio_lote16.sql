-- Explicações pedagógicas (BE-004) — Finanças médio lote 16, perguntas 26 a 35 do seed 046 (10 perguntas). Mesmo critério das migrations 109 a
-- 122: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v1', 'O que significa investir de acordo com o próprio perfil de risco?',
     'Investir conforme o perfil de risco é escolher aplicações compatíveis com a sua capacidade e disposição de lidar com perdas e oscilações. Seguir desconhecidos, não analisar ou escolher sempre o maior risco são erros.'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?',
     'Os juros aumentam o custo total do empréstimo: no fim, paga-se mais do que o valor emprestado. Os juros não eliminam a dívida, não a transformam em poupança e não reduzem o valor devido.'),
    ('seed_financas_medio_v1', 'O que significa pagar uma dívida antecipadamente?',
     'Pagar antecipadamente é quitar a dívida, toda ou em parte, antes do prazo previsto. Não aumenta a dívida nem é contrair outro empréstimo, e pode reduzir os juros que se pagariam.'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?',
     'O comprovativo serve como prova de que o pagamento foi feito, útil se houver dúvida ou cobrança indevida. Não aumenta o saldo, não elimina impostos e não garante lucro.'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?',
     'Ignorar as obrigações financeiras pode acumular encargos, atrasos e outros problemas. A dívida não desaparece sozinha e o credor não a paga no lugar da pessoa.'),
    ('seed_financas_medio_v1', 'O que é inflação?',
     'Inflação é o aumento geral dos preços ao longo do tempo. Com ela, a mesma quantia compra menos. Não é aumento automático dos salários nem queda dos preços.'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?',
     'Diversificar é distribuir o dinheiro entre diferentes investimentos, para não depender de um só. Pôr tudo num único ativo, ou não investir, não é diversificar.'),
    ('seed_financas_medio_v1', 'O que é juros?',
     'Juros são o valor ligado ao uso ou ao rendimento do dinheiro ao longo do tempo: quem pede emprestado paga juros, e quem aplica pode receber. Não são imposto sobre compras, salário extra nem desconto.'),
    ('seed_financas_medio_v1', 'Qual é um possível risco de um investimento?',
     'Um risco de investir é perder parte ou todo o capital aplicado. Lucro garantido, ganhar sempre ou nunca variar não existem em investimentos com risco.'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:',
     'Antes de contratar um empréstimo, confira as taxas, o prazo e o custo total, para saber quanto vai pagar. A aparência do banco, a publicidade ou o nome do funcionário não dizem isso.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 16, perguntas 26 a 35 do seed 046: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
