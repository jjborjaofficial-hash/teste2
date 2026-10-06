-- Explicações pedagógicas (BE-004) — Finanças médio, lote 17 (10 perguntas): fecha o seed 046
-- (as 3 últimas, source 'seed_financas_medio_v1') e abre o seed 065 (as 7 primeiras, source
-- 'seed_financas_medio_v2'). Mesmo critério das migrations 109 a 123: só preenche
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
    ('seed_financas_medio_v1', 'O que é patrimônio?',
     'Patrimônio é o conjunto de bens, direitos e obrigações de uma pessoa ou entidade. Não é só o salário, só as dívidas ou só o dinheiro que se leva na carteira.'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?',
     'Quando os preços sobem muito, o poder de compra pode diminuir: a mesma quantia compra menos coisas. Ele não fica igual, não aumenta sempre e não duplica sozinho.'),
    ('seed_financas_medio_v1', 'Por que é importante verificar a origem de uma oportunidade de investimento?',
     'Verificar a origem da oportunidade ajuda a reduzir o risco de cair em fraude. Não garante lucro nem isenta de impostos. Desconfie de ofertas de quem você não conhece ou não consegue confirmar.'),
    ('seed_financas_medio_v2', 'O que é diversificação de investimentos?',
     'Diversificar é distribuir o dinheiro em diferentes tipos de investimento para reduzir riscos. Pôr tudo num só investimento, gastar tudo ou evitar investir não é diversificar.'),
    ('seed_financas_medio_v2', 'Qual é a principal finalidade de uma reserva de emergência?',
     'A reserva de emergência serve para cobrir situações inesperadas sem precisar recorrer a dívidas. Não é para gastos mensais, produtos de luxo nem investimentos de alto risco.'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?',
     'Nos juros compostos, os juros rendem também sobre os juros anteriores. Em longo prazo, isso pode aumentar muito o crescimento do dinheiro. Eles não eliminam o lucro nem reduzem sempre o valor investido.'),
    ('seed_financas_medio_v2', 'O que significa um investimento de alta liquidez?',
     'Alta liquidez significa que o investimento pode ser convertido em dinheiro rapidamente. Não quer dizer prazo infinito, impossibilidade de venda nem prejuízo.'),
    ('seed_financas_medio_v2', 'O que é risco financeiro?',
     'Risco financeiro é a possibilidade de perder dinheiro ou de não alcançar o resultado esperado. Não é ausência de decisões, aumento automático do dinheiro nem garantia de lucro.'),
    ('seed_financas_medio_v2', 'O que é retorno de investimento?',
     'Retorno é o ganho ou resultado obtido depois de aplicar dinheiro. Pode ser positivo ou negativo. Não é conta mensal, valor perdido nem dívida bancária.'),
    ('seed_financas_medio_v2', 'O que é perfil de investidor?',
     'Perfil de investidor são as características da pessoa ligadas à tolerância ao risco, por exemplo se é mais cautelosa ou mais arrojada. Ajuda a escolher investimentos adequados. Não é o nome do banco nem o número de contas.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 17: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
