-- Alternativas (BE-003, regularização) — Produtividade difícil lote 4: as 23 perguntas ativas que faltam do seed v2 (v2#52 a v2#73, migration 078) e a do seed v3 (migration 101), que fecha o difícil.
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
    ('seed_produtividade_dificil_v2', 'O que é uma premissa de planejamento?', 0, 'Um resultado garantido', 'Um resultado garantido depois de executar o plano'),
    ('seed_produtividade_dificil_v2', 'O que é uma premissa de planejamento?', 1, 'Uma pausa', 'Uma pausa estratégica prevista dentro do plano'),
    ('seed_produtividade_dificil_v2', 'O que é uma premissa de planejamento?', 3, 'Uma tarefa concluída', 'Uma tarefa concluída que serve de base ao plano'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 0, 'Porque todo plano deve ser abandonado semanalmente', 'Porque os planos devem ser abandonados quando surgem críticas'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 1, 'Porque dados não são importantes', 'Porque os dados do plano deixam de ser úteis depois de aprovados'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 2, 'Porque metas não precisam de estabilidade', 'Porque as metas devem ser alteradas quando alguém discorda delas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa estabelece um prazo sem considerar a duração das dependências anteriores. Qual falha ocorreu?', 0, 'A tarefa ficou simples demais', 'A tarefa ficou demasiado simples e a equipa perdeu o interesse nela'),
    ('seed_produtividade_dificil_v2', 'Uma equipa estabelece um prazo sem considerar a duração das dependências anteriores. Qual falha ocorreu?', 2, 'Houve excesso de automação', 'Houve excesso de automação nas tarefas anteriores do projeto'),
    ('seed_produtividade_dificil_v2', 'Uma equipa estabelece um prazo sem considerar a duração das dependências anteriores. Qual falha ocorreu?', 3, 'A equipa possui demasiados recursos', 'A equipa possui recursos demais para a duração do projeto'),
    ('seed_produtividade_dificil_v2', 'O que significa identificar o caminho crítico de um projeto?', 0, 'Escolher as tarefas mais fáceis', 'Escolher as tarefas mais fáceis para que o projeto comece com resultados rápidos'),
    ('seed_produtividade_dificil_v2', 'O que significa identificar o caminho crítico de um projeto?', 1, 'Escolher o maior número de participantes', 'Escolher os participantes que terão a maior carga de trabalho no projeto'),
    ('seed_produtividade_dificil_v2', 'O que significa identificar o caminho crítico de um projeto?', 2, 'Eliminar atividades independentes', 'Eliminar as atividades independentes para reduzir o número de tarefas do projeto'),
    ('seed_produtividade_dificil_v2', 'Se uma atividade do caminho crítico atrasar e não houver margem, o que pode acontecer?', 0, 'A atividade deixa de ser necessária', 'A atividade pode deixar de ser necessária'),
    ('seed_produtividade_dificil_v2', 'Se uma atividade do caminho crítico atrasar e não houver margem, o que pode acontecer?', 1, 'O atraso desaparece', 'O atraso pode desaparecer com o passar do tempo'),
    ('seed_produtividade_dificil_v2', 'Se uma atividade do caminho crítico atrasar e não houver margem, o que pode acontecer?', 2, 'O projeto necessariamente termina antes', 'O projeto pode terminar antes do prazo previsto'),
    ('seed_produtividade_dificil_v2', 'Qual é a finalidade de uma retrospectiva de projeto?', 0, 'Evitar documentação', 'Evitar documentação para que a equipa não perca tempo a escrever'),
    ('seed_produtividade_dificil_v2', 'Qual é a finalidade de uma retrospectiva de projeto?', 1, 'Eliminar indicadores', 'Eliminar indicadores para que a equipa se concentre nas tarefas'),
    ('seed_produtividade_dificil_v2', 'Qual é a finalidade de uma retrospectiva de projeto?', 2, 'Repetir todas as decisões', 'Repetir as decisões tomadas no início do projeto para as confirmar'),
    ('seed_produtividade_dificil_v2', 'Uma retrospectiva identifica que reuniões longas foram responsáveis por atrasos recorrentes. Qual seria uma resposta baseada em evidências?', 0, 'Ignorar a descoberta', 'Ignorar a descoberta e manter as reuniões como estão'),
    ('seed_produtividade_dificil_v2', 'Uma retrospectiva identifica que reuniões longas foram responsáveis por atrasos recorrentes. Qual seria uma resposta baseada em evidências?', 1, 'Adicionar mais reuniões', 'Adicionar reuniões para discutir os atrasos recorrentes'),
    ('seed_produtividade_dificil_v2', 'Uma retrospectiva identifica que reuniões longas foram responsáveis por atrasos recorrentes. Qual seria uma resposta baseada em evidências?', 3, 'Aumentar a duração das reuniões', 'Aumentar a duração das reuniões para discutir os assuntos com mais calma'),
    ('seed_produtividade_dificil_v2', 'Por que testar uma melhoria antes de aplicá-la em toda a organização pode ser útil?', 0, 'Impede aprendizagem', 'Impede que a organização aprenda com os erros do teste'),
    ('seed_produtividade_dificil_v2', 'Por que testar uma melhoria antes de aplicá-la em toda a organização pode ser útil?', 2, 'Elimina qualquer necessidade de medição', 'Elimina a necessidade de medição depois da aplicação'),
    ('seed_produtividade_dificil_v2', 'Por que testar uma melhoria antes de aplicá-la em toda a organização pode ser útil?', 3, 'Garante que a melhoria funcionará', 'Garante que a melhoria terá o mesmo resultado na organização'),
    ('seed_produtividade_dificil_v2', 'Uma equipa implementa uma nova rotina e, após um mês, verifica que o desempenho piorou. Qual atitude é mais adequada?', 1, 'Manter a rotina obrigatoriamente', 'Manter a rotina por mais tempo, porque a mudança ainda precisa de ser aceite'),
    ('seed_produtividade_dificil_v2', 'Uma equipa implementa uma nova rotina e, após um mês, verifica que o desempenho piorou. Qual atitude é mais adequada?', 2, 'Ignorar os resultados', 'Ignorar os resultados do primeiro mês, porque ainda é cedo para concluir'),
    ('seed_produtividade_dificil_v2', 'Uma equipa implementa uma nova rotina e, após um mês, verifica que o desempenho piorou. Qual atitude é mais adequada?', 3, 'Aumentar a complexidade', 'Aumentar a complexidade da rotina para compensar a queda de desempenho'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma cultura de melhoria contínua?', 0, 'Evitar qualquer mudança', 'Evitar mudanças nos processos para preservar a estabilidade da equipa'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma cultura de melhoria contínua?', 2, 'Alterar processos constantemente sem medir resultados', 'Alterar os processos com frequência, sem medir os resultados obtidos'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma cultura de melhoria contínua?', 3, 'Utilizar sempre ferramentas novas', 'Adotar ferramentas novas para modernizar os processos e acompanhar as tendências do setor'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa trabalha melhor quando possui um objetivo claramente definido, mas recebe tarefas inesperadas constantemente. Qual solução pode equilibrar flexibilidade e foco?', 0, 'Cancelar todos os objetivos', 'Cancelar os objetivos para atender às novas tarefas'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa trabalha melhor quando possui um objetivo claramente definido, mas recebe tarefas inesperadas constantemente. Qual solução pode equilibrar flexibilidade e foco?', 1, 'Preencher cada minuto do calendário', 'Preencher o calendário com as tarefas previstas e urgentes'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa trabalha melhor quando possui um objetivo claramente definido, mas recebe tarefas inesperadas constantemente. Qual solução pode equilibrar flexibilidade e foco?', 3, 'Ignorar todas as novas tarefas', 'Ignorar as novas tarefas até terminar o objetivo atual'),
    ('seed_produtividade_dificil_v2', 'Qual é a principal função de uma margem de capacidade no planejamento?', 1, 'Garantir que o calendário fique completamente cheio', 'Garantir que o calendário seja preenchido com as tarefas mais importantes'),
    ('seed_produtividade_dificil_v2', 'Qual é a principal função de uma margem de capacidade no planejamento?', 2, 'Aumentar interrupções', 'Aumentar a tolerância a interrupções durante o dia de trabalho'),
    ('seed_produtividade_dificil_v2', 'Qual é a principal função de uma margem de capacidade no planejamento?', 3, 'Eliminar prioridades', 'Eliminar as prioridades menos urgentes do plano semanal'),
    ('seed_produtividade_dificil_v2', 'Uma equipa está sempre ocupada, mas os resultados estratégicos não melhoram. Qual diagnóstico deve ser considerado primeiro?', 0, 'Falta de tarefas', 'Falta de tarefas para ocupar a equipa durante o horário de trabalho'),
    ('seed_produtividade_dificil_v2', 'Uma equipa está sempre ocupada, mas os resultados estratégicos não melhoram. Qual diagnóstico deve ser considerado primeiro?', 1, 'Falta de reuniões', 'Falta de reuniões de acompanhamento com a equipa'),
    ('seed_produtividade_dificil_v2', 'Uma equipa está sempre ocupada, mas os resultados estratégicos não melhoram. Qual diagnóstico deve ser considerado primeiro?', 2, 'Excesso de ferramentas', 'Excesso de ferramentas disponíveis para a equipa'),
    ('seed_produtividade_dificil_v2', 'Qual pergunta melhor ajuda a identificar atividades de baixo valor?', 1, '"Quantas aplicações uso?"', '"Quantas aplicações uso para realizar esta atividade?"'),
    ('seed_produtividade_dificil_v2', 'Qual pergunta melhor ajuda a identificar atividades de baixo valor?', 2, '"Quantas mensagens recebi?"', '"Quantas mensagens recebi enquanto fazia esta atividade?"'),
    ('seed_produtividade_dificil_v2', 'Qual pergunta melhor ajuda a identificar atividades de baixo valor?', 3, '"Quanto tempo estou ocupado?"', '"Quanto tempo por dia estou ocupado a realizar esta atividade em concreto?"'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa continua executando manualmente uma tarefa porque "sempre foi assim". Qual princípio de produtividade deve ser aplicado?', 0, 'Adicionar etapas', 'Adicionar etapas ao processo para garantir que nada falha'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa continua executando manualmente uma tarefa porque "sempre foi assim". Qual princípio de produtividade deve ser aplicado?', 1, 'Aumentar o trabalho manual', 'Aumentar o trabalho manual para manter o controlo de cada fase do processo'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa continua executando manualmente uma tarefa porque "sempre foi assim". Qual princípio de produtividade deve ser aplicado?', 3, 'Nunca mudar processos', 'Manter o processo atual porque já foi testado no passado'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa desperdício de capacidade?', 0, 'Reservar tempo para descanso', 'Reservar tempo para descanso e recuperação durante o dia de trabalho, de acordo com a carga'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa desperdício de capacidade?', 1, 'Revisar resultados', 'Revisar os resultados do trabalho antes de passar à etapa seguinte'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa desperdício de capacidade?', 3, 'Planejar tarefas críticas', 'Planejar as tarefas críticas com antecedência e acompanhar o seu progresso'),
    ('seed_produtividade_dificil_v2', 'Uma organização possui excelentes planos, mas baixa execução. Qual fator pode explicar essa diferença?', 0, 'Excesso de clareza', 'Excesso de clareza nos planos, que limita a flexibilidade da equipa'),
    ('seed_produtividade_dificil_v2', 'Uma organização possui excelentes planos, mas baixa execução. Qual fator pode explicar essa diferença?', 1, 'Planejamento demasiado simples', 'Planejamento demasiado simples, sem detalhe sobre as tarefas futuras'),
    ('seed_produtividade_dificil_v2', 'Uma organização possui excelentes planos, mas baixa execução. Qual fator pode explicar essa diferença?', 2, 'Excesso de objetivos mensuráveis', 'Excesso de objetivos mensuráveis em cada área da organização'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 1, 'Apenas uma lista de desejos', 'Uma lista de metas gerais definidas pela direção da organização'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 2, 'Mais tarefas', 'Mais tarefas e mais reuniões de planeamento'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 3, 'Menos informação', 'Menos informação e menos detalhe nos planos'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa termina uma tarefa e imediatamente começa outra sem verificar se o resultado atende aos critérios definidos. Qual risco aumenta?', 1, 'Maior clareza', 'Maior clareza sobre o estado das tarefas'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa termina uma tarefa e imediatamente começa outra sem verificar se o resultado atende aos critérios definidos. Qual risco aumenta?', 2, 'Melhor validação', 'Melhor validação dos resultados entregues ao cliente no fim do projeto'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa termina uma tarefa e imediatamente começa outra sem verificar se o resultado atende aos critérios definidos. Qual risco aumenta?', 3, 'Redução de retrabalho', 'Redução do retrabalho nas fases seguintes'),
    ('seed_produtividade_dificil_v2', 'Qual etapa deve ocorrer antes de considerar uma entrega concluída em um processo que exige qualidade?', 0, 'Início de outra tarefa', 'Início da tarefa seguinte do plano'),
    ('seed_produtividade_dificil_v2', 'Qual etapa deve ocorrer antes de considerar uma entrega concluída em um processo que exige qualidade?', 1, 'Criação de uma nova prioridade', 'Criação de uma nova prioridade para a equipa'),
    ('seed_produtividade_dificil_v2', 'Qual etapa deve ocorrer antes de considerar uma entrega concluída em um processo que exige qualidade?', 3, 'Eliminação dos registros', 'Eliminação dos registros do trabalho feito'),
    ('seed_produtividade_dificil_v2', 'Um projeto apresenta muitas revisões porque os requisitos mudam constantemente. Qual medida pode reduzir retrabalho?', 0, 'Evitar comunicação', 'Evitar comunicação com o cliente para reduzir o número de pedidos'),
    ('seed_produtividade_dificil_v2', 'Um projeto apresenta muitas revisões porque os requisitos mudam constantemente. Qual medida pode reduzir retrabalho?', 1, 'Aumentar o número de versões sem controle', 'Aumentar o número de versões entregues para o cliente escolher'),
    ('seed_produtividade_dificil_v2', 'Um projeto apresenta muitas revisões porque os requisitos mudam constantemente. Qual medida pode reduzir retrabalho?', 2, 'Fazer mais trabalho sem requisitos', 'Começar a execução sem requisitos fechados e corrigir ao longo do trabalho'),
    ('seed_produtividade_dificil_v2', 'Qual é uma consequência direta de requisitos pouco claros?', 1, 'Maior previsibilidade', 'Maior previsibilidade dos prazos'),
    ('seed_produtividade_dificil_v2', 'Qual é uma consequência direta de requisitos pouco claros?', 2, 'Redução automática dos custos', 'Redução dos custos de comunicação'),
    ('seed_produtividade_dificil_v2', 'Qual é uma consequência direta de requisitos pouco claros?', 3, 'Menor necessidade de comunicação', 'Menor necessidade de comunicação entre os membros da equipa'),
    ('seed_produtividade_dificil_v3', 'O que é a técnica de time blocking?', 0, 'Impedir qualquer interrupção permanentemente', 'Impedir interrupções externas durante o horário de trabalho para proteger o foco da equipa'),
    ('seed_produtividade_dificil_v3', 'O que é a técnica de time blocking?', 1, 'Trabalhar sem qualquer planejamento de horário', 'Trabalhar sem planejamento de horário, escolhendo as tarefas conforme o ânimo do dia'),
    ('seed_produtividade_dificil_v3', 'O que é a técnica de time blocking?', 3, 'Dividir uma equipa em vários turnos aleatórios', 'Dividir a equipa em turnos de trabalho com horários diferentes para cada pessoa')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade difícil lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
