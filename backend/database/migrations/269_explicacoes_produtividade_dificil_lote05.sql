-- Explicações pedagógicas (BE-004) — Produtividade difícil lote 5 (fecho): 2 perguntas do seed dificil_v2 (migration 078) que ficaram fora do lote 4 e sem explicação.
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (difícil: raciocínio e relação entre conceitos, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 268. Só atualiza
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
    ('seed_produtividade_dificil_v2', 'Se a tarefa B só pode começar depois que A termina, existe uma:', 'Quando a tarefa B só pode começar depois que A termina, existe uma dependência entre elas (do tipo término-início). Mapear as dependências define a ordem do trabalho e ajuda a identificar o caminho crítico, enquanto tarefas independentes podem avançar em paralelo.'),
    ('seed_produtividade_dificil_v2', 'Reduzir o número de tarefas iniciadas simultaneamente pode melhorar o fluxo porque:', 'Limitar o trabalho em andamento diminui a dispersão de recursos e atenção: com menos tarefas abertas há menos trocas de contexto e cada uma é concluída mais depressa. É o princípio de limitar o WIP em métodos como o Kanban, e melhora o fluxo de entrega.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade difícil lote 5 (fecho): 2 perguntas do seed dificil_v2 (migration 078) que ficaram fora do lote 4 e sem explicação: % pergunta(s) atualizada(s) (esperado: 2).', v_updated;
END $$;
