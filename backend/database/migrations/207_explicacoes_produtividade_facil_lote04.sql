-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 4: seed v5 completo (migration 089, 7 perguntas) e seed v6 completo (migration 091, 1 pergunta).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 206. Só atualiza
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
    ('seed_produtividade_facil_v5', 'O que significa organizar uma tarefa por etapas?', 'Organizar uma tarefa por etapas é dividi-la em partes menores e colocá-las em ordem. Assim fica mais fácil saber por onde começar, acompanhar o progresso e não se sentir sobrecarregado.'),
    ('seed_produtividade_facil_v5', 'Qual é uma boa prática ao iniciar uma atividade importante?', 'Antes de iniciar uma atividade importante, é boa prática definir claramente o que precisa ser concluído. Com o objetivo à vista, escolhem-se melhor as ações e sabe-se quando o trabalho está pronto.'),
    ('seed_produtividade_facil_v5', 'Para que serve um cronograma?', 'Um cronograma serve para organizar as atividades de acordo com períodos ou datas, mostrando o que será feito e quando. Ajuda a distribuir o trabalho no tempo e a cumprir os prazos.'),
    ('seed_produtividade_facil_v5', 'O que significa concluir uma tarefa dentro do prazo?', 'Concluir uma tarefa dentro do prazo é realizá-la até a data ou o período estabelecido. Para isso, é preciso planejar o tempo e começar com antecedência suficiente.'),
    ('seed_produtividade_facil_v5', 'Por que é útil saber qual tarefa deve ser feita primeiro?', 'Saber qual tarefa deve ser feita primeiro orienta melhor o uso do tempo e dos recursos, porque o esforço vai para o que é mais importante ou urgente. Assim evitam-se atrasos e trabalho desperdiçado.'),
    ('seed_produtividade_facil_v5', 'O que significa preparar uma tarefa com antecedência?', 'Preparar uma tarefa com antecedência é realizar parte da preparação antes do momento em que ela será necessária, como reunir materiais ou organizar informações. Isso reduz a pressa e os imprevistos.'),
    ('seed_produtividade_facil_v5', 'Qual ação pode facilitar o cumprimento de uma meta?', 'Definir ações concretas relacionadas ao objetivo transforma uma meta geral em passos que se podem executar. Quando se sabe o que fazer a seguir, é mais fácil manter o ritmo e chegar ao resultado.'),
    ('seed_produtividade_facil_v6', 'O que significa dizer que uma tarefa foi concluída?', 'Dizer que uma tarefa foi concluída significa que o resultado necessário foi realizado, ou seja, ela foi feita até o fim. Iniciar, transferir ou apenas registrar a tarefa não é o mesmo que concluí-la.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 4: seed v5 completo (migration 089, 7 perguntas) e seed v6 completo (migration 091, 1 pergunta): % pergunta(s) atualizada(s) (esperado: 8).', v_updated;
END $$;
