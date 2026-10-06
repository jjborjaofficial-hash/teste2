-- Explicações pedagógicas (BE-004) — Finanças médio lote 20, perguntas 28 a 37 do seed 065 (10 perguntas). Mesmo critério das migrations 109 a
-- 126: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'O que é taxa de juros?',
     'Taxa de juros é o percentual cobrado ou pago pelo uso do dinheiro. Quem pede emprestado paga juros, e quem aplica pode receber. Não é o preço de um produto, o salário nem o valor de uma conta.'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?',
     'Com juros altos, o crédito fica mais caro: paga-se mais pelo mesmo empréstimo. Isso não reduz as dívidas, não elimina pagamentos e não aumenta a renda.'),
    ('seed_financas_medio_v2', 'O que é amortização?',
     'Amortização é a redução gradual de uma dívida por meio dos pagamentos feitos. Cada parcela paga abate parte do que se deve. Não é criar dívida, aumentar juros nem perder investimento.'),
    ('seed_financas_medio_v2', 'O que é financiamento?',
     'Financiamento é a operação em que uma instituição fornece o dinheiro para uma compra, como um carro ou uma casa, e a pessoa paga depois. Não é dinheiro gratuito, doação nem investimento sem risco.'),
    ('seed_financas_medio_v2', 'Qual a diferença entre financiamento e empréstimo?',
     'O financiamento costuma ter uma finalidade específica, como comprar um bem, enquanto o empréstimo pode ser usado de forma mais livre. Ambos precisam ser pagos, com juros.'),
    ('seed_financas_medio_v2', 'O que é cheque especial?',
     'Cheque especial é uma linha de crédito que o banco deixa disponível na conta para uso emergencial, quando o saldo acaba. Não é reserva de emergência, cartão de débito nem conta de investimento.'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?',
     'O cheque especial deve ser usado com cuidado porque costuma ter juros elevados, e a dívida cresce rápido. Não elimina dívidas, não aumenta salário e não é investimento.'),
    ('seed_financas_medio_v2', 'O que é score de crédito?',
     'Score de crédito é uma pontuação que avalia o histórico financeiro da pessoa, como se paga as contas em dia. Não é um tipo de cartão, o salário nem o saldo da conta.'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?',
     'Um bom score pode facilitar o acesso a crédito em melhores condições, como juros menores. Não garante riqueza, não elimina pagamentos e não substitui investimentos.'),
    ('seed_financas_medio_v2', 'O que é planejamento tributário?',
     'Planejamento tributário é organizar as obrigações fiscais dentro da lei, para pagar o que é devido da forma mais adequada. Evitar impostos de forma ilegal é crime, e não faz parte do planejamento.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 20, perguntas 28 a 37 do seed 065: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
