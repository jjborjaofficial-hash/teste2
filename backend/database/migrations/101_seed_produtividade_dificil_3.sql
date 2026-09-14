-- Seed: conteúdo Produtividade, nível Difícil (1 pergunta)
-- Fonte: pergunta ELABORADA POR IA (Claude), a pedido do proprietário do
-- projeto, para completar a categoria/dificuldade que ainda não tinha
-- atingido 100 perguntas (estava em 99, faltava só 1). Não veio de um
-- documento fornecido pelo proprietário — recomenda-se revisão humana
-- antes de considerar definitiva.
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
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_dificil_v3') THEN
    RAISE NOTICE 'Pergunta já foi inserida anteriormente (source=seed_produtividade_dificil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_dificil3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_produtividade_dificil_v3'
    FROM (VALUES
      ('O que é a técnica de time blocking?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_dificil3 q
    JOIN (VALUES
      ('O que é a técnica de time blocking?', 'Impedir qualquer interrupção permanentemente', FALSE, 0),
      ('O que é a técnica de time blocking?', 'Trabalhar sem qualquer planejamento de horário', FALSE, 1),
      ('O que é a técnica de time blocking?', 'Reservar blocos específicos de tempo na agenda para tarefas ou tipos de atividade definidos', TRUE, 2),
      ('O que é a técnica de time blocking?', 'Dividir uma equipa em vários turnos aleatórios', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_dificil3;

    RAISE NOTICE '1 pergunta inserida com sucesso (source=seed_produtividade_dificil_v3).';
  END IF;
END $$;

COMMIT;
