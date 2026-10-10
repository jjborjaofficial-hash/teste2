-- Alternativas (BE-003, regularização) — Produtividade difícil lote 2: 25 perguntas seguintes do seed v2 (v2#2 a v2#26, migration 078).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (difícil: 260 a 267) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_dificil_v2', 'Um profissional planeia 8 horas de trabalho com tarefas que somam exatamente 8 horas, sem considerar interrupções ou imprevistos. Qual é o principal problema?', 1, 'O profissional possui demasiado tempo livre', 'O plano deixa tempo livre em excesso'),
    ('seed_produtividade_dificil_v2', 'Um profissional planeia 8 horas de trabalho com tarefas que somam exatamente 8 horas, sem considerar interrupções ou imprevistos. Qual é o principal problema?', 3, 'As tarefas são necessariamente pequenas', 'As tarefas planeadas são demasiado pequenas'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa importante tem prazo para amanhã, enquanto várias tarefas menores não possuem prazo definido. Qual princípio deve orientar a decisão?', 0, 'Priorizar sempre a tarefa mais curta', 'Priorizar a tarefa que demora menos'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa importante tem prazo para amanhã, enquanto várias tarefas menores não possuem prazo definido. Qual princípio deve orientar a decisão?', 3, 'Trabalhar exclusivamente nas tarefas menores', 'Trabalhar nas tarefas menores primeiro'),
    ('seed_produtividade_dificil_v2', 'Um gestor percebe que a equipa passa grande parte do dia respondendo mensagens, enquanto atividades estratégicas ficam atrasadas. Qual intervenção tende a ser mais eficiente?', 1, 'Adicionar mais reuniões', 'Adicionar reuniões de acompanhamento diárias'),
    ('seed_produtividade_dificil_v2', 'Um gestor percebe que a equipa passa grande parte do dia respondendo mensagens, enquanto atividades estratégicas ficam atrasadas. Qual intervenção tende a ser mais eficiente?', 2, 'Eliminar todas as mensagens', 'Eliminar as mensagens menos importantes'),
    ('seed_produtividade_dificil_v2', 'Um gestor percebe que a equipa passa grande parte do dia respondendo mensagens, enquanto atividades estratégicas ficam atrasadas. Qual intervenção tende a ser mais eficiente?', 3, 'Aumentar a frequência de verificação das mensagens', 'Verificar as mensagens com mais frequência'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa trabalha oito horas, mas passa frequentemente de uma aplicação para outra. Qual indicador seria mais útil para diagnosticar o problema?', 1, 'Tamanho do monitor', 'Tamanho e qualidade do monitor'),
    ('seed_produtividade_dificil_v2', 'Um projeto está atrasado porque uma única pessoa precisa aprovar todas as etapas. Qual conceito descreve melhor essa situação?', 0, 'Planeamento reverso', 'Prazo'),
    ('seed_produtividade_dificil_v2', 'Um projeto está atrasado porque uma única pessoa precisa aprovar todas as etapas. Qual conceito descreve melhor essa situação?', 2, 'Delegação excessiva', 'Delegação'),
    ('seed_produtividade_dificil_v2', 'Um projeto está atrasado porque uma única pessoa precisa aprovar todas as etapas. Qual conceito descreve melhor essa situação?', 3, 'Pausa produtiva', 'Pausa'),
    ('seed_produtividade_dificil_v2', 'Para eliminar um gargalo, uma equipa simplesmente adiciona mais tarefas à etapa já sobrecarregada. Qual é o problema dessa estratégia?', 1, 'Aumenta a capacidade da etapa', 'Pode aumentar a capacidade da etapa'),
    ('seed_produtividade_dificil_v2', 'Para eliminar um gargalo, uma equipa simplesmente adiciona mais tarefas à etapa já sobrecarregada. Qual é o problema dessa estratégia?', 2, 'Reduz automaticamente o tempo de execução', 'Pode reduzir o tempo de execução'),
    ('seed_produtividade_dificil_v2', 'Para eliminar um gargalo, uma equipa simplesmente adiciona mais tarefas à etapa já sobrecarregada. Qual é o problema dessa estratégia?', 3, 'Elimina a dependência', 'Pode eliminar a dependência entre etapas'),
    ('seed_produtividade_dificil_v2', 'Uma empresa quer descobrir por que um processo demora muito. Qual abordagem é mais adequada?', 0, 'Aumentar todos os prazos', 'Aumentar os prazos para que a equipa tenha mais tempo'),
    ('seed_produtividade_dificil_v2', 'Uma empresa quer descobrir por que um processo demora muito. Qual abordagem é mais adequada?', 1, 'Medir apenas o número de funcionários', 'Medir o número de funcionários envolvidos no processo'),
    ('seed_produtividade_dificil_v2', 'Uma empresa quer descobrir por que um processo demora muito. Qual abordagem é mais adequada?', 3, 'Eliminar os indicadores', 'Eliminar os indicadores para simplificar a análise'),
    ('seed_produtividade_dificil_v2', 'Um funcionário termina 30 tarefas de baixa importância enquanto deixa duas tarefas críticas pendentes. O que isso demonstra?', 1, 'Planeamento reverso correto', 'Boa gestão do tempo'),
    ('seed_produtividade_dificil_v2', 'Um funcionário termina 30 tarefas de baixa importância enquanto deixa duas tarefas críticas pendentes. O que isso demonstra?', 2, 'Alta produtividade necessariamente', 'Foco no que é urgente'),
    ('seed_produtividade_dificil_v2', 'Um funcionário termina 30 tarefas de baixa importância enquanto deixa duas tarefas críticas pendentes. O que isso demonstra?', 3, 'Excelente gestão de energia', 'Boa gestão de energia'),
    ('seed_produtividade_dificil_v2', 'Qual combinação representa melhor produtividade sustentável?', 1, 'Alta velocidade sem qualidade', 'Alta velocidade de execução com baixa qualidade'),
    ('seed_produtividade_dificil_v2', 'Qual combinação representa melhor produtividade sustentável?', 2, 'Alta ocupação sem resultados', 'Agenda cheia de tarefas com poucos resultados'),
    ('seed_produtividade_dificil_v2', 'Qual combinação representa melhor produtividade sustentável?', 3, 'Trabalho contínuo sem descanso', 'Trabalho contínuo, com horas extra e sem pausas'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa apresenta grande impacto, mas não é urgente. Outra é urgente, mas possui pouco impacto. Qual abordagem evita uma decisão simplista?', 1, 'Escolher sempre a urgente', 'Escolher a tarefa urgente primeiro'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa apresenta grande impacto, mas não é urgente. Outra é urgente, mas possui pouco impacto. Qual abordagem evita uma decisão simplista?', 2, 'Avaliar apenas o prazo', 'Avaliar o prazo e o esforço de cada uma'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa apresenta grande impacto, mas não é urgente. Outra é urgente, mas possui pouco impacto. Qual abordagem evita uma decisão simplista?', 3, 'Escolher sempre a importante', 'Escolher a tarefa importante primeiro'),
    ('seed_produtividade_dificil_v2', 'Um profissional possui energia elevada pela manhã e baixa concentração no final do dia. Como pode adaptar o planejamento?', 0, 'Fazer todas as tarefas difíceis à noite', 'Colocar as tarefas cognitivamente exigentes no período de menor energia'),
    ('seed_produtividade_dificil_v2', 'Um profissional possui energia elevada pela manhã e baixa concentração no final do dia. Como pode adaptar o planejamento?', 2, 'Evitar qualquer horário definido', 'Evitar horários definidos e trabalhar conforme o ritmo do dia'),
    ('seed_produtividade_dificil_v2', 'Um profissional possui energia elevada pela manhã e baixa concentração no final do dia. Como pode adaptar o planejamento?', 3, 'Distribuir todas as tarefas aleatoriamente', 'Distribuir as tarefas pelo dia sem considerar a sua dificuldade'),
    ('seed_produtividade_dificil_v2', 'O que significa alinhar tarefas com níveis de energia?', 0, 'Eliminar tarefas difíceis', 'Eliminar as tarefas difíceis do plano para poupar energia ao longo do dia'),
    ('seed_produtividade_dificil_v2', 'O que significa alinhar tarefas com níveis de energia?', 1, 'Trabalhar apenas quando houver motivação', 'Trabalhar nas tarefas quando a motivação surgir, sem horário definido'),
    ('seed_produtividade_dificil_v2', 'O que significa alinhar tarefas com níveis de energia?', 2, 'Executar todas as tarefas no mesmo horário', 'Executar as tarefas do dia no mesmo horário, independentemente do tipo'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mede produtividade apenas pelo número de tarefas concluídas. Qual limitação existe?', 0, 'Mede demasiados fatores', 'Mede demasiados fatores ao mesmo tempo'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mede produtividade apenas pelo número de tarefas concluídas. Qual limitação existe?', 1, 'Avalia necessariamente resultados estratégicos', 'Avalia bem os resultados estratégicos'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mede produtividade apenas pelo número de tarefas concluídas. Qual limitação existe?', 3, 'Elimina qualquer comparação', 'Impede a comparação entre equipas'),
    ('seed_produtividade_dificil_v2', 'Qual indicador seria mais completo para avaliar a execução de um projeto?', 0, 'Quantidade de mensagens enviadas', 'Quantidade de mensagens enviadas e reuniões realizadas pela equipa'),
    ('seed_produtividade_dificil_v2', 'Qual indicador seria mais completo para avaliar a execução de um projeto?', 2, 'Número de horas trabalhadas', 'Número de horas trabalhadas por cada membro da equipa no projeto'),
    ('seed_produtividade_dificil_v2', 'Qual indicador seria mais completo para avaliar a execução de um projeto?', 3, 'Número de tarefas realizadas', 'Número de tarefas concluídas em cada semana do projeto'),
    ('seed_produtividade_dificil_v2', 'Um projeto possui prazo fixo e várias atividades dependentes umas das outras. Qual ferramenta pode ajudar a visualizar a sequência temporal?', 0, 'Lista de contactos', 'Orçamento'),
    ('seed_produtividade_dificil_v2', 'Um projeto possui prazo fixo e várias atividades dependentes umas das outras. Qual ferramenta pode ajudar a visualizar a sequência temporal?', 1, 'Caixa de entrada', 'Inventário'),
    ('seed_produtividade_dificil_v2', 'Um projeto possui prazo fixo e várias atividades dependentes umas das outras. Qual ferramenta pode ajudar a visualizar a sequência temporal?', 2, 'Galeria', 'Galeria'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa crítica depende de outra que frequentemente atrasa. Qual é o primeiro passo mais adequado?', 1, 'Ignorar a dependência', 'Ignorar a dependência e avançar com a tarefa'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa crítica depende de outra que frequentemente atrasa. Qual é o primeiro passo mais adequado?', 2, 'Eliminar o prazo', 'Alargar o prazo da tarefa sem analisar a causa'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui muitas tarefas classificadas como "urgentes". Qual problema isso pode indicar?', 0, 'Automação perfeita', 'Excesso de automação nos processos'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui muitas tarefas classificadas como "urgentes". Qual problema isso pode indicar?', 2, 'Excelente priorização', 'Priorização feita com critérios rigorosos'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui muitas tarefas classificadas como "urgentes". Qual problema isso pode indicar?', 3, 'Excesso de tempo disponível', 'Excesso de tempo disponível na equipa'),
    ('seed_produtividade_dificil_v2', 'Se tudo é considerado prioridade, qual é a consequência mais provável?', 1, 'O trabalho torna-se automaticamente mais rápido', 'O trabalho torna-se mais rápido de executar'),
    ('seed_produtividade_dificil_v2', 'Se tudo é considerado prioridade, qual é a consequência mais provável?', 2, 'Os prazos deixam de existir', 'Os prazos tornam-se mais fáceis de cumprir'),
    ('seed_produtividade_dificil_v2', 'Se tudo é considerado prioridade, qual é a consequência mais provável?', 3, 'Todas as tarefas recebem atenção máxima', 'Cada tarefa recebe a atenção de que precisa'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa estabelece uma meta de "trabalhar mais". Por que essa meta é fraca?', 0, 'Porque possui métricas demais', 'Porque possui demasiadas métricas de acompanhamento'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa estabelece uma meta de "trabalhar mais". Por que essa meta é fraca?', 2, 'Porque possui prazo curto', 'Porque possui um prazo demasiado curto para cumprir'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa estabelece uma meta de "trabalhar mais". Por que essa meta é fraca?', 3, 'Porque é demasiado específica', 'Porque é demasiado específica para ser acompanhada'),
    ('seed_produtividade_dificil_v2', 'Qual característica torna uma meta mais mensurável?', 0, 'Eliminar prazos', 'Eliminar os prazos para dar flexibilidade ao trabalho'),
    ('seed_produtividade_dificil_v2', 'Qual característica torna uma meta mais mensurável?', 1, 'Utilizar apenas palavras genéricas', 'Utilizar palavras genéricas que permitam várias leituras'),
    ('seed_produtividade_dificil_v2', 'Qual característica torna uma meta mais mensurável?', 3, 'Evitar números', 'Evitar números para não limitar a interpretação'),
    ('seed_produtividade_dificil_v2', 'Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?', 0, 'Ignorar o processo', 'Ignorar o processo atual e começar a automatizar as etapas mais lentas'),
    ('seed_produtividade_dificil_v2', 'Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?', 1, 'Automatizar imediatamente sem analisar', 'Automatizar o processo já existente e medir os resultados só depois'),
    ('seed_produtividade_dificil_v2', 'Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?', 3, 'Adicionar etapas manuais', 'Adicionar etapas manuais de controlo e depois reduzir os desperdícios'),
    ('seed_produtividade_dificil_v2', 'Por que automatizar um processo mal estruturado pode ser problemático?', 0, 'Sempre elimina erros', 'Pode eliminar os erros do processo, mas deixa de ser necessário medi-lo'),
    ('seed_produtividade_dificil_v2', 'Por que automatizar um processo mal estruturado pode ser problemático?', 1, 'Impede qualquer repetição', 'Pode impedir a repetição de tarefas, o que reduz a flexibilidade da equipa'),
    ('seed_produtividade_dificil_v2', 'Por que automatizar um processo mal estruturado pode ser problemático?', 3, 'Sempre reduz custos', 'Pode reduzir os custos, mas obriga a equipa a repetir as tarefas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa automatizou uma tarefa, mas agora erros são replicados em grande escala. Qual princípio foi negligenciado?', 0, 'Aumentar o número de tarefas', 'Aumentar o número de tarefas automatizadas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa automatizou uma tarefa, mas agora erros são replicados em grande escala. Qual princípio foi negligenciado?', 2, 'Eliminar a revisão', 'Eliminar a revisão humana dos resultados'),
    ('seed_produtividade_dificil_v2', 'Uma equipa automatizou uma tarefa, mas agora erros são replicados em grande escala. Qual princípio foi negligenciado?', 3, 'Reduzir o controlo', 'Reduzir o controlo sobre as tarefas repetidas'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa melhor uma melhoria de processo?', 0, 'Aumentar o número de aprovações', 'Aumentar o número de aprovações necessárias em cada etapa'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa melhor uma melhoria de processo?', 2, 'Fazer a mesma tarefa com mais etapas', 'Repetir a mesma tarefa com mais etapas de verificação'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa melhor uma melhoria de processo?', 3, 'Adicionar mais relatórios sem finalidade', 'Adicionar relatórios mensais sem finalidade definida'),
    ('seed_produtividade_dificil_v2', 'Uma equipa realiza uma reunião semanal de duas horas, mas grande parte dos participantes não precisa participar de todos os assuntos. Qual melhoria é mais adequada?', 0, 'Aumentar a reunião para três horas', 'Aumentar a reunião para três horas, mantendo os mesmos participantes'),
    ('seed_produtividade_dificil_v2', 'Uma equipa realiza uma reunião semanal de duas horas, mas grande parte dos participantes não precisa participar de todos os assuntos. Qual melhoria é mais adequada?', 2, 'Adicionar mais tópicos', 'Adicionar mais tópicos para aproveitar o tempo da reunião'),
    ('seed_produtividade_dificil_v2', 'Uma equipa realiza uma reunião semanal de duas horas, mas grande parte dos participantes não precisa participar de todos os assuntos. Qual melhoria é mais adequada?', 3, 'Eliminar a pauta', 'Eliminar a pauta para tornar a reunião mais flexível')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade difícil lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 70).', v_updated;
END $$;
