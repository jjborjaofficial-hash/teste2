-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 09 (10 perguntas: 23 a 32 do
-- seed 064, source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 115: só preenche
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
    ('O que é um desejo financeiro?',
     'Desejo financeiro é algo que queremos, mas que não é essencial para viver. Dá prazer ou conforto, mas dá para passar sem ele. Dívida, receita e obrigação de pagamento são outras coisas.'),
    ('Qual é a diferença entre necessidade e desejo?',
     'Necessidade é o que é essencial, como comida, moradia e saúde. Desejo é o que é opcional, como um passeio ou um aparelho novo. Distinguir os dois ajuda a decidir o que pagar primeiro quando o dinheiro é pouco.'),
    ('Como a inflação pode afetar o dinheiro?',
     'Inflação é o aumento geral dos preços. Com ela, o mesmo dinheiro compra menos do que antes, ou seja, o poder de compra diminui. Ela não elimina despesas nem torna os produtos gratuitos.'),
    ('O que é poder de compra?',
     'Poder de compra é a capacidade de adquirir produtos e serviços com determinado valor. Se os preços sobem e o dinheiro continua igual, o poder de compra diminui.'),
    ('O que acontece quando alguém atrasa um pagamento?',
     'Atrasar um pagamento pode gerar juros ou multas, e a dívida cresce. Ela não desaparece nem recebe desconto automático. Pagar no prazo evita esse custo extra.'),
    ('O que é uma despesa fixa?',
     'Despesa fixa é a que acontece regularmente com valor semelhante, como aluguel ou mensalidade. Como se repete e é previsível, deve entrar primeiro no orçamento.'),
    ('Qual exemplo representa uma despesa fixa?',
     'O aluguel mensal é despesa fixa porque se repete todo mês com o mesmo valor. Presente ocasional, viagem aleatória e compra inesperada não têm regularidade, por isso são despesas variáveis.'),
    ('O que é uma despesa variável?',
     'Despesa variável é o gasto que pode mudar de valor conforme o período, como comida, lazer ou transporte ocasional. Por variar, é onde mais se consegue economizar quando se presta atenção.'),
    ('Qual exemplo representa uma despesa variável?',
     'Alimentação e lazer são despesas variáveis, porque o valor muda de um mês para outro. Salário é receita, e mensalidade igual e contrato fixo são exemplos de despesa fixa.'),
    ('O que é saldo bancário?',
     'Saldo bancário é o valor disponível numa conta naquele momento. Não é imposto, dívida nem investimento obrigatório. Consultar o saldo antes de pagar ajuda a não gastar mais do que se tem.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v2'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 09: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
