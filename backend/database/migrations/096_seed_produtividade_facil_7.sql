-- Seed de conteúdo real: 48 perguntas — Produtividade — Fácil (lote 7)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/066_produtividade_facil_7.sql
--
-- ORIGEM: lote de 63 perguntas de Produtividade Fácil recebido em outra
-- ramificação do projeto (rodada de consolidação), com o `source` original
-- 'seed_produtividade_facil_v3' — que já colide com o v3 desta árvore (arquivo
-- 054, conteúdo diferente). Renomeado para v7 (próxima versão livre).
--
-- DEDUPLICAÇÃO: das 63 perguntas originais do lote, 9 já tinham sido
-- descartadas pela ramificação de origem (contra os seeds 012/021). Ao
-- conferir as 54 restantes contra TODO o banco desta árvore (1.566
-- perguntas, incluindo lotes que a ramificação de origem nunca viu — 054,
-- 057, 059, 061), mais 6 já existiam aqui. Restam as 48 desta seed.
--
-- CORREÇÃO DE QUALIDADE: NÃO foi aplicada uma nova redistribuição de posição
-- aqui — a ramificação de origem já tinha corrigido o viés original ("sempre
-- A" em 40 das 54) com a própria seed de embaralhamento dela (65). A ordem
-- das alternativas abaixo é herdada exatamente como recebida, já balanceada
-- (checado: distribuição 8/17/14/9 entre A/B/C/D nas 48 sobreviventes).

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v7') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v7) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_facil_v7 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v7'
    FROM (VALUES
      ('Qual é uma boa prática para organizar as tarefas do dia?'),
      ('O que significa estabelecer uma prioridade?'),
      ('Qual ferramenta pode ajudar a controlar as tarefas?'),
      ('Por que é útil definir objetivos?'),
      ('Qual destas atividades geralmente prejudica a concentração?'),
      ('Para que serve uma agenda?'),
      ('O que pode ajudar a manter o foco?'),
      ('Qual é a função de um calendário?'),
      ('Qual comportamento contribui para uma boa organização?'),
      ('Por que dividir uma tarefa grande em partes menores pode ser útil?'),
      ('O que significa administrar o tempo?'),
      ('Qual destas opções é uma distração digital comum?'),
      ('Qual é uma vantagem de preparar as atividades do dia seguinte?'),
      ('Qual hábito pode melhorar a produtividade?'),
      ('O que significa estar concentrado?'),
      ('Qual recurso pode ser usado para lembrar compromissos?'),
      ('Qual é uma vantagem de manter o espaço de trabalho organizado?'),
      ('Qual é uma boa forma de lidar com várias tarefas?'),
      ('O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?'),
      ('Para que serve um lembrete?'),
      ('Qual atitude ajuda a começar uma tarefa difícil?'),
      ('Qual destas ferramentas é útil para controlar horários?'),
      ('Qual é uma vantagem de estabelecer horários?'),
      ('O que é um objetivo?'),
      ('Qual destas ações ajuda a reduzir distrações?'),
      ('Por que é importante fazer uma lista de tarefas?'),
      ('O que é uma prioridade?'),
      ('Qual hábito pode ajudar na pontualidade?'),
      ('Qual destas atitudes demonstra boa gestão do tempo?'),
      ('O que significa organizar uma tarefa?'),
      ('Qual é uma consequência possível de não organizar compromissos?'),
      ('O que pode ajudar a controlar o tempo gasto numa atividade?'),
      ('O que significa manter consistência?'),
      ('Qual atitude pode melhorar a utilização do tempo?'),
      ('Por que o descanso é importante?'),
      ('Qual destas opções ajuda a lembrar tarefas futuras?'),
      ('O que significa preparar uma tarefa?'),
      ('Qual é uma vantagem de definir uma hora para começar uma tarefa?'),
      ('O que é uma meta diária?'),
      ('Qual ação ajuda a acompanhar o progresso?'),
      ('O que pode ajudar uma pessoa a manter uma rotina?'),
      ('Qual é uma maneira simples de evitar esquecer compromissos?'),
      ('Qual atitude pode facilitar o início do trabalho?'),
      ('O que é uma lista de prioridades?'),
      ('Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?'),
      ('Por que é útil definir um prazo para uma atividade?'),
      ('Qual é uma boa prática ao terminar o dia?'),
      ('Qual atitude contribui para uma melhor gestão das tarefas?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_facil_v7 q
    JOIN (VALUES
      ('Qual é uma boa prática para organizar as tarefas do dia?', 'Fazer tudo ao mesmo tempo', FALSE, 0),
      ('Qual é uma boa prática para organizar as tarefas do dia?', 'Trabalhar somente nas tarefas mais fáceis', FALSE, 1),
      ('Qual é uma boa prática para organizar as tarefas do dia?', 'Definir prioridades', TRUE, 2),
      ('Qual é uma boa prática para organizar as tarefas do dia?', 'Evitar qualquer planejamento', FALSE, 3),
      ('O que significa estabelecer uma prioridade?', 'Adiar todas as tarefas', FALSE, 0),
      ('O que significa estabelecer uma prioridade?', 'Escolher uma tarefa aleatoriamente', FALSE, 1),
      ('O que significa estabelecer uma prioridade?', 'Eliminar todas as atividades', FALSE, 2),
      ('O que significa estabelecer uma prioridade?', 'Determinar o que deve ser feito primeiro', TRUE, 3),
      ('Qual ferramenta pode ajudar a controlar as tarefas?', 'Calculadora científica', FALSE, 0),
      ('Qual ferramenta pode ajudar a controlar as tarefas?', 'Câmera', FALSE, 1),
      ('Qual ferramenta pode ajudar a controlar as tarefas?', 'Lista de tarefas', TRUE, 2),
      ('Qual ferramenta pode ajudar a controlar as tarefas?', 'Leitor de música', FALSE, 3),
      ('Por que é útil definir objetivos?', 'Para aumentar a confusão', FALSE, 0),
      ('Por que é útil definir objetivos?', 'Para orientar os esforços', TRUE, 1),
      ('Por que é útil definir objetivos?', 'Para evitar resultados', FALSE, 2),
      ('Por que é útil definir objetivos?', 'Para eliminar responsabilidades', FALSE, 3),
      ('Qual destas atividades geralmente prejudica a concentração?', 'Verificar constantemente as redes sociais', TRUE, 0),
      ('Qual destas atividades geralmente prejudica a concentração?', 'Definir uma meta', FALSE, 1),
      ('Qual destas atividades geralmente prejudica a concentração?', 'Organizar o ambiente', FALSE, 2),
      ('Qual destas atividades geralmente prejudica a concentração?', 'Fazer uma pausa planejada', FALSE, 3),
      ('Para que serve uma agenda?', 'Substituir todas as ferramentas', FALSE, 0),
      ('Para que serve uma agenda?', 'Registrar e organizar compromissos', TRUE, 1),
      ('Para que serve uma agenda?', 'Aumentar tarefas sem controle', FALSE, 2),
      ('Para que serve uma agenda?', 'Eliminar horários', FALSE, 3),
      ('O que pode ajudar a manter o foco?', 'Evitar qualquer planejamento', FALSE, 0),
      ('O que pode ajudar a manter o foco?', 'Alternar constantemente entre tarefas', FALSE, 1),
      ('O que pode ajudar a manter o foco?', 'Definir um período específico para uma tarefa', TRUE, 2),
      ('O que pode ajudar a manter o foco?', 'Trabalhar com várias distrações abertas', FALSE, 3),
      ('Qual é a função de um calendário?', 'Apagar tarefas', FALSE, 0),
      ('Qual é a função de um calendário?', 'Organizar datas e compromissos', TRUE, 1),
      ('Qual é a função de um calendário?', 'Aumentar distrações', FALSE, 2),
      ('Qual é a função de um calendário?', 'Substituir a memória humana completamente', FALSE, 3),
      ('Qual comportamento contribui para uma boa organização?', 'Ignorar documentos', FALSE, 0),
      ('Qual comportamento contribui para uma boa organização?', 'Guardar informações importantes de forma desordenada', FALSE, 1),
      ('Qual comportamento contribui para uma boa organização?', 'Evitar listas', FALSE, 2),
      ('Qual comportamento contribui para uma boa organização?', 'Manter materiais organizados', TRUE, 3),
      ('Por que dividir uma tarefa grande em partes menores pode ser útil?', 'Facilita o acompanhamento do progresso', TRUE, 0),
      ('Por que dividir uma tarefa grande em partes menores pode ser útil?', 'Torna o trabalho mais confuso', FALSE, 1),
      ('Por que dividir uma tarefa grande em partes menores pode ser útil?', 'Aumenta necessariamente o tempo', FALSE, 2),
      ('Por que dividir uma tarefa grande em partes menores pode ser útil?', 'Impede a conclusão', FALSE, 3),
      ('O que significa administrar o tempo?', 'Usar o tempo de maneira planejada', TRUE, 0),
      ('O que significa administrar o tempo?', 'Fazer tudo simultaneamente', FALSE, 1),
      ('O que significa administrar o tempo?', 'Trabalhar sem descanso', FALSE, 2),
      ('O que significa administrar o tempo?', 'Evitar horários', FALSE, 3),
      ('Qual destas opções é uma distração digital comum?', 'Lista de tarefas', FALSE, 0),
      ('Qual destas opções é uma distração digital comum?', 'Cronómetro', FALSE, 1),
      ('Qual destas opções é uma distração digital comum?', 'Notificação desnecessária', TRUE, 2),
      ('Qual destas opções é uma distração digital comum?', 'Calendário', FALSE, 3),
      ('Qual é uma vantagem de preparar as atividades do dia seguinte?', 'Impede mudanças de planos', FALSE, 0),
      ('Qual é uma vantagem de preparar as atividades do dia seguinte?', 'Permite começar o dia com maior clareza', TRUE, 1),
      ('Qual é uma vantagem de preparar as atividades do dia seguinte?', 'Reduz a necessidade de organização', FALSE, 2),
      ('Qual é uma vantagem de preparar as atividades do dia seguinte?', 'Elimina todos os problemas', FALSE, 3),
      ('Qual hábito pode melhorar a produtividade?', 'Definir horários para atividades importantes', TRUE, 0),
      ('Qual hábito pode melhorar a produtividade?', 'Adiar constantemente as responsabilidades', FALSE, 1),
      ('Qual hábito pode melhorar a produtividade?', 'Trabalhar sem qualquer objetivo', FALSE, 2),
      ('Qual hábito pode melhorar a produtividade?', 'Ignorar compromissos', FALSE, 3),
      ('O que significa estar concentrado?', 'Evitar qualquer atividade', FALSE, 0),
      ('O que significa estar concentrado?', 'Prestar atenção ao que está sendo realizado', TRUE, 1),
      ('O que significa estar concentrado?', 'Pensar em várias coisas ao mesmo tempo', FALSE, 2),
      ('O que significa estar concentrado?', 'Verificar mensagens continuamente', FALSE, 3),
      ('Qual recurso pode ser usado para lembrar compromissos?', 'Galeria de fotos', FALSE, 0),
      ('Qual recurso pode ser usado para lembrar compromissos?', 'Calculadora', FALSE, 1),
      ('Qual recurso pode ser usado para lembrar compromissos?', 'Lanterna', FALSE, 2),
      ('Qual recurso pode ser usado para lembrar compromissos?', 'Alarme', TRUE, 3),
      ('Qual é uma vantagem de manter o espaço de trabalho organizado?', 'Elimina todos os erros', FALSE, 0),
      ('Qual é uma vantagem de manter o espaço de trabalho organizado?', 'Dispensa planejamento', FALSE, 1),
      ('Qual é uma vantagem de manter o espaço de trabalho organizado?', 'Facilita encontrar materiais', TRUE, 2),
      ('Qual é uma vantagem de manter o espaço de trabalho organizado?', 'Aumenta automaticamente o salário', FALSE, 3),
      ('Qual é uma boa forma de lidar com várias tarefas?', 'Ignorar todas', FALSE, 0),
      ('Qual é uma boa forma de lidar com várias tarefas?', 'Organizar por prioridade', TRUE, 1),
      ('Qual é uma boa forma de lidar com várias tarefas?', 'Começar sempre pela última', FALSE, 2),
      ('Qual é uma boa forma de lidar com várias tarefas?', 'Fazer todas simultaneamente', FALSE, 3),
      ('O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 'Os erros desaparecem', FALSE, 0),
      ('O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 'Todas as tarefas ficam automaticamente melhores', FALSE, 1),
      ('O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 'A concentração pode diminuir', TRUE, 2),
      ('O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 'O tempo deixa de existir', FALSE, 3),
      ('Para que serve um lembrete?', 'Substituir uma tarefa', FALSE, 0),
      ('Para que serve um lembrete?', 'Eliminar uma obrigação', FALSE, 1),
      ('Para que serve um lembrete?', 'Ajudar a recordar uma atividade ou compromisso', TRUE, 2),
      ('Para que serve um lembrete?', 'Aumentar uma dívida', FALSE, 3),
      ('Qual atitude ajuda a começar uma tarefa difícil?', 'Evitá-la sempre', FALSE, 0),
      ('Qual atitude ajuda a começar uma tarefa difícil?', 'Dividi-la em pequenos passos', TRUE, 1),
      ('Qual atitude ajuda a começar uma tarefa difícil?', 'Fazer outra atividade aleatória', FALSE, 2),
      ('Qual atitude ajuda a começar uma tarefa difícil?', 'Esperar pelo último momento', FALSE, 3),
      ('Qual destas ferramentas é útil para controlar horários?', 'Relógio', TRUE, 0),
      ('Qual destas ferramentas é útil para controlar horários?', 'Galeria', FALSE, 1),
      ('Qual destas ferramentas é útil para controlar horários?', 'Microfone', FALSE, 2),
      ('Qual destas ferramentas é útil para controlar horários?', 'Câmara', FALSE, 3),
      ('Qual é uma vantagem de estabelecer horários?', 'Ajuda a estruturar o dia', TRUE, 0),
      ('Qual é uma vantagem de estabelecer horários?', 'Elimina a necessidade de descanso', FALSE, 1),
      ('Qual é uma vantagem de estabelecer horários?', 'Impede qualquer mudança', FALSE, 2),
      ('Qual é uma vantagem de estabelecer horários?', 'Faz todas as tarefas desaparecerem', FALSE, 3),
      ('O que é um objetivo?', 'Uma distração', FALSE, 0),
      ('O que é um objetivo?', 'Um resultado que se pretende alcançar', TRUE, 1),
      ('O que é um objetivo?', 'Um atraso', FALSE, 2),
      ('O que é um objetivo?', 'Uma pausa', FALSE, 3),
      ('Qual destas ações ajuda a reduzir distrações?', 'Manter todas as notificações ativas', FALSE, 0),
      ('Qual destas ações ajuda a reduzir distrações?', 'Verificar o telefone a cada minuto', FALSE, 1),
      ('Qual destas ações ajuda a reduzir distrações?', 'Abrir várias redes sociais', FALSE, 2),
      ('Qual destas ações ajuda a reduzir distrações?', 'Desativar notificações desnecessárias', TRUE, 3),
      ('Por que é importante fazer uma lista de tarefas?', 'Para aumentar a desorganização', FALSE, 0),
      ('Por que é importante fazer uma lista de tarefas?', 'Para evitar prioridades', FALSE, 1),
      ('Por que é importante fazer uma lista de tarefas?', 'Para substituir o descanso', FALSE, 2),
      ('Por que é importante fazer uma lista de tarefas?', 'Para visualizar o que precisa ser realizado', TRUE, 3),
      ('O que é uma prioridade?', 'Uma tarefa sem importância', FALSE, 0),
      ('O que é uma prioridade?', 'Algo que merece atenção antes de outras atividades', TRUE, 1),
      ('O que é uma prioridade?', 'Um período de férias', FALSE, 2),
      ('O que é uma prioridade?', 'Uma distração', FALSE, 3),
      ('Qual hábito pode ajudar na pontualidade?', 'Considerar o tempo necessário para deslocamento', TRUE, 0),
      ('Qual hábito pode ajudar na pontualidade?', 'Sair sempre no último minuto', FALSE, 1),
      ('Qual hábito pode ajudar na pontualidade?', 'Ignorar horários', FALSE, 2),
      ('Qual hábito pode ajudar na pontualidade?', 'Não utilizar relógio', FALSE, 3),
      ('Qual destas atitudes demonstra boa gestão do tempo?', 'Adiar atividades constantemente', FALSE, 0),
      ('Qual destas atitudes demonstra boa gestão do tempo?', 'Evitar qualquer planejamento', FALSE, 1),
      ('Qual destas atitudes demonstra boa gestão do tempo?', 'Reservar tempo para tarefas importantes', TRUE, 2),
      ('Qual destas atitudes demonstra boa gestão do tempo?', 'Aceitar todas as interrupções', FALSE, 3),
      ('O que significa organizar uma tarefa?', 'Eliminá-la', FALSE, 0),
      ('O que significa organizar uma tarefa?', 'Definir como e quando ela será realizada', TRUE, 1),
      ('O que significa organizar uma tarefa?', 'Torná-la impossível', FALSE, 2),
      ('O que significa organizar uma tarefa?', 'Esquecê-la', FALSE, 3),
      ('Qual é uma consequência possível de não organizar compromissos?', 'Mais tempo disponível automaticamente', FALSE, 0),
      ('Qual é uma consequência possível de não organizar compromissos?', 'Esquecimento de atividades importantes', TRUE, 1),
      ('Qual é uma consequência possível de não organizar compromissos?', 'Maior clareza automática', FALSE, 2),
      ('Qual é uma consequência possível de não organizar compromissos?', 'Menos responsabilidades', FALSE, 3),
      ('O que pode ajudar a controlar o tempo gasto numa atividade?', 'Câmara', FALSE, 0),
      ('O que pode ajudar a controlar o tempo gasto numa atividade?', 'Cronómetro', TRUE, 1),
      ('O que pode ajudar a controlar o tempo gasto numa atividade?', 'Gravador', FALSE, 2),
      ('O que pode ajudar a controlar o tempo gasto numa atividade?', 'Lanterna', FALSE, 3),
      ('O que significa manter consistência?', 'Evitar hábitos', FALSE, 0),
      ('O que significa manter consistência?', 'Fazer algo apenas uma vez', FALSE, 1),
      ('O que significa manter consistência?', 'Realizar uma ação de forma regular', TRUE, 2),
      ('O que significa manter consistência?', 'Mudar de objetivo diariamente', FALSE, 3),
      ('Qual atitude pode melhorar a utilização do tempo?', 'Trabalhar sem prioridades', FALSE, 0),
      ('Qual atitude pode melhorar a utilização do tempo?', 'Aceitar todas as distrações', FALSE, 1),
      ('Qual atitude pode melhorar a utilização do tempo?', 'Adiar tarefas simples', FALSE, 2),
      ('Qual atitude pode melhorar a utilização do tempo?', 'Estabelecer limites para atividades pouco importantes', TRUE, 3),
      ('Por que o descanso é importante?', 'Substitui o planejamento', FALSE, 0),
      ('Por que o descanso é importante?', 'Pode ajudar na recuperação e manutenção da energia', TRUE, 1),
      ('Por que o descanso é importante?', 'Elimina a necessidade de trabalhar', FALSE, 2),
      ('Por que o descanso é importante?', 'Torna qualquer tarefa automática', FALSE, 3),
      ('Qual destas opções ajuda a lembrar tarefas futuras?', 'Câmara', FALSE, 0),
      ('Qual destas opções ajuda a lembrar tarefas futuras?', 'Galeria', FALSE, 1),
      ('Qual destas opções ajuda a lembrar tarefas futuras?', 'Lista de lembretes', TRUE, 2),
      ('Qual destas opções ajuda a lembrar tarefas futuras?', 'Aplicativo de música', FALSE, 3),
      ('O que significa preparar uma tarefa?', 'Ignorar os materiais', FALSE, 0),
      ('O que significa preparar uma tarefa?', 'Reunir informações e recursos necessários antes de executá-la', TRUE, 1),
      ('O que significa preparar uma tarefa?', 'Evitar a tarefa', FALSE, 2),
      ('O que significa preparar uma tarefa?', 'Cancelar o objetivo', FALSE, 3),
      ('Qual é uma vantagem de definir uma hora para começar uma tarefa?', 'Cria um ponto claro de início', TRUE, 0),
      ('Qual é uma vantagem de definir uma hora para começar uma tarefa?', 'Elimina a responsabilidade', FALSE, 1),
      ('Qual é uma vantagem de definir uma hora para começar uma tarefa?', 'Garante que não haverá dificuldades', FALSE, 2),
      ('Qual é uma vantagem de definir uma hora para começar uma tarefa?', 'Torna a tarefa desnecessária', FALSE, 3),
      ('O que é uma meta diária?', 'Uma tarefa sem prazo', FALSE, 0),
      ('O que é uma meta diária?', 'Uma distração', FALSE, 1),
      ('O que é uma meta diária?', 'Um resultado que se pretende alcançar durante o dia', TRUE, 2),
      ('O que é uma meta diária?', 'Um período de descanso', FALSE, 3),
      ('Qual ação ajuda a acompanhar o progresso?', 'Evitar registros', FALSE, 0),
      ('Qual ação ajuda a acompanhar o progresso?', 'Ignorar resultados', FALSE, 1),
      ('Qual ação ajuda a acompanhar o progresso?', 'Apagar todas as tarefas', FALSE, 2),
      ('Qual ação ajuda a acompanhar o progresso?', 'Marcar tarefas concluídas', TRUE, 3),
      ('O que pode ajudar uma pessoa a manter uma rotina?', 'Ausência de planejamento', FALSE, 0),
      ('O que pode ajudar uma pessoa a manter uma rotina?', 'Mudanças constantes sem motivo', FALSE, 1),
      ('O que pode ajudar uma pessoa a manter uma rotina?', 'Horários relativamente consistentes', TRUE, 2),
      ('O que pode ajudar uma pessoa a manter uma rotina?', 'Ignorar compromissos', FALSE, 3),
      ('Qual é uma maneira simples de evitar esquecer compromissos?', 'Não registrar horários', FALSE, 0),
      ('Qual é uma maneira simples de evitar esquecer compromissos?', 'Usar lembretes', TRUE, 1),
      ('Qual é uma maneira simples de evitar esquecer compromissos?', 'Ignorar a agenda', FALSE, 2),
      ('Qual é uma maneira simples de evitar esquecer compromissos?', 'Confiar sempre na memória', FALSE, 3),
      ('Qual atitude pode facilitar o início do trabalho?', 'Procurar distrações', FALSE, 0),
      ('Qual atitude pode facilitar o início do trabalho?', 'Preparar previamente os materiais necessários', TRUE, 1),
      ('Qual atitude pode facilitar o início do trabalho?', 'Adiar indefinidamente', FALSE, 2),
      ('Qual atitude pode facilitar o início do trabalho?', 'Evitar saber o objetivo', FALSE, 3),
      ('O que é uma lista de prioridades?', 'Um calendário de feriados', FALSE, 0),
      ('O que é uma lista de prioridades?', 'Uma lista de contatos', FALSE, 1),
      ('O que é uma lista de prioridades?', 'Uma relação de atividades organizada pela importância', TRUE, 2),
      ('O que é uma lista de prioridades?', 'Uma lista de distrações', FALSE, 3),
      ('Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 'Responder a todas as notificações imediatamente', FALSE, 0),
      ('Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 'Assistir vídeos aleatórios', FALSE, 1),
      ('Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 'Alternar constantemente entre aplicações', FALSE, 2),
      ('Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 'Manter o foco numa tarefa definida', TRUE, 3),
      ('Por que é útil definir um prazo para uma atividade?', 'Garante que não haverá erros', FALSE, 0),
      ('Por que é útil definir um prazo para uma atividade?', 'Elimina a necessidade de ação', FALSE, 1),
      ('Por que é útil definir um prazo para uma atividade?', 'Torna a atividade impossível', FALSE, 2),
      ('Por que é útil definir um prazo para uma atividade?', 'Ajuda a orientar quando ela deve ser concluída', TRUE, 3),
      ('Qual é uma boa prática ao terminar o dia?', 'Apagar todos os registros', FALSE, 0),
      ('Qual é uma boa prática ao terminar o dia?', 'Evitar qualquer planejamento', FALSE, 1),
      ('Qual é uma boa prática ao terminar o dia?', 'Rever o que foi realizado e preparar as próximas tarefas', TRUE, 2),
      ('Qual é uma boa prática ao terminar o dia?', 'Ignorar tarefas pendentes', FALSE, 3),
      ('Qual atitude contribui para uma melhor gestão das tarefas?', 'Evitar qualquer prazo', FALSE, 0),
      ('Qual atitude contribui para uma melhor gestão das tarefas?', 'Definir o que fazer, quando fazer e qual a prioridade', TRUE, 1),
      ('Qual atitude contribui para uma melhor gestão das tarefas?', 'Começar tudo ao mesmo tempo', FALSE, 2),
      ('Qual atitude contribui para uma melhor gestão das tarefas?', 'Deixar todas as decisões para o último momento', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_facil_v7;

    RAISE NOTICE '48 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_facil_v7).';
  END IF;
END $$;

COMMIT;