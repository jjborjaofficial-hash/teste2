-- Migration/seed: conteúdo Marketing Digital, nível Médio — fechamento (1 pergunta)
-- Fonte: mini-lote "FECHAMENTO DE CATEGORIA — MARKETING DIGITAL" fornecido
-- pelo proprietário do projeto, com o objetivo explícito de completar
-- Marketing Digital Médio para 100 perguntas (99 + 1 = 100). Com este
-- arquivo, Marketing Digital fica completo nos 3 níveis (Fácil, Médio e
-- Difícil, este último já em 106).
--
-- Verificado: a pergunta não colide (mesmo enunciado) com as 1001 perguntas
-- já existentes no banco.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): resposta correta originalmente "A"
-- — como há apenas 1 pergunta neste lote, a posição da alternativa correta
-- foi fixada em C (posição 2) com seed fixa (81 — distinta das seeds 42 a
-- 80 já usadas), para não repetir o padrão "sempre A"; conteúdo pedagógico
-- inalterado, só a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v6') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v6) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio_v6 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v6'
    FROM (VALUES
      ('O que é segmentação de público em Marketing Digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio_v6 q
    JOIN (VALUES
      ('O que é segmentação de público em Marketing Digital?', 'Divisão dos consumidores em grupos com características ou interesses semelhantes', TRUE, 0),
      ('O que é segmentação de público em Marketing Digital?', 'Envio da mesma mensagem para todas as pessoas', FALSE, 1),
      ('O que é segmentação de público em Marketing Digital?', 'Exclusão de clientes antigos', FALSE, 2),
      ('O que é segmentação de público em Marketing Digital?', 'Criação de produtos sem pesquisa', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio_v6;

    RAISE NOTICE '1 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v6).';
  END IF;
END $$;

COMMIT;
