-- Migration/seed: conteúdo Finanças, nível Difícil — fechamento final (1 pergunta)
-- Fonte: mini-lote "FINANÇAS DIFÍCIL — ADICIONAR: 1 QUESTÃO" fornecido pelo
-- proprietário do projeto, com o objetivo explícito de completar Finanças
-- Difícil para 100 perguntas (99 + 1 = 100).
--
-- Com este arquivo, a categoria Finanças fica completa nos 3 níveis:
-- Fácil 100, Médio 100, Difícil 100.
--
-- Verificado: a pergunta não colide (mesmo enunciado) com as 1072 perguntas
-- já existentes no banco.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): resposta correta originalmente "A"
-- — como há apenas 1 pergunta neste lote, a posição da alternativa correta
-- foi fixada em C (posição 2), mesma convenção usada em
-- 042_marketing_digital_medio_6.sql para não repetir o padrão "sempre A";
-- conteúdo pedagógico inalterado, só a ORDEM de exibição mudou.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_dificil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_dificil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_dificil_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_financas_dificil_v4'
    FROM (VALUES
      ('O que é due diligence financeira?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_dificil_v4 q
    JOIN (VALUES
      ('O que é due diligence financeira?', 'Processo de criação de uma campanha publicitária', FALSE, 0),
      ('O que é due diligence financeira?', 'Sistema usado apenas para controlar funcionários', FALSE, 1),
      ('O que é due diligence financeira?', 'Processo de investigação e análise detalhada das informações financeiras de uma empresa antes de uma decisão importante, como aquisição ou investimento', TRUE, 2),
      ('O que é due diligence financeira?', 'Método utilizado para aumentar preços automaticamente', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_dificil_v4;

    RAISE NOTICE '1 pergunta inserida com sucesso (source=seed_financas_dificil_v4).';
  END IF;
END $$;

COMMIT;
