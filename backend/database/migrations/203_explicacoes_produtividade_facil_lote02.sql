-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 2: perguntas 1 a 12 do seed v2 (migration 051) e 1 a 13 do seed v3 (migration 084).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 202. Só atualiza
-- perguntas que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera
-- perguntas nem alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não
-- impedir o arranque do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 'Priorizar é decidir quais tarefas são mais importantes ou urgentes e fazê-las primeiro. Assim, o tempo e a energia vão para o que mais importa, e não para o que simplesmente aparece à frente.'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de criar uma lista de tarefas?', 'Uma lista de tarefas reúne tudo o que precisa ser feito num só lugar, o que ajuda a organizar as atividades e a acompanhar o que já foi concluído. Assim ninguém precisa confiar apenas na memória.'),
    ('seed_produtividade_facil_v2', 'Qual estratégia pode ajudar a reduzir distrações?', 'Notificações interrompem a atenção e custam tempo para voltar ao foco. Desativar as que não são necessárias durante uma tarefa ajuda a manter a concentração e a terminar mais depressa.'),
    ('seed_produtividade_facil_v2', 'O que significa estabelecer uma meta?', 'Estabelecer uma meta é definir o resultado que se pretende alcançar. Com um destino claro, fica mais fácil escolher as ações certas e saber quando se chegou lá.'),
    ('seed_produtividade_facil_v2', 'Por que dividir uma tarefa grande em etapas pode ajudar?', 'Dividir uma tarefa grande em etapas pequenas torna o trabalho mais gerenciável: cada parte é mais fácil de começar e de concluir, e o progresso fica visível ao longo do caminho.'),
    ('seed_produtividade_facil_v2', 'Para que serve um calendário?', 'O calendário serve para organizar compromissos e atividades ao longo do tempo, mostrando datas e prazos. Assim é mais fácil planejar e evitar marcar duas coisas para o mesmo momento.'),
    ('seed_produtividade_facil_v2', 'Qual prática pode ajudar na concentração?', 'Trabalhar em blocos de atenção, com pausas planejadas, ajuda a manter o foco e evita o cansaço mental. Depois de cada pausa, a concentração costuma voltar mais forte para o bloco seguinte.'),
    ('seed_produtividade_facil_v2', 'Por que revisar objetivos regularmente pode ser útil?', 'Revisar objetivos regularmente permite avaliar o progresso e fazer ajustes, caso as prioridades ou as condições tenham mudado. Assim se evita seguir um plano que já não faz sentido.'),
    ('seed_produtividade_facil_v2', 'O que é uma tarefa recorrente?', 'Uma tarefa recorrente é aquela que precisa ser realizada repetidamente, por exemplo todos os dias ou todos os meses. Agendá-la como recorrente ajuda a não se esquecer dela.'),
    ('seed_produtividade_facil_v2', 'Qual atitude ajuda a evitar atrasos?', 'Reservar tempo suficiente para cada tarefa, com alguma margem, evita correrias e atrasos. Quando o tempo é calculado de forma realista, os prazos são cumpridos com mais tranquilidade.'),
    ('seed_produtividade_facil_v2', 'O que é planejamento?', 'Planejamento é definir antecipadamente as ações necessárias para alcançar um objetivo. Pensar antes de agir ajuda a organizar os passos, os recursos e os prazos.'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 'Revisar o trabalho antes de entregá-lo pode ajudar a encontrar erros que passaram despercebidos e a corrigi-los a tempo. É uma etapa rápida que melhora a qualidade do resultado.'),
    ('seed_produtividade_facil_v3', 'Qual é uma boa prática para começar o dia de trabalho?', 'Começar o dia definindo as principais prioridades dá direção ao trabalho e garante que o tempo vai para o que é mais importante, antes que mensagens e imprevistos tomem conta da agenda.'),
    ('seed_produtividade_facil_v3', 'Qual ferramenta pode ajudar a organizar tarefas?', 'Uma lista de tarefas é uma ferramenta simples para organizar o que precisa ser feito e acompanhar o que já foi concluído. Calculadoras, editores de imagem ou leitores de música têm outras funções.'),
    ('seed_produtividade_facil_v3', 'Por que é importante estabelecer objetivos?', 'Estabelecer objetivos orienta as ações, porque mostra para onde se quer ir, e permite medir o progresso ao longo do caminho. Sem objetivos, é difícil saber se o esforço está a dar resultado.'),
    ('seed_produtividade_facil_v3', 'O que pode ajudar a evitar distrações durante o trabalho?', 'Notificações desnecessárias roubam a atenção e interrompem o raciocínio. Desativá-las durante o trabalho reduz as distrações e ajuda a manter o foco numa tarefa de cada vez.'),
    ('seed_produtividade_facil_v3', 'O que significa organizar o tempo?', 'Organizar o tempo é usá-lo de maneira planejada, definindo o que fazer, quando e por quanto tempo. Com um plano, sobra espaço para o que é importante e para o descanso.'),
    ('seed_produtividade_facil_v3', 'Uma agenda serve principalmente para:', 'A agenda serve principalmente para organizar compromissos e tarefas, com datas e horários. Ela ajuda a lembrar do que precisa ser feito e a evitar conflitos entre atividades.'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 'As pausas curtas permitem descansar a mente e podem ajudar a recuperar a concentração. Depois de uma pausa bem feita, o trabalho costuma render mais e com menos erros.'),
    ('seed_produtividade_facil_v3', 'Qual é uma característica de uma meta bem definida?', 'Uma meta bem definida é clara e específica: diz exatamente o que se quer alcançar, o que facilita medir o progresso e saber quando foi cumprida. Metas vagas dificultam essa avaliação.'),
    ('seed_produtividade_facil_v3', 'O que ajuda a acompanhar o progresso de um projeto?', 'Para acompanhar o progresso de um projeto é preciso registrar e verificar regularmente o andamento das atividades. Assim se percebe cedo o que está atrasado e o que já foi concluído.'),
    ('seed_produtividade_facil_v3', 'Qual atitude pode melhorar a concentração?', 'Um ambiente organizado reduz as distrações e a procura por materiais, o que ajuda a concentração. Quando tudo está no lugar, a atenção fica na tarefa e não no que está à volta.'),
    ('seed_produtividade_facil_v3', 'Por que estabelecer prazos pode ajudar na produtividade?', 'Estabelecer prazos ajuda a criar um limite de tempo para concluir as atividades e a decidir o que fazer primeiro. Sem prazo, é fácil adiar e deixar as tarefas acumular.'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 'Quando existem muitas tarefas, o melhor é organizá-las e definir prioridades, começando pelas mais importantes ou urgentes. Tentar fazer tudo ao mesmo tempo só aumenta o desgaste.'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 'Procrastinar constantemente, isto é, adiar tarefas sem necessidade, acumula trabalho e cria pressa no fim. Planejar, ter foco e definir prioridades são hábitos que ajudam a produtividade.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 2: perguntas 1 a 12 do seed v2 (migration 051) e 1 a 13 do seed v3 (migration 084): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
