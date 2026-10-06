-- Explicações pedagógicas (BE-004) — Finanças médio lote 21, perguntas 38 a 47 do seed 065 (10 perguntas). Mesmo critério das migrations 109 a
-- 127: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'O que é imposto?',
     'Imposto é um valor cobrado pelo governo para financiar serviços públicos, como saúde, educação e estradas. Não é uma venda, um salário nem um investimento.'),
    ('seed_financas_medio_v2', 'O que é capital?',
     'Capital são os recursos financeiros usados para iniciar ou desenvolver uma atividade, como um negócio. Não é cartão bancário, dívida nem dinheiro perdido.'),
    ('seed_financas_medio_v2', 'O que é empreendedorismo financeiro?',
     'Empreendedorismo financeiro é criar e gerir negócios buscando gerar valor e renda. Não é só guardar dinheiro, evitar investir ou gastar sem planejamento.'),
    ('seed_financas_medio_v2', 'O que é preço de venda?',
     'Preço de venda é o valor cobrado por um produto ou serviço. Ele deve cobrir os custos e deixar lucro. Não é salário, imposto pago nem apenas o custo de produção.'),
    ('seed_financas_medio_v2', 'O que é custo de produção?',
     'Custo de produção são os gastos necessários para criar um produto ou serviço, como matéria-prima e mão de obra. Receita e lucro final não são custos, e investimento bancário também não.'),
    ('seed_financas_medio_v2', 'O que é ponto de equilíbrio financeiro?',
     'Ponto de equilíbrio é o momento em que as receitas cobrem todos os custos e despesas: nem lucro, nem prejuízo. A partir dele, cada venda a mais gera lucro.'),
    ('seed_financas_medio_v2', 'O que é análise de risco financeiro?',
     'Análise de risco financeiro é avaliar as possibilidades de perda antes de decidir. Ajuda a escolher com mais consciência. Evitar informações, gastar tudo ou ignorar problemas é o contrário.'),
    ('seed_financas_medio_v2', 'O que é carteira de investimentos?',
     'Carteira de investimentos é o conjunto de diferentes investimentos de uma pessoa, como ações e títulos. Não é uma lista de despesas, uma conta bancária nem uma carteira física de documentos.'),
    ('seed_financas_medio_v2', 'O que é um fundo de investimento?',
     'Fundo de investimento reúne o dinheiro de vários investidores, e uma instituição o administra. Assim, cada um participa de uma carteira maior. Não é cartão, dívida pessoal nem salário.'),
    ('seed_financas_medio_v2', 'O que é renda fixa?',
     'Renda fixa é um investimento com regras de remuneração definidas antecipadamente, de modo que se sabe como o dinheiro vai render. Não é compra de produtos, despesa mensal nem investimento sem informação.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 21, perguntas 38 a 47 do seed 065: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
