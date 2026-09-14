-- Migration/seed: conteúdo Produtividade, nível Médio (5 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 5 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (61 — distinta das seeds 42 a
-- 60 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Produtividade" (slug: produtividade) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_medio_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_medio2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v2'
    FROM (VALUES
      ('O que significa delegar uma tarefa?'),
      ('Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?'),
      ('O que é uma deadline?'),
      ('O que significa automatizar uma tarefa?'),
      ('Por que estabelecer prioridades pode melhorar o uso do tempo?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_medio2 q
    JOIN (VALUES
      ('O que significa delegar uma tarefa?', 'Atribuí-la a outra pessoa adequada para executá-la', TRUE, 0),
      ('O que significa delegar uma tarefa?', 'Ignorá-la', FALSE, 1),
      ('O que significa delegar uma tarefa?', 'Fazer duas vezes', FALSE, 2),
      ('O que significa delegar uma tarefa?', 'Apagá-la', FALSE, 3),
      ('Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 'Pode aumentar distrações e reduzir eficiência', TRUE, 0),
      ('Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 'Sempre reduz o tempo', FALSE, 1),
      ('Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 'Garante maior qualidade', FALSE, 2),
      ('Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 'Elimina erros', FALSE, 3),
      ('O que é uma deadline?', 'Horário de almoço', FALSE, 0),
      ('O que é uma deadline?', 'Início de uma tarefa', FALSE, 1),
      ('O que é uma deadline?', 'Prazo limite para concluir uma atividade', TRUE, 2),
      ('O que é uma deadline?', 'Data de pagamento exclusivamente', FALSE, 3),
      ('O que significa automatizar uma tarefa?', 'Transferir a tarefa sem autorização', FALSE, 0),
      ('O que significa automatizar uma tarefa?', 'Utilizar ferramentas ou sistemas para executar automaticamente uma atividade', TRUE, 1),
      ('O que significa automatizar uma tarefa?', 'Fazer tudo manualmente', FALSE, 2),
      ('O que significa automatizar uma tarefa?', 'Apagar a tarefa', FALSE, 3),
      ('Por que estabelecer prioridades pode melhorar o uso do tempo?', 'Faz o dia ficar maior', FALSE, 0),
      ('Por que estabelecer prioridades pode melhorar o uso do tempo?', 'Garante sucesso imediato', FALSE, 1),
      ('Por que estabelecer prioridades pode melhorar o uso do tempo?', 'Elimina todas as tarefas', FALSE, 2),
      ('Por que estabelecer prioridades pode melhorar o uso do tempo?', 'Ajuda a concentrar recursos nas atividades mais relevantes', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_medio2;

    RAISE NOTICE '5 perguntas inseridas com sucesso (source=seed_produtividade_medio_v2).';
  END IF;
END $$;

COMMIT;
