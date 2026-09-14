-- Migration/seed: conteúdo Finanças, nível Difícil — adição extra (1 pergunta)
-- Fonte: pergunta fornecida pelo proprietário do projeto ("Uma pessoa possui
-- uma dívida de 50.000 MZN com juros compostos de 10% ao ano...").
--
-- CONTEXTO IMPORTANTE: Finanças Difícil já havia sido fechada em 100
-- perguntas pelo seed 045_financas_dificil_4.sql (pergunta "O que é due
-- diligence financeira?", uma pergunta DIFERENTE desta). O proprietário do
-- projeto confirmou explicitamente que quer esta pergunta adicionada MESMO
-- ASSIM, mesmo excedendo a meta — Finanças Difícil fica com 101 perguntas
-- após este arquivo, não 100.
--
-- Verificação de cálculo (conferida independentemente antes de aceitar a
-- alternativa C como correta): 50.000 MZN a juros compostos de 10% ao ano,
-- sem pagamentos, após 2 anos = 50.000 × (1,10)² = 50.000 × 1,21 = 60.500
-- MZN. Bate com a alternativa C informada pelo proprietário do projeto.
--
-- Verificado: não há nenhuma outra pergunta idêntica a esta (o texto
-- "juros compostos" aparece em 3 outros lugares do banco — 001, 017, 035 —
-- mas todas são perguntas conceituais de definição, não este problema
-- numérico específico).
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): resposta correta já veio na
-- posição C (não "A") no material original — nenhuma redistribuição foi
-- necessária para evitar o padrão "sempre A" detectado em lotes anteriores.
-- Ainda assim, usamos uma seed fixa (91 — distinta das seeds 42 a 90 já
-- usadas) para manter o registro rastreável do processo, seguindo a mesma
-- convenção dos demais arquivos, mesmo não havendo troca de posição a
-- fazer neste caso (lote de 1 pergunta só).
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_dificil_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_dificil_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_dificil_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_financas_dificil_v5'
    FROM (VALUES
      ('Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_dificil_v5 q
    JOIN (VALUES
      ('Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?', '55.000 MZN', FALSE, 0),
      ('Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?', '60.000 MZN', FALSE, 1),
      ('Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?', '60.500 MZN', TRUE, 2),
      ('Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?', '65.000 MZN', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_dificil_v5;

    RAISE NOTICE '1 pergunta inserida com sucesso (source=seed_financas_dificil_v5).';
  END IF;
END $$;

COMMIT;
