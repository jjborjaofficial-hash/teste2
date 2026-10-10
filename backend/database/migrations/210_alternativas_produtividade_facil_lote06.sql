-- Alternativas (BE-003, regularização) — Produtividade fácil lote 6: perguntas 1 a 25 do seed v7 (migration 096).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (fácil: migrations 210 e 211) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order, perguntas nem explicações. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 0, 'Fazer tudo ao mesmo tempo', 'Fazer duas coisas juntas'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 1, 'Trabalhar somente nas tarefas mais fáceis', 'Escolher as tarefas mais fáceis'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 3, 'Evitar qualquer planejamento', 'Adiar o planejamento'),
    ('seed_produtividade_facil_v7', 'O que significa estabelecer uma prioridade?', 0, 'Adiar todas as tarefas', 'Adiar as tarefas mais difíceis do dia'),
    ('seed_produtividade_facil_v7', 'O que significa estabelecer uma prioridade?', 1, 'Escolher uma tarefa aleatoriamente', 'Escolher uma tarefa por sorteio entre as pendentes'),
    ('seed_produtividade_facil_v7', 'O que significa estabelecer uma prioridade?', 2, 'Eliminar todas as atividades', 'Eliminar as atividades que dão trabalho'),
    ('seed_produtividade_facil_v7', 'Qual ferramenta pode ajudar a controlar as tarefas?', 0, 'Calculadora científica', 'Calculadora de bolso'),
    ('seed_produtividade_facil_v7', 'Qual ferramenta pode ajudar a controlar as tarefas?', 1, 'Câmera', 'Câmera fotográfica'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir objetivos?', 2, 'Para evitar resultados', 'Para adiar os resultados'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir objetivos?', 3, 'Para eliminar responsabilidades', 'Para reduzir as responsabilidades'),
    ('seed_produtividade_facil_v7', 'Qual destas atividades geralmente prejudica a concentração?', 1, 'Definir uma meta', 'Definir uma meta para o dia de trabalho'),
    ('seed_produtividade_facil_v7', 'Qual destas atividades geralmente prejudica a concentração?', 2, 'Organizar o ambiente', 'Organizar o ambiente de trabalho'),
    ('seed_produtividade_facil_v7', 'Qual destas atividades geralmente prejudica a concentração?', 3, 'Fazer uma pausa planejada', 'Fazer uma pausa curta e planejada'),
    ('seed_produtividade_facil_v7', 'Para que serve uma agenda?', 0, 'Substituir todas as ferramentas', 'Substituir as outras ferramentas de trabalho'),
    ('seed_produtividade_facil_v7', 'Para que serve uma agenda?', 2, 'Aumentar tarefas sem controle', 'Aumentar as tarefas sem controle'),
    ('seed_produtividade_facil_v7', 'Para que serve uma agenda?', 3, 'Eliminar horários', 'Eliminar os horários marcados'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a manter o foco?', 0, 'Evitar qualquer planejamento', 'Evitar planejar o período das tarefas'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a manter o foco?', 1, 'Alternar constantemente entre tarefas', 'Alternar entre várias tarefas ao longo do dia'),
    ('seed_produtividade_facil_v7', 'Qual é a função de um calendário?', 0, 'Apagar tarefas', 'Apagar as tarefas antigas'),
    ('seed_produtividade_facil_v7', 'Qual é a função de um calendário?', 2, 'Aumentar distrações', 'Aumentar as distrações do dia'),
    ('seed_produtividade_facil_v7', 'Qual é a função de um calendário?', 3, 'Substituir a memória humana completamente', 'Substituir a memória das pessoas'),
    ('seed_produtividade_facil_v7', 'Qual comportamento contribui para uma boa organização?', 0, 'Ignorar documentos', 'Ignorar os documentos do dia'),
    ('seed_produtividade_facil_v7', 'Qual comportamento contribui para uma boa organização?', 1, 'Guardar informações importantes de forma desordenada', 'Guardar documentos sem ordem'),
    ('seed_produtividade_facil_v7', 'Qual comportamento contribui para uma boa organização?', 2, 'Evitar listas', 'Evitar o uso de listas'),
    ('seed_produtividade_facil_v7', 'Por que dividir uma tarefa grande em partes menores pode ser útil?', 1, 'Torna o trabalho mais confuso', 'Torna o trabalho mais confuso e lento'),
    ('seed_produtividade_facil_v7', 'Por que dividir uma tarefa grande em partes menores pode ser útil?', 2, 'Aumenta necessariamente o tempo', 'Aumenta o tempo gasto na tarefa'),
    ('seed_produtividade_facil_v7', 'Por que dividir uma tarefa grande em partes menores pode ser útil?', 3, 'Impede a conclusão', 'Impede a conclusão da tarefa'),
    ('seed_produtividade_facil_v7', 'O que significa administrar o tempo?', 1, 'Fazer tudo simultaneamente', 'Fazer várias coisas ao mesmo tempo'),
    ('seed_produtividade_facil_v7', 'O que significa administrar o tempo?', 2, 'Trabalhar sem descanso', 'Trabalhar sem fazer pausas'),
    ('seed_produtividade_facil_v7', 'O que significa administrar o tempo?', 3, 'Evitar horários', 'Evitar os horários marcados'),
    ('seed_produtividade_facil_v7', 'Qual destas opções é uma distração digital comum?', 0, 'Lista de tarefas', 'Lista de tarefas pendentes'),
    ('seed_produtividade_facil_v7', 'Qual destas opções é uma distração digital comum?', 1, 'Cronómetro', 'Cronómetro de estudo'),
    ('seed_produtividade_facil_v7', 'Qual destas opções é uma distração digital comum?', 3, 'Calendário', 'Calendário do telemóvel'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de preparar as atividades do dia seguinte?', 0, 'Impede mudanças de planos', 'Impede mudanças nos planos do dia'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de preparar as atividades do dia seguinte?', 3, 'Elimina todos os problemas', 'Elimina os problemas do dia seguinte'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode melhorar a produtividade?', 1, 'Adiar constantemente as responsabilidades', 'Adiar as responsabilidades para o fim da semana'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode melhorar a produtividade?', 2, 'Trabalhar sem qualquer objetivo', 'Trabalhar sem ter um objetivo claro'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode melhorar a produtividade?', 3, 'Ignorar compromissos', 'Ignorar os compromissos marcados'),
    ('seed_produtividade_facil_v7', 'O que significa estar concentrado?', 0, 'Evitar qualquer atividade', 'Evitar fazer atividades difíceis'),
    ('seed_produtividade_facil_v7', 'O que significa estar concentrado?', 3, 'Verificar mensagens continuamente', 'Verificar as mensagens a cada instante'),
    ('seed_produtividade_facil_v7', 'Qual recurso pode ser usado para lembrar compromissos?', 0, 'Galeria de fotos', 'Galeria'),
    ('seed_produtividade_facil_v7', 'Qual recurso pode ser usado para lembrar compromissos?', 1, 'Calculadora', 'Câmara'),
    ('seed_produtividade_facil_v7', 'Qual recurso pode ser usado para lembrar compromissos?', 2, 'Lanterna', 'Lanterna'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 0, 'Elimina todos os erros', 'Elimina os erros de cálculo'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 1, 'Dispensa planejamento', 'Dispensa o planejamento diário'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 3, 'Aumenta automaticamente o salário', 'Aumenta o salário no fim do mês'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa forma de lidar com várias tarefas?', 0, 'Ignorar todas', 'Ignorar as mais urgentes'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa forma de lidar com várias tarefas?', 2, 'Começar sempre pela última', 'Começar pela última da lista'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa forma de lidar com várias tarefas?', 3, 'Fazer todas simultaneamente', 'Fazer várias ao mesmo tempo'),
    ('seed_produtividade_facil_v7', 'O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 0, 'Os erros desaparecem', 'Os erros podem desaparecer'),
    ('seed_produtividade_facil_v7', 'O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 1, 'Todas as tarefas ficam automaticamente melhores', 'As tarefas podem ficar melhores'),
    ('seed_produtividade_facil_v7', 'O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 3, 'O tempo deixa de existir', 'O tempo pode render mais'),
    ('seed_produtividade_facil_v7', 'Para que serve um lembrete?', 0, 'Substituir uma tarefa', 'Substituir uma tarefa por outra mais fácil'),
    ('seed_produtividade_facil_v7', 'Para que serve um lembrete?', 1, 'Eliminar uma obrigação', 'Eliminar uma obrigação do calendário'),
    ('seed_produtividade_facil_v7', 'Para que serve um lembrete?', 3, 'Aumentar uma dívida', 'Aumentar o valor de uma dívida pendente'),
    ('seed_produtividade_facil_v7', 'Qual atitude ajuda a começar uma tarefa difícil?', 0, 'Evitá-la sempre', 'Evitá-la até ficar mais fácil'),
    ('seed_produtividade_facil_v7', 'Qual atitude ajuda a começar uma tarefa difícil?', 2, 'Fazer outra atividade aleatória', 'Fazer outra atividade primeiro'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de estabelecer horários?', 1, 'Elimina a necessidade de descanso', 'Elimina o tempo de descanso'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de estabelecer horários?', 2, 'Impede qualquer mudança', 'Impede mudanças no dia'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de estabelecer horários?', 3, 'Faz todas as tarefas desaparecerem', 'Faz as tarefas desaparecerem'),
    ('seed_produtividade_facil_v7', 'O que é um objetivo?', 0, 'Uma distração', 'Uma distração que atrapalha o trabalho'),
    ('seed_produtividade_facil_v7', 'O que é um objetivo?', 2, 'Um atraso', 'Um atraso que se quer evitar no trabalho'),
    ('seed_produtividade_facil_v7', 'O que é um objetivo?', 3, 'Uma pausa', 'Uma pausa que se faz entre as tarefas'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 0, 'Manter todas as notificações ativas', 'Manter as notificações ativas no telemóvel'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 2, 'Abrir várias redes sociais', 'Abrir várias redes sociais ao mesmo tempo')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 6: % alternativa(s) errada(s) atualizada(s) (esperado: 65).', v_updated;
END $$;
