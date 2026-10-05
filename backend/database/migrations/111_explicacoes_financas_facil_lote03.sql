-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 03 (5 perguntas: 11 a 15 do seed 045).
-- Mesmo critério das migrations 109 e 110: só preenche questions.explanation das perguntas do
-- seed 'seed_financas_facil_v1' que ainda não têm explicação (idempotente, nunca sobrescreve),
-- não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('O que é preço?',
     'Preço é o valor cobrado por um produto ou serviço. É o que se paga para ter aquilo que se quer comprar. Comparar preços antes de comprar ajuda a gastar melhor.'),
    ('O que significa gastar por impulso?',
     'Gastar por impulso é comprar sem planejar nem pensar o suficiente, só porque deu vontade na hora. Costuma gerar gastos desnecessários e arrependimento. Esperar um pouco antes de comprar ajuda a decidir com calma.'),
    ('Qual destes pode ser considerado um gasto com transporte?',
     'Gastos com transporte são os que servem para se deslocar, como a passagem de autocarro, o combustível ou o táxi. Alimento, caderno e livro pertencem a outras categorias de despesa, como alimentação e estudos.'),
    ('O que é dinheiro?',
     'Dinheiro é o meio que usamos para fazer trocas e pagamentos. Em vez de trocar um bem por outro, pagamos com dinheiro e recebemos o que precisamos. Ele pode ser notas, moedas ou saldo em conta e em carteira digital.'),
    ('Qual é uma vantagem de guardar parte da renda?',
     'Guardar parte do que se ganha cria uma reserva para objetivos futuros, como estudar, comprar algo importante ou enfrentar um imprevisto. Mesmo guardando pouco, o hábito constante faz o valor crescer com o tempo.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v1'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 03: % pergunta(s) atualizada(s) (esperado: 5).', v_updated;
END $$;
