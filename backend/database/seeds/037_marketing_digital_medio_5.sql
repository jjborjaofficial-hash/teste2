-- Migration/seed: conteúdo Marketing Digital, nível Médio — lote "Fase 1 / Lote 1" (1 de 2 perguntas)
-- Fonte: mini-lote "FASE 1 — LOTE 1" fornecido pelo proprietário do projeto
-- para completar categorias específicas rumo à meta de 100 perguntas por
-- categoria+dificuldade.
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra todo o banco já
-- existente e encontrei 1 repetida(s), removida(s) deste arquivo:
--   - "O que é uma persona no Marketing Digital?"
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (76 — distinta das
-- seeds 42 a 74 já usadas) e distribuição controlada entre A/B/C/D,
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v5'
    FROM (VALUES
      ('Qual é a importância de analisar métricas em uma campanha digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio_v5 q
    JOIN (VALUES
      ('Qual é a importância de analisar métricas em uma campanha digital?', 'Permite avaliar resultados e melhorar estratégias', TRUE, 0),
      ('Qual é a importância de analisar métricas em uma campanha digital?', 'Serve apenas para aumentar seguidores', FALSE, 1),
      ('Qual é a importância de analisar métricas em uma campanha digital?', 'Substitui completamente o planejamento', FALSE, 2),
      ('Qual é a importância de analisar métricas em uma campanha digital?', 'Impede mudanças na campanha', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio_v5;

    RAISE NOTICE '1 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v5).';
  END IF;
END $$;

COMMIT;
