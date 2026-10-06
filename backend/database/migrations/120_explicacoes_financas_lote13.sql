-- Explicações pedagógicas (BE-004) — lote 13 (10 perguntas): fecha Finanças fácil (as 5 que
-- faltavam: seed 094 = 1 e seed 099 = 4) e abre Finanças médio (as 5 primeiras do seed 046,
-- source 'seed_financas_medio_v1'). Mesmo critério das migrations 109 a 119: só preenche
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
    ('seed_financas_facil_v4', 'O que é uma conta poupança?',
     'Conta poupança é uma conta bancária feita para guardar dinheiro e, em geral, render juros com o tempo. Não é imposto, cartão de crédito nem empréstimo. É um lugar para juntar dinheiro para os seus objetivos.'),
    ('seed_financas_facil_v5', 'O que é uma fatura?',
     'Fatura é o documento que detalha o que se deve pagar por um produto ou serviço, com os valores cobrados. Não é investimento, cartão bancário nem taxa de juro. Guardar as faturas ajuda a controlar as despesas.'),
    ('seed_financas_facil_v5', 'O que é câmbio de moeda?',
     'Câmbio é a troca de uma moeda por outra, feita a uma taxa de conversão que muda com o tempo. Não é aumento de salário, imposto nem poupança obrigatória.'),
    ('seed_financas_facil_v5', 'O que é um cheque?',
     'Cheque é um documento que ordena ao banco pagar um valor a partir da conta de quem o emite. Não é cartão de crédito, aplicação financeira nem comprovativo de poupança.'),
    ('seed_financas_facil_v5', 'O que é uma prestação (parcela) de um empréstimo?',
     'Prestação é cada pagamento periódico feito para quitar um empréstimo aos poucos. Não é o valor total do empréstimo nem uma multa por atraso. Pagar em dia evita multas.'),
    ('seed_financas_medio_v1', 'Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?',
     'O que sobra é a renda menos as despesas: 15.000 − 11.500 = 3.500 MZN. Esse é o valor disponível antes de outros gastos, e uma parte dele pode ser poupada.'),
    ('seed_financas_medio_v1', 'Qual é a principal diferença entre poupança e investimento?',
     'A poupança prioriza guardar com segurança e poder usar o dinheiro quando precisar. O investimento busca render mais, mas aceita algum risco. A poupança nem sempre rende mais, e todo investimento tem algum risco.'),
    ('seed_financas_medio_v1', 'O que é liquidez?',
     'Liquidez é a facilidade de transformar um bem em dinheiro rapidamente, sem perder valor. Dinheiro vivo tem liquidez total; uma casa tem pouca. Nada a ver com inflação, dívidas ou impostos.'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?',
     'A reserva de emergência pode ser necessária de repente, para despesas inesperadas, por isso deve ser fácil de acessar. Não serve para luxos nem deve ficar presa em ativos de alto risco.'),
    ('seed_financas_medio_v1', 'Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?',
     'Dez por cento de 20.000 é 2.000 MZN (20.000 × 0,10). Para achar 10% de um valor, basta dividi-lo por 10.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações lote 13 (Finanças fácil final + médio início): % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
