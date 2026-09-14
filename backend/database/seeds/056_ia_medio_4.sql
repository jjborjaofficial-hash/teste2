-- Seed de conteúdo real: 1 pergunta(s) — Inteligência Artificial — Médio (lote 4, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/056_ia_medio_4.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original enviado tinha mais perguntas; as que
-- já existiam (texto idêntico) em outros seeds foram removidas deste arquivo —
-- ver CHANGELOG para a lista completa do que foi descartado e por quê.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (94 — distinta das seeds 42 a 91 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_medio_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_medio_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_ia_medio_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_ia_medio_v4'
    FROM (VALUES
      ('O que é aprendizado de máquina (Machine Learning)?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_ia_medio_v4 q
    JOIN (VALUES
      ('O que é aprendizado de máquina (Machine Learning)?', 'Um método para montar computadores manualmente', FALSE, 0),
      ('O que é aprendizado de máquina (Machine Learning)?', 'Uma técnica em que sistemas aprendem padrões a partir de dados', TRUE, 1),
      ('O que é aprendizado de máquina (Machine Learning)?', 'Um programa usado apenas para editar vídeos', FALSE, 2),
      ('O que é aprendizado de máquina (Machine Learning)?', 'Uma tecnologia que não utiliza dados', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_ia_medio_v4;

    RAISE NOTICE '1 pergunta(s) inserida(s) com sucesso (source=seed_ia_medio_v4).';
  END IF;
END $$;

COMMIT;