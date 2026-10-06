-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 08 (10 perguntas: 13 a 22 do
-- seed 064, source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 114: só preenche
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
    ('O que é lucro?',
     'Lucro é o resultado positivo: acontece quando as receitas são maiores que as despesas, isto é, entrou mais dinheiro do que saiu. É o oposto do prejuízo. Não é uma despesa nem uma perda.'),
    ('O que é prejuízo?',
     'Prejuízo é o resultado negativo: acontece quando as despesas superam as receitas, ou seja, saiu mais dinheiro do que entrou. É o oposto do lucro e mostra que é preciso rever os gastos.'),
    ('O que é investimento?',
     'Investir é aplicar dinheiro esperando um retorno no futuro. Ao contrário de gastar sem objetivo, o investimento tem um propósito. Todo investimento tem algum risco, por isso vale entender antes de aplicar.'),
    ('O que é salário?',
     'Salário é o pagamento recebido pelo trabalho realizado. Não é empréstimo, imposto nem dívida: é dinheiro que entra pelo seu trabalho e, normalmente, é a base do orçamento.'),
    ('O que é consumo consciente?',
     'Consumo consciente é comprar pensando na necessidade e no que cabe no bolso. Comprar sem planejamento, fazer dívidas ou gastar todo o dinheiro vai no sentido contrário. Antes de comprar, vale perguntar se é preciso e se dá para pagar.'),
    ('O que é planejamento financeiro?',
     'Planejamento financeiro é organizar as decisões sobre o dinheiro: quanto ganhar, gastar, guardar e investir. Evitar controle, gastar sem pensar ou viver de empréstimos é o contrário. Planejar ajuda a chegar aos objetivos com menos sustos.'),
    ('O que é uma meta financeira?',
     'Meta financeira é um objetivo ligado ao uso do dinheiro, como juntar uma quantia ou pagar uma dívida. Um cartão, uma dívida obrigatória ou uma despesa não são metas. Ter uma meta dá direção ao que se guarda e ao que se gasta.'),
    ('O que é emergência financeira?',
     'Emergência financeira é uma situação inesperada que exige dinheiro, como um problema de saúde ou um conserto urgente. Compra planejada, salário mensal e investimento são coisas previstas, por isso não são emergências.'),
    ('O que é reserva de emergência?',
     'Reserva de emergência é o dinheiro guardado para situações inesperadas. Não é dívida nem imposto, e também não é dinheiro para gastar rápido: deve ficar guardado para quando for preciso de verdade.'),
    ('O que é uma necessidade financeira?',
     'Necessidade financeira é algo essencial para a vida ou para o funcionamento de uma pessoa, como alimentação, moradia e saúde. Luxo, gasto sem importância e compra por impulso não são necessidades.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v2'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 08: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
