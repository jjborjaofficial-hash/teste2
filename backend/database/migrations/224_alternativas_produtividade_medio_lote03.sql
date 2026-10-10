-- Alternativas (BE-003, regularização) — Produtividade médio lote 3: Produtividade médio lote 3.
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (médio: migrations 224 e 225) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_medio_v3', 'Qual prática ajuda a reduzir o custo de troca de contexto?', 3, 'Alternar constantemente entre tarefas', 'Alternar entre tarefas várias vezes'),
    ('seed_produtividade_medio_v3', 'Quando a delegação é especialmente útil?', 1, 'Quando a tarefa não possui importância', 'Quando a tarefa não tem importância para ninguém da equipa nem para os clientes'),
    ('seed_produtividade_medio_v3', 'Quando a delegação é especialmente útil?', 2, 'Quando ninguém sabe realizar a tarefa', 'Quando a equipa ainda não tem competência nem recursos para executar a tarefa'),
    ('seed_produtividade_medio_v3', 'Quando a delegação é especialmente útil?', 3, 'Quando não existe prazo', 'Quando a tarefa não tem prazo definido e pode ficar parada por tempo indeterminado na lista'),
    ('seed_produtividade_medio_v3', 'O que é automação de tarefas?', 0, 'Aumentar o número de reuniões', 'Aumentar o número de reuniões para decidir como as atividades repetitivas serão feitas'),
    ('seed_produtividade_medio_v3', 'O que é automação de tarefas?', 2, 'Eliminar qualquer tecnologia', 'Eliminar a tecnologia das atividades repetitivas para reduzir a dependência de sistemas'),
    ('seed_produtividade_medio_v3', 'O que é automação de tarefas?', 3, 'Fazer todas as tarefas manualmente', 'Fazer as atividades repetitivas manualmente, passo a passo, para garantir o controlo'),
    ('seed_produtividade_medio_v3', 'Qual tarefa é uma boa candidata à automação?', 0, 'Uma conversa emocional complexa', 'Uma conversa difícil com um colega sobre um problema pessoal'),
    ('seed_produtividade_medio_v3', 'Qual tarefa é uma boa candidata à automação?', 1, 'Uma decisão estratégica altamente subjetiva', 'Uma decisão estratégica baseada em critérios subjetivos'),
    ('seed_produtividade_medio_v3', 'Qual tarefa é uma boa candidata à automação?', 2, 'Uma negociação imprevisível', 'Uma negociação com resultado imprevisível entre as partes'),
    ('seed_produtividade_medio_v3', 'O que é uma rotina produtiva?', 0, 'Um período sem objetivos', 'Um conjunto de períodos livres, sem objetivos definidos, usados conforme a vontade de cada pessoa'),
    ('seed_produtividade_medio_v3', 'O que é uma rotina produtiva?', 2, 'Uma lista aleatória de tarefas', 'Uma lista de tarefas escolhidas ao acaso e realizadas sem ordem nem planejamento'),
    ('seed_produtividade_medio_v3', 'O que é uma rotina produtiva?', 3, 'Uma agenda sem horários', 'Uma agenda preenchida com tarefas sem horários, feitas conforme o ânimo do dia'),
    ('seed_produtividade_medio_v3', 'Por que rotinas podem melhorar a produtividade?', 0, 'Eliminam a necessidade de descanso', 'Eliminam a necessidade de descansar entre as atividades que se repetem no dia de trabalho'),
    ('seed_produtividade_medio_v3', 'Por que rotinas podem melhorar a produtividade?', 2, 'Garantem que todas as tarefas sejam fáceis', 'Tornam fáceis as tarefas difíceis, pois a repetição elimina o esforço mental'),
    ('seed_produtividade_medio_v3', 'Por que rotinas podem melhorar a produtividade?', 3, 'Impedem mudanças de prioridade', 'Impedem mudanças de prioridade nas situações em que a rotina já está definida'),
    ('seed_produtividade_medio_v3', 'O que é energia mental no contexto da produtividade?', 0, 'Quantidade de eletricidade consumida pelo computador', 'Quantidade de energia elétrica consumida pelo computador durante o trabalho'),
    ('seed_produtividade_medio_v3', 'O que é energia mental no contexto da produtividade?', 2, 'Número de tarefas concluídas', 'Número de tarefas concluídas por dia, usado para medir o desempenho'),
    ('seed_produtividade_medio_v3', 'O que é energia mental no contexto da produtividade?', 3, 'Velocidade da internet', 'Velocidade da internet disponível para trabalhar com o computador'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 1, 'Porque tarefas simples exigem mais concentração', 'Porque tarefas simples exigem mais concentração do que as complexas'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 2, 'Porque tarefas difíceis nunca podem ser feitas à tarde', 'Porque tarefas difíceis devem ser feitas quando há menos pressão'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 3, 'Porque o cérebro funciona apenas pela manhã', 'Porque o cérebro funciona melhor quando há menos pessoas por perto'),
    ('seed_produtividade_medio_v3', 'O que é fadiga decisória?', 1, 'Excesso de descanso', 'Excesso de descanso que reduz a disposição para tomar novas decisões'),
    ('seed_produtividade_medio_v3', 'O que é fadiga decisória?', 2, 'Aumento automático da criatividade', 'Aumento da criatividade para decidir depois de muitas decisões acumuladas ao longo do dia'),
    ('seed_produtividade_medio_v3', 'O que é fadiga decisória?', 3, 'Falta de tarefas', 'Falta de tarefas e de decisões a tomar durante o dia de trabalho'),
    ('seed_produtividade_medio_v3', 'Qual prática pode reduzir a fadiga decisória?', 0, 'Aumentar o número de escolhas desnecessárias', 'Aumentar as escolhas disponíveis em cada decisão'),
    ('seed_produtividade_medio_v3', 'Qual prática pode reduzir a fadiga decisória?', 1, 'Mudar constantemente os métodos de trabalho', 'Mudar de método de trabalho a cada nova decisão'),
    ('seed_produtividade_medio_v3', 'Qual prática pode reduzir a fadiga decisória?', 3, 'Evitar qualquer planejamento', 'Evitar planejar as decisões antes de as tomar'),
    ('seed_produtividade_medio_v3', 'O que é uma revisão diária?', 0, 'Exclusão de todas as tarefas incompletas', 'Exclusão das tarefas incompletas do dia para começar o seguinte do zero'),
    ('seed_produtividade_medio_v3', 'O que é uma revisão diária?', 1, 'Planejamento anual', 'Planejamento anual com a avaliação do que foi feito e do que falta fazer'),
    ('seed_produtividade_medio_v3', 'O que é uma revisão diária?', 3, 'Um período exclusivamente de descanso', 'Um período de descanso curto, usado para recuperar a energia mental ao fim de cada dia de trabalho'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 1, 'Aumentar automaticamente a carga horária', 'Aumentar a carga horária da semana para recuperar o trabalho em atraso acumulado'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 2, 'Trabalhar sem prioridades', 'Trabalhar a semana seguinte sem ter prioridades definidas à partida'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 3, 'Apagar objetivos antigos sem análise', 'Apagar os objetivos antigos da lista sem os analisar nem os atualizar'),
    ('seed_produtividade_medio_v3', 'O que é backlog de tarefas?', 0, 'Lista de tarefas já concluídas', 'Conjunto de tarefas já concluídas que aguardam arquivamento ou revisão'),
    ('seed_produtividade_medio_v3', 'O que é backlog de tarefas?', 2, 'Agenda de reuniões realizadas', 'Conjunto de reuniões já realizadas que aguardam o registo das atas'),
    ('seed_produtividade_medio_v3', 'O que é backlog de tarefas?', 3, 'Arquivo de documentos eliminados', 'Conjunto de documentos eliminados que aguardam recuperação ou arquivo'),
    ('seed_produtividade_medio_v3', 'Por que um backlog excessivamente grande pode ser prejudicial?', 0, 'Garante maior produtividade', 'Pode aumentar a produtividade por oferecer mais tarefas para escolher em cada momento'),
    ('seed_produtividade_medio_v3', 'Por que um backlog excessivamente grande pode ser prejudicial?', 2, 'Elimina a necessidade de planejamento', 'Pode eliminar a necessidade de planejamento, porque tudo já está listado'),
    ('seed_produtividade_medio_v3', 'Por que um backlog excessivamente grande pode ser prejudicial?', 3, 'Faz todas as tarefas tornarem-se urgentes', 'Pode transformar as tarefas em urgentes por falta de tempo para as fazer'),
    ('seed_produtividade_medio_v3', 'Qual é uma consequência de aceitar compromissos em excesso?', 0, 'Mais tempo disponível', 'Aumento do tempo livre e redução da carga de trabalho semanal'),
    ('seed_produtividade_medio_v3', 'Qual é uma consequência de aceitar compromissos em excesso?', 1, 'Menor necessidade de organização', 'Menor necessidade de organização e de acompanhamento dos prazos assumidos'),
    ('seed_produtividade_medio_v3', 'Qual é uma consequência de aceitar compromissos em excesso?', 3, 'Aumento garantido da qualidade', 'Aumento da qualidade pela maior dedicação a cada compromisso'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 0, 'Uma tarefa que precisa ser feita por último', 'Uma atividade que deve ser deixada por último por ter pouca contribuição'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 2, 'Uma atividade que demora muitas horas', 'Uma atividade que demora muitas horas e ocupa a maior parte do dia'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 3, 'Necessariamente uma tarefa difícil', 'Uma tarefa difícil de executar, que exige muita competência técnica'),
    ('seed_produtividade_medio_v3', 'Por que estar ocupado não significa necessariamente ser produtivo?', 0, 'Porque tarefas importantes são sempre rápidas', 'Porque tarefas importantes costumam ser rápidas, e a ocupação mede quanto se faz'),
    ('seed_produtividade_medio_v3', 'Por que estar ocupado não significa necessariamente ser produtivo?', 1, 'Porque trabalhar nunca é produtivo', 'Porque o trabalho contínuo gera cansaço, e o cansaço reduz o rendimento da equipa'),
    ('seed_produtividade_medio_v3', 'Por que estar ocupado não significa necessariamente ser produtivo?', 2, 'Porque produtividade não depende de resultados', 'Porque produtividade depende da quantidade de horas trabalhadas, independentemente dos resultados'),
    ('seed_produtividade_medio_v3', 'O que é a regra dos dois minutos, associada ao método GTD?', 0, 'Todas as tarefas devem durar exatamente dois minutos', 'Se uma ação demorar mais de dois minutos, deve ser realizada imediatamente'),
    ('seed_produtividade_medio_v3', 'O que é a regra dos dois minutos, associada ao método GTD?', 1, 'Todo trabalho deve ser interrompido a cada dois minutos', 'Se uma ação for importante, pode ser mais eficiente interrompê-la a cada dois minutos'),
    ('seed_produtividade_medio_v3', 'O que é a regra dos dois minutos, associada ao método GTD?', 3, 'Nenhuma tarefa pode ser delegada', 'Se uma ação puder ser delegada, deve esperar dois minutos antes de ser entregue'),
    ('seed_produtividade_medio_v3', 'No método GTD, qual é uma etapa fundamental?', 0, 'Memorizar todas as tarefas', 'Memorizar os compromissos e informações que exigem atenção'),
    ('seed_produtividade_medio_v3', 'No método GTD, qual é uma etapa fundamental?', 1, 'Evitar listas externas', 'Evitar listas externas e guardar compromissos só na memória'),
    ('seed_produtividade_medio_v3', 'No método GTD, qual é uma etapa fundamental?', 3, 'Trabalhar sem revisão', 'Trabalhar sem revisão dos compromissos e informações registrados'),
    ('seed_produtividade_medio_v3', 'O que é um sistema externo de organização?', 0, 'Uma técnica para eliminar tarefas', 'Uma técnica usada para eliminar tarefas e informações que ocupam espaço na memória de trabalho do computador'),
    ('seed_produtividade_medio_v3', 'O que é um sistema externo de organização?', 2, 'Um método de trabalho sem registros', 'Um método de trabalho em que as informações são guardadas na memória da própria pessoa que as executa'),
    ('seed_produtividade_medio_v3', 'O que é um sistema externo de organização?', 3, 'Um sistema que substitui o pensamento', 'Um sistema usado para tomar as decisões no lugar das pessoas que o utilizam no trabalho'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de utilizar um calendário para compromissos?', 0, 'Serve apenas para registrar tarefas concluídas', 'Serve para registrar as tarefas concluídas em cada data e hora'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de utilizar um calendário para compromissos?', 1, 'Impede alterações de agenda', 'Impede alterações de agenda depois de marcados os compromissos principais da semana'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de utilizar um calendário para compromissos?', 2, 'Elimina a necessidade de prioridades', 'Elimina a necessidade de definir prioridades entre as atividades'),
    ('seed_produtividade_medio_v3', 'O que caracteriza uma boa sessão de foco?', 0, 'Várias tarefas simultâneas', 'Várias tarefas simultâneas, ambiente com música e período flexível de trabalho'),
    ('seed_produtividade_medio_v3', 'O que caracteriza uma boa sessão de foco?', 1, 'Ausência de objetivo', 'Ausência de objetivo, ambiente com música alta e período sem limite de tempo'),
    ('seed_produtividade_medio_v3', 'O que caracteriza uma boa sessão de foco?', 2, 'Muitas interrupções', 'Muitas interrupções planeadas, ambiente movimentado e período curto de trabalho em cada dia'),
    ('seed_produtividade_medio_v3', 'Por que estimar o tempo das tarefas pode melhorar o planejamento?', 1, 'Elimina todos os imprevistos', 'Ajuda a eliminar os imprevistos que surgem durante a execução das tarefas'),
    ('seed_produtividade_medio_v3', 'Por que estimar o tempo das tarefas pode melhorar o planejamento?', 2, 'Garante que nenhuma tarefa sofrerá atrasos', 'Ajuda a garantir que as tarefas sejam concluídas antes do prazo definido pelo gestor'),
    ('seed_produtividade_medio_v3', 'Por que estimar o tempo das tarefas pode melhorar o planejamento?', 3, 'Torna todas as tarefas igualmente importantes', 'Ajuda a tornar as tarefas igualmente importantes para a pessoa que as executa'),
    ('seed_produtividade_medio_v3', 'Qual é uma característica de um sistema de produtividade sustentável?', 0, 'Mantém a agenda cheia em todos os momentos', 'Mantém a agenda preenchida com tarefas durante o horário de trabalho e a pausa'),
    ('seed_produtividade_medio_v3', 'Qual é uma característica de um sistema de produtividade sustentável?', 2, 'Prioriza quantidade de tarefas acima da qualidade', 'Prioriza a quantidade de tarefas concluídas, mesmo que a qualidade seja menor'),
    ('seed_produtividade_medio_v3', 'Qual é uma característica de um sistema de produtividade sustentável?', 3, 'Exige trabalhar continuamente sem pausas', 'Exige trabalhar de forma contínua e manter o ritmo máximo mesmo em dias difíceis'),
    ('seed_produtividade_medio_v4', 'Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 0, 'Começar pela tarefa mais fácil', 'Começar pela tarefa mais fácil entre as cinco'),
    ('seed_produtividade_medio_v4', 'Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 1, 'Escolher aleatoriamente', 'Escolher a tarefa por sorteio entre as cinco'),
    ('seed_produtividade_medio_v4', 'Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 2, 'Adiar ambas', 'Adiar as duas tarefas para o dia seguinte')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 73).', v_updated;
END $$;
