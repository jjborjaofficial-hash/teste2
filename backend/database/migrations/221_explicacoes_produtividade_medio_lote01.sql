-- Explicações pedagógicas (BE-004) — Produtividade médio lote 1: perguntas 1 a 25 do seed médio v1 (migration 043).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 220. Só atualiza perguntas
-- que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não impedir o arranque
-- do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_medio_v1', 'O que é a matriz de Eisenhower?', 'A matriz de Eisenhower classifica as tarefas por urgência e importância, o que mostra o que fazer já, o que agendar, o que delegar e o que descartar. Ajuda a não confundir o que é urgente com o que realmente importa.'),
    ('seed_produtividade_medio_v1', 'O que é planejamento semanal?', 'O planejamento semanal organiza as principais tarefas e compromissos da semana, de forma a distribuir o trabalho pelos dias. Olha para a frente, e não para o que já foi feito.'),
    ('seed_produtividade_medio_v1', 'Qual é a vantagem de dividir um projeto grande em etapas?', 'Dividir um projeto grande em etapas torna o progresso mais fácil de acompanhar e administrar, porque cada etapa concluída mostra o avanço. Também deixa o começo menos pesado.'),
    ('seed_produtividade_medio_v1', 'O que é uma tarefa prioritária?', 'Uma tarefa prioritária merece atenção antes das outras por causa da sua importância ou urgência, e não por ser fácil, rápida ou aleatória. Priorizar é escolher pelo impacto.'),
    ('seed_produtividade_medio_v1', 'O que é time blocking?', 'Time blocking é reservar blocos específicos de tempo na agenda para determinadas atividades. Assim cada tarefa tem o seu momento e o tempo importante fica protegido.'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem do time blocking?', 'O time blocking ajuda a proteger períodos de foco para tarefas específicas, porque o tempo fica reservado. Não elimina todas as distrações nem impede mudanças, mas torna o foco mais fácil de defender.'),
    ('seed_produtividade_medio_v1', 'O que é multitarefa?', 'Multitarefa é tentar lidar com várias atividades ao mesmo tempo ou alterná-las depressa. É o contrário de fazer uma única atividade até ao fim.'),
    ('seed_produtividade_medio_v1', 'Por que a multitarefa pode prejudicar algumas atividades cognitivas?', 'Alternar a atenção com frequência obriga o cérebro a recomeçar o raciocínio a cada troca, o que pode aumentar erros e reduzir a eficiência. Por isso muitas atividades que exigem raciocínio rendem menos em multitarefa.'),
    ('seed_produtividade_medio_v1', 'O que é batching de tarefas?', 'Batching é agrupar tarefas semelhantes para as realizar em conjunto, por exemplo responder e-mails todos de uma vez. Assim a mente mantém o mesmo modo de trabalho.'),
    ('seed_produtividade_medio_v1', 'Qual é um benefício do batching?', 'O batching pode reduzir o custo de alternância entre tipos de atividade, porque a pessoa passa várias tarefas parecidas seguidas em vez de saltar entre tipos diferentes. Não garante ausência de erros nem elimina pausas.'),
    ('seed_produtividade_medio_v1', 'O que é a técnica Pomodoro?', 'A técnica Pomodoro alterna períodos de trabalho focado, em geral 25 minutos, com pausas curtas. O nome vem do cronómetro de cozinha em forma de tomate.'),
    ('seed_produtividade_medio_v1', 'Qual é a finalidade principal das pausas na técnica Pomodoro?', 'As pausas do Pomodoro servem para recuperar a atenção durante os ciclos de trabalho: a mente descansa e o foco volta mais forte. Não substituem metas nem aumentam distrações.'),
    ('seed_produtividade_medio_v1', 'O que é delegação?', 'Delegar é transferir uma tarefa ou responsabilidade para outra pessoa, quando é apropriado, por exemplo quando ela tem mais competência ou tempo. Não é adiar, cancelar ou fazer tudo sozinho.'),
    ('seed_produtividade_medio_v1', 'Por que delegar pode aumentar a produtividade?', 'Delegar pode aumentar a produtividade porque cada pessoa se concentra em atividades adequadas às suas responsabilidades e competências. O trabalho não desaparece nem dispensa acompanhamento: apenas é distribuído.'),
    ('seed_produtividade_medio_v1', 'O que é uma interrupção?', 'Uma interrupção é um evento que quebra o fluxo de atenção durante uma atividade, como uma chamada ou uma mensagem. Depois dela, voltar ao ponto onde se estava custa tempo e esforço.'),
    ('seed_produtividade_medio_v1', 'Por que notificações podem prejudicar o foco?', 'As notificações podem interromper a atenção e incentivar a mudança frequente de atividade, o que quebra o foco. Mesmo uma olhada rápida obriga a mente a trocar de contexto.'),
    ('seed_produtividade_medio_v1', 'O que significa dizer "não" de forma produtiva?', 'Dizer "não" de forma produtiva é recusar o que não se encaixa nas prioridades quando é necessário, para ter tempo para o que importa. Não é recusar tudo nem fugir das responsabilidades.'),
    ('seed_produtividade_medio_v1', 'O que é uma revisão semanal?', 'A revisão semanal é o momento para analisar o que foi feito, o que ficou pendente e o que precisa ser planejado. Ajuda a corrigir o rumo antes que os atrasos se acumulem.'),
    ('seed_produtividade_medio_v1', 'Qual é uma vantagem de revisar tarefas pendentes?', 'Revisar as tarefas pendentes permite reorganizar as prioridades e evitar que obrigações sejam esquecidas. Não torna as tarefas fáceis nem impede o surgimento de novas.'),
    ('seed_produtividade_medio_v1', 'O que é planejamento reverso?', 'No planejamento reverso começa-se pelo resultado ou pelo prazo final e define-se, de trás para a frente, as etapas necessárias. Assim sabe-se até quando cada passo deve estar pronto.'),
    ('seed_produtividade_medio_v1', 'Por que definir prazos intermediários pode ser útil?', 'Prazos intermediários ajudam a acompanhar o progresso antes do prazo final, e permitem corrigir o rumo a tempo. Sem eles, o atraso só se vê no fim.'),
    ('seed_produtividade_medio_v1', 'O que é custo de alternância de tarefas?', 'O custo de alternância é o tempo e o esforço mental gastos ao mudar de uma atividade para outra: é preciso largar o raciocínio anterior e retomar o novo. Por isso trocar de tarefa a toda a hora cansa e atrasa.'),
    ('seed_produtividade_medio_v1', 'O que é ambiente de trabalho favorável à concentração?', 'Um ambiente favorável à concentração reduz interrupções e deixa o necessário para a tarefa ao alcance, para a atenção não se desviar. Notificações, desordem e distrações fazem o contrário.'),
    ('seed_produtividade_medio_v1', 'Qual estratégia pode reduzir distrações digitais?', 'Desativar as notificações não essenciais durante os períodos de foco evita interrupções e mudanças de contexto. Abrir redes sociais ou ter vários aplicativos ativos faz perder a concentração.'),
    ('seed_produtividade_medio_v1', 'O que é gestão de energia?', 'Gestão de energia, na produtividade, é organizar as atividades considerando os períodos de maior e menor disposição: tarefas exigentes quando se rende mais, tarefas leves quando se rende menos. Não tem a ver com eletricidade nem dinheiro.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
