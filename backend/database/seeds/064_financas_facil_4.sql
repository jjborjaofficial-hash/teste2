-- Seed de conteúdo real: 1 pergunta — Finanças — Fácil (lote 4)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/064_financas_facil_4.sql
--
-- ORIGEM: pergunta escrita por nós (Claude), não pelo proprietário do
-- projeto, para fechar a lacuna de Finanças Fácil (presa em 99 há 3
-- tentativas seguidas por causa de duplicatas/quase-duplicatas de
-- 'orçamento pessoal'/'poupar'/'despesa'). Conceito escolhido ('conta
-- poupança') foi conferido contra TODO o banco de seeds antes de escrever —
-- zero ocorrências prévias do termo em qualquer arquivo. Vale o proprietário
-- do projeto revisar o enunciado/alternativas antes de considerar definitivo,
-- já que não veio do material original fornecido por ele.
--
-- Posição da resposta correta definida com seed fixa (102 — distinta
-- das seeds 42 a 101 já usadas), mesma convenção dos demais arquivos.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_facil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_facil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_financas_facil_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_financas_facil_v4'
    FROM (VALUES
      ('O que é uma conta poupança?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_financas_facil_v4 q
    JOIN (VALUES
      ('O que é uma conta poupança?', 'Um documento usado para pagar impostos', FALSE, 0),
      ('O que é uma conta poupança?', 'Um tipo de conta bancária destinada a guardar dinheiro, geralmente rendendo juros ao longo do tempo', TRUE, 1),
      ('O que é uma conta poupança?', 'Um cartão utilizado exclusivamente para fazer compras a crédito', FALSE, 2),
      ('O que é uma conta poupança?', 'Um tipo de empréstimo bancário', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_financas_facil_v4;

    RAISE NOTICE '1 pergunta inserida com sucesso (source=seed_financas_facil_v4).';
  END IF;
END $$;

COMMIT;