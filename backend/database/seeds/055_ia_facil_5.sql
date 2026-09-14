-- Seed de conteúdo real: 2 pergunta(s) — Inteligência Artificial — Fácil (lote 5, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/055_ia_facil_5.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original enviado tinha mais perguntas; as que
-- já existiam (texto idêntico) em outros seeds foram removidas deste arquivo —
-- ver CHANGELOG para a lista completa do que foi descartado e por quê.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (93 — distinta das seeds 42 a 91 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_ia_facil_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v5'
    FROM (VALUES
      ('Qual é um exemplo de aplicação de Inteligência Artificial?'),
      ('Para que modelos de IA precisam de dados durante o treinamento?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_ia_facil_v5 q
    JOIN (VALUES
      ('Qual é um exemplo de aplicação de Inteligência Artificial?', 'Uma folha de papel', FALSE, 0),
      ('Qual é um exemplo de aplicação de Inteligência Artificial?', 'Uma tomada elétrica comum', FALSE, 1),
      ('Qual é um exemplo de aplicação de Inteligência Artificial?', 'Uma cadeira', FALSE, 2),
      ('Qual é um exemplo de aplicação de Inteligência Artificial?', 'Assistentes virtuais', TRUE, 3),
      ('Para que modelos de IA precisam de dados durante o treinamento?', 'Para aumentar o tamanho físico do computador', FALSE, 0),
      ('Para que modelos de IA precisam de dados durante o treinamento?', 'Para substituir a eletricidade', FALSE, 1),
      ('Para que modelos de IA precisam de dados durante o treinamento?', 'Para aprender padrões e relações', TRUE, 2),
      ('Para que modelos de IA precisam de dados durante o treinamento?', 'Para desligar o sistema', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_ia_facil_v5;

    RAISE NOTICE '2 pergunta(s) inserida(s) com sucesso (source=seed_ia_facil_v5).';
  END IF;
END $$;

COMMIT;