-- Migration/seed: conteúdo Produtividade, nível Médio (30 perguntas)
-- Fonte: lote de 80 perguntas de Produtividade fornecido pelo proprietário do
-- projeto (perguntas 26–55 do lote, marcadas como "Médio"). Ver
-- 012_produtividade_facil.sql para o contexto completo do lote, incluindo a
-- observação sobre a pergunta 80 (nível Difícil) ainda pendente por documento
-- incompleto.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): respostas corretas originalmente TODAS "A" —
-- posição redistribuída com seed fixa (52 — distinta das seeds 42 a 51 já
-- usadas) e distribuição controlada entre A/B/C/D, reprodutível — conteúdo
-- pedagógico inalterado, só a ORDEM de exibição mudou.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_medio_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_medio AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v1'
    FROM (VALUES
      ('O que é a matriz de Eisenhower?'),
      ('Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:'),
      ('O que é planejamento semanal?'),
      ('Qual é a vantagem de dividir um projeto grande em etapas?'),
      ('O que é uma tarefa prioritária?'),
      ('O que é time blocking?'),
      ('Qual é uma vantagem do time blocking?'),
      ('O que é multitarefa?'),
      ('Por que a multitarefa pode prejudicar algumas atividades cognitivas?'),
      ('O que é batching de tarefas?'),
      ('Qual é um benefício do batching?'),
      ('O que é a técnica Pomodoro?'),
      ('Qual é a finalidade principal das pausas na técnica Pomodoro?'),
      ('O que é delegação?'),
      ('Por que delegar pode aumentar a produtividade?'),
      ('O que é uma interrupção?'),
      ('Por que notificações podem prejudicar o foco?'),
      ('O que significa dizer "não" de forma produtiva?'),
      ('O que é uma revisão semanal?'),
      ('Qual é uma vantagem de revisar tarefas pendentes?'),
      ('O que é planejamento reverso?'),
      ('Por que definir prazos intermediários pode ser útil?'),
      ('O que é custo de alternância de tarefas?'),
      ('O que é ambiente de trabalho favorável à concentração?'),
      ('Qual estratégia pode reduzir distrações digitais?'),
      ('O que é gestão de energia?'),
      ('Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?'),
      ('O que significa estimar o tempo de uma tarefa?'),
      ('Por que registrar o tempo real gasto em tarefas pode ser útil?'),
      ('O que é margem de tempo em um planejamento?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_medio q
    JOIN (VALUES
      ('O que é a matriz de Eisenhower?', 'Método financeiro', FALSE, 0),
      ('O que é a matriz de Eisenhower?', 'Método que classifica tarefas principalmente por urgência e importância', TRUE, 1),
      ('O que é a matriz de Eisenhower?', 'Técnica exclusiva de memorização', FALSE, 2),
      ('O que é a matriz de Eisenhower?', 'Aplicativo de mensagens', FALSE, 3),
      ('Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 'Adiada para o próximo mês', FALSE, 0),
      ('Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 'Delegada sempre', FALSE, 1),
      ('Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 'Tratada prioritariamente', TRUE, 2),
      ('Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 'Ignorada', FALSE, 3),
      ('O que é planejamento semanal?', 'Registro de despesas', FALSE, 0),
      ('O que é planejamento semanal?', 'Lista de tarefas feitas no passado', FALSE, 1),
      ('O que é planejamento semanal?', 'Organização das principais tarefas e compromissos de uma semana', TRUE, 2),
      ('O que é planejamento semanal?', 'Organização exclusiva das férias', FALSE, 3),
      ('Qual é a vantagem de dividir um projeto grande em etapas?', 'Aumenta obrigatoriamente a complexidade', FALSE, 0),
      ('Qual é a vantagem de dividir um projeto grande em etapas?', 'Elimina a necessidade de execução', FALSE, 1),
      ('Qual é a vantagem de dividir um projeto grande em etapas?', 'Torna o progresso mais fácil de acompanhar e administrar', TRUE, 2),
      ('Qual é a vantagem de dividir um projeto grande em etapas?', 'Impede mudanças', FALSE, 3),
      ('O que é uma tarefa prioritária?', 'Sempre a tarefa mais fácil', FALSE, 0),
      ('O que é uma tarefa prioritária?', 'Tarefa que merece atenção antes de outras devido à sua importância ou urgência', TRUE, 1),
      ('O que é uma tarefa prioritária?', 'Qualquer tarefa aleatória', FALSE, 2),
      ('O que é uma tarefa prioritária?', 'Sempre a tarefa mais rápida', FALSE, 3),
      ('O que é time blocking?', 'Sistema de bloqueio de contas', FALSE, 0),
      ('O que é time blocking?', 'Técnica de reservar blocos específicos de tempo para determinadas atividades', TRUE, 1),
      ('O que é time blocking?', 'Método para eliminar calendários', FALSE, 2),
      ('O que é time blocking?', 'Técnica de trabalhar sem horários', FALSE, 3),
      ('Qual é uma vantagem do time blocking?', 'Elimina todas as distrações automaticamente', FALSE, 0),
      ('Qual é uma vantagem do time blocking?', 'Garante que nenhuma tarefa será interrompida', FALSE, 1),
      ('Qual é uma vantagem do time blocking?', 'Ajuda a proteger períodos de foco para tarefas específicas', TRUE, 2),
      ('Qual é uma vantagem do time blocking?', 'Impede qualquer mudança no planejamento', FALSE, 3),
      ('O que é multitarefa?', 'Tentativa de lidar com várias atividades ao mesmo tempo ou alterná-las rapidamente', TRUE, 0),
      ('O que é multitarefa?', 'Planejamento semanal', FALSE, 1),
      ('O que é multitarefa?', 'Realização de uma única atividade', FALSE, 2),
      ('O que é multitarefa?', 'Período de descanso', FALSE, 3),
      ('Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 'Porque sempre aumenta a concentração', FALSE, 0),
      ('Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 'Porque torna qualquer atividade impossível', FALSE, 1),
      ('Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 'A alternância frequente de atenção pode aumentar erros e reduzir eficiência', TRUE, 2),
      ('Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 'Porque elimina a necessidade de foco', FALSE, 3),
      ('O que é batching de tarefas?', 'Agrupar tarefas semelhantes para realizá-las em conjunto', TRUE, 0),
      ('O que é batching de tarefas?', 'Dividir cada tarefa em milhares de partes', FALSE, 1),
      ('O que é batching de tarefas?', 'Fazer todas as tarefas aleatoriamente', FALSE, 2),
      ('O que é batching de tarefas?', 'Cancelar tarefas repetitivas', FALSE, 3),
      ('Qual é um benefício do batching?', 'Garante que nenhuma tarefa terá erros', FALSE, 0),
      ('Qual é um benefício do batching?', 'Elimina todas as pausas', FALSE, 1),
      ('Qual é um benefício do batching?', 'Impede planejamento', FALSE, 2),
      ('Qual é um benefício do batching?', 'Pode reduzir o custo de alternância entre diferentes tipos de atividade', TRUE, 3),
      ('O que é a técnica Pomodoro?', 'Método que alterna períodos de trabalho focado com pausas', TRUE, 0),
      ('O que é a técnica Pomodoro?', 'Técnica de vendas', FALSE, 1),
      ('O que é a técnica Pomodoro?', 'Sistema bancário', FALSE, 2),
      ('O que é a técnica Pomodoro?', 'Aplicativo de edição de vídeo', FALSE, 3),
      ('Qual é a finalidade principal das pausas na técnica Pomodoro?', 'Permitir recuperação da atenção durante ciclos de trabalho', TRUE, 0),
      ('Qual é a finalidade principal das pausas na técnica Pomodoro?', 'Substituir as metas', FALSE, 1),
      ('Qual é a finalidade principal das pausas na técnica Pomodoro?', 'Aumentar as distrações', FALSE, 2),
      ('Qual é a finalidade principal das pausas na técnica Pomodoro?', 'Evitar qualquer trabalho', FALSE, 3),
      ('O que é delegação?', 'Adiar uma tarefa', FALSE, 0),
      ('O que é delegação?', 'Cancelar um projeto', FALSE, 1),
      ('O que é delegação?', 'Fazer todas as tarefas sozinho', FALSE, 2),
      ('O que é delegação?', 'Transferir uma tarefa ou responsabilidade para outra pessoa quando apropriado', TRUE, 3),
      ('Por que delegar pode aumentar a produtividade?', 'Porque garante que todas as tarefas sejam feitas perfeitamente', FALSE, 0),
      ('Por que delegar pode aumentar a produtividade?', 'Porque elimina todo o trabalho', FALSE, 1),
      ('Por que delegar pode aumentar a produtividade?', 'Porque ninguém precisa supervisionar', FALSE, 2),
      ('Por que delegar pode aumentar a produtividade?', 'Pode permitir que cada pessoa se concentre em atividades adequadas às suas responsabilidades e competências', TRUE, 3),
      ('O que é uma interrupção?', 'Evento que quebra o fluxo de atenção durante uma atividade', TRUE, 0),
      ('O que é uma interrupção?', 'Uma tarefa concluída', FALSE, 1),
      ('O que é uma interrupção?', 'Um planejamento', FALSE, 2),
      ('O que é uma interrupção?', 'Uma meta', FALSE, 3),
      ('Por que notificações podem prejudicar o foco?', 'Porque eliminam todas as tarefas', FALSE, 0),
      ('Por que notificações podem prejudicar o foco?', 'Podem interromper a atenção e incentivar mudanças frequentes de atividade', TRUE, 1),
      ('Por que notificações podem prejudicar o foco?', 'Porque melhoram qualquer trabalho', FALSE, 2),
      ('Por que notificações podem prejudicar o foco?', 'Porque aumentam automaticamente a concentração', FALSE, 3),
      ('O que significa dizer "não" de forma produtiva?', 'Evitar toda colaboração', FALSE, 0),
      ('O que significa dizer "não" de forma produtiva?', 'Nunca ajudar ninguém', FALSE, 1),
      ('O que significa dizer "não" de forma produtiva?', 'Recusar qualquer responsabilidade', FALSE, 2),
      ('O que significa dizer "não" de forma produtiva?', 'Recusar atividades que não são adequadas às prioridades quando necessário', TRUE, 3),
      ('O que é uma revisão semanal?', 'Um método de estudo', FALSE, 0),
      ('O que é uma revisão semanal?', 'Período sem trabalho', FALSE, 1),
      ('O que é uma revisão semanal?', 'Momento para analisar o que foi feito, o que ficou pendente e o que precisa ser planejado', TRUE, 2),
      ('O que é uma revisão semanal?', 'Exclusivamente uma reunião financeira', FALSE, 3),
      ('Qual é uma vantagem de revisar tarefas pendentes?', 'Garante que todas sejam fáceis', FALSE, 0),
      ('Qual é uma vantagem de revisar tarefas pendentes?', 'Elimina prazos', FALSE, 1),
      ('Qual é uma vantagem de revisar tarefas pendentes?', 'Impede novas tarefas', FALSE, 2),
      ('Qual é uma vantagem de revisar tarefas pendentes?', 'Permite reorganizar prioridades e evitar que obrigações sejam esquecidas', TRUE, 3),
      ('O que é planejamento reverso?', 'Começar pelo resultado ou prazo final e definir etapas necessárias para chegar até ele', TRUE, 0),
      ('O que é planejamento reverso?', 'Fazer tarefas aleatoriamente', FALSE, 1),
      ('O que é planejamento reverso?', 'Ignorar o prazo final', FALSE, 2),
      ('O que é planejamento reverso?', 'Trabalhar sem objetivo', FALSE, 3),
      ('Por que definir prazos intermediários pode ser útil?', 'Ajuda a acompanhar o progresso antes do prazo final', TRUE, 0),
      ('Por que definir prazos intermediários pode ser útil?', 'Torna todos os projetos menores', FALSE, 1),
      ('Por que definir prazos intermediários pode ser útil?', 'Elimina a necessidade de trabalhar', FALSE, 2),
      ('Por que definir prazos intermediários pode ser útil?', 'Impede ajustes', FALSE, 3),
      ('O que é custo de alternância de tarefas?', 'Custo financeiro obrigatório', FALSE, 0),
      ('O que é custo de alternância de tarefas?', 'Tempo de descanso', FALSE, 1),
      ('O que é custo de alternância de tarefas?', 'Valor de uma ferramenta', FALSE, 2),
      ('O que é custo de alternância de tarefas?', 'Tempo e esforço mental envolvidos ao mudar de uma atividade para outra', TRUE, 3),
      ('O que é ambiente de trabalho favorável à concentração?', 'Ambiente cheio de notificações', FALSE, 0),
      ('O que é ambiente de trabalho favorável à concentração?', 'Ambiente que reduz interrupções e facilita o acesso ao necessário para a tarefa', TRUE, 1),
      ('O que é ambiente de trabalho favorável à concentração?', 'Ambiente sem organização', FALSE, 2),
      ('O que é ambiente de trabalho favorável à concentração?', 'Ambiente com várias distrações', FALSE, 3),
      ('Qual estratégia pode reduzir distrações digitais?', 'Abrir todas as redes sociais', FALSE, 0),
      ('Qual estratégia pode reduzir distrações digitais?', 'Desativar notificações não essenciais durante períodos de foco', TRUE, 1),
      ('Qual estratégia pode reduzir distrações digitais?', 'Ativar todas as notificações', FALSE, 2),
      ('Qual estratégia pode reduzir distrações digitais?', 'Usar vários aplicativos simultaneamente', FALSE, 3),
      ('O que é gestão de energia?', 'Uso de redes sociais', FALSE, 0),
      ('O que é gestão de energia?', 'Organização das atividades considerando períodos de maior e menor disposição', TRUE, 1),
      ('O que é gestão de energia?', 'Apenas controle financeiro', FALSE, 2),
      ('O que é gestão de energia?', 'Gestão da eletricidade de uma casa', FALSE, 3),
      ('Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 'Porque elimina a necessidade de descanso', FALSE, 0),
      ('Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 'Porque tarefas complexas ficam sempre fáceis', FALSE, 1),
      ('Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 'Pode aproveitar melhor os períodos de maior capacidade de atenção', TRUE, 2),
      ('Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 'Porque reduz automaticamente o prazo', FALSE, 3),
      ('O que significa estimar o tempo de uma tarefa?', 'Cancelar a tarefa', FALSE, 0),
      ('O que significa estimar o tempo de uma tarefa?', 'Fazer a tarefa sem planejamento', FALSE, 1),
      ('O que significa estimar o tempo de uma tarefa?', 'Definir seu preço', FALSE, 2),
      ('O que significa estimar o tempo de uma tarefa?', 'Prever aproximadamente quanto tempo será necessário para concluí-la', TRUE, 3),
      ('Por que registrar o tempo real gasto em tarefas pode ser útil?', 'Ajuda a melhorar estimativas futuras', TRUE, 0),
      ('Por que registrar o tempo real gasto em tarefas pode ser útil?', 'Elimina atrasos automaticamente', FALSE, 1),
      ('Por que registrar o tempo real gasto em tarefas pode ser útil?', 'Reduz todas as tarefas', FALSE, 2),
      ('Por que registrar o tempo real gasto em tarefas pode ser útil?', 'Garante produtividade máxima', FALSE, 3),
      ('O que é margem de tempo em um planejamento?', 'Tempo desperdiçado obrigatoriamente', FALSE, 0),
      ('O que é margem de tempo em um planejamento?', 'Tempo adicional reservado para imprevistos ou atrasos', TRUE, 1),
      ('O que é margem de tempo em um planejamento?', 'Tempo sem finalidade', FALSE, 2),
      ('O que é margem de tempo em um planejamento?', 'Tempo usado apenas para redes sociais', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_medio;

    RAISE NOTICE '30 perguntas inseridas com sucesso (source=seed_produtividade_medio_v1).';
  END IF;
END $$;

COMMIT;
