-- Migration/seed: conteúdo Produtividade, nível Médio — lote 3 (43 de 50 perguntas)
-- Fonte: novo lote de 50 perguntas de Produtividade/Médio fornecido pelo
-- proprietário do projeto. O documento não trazia cabeçalho de dificuldade
-- (diferente dos lotes anteriores) — nível confirmado como Médio diretamente
-- com o proprietário antes da inserção.
--
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra as perguntas já
-- existentes no banco (todas as categorias/dificuldades) e encontrei 7
-- repetidas, removidas deste arquivo:
--   - "O que significa priorizar tarefas?"
--   - "O que é planejamento semanal?"
--   - "O que é multitarefa?"
--   - "Qual é uma vantagem do time blocking?"
--   - "O que é batching de tarefas?"
--   - "O que significa delegar uma tarefa?"
--   - "O que significa dizer "não" de forma produtiva?"
-- Sobraram 43 perguntas novas e únicas.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): este lote já veio com respostas
-- parcialmente variadas (39 A, 10 B, 1 C antes da deduplicação) — diferente
-- dos primeiros lotes, que vinham 100% em "A". Mesmo assim, para manter
-- consistência de distribuição com o resto do banco, a posição da
-- alternativa correta (preservando o texto e a letra corretos do documento
-- original) foi redistribuída por pergunta com seed fixa (90 — sequência
-- das seeds 42 a 89 já usadas) e distribuição controlada (11/11/11/10 entre
-- A/B/C/D). Conteúdo pedagógico inalterado, só a ORDEM de exibição mudou.
--
-- `xp_reward` (10) e `time_limit_seconds` (15): mesmos valores usados em
-- todos os seeds de pergunta do projeto, independente de dificuldade.
--
-- Categoria "Produtividade" já existe desde a migration 021.
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
    RAISE EXCEPTION 'Categoria "Produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v3') THEN
    RAISE NOTICE 'Perguntas de Produtividade (médio, lote 3) já foram inseridas anteriormente — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_produtividade_medio3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v3'
    FROM (VALUES
      ('Qual é uma das principais finalidades da gestão do tempo?'),
      ('Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:'),
      ('Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:'),
      ('Qual é o principal objetivo da técnica Pomodoro?'),
      ('O que caracteriza a procrastinação?'),
      ('Qual estratégia pode ajudar a combater a procrastinação?'),
      ('O que é uma meta SMART?'),
      ('Por que estabelecer prazos realistas melhora a produtividade?'),
      ('Qual é uma vantagem de definir as três principais prioridades do dia?'),
      ('Por que a multitarefa pode reduzir a produtividade?'),
      ('O que é monotarefa?'),
      ('O que são interrupções no trabalho?'),
      ('Qual estratégia reduz interrupções desnecessárias?'),
      ('O que significa trabalhar em blocos de tempo?'),
      ('O que é uma lista de tarefas eficaz?'),
      ('Por que dividir tarefas complexas em subtarefas pode ser útil?'),
      ('Qual atividade é um bom exemplo de batching?'),
      ('O que é custo de troca de contexto?'),
      ('Qual prática ajuda a reduzir o custo de troca de contexto?'),
      ('Quando a delegação é especialmente útil?'),
      ('O que é automação de tarefas?'),
      ('Qual tarefa é uma boa candidata à automação?'),
      ('O que é uma rotina produtiva?'),
      ('Por que rotinas podem melhorar a produtividade?'),
      ('O que é energia mental no contexto da produtividade?'),
      ('Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?'),
      ('O que é fadiga decisória?'),
      ('Qual prática pode reduzir a fadiga decisória?'),
      ('O que é uma revisão diária?'),
      ('Qual é uma finalidade da revisão semanal?'),
      ('O que é backlog de tarefas?'),
      ('Por que um backlog excessivamente grande pode ser prejudicial?'),
      ('Qual é uma consequência de aceitar compromissos em excesso?'),
      ('O que é uma tarefa de alto impacto?'),
      ('Por que estar ocupado não significa necessariamente ser produtivo?'),
      ('O que é a regra dos dois minutos, associada ao método GTD?'),
      ('No método GTD, qual é uma etapa fundamental?'),
      ('O que é um sistema externo de organização?'),
      ('Qual é uma vantagem de utilizar um calendário para compromissos?'),
      ('O que caracteriza uma boa sessão de foco?'),
      ('O que é margem de tempo no planejamento?'),
      ('Por que estimar o tempo das tarefas pode melhorar o planejamento?'),
      ('Qual é uma característica de um sistema de produtividade sustentável?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_produtividade_medio3 q
    JOIN (VALUES
      ('Qual é uma das principais finalidades da gestão do tempo?', 'Evitar qualquer período de descanso', FALSE, 0),
      ('Qual é uma das principais finalidades da gestão do tempo?', 'Fazer várias tarefas simultaneamente', FALSE, 1),
      ('Qual é uma das principais finalidades da gestão do tempo?', 'Preencher todo o dia com tarefas', FALSE, 2),
      ('Qual é uma das principais finalidades da gestão do tempo?', 'Utilizar o tempo de forma alinhada às prioridades e objetivos', TRUE, 3),
      ('Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 'Delegada sempre', FALSE, 0),
      ('Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 'Eliminada', FALSE, 1),
      ('Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 'Feita imediatamente', TRUE, 2),
      ('Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 'Adiada indefinidamente', FALSE, 3),
      ('Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 'Planejadas', TRUE, 0),
      ('Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 'Delegadas obrigatoriamente', FALSE, 1),
      ('Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 'Eliminadas', FALSE, 2),
      ('Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 'Ignoradas', FALSE, 3),
      ('Qual é o principal objetivo da técnica Pomodoro?', 'Eliminar todas as tarefas difíceis', FALSE, 0),
      ('Qual é o principal objetivo da técnica Pomodoro?', 'Organizar o trabalho em períodos de foco e pausas planejadas', TRUE, 1),
      ('Qual é o principal objetivo da técnica Pomodoro?', 'Trabalhar continuamente sem pausas', FALSE, 2),
      ('Qual é o principal objetivo da técnica Pomodoro?', 'Fazer várias tarefas simultaneamente', FALSE, 3),
      ('O que caracteriza a procrastinação?', 'Adiamento desnecessário de tarefas relevantes', TRUE, 0),
      ('O que caracteriza a procrastinação?', 'Planejamento antecipado', FALSE, 1),
      ('O que caracteriza a procrastinação?', 'Organização das prioridades', FALSE, 2),
      ('O que caracteriza a procrastinação?', 'Delegação eficiente', FALSE, 3),
      ('Qual estratégia pode ajudar a combater a procrastinação?', 'Dividir uma tarefa grande em etapas menores', TRUE, 0),
      ('Qual estratégia pode ajudar a combater a procrastinação?', 'Esperar sempre pela motivação perfeita', FALSE, 1),
      ('Qual estratégia pode ajudar a combater a procrastinação?', 'Adiar tarefas difíceis', FALSE, 2),
      ('Qual estratégia pode ajudar a combater a procrastinação?', 'Trabalhar sem planejamento', FALSE, 3),
      ('O que é uma meta SMART?', 'Uma meta necessariamente financeira', FALSE, 0),
      ('O que é uma meta SMART?', 'Uma meta sem prazo', FALSE, 1),
      ('O que é uma meta SMART?', 'Uma meta específica, mensurável, alcançável, relevante e temporalmente definida', TRUE, 2),
      ('O que é uma meta SMART?', 'Uma meta baseada apenas em desejos', FALSE, 3),
      ('Por que estabelecer prazos realistas melhora a produtividade?', 'Porque elimina a necessidade de prioridades', FALSE, 0),
      ('Por que estabelecer prazos realistas melhora a produtividade?', 'Porque permite aceitar qualquer quantidade de tarefas', FALSE, 1),
      ('Por que estabelecer prazos realistas melhora a produtividade?', 'Porque elimina todas as dificuldades', FALSE, 2),
      ('Por que estabelecer prazos realistas melhora a produtividade?', 'Porque ajuda a estruturar o trabalho e controlar o progresso', TRUE, 3),
      ('Qual é uma vantagem de definir as três principais prioridades do dia?', 'Garantir que nenhuma tarefa seja concluída', FALSE, 0),
      ('Qual é uma vantagem de definir as três principais prioridades do dia?', 'Concentrar atenção nas atividades de maior impacto', TRUE, 1),
      ('Qual é uma vantagem de definir as três principais prioridades do dia?', 'Eliminar a necessidade de planejamento', FALSE, 2),
      ('Qual é uma vantagem de definir as três principais prioridades do dia?', 'Aumentar propositalmente a carga de trabalho', FALSE, 3),
      ('Por que a multitarefa pode reduzir a produtividade?', 'Porque a alternância frequente de atenção pode gerar custos cognitivos e perda de foco', TRUE, 0),
      ('Por que a multitarefa pode reduzir a produtividade?', 'Porque impede qualquer comunicação', FALSE, 1),
      ('Por que a multitarefa pode reduzir a produtividade?', 'Porque elimina a necessidade de concentração', FALSE, 2),
      ('Por que a multitarefa pode reduzir a produtividade?', 'Porque reduz automaticamente o número de tarefas', FALSE, 3),
      ('O que é monotarefa?', 'Delegar todas as responsabilidades', FALSE, 0),
      ('O que é monotarefa?', 'Realizar várias tarefas simultaneamente', FALSE, 1),
      ('O que é monotarefa?', 'Adiar todas as tarefas', FALSE, 2),
      ('O que é monotarefa?', 'Executar uma tarefa de cada vez com atenção concentrada', TRUE, 3),
      ('O que são interrupções no trabalho?', 'Técnicas de planejamento', FALSE, 0),
      ('O que são interrupções no trabalho?', 'Períodos de descanso planejados', FALSE, 1),
      ('O que são interrupções no trabalho?', 'Eventos que desviam a atenção da atividade em execução', TRUE, 2),
      ('O que são interrupções no trabalho?', 'Metas mensuráveis', FALSE, 3),
      ('Qual estratégia reduz interrupções desnecessárias?', 'Manter todas as notificações ativadas', FALSE, 0),
      ('Qual estratégia reduz interrupções desnecessárias?', 'Verificar mensagens constantemente', FALSE, 1),
      ('Qual estratégia reduz interrupções desnecessárias?', 'Criar períodos específicos de foco e limitar notificações', TRUE, 2),
      ('Qual estratégia reduz interrupções desnecessárias?', 'Trabalhar sempre com várias abas abertas', FALSE, 3),
      ('O que significa trabalhar em blocos de tempo?', 'Reservar períodos específicos para determinadas atividades', TRUE, 0),
      ('O que significa trabalhar em blocos de tempo?', 'Fazer somente tarefas urgentes', FALSE, 1),
      ('O que significa trabalhar em blocos de tempo?', 'Executar todas as tarefas simultaneamente', FALSE, 2),
      ('O que significa trabalhar em blocos de tempo?', 'Trabalhar sem horários definidos', FALSE, 3),
      ('O que é uma lista de tarefas eficaz?', 'Uma lista organizada que ajuda a visualizar e executar responsabilidades', TRUE, 0),
      ('O que é uma lista de tarefas eficaz?', 'Uma lista com todas as atividades sem qualquer prioridade', FALSE, 1),
      ('O que é uma lista de tarefas eficaz?', 'Uma lista que deve permanecer sempre aberta', FALSE, 2),
      ('O que é uma lista de tarefas eficaz?', 'Uma lista composta apenas por tarefas urgentes', FALSE, 3),
      ('Por que dividir tarefas complexas em subtarefas pode ser útil?', 'Elimina a necessidade de planejamento', FALSE, 0),
      ('Por que dividir tarefas complexas em subtarefas pode ser útil?', 'Impede a conclusão da tarefa principal', FALSE, 1),
      ('Por que dividir tarefas complexas em subtarefas pode ser útil?', 'Aumenta necessariamente o trabalho', FALSE, 2),
      ('Por que dividir tarefas complexas em subtarefas pode ser útil?', 'Torna o objetivo mais claro e facilita o acompanhamento do progresso', TRUE, 3),
      ('Qual atividade é um bom exemplo de batching?', 'Evitar qualquer comunicação', FALSE, 0),
      ('Qual atividade é um bom exemplo de batching?', 'Interromper cada tarefa para verificar o e-mail', FALSE, 1),
      ('Qual atividade é um bom exemplo de batching?', 'Responder mensagens durante todo o dia', FALSE, 2),
      ('Qual atividade é um bom exemplo de batching?', 'Reservar um único período para responder e-mails e mensagens', TRUE, 3),
      ('O que é custo de troca de contexto?', 'Tempo de deslocamento até o trabalho', FALSE, 0),
      ('O que é custo de troca de contexto?', 'Tempo usado para descansar', FALSE, 1),
      ('O que é custo de troca de contexto?', 'Tempo necessário para criar uma senha', FALSE, 2),
      ('O que é custo de troca de contexto?', 'Tempo e esforço mental necessários para mudar de uma atividade ou contexto para outro', TRUE, 3),
      ('Qual prática ajuda a reduzir o custo de troca de contexto?', 'Manter várias notificações ativas', FALSE, 0),
      ('Qual prática ajuda a reduzir o custo de troca de contexto?', 'Começar várias tarefas e terminar poucas', FALSE, 1),
      ('Qual prática ajuda a reduzir o custo de troca de contexto?', 'Agrupar atividades semelhantes', TRUE, 2),
      ('Qual prática ajuda a reduzir o custo de troca de contexto?', 'Alternar constantemente entre tarefas', FALSE, 3),
      ('Quando a delegação é especialmente útil?', 'Quando outra pessoa possui competência ou recursos adequados para executar a tarefa', TRUE, 0),
      ('Quando a delegação é especialmente útil?', 'Quando a tarefa não possui importância', FALSE, 1),
      ('Quando a delegação é especialmente útil?', 'Quando ninguém sabe realizar a tarefa', FALSE, 2),
      ('Quando a delegação é especialmente útil?', 'Quando não existe prazo', FALSE, 3),
      ('O que é automação de tarefas?', 'Aumentar o número de reuniões', FALSE, 0),
      ('O que é automação de tarefas?', 'Utilizar ferramentas ou sistemas para executar automaticamente atividades repetitivas', TRUE, 1),
      ('O que é automação de tarefas?', 'Eliminar qualquer tecnologia', FALSE, 2),
      ('O que é automação de tarefas?', 'Fazer todas as tarefas manualmente', FALSE, 3),
      ('Qual tarefa é uma boa candidata à automação?', 'Uma conversa emocional complexa', FALSE, 0),
      ('Qual tarefa é uma boa candidata à automação?', 'Uma decisão estratégica altamente subjetiva', FALSE, 1),
      ('Qual tarefa é uma boa candidata à automação?', 'Uma negociação imprevisível', FALSE, 2),
      ('Qual tarefa é uma boa candidata à automação?', 'Uma atividade repetitiva baseada em regras claras', TRUE, 3),
      ('O que é uma rotina produtiva?', 'Um período sem objetivos', FALSE, 0),
      ('O que é uma rotina produtiva?', 'Um conjunto estruturado de comportamentos e atividades repetidos de forma planejada', TRUE, 1),
      ('O que é uma rotina produtiva?', 'Uma lista aleatória de tarefas', FALSE, 2),
      ('O que é uma rotina produtiva?', 'Uma agenda sem horários', FALSE, 3),
      ('Por que rotinas podem melhorar a produtividade?', 'Eliminam a necessidade de descanso', FALSE, 0),
      ('Por que rotinas podem melhorar a produtividade?', 'Reduzem a necessidade de decidir constantemente o que fazer em situações recorrentes', TRUE, 1),
      ('Por que rotinas podem melhorar a produtividade?', 'Garantem que todas as tarefas sejam fáceis', FALSE, 2),
      ('Por que rotinas podem melhorar a produtividade?', 'Impedem mudanças de prioridade', FALSE, 3),
      ('O que é energia mental no contexto da produtividade?', 'Quantidade de eletricidade consumida pelo computador', FALSE, 0),
      ('O que é energia mental no contexto da produtividade?', 'Capacidade disponível para manter atenção, raciocinar e tomar decisões', TRUE, 1),
      ('O que é energia mental no contexto da produtividade?', 'Número de tarefas concluídas', FALSE, 2),
      ('O que é energia mental no contexto da produtividade?', 'Velocidade da internet', FALSE, 3),
      ('Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 'Porque a capacidade de concentração pode variar ao longo do dia', TRUE, 0),
      ('Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 'Porque tarefas simples exigem mais concentração', FALSE, 1),
      ('Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 'Porque tarefas difíceis nunca podem ser feitas à tarde', FALSE, 2),
      ('Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 'Porque o cérebro funciona apenas pela manhã', FALSE, 3),
      ('O que é fadiga decisória?', 'Redução da qualidade ou disposição para tomar decisões após muitas decisões acumuladas', TRUE, 0),
      ('O que é fadiga decisória?', 'Excesso de descanso', FALSE, 1),
      ('O que é fadiga decisória?', 'Aumento automático da criatividade', FALSE, 2),
      ('O que é fadiga decisória?', 'Falta de tarefas', FALSE, 3),
      ('Qual prática pode reduzir a fadiga decisória?', 'Aumentar o número de escolhas desnecessárias', FALSE, 0),
      ('Qual prática pode reduzir a fadiga decisória?', 'Mudar constantemente os métodos de trabalho', FALSE, 1),
      ('Qual prática pode reduzir a fadiga decisória?', 'Criar rotinas e padronizar decisões recorrentes', TRUE, 2),
      ('Qual prática pode reduzir a fadiga decisória?', 'Evitar qualquer planejamento', FALSE, 3),
      ('O que é uma revisão diária?', 'Exclusão de todas as tarefas incompletas', FALSE, 0),
      ('O que é uma revisão diária?', 'Planejamento anual', FALSE, 1),
      ('O que é uma revisão diária?', 'Avaliação breve do que foi feito, do que ficou pendente e do que precisa ser ajustado', TRUE, 2),
      ('O que é uma revisão diária?', 'Um período exclusivamente de descanso', FALSE, 3),
      ('Qual é uma finalidade da revisão semanal?', 'Analisar resultados, identificar pendências e planejar a próxima semana', TRUE, 0),
      ('Qual é uma finalidade da revisão semanal?', 'Aumentar automaticamente a carga horária', FALSE, 1),
      ('Qual é uma finalidade da revisão semanal?', 'Trabalhar sem prioridades', FALSE, 2),
      ('Qual é uma finalidade da revisão semanal?', 'Apagar objetivos antigos sem análise', FALSE, 3),
      ('O que é backlog de tarefas?', 'Lista de tarefas já concluídas', FALSE, 0),
      ('O que é backlog de tarefas?', 'Conjunto de tarefas pendentes que aguardam execução ou priorização', TRUE, 1),
      ('O que é backlog de tarefas?', 'Agenda de reuniões realizadas', FALSE, 2),
      ('O que é backlog de tarefas?', 'Arquivo de documentos eliminados', FALSE, 3),
      ('Por que um backlog excessivamente grande pode ser prejudicial?', 'Garante maior produtividade', FALSE, 0),
      ('Por que um backlog excessivamente grande pode ser prejudicial?', 'Pode aumentar a sensação de sobrecarga e dificultar a definição de prioridades', TRUE, 1),
      ('Por que um backlog excessivamente grande pode ser prejudicial?', 'Elimina a necessidade de planejamento', FALSE, 2),
      ('Por que um backlog excessivamente grande pode ser prejudicial?', 'Faz todas as tarefas tornarem-se urgentes', FALSE, 3),
      ('Qual é uma consequência de aceitar compromissos em excesso?', 'Mais tempo disponível', FALSE, 0),
      ('Qual é uma consequência de aceitar compromissos em excesso?', 'Menor necessidade de organização', FALSE, 1),
      ('Qual é uma consequência de aceitar compromissos em excesso?', 'Aumento da sobrecarga e redução da capacidade de cumprir prioridades', TRUE, 2),
      ('Qual é uma consequência de aceitar compromissos em excesso?', 'Aumento garantido da qualidade', FALSE, 3),
      ('O que é uma tarefa de alto impacto?', 'Uma tarefa que precisa ser feita por último', FALSE, 0),
      ('O que é uma tarefa de alto impacto?', 'Uma atividade que pode produzir contribuição significativa para um objetivo importante', TRUE, 1),
      ('O que é uma tarefa de alto impacto?', 'Uma atividade que demora muitas horas', FALSE, 2),
      ('O que é uma tarefa de alto impacto?', 'Necessariamente uma tarefa difícil', FALSE, 3),
      ('Por que estar ocupado não significa necessariamente ser produtivo?', 'Porque tarefas importantes são sempre rápidas', FALSE, 0),
      ('Por que estar ocupado não significa necessariamente ser produtivo?', 'Porque trabalhar nunca é produtivo', FALSE, 1),
      ('Por que estar ocupado não significa necessariamente ser produtivo?', 'Porque produtividade não depende de resultados', FALSE, 2),
      ('Por que estar ocupado não significa necessariamente ser produtivo?', 'Porque produtividade depende do progresso em objetivos relevantes, e não apenas da quantidade de atividade', TRUE, 3),
      ('O que é a regra dos dois minutos, associada ao método GTD?', 'Todas as tarefas devem durar exatamente dois minutos', FALSE, 0),
      ('O que é a regra dos dois minutos, associada ao método GTD?', 'Todo trabalho deve ser interrompido a cada dois minutos', FALSE, 1),
      ('O que é a regra dos dois minutos, associada ao método GTD?', 'Se uma ação puder ser concluída rapidamente, pode ser mais eficiente realizá-la imediatamente', TRUE, 2),
      ('O que é a regra dos dois minutos, associada ao método GTD?', 'Nenhuma tarefa pode ser delegada', FALSE, 3),
      ('No método GTD, qual é uma etapa fundamental?', 'Memorizar todas as tarefas', FALSE, 0),
      ('No método GTD, qual é uma etapa fundamental?', 'Evitar listas externas', FALSE, 1),
      ('No método GTD, qual é uma etapa fundamental?', 'Capturar compromissos e informações que exigem atenção', TRUE, 2),
      ('No método GTD, qual é uma etapa fundamental?', 'Trabalhar sem revisão', FALSE, 3),
      ('O que é um sistema externo de organização?', 'Uma técnica para eliminar tarefas', FALSE, 0),
      ('O que é um sistema externo de organização?', 'Uma ferramenta usada para armazenar e acompanhar informações que não precisam permanecer apenas na memória', TRUE, 1),
      ('O que é um sistema externo de organização?', 'Um método de trabalho sem registros', FALSE, 2),
      ('O que é um sistema externo de organização?', 'Um sistema que substitui o pensamento', FALSE, 3),
      ('Qual é uma vantagem de utilizar um calendário para compromissos?', 'Serve apenas para registrar tarefas concluídas', FALSE, 0),
      ('Qual é uma vantagem de utilizar um calendário para compromissos?', 'Impede alterações de agenda', FALSE, 1),
      ('Qual é uma vantagem de utilizar um calendário para compromissos?', 'Elimina a necessidade de prioridades', FALSE, 2),
      ('Qual é uma vantagem de utilizar um calendário para compromissos?', 'Permite visualizar atividades vinculadas a datas e horários específicos', TRUE, 3),
      ('O que caracteriza uma boa sessão de foco?', 'Várias tarefas simultâneas', FALSE, 0),
      ('O que caracteriza uma boa sessão de foco?', 'Ausência de objetivo', FALSE, 1),
      ('O que caracteriza uma boa sessão de foco?', 'Muitas interrupções', FALSE, 2),
      ('O que caracteriza uma boa sessão de foco?', 'Objetivo definido, ambiente com poucas distrações e período delimitado de concentração', TRUE, 3),
      ('O que é margem de tempo no planejamento?', 'Tempo dedicado apenas às redes sociais', FALSE, 0),
      ('O que é margem de tempo no planejamento?', 'Tempo que nunca deve ser utilizado', FALSE, 1),
      ('O que é margem de tempo no planejamento?', 'Espaço reservado para imprevistos, transições ou tarefas que ultrapassem o tempo estimado', TRUE, 2),
      ('O que é margem de tempo no planejamento?', 'Tempo desperdiçado propositalmente', FALSE, 3),
      ('Por que estimar o tempo das tarefas pode melhorar o planejamento?', 'Ajuda a comparar a carga de trabalho disponível com o tempo realmente necessário', TRUE, 0),
      ('Por que estimar o tempo das tarefas pode melhorar o planejamento?', 'Elimina todos os imprevistos', FALSE, 1),
      ('Por que estimar o tempo das tarefas pode melhorar o planejamento?', 'Garante que nenhuma tarefa sofrerá atrasos', FALSE, 2),
      ('Por que estimar o tempo das tarefas pode melhorar o planejamento?', 'Torna todas as tarefas igualmente importantes', FALSE, 3),
      ('Qual é uma característica de um sistema de produtividade sustentável?', 'Mantém a agenda cheia em todos os momentos', FALSE, 0),
      ('Qual é uma característica de um sistema de produtividade sustentável?', 'Permite alcançar resultados mantendo equilíbrio entre execução, recuperação e capacidade pessoal', TRUE, 1),
      ('Qual é uma característica de um sistema de produtividade sustentável?', 'Prioriza quantidade de tarefas acima da qualidade', FALSE, 2),
      ('Qual é uma característica de um sistema de produtividade sustentável?', 'Exige trabalhar continuamente sem pausas', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_produtividade_medio3;

    RAISE NOTICE '43 perguntas de Produtividade (médio, lote 3) inseridas com sucesso.';
  END IF;
END $$;

COMMIT;
