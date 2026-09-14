-- Seed: conteúdo Inteligência Artificial, nível Fácil (2 perguntas)
-- Fonte: perguntas ELABORADAS POR IA (Claude), a pedido do proprietário do
-- projeto, para completar a categoria/dificuldade que ainda não tinha
-- atingido 100 perguntas (estava em 98). Não vieram de um documento
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
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v7') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v7) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_facil7 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v7'
    FROM (VALUES
      ('O que é síntese de voz?'),
      ('O que é um filtro de spam baseado em IA?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_facil7 q
    JOIN (VALUES
      ('O que é síntese de voz?', 'Um tipo de vírus de computador', FALSE, 0),
      ('O que é síntese de voz?', 'Um sistema de armazenamento de áudio', FALSE, 1),
      ('O que é síntese de voz?', 'Um cabo de conexão para microfones', FALSE, 2),
      ('O que é síntese de voz?', 'Tecnologia que converte texto em fala', TRUE, 3),

      ('O que é um filtro de spam baseado em IA?', 'Um antivírus físico', FALSE, 0),
      ('O que é um filtro de spam baseado em IA?', 'Sistema que utiliza padrões aprendidos para identificar e bloquear mensagens indesejadas', TRUE, 1),
      ('O que é um filtro de spam baseado em IA?', 'Um tipo de teclado inteligente', FALSE, 2),
      ('O que é um filtro de spam baseado em IA?', 'Um cabo de rede especial', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_facil7;

    RAISE NOTICE '2 perguntas inseridas com sucesso (source=seed_ia_facil_v7).';
  END IF;
END $$;

COMMIT;
