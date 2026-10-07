-- Ajuste de alternativas (BE-003, regularização) — Finanças, resíduo: 4 perguntas cuja certa ficou muito mais curta que as erradas.
-- Aprovado pelo dono em 2026-10-07 (rascunho: docs/quiz-lotes-alternativas/financas-ajuste-residual.md).
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é encurtado. As explicações
-- destas 4 perguntas são conceptuais e continuam coerentes com o novo texto, por isso não são tocadas.
-- CORREÇÃO POSTERIOR a lotes já aplicados (ex.: lote 152 mexeu em "inflação esperada"): o nome `*_ajuste_alternativas_*`
-- diz ao teste dos lotes (tests/quiz-alternatives-lotes.test.js) que este texto substitui o do lote.
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
    ('seed_financas_dificil_v1', 'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 1, 'A empresa passa a ter lucro maior em todas as situações', 'O lucro passa a ser maior'),
    ('seed_financas_dificil_v1', 'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 2, 'Os custos acabam sendo cobertos automaticamente pelas vendas', 'As vendas cobrem os custos sozinhas'),
    ('seed_financas_dificil_v1', 'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 3, 'O lucro cresce na mesma proporção do aumento das vendas', 'O lucro cresce junto com as vendas'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 1, 'Quantidade de dinheiro que as famílias guardam no banco', 'Dinheiro que as famílias guardam no banco'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 2, 'Valor atual do salário pago aos trabalhadores no país', 'Salário pago hoje aos trabalhadores'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?', 3, 'Lucro obtido pelas empresas no último ano de atividade', 'Lucro das empresas no último ano'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 2, 'Aumenta junto com os preços', 'Aumenta junto'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 3, 'Duplica automaticamente', 'Duplica depressa'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 0, 'Pode reduzir o valor total das dívidas', 'Pode reduzir o valor das dívidas'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 1, 'Elimina a necessidade de pagar prestações', 'Dispensa o pagamento de prestações'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 3, 'Aumenta o rendimento de quem pediu o empréstimo', 'Aumenta o rendimento de quem pediu')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Finanças (resíduo): % alternativa(s) errada(s) atualizada(s) (esperado: 11).', v_updated;
END $$;
