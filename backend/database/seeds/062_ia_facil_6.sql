-- Seed de conteúdo real: 2 pergunta(s) — Inteligência Artificial — Fácil (lote 6)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/062_ia_facil_6.sql
--
-- DEDUPLICAÇÃO APLICADA: as 2 perguntas do lote são inéditas — nenhuma duplicata encontrada.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (100 — distinta das seeds 42 a 98 já usadas) e distribuição
-- controlada entre A/B/C/D, reprodutível — conteúdo pedagógico inalterado, só
-- a ORDEM de exibição mudou.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v6') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v6) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_ia_facil_v6 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v6'
    FROM (VALUES
      ('Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?'),
      ('O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_ia_facil_v6 q
    JOIN (VALUES
      ('Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 'Substituir fisicamente os computadores', FALSE, 0),
      ('Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 'Responder automaticamente a perguntas frequentes', TRUE, 1),
      ('Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 'Aumentar a capacidade da bateria dos telefones', FALSE, 2),
      ('Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 'Fabricar cabos de rede', FALSE, 3),
      ('O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 'O sistema torna-se automaticamente mais preciso', FALSE, 0),
      ('O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 'O modelo deixa de precisar de treinamento', FALSE, 1),
      ('O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 'Todos os erros são corrigidos automaticamente', FALSE, 2),
      ('O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 'A qualidade dos resultados pode ser prejudicada', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_ia_facil_v6;

    RAISE NOTICE '2 pergunta(s) inserida(s) com sucesso (source=seed_ia_facil_v6).';
  END IF;
END $$;

COMMIT;