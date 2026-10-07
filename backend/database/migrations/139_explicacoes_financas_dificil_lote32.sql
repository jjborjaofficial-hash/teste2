-- Explicações pedagógicas (BE-004) — Finanças difícil lote 32, perguntas 20 a 29 do seed 074 (10 perguntas). Mesmo critério das migrations 109 a
-- 138: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v3', 'O que é EBITDA?',
     'EBITDA é o resultado da empresa antes de descontar juros, impostos, depreciação e amortização. Ao tirar esses itens, mostra o desempenho da operação em si, sem a influência de como a empresa se financia, dos impostos ou do desgaste contábil dos ativos. Por isso serve para comparar empresas com estruturas diferentes. Não é taxa de cartão, dívida pessoal nem salário.'),
    ('seed_financas_dificil_v3', 'O que é depreciação?',
     'Depreciação é a perda de valor de um ativo, como uma máquina ou um veículo, por uso, desgaste ou passagem do tempo. Contabilmente, o custo do ativo é distribuído em vários períodos, e isso reduz o lucro contábil sem sair dinheiro no momento, razão pela qual o EBITDA a deixa de fora. Não é receita extra, lucro financeiro nem aumento do valor.'),
    ('seed_financas_dificil_v3', 'O que é amortização contábil?',
     'Amortização contábil é a redução gradual do valor de ativos e direitos ao longo do tempo, normalmente os que não têm forma física, como licenças, patentes e marcas. É parente da depreciação, que faz o mesmo com bens físicos. Em ambas, o custo é espalhado pelos períodos em que o ativo traz benefício. Não é criação de ativos, venda de produtos nem aumento de impostos.'),
    ('seed_financas_dificil_v3', 'O que é capital próprio?',
     'Capital próprio são os recursos que pertencem aos proprietários da empresa, como o dinheiro que investiram e os lucros que ficaram retidos. Diferente do capital de terceiros, não precisa de ser devolvido nem paga juros, mas os donos assumem o risco do negócio. Não é dinheiro emprestado pelo banco, imposto pago nem dívida de clientes.'),
    ('seed_financas_dificil_v3', 'O que é capital de terceiros?',
     'Capital de terceiros são os recursos que a empresa obtém de outros, por empréstimos ou financiamentos, e que terá de devolver, em geral com juros. Pode acelerar o crescimento, mas aumenta o risco: as parcelas têm de ser pagas mesmo quando as vendas caem. Não é dinheiro pessoal guardado, lucro distribuído nem receita de vendas.'),
    ('seed_financas_dificil_v3', 'O que é análise de viabilidade financeira?',
     'Análise de viabilidade financeira é a avaliação feita antes de investir, para saber se um projeto tem condições de gerar resultados positivos: estimam-se os custos, as receitas e o retorno esperado e compara-se com o risco. Ajuda a evitar investimentos que dão prejuízo. Não é criar despesas, controlar funcionários nem fazer publicidade.'),
    ('seed_financas_dificil_v3', 'O que é orçamento de capital?',
     'Orçamento de capital é o planejamento dos investimentos de longo prazo da organização, como comprar máquinas, abrir uma filial ou lançar um produto. Como são decisões grandes e difíceis de desfazer, escolhe-se onde aplicar o dinheiro depois de analisar o retorno de cada opção. Não é lista de clientes, controle de salários nem plano de vendas.'),
    ('seed_financas_dificil_v3', 'O que é custo fixo?',
     'Custo fixo é o que a empresa paga mais ou menos o mesmo valor todos os meses, independentemente de produzir ou vender mais ou menos, como a renda do local ou o salário da equipa fixa. Por isso pesa mais quando as vendas caem: o custo continua, e o lucro desaparece primeiro. Não é custo que muda sempre, receita extra nem lucro líquido.'),
    ('seed_financas_dificil_v3', 'O que é custo variável?',
     'Custo variável é o que muda conforme a produção ou as vendas: se a empresa produz mais, gasta mais com matéria-prima, embalagem ou comissões, e se produz menos, gasta menos. Junto com o custo fixo, ajuda a calcular o preço mínimo e o ponto em que a empresa começa a lucrar. Não é investimento financeiro, custo sempre igual nem receita garantida.'),
    ('seed_financas_dificil_v3', 'O que é eficiência financeira?',
     'Eficiência financeira é a capacidade de alcançar os objetivos usando os recursos de forma adequada, ou seja, obter bons resultados sem desperdício de dinheiro, tempo ou materiais. Uma empresa eficiente consegue o mesmo resultado gastando menos, ou um resultado maior com os mesmos recursos. Não é gastar mais, evitar planejamento nem aumentar dívidas.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 32, perguntas 20 a 29 do seed 074: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
