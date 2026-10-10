-- Alternativas (BE-003, regularização) — Produtividade fácil lote 7: as 23 perguntas ativas que faltam do seed v7 (v7#26 a v7#48, migration 096), que fecha o fácil.
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (fácil: migrations 212 e 213) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_facil_v7', 'Por que é importante fazer uma lista de tarefas?', 0, 'Para aumentar a desorganização', 'Para aumentar a desorganização do dia'),
    ('seed_produtividade_facil_v7', 'Por que é importante fazer uma lista de tarefas?', 1, 'Para evitar prioridades', 'Para evitar ter de definir as prioridades do dia'),
    ('seed_produtividade_facil_v7', 'Por que é importante fazer uma lista de tarefas?', 2, 'Para substituir o descanso', 'Para substituir o descanso e o lazer'),
    ('seed_produtividade_facil_v7', 'O que é uma prioridade?', 0, 'Uma tarefa sem importância', 'Uma tarefa que pode ser deixada para depois'),
    ('seed_produtividade_facil_v7', 'O que é uma prioridade?', 2, 'Um período de férias', 'Um período de pausa entre as atividades'),
    ('seed_produtividade_facil_v7', 'O que é uma prioridade?', 3, 'Uma distração', 'Uma distração que atrapalha o trabalho'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode ajudar na pontualidade?', 1, 'Sair sempre no último minuto', 'Sair de casa pouco antes da hora marcada'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode ajudar na pontualidade?', 2, 'Ignorar horários', 'Ignorar os horários dos compromissos'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode ajudar na pontualidade?', 3, 'Não utilizar relógio', 'Deixar de usar o relógio no dia a dia'),
    ('seed_produtividade_facil_v7', 'Qual destas atitudes demonstra boa gestão do tempo?', 0, 'Adiar atividades constantemente', 'Adiar as atividades para o dia seguinte'),
    ('seed_produtividade_facil_v7', 'Qual destas atitudes demonstra boa gestão do tempo?', 1, 'Evitar qualquer planejamento', 'Evitar planejar o dia de trabalho'),
    ('seed_produtividade_facil_v7', 'Qual destas atitudes demonstra boa gestão do tempo?', 3, 'Aceitar todas as interrupções', 'Aceitar as interrupções que surgirem'),
    ('seed_produtividade_facil_v7', 'O que significa organizar uma tarefa?', 0, 'Eliminá-la', 'Eliminá-la da lista quando parecer difícil'),
    ('seed_produtividade_facil_v7', 'O que significa organizar uma tarefa?', 2, 'Torná-la impossível', 'Torná-la mais difícil de executar no dia'),
    ('seed_produtividade_facil_v7', 'O que significa organizar uma tarefa?', 3, 'Esquecê-la', 'Esquecê-la até alguém lembrar que existe'),
    ('seed_produtividade_facil_v7', 'Qual é uma consequência possível de não organizar compromissos?', 0, 'Mais tempo disponível automaticamente', 'Mais tempo livre durante o dia'),
    ('seed_produtividade_facil_v7', 'Qual é uma consequência possível de não organizar compromissos?', 2, 'Maior clareza automática', 'Maior clareza sobre as tarefas'),
    ('seed_produtividade_facil_v7', 'Qual é uma consequência possível de não organizar compromissos?', 3, 'Menos responsabilidades', 'Menos responsabilidades no trabalho e em casa'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a controlar o tempo gasto numa atividade?', 2, 'Gravador', 'Microfone'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a controlar o tempo gasto numa atividade?', 3, 'Lanterna', 'Calculadora'),
    ('seed_produtividade_facil_v7', 'O que significa manter consistência?', 0, 'Evitar hábitos', 'Evitar criar hábitos de trabalho'),
    ('seed_produtividade_facil_v7', 'O que significa manter consistência?', 1, 'Fazer algo apenas uma vez', 'Fazer uma ação uma única vez por mês'),
    ('seed_produtividade_facil_v7', 'O que significa manter consistência?', 3, 'Mudar de objetivo diariamente', 'Mudar de objetivo quando surgir dúvida'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode melhorar a utilização do tempo?', 0, 'Trabalhar sem prioridades', 'Trabalhar sem definir quais são as prioridades'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode melhorar a utilização do tempo?', 1, 'Aceitar todas as distrações', 'Aceitar as distrações que aparecem durante o dia'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode melhorar a utilização do tempo?', 2, 'Adiar tarefas simples', 'Adiar as tarefas simples para o fim do dia'),
    ('seed_produtividade_facil_v7', 'Por que o descanso é importante?', 0, 'Substitui o planejamento', 'Pode substituir o planejamento do dia de trabalho'),
    ('seed_produtividade_facil_v7', 'Por que o descanso é importante?', 2, 'Elimina a necessidade de trabalhar', 'Pode eliminar a necessidade de trabalhar no dia seguinte'),
    ('seed_produtividade_facil_v7', 'Por que o descanso é importante?', 3, 'Torna qualquer tarefa automática', 'Pode tornar as tarefas mais automáticas e fáceis'),
    ('seed_produtividade_facil_v7', 'Qual destas opções ajuda a lembrar tarefas futuras?', 0, 'Câmara', 'Câmara de vídeo'),
    ('seed_produtividade_facil_v7', 'Qual destas opções ajuda a lembrar tarefas futuras?', 1, 'Galeria', 'Galeria de fotos'),
    ('seed_produtividade_facil_v7', 'O que significa preparar uma tarefa?', 0, 'Ignorar os materiais', 'Ignorar os materiais e começar a executá-la sem preparação'),
    ('seed_produtividade_facil_v7', 'O que significa preparar uma tarefa?', 2, 'Evitar a tarefa', 'Evitar a tarefa até alguém explicar como se faz'),
    ('seed_produtividade_facil_v7', 'O que significa preparar uma tarefa?', 3, 'Cancelar o objetivo', 'Cancelar o objetivo e passar para outra tarefa mais fácil'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de definir uma hora para começar uma tarefa?', 1, 'Elimina a responsabilidade', 'Tira a responsabilidade da tarefa'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de definir uma hora para começar uma tarefa?', 2, 'Garante que não haverá dificuldades', 'Evita as dificuldades da tarefa'),
    ('seed_produtividade_facil_v7', 'O que é uma meta diária?', 0, 'Uma tarefa sem prazo', 'Uma tarefa sem prazo, que se faz quando houver tempo'),
    ('seed_produtividade_facil_v7', 'O que é uma meta diária?', 1, 'Uma distração', 'Uma distração que costuma aparecer durante o dia'),
    ('seed_produtividade_facil_v7', 'O que é uma meta diária?', 3, 'Um período de descanso', 'Um período de descanso reservado para o fim do dia'),
    ('seed_produtividade_facil_v7', 'Qual ação ajuda a acompanhar o progresso?', 0, 'Evitar registros', 'Evitar registrar o trabalho'),
    ('seed_produtividade_facil_v7', 'Qual ação ajuda a acompanhar o progresso?', 1, 'Ignorar resultados', 'Ignorar os resultados obtidos'),
    ('seed_produtividade_facil_v7', 'Qual ação ajuda a acompanhar o progresso?', 2, 'Apagar todas as tarefas', 'Apagar as tarefas da lista'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar uma pessoa a manter uma rotina?', 0, 'Ausência de planejamento', 'Ausência de planejamento diário'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar uma pessoa a manter uma rotina?', 3, 'Ignorar compromissos', 'Ignorar os compromissos marcados no calendário'),
    ('seed_produtividade_facil_v7', 'Qual é uma maneira simples de evitar esquecer compromissos?', 0, 'Não registrar horários', 'Não anotar nada'),
    ('seed_produtividade_facil_v7', 'Qual é uma maneira simples de evitar esquecer compromissos?', 3, 'Confiar sempre na memória', 'Confiar na memória'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode facilitar o início do trabalho?', 0, 'Procurar distrações', 'Procurar distrações antes de começar'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode facilitar o início do trabalho?', 2, 'Adiar indefinidamente', 'Adiar o início até ao último momento'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode facilitar o início do trabalho?', 3, 'Evitar saber o objetivo', 'Evitar saber qual é o objetivo da tarefa do dia'),
    ('seed_produtividade_facil_v7', 'O que é uma lista de prioridades?', 0, 'Um calendário de feriados', 'Um calendário de feriados e datas especiais'),
    ('seed_produtividade_facil_v7', 'O que é uma lista de prioridades?', 1, 'Uma lista de contatos', 'Uma lista de contatos organizada por ordem alfabética'),
    ('seed_produtividade_facil_v7', 'O que é uma lista de prioridades?', 3, 'Uma lista de distrações', 'Uma lista de distrações organizada por tipo'),
    ('seed_produtividade_facil_v7', 'Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 0, 'Responder a todas as notificações imediatamente', 'Responder às notificações à medida que chegam'),
    ('seed_produtividade_facil_v7', 'Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 1, 'Assistir vídeos aleatórios', 'Assistir a vídeos durante o estudo'),
    ('seed_produtividade_facil_v7', 'Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 2, 'Alternar constantemente entre aplicações', 'Alternar entre várias aplicações'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir um prazo para uma atividade?', 0, 'Garante que não haverá erros', 'Evita que ocorram erros durante a atividade'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir um prazo para uma atividade?', 1, 'Elimina a necessidade de ação', 'Elimina a necessidade de começar a atividade'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir um prazo para uma atividade?', 2, 'Torna a atividade impossível', 'Torna a atividade mais difícil de concluir'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática ao terminar o dia?', 0, 'Apagar todos os registros', 'Apagar os registros do dia e começar do zero amanhã'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática ao terminar o dia?', 1, 'Evitar qualquer planejamento', 'Evitar planejar as tarefas do dia seguinte'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática ao terminar o dia?', 3, 'Ignorar tarefas pendentes', 'Ignorar as tarefas pendentes e esperar pelo dia seguinte'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 0, 'Evitar qualquer prazo', 'Evitar definir prazos e prioridades para as tarefas'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 2, 'Começar tudo ao mesmo tempo', 'Começar várias tarefas ao mesmo tempo e depois escolher'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 3, 'Deixar todas as decisões para o último momento', 'Deixar as decisões importantes para o último momento')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 7: % alternativa(s) errada(s) atualizada(s) (esperado: 64).', v_updated;
END $$;
