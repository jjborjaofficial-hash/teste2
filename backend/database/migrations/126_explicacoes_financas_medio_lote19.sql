-- Explicações pedagógicas (BE-004) — Finanças médio lote 19, perguntas 18 a 27 do seed 065 (10 perguntas). Mesmo critério das migrations 109 a
-- 125: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'Por que acompanhar o fluxo de caixa é importante?',
     'Acompanhar o fluxo de caixa mostra quanto entra e quanto sai, ajudando a entender a situação financeira e a decidir melhor. Quem não acompanha perde o controle e planeja pior.'),
    ('seed_financas_medio_v2', 'O que é inadimplência?',
     'Inadimplência é a falta de pagamento de uma obrigação financeira no prazo. Gera multas e juros e pode prejudicar o acesso a crédito. Não é economia, investimento nem aumento de renda.'),
    ('seed_financas_medio_v2', 'O que é renegociação de dívida?',
     'Renegociar uma dívida é combinar com o credor novas condições de pagamento para facilitar a quitação, como outro prazo ou outras parcelas. Não é cancelar todos os pagamentos nem criar novas dívidas.'),
    ('seed_financas_medio_v2', 'O que é crédito responsável?',
     'Crédito responsável é usar o crédito considerando a capacidade de pagamento, sabendo os juros e quanto pode pagar por mês. Usar todo o limite, pedir empréstimos sem análise ou ignorar juros não é responsável.'),
    ('seed_financas_medio_v2', 'O que é planejamento de aposentadoria?',
     'Planejamento de aposentadoria é organizar o dinheiro agora para garantir recursos no futuro, quando já não se trabalhar. Gastar tudo, fazer dívidas ou evitar investir vai no sentido contrário.'),
    ('seed_financas_medio_v2', 'O que é independência financeira?',
     'Independência financeira é a situação em que os rendimentos conseguem cobrir as despesas, sem depender só de trabalhar. Gastar sem controle, não ter renda ou ter muitas dívidas é o oposto.'),
    ('seed_financas_medio_v2', 'O que é análise financeira?',
     'Análise financeira é avaliar informações financeiras, como receitas, despesas e dívidas, para tomar decisões. Não é fazer compras, apenas guardar dinheiro nem criar contas.'),
    ('seed_financas_medio_v2', 'O que é inflação de demanda?',
     'Inflação de demanda é o aumento dos preços causado por excesso de procura: quando muita gente quer comprar e há pouco para vender, os preços sobem. Não é queda de investimentos nem redução de salários.'),
    ('seed_financas_medio_v2', 'O que é inflação de custos?',
     'Inflação de custos é o aumento dos preços causado pelo aumento dos custos de produção, como matéria-prima ou energia. As empresas repassam o custo maior aos preços. Não é crescimento da poupança nem queda de preços.'),
    ('seed_financas_medio_v2', 'O que é deflação?',
     'Deflação é a redução geral dos preços de produtos e serviços, o oposto da inflação. Não é aumento de preços, de dívidas ou de juros.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 19, perguntas 18 a 27 do seed 065: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
