-- Migration/seed: conteúdo Marketing Digital, nível Fácil — fechamento (2 perguntas)
-- Fonte: mini-lote "FECHAMENTO DE CATEGORIA — MARKETING DIGITAL" fornecido
-- pelo proprietário do projeto, com o objetivo explícito de completar
-- Marketing Digital Fácil para 100 perguntas (98 + 2 = 100).
--
-- Verificado: nenhuma das 2 perguntas colide (mesmo enunciado) com as 1001
-- perguntas já existentes no banco.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (80 — distinta das
-- seeds 42 a 79 já usadas) e distribuição controlada entre A/B/C/D,
-- reprodutível — conteúdo pedagógico inalterado, só a ORDEM de exibição
-- mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v6') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v6) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil_v6 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v6'
    FROM (VALUES
      ('O que é alcance em uma rede social?'),
      ('O que é uma campanha de Marketing Digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil_v6 q
    JOIN (VALUES
      ('O que é alcance em uma rede social?', 'Número de pessoas que visualizaram determinado conteúdo', TRUE, 0),
      ('O que é alcance em uma rede social?', 'Quantidade de dinheiro investido', FALSE, 1),
      ('O que é alcance em uma rede social?', 'Quantidade de produtos vendidos', FALSE, 2),
      ('O que é alcance em uma rede social?', 'Número de funcionários de uma empresa', FALSE, 3),
      ('O que é uma campanha de Marketing Digital?', 'Apenas uma publicação aleatória', FALSE, 0),
      ('O que é uma campanha de Marketing Digital?', 'Conjunto de ações planejadas para alcançar um objetivo de marketing na internet', TRUE, 1),
      ('O que é uma campanha de Marketing Digital?', 'Uma conta bancária', FALSE, 2),
      ('O que é uma campanha de Marketing Digital?', 'Um programa de computador', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil_v6;

    RAISE NOTICE '2 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v6).';
  END IF;
END $$;

COMMIT;
