-- Seed de conteúdo real: 1 pergunta(s) — Inteligência Artificial — Médio (lote 5)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/063_ia_medio_5.sql
--
-- DEDUPLICAÇÃO APLICADA: a única pergunta do lote é inédita — nenhuma duplicata encontrada.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (101 — distinta das seeds 42 a 98 já usadas) e distribuição
-- controlada entre A/B/C/D, reprodutível — conteúdo pedagógico inalterado, só
-- a ORDEM de exibição mudou.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_medio_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_medio_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_ia_medio_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_ia_medio_v5'
    FROM (VALUES
      ('Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_ia_medio_v5 q
    JOIN (VALUES
      ('Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 'Porque qualquer modelo de IA produz necessariamente resultados aleatórios', FALSE, 0),
      ('Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 'Porque o modelo pode reproduzir ou ampliar padrões injustos presentes nos dados', TRUE, 1),
      ('Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 'Porque os dados não influenciam as decisões do modelo', FALSE, 2),
      ('Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 'Porque eliminar os dados torna o sistema mais preciso', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_ia_medio_v5;

    RAISE NOTICE '1 pergunta(s) inserida(s) com sucesso (source=seed_ia_medio_v5).';
  END IF;
END $$;

COMMIT;