-- Migration/seed: conteúdo Finanças, nível Fácil — lote "Fase 1 / Lote 1" (3 de 3 perguntas)
-- Fonte: mini-lote "FASE 1 — LOTE 1" fornecido pelo proprietário do projeto
-- para completar categorias específicas rumo à meta de 100 perguntas por
-- categoria+dificuldade.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (77 — distinta das
-- seeds 42 a 74 já usadas) e distribuição controlada entre A/B/C/D,
-- reprodutível — conteúdo pedagógico inalterado, só a ORDEM de exibição
-- mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_facil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_facil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_facil_v3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_financas_facil_v3'
    FROM (VALUES
      ('O que é uma conta de poupança?'),
      ('Por que é importante guardar parte da renda?'),
      ('O que é uma despesa desnecessária?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_facil_v3 q
    JOIN (VALUES
      ('O que é uma conta de poupança?', 'Conta destinada a guardar dinheiro e receber rendimentos', TRUE, 0),
      ('O que é uma conta de poupança?', 'Cartão de crédito', FALSE, 1),
      ('O que é uma conta de poupança?', 'Tipo de empréstimo', FALSE, 2),
      ('O que é uma conta de poupança?', 'Conta usada apenas para fazer dívidas', FALSE, 3),
      ('Por que é importante guardar parte da renda?', 'Para evitar qualquer planejamento', FALSE, 0),
      ('Por que é importante guardar parte da renda?', 'Para perder poder de compra', FALSE, 1),
      ('Por que é importante guardar parte da renda?', 'Para criar segurança financeira e alcançar objetivos futuros', TRUE, 2),
      ('Por que é importante guardar parte da renda?', 'Para aumentar despesas', FALSE, 3),
      ('O que é uma despesa desnecessária?', 'Pagamento obrigatório', FALSE, 0),
      ('O que é uma despesa desnecessária?', 'Gasto que pode ser evitado sem prejudicar necessidades básicas', TRUE, 1),
      ('O que é uma despesa desnecessária?', 'Investimento importante', FALSE, 2),
      ('O que é uma despesa desnecessária?', 'Conta essencial', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_facil_v3;

    RAISE NOTICE '3 perguntas inseridas com sucesso (source=seed_financas_facil_v3).';
  END IF;
END $$;

COMMIT;
