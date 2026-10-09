-- Ajuste de alternativas (BE-003, regularização) — Produtividade fácil lote 2 (migration 202), resíduo: 5 perguntas que o
-- detetor de viés (BE-003, P9) passou a apontar depois do lote: absolutos só nas erradas, cautela ("pode") só na correta e
-- diferença grande de palavras entre as opções. Mesma correção que a migration 326 fez em Tecnologia.
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é ajustado. Nas 5 perguntas as
-- explicações são conceptuais e continuam coerentes com o novo texto, por isso não são tocadas.
-- CORREÇÃO POSTERIOR a um lote já aplicado (202): o nome `*_ajuste_alternativas_*` diz ao teste dos lotes
-- (tests/quiz-alternatives-lotes.test.js) que este texto substitui o do lote. Fica na faixa 2xx, depois do lote 2 e antes da 300.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 0, 'Dividir as tarefas igualmente entre todas as pessoas', 'Dividir as tarefas em partes iguais entre as pessoas'),
    ('seed_produtividade_facil_v2', 'O que significa priorizar tarefas?', 1, 'Registrar todas as tarefas em uma lista por ordem alfabética', 'Registrar as tarefas em uma lista por ordem alfabética'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 1, 'Substitui a necessidade de prazos', 'Pode reduzir a necessidade de prazos'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 2, 'Garante a aprovação do trabalho', 'Pode atrasar a entrega sem ganho'),
    ('seed_produtividade_facil_v2', 'Qual é uma vantagem de revisar o trabalho antes de entregá-lo?', 3, 'Dispensa a organização das tarefas', 'Pode dispensar o uso de agenda'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 0, 'Aumenta o cansaço depois de cada tarefa', 'Pode aumentar o cansaço depois de cada tarefa'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 1, 'Dispensa a definição de prioridades', 'Pode dispensar a definição de prioridades'),
    ('seed_produtividade_facil_v3', 'Por que fazer pausas durante o trabalho pode ser útil?', 2, 'Reduz a qualidade das tarefas concluídas', 'Pode reduzir a qualidade das tarefas feitas'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 0, 'Escolher apenas as mais fáceis', 'Escolher as que dão menos trabalho'),
    ('seed_produtividade_facil_v3', 'O que deve ser feito quando existem muitas tarefas?', 2, 'Fazer a lista só no fim do dia', 'Fazer a lista no fim do dia'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 1, 'Revisar as tarefas todos os dias', 'Organizar as tarefas'),
    ('seed_produtividade_facil_v3', 'Qual comportamento pode prejudicar a produtividade?', 2, 'Fazer pausas curtas e planejadas', 'Fazer pausas curtas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Produtividade fácil lote 2 (resíduo): % alternativa(s) errada(s) atualizada(s) (esperado: 12).', v_updated;
END $$;
