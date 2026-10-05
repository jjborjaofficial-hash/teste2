-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lotes 04 e 05 juntos (10 perguntas:
-- 16 a 25 do seed 045). Mesmo critério das migrations 109 a 111: só preenche questions.explanation
-- das perguntas do seed 'seed_financas_facil_v1' que ainda não têm explicação (idempotente, nunca
-- sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('O que é uma compra planejada?',
     'Compra planejada é aquela decidida com antecedência, depois de pensar se é necessária e se há dinheiro para ela. Planejar evita gastos de última hora e dívidas, e ajuda a escolher melhor.'),
    ('O que significa preço promocional?',
     'Preço promocional é um preço reduzido ou uma condição especial oferecida por um tempo. Promoção só vale a pena se for algo de que se precisa: comprar o que não precisa só porque está barato continua sendo gasto.'),
    ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?',
     'Comparar produtos e preços antes de comprar ajuda a encontrar o melhor custo-benefício e a não pagar mais do que o necessário. Comprar tudo na hora ou ignorar o orçamento leva a gastos que poderiam ser evitados.'),
    ('O que é um objetivo financeiro?',
     'Objetivo financeiro é um resultado ligado ao dinheiro que a pessoa quer alcançar, como juntar uma quantia, pagar uma dívida ou montar uma reserva. Ter um objetivo dá direção ao que se ganha e ao que se gasta.'),
    ('Qual é um exemplo de objetivo financeiro?',
     'Juntar dinheiro para comprar um computador é um objetivo financeiro: tem um alvo claro e exige guardar parte da renda. Gastar tudo, aumentar dívidas ou ignorar despesas afastam a pessoa dos seus objetivos.'),
    ('Qual é a principal finalidade de um orçamento pessoal?',
     'O orçamento pessoal serve para controlar receitas e despesas: saber quanto entra, quanto sai e quanto sobra. Não elimina impostos nem aumenta o salário, mas mostra onde é possível gastar melhor.'),
    ('O que significa poupar dinheiro?',
     'Poupar é guardar parte do dinheiro para usar no futuro, em vez de gastar tudo agora. Quem poupa tem recursos para objetivos e imprevistos, e depende menos de empréstimos.'),
    ('Qual destes é um exemplo de despesa fixa?',
     'Despesa fixa é a que se repete em todo período com o mesmo valor, como o aluguel. Lanche eventual, passeio e compra ocasional de roupa são despesas variáveis, porque mudam de um mês para outro.'),
    ('O que caracteriza uma despesa variável?',
     'Despesa variável é a que muda de valor de um período para outro, como lazer, lanches e compras ocasionais. Por variar, é a que mais exige atenção no orçamento, porque é onde mais se consegue reduzir gastos.'),
    ('Para que serve uma reserva de emergência?',
     'A reserva de emergência serve para cobrir despesas inesperadas, como um problema de saúde, um conserto urgente ou a perda de renda. Com ela guardada, a pessoa não precisa pedir dinheiro emprestado quando surge um imprevisto.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v1'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lotes 04 e 05: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
