-- Seed de conteúdo real: 7 pergunta(s) — Produtividade — Fácil (lote 5, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/059_produtividade_facil_5.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original tinha 8 perguntas; 1 já existia (texto idêntico) no seed 054 — removida deste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (97 — distinta das seeds 42 a 96 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_facil_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v5'
    FROM (VALUES
      ('O que significa organizar uma tarefa por etapas?'),
      ('Qual é uma boa prática ao iniciar uma atividade importante?'),
      ('Para que serve um cronograma?'),
      ('O que significa concluir uma tarefa dentro do prazo?'),
      ('Por que é útil saber qual tarefa deve ser feita primeiro?'),
      ('O que significa preparar uma tarefa com antecedência?'),
      ('Qual ação pode facilitar o cumprimento de uma meta?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_facil_v5 q
    JOIN (VALUES
      ('O que significa organizar uma tarefa por etapas?', 'Fazer todas as partes ao mesmo tempo', FALSE, 0),
      ('O que significa organizar uma tarefa por etapas?', 'Dividi-la em partes menores e ordenadas', TRUE, 1),
      ('O que significa organizar uma tarefa por etapas?', 'Eliminar a tarefa', FALSE, 2),
      ('O que significa organizar uma tarefa por etapas?', 'Adiar todas as etapas', FALSE, 3),
      ('Qual é uma boa prática ao iniciar uma atividade importante?', 'Abrir várias tarefas diferentes', FALSE, 0),
      ('Qual é uma boa prática ao iniciar uma atividade importante?', 'Evitar qualquer objetivo', FALSE, 1),
      ('Qual é uma boa prática ao iniciar uma atividade importante?', 'Começar sem saber o que fazer', FALSE, 2),
      ('Qual é uma boa prática ao iniciar uma atividade importante?', 'Definir claramente o que precisa ser concluído', TRUE, 3),
      ('Para que serve um cronograma?', 'Para apagar tarefas', FALSE, 0),
      ('Para que serve um cronograma?', 'Para substituir todos os documentos', FALSE, 1),
      ('Para que serve um cronograma?', 'Para organizar atividades de acordo com períodos ou datas', TRUE, 2),
      ('Para que serve um cronograma?', 'Para aumentar as distrações', FALSE, 3),
      ('O que significa concluir uma tarefa dentro do prazo?', 'Começá-la depois da data limite', FALSE, 0),
      ('O que significa concluir uma tarefa dentro do prazo?', 'Cancelá-la antes de começar', FALSE, 1),
      ('O que significa concluir uma tarefa dentro do prazo?', 'Transferi-la para outra pessoa', FALSE, 2),
      ('O que significa concluir uma tarefa dentro do prazo?', 'Realizá-la até a data ou período estabelecido', TRUE, 3),
      ('Por que é útil saber qual tarefa deve ser feita primeiro?', 'Para aumentar o número de tarefas', FALSE, 0),
      ('Por que é útil saber qual tarefa deve ser feita primeiro?', 'Para orientar melhor o uso do tempo e dos recursos', TRUE, 1),
      ('Por que é útil saber qual tarefa deve ser feita primeiro?', 'Para evitar qualquer planejamento', FALSE, 2),
      ('Por que é útil saber qual tarefa deve ser feita primeiro?', 'Para tornar todas as tarefas urgentes', FALSE, 3),
      ('O que significa preparar uma tarefa com antecedência?', 'Realizar parte da preparação antes do momento em que ela será necessária', TRUE, 0),
      ('O que significa preparar uma tarefa com antecedência?', 'Cancelar a tarefa', FALSE, 1),
      ('O que significa preparar uma tarefa com antecedência?', 'Adiar todo o trabalho', FALSE, 2),
      ('O que significa preparar uma tarefa com antecedência?', 'Ignorar os materiais necessários', FALSE, 3),
      ('Qual ação pode facilitar o cumprimento de uma meta?', 'Não acompanhar o progresso', FALSE, 0),
      ('Qual ação pode facilitar o cumprimento de uma meta?', 'Alterar o objetivo diariamente sem motivo', FALSE, 1),
      ('Qual ação pode facilitar o cumprimento de uma meta?', 'Definir ações concretas relacionadas ao objetivo', TRUE, 2),
      ('Qual ação pode facilitar o cumprimento de uma meta?', 'Evitar qualquer prazo', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_facil_v5;

    RAISE NOTICE '7 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_facil_v5).';
  END IF;
END $$;

COMMIT;