-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 06 (10 perguntas): as 8 que
-- faltavam do seed 045 (perguntas 26 a 33, source 'seed_financas_facil_v1') e as 2 primeiras do
-- seed 064 (source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 112: só preenche
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
    ('seed_financas_facil_v1', 'O que acontece quando uma pessoa gasta continuamente mais do que recebe?',
     'Quando se gasta sempre mais do que se recebe, o dinheiro não chega e a pessoa passa a recorrer a empréstimos, acumulando dívidas. Quanto mais tempo isso dura, mais difícil é voltar ao equilíbrio. O caminho é ajustar os gastos à receita.'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de comparar preços antes de comprar?',
     'Comparar preços ajuda a encontrar o melhor custo-benefício, isto é, a opção que dá o que se precisa por um preço justo. Não torna o produto gratuito nem elimina riscos, mas ajuda a gastar melhor.'),
    ('seed_financas_facil_v1', 'O que é uma dívida?',
     'Dívida é o dinheiro que uma pessoa ou entidade deve a outra e precisa devolver, muitas vezes com juros. Não é um investimento garantido nem dinheiro que se possa deixar de pagar.'),
    ('seed_financas_facil_v1', 'Qual comportamento pode ajudar no controle financeiro?',
     'Registrar o que entra e o que sai mostra para onde o dinheiro está indo. Com esse controle fica mais fácil cortar excessos, planejar compras e evitar surpresas no fim do mês.'),
    ('seed_financas_facil_v1', 'O que é renda?',
     'Renda é o dinheiro que uma pessoa ou entidade recebe, como salário, ganhos de um negócio ou outros pagamentos. É a base do orçamento: o que se gasta e o que se guarda dependem dela.'),
    ('seed_financas_facil_v1', 'Qual atitude representa consumo consciente?',
     'Consumo consciente é pensar antes de comprar: preciso mesmo disto? o preço é justo? a qualidade compensa? Comprar tudo em promoção ou sempre o mais caro não é consciente, porque não olha para a necessidade real.'),
    ('seed_financas_facil_v1', 'Qual é uma boa razão para estabelecer metas financeiras?',
     'Metas financeiras dão direção ao dinheiro: mostram para onde ele deve ir e quanto é preciso guardar. Sem metas é fácil gastar sem perceber; com elas, o dinheiro trabalha a favor dos seus planos.'),
    ('seed_financas_facil_v1', 'Qual destas práticas pode melhorar a saúde financeira?',
     'Planejar os gastos antes de receber o dinheiro mostra, desde o início, quanto vai para as contas, quanto para os desejos e quanto para guardar. Ignorar dívidas, pedir empréstimos sem necessidade ou gastar sem calcular piora a saúde financeira.'),
    ('seed_financas_facil_v2', 'O que são finanças?',
     'Finanças é a gestão do dinheiro e dos recursos: ganhar, gastar, guardar e investir de forma organizada. Entender finanças ajuda a tomar melhores decisões no dia a dia, em casa ou num negócio.'),
    ('seed_financas_facil_v2', 'O que é uma receita financeira?',
     'Receita financeira é o valor que uma pessoa ou empresa recebe: o dinheiro que entra, não o que sai. Conhecer a receita é o ponto de partida para planejar quanto se pode gastar e quanto guardar.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 06: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
