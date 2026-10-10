-- Explicações pedagógicas (BE-004) — Produtividade médio lote 4: as mesmas 25 perguntas da migration 226 (explicação curta e clara,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 'Na Matriz de Eisenhower, o que é importante mas não urgente deve ser planejado: ainda há tempo para fazer bem, e é aí que ficam metas, estudo e prevenção. Se for deixado de lado, tende a tornar-se urgente mais tarde.'),
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 'O que é importante e urgente tem prazo curto e consequências sérias se falhar, por isso deve ser feito já. É o quadrante das crises e dos prazos a acabar, que convém reduzir com bom planejamento.'),
    ('seed_produtividade_medio_v4', 'Qual pode ser a vantagem de agrupar tarefas semelhantes?', 'Agrupar tarefas parecidas, como responder a todos os e-mails de uma vez, evita ter de mudar de assunto a toda a hora. Cada mudança de contexto custa tempo e atenção, por isso fazer o semelhante em bloco costuma render mais.'),
    ('seed_produtividade_medio_v4', 'O que é mudança de contexto no trabalho?', 'Mudança de contexto é saltar de uma atividade ou tipo de tarefa para outro. Cada salto obriga o cérebro a largar um assunto e a retomar outro, o que gasta tempo e atenção e aumenta os erros.'),
    ('seed_produtividade_medio_v4', 'O que é uma margem de segurança no planejamento do tempo?', 'A margem de segurança é uma folga no calendário para imprevistos e atrasos. Como as tarefas costumam demorar mais do que o previsto, essa folga evita que um atraso desorganize o resto do dia.'),
    ('seed_produtividade_medio_v4', 'Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 'Quando o projeto muda, a importância das tarefas também muda. Convém reavaliar a prioridade em vez de continuar por hábito, para o tempo ir para o que agora conta.'),
    ('seed_produtividade_medio_v4', 'O que é uma interrupção planejada?', 'Uma interrupção planejada é uma pausa ou troca de atividade que se define de antemão, por exemplo descansar a cada hora ou ver mensagens em horas fixas. Ao contrário da distração, é você que decide quando acontece.'),
    ('seed_produtividade_medio_v4', 'O que significa dizer "não" a uma tarefa que não é prioritária?', 'Dizer não ao que não é prioritário é uma forma de proteger o tempo e a atenção para o que realmente importa. Não é recusar trabalho por preguiça: é escolher bem onde gastar a energia.'),
    ('seed_produtividade_medio_v4', 'Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 'Se o tempo de cada tarefa é sempre subestimado, cabem mais tarefas do que o dia permite. O calendário fica sobrecarregado, os atrasos acumulam-se e o stress aumenta.'),
    ('seed_produtividade_medio_v4', 'Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 'Ver a diferença entre o tempo previsto e o tempo real mostra onde costuma errar, por exemplo se subestima certas tarefas. Com essa informação, as próximas estimativas e o planejamento ficam mais realistas.'),
    ('seed_produtividade_medio_v4', 'O que é uma estimativa de esforço?', 'Uma estimativa de esforço é uma avaliação aproximada de quanto trabalho vai ser preciso para concluir uma atividade. É aproximada porque o futuro tem incertezas, mas ajuda a planear prazos e a distribuir o trabalho.'),
    ('seed_produtividade_medio_v4', 'Por que evitar preencher cada minuto do dia pode ser útil?', 'Um dia sem folgas não aguenta nenhum imprevisto: um telefonema ou um atraso estraga tudo o que vem a seguir. Deixar espaço livre permite absorver o inesperado sem desorganizar o resto.'),
    ('seed_produtividade_medio_v4', 'Qual é o principal objetivo de uma matriz de prioridades?', 'Uma matriz de prioridades serve para classificar atividades por critérios como importância e urgência, para se perceber o que fazer primeiro, o que planejar, o que delegar e o que deixar de fazer.'),
    ('seed_produtividade_medio_v4', 'Por que mudanças constantes de contexto podem prejudicar a produtividade?', 'Cada vez que muda de atividade, o cérebro precisa de largar um assunto e de recordar onde ficou o outro. Esse esforço gasta tempo e atenção, por isso muitas mudanças seguidas fazem render menos.'),
    ('seed_produtividade_medio_v4', 'Qual é uma característica de uma reunião produtiva?', 'Uma reunião produtiva sabe para que serve e tem uma pauta, ou seja, a lista do que vai ser tratado. Assim todos se preparam, a conversa não se desvia e acaba com decisões claras.'),
    ('seed_produtividade_medio_v4', 'O que significa estimar a duração de uma tarefa?', 'Estimar a duração é prever, de forma aproximada, quanto tempo uma tarefa vai exigir, com base na experiência de tarefas parecidas. Serve para planear prazos e para não prometer mais do que cabe no dia.'),
    ('seed_produtividade_medio_v4', 'Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 'O que é importante mas não urgente não tem pressa hoje, mas pode ficar urgente se for esquecido. Por isso convém agendá-lo e planeá-lo com antecedência, em vez de esperar pela urgência.'),
    ('seed_produtividade_medio_v4', 'Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:', 'Reservar um bloco fixo do dia para uma única atividade chama-se time blocking, ou blocagem de tempo. Ajuda a proteger o tempo para o que importa e a evitar interrupções e multitarefa.'),
    ('seed_produtividade_medio_v4', 'O que significa revisar prioridades?', 'Prioridades não são para sempre: prazos, pedidos e objetivos mudam. Revisá-las é voltar a avaliar o que merece atenção agora, para o tempo ir para o que conta hoje e não para o que contava ontem.'),
    ('seed_produtividade_medio_v4', 'Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 'Quem começa muitas tarefas e acaba poucas costuma estar a dividir demasiado a atenção. Limitar quantas tarefas estão em curso ao mesmo tempo, e escolher o que vem primeiro, ajuda a levar cada uma até ao fim.'),
    ('seed_produtividade_medio_v4', 'Por que uma agenda de reunião pode aumentar a produtividade?', 'A agenda diz de antemão o que vai ser tratado e em que ordem. Assim a reunião mantém o foco nos assuntos previstos, evita conversas paralelas e acaba mais depressa.'),
    ('seed_produtividade_medio_v5', 'Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 'Para uma tarefa que exige concentração, o melhor é reduzir as fontes de distração. Desativar ou limitar notificações durante esse período evita interrupções e dá-lhe tempo para trabalhar em profundidade.'),
    ('seed_produtividade_medio_v5', 'Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 'Quem adia o difícil costuma esperar pelo momento certo, que nunca chega. Marcar de antemão quando começar e dividir a tarefa em etapas pequenas torna o início menos pesado e o progresso visível.'),
    ('seed_produtividade_medio_v6', 'Qual característica é desejável em um KPI?', 'Um KPI (indicador-chave de desempenho) só serve se estiver ligado a um objetivo que importa e se puder ser medido sempre da mesma forma, para se comparar ao longo do tempo. Medir só o que é fácil não ajuda a decidir.'),
    ('seed_produtividade_medio_v6', 'Por que o custo de oportunidade é relevante para a produtividade?', 'Quando usa o tempo numa atividade, deixa de o usar noutra: esse é o custo de oportunidade. Perceber isso ajuda a decidir melhor onde investir o tempo, porque dizer sim a uma coisa é dizer não a outras.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 4: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
