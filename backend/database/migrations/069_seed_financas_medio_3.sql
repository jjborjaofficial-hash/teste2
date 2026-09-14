-- Migration/seed: conteúdo Finanças, nível Médio — lote "Fase 1 / Lote 1" (3 de 3 perguntas)
-- Fonte: mini-lote "FASE 1 — LOTE 1" fornecido pelo proprietário do projeto
-- para completar categorias específicas rumo à meta de 100 perguntas por
-- categoria+dificuldade.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (78 — distinta das
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_medio_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_medio_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_medio_v3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_financas_medio_v3'
    FROM (VALUES
      ('O que é uma taxa de retorno de investimento?'),
      ('Qual é a vantagem de criar uma carteira de investimentos diversificada?'),
      ('O que significa viver abaixo das próprias possibilidades financeiras?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_medio_v3 q
    JOIN (VALUES
      ('O que é uma taxa de retorno de investimento?', 'Valor da conta bancária', FALSE, 0),
      ('O que é uma taxa de retorno de investimento?', 'Percentual de ganho ou perda obtido em uma aplicação financeira', TRUE, 1),
      ('O que é uma taxa de retorno de investimento?', 'Número de clientes', FALSE, 2),
      ('O que é uma taxa de retorno de investimento?', 'Quantidade de dinheiro gasto', FALSE, 3),
      ('Qual é a vantagem de criar uma carteira de investimentos diversificada?', 'Garantir lucro em todos os investimentos', FALSE, 0),
      ('Qual é a vantagem de criar uma carteira de investimentos diversificada?', 'Evitar qualquer análise financeira', FALSE, 1),
      ('Qual é a vantagem de criar uma carteira de investimentos diversificada?', 'Reduzir riscos distribuindo recursos em diferentes ativos', TRUE, 2),
      ('Qual é a vantagem de criar uma carteira de investimentos diversificada?', 'Eliminar todos os custos', FALSE, 3),
      ('O que significa viver abaixo das próprias possibilidades financeiras?', 'Gastar menos do que recebe e conseguir guardar recursos', TRUE, 0),
      ('O que significa viver abaixo das próprias possibilidades financeiras?', 'Gastar todo o salário', FALSE, 1),
      ('O que significa viver abaixo das próprias possibilidades financeiras?', 'Evitar qualquer planejamento', FALSE, 2),
      ('O que significa viver abaixo das próprias possibilidades financeiras?', 'Fazer mais dívidas', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_medio_v3;

    RAISE NOTICE '3 perguntas inseridas com sucesso (source=seed_financas_medio_v3).';
  END IF;
END $$;

COMMIT;
