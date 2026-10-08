-- Alternativas (BE-003, regularização) — Produtividade fácil lote 2: perguntas 1 a 12 do seed v2 (migration 051) e 1 a 13 do seed v3 (migration 084).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+).
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
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 0, 'Evitar tarefas importantes', 'Dividir as tarefas igualmente entre todas as pessoas'),
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 1, 'Fazer tudo ao mesmo tempo', 'Registrar todas as tarefas em uma lista por ordem alfabética'),
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 3, 'Trabalhar sem planejamento', 'Adiar as tarefas mais difíceis para quando houver tempo'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de criar uma lista de tarefas?', 0, 'Trabalhar sem descanso', 'Aumentar o número de tarefas que podem ser iniciadas'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de criar uma lista de tarefas?', 1, 'Eliminar todas as dificuldades', 'Reduzir a necessidade de definir prazos e prioridades'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de criar uma lista de tarefas?', 2, 'Aumentar automaticamente o salário', 'Registrar apenas as atividades que já foram concluídas'),
    ('seed_produtividade_facil_v2', 'Qual estratégia pode ajudar a reduzir distrações?', 1, 'Responder todas as mensagens imediatamente', 'Manter o celular ao lado com o som ligado'),
    ('seed_produtividade_facil_v2', 'Qual estratégia pode ajudar a reduzir distrações?', 2, 'Trocar constantemente de atividade', 'Abrir várias abas para consultar tudo ao mesmo tempo'),
    ('seed_produtividade_facil_v2', 'Qual estratégia pode ajudar a reduzir distrações?', 3, 'Abrir várias redes sociais', 'Alternar entre tarefas sempre que surgir uma ideia nova'),
    ('seed_produtividade_facil_v2', 'O que significa estabelecer uma meta?', 1, 'Trabalhar sem direção', 'Listar as atividades que já foram realizadas'),
    ('seed_produtividade_facil_v2', 'O que significa estabelecer uma meta?', 2, 'Evitar qualquer objetivo', 'Escolher o horário em que se começa a trabalhar'),
    ('seed_produtividade_facil_v2', 'O que significa estabelecer uma meta?', 3, 'Fazer tarefas aleatórias', 'Calcular o tempo gasto em cada tarefa do dia'),
    ('seed_produtividade_facil_v2', 'Por que dividir uma tarefa grande em etapas pode ajudar?', 0, 'Aumenta sempre o tempo', 'Aumenta a quantidade de trabalho'),
    ('seed_produtividade_facil_v2', 'Por que dividir uma tarefa grande em etapas pode ajudar?', 2, 'Torna a tarefa impossível', 'Reduz a necessidade de planejar'),
    ('seed_produtividade_facil_v2', 'Por que dividir uma tarefa grande em etapas pode ajudar?', 3, 'Elimina a necessidade de execução', 'Dispensa o acompanhamento do progresso'),
    ('seed_produtividade_facil_v2', 'Para que serve um calendário?', 0, 'Editar imagens', 'Calcular os gastos mensais e as receitas da família'),
    ('seed_produtividade_facil_v2', 'Para que serve um calendário?', 1, 'Criar senhas', 'Guardar documentos e arquivos importantes em pastas'),
    ('seed_produtividade_facil_v2', 'Para que serve um calendário?', 2, 'Guardar dinheiro', 'Registrar contatos e números de telefone das pessoas'),
    ('seed_produtividade_facil_v2', 'Qual prática pode ajudar na concentração?', 0, 'Manter todas as notificações ativas', 'Alternar entre várias tarefas ao longo de cada hora'),
    ('seed_produtividade_facil_v2', 'Qual prática pode ajudar na concentração?', 2, 'Mudar de tarefa a cada minuto', 'Trabalhar por muitas horas seguidas sem descanso'),
    ('seed_produtividade_facil_v2', 'Qual prática pode ajudar na concentração?', 3, 'Trabalhar sem objetivo', 'Deixar as tarefas mais importantes para o fim do dia'),
    ('seed_produtividade_facil_v2', 'Por que revisar objetivos regularmente pode ser útil?', 0, 'Elimina metas', 'Permite esquecer as metas que já foram definidas'),
    ('seed_produtividade_facil_v2', 'Por que revisar objetivos regularmente pode ser útil?', 1, 'Impede qualquer mudança', 'Serve para comparar o desempenho com outras pessoas'),
    ('seed_produtividade_facil_v2', 'Por que revisar objetivos regularmente pode ser útil?', 3, 'Garante resultados automaticamente', 'Evita a necessidade de planejar as atividades'),
    ('seed_produtividade_facil_v2', 'O que é uma tarefa recorrente?', 0, 'Uma atividade realizada apenas uma vez', 'Uma atividade que só pode ser feita em datas especiais'),
    ('seed_produtividade_facil_v2', 'O que é uma tarefa recorrente?', 1, 'Uma atividade impossível', 'Uma atividade que foi adiada para o dia seguinte'),
    ('seed_produtividade_facil_v2', 'O que é uma tarefa recorrente?', 3, 'Uma tarefa cancelada', 'Uma atividade que depende da aprovação de outra pessoa'),
    ('seed_produtividade_facil_v2', 'Qual atitude ajuda a evitar atrasos?', 0, 'Não registrar compromissos', 'Aceitar mais tarefas do que o tempo permite'),
    ('seed_produtividade_facil_v2', 'Qual atitude ajuda a evitar atrasos?', 2, 'Começar sempre no último minuto', 'Deixar o trabalho para quando houver vontade'),
    ('seed_produtividade_facil_v2', 'Qual atitude ajuda a evitar atrasos?', 3, 'Ignorar prazos', 'Evitar anotar os prazos combinados'),
    ('seed_produtividade_facil_v2', 'O que é planejamento?', 0, 'Adiamento de todas as tarefas', 'Avaliação posterior dos resultados obtidos em cada objetivo'),
    ('seed_produtividade_facil_v2', 'O que é planejamento?', 1, 'Improvisação permanente', 'Distribuição das tarefas entre os membros de uma equipe'),
    ('seed_produtividade_facil_v2', 'O que é planejamento?', 2, 'Trabalho sem direção', 'Registro diário das horas trabalhadas em cada atividade'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 1, 'Aumenta sempre o custo', 'Substitui a necessidade de prazos'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 2, 'Garante que nunca haverá erros', 'Garante a aprovação do trabalho'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 3, 'Elimina a necessidade de aprender', 'Dispensa a organização das tarefas'),
    ('seed_produtividade_facil_v3', 'Qual é uma boa prática para começar o dia de trabalho?', 0, 'Começar várias tarefas ao mesmo tempo', 'Responder todas as mensagens recebidas'),
    ('seed_produtividade_facil_v3', 'Qual é uma boa prática para começar o dia de trabalho?', 1, 'Evitar qualquer planejamento', 'Verificar as redes sociais antes de tudo'),
    ('seed_produtividade_facil_v3', 'Qual é uma boa prática para começar o dia de trabalho?', 3, 'Trabalhar sem pausas', 'Deixar o planejamento para o fim do dia'),
    ('seed_produtividade_facil_v3', 'Por que é importante estabelecer objetivos?', 1, 'Para aumentar a confusão', 'Para comparar o trabalho com o de outras pessoas'),
    ('seed_produtividade_facil_v3', 'Por que é importante estabelecer objetivos?', 2, 'Para evitar qualquer planejamento', 'Para reduzir o número de tarefas a executar'),
    ('seed_produtividade_facil_v3', 'Por que é importante estabelecer objetivos?', 3, 'Para eliminar todas as responsabilidades', 'Para evitar prazos e compromissos futuros'),
    ('seed_produtividade_facil_v3', 'O que pode ajudar a evitar distrações durante o trabalho?', 0, 'Manter várias redes sociais abertas', 'Manter o celular sempre à vista'),
    ('seed_produtividade_facil_v3', 'O que pode ajudar a evitar distrações durante o trabalho?', 1, 'Ver vídeos constantemente', 'Alternar entre várias tarefas sem parar'),
    ('seed_produtividade_facil_v3', 'O que pode ajudar a evitar distrações durante o trabalho?', 2, 'Trocar de tarefa a cada minuto', 'Responder as mensagens assim que chegam'),
    ('seed_produtividade_facil_v3', 'O que significa organizar o tempo?', 0, 'Trabalhar sem horários', 'Usar o tempo conforme a vontade'),
    ('seed_produtividade_facil_v3', 'O que significa organizar o tempo?', 1, 'Evitar prioridades', 'Gastar o tempo apenas em tarefas fáceis'),
    ('seed_produtividade_facil_v3', 'O que significa organizar o tempo?', 2, 'Fazer tudo simultaneamente', 'Reduzir o número de horas de descanso'),
    ('seed_produtividade_facil_v3', 'Uma agenda serve principalmente para:', 0, 'Entreter o usuário', 'Calcular gastos e receitas mensais'),
    ('seed_produtividade_facil_v3', 'Uma agenda serve principalmente para:', 1, 'Criar imagens', 'Editar fotos e vídeos pessoais'),
    ('seed_produtividade_facil_v3', 'Uma agenda serve principalmente para:', 3, 'Fazer cálculos complexos', 'Reproduzir músicas durante o trabalho'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 0, 'Faz perder sempre produtividade', 'Aumenta o cansaço depois de cada tarefa'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 1, 'Elimina a necessidade de planejamento', 'Dispensa a definição de prioridades'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 2, 'Impede a conclusão das tarefas', 'Reduz a qualidade das tarefas concluídas'),
    ('seed_produtividade_facil_v3', 'Qual é uma característica de uma meta bem definida?', 0, 'Ser completamente vaga', 'Ser ampla e flexível'),
    ('seed_produtividade_facil_v3', 'Qual é uma característica de uma meta bem definida?', 2, 'Não possuir prazo', 'Ter um prazo indefinido'),
    ('seed_produtividade_facil_v3', 'Qual é uma característica de uma meta bem definida?', 3, 'Não poder ser medida', 'Ser difícil de medir'),
    ('seed_produtividade_facil_v3', 'O que ajuda a acompanhar o progresso de um projeto?', 1, 'Ignorar as tarefas concluídas', 'Aumentar o número de tarefas simultâneas do projeto'),
    ('seed_produtividade_facil_v3', 'O que ajuda a acompanhar o progresso de um projeto?', 2, 'Evitar qualquer registro', 'Reduzir as reuniões e conversas entre os membros'),
    ('seed_produtividade_facil_v3', 'O que ajuda a acompanhar o progresso de um projeto?', 3, 'Mudar constantemente os objetivos', 'Comparar o projeto com o de outras equipes'),
    ('seed_produtividade_facil_v3', 'Qual atitude pode melhorar a concentração?', 0, 'Usar várias aplicações simultaneamente', 'Trabalhar com várias abas abertas'),
    ('seed_produtividade_facil_v3', 'Qual atitude pode melhorar a concentração?', 1, 'Responder a todas as notificações imediatamente', 'Manter o celular sempre ao alcance'),
    ('seed_produtividade_facil_v3', 'Qual atitude pode melhorar a concentração?', 3, 'Interromper o trabalho constantemente', 'Mudar de tarefa várias vezes por hora'),
    ('seed_produtividade_facil_v3', 'Por que estabelecer prazos pode ajudar na produtividade?', 0, 'Elimina todas as responsabilidades', 'Ajuda a aumentar o número de tarefas pendentes em aberto'),
    ('seed_produtividade_facil_v3', 'Por que estabelecer prazos pode ajudar na produtividade?', 1, 'Impede o planejamento', 'Reduz a necessidade de organizar as tarefas por prioridade'),
    ('seed_produtividade_facil_v3', 'Por que estabelecer prazos pode ajudar na produtividade?', 2, 'Faz todas as tarefas desaparecerem', 'Permite adiar as atividades sem afetar o resultado final'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 0, 'Ignorar todas', 'Escolher apenas as mais fáceis'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 2, 'Fazer todas simultaneamente', 'Fazer a lista só no fim do dia'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 3, 'Adiar indefinidamente', 'Pedir que outra pessoa decida tudo'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 1, 'Planejar as atividades', 'Revisar as tarefas todos os dias'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 2, 'Trabalhar com foco', 'Fazer pausas curtas e planejadas'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 3, 'Definir prioridades', 'Estabelecer prazos realistas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 2: perguntas 1 a 12 do seed v2 (migration 051) e 1 a 13 do seed v3 (migration 084): % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
