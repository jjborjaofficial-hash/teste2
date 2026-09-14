-- Seed: conteúdo Finanças, nível Médio (5 perguntas)
-- Fonte: perguntas ELABORADAS POR IA (Claude), a pedido do proprietário do
-- projeto, para completar a categoria/dificuldade que ainda não tinha
-- atingido 100 perguntas (estava em 95). Não vieram de um documento
-- fornecido pelo proprietário — recomenda-se revisão humana antes de
-- considerar definitivas.
--
-- Confirmado por comparação de texto normalizado contra as 1.646 perguntas
-- já existentes no banco: nenhuma duplicata.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_medio_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_medio_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_medio4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_financas_medio_v4'
    FROM (VALUES
      ('Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?'),
      ('Por que manter um bom histórico de pagamentos pode ser importante?'),
      ('O que é amortização de uma dívida?'),
      ('Qual é a diferença entre taxa de juro fixa e taxa de juro variável?'),
      ('O que é o limite de crédito de um cartão?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_medio4 q
    JOIN (VALUES
      ('Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?', '2.500 MZN', FALSE, 0),
      ('Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?', '3.500 MZN', FALSE, 1),
      ('Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?', '3.000 MZN', TRUE, 2),
      ('Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?', '6.000 MZN', FALSE, 3),

      ('Por que manter um bom histórico de pagamentos pode ser importante?', 'Elimina automaticamente todas as dívidas', FALSE, 0),
      ('Por que manter um bom histórico de pagamentos pode ser importante?', 'Garante isenção de impostos', FALSE, 1),
      ('Por que manter um bom histórico de pagamentos pode ser importante?', 'Pode facilitar a obtenção de crédito em condições melhores no futuro', TRUE, 2),
      ('Por que manter um bom histórico de pagamentos pode ser importante?', 'Aumenta o salário automaticamente', FALSE, 3),

      ('O que é amortização de uma dívida?', 'Processo de reduzir gradualmente o valor de uma dívida através de pagamentos', TRUE, 0),
      ('O que é amortização de uma dívida?', 'Aumento do valor total devido', FALSE, 1),
      ('O que é amortização de uma dívida?', 'Cancelamento automático da dívida', FALSE, 2),
      ('O que é amortização de uma dívida?', 'Um tipo de imposto sobre empréstimos', FALSE, 3),

      ('Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 'A fixa muda todos os meses; a variável nunca muda', FALSE, 0),
      ('Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 'Não existe diferença real entre elas', FALSE, 1),
      ('Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 'A variável é sempre menor que a fixa', FALSE, 2),
      ('Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 'A fixa permanece igual durante o contrato; a variável pode mudar conforme condições de mercado', TRUE, 3),

      ('O que é o limite de crédito de um cartão?', 'O valor mínimo obrigatório de compra', FALSE, 0),
      ('O que é o limite de crédito de um cartão?', 'O valor máximo que pode ser utilizado através do cartão', TRUE, 1),
      ('O que é o limite de crédito de um cartão?', 'A taxa de juro cobrada mensalmente', FALSE, 2),
      ('O que é o limite de crédito de um cartão?', 'O prazo de validade do cartão', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_medio4;

    RAISE NOTICE '5 perguntas inseridas com sucesso (source=seed_financas_medio_v4).';
  END IF;
END $$;

COMMIT;
