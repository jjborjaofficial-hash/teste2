-- Alternativas (BE-003, regularização) — Produtividade difícil lote 5 (fecho): 2 perguntas do seed dificil_v2 (migration 078) que ficaram fora do lote 4 e sem explicação.
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
    ('seed_produtividade_dificil_v2', 'Se a tarefa B só pode começar depois que A termina, existe uma:', 0, 'Pausa', 'Paralelismo'),
    ('seed_produtividade_dificil_v2', 'Se a tarefa B só pode começar depois que A termina, existe uma:', 1, 'Automação', 'Redundância'),
    ('seed_produtividade_dificil_v2', 'Reduzir o número de tarefas iniciadas simultaneamente pode melhorar o fluxo porque:', 0, 'Impede a conclusão', 'Aumenta a quantidade de tarefas em espera'),
    ('seed_produtividade_dificil_v2', 'Reduzir o número de tarefas iniciadas simultaneamente pode melhorar o fluxo porque:', 1, 'Elimina todos os prazos', 'Elimina a necessidade de definir prioridades'),
    ('seed_produtividade_dificil_v2', 'Reduzir o número de tarefas iniciadas simultaneamente pode melhorar o fluxo porque:', 3, 'Aumenta necessariamente o número de reuniões', 'Aumenta o número de reuniões de acompanhamento')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade difícil lote 5 (fecho): 2 perguntas do seed dificil_v2 (migration 078) que ficaram fora do lote 4 e sem explicação: % alternativa(s) errada(s) atualizada(s) (esperado: 5).', v_updated;
END $$;
