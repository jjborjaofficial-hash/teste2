-- Explicações pedagógicas (BE-004) — Finanças médio lote 18, perguntas 8 a 17 do seed 065 (10 perguntas). Mesmo critério das migrations 109 a
-- 124: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'Quais são exemplos de perfis de investidores?',
     'Os perfis de investidor mais comuns são conservador, moderado e agressivo, conforme a tolerância ao risco. Pequeno, médio, grande, simples, complexo, nacional ou internacional não são perfis de investidor.'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor conservador?',
     'O investidor conservador prefere segurança, mesmo que isso signifique ter menos chance de retorno. Ele não busca sempre o maior risco, não aceita qualquer risco e não investe sem analisar.'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor agressivo?',
     'O investidor agressivo aceita riscos maiores em busca de retornos maiores. Mesmo assim, analisa as oportunidades: não evita investir nem guarda só dinheiro físico.'),
    ('seed_financas_medio_v2', 'O que é mercado financeiro?',
     'Mercado financeiro é o ambiente onde acontecem operações com dinheiro e investimentos, como compra e venda de ações e títulos. Não é um banco específico, um aplicativo ou só lojas comerciais.'),
    ('seed_financas_medio_v2', 'O que é uma ação?',
     'Ação é uma pequena parte da propriedade de uma empresa. Quem a compra passa a ser sócio dela. Não é empréstimo bancário, despesa nem conta mensal.'),
    ('seed_financas_medio_v2', 'O que significa comprar ações?',
     'Comprar ações é tornar-se parcialmente proprietário de uma empresa, na proporção do que se comprou. Não é pagar imposto, fazer dívida nem comprar dinheiro físico.'),
    ('seed_financas_medio_v2', 'O que é dividendo?',
     'Dividendo é a parte do lucro de uma empresa que é distribuída aos acionistas. Não é dívida, taxa bancária nem imposto.'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?',
     'Ativo financeiro é um recurso que tem valor econômico e pode gerar retorno, como uma ação ou dinheiro aplicado. Despesa, imposto e dívida não são ativos.'),
    ('seed_financas_medio_v2', 'O que é um passivo financeiro?',
     'Passivo financeiro é uma obrigação ou dívida que faz o dinheiro sair. É o contrário do ativo. Investimento, receita e lucro não são passivos.'),
    ('seed_financas_medio_v2', 'O que é fluxo de caixa?',
     'Fluxo de caixa é o controle das entradas e saídas de dinheiro. Mostra se está entrando mais do que sai. Não é um cartão, uma dívida nem apenas o saldo do banco.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 18, perguntas 8 a 17 do seed 065: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
