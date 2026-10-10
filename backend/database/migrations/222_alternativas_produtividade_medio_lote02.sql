-- Alternativas (BE-003, regularização) — Produtividade médio lote 2: v1#26 a v1#30, v2 (5) e as 15 primeiras do v3 do seed médio (migrations 043, 052 e 082).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (médio: migrations 222 e 223) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_medio_v1', 'Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 0, 'Porque elimina a necessidade de descanso', 'Pode eliminar a necessidade de descanso durante o dia de trabalho'),
    ('seed_produtividade_medio_v1', 'Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 1, 'Porque tarefas complexas ficam sempre fáceis', 'Pode tornar as tarefas complexas mais fáceis de concluir em menos tempo'),
    ('seed_produtividade_medio_v1', 'Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 3, 'Porque reduz automaticamente o prazo', 'Pode reduzir o prazo da tarefa sem alterar o esforço necessário'),
    ('seed_produtividade_medio_v1', 'O que significa estimar o tempo de uma tarefa?', 0, 'Cancelar a tarefa', 'Calcular aproximadamente quanto dinheiro será necessário para concluí-la'),
    ('seed_produtividade_medio_v1', 'O que significa estimar o tempo de uma tarefa?', 1, 'Fazer a tarefa sem planejamento', 'Fazer a tarefa rapidamente, sem pensar no tempo que vai demorar'),
    ('seed_produtividade_medio_v1', 'O que significa estimar o tempo de uma tarefa?', 2, 'Definir seu preço', 'Definir o preço que será cobrado pela realização da tarefa'),
    ('seed_produtividade_medio_v1', 'Por que registrar o tempo real gasto em tarefas pode ser útil?', 1, 'Elimina atrasos automaticamente', 'Evita atrasos nas tarefas em andamento'),
    ('seed_produtividade_medio_v1', 'Por que registrar o tempo real gasto em tarefas pode ser útil?', 2, 'Reduz todas as tarefas', 'Reduz o número de tarefas da semana'),
    ('seed_produtividade_medio_v1', 'Por que registrar o tempo real gasto em tarefas pode ser útil?', 3, 'Garante produtividade máxima', 'Aumenta a produtividade do dia seguinte'),
    ('seed_produtividade_medio_v1', 'O que é margem de tempo em um planejamento?', 0, 'Tempo desperdiçado obrigatoriamente', 'Tempo perdido entre uma tarefa e outra do planejamento'),
    ('seed_produtividade_medio_v1', 'O que é margem de tempo em um planejamento?', 2, 'Tempo sem finalidade', 'Tempo sem finalidade definida dentro do planejamento do dia'),
    ('seed_produtividade_medio_v1', 'O que é margem de tempo em um planejamento?', 3, 'Tempo usado apenas para redes sociais', 'Tempo reservado para pausas de lazer e redes sociais'),
    ('seed_produtividade_medio_v2', 'O que significa delegar uma tarefa?', 1, 'Ignorá-la', 'Ignorá-la até que alguém se lembre de a executar'),
    ('seed_produtividade_medio_v2', 'O que significa delegar uma tarefa?', 2, 'Fazer duas vezes', 'Fazê-la duas vezes para garantir a sua qualidade'),
    ('seed_produtividade_medio_v2', 'O que significa delegar uma tarefa?', 3, 'Apagá-la', 'Apagá-la da lista quando houver muitas pendentes'),
    ('seed_produtividade_medio_v2', 'Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 1, 'Sempre reduz o tempo', 'Pode reduzir o tempo total gasto nas tarefas'),
    ('seed_produtividade_medio_v2', 'Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 2, 'Garante maior qualidade', 'Pode aumentar a qualidade do resultado final'),
    ('seed_produtividade_medio_v2', 'Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 3, 'Elimina erros', 'Pode eliminar os erros das tarefas em andamento'),
    ('seed_produtividade_medio_v2', 'O que é uma deadline?', 0, 'Horário de almoço', 'Horário limite para o intervalo de almoço'),
    ('seed_produtividade_medio_v2', 'O que é uma deadline?', 1, 'Início de uma tarefa', 'Data prevista para o início de uma tarefa'),
    ('seed_produtividade_medio_v2', 'O que é uma deadline?', 3, 'Data de pagamento exclusivamente', 'Data limite para o pagamento de uma fatura'),
    ('seed_produtividade_medio_v2', 'O que significa automatizar uma tarefa?', 0, 'Transferir a tarefa sem autorização', 'Transferir a tarefa para outra pessoa sem pedir autorização do responsável'),
    ('seed_produtividade_medio_v2', 'O que significa automatizar uma tarefa?', 2, 'Fazer tudo manualmente', 'Fazer a atividade manualmente, passo a passo, sem usar ferramentas ou sistemas'),
    ('seed_produtividade_medio_v2', 'O que significa automatizar uma tarefa?', 3, 'Apagar a tarefa', 'Apagar a tarefa do sistema para que deixe de ser executada pela equipa'),
    ('seed_produtividade_medio_v2', 'Por que estabelecer prioridades pode melhorar o uso do tempo?', 0, 'Faz o dia ficar maior', 'Ajuda a aumentar o número de horas disponíveis no dia'),
    ('seed_produtividade_medio_v2', 'Por que estabelecer prioridades pode melhorar o uso do tempo?', 1, 'Garante sucesso imediato', 'Ajuda a obter resultados imediatos nas tarefas do dia'),
    ('seed_produtividade_medio_v2', 'Por que estabelecer prioridades pode melhorar o uso do tempo?', 2, 'Elimina todas as tarefas', 'Ajuda a eliminar as tarefas que a equipa não gosta de fazer'),
    ('seed_produtividade_medio_v3', 'Qual é uma das principais finalidades da gestão do tempo?', 0, 'Evitar qualquer período de descanso', 'Utilizar o tempo para evitar períodos de descanso durante o trabalho'),
    ('seed_produtividade_medio_v3', 'Qual é uma das principais finalidades da gestão do tempo?', 1, 'Fazer várias tarefas simultaneamente', 'Utilizar o tempo para fazer várias tarefas ao mesmo tempo'),
    ('seed_produtividade_medio_v3', 'Qual é uma das principais finalidades da gestão do tempo?', 2, 'Preencher todo o dia com tarefas', 'Utilizar o tempo para preencher a agenda com o máximo de tarefas'),
    ('seed_produtividade_medio_v3', 'Qual é o principal objetivo da técnica Pomodoro?', 0, 'Eliminar todas as tarefas difíceis', 'Eliminar as tarefas difíceis para trabalhar em períodos mais leves'),
    ('seed_produtividade_medio_v3', 'Qual é o principal objetivo da técnica Pomodoro?', 2, 'Trabalhar continuamente sem pausas', 'Trabalhar em períodos longos, com pausas só quando o corpo pedir'),
    ('seed_produtividade_medio_v3', 'Qual é o principal objetivo da técnica Pomodoro?', 3, 'Fazer várias tarefas simultaneamente', 'Fazer várias tarefas em simultâneo durante períodos de trabalho'),
    ('seed_produtividade_medio_v3', 'O que caracteriza a procrastinação?', 1, 'Planejamento antecipado', 'Planejamento antecipado de tarefas relevantes'),
    ('seed_produtividade_medio_v3', 'O que caracteriza a procrastinação?', 2, 'Organização das prioridades', 'Organização das prioridades das tarefas relevantes'),
    ('seed_produtividade_medio_v3', 'O que caracteriza a procrastinação?', 3, 'Delegação eficiente', 'Delegação eficiente de tarefas relevantes'),
    ('seed_produtividade_medio_v3', 'Qual estratégia pode ajudar a combater a procrastinação?', 1, 'Esperar sempre pela motivação perfeita', 'Esperar pela motivação perfeita antes de começar'),
    ('seed_produtividade_medio_v3', 'Qual estratégia pode ajudar a combater a procrastinação?', 2, 'Adiar tarefas difíceis', 'Adiar as tarefas difíceis para o fim do dia'),
    ('seed_produtividade_medio_v3', 'Qual estratégia pode ajudar a combater a procrastinação?', 3, 'Trabalhar sem planejamento', 'Trabalhar sem planejamento, só quando houver vontade'),
    ('seed_produtividade_medio_v3', 'O que é uma meta SMART?', 0, 'Uma meta necessariamente financeira', 'Uma meta simples, motivadora, ambiciosa, rápida e tecnicamente detalhada'),
    ('seed_produtividade_medio_v3', 'O que é uma meta SMART?', 1, 'Uma meta sem prazo', 'Uma meta específica, mensurável e relevante, mas sem prazo definido'),
    ('seed_produtividade_medio_v3', 'O que é uma meta SMART?', 3, 'Uma meta baseada apenas em desejos', 'Uma meta baseada em desejos, sem medidas nem critérios de avaliação'),
    ('seed_produtividade_medio_v3', 'Por que estabelecer prazos realistas melhora a produtividade?', 0, 'Porque elimina a necessidade de prioridades', 'Porque dispensa a definição de prioridades entre as tarefas'),
    ('seed_produtividade_medio_v3', 'Por que estabelecer prazos realistas melhora a produtividade?', 1, 'Porque permite aceitar qualquer quantidade de tarefas', 'Porque permite aceitar um maior volume de tarefas na semana'),
    ('seed_produtividade_medio_v3', 'Por que estabelecer prazos realistas melhora a produtividade?', 2, 'Porque elimina todas as dificuldades', 'Porque reduz as dificuldades que surgem durante o trabalho'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de definir as três principais prioridades do dia?', 0, 'Garantir que nenhuma tarefa seja concluída', 'Garantir que as tarefas menores sejam concluídas primeiro'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de definir as três principais prioridades do dia?', 2, 'Eliminar a necessidade de planejamento', 'Eliminar a necessidade de revisar o planejamento semanal'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de definir as três principais prioridades do dia?', 3, 'Aumentar propositalmente a carga de trabalho', 'Aumentar a carga de trabalho para ganhar produtividade'),
    ('seed_produtividade_medio_v3', 'Por que a multitarefa pode reduzir a produtividade?', 1, 'Porque impede qualquer comunicação', 'Porque a divisão do tempo entre tarefas pode gerar custos financeiros e perda de prazos'),
    ('seed_produtividade_medio_v3', 'Por que a multitarefa pode reduzir a produtividade?', 2, 'Porque elimina a necessidade de concentração', 'Porque a repetição frequente das mesmas tarefas pode gerar tédio e perda de motivação'),
    ('seed_produtividade_medio_v3', 'Por que a multitarefa pode reduzir a produtividade?', 3, 'Porque reduz automaticamente o número de tarefas', 'Porque a redução frequente do número de tarefas pode gerar atrasos e perda de clientes'),
    ('seed_produtividade_medio_v3', 'O que é monotarefa?', 0, 'Delegar todas as responsabilidades', 'Delegar as tarefas a uma só pessoa com atenção concentrada'),
    ('seed_produtividade_medio_v3', 'O que é monotarefa?', 1, 'Realizar várias tarefas simultaneamente', 'Realizar várias tarefas ao mesmo tempo com atenção dividida'),
    ('seed_produtividade_medio_v3', 'O que é monotarefa?', 2, 'Adiar todas as tarefas', 'Adiar uma tarefa de cada vez até terem acabado as outras'),
    ('seed_produtividade_medio_v3', 'O que são interrupções no trabalho?', 0, 'Técnicas de planejamento', 'Técnicas usadas para organizar a atividade em execução'),
    ('seed_produtividade_medio_v3', 'O que são interrupções no trabalho?', 1, 'Períodos de descanso planejados', 'Períodos de descanso planejados dentro da atividade em execução'),
    ('seed_produtividade_medio_v3', 'O que são interrupções no trabalho?', 3, 'Metas mensuráveis', 'Metas mensuráveis definidas para a atividade em execução'),
    ('seed_produtividade_medio_v3', 'Qual estratégia reduz interrupções desnecessárias?', 0, 'Manter todas as notificações ativadas', 'Manter as notificações ativadas para responder com rapidez'),
    ('seed_produtividade_medio_v3', 'Qual estratégia reduz interrupções desnecessárias?', 1, 'Verificar mensagens constantemente', 'Verificar as mensagens assim que cada uma chegar ao telemóvel'),
    ('seed_produtividade_medio_v3', 'Qual estratégia reduz interrupções desnecessárias?', 3, 'Trabalhar sempre com várias abas abertas', 'Trabalhar com várias abas abertas para trocar de assunto com rapidez'),
    ('seed_produtividade_medio_v3', 'O que significa trabalhar em blocos de tempo?', 1, 'Fazer somente tarefas urgentes', 'Fazer as tarefas urgentes primeiro e deixar as outras para depois'),
    ('seed_produtividade_medio_v3', 'O que significa trabalhar em blocos de tempo?', 2, 'Executar todas as tarefas simultaneamente', 'Executar várias tarefas ao mesmo tempo dentro de cada bloco'),
    ('seed_produtividade_medio_v3', 'O que significa trabalhar em blocos de tempo?', 3, 'Trabalhar sem horários definidos', 'Trabalhar sem horários definidos, conforme o ânimo de cada dia'),
    ('seed_produtividade_medio_v3', 'O que é uma lista de tarefas eficaz?', 1, 'Uma lista com todas as atividades sem qualquer prioridade', 'Uma lista extensa com as atividades registradas por ordem de chegada'),
    ('seed_produtividade_medio_v3', 'O que é uma lista de tarefas eficaz?', 2, 'Uma lista que deve permanecer sempre aberta', 'Uma lista que deve ser mantida aberta no ecrã durante o trabalho'),
    ('seed_produtividade_medio_v3', 'O que é uma lista de tarefas eficaz?', 3, 'Uma lista composta apenas por tarefas urgentes', 'Uma lista composta por tarefas urgentes, sem as de médio prazo'),
    ('seed_produtividade_medio_v3', 'Por que dividir tarefas complexas em subtarefas pode ser útil?', 0, 'Elimina a necessidade de planejamento', 'Elimina a necessidade de planejar e facilita a conclusão do trabalho'),
    ('seed_produtividade_medio_v3', 'Por que dividir tarefas complexas em subtarefas pode ser útil?', 1, 'Impede a conclusão da tarefa principal', 'Torna a tarefa principal mais longa e dificulta o acompanhamento'),
    ('seed_produtividade_medio_v3', 'Por que dividir tarefas complexas em subtarefas pode ser útil?', 2, 'Aumenta necessariamente o trabalho', 'Aumenta o trabalho total e dificulta o acompanhamento do progresso'),
    ('seed_produtividade_medio_v3', 'Qual atividade é um bom exemplo de batching?', 0, 'Evitar qualquer comunicação', 'Evitar a comunicação por e-mail e mensagens durante a semana'),
    ('seed_produtividade_medio_v3', 'Qual atividade é um bom exemplo de batching?', 1, 'Interromper cada tarefa para verificar o e-mail', 'Interromper cada tarefa para responder logo a cada e-mail que chega'),
    ('seed_produtividade_medio_v3', 'Qual atividade é um bom exemplo de batching?', 2, 'Responder mensagens durante todo o dia', 'Responder mensagens à medida que chegam, ao longo do dia'),
    ('seed_produtividade_medio_v3', 'O que é custo de troca de contexto?', 0, 'Tempo de deslocamento até o trabalho', 'Tempo e custo de deslocamento necessários para mudar de local de trabalho'),
    ('seed_produtividade_medio_v3', 'O que é custo de troca de contexto?', 1, 'Tempo usado para descansar', 'Tempo de descanso necessário para recuperar a atenção ao mudar de atividade'),
    ('seed_produtividade_medio_v3', 'O que é custo de troca de contexto?', 2, 'Tempo necessário para criar uma senha', 'Tempo e esforço mental necessários para criar uma senha segura em cada sistema')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
