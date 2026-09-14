-- Seed de conteúdo real: 2 pergunta(s) — Produtividade — Médio (lote 5)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/060_produtividade_medio_5.sql
--
-- DEDUPLICAÇÃO APLICADA: as 2 perguntas do lote são inéditas — nenhuma duplicata encontrada.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (98 — distinta das seeds 42 a 96 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_medio_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_medio_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v5'
    FROM (VALUES
      ('Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?'),
      ('Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_medio_v5 q
    JOIN (VALUES
      ('Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 'Aumentar o número de notificações', FALSE, 0),
      ('Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 'Alternar entre a tarefa e todas as notificações', FALSE, 1),
      ('Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 'Trabalhar sem qualquer objetivo', FALSE, 2),
      ('Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 'Desativar ou limitar notificações durante o período de concentração', TRUE, 3),
      ('Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 'Adiar também as tarefas fáceis', FALSE, 0),
      ('Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 'Remover todas as tarefas do calendário', FALSE, 1),
      ('Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 'Definir antecipadamente quando começará a tarefa difícil e dividir o trabalho em etapas', TRUE, 2),
      ('Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 'Esperar até sentir vontade de começar', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_medio_v5;

    RAISE NOTICE '2 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_medio_v5).';
  END IF;
END $$;

COMMIT;