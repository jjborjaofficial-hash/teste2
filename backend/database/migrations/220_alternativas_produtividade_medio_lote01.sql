-- Alternativas (BE-003, regularização) — Produtividade médio lote 1: perguntas 1 a 25 do seed médio v1 (migration 043).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (médio: migrations 220 e 221) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_medio_v1', 'O que é a matriz de Eisenhower?', 0, 'Método financeiro', 'Método que classifica as despesas principalmente por valor e por prazo de pagamento'),
    ('seed_produtividade_medio_v1', 'O que é a matriz de Eisenhower?', 2, 'Técnica exclusiva de memorização', 'Técnica que organiza as ideias principalmente por associação e por repetição'),
    ('seed_produtividade_medio_v1', 'O que é a matriz de Eisenhower?', 3, 'Aplicativo de mensagens', 'Aplicativo que organiza as mensagens principalmente por data e por remetente'),
    ('seed_produtividade_medio_v1', 'O que é planejamento semanal?', 0, 'Registro de despesas', 'Registro das principais despesas e dos pagamentos previstos para uma semana'),
    ('seed_produtividade_medio_v1', 'O que é planejamento semanal?', 1, 'Lista de tarefas feitas no passado', 'Lista das tarefas feitas e dos compromissos cumpridos na semana anterior'),
    ('seed_produtividade_medio_v1', 'O que é planejamento semanal?', 3, 'Organização exclusiva das férias', 'Organização das atividades e dos compromissos de um período de férias'),
    ('seed_produtividade_medio_v1', 'Qual é a vantagem de dividir um projeto grande em etapas?', 0, 'Aumenta obrigatoriamente a complexidade', 'Aumenta a complexidade e o número de tarefas que precisam de ser feitas'),
    ('seed_produtividade_medio_v1', 'Qual é a vantagem de dividir um projeto grande em etapas?', 1, 'Elimina a necessidade de execução', 'Elimina a necessidade de planejar o trabalho de cada etapa'),
    ('seed_produtividade_medio_v1', 'Qual é a vantagem de dividir um projeto grande em etapas?', 3, 'Impede mudanças', 'Impede mudanças no projeto depois de definidas as etapas'),
    ('seed_produtividade_medio_v1', 'O que é uma tarefa prioritária?', 0, 'Sempre a tarefa mais fácil', 'Tarefa que merece atenção antes de outras por ser a mais fácil de concluir'),
    ('seed_produtividade_medio_v1', 'O que é uma tarefa prioritária?', 2, 'Qualquer tarefa aleatória', 'Tarefa escolhida ao acaso entre as pendentes, sem critério de importância'),
    ('seed_produtividade_medio_v1', 'O que é uma tarefa prioritária?', 3, 'Sempre a tarefa mais rápida', 'Tarefa que demora menos tempo para ser concluída durante o dia'),
    ('seed_produtividade_medio_v1', 'O que é time blocking?', 0, 'Sistema de bloqueio de contas', 'Sistema de bloqueio de contas que impede o acesso a aplicativos durante o trabalho'),
    ('seed_produtividade_medio_v1', 'O que é time blocking?', 2, 'Método para eliminar calendários', 'Método para eliminar o uso de calendários e organizar as tarefas por listas'),
    ('seed_produtividade_medio_v1', 'O que é time blocking?', 3, 'Técnica de trabalhar sem horários', 'Técnica de trabalhar sem horários fixos, escolhendo as tarefas conforme o ânimo'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem do time blocking?', 0, 'Elimina todas as distrações automaticamente', 'Reduz o tempo gasto com reuniões e mensagens do dia'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem do time blocking?', 1, 'Garante que nenhuma tarefa será interrompida', 'Permite concluir as tarefas mais depressa, sem planejamento prévio'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem do time blocking?', 3, 'Impede qualquer mudança no planejamento', 'Facilita a mudança frequente de tarefa ao longo do dia'),
    ('seed_produtividade_medio_v1', 'O que é multitarefa?', 1, 'Planejamento semanal', 'Planejamento das atividades de várias semanas de trabalho em sequência'),
    ('seed_produtividade_medio_v1', 'O que é multitarefa?', 2, 'Realização de uma única atividade', 'Realização de uma única atividade até ao fim, antes de começar outra'),
    ('seed_produtividade_medio_v1', 'O que é multitarefa?', 3, 'Período de descanso', 'Período de descanso entre atividades, usado para recuperar a atenção'),
    ('seed_produtividade_medio_v1', 'Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 0, 'Porque sempre aumenta a concentração', 'A divisão do tempo entre tarefas pode aumentar a concentração e reduzir erros'),
    ('seed_produtividade_medio_v1', 'Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 1, 'Porque torna qualquer atividade impossível', 'A mudança de atividade pode tornar o trabalho mais rápido e reduzir o esforço'),
    ('seed_produtividade_medio_v1', 'Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 3, 'Porque elimina a necessidade de foco', 'A necessidade de foco pode desaparecer quando se alterna entre tarefas'),
    ('seed_produtividade_medio_v1', 'O que é batching de tarefas?', 1, 'Dividir cada tarefa em milhares de partes', 'Dividir cada tarefa em partes pequenas para serem feitas em dias diferentes'),
    ('seed_produtividade_medio_v1', 'O que é batching de tarefas?', 2, 'Fazer todas as tarefas aleatoriamente', 'Fazer as tarefas pela ordem em que chegam, sem as agrupar'),
    ('seed_produtividade_medio_v1', 'O que é batching de tarefas?', 3, 'Cancelar tarefas repetitivas', 'Cancelar as tarefas repetitivas para reduzir a carga de trabalho'),
    ('seed_produtividade_medio_v1', 'Qual é um benefício do batching?', 0, 'Garante que nenhuma tarefa terá erros', 'Pode aumentar a velocidade de resposta a mensagens e a pedidos urgentes'),
    ('seed_produtividade_medio_v1', 'Qual é um benefício do batching?', 1, 'Elimina todas as pausas', 'Pode eliminar a necessidade de pausas durante o trabalho concentrado'),
    ('seed_produtividade_medio_v1', 'Qual é um benefício do batching?', 2, 'Impede planejamento', 'Pode dispensar o planejamento das tarefas semelhantes do dia'),
    ('seed_produtividade_medio_v1', 'O que é a técnica Pomodoro?', 1, 'Técnica de vendas', 'Método que alterna períodos de vendas com visitas a clientes'),
    ('seed_produtividade_medio_v1', 'O que é a técnica Pomodoro?', 2, 'Sistema bancário', 'Sistema que alterna períodos de pagamento com períodos de recebimento'),
    ('seed_produtividade_medio_v1', 'O que é a técnica Pomodoro?', 3, 'Aplicativo de edição de vídeo', 'Aplicativo que alterna cenas de vídeo com efeitos durante a edição'),
    ('seed_produtividade_medio_v1', 'Qual é a finalidade principal das pausas na técnica Pomodoro?', 1, 'Substituir as metas', 'Substituir as metas definidas para cada ciclo de trabalho'),
    ('seed_produtividade_medio_v1', 'Qual é a finalidade principal das pausas na técnica Pomodoro?', 2, 'Aumentar as distrações', 'Aumentar as distrações permitidas durante cada ciclo de trabalho'),
    ('seed_produtividade_medio_v1', 'Qual é a finalidade principal das pausas na técnica Pomodoro?', 3, 'Evitar qualquer trabalho', 'Evitar o trabalho nos períodos mais difíceis do dia'),
    ('seed_produtividade_medio_v1', 'O que é delegação?', 0, 'Adiar uma tarefa', 'Adiar uma tarefa ou responsabilidade para outro dia quando for conveniente'),
    ('seed_produtividade_medio_v1', 'O que é delegação?', 1, 'Cancelar um projeto', 'Cancelar uma tarefa ou responsabilidade quando houver pouco tempo disponível'),
    ('seed_produtividade_medio_v1', 'O que é delegação?', 2, 'Fazer todas as tarefas sozinho', 'Fazer uma tarefa ou responsabilidade sozinho para garantir a sua qualidade'),
    ('seed_produtividade_medio_v1', 'Por que delegar pode aumentar a produtividade?', 0, 'Porque garante que todas as tarefas sejam feitas perfeitamente', 'Pode permitir que as tarefas sejam feitas sem supervisão, porque cada pessoa trabalha à sua maneira'),
    ('seed_produtividade_medio_v1', 'Por que delegar pode aumentar a produtividade?', 1, 'Porque elimina todo o trabalho', 'Pode reduzir a quantidade de trabalho total do projeto, porque as tarefas passam a ser de outra pessoa da equipa'),
    ('seed_produtividade_medio_v1', 'Por que delegar pode aumentar a produtividade?', 2, 'Porque ninguém precisa supervisionar', 'Pode permitir que o responsável pelo projeto deixe de acompanhar o andamento das tarefas entregues'),
    ('seed_produtividade_medio_v1', 'O que é uma interrupção?', 1, 'Uma tarefa concluída', 'Tarefa concluída que interrompe o ritmo de trabalho da equipa'),
    ('seed_produtividade_medio_v1', 'O que é uma interrupção?', 2, 'Um planejamento', 'Planejamento feito durante uma atividade para organizar o tempo'),
    ('seed_produtividade_medio_v1', 'O que é uma interrupção?', 3, 'Uma meta', 'Meta definida durante uma atividade para orientar o resultado'),
    ('seed_produtividade_medio_v1', 'Por que notificações podem prejudicar o foco?', 0, 'Porque eliminam todas as tarefas', 'Podem eliminar as tarefas pendentes e reduzir a carga de trabalho do dia'),
    ('seed_produtividade_medio_v1', 'Por que notificações podem prejudicar o foco?', 2, 'Porque melhoram qualquer trabalho', 'Podem melhorar o desempenho e aumentar a velocidade de resposta da pessoa'),
    ('seed_produtividade_medio_v1', 'Por que notificações podem prejudicar o foco?', 3, 'Porque aumentam automaticamente a concentração', 'Podem reforçar a concentração e ajudar a manter o ritmo de trabalho'),
    ('seed_produtividade_medio_v1', 'O que significa dizer "não" de forma produtiva?', 0, 'Evitar toda colaboração', 'Evitar a colaboração com colegas para concluir o trabalho mais depressa'),
    ('seed_produtividade_medio_v1', 'O que significa dizer "não" de forma produtiva?', 1, 'Nunca ajudar ninguém', 'Recusar ajudar os outros para evitar perder tempo com os seus pedidos'),
    ('seed_produtividade_medio_v1', 'O que significa dizer "não" de forma produtiva?', 2, 'Recusar qualquer responsabilidade', 'Recusar responsabilidades novas, mesmo quando fazem parte do seu trabalho'),
    ('seed_produtividade_medio_v1', 'O que é uma revisão semanal?', 0, 'Um método de estudo', 'Momento para estudar os conteúdos da semana e preparar as provas seguintes'),
    ('seed_produtividade_medio_v1', 'O que é uma revisão semanal?', 1, 'Período sem trabalho', 'Período da semana sem trabalho, usado para descansar e recuperar energia'),
    ('seed_produtividade_medio_v1', 'O que é uma revisão semanal?', 3, 'Exclusivamente uma reunião financeira', 'Reunião para analisar as contas, os pagamentos pendentes e o orçamento da semana'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem de revisar tarefas pendentes?', 0, 'Garante que todas sejam fáceis', 'Permite escolher as tarefas mais fáceis e adiar as mais difíceis para depois'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem de revisar tarefas pendentes?', 1, 'Elimina prazos', 'Permite eliminar os prazos das tarefas que estão em atraso no momento'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem de revisar tarefas pendentes?', 2, 'Impede novas tarefas', 'Permite impedir que novas tarefas entrem na lista de pendentes'),
    ('seed_produtividade_medio_v1', 'O que é planejamento reverso?', 1, 'Fazer tarefas aleatoriamente', 'Começar pela primeira etapa e definir o prazo final só no fim do projeto'),
    ('seed_produtividade_medio_v1', 'O que é planejamento reverso?', 2, 'Ignorar o prazo final', 'Começar pelo resultado intermédio e deixar o prazo final em aberto no início'),
    ('seed_produtividade_medio_v1', 'O que é planejamento reverso?', 3, 'Trabalhar sem objetivo', 'Começar pelas tarefas mais simples e definir o objetivo depois de concluí-las'),
    ('seed_produtividade_medio_v1', 'Por que definir prazos intermediários pode ser útil?', 1, 'Torna todos os projetos menores', 'Torna os projetos mais curtos ao reduzir o número de tarefas'),
    ('seed_produtividade_medio_v1', 'Por que definir prazos intermediários pode ser útil?', 2, 'Elimina a necessidade de trabalhar', 'Elimina a necessidade de revisar o trabalho antes do prazo'),
    ('seed_produtividade_medio_v1', 'Por que definir prazos intermediários pode ser útil?', 3, 'Impede ajustes', 'Impede ajustes no plano depois de definidos os prazos'),
    ('seed_produtividade_medio_v1', 'O que é custo de alternância de tarefas?', 0, 'Custo financeiro obrigatório', 'Custo financeiro envolvido ao mudar de fornecedor ou de ferramenta de trabalho'),
    ('seed_produtividade_medio_v1', 'O que é custo de alternância de tarefas?', 1, 'Tempo de descanso', 'Tempo de descanso necessário ao mudar de uma atividade para outra'),
    ('seed_produtividade_medio_v1', 'O que é custo de alternância de tarefas?', 2, 'Valor de uma ferramenta', 'Valor pago por uma ferramenta ao mudar de plano de assinatura'),
    ('seed_produtividade_medio_v1', 'O que é ambiente de trabalho favorável à concentração?', 0, 'Ambiente cheio de notificações', 'Ambiente que aumenta as notificações e facilita o contacto com os colegas'),
    ('seed_produtividade_medio_v1', 'O que é ambiente de trabalho favorável à concentração?', 2, 'Ambiente sem organização', 'Ambiente que dispensa a organização e deixa os materiais espalhados na mesa'),
    ('seed_produtividade_medio_v1', 'O que é ambiente de trabalho favorável à concentração?', 3, 'Ambiente com várias distrações', 'Ambiente que oferece várias distrações e atividades alternativas durante a tarefa'),
    ('seed_produtividade_medio_v1', 'Qual estratégia pode reduzir distrações digitais?', 0, 'Abrir todas as redes sociais', 'Abrir as redes sociais durante os períodos de foco para relaxar'),
    ('seed_produtividade_medio_v1', 'Qual estratégia pode reduzir distrações digitais?', 2, 'Ativar todas as notificações', 'Ativar as notificações dos aplicativos durante os períodos de foco'),
    ('seed_produtividade_medio_v1', 'Qual estratégia pode reduzir distrações digitais?', 3, 'Usar vários aplicativos simultaneamente', 'Usar vários aplicativos ao mesmo tempo durante os períodos de foco'),
    ('seed_produtividade_medio_v1', 'O que é gestão de energia?', 0, 'Uso de redes sociais', 'Uso de redes sociais para recuperar a energia entre as atividades do dia'),
    ('seed_produtividade_medio_v1', 'O que é gestão de energia?', 2, 'Apenas controle financeiro', 'Controle financeiro dos gastos com energia elétrica e combustível do mês'),
    ('seed_produtividade_medio_v1', 'O que é gestão de energia?', 3, 'Gestão da eletricidade de uma casa', 'Gestão do consumo de eletricidade de uma casa ao longo do mês')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
