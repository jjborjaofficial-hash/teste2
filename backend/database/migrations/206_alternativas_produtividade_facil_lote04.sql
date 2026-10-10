-- Alternativas (BE-003, regularização) — Produtividade fácil lote 4: seed v5 completo (migration 089, 7 perguntas) e seed v6 completo (migration 091, 1 pergunta).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_facil_v5', 'O que significa organizar uma tarefa por etapas?', 0, 'Fazer todas as partes ao mesmo tempo', 'Reunir as partes em uma etapa longa'),
    ('seed_produtividade_facil_v5', 'O que significa organizar uma tarefa por etapas?', 2, 'Eliminar a tarefa', 'Entregá-la a outra pessoa para executar'),
    ('seed_produtividade_facil_v5', 'O que significa organizar uma tarefa por etapas?', 3, 'Adiar todas as etapas', 'Colocar as partes em ordem aleatória'),
    ('seed_produtividade_facil_v5', 'Qual é uma boa prática ao iniciar uma atividade importante?', 0, 'Abrir várias tarefas diferentes', 'Abrir várias tarefas diferentes ao mesmo tempo'),
    ('seed_produtividade_facil_v5', 'Qual é uma boa prática ao iniciar uma atividade importante?', 1, 'Evitar qualquer objetivo', 'Deixar o objetivo para ser definido depois'),
    ('seed_produtividade_facil_v5', 'Qual é uma boa prática ao iniciar uma atividade importante?', 2, 'Começar sem saber o que fazer', 'Começar pelo que parecer mais agradável'),
    ('seed_produtividade_facil_v5', 'Para que serve um cronograma?', 0, 'Para apagar tarefas', 'Para registrar gastos e receitas ao longo de cada mês'),
    ('seed_produtividade_facil_v5', 'Para que serve um cronograma?', 1, 'Para substituir todos os documentos', 'Para guardar documentos em pastas por ordem alfabética'),
    ('seed_produtividade_facil_v5', 'Para que serve um cronograma?', 3, 'Para aumentar as distrações', 'Para medir a velocidade de execução de cada tarefa'),
    ('seed_produtividade_facil_v5', 'O que significa concluir uma tarefa dentro do prazo?', 0, 'Começá-la depois da data limite', 'Iniciá-la depois de passada a data final prevista'),
    ('seed_produtividade_facil_v5', 'O que significa concluir uma tarefa dentro do prazo?', 1, 'Cancelá-la antes de começar', 'Repeti-la várias vezes antes da data final'),
    ('seed_produtividade_facil_v5', 'O que significa concluir uma tarefa dentro do prazo?', 2, 'Transferi-la para outra pessoa', 'Cancelá-la quando faltar pouco para o fim'),
    ('seed_produtividade_facil_v5', 'Por que é útil saber qual tarefa deve ser feita primeiro?', 0, 'Para aumentar o número de tarefas', 'Para aumentar o volume de tarefas diárias da equipe'),
    ('seed_produtividade_facil_v5', 'Por que é útil saber qual tarefa deve ser feita primeiro?', 2, 'Para evitar qualquer planejamento', 'Para reduzir a necessidade de definir prazos'),
    ('seed_produtividade_facil_v5', 'Por que é útil saber qual tarefa deve ser feita primeiro?', 3, 'Para tornar todas as tarefas urgentes', 'Para facilitar a divisão do trabalho entre colegas'),
    ('seed_produtividade_facil_v5', 'O que significa preparar uma tarefa com antecedência?', 1, 'Cancelar a tarefa', 'Revisar o resultado da tarefa depois de ela estar totalmente concluída'),
    ('seed_produtividade_facil_v5', 'O que significa preparar uma tarefa com antecedência?', 2, 'Adiar todo o trabalho', 'Pedir ajuda a um colega no exato momento em que o prazo terminar'),
    ('seed_produtividade_facil_v5', 'O que significa preparar uma tarefa com antecedência?', 3, 'Ignorar os materiais necessários', 'Guardar os materiais utilizados depois de a tarefa ter sido concluída'),
    ('seed_produtividade_facil_v5', 'Qual ação pode facilitar o cumprimento de uma meta?', 0, 'Não acompanhar o progresso', 'Adiar o acompanhamento até o fim do período'),
    ('seed_produtividade_facil_v5', 'Qual ação pode facilitar o cumprimento de uma meta?', 1, 'Alterar o objetivo diariamente sem motivo', 'Trocar de objetivo a cada nova ideia que surge no dia'),
    ('seed_produtividade_facil_v5', 'Qual ação pode facilitar o cumprimento de uma meta?', 3, 'Evitar qualquer prazo', 'Deixar o prazo para ser decidido no último dia'),
    ('seed_produtividade_facil_v6', 'O que significa dizer que uma tarefa foi concluída?', 0, 'Que ela foi iniciada, mas deixada pela metade', 'Que ela foi iniciada e deixada pela metade')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 4: seed v5 completo (migration 089, 7 perguntas) e seed v6 completo (migration 091, 1 pergunta): % alternativa(s) errada(s) atualizada(s) (esperado: 22).', v_updated;
END $$;
