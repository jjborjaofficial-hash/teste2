-- Seed de conteúdo real: 1 pergunta(s) — Produtividade — Fácil (lote 6)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/061_produtividade_facil_6.sql
--
-- DEDUPLICAÇÃO APLICADA: a única pergunta do lote é inédita — nenhuma duplicata encontrada.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (99 — distinta das seeds 42 a 98 já usadas) e distribuição
-- controlada entre A/B/C/D, reprodutível — conteúdo pedagógico inalterado, só
-- a ORDEM de exibição mudou.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v6') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v6) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_facil_v6 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v6'
    FROM (VALUES
      ('O que significa dizer que uma tarefa foi concluída?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_facil_v6 q
    JOIN (VALUES
      ('O que significa dizer que uma tarefa foi concluída?', 'Que ela foi iniciada, mas deixada pela metade', FALSE, 0),
      ('O que significa dizer que uma tarefa foi concluída?', 'Que ela foi transferida para outra pessoa', FALSE, 1),
      ('O que significa dizer que uma tarefa foi concluída?', 'Que ela foi adicionada à lista de tarefas', FALSE, 2),
      ('O que significa dizer que uma tarefa foi concluída?', 'Que o resultado necessário foi realizado', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_facil_v6;

    RAISE NOTICE '1 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_facil_v6).';
  END IF;
END $$;

COMMIT;