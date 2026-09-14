-- Seed de conteúdo real: 13 pergunta(s) — Produtividade — Fácil (lote 3, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/054_produtividade_facil_3.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original enviado tinha mais perguntas; as que
-- já existiam (texto idêntico) em outros seeds foram removidas deste arquivo —
-- ver CHANGELOG para a lista completa do que foi descartado e por quê.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (92 — distinta das seeds 42 a 91 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_facil_v3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v3'
    FROM (VALUES
      ('Qual é uma boa prática para começar o dia de trabalho?'),
      ('Qual ferramenta pode ajudar a organizar tarefas?'),
      ('Por que é importante estabelecer objetivos?'),
      ('O que pode ajudar a evitar distrações durante o trabalho?'),
      ('O que significa organizar o tempo?'),
      ('Uma agenda serve principalmente para:'),
      ('Por que fazer pausas durante o trabalho pode ser útil?'),
      ('Qual é uma característica de uma meta bem definida?'),
      ('O que ajuda a acompanhar o progresso de um projeto?'),
      ('Qual atitude pode melhorar a concentração?'),
      ('Por que estabelecer prazos pode ajudar na produtividade?'),
      ('O que deve ser feito quando existem muitas tarefas?'),
      ('Qual comportamento pode prejudicar a produtividade?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_facil_v3 q
    JOIN (VALUES
      ('Qual é uma boa prática para começar o dia de trabalho?', 'Começar várias tarefas ao mesmo tempo', FALSE, 0),
      ('Qual é uma boa prática para começar o dia de trabalho?', 'Evitar qualquer planejamento', FALSE, 1),
      ('Qual é uma boa prática para começar o dia de trabalho?', 'Definir as principais prioridades do dia', TRUE, 2),
      ('Qual é uma boa prática para começar o dia de trabalho?', 'Trabalhar sem pausas', FALSE, 3),
      ('Qual ferramenta pode ajudar a organizar tarefas?', 'Calculadora', FALSE, 0),
      ('Qual ferramenta pode ajudar a organizar tarefas?', 'Lista de tarefas', TRUE, 1),
      ('Qual ferramenta pode ajudar a organizar tarefas?', 'Editor de imagens', FALSE, 2),
      ('Qual ferramenta pode ajudar a organizar tarefas?', 'Leitor de música', FALSE, 3),
      ('Por que é importante estabelecer objetivos?', 'Para orientar as ações e medir o progresso', TRUE, 0),
      ('Por que é importante estabelecer objetivos?', 'Para aumentar a confusão', FALSE, 1),
      ('Por que é importante estabelecer objetivos?', 'Para evitar qualquer planejamento', FALSE, 2),
      ('Por que é importante estabelecer objetivos?', 'Para eliminar todas as responsabilidades', FALSE, 3),
      ('O que pode ajudar a evitar distrações durante o trabalho?', 'Manter várias redes sociais abertas', FALSE, 0),
      ('O que pode ajudar a evitar distrações durante o trabalho?', 'Ver vídeos constantemente', FALSE, 1),
      ('O que pode ajudar a evitar distrações durante o trabalho?', 'Trocar de tarefa a cada minuto', FALSE, 2),
      ('O que pode ajudar a evitar distrações durante o trabalho?', 'Desativar notificações desnecessárias', TRUE, 3),
      ('O que significa organizar o tempo?', 'Trabalhar sem horários', FALSE, 0),
      ('O que significa organizar o tempo?', 'Evitar prioridades', FALSE, 1),
      ('O que significa organizar o tempo?', 'Fazer tudo simultaneamente', FALSE, 2),
      ('O que significa organizar o tempo?', 'Usar o tempo de maneira planejada', TRUE, 3),
      ('Uma agenda serve principalmente para:', 'Entreter o usuário', FALSE, 0),
      ('Uma agenda serve principalmente para:', 'Criar imagens', FALSE, 1),
      ('Uma agenda serve principalmente para:', 'Organizar compromissos e tarefas', TRUE, 2),
      ('Uma agenda serve principalmente para:', 'Fazer cálculos complexos', FALSE, 3),
      ('Por que fazer pausas durante o trabalho pode ser útil?', 'Faz perder sempre produtividade', FALSE, 0),
      ('Por que fazer pausas durante o trabalho pode ser útil?', 'Elimina a necessidade de planejamento', FALSE, 1),
      ('Por que fazer pausas durante o trabalho pode ser útil?', 'Impede a conclusão das tarefas', FALSE, 2),
      ('Por que fazer pausas durante o trabalho pode ser útil?', 'Pode ajudar a recuperar a concentração', TRUE, 3),
      ('Qual é uma característica de uma meta bem definida?', 'Ser completamente vaga', FALSE, 0),
      ('Qual é uma característica de uma meta bem definida?', 'Ser clara e específica', TRUE, 1),
      ('Qual é uma característica de uma meta bem definida?', 'Não possuir prazo', FALSE, 2),
      ('Qual é uma característica de uma meta bem definida?', 'Não poder ser medida', FALSE, 3),
      ('O que ajuda a acompanhar o progresso de um projeto?', 'Registrar e verificar o andamento das atividades', TRUE, 0),
      ('O que ajuda a acompanhar o progresso de um projeto?', 'Ignorar as tarefas concluídas', FALSE, 1),
      ('O que ajuda a acompanhar o progresso de um projeto?', 'Evitar qualquer registro', FALSE, 2),
      ('O que ajuda a acompanhar o progresso de um projeto?', 'Mudar constantemente os objetivos', FALSE, 3),
      ('Qual atitude pode melhorar a concentração?', 'Usar várias aplicações simultaneamente', FALSE, 0),
      ('Qual atitude pode melhorar a concentração?', 'Responder a todas as notificações imediatamente', FALSE, 1),
      ('Qual atitude pode melhorar a concentração?', 'Trabalhar em um ambiente organizado', TRUE, 2),
      ('Qual atitude pode melhorar a concentração?', 'Interromper o trabalho constantemente', FALSE, 3),
      ('Por que estabelecer prazos pode ajudar na produtividade?', 'Elimina todas as responsabilidades', FALSE, 0),
      ('Por que estabelecer prazos pode ajudar na produtividade?', 'Impede o planejamento', FALSE, 1),
      ('Por que estabelecer prazos pode ajudar na produtividade?', 'Faz todas as tarefas desaparecerem', FALSE, 2),
      ('Por que estabelecer prazos pode ajudar na produtividade?', 'Ajuda a criar um limite de tempo para concluir atividades', TRUE, 3),
      ('O que deve ser feito quando existem muitas tarefas?', 'Ignorar todas', FALSE, 0),
      ('O que deve ser feito quando existem muitas tarefas?', 'Organizar e definir prioridades', TRUE, 1),
      ('O que deve ser feito quando existem muitas tarefas?', 'Fazer todas simultaneamente', FALSE, 2),
      ('O que deve ser feito quando existem muitas tarefas?', 'Adiar indefinidamente', FALSE, 3),
      ('Qual comportamento pode prejudicar a produtividade?', 'Procrastinar constantemente', TRUE, 0),
      ('Qual comportamento pode prejudicar a produtividade?', 'Planejar as atividades', FALSE, 1),
      ('Qual comportamento pode prejudicar a produtividade?', 'Trabalhar com foco', FALSE, 2),
      ('Qual comportamento pode prejudicar a produtividade?', 'Definir prioridades', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_facil_v3;

    RAISE NOTICE '13 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_facil_v3).';
  END IF;
END $$;

COMMIT;