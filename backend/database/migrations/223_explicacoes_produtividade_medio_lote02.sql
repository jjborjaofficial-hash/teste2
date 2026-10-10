-- Explicações pedagógicas (BE-004) — Produtividade médio lote 2: v1#26 a v1#30, v2 (5) e as 15 primeiras do v3 do seed médio (migrations 043, 052 e 082).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 222. Só atualiza perguntas
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
    ('seed_produtividade_medio_v1', 'Por que realizar tarefas complexas em períodos de maior concentração pode ajudar?', 'Tarefas complexas exigem mais atenção, por isso rendem mais quando feitas nos períodos em que a capacidade de atenção está no máximo. Isso não elimina o descanso nem torna a tarefa mais simples: só aproveita melhor a energia.'),
    ('seed_produtividade_medio_v1', 'O que significa estimar o tempo de uma tarefa?', 'Estimar o tempo de uma tarefa é prever aproximadamente quanto tempo será necessário para concluí-la. É uma previsão, não um valor exato, e serve de base ao planejamento.'),
    ('seed_produtividade_medio_v1', 'Por que registrar o tempo real gasto em tarefas pode ser útil?', 'Registar o tempo real gasto permite comparar com o que foi estimado e ajustar as estimativas seguintes. Com o tempo, os planos ficam mais realistas.'),
    ('seed_produtividade_medio_v1', 'O que é margem de tempo em um planejamento?', 'A margem de tempo é um tempo adicional reservado para imprevistos ou atrasos. Sem ela, qualquer imprevisto desorganiza o resto do planejamento.'),
    ('seed_produtividade_medio_v2', 'O que significa delegar uma tarefa?', 'Delegar uma tarefa é atribuí-la a outra pessoa adequada para a executar, por exemplo por ter mais competência ou tempo. Ignorar, repetir ou apagar a tarefa não é delegar.'),
    ('seed_produtividade_medio_v2', 'Qual é uma consequência de tentar fazer muitas tarefas simultaneamente?', 'Fazer muitas tarefas ao mesmo tempo pode aumentar as distrações e reduzir a eficiência, porque a atenção se divide. O resultado costuma ser mais erros e mais tempo.'),
    ('seed_produtividade_medio_v2', 'O que é uma deadline?', 'Deadline é o prazo limite para concluir uma atividade. Não é o início nem uma data de pagamento; é o ponto até onde o trabalho tem de estar pronto.'),
    ('seed_produtividade_medio_v2', 'O que significa automatizar uma tarefa?', 'Automatizar uma tarefa é usar ferramentas ou sistemas para executar a atividade sem intervenção manual a cada vez. É útil para tarefas repetitivas, que poupam tempo ao serem feitas pela máquina.'),
    ('seed_produtividade_medio_v2', 'Por que estabelecer prioridades pode melhorar o uso do tempo?', 'Estabelecer prioridades ajuda a concentrar o tempo e os recursos nas atividades mais relevantes, que dão mais resultado. O dia não ganha horas: o mesmo tempo passa a ser mais bem usado.'),
    ('seed_produtividade_medio_v3', 'Qual é uma das principais finalidades da gestão do tempo?', 'A gestão do tempo busca usar o tempo de forma alinhada às prioridades e objetivos, para ganhar o que realmente importa. Não é encher o dia nem trabalhar sem descanso.'),
    ('seed_produtividade_medio_v3', 'Qual é o principal objetivo da técnica Pomodoro?', 'O Pomodoro organiza o trabalho em períodos de foco e pausas planejadas, para manter a atenção e evitar o cansaço. As pausas fazem parte do método.'),
    ('seed_produtividade_medio_v3', 'O que caracteriza a procrastinação?', 'Procrastinar é adiar sem necessidade tarefas que importam. Planejar com antecedência, organizar prioridades e delegar são o contrário.'),
    ('seed_produtividade_medio_v3', 'Qual estratégia pode ajudar a combater a procrastinação?', 'Dividir uma tarefa grande em etapas menores torna o começo mais leve e dá pequenos avanços, o que combate a procrastinação. Esperar pela motivação ou adiar só prolonga o problema.'),
    ('seed_produtividade_medio_v3', 'O que é uma meta SMART?', 'SMART é uma sigla em inglês para metas específicas, mensuráveis, alcançáveis, relevantes e temporalmente definidas. Uma meta com estes cinco pontos é clara e dá para saber quando foi cumprida.'),
    ('seed_produtividade_medio_v3', 'Por que estabelecer prazos realistas melhora a produtividade?', 'Prazos realistas ajudam a estruturar o trabalho e a controlar o progresso, porque cada etapa tem um tempo possível de cumprir. Prazos irreais geram atraso e pressão.'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de definir as três principais prioridades do dia?', 'Definir as três principais prioridades do dia concentra a atenção nas atividades de maior impacto. Assim, mesmo que o dia corra mal, o que mais importa foi feito.'),
    ('seed_produtividade_medio_v3', 'Por que a multitarefa pode reduzir a produtividade?', 'Na multitarefa, a atenção alterna com frequência, e cada troca tem um custo cognitivo e faz perder o foco. Por isso o rendimento total costuma cair.'),
    ('seed_produtividade_medio_v3', 'O que é monotarefa?', 'Monotarefa é executar uma tarefa de cada vez com atenção concentrada, sem saltar para outra. É o oposto da multitarefa.'),
    ('seed_produtividade_medio_v3', 'O que são interrupções no trabalho?', 'Interrupções são eventos que desviam a atenção da atividade em execução, como chamadas, mensagens ou pedidos de colegas. Cada uma custa tempo para retomar o foco.'),
    ('seed_produtividade_medio_v3', 'Qual estratégia reduz interrupções desnecessárias?', 'Criar períodos específicos de foco e limitar as notificações evita as interrupções desnecessárias, e o trabalho flui. Manter tudo ativo, ou verificar a toda a hora, faz o contrário.'),
    ('seed_produtividade_medio_v3', 'O que significa trabalhar em blocos de tempo?', 'Trabalhar em blocos de tempo é reservar períodos específicos para determinadas atividades, o que protege o foco e dá estrutura ao dia.'),
    ('seed_produtividade_medio_v3', 'O que é uma lista de tarefas eficaz?', 'Uma lista de tarefas eficaz é organizada e ajuda a visualizar e executar as responsabilidades, com prioridades claras. Uma lista solta, por ordem de chegada, não orienta o trabalho.'),
    ('seed_produtividade_medio_v3', 'Por que dividir tarefas complexas em subtarefas pode ser útil?', 'Dividir tarefas complexas em subtarefas torna o objetivo mais claro e facilita o acompanhamento do progresso, porque cada subtarefa concluída mostra o avanço. Também reduz a sensação de peso.'),
    ('seed_produtividade_medio_v3', 'Qual atividade é um bom exemplo de batching?', 'Batching é reservar um único período para tarefas parecidas, como responder e-mails e mensagens. Assim evitam-se interrupções ao longo do dia.'),
    ('seed_produtividade_medio_v3', 'O que é custo de troca de contexto?', 'O custo de troca de contexto é o tempo e o esforço mental para mudar de uma atividade ou contexto para outro: é preciso largar um raciocínio e retomar outro. Por isso trocar de tarefa com frequência faz perder tempo.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 2: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
