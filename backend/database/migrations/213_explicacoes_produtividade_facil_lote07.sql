-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 7: as 23 perguntas ativas que faltam do seed v7 (v7#26 a v7#48, migration 096), que fecha o fácil.
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 212. Só atualiza perguntas
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
    ('seed_produtividade_facil_v7', 'Por que é importante fazer uma lista de tarefas?', 'Fazer uma lista de tarefas ajuda a visualizar o que precisa ser realizado, para nada ser esquecido. Não serve para desorganizar nem para substituir o descanso.'),
    ('seed_produtividade_facil_v7', 'O que é uma prioridade?', 'Uma prioridade é algo que merece atenção antes de outras atividades, por ser mais importante ou urgente. Não é uma tarefa sem importância nem uma distração.'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode ajudar na pontualidade?', 'Considerar o tempo necessário para o deslocamento evita atrasos, porque se sai com a folga certa. Sair em cima da hora ou ignorar horários leva a chegar atrasado.'),
    ('seed_produtividade_facil_v7', 'Qual destas atitudes demonstra boa gestão do tempo?', 'Reservar tempo para as tarefas importantes é boa gestão do tempo, porque garante espaço para o que mais conta. Adiar, não planejar ou aceitar todas as interrupções desperdiça tempo.'),
    ('seed_produtividade_facil_v7', 'O que significa organizar uma tarefa?', 'Organizar uma tarefa é definir como e quando ela será realizada, para saber os passos e o momento. Eliminar ou esquecer a tarefa não é organizá-la.'),
    ('seed_produtividade_facil_v7', 'Qual é uma consequência possível de não organizar compromissos?', 'Sem organizar os compromissos, é fácil esquecer atividades importantes. Organizar não dá mais tempo por si só, mas ajuda a não deixar nada para trás.'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a controlar o tempo gasto numa atividade?', 'O cronómetro mede quanto tempo passa, por isso ajuda a controlar o tempo gasto numa atividade. Câmara, microfone e calculadora não medem o tempo.'),
    ('seed_produtividade_facil_v7', 'O que significa manter consistência?', 'Manter consistência é realizar uma ação de forma regular, para o hábito se formar. Fazer uma só vez ou mudar de objetivo a toda a hora não cria consistência.'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode melhorar a utilização do tempo?', 'Estabelecer limites para atividades pouco importantes melhora a utilização do tempo, porque sobra mais tempo para o que conta. Aceitar distrações ou trabalhar sem prioridades gasta tempo à toa.'),
    ('seed_produtividade_facil_v7', 'Por que o descanso é importante?', 'O descanso pode ajudar na recuperação e na manutenção da energia, e assim melhorar o rendimento. Não substitui o planejamento nem elimina o trabalho.'),
    ('seed_produtividade_facil_v7', 'Qual destas opções ajuda a lembrar tarefas futuras?', 'Uma lista de lembretes ajuda a lembrar tarefas futuras, porque as deixa registradas e visíveis. Câmara, galeria e aplicativo de música servem para outras coisas.'),
    ('seed_produtividade_facil_v7', 'O que significa preparar uma tarefa?', 'Preparar uma tarefa é reunir as informações e os recursos necessários antes de executá-la, assim o trabalho flui sem paragens. Ignorar materiais ou cancelar o objetivo não é preparar.'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de definir uma hora para começar uma tarefa?', 'Definir uma hora para começar cria um ponto claro de início, e fica mais fácil de não adiar. Não tira a responsabilidade nem evita as dificuldades.'),
    ('seed_produtividade_facil_v7', 'O que é uma meta diária?', 'Uma meta diária é um resultado que se pretende alcançar durante o dia, e orienta o que fazer. Não é uma tarefa sem prazo, uma distração nem um período de descanso.'),
    ('seed_produtividade_facil_v7', 'Qual ação ajuda a acompanhar o progresso?', 'Marcar as tarefas concluídas mostra o que já foi feito e o que falta, por isso ajuda a acompanhar o progresso. Evitar registros ou ignorar resultados impede de ver o avanço.'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar uma pessoa a manter uma rotina?', 'Horários relativamente consistentes criam rotina, porque o corpo e a mente se habituam. Não planejar, mudar sem motivo ou ignorar compromissos desorganiza a rotina.'),
    ('seed_produtividade_facil_v7', 'Qual é uma maneira simples de evitar esquecer compromissos?', 'Usar lembretes é uma forma simples de não esquecer compromissos: o aviso aparece na hora certa. Confiar só na memória ou ignorar a agenda aumenta o risco de esquecer.'),
    ('seed_produtividade_facil_v7', 'Qual atitude pode facilitar o início do trabalho?', 'Preparar os materiais antes facilita o início do trabalho, porque nada falta na hora de começar. Procurar distrações ou adiar só torna o começo mais difícil.'),
    ('seed_produtividade_facil_v7', 'O que é uma lista de prioridades?', 'Uma lista de prioridades é uma relação de atividades organizada pela importância, com o mais importante em primeiro lugar. Calendário, contatos e distrações são outras coisas.'),
    ('seed_produtividade_facil_v7', 'Qual comportamento pode aumentar a produtividade durante uma sessão de estudo?', 'Para estudar com mais produtividade, convém manter o foco numa tarefa definida. Responder a notificações, ver vídeos ou trocar de aplicação a toda a hora quebra a concentração.'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir um prazo para uma atividade?', 'Um prazo ajuda a orientar quando a atividade deve ser concluída, e dá um limite para o planejamento. Não garante a ausência de erros nem elimina o trabalho.'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática ao terminar o dia?', 'Ao terminar o dia, é boa prática rever o que foi realizado e preparar as próximas tarefas, assim o dia seguinte começa organizado. Apagar registros ou ignorar pendências deixa tudo solto.'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 'Boa gestão das tarefas é definir o que fazer, quando fazer e qual a prioridade. Evitar prazos, começar tudo junto ou decidir em cima da hora gera confusão.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 7: % pergunta(s) atualizada(s) (esperado: 23).', v_updated;
END $$;
