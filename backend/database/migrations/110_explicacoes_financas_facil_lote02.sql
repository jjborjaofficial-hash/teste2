-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 02 (5 perguntas: 6 a 10 do seed 045).
-- Mesmo critério da migration 109: só preenche questions.explanation das perguntas do seed
-- 'seed_financas_facil_v1' que ainda não têm explicação (idempotente, nunca sobrescreve),
-- não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('O que é consumo?',
     'Consumo é usar bens ou serviços para satisfazer uma necessidade ou um desejo, como comer, apanhar um transporte ou usar a internet. Guardar dinheiro ou investir não é consumo. Perceber o que se consome ajuda a controlar os gastos.'),
    ('Para que serve uma conta bancária?',
     'A conta bancária serve para guardar dinheiro com segurança e movimentá-lo: receber salário, pagar contas, transferir e levantar. É um serviço financeiro completo, não serve só para um tipo de gasto. Ter conta facilita acompanhar o que entra e o que sai.'),
    ('O que é um recibo?',
     'O recibo é o documento que prova que uma compra ou um pagamento foi feito. Guardá-lo ajuda a conferir valores, reclamar se houver um problema e provar que uma dívida foi paga.'),
    ('O que significa economizar?',
     'Economizar é reduzir ou controlar os gastos para não desperdiçar recursos. Não é deixar de viver bem, é gastar com atenção ao que realmente é preciso. O dinheiro economizado pode ser guardado para objetivos futuros.'),
    ('Qual é a melhor atitude antes de fazer uma compra não planejada?',
     'Antes de uma compra não planejada, vale parar e perguntar: tenho dinheiro disponível e preciso mesmo disto? Comprar na hora, por impulso, ou pedir emprestado sem analisar costuma levar a dívidas e arrependimento.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v1'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 02: % pergunta(s) atualizada(s) (esperado: 5).', v_updated;
END $$;
