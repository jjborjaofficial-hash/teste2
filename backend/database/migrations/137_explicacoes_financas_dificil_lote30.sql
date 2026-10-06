-- Explicações pedagógicas (BE-004) — Finanças difícil, lote 30 (10 perguntas): fecha o seed 073
-- (a última, source 'seed_financas_dificil_v2') e abre o seed 074 (as 9 primeiras, source
-- 'seed_financas_dificil_v3'). Mesmo critério das migrations 109 a 136: só preenche
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
    ('seed_financas_dificil_v2', 'O que é solvência empresarial?',
     'Solvência empresarial é a capacidade de uma empresa cumprir as suas obrigações financeiras no longo prazo, ou seja, os bens e recursos cobrem as dívidas. Complementa a liquidez, que olha para o curto prazo. Não é só vender mais, nem número de clientes ou de anúncios.'),
    ('seed_financas_dificil_v3', 'O que é análise de crédito?',
     'Análise de crédito é o processo de avaliar a capacidade de pagamento de uma pessoa ou empresa antes de emprestar. Quem empresta usa esse resultado para decidir se concede o crédito, o limite e os juros: quanto maior o risco, mais caro tende a ser. Não é venda de produtos financeiros, criação de dinheiro nem redução automática de juros.'),
    ('seed_financas_dificil_v3', 'O que é política monetária?',
     'Política monetária é o conjunto de medidas que o banco central usa para controlar a moeda e a inflação, por exemplo, mexendo nos juros e na quantidade de dinheiro em circulação. Atua sobre toda a economia, ao contrário da política fiscal, que usa receitas e gastos públicos. Não é estratégia de vendas, controle de salários nem planejamento pessoal.'),
    ('seed_financas_dificil_v3', 'Qual é uma ferramenta de política monetária?',
     'A alteração das taxas de juros é uma das principais ferramentas da política monetária. Juros mais altos encarecem o crédito e tendem a esfriar a procura e a inflação; juros mais baixos têm o efeito contrário. Criar anúncios, vender produtos ou reduzir funcionários não são ferramentas de política monetária.'),
    ('seed_financas_dificil_v3', 'O que é política fiscal?',
     'Política fiscal é o uso das receitas e dos gastos públicos, ou seja, impostos e despesas do governo, para influenciar a economia. Difere da política monetária, que é conduzida pelo banco central com juros e moeda. Não é controle de investimentos pessoais, gestão de cartões nem estratégia de marketing.'),
    ('seed_financas_dificil_v3', 'O que é taxa básica de juros?',
     'Taxa básica de juros é a taxa de referência usada para influenciar as outras taxas da economia, como as dos empréstimos e das aplicações. Quando o banco central a altera, os juros cobrados ao público tendem a acompanhar. Não é salário mínimo, valor de uma ação nem preço de um produto.'),
    ('seed_financas_dificil_v3', 'O que é câmbio?',
     'Câmbio é a relação de troca entre diferentes moedas, isto é, quanto de uma moeda é preciso para obter outra. A taxa muda com a oferta e a procura e influencia o preço de importações e exportações. Não é sistema de impostos, tipo de investimento nem valor de um imóvel.'),
    ('seed_financas_dificil_v3', 'O que é risco cambial?',
     'Risco cambial é a possibilidade de perdas devido à variação das taxas de câmbio. Atinge quem tem dívidas, receitas ou investimentos em outra moeda: se a moeda estrangeira sobe, a dívida em dólares, por exemplo, fica mais cara. Não é redução de despesas, garantia de lucro internacional nem aumento de salário.'),
    ('seed_financas_dificil_v3', 'O que é mercado de capitais?',
     'Mercado de capitais é onde empresas captam recursos de investidores por meio de valores mobiliários, como ações e títulos de dívida. Serve para financiar o crescimento das empresas no médio e longo prazo. Não é sistema de pagamentos digitais, mercado de alimentos nem mercado de trabalho.'),
    ('seed_financas_dificil_v3', 'O que são títulos de dívida?',
     'Títulos de dívida são instrumentos usados para captar recursos por meio de empréstimos: quem os compra empresta dinheiro ao emissor, que se compromete a devolver com juros. Ao contrário das ações, não dão propriedade da empresa. Não são contas pessoais, cartões bancários nem produtos sem valor.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 30: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
