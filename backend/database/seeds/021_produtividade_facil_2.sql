-- Migration/seed: conteúdo Produtividade, nível Fácil (12 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 12 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (60 — distinta das seeds 42 a
-- 59 já usadas nos seeds anteriores) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_facil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v2'
    FROM (VALUES
      ('O que significa priorizar tarefas?'),
      ('Qual é uma vantagem de criar uma lista de tarefas?'),
      ('Qual estratégia pode ajudar a reduzir distrações?'),
      ('O que significa estabelecer uma meta?'),
      ('Por que dividir uma tarefa grande em etapas pode ajudar?'),
      ('Para que serve um calendário?'),
      ('Qual prática pode ajudar na concentração?'),
      ('Por que revisar objetivos regularmente pode ser útil?'),
      ('O que é uma tarefa recorrente?'),
      ('Qual atitude ajuda a evitar atrasos?'),
      ('O que é planejamento?'),
      ('Qual é uma vantagem de revisar o trabalho antes de entregá-lo?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_facil2 q
    JOIN (VALUES
      ('O que significa priorizar tarefas?', 'Evitar tarefas importantes', FALSE, 0),
      ('O que significa priorizar tarefas?', 'Fazer tudo ao mesmo tempo', FALSE, 1),
      ('O que significa priorizar tarefas?', 'Decidir quais tarefas são mais importantes ou urgentes', TRUE, 2),
      ('O que significa priorizar tarefas?', 'Trabalhar sem planejamento', FALSE, 3),
      ('Qual é uma vantagem de criar uma lista de tarefas?', 'Trabalhar sem descanso', FALSE, 0),
      ('Qual é uma vantagem de criar uma lista de tarefas?', 'Eliminar todas as dificuldades', FALSE, 1),
      ('Qual é uma vantagem de criar uma lista de tarefas?', 'Aumentar automaticamente o salário', FALSE, 2),
      ('Qual é uma vantagem de criar uma lista de tarefas?', 'Organizar atividades e acompanhar o que precisa ser feito', TRUE, 3),
      ('Qual estratégia pode ajudar a reduzir distrações?', 'Desativar notificações desnecessárias durante uma tarefa', TRUE, 0),
      ('Qual estratégia pode ajudar a reduzir distrações?', 'Responder todas as mensagens imediatamente', FALSE, 1),
      ('Qual estratégia pode ajudar a reduzir distrações?', 'Trocar constantemente de atividade', FALSE, 2),
      ('Qual estratégia pode ajudar a reduzir distrações?', 'Abrir várias redes sociais', FALSE, 3),
      ('O que significa estabelecer uma meta?', 'Definir um resultado que se pretende alcançar', TRUE, 0),
      ('O que significa estabelecer uma meta?', 'Trabalhar sem direção', FALSE, 1),
      ('O que significa estabelecer uma meta?', 'Evitar qualquer objetivo', FALSE, 2),
      ('O que significa estabelecer uma meta?', 'Fazer tarefas aleatórias', FALSE, 3),
      ('Por que dividir uma tarefa grande em etapas pode ajudar?', 'Aumenta sempre o tempo', FALSE, 0),
      ('Por que dividir uma tarefa grande em etapas pode ajudar?', 'Torna o trabalho mais gerenciável', TRUE, 1),
      ('Por que dividir uma tarefa grande em etapas pode ajudar?', 'Torna a tarefa impossível', FALSE, 2),
      ('Por que dividir uma tarefa grande em etapas pode ajudar?', 'Elimina a necessidade de execução', FALSE, 3),
      ('Para que serve um calendário?', 'Editar imagens', FALSE, 0),
      ('Para que serve um calendário?', 'Criar senhas', FALSE, 1),
      ('Para que serve um calendário?', 'Guardar dinheiro', FALSE, 2),
      ('Para que serve um calendário?', 'Organizar compromissos e atividades ao longo do tempo', TRUE, 3),
      ('Qual prática pode ajudar na concentração?', 'Manter todas as notificações ativas', FALSE, 0),
      ('Qual prática pode ajudar na concentração?', 'Trabalhar em blocos de atenção com pausas planejadas', TRUE, 1),
      ('Qual prática pode ajudar na concentração?', 'Mudar de tarefa a cada minuto', FALSE, 2),
      ('Qual prática pode ajudar na concentração?', 'Trabalhar sem objetivo', FALSE, 3),
      ('Por que revisar objetivos regularmente pode ser útil?', 'Elimina metas', FALSE, 0),
      ('Por que revisar objetivos regularmente pode ser útil?', 'Impede qualquer mudança', FALSE, 1),
      ('Por que revisar objetivos regularmente pode ser útil?', 'Permite avaliar progresso e fazer ajustes', TRUE, 2),
      ('Por que revisar objetivos regularmente pode ser útil?', 'Garante resultados automaticamente', FALSE, 3),
      ('O que é uma tarefa recorrente?', 'Uma atividade realizada apenas uma vez', FALSE, 0),
      ('O que é uma tarefa recorrente?', 'Uma atividade impossível', FALSE, 1),
      ('O que é uma tarefa recorrente?', 'Uma atividade que precisa ser realizada repetidamente', TRUE, 2),
      ('O que é uma tarefa recorrente?', 'Uma tarefa cancelada', FALSE, 3),
      ('Qual atitude ajuda a evitar atrasos?', 'Não registrar compromissos', FALSE, 0),
      ('Qual atitude ajuda a evitar atrasos?', 'Reservar tempo suficiente para as tarefas', TRUE, 1),
      ('Qual atitude ajuda a evitar atrasos?', 'Começar sempre no último minuto', FALSE, 2),
      ('Qual atitude ajuda a evitar atrasos?', 'Ignorar prazos', FALSE, 3),
      ('O que é planejamento?', 'Adiamento de todas as tarefas', FALSE, 0),
      ('O que é planejamento?', 'Improvisação permanente', FALSE, 1),
      ('O que é planejamento?', 'Trabalho sem direção', FALSE, 2),
      ('O que é planejamento?', 'Definição antecipada de ações para alcançar determinado objetivo', TRUE, 3),
      ('Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 'Pode ajudar a encontrar erros', TRUE, 0),
      ('Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 'Aumenta sempre o custo', FALSE, 1),
      ('Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 'Garante que nunca haverá erros', FALSE, 2),
      ('Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 'Elimina a necessidade de aprender', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_facil2;

    RAISE NOTICE '12 perguntas inseridas com sucesso (source=seed_produtividade_facil_v2).';
  END IF;
END $$;

COMMIT;
