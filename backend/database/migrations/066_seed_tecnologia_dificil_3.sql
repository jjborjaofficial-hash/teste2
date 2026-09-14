-- Migration/seed: conteúdo Tecnologia, nível Difícil — lote "Fase 1 / Lote 1" (2 de 2 perguntas)
-- Fonte: mini-lote "FASE 1 — LOTE 1" fornecido pelo proprietário do projeto
-- para completar categorias específicas rumo à meta de 100 perguntas por
-- categoria+dificuldade.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (75 — distinta das
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
  SELECT id INTO v_category_id FROM categories WHERE slug = 'tecnologia';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "tecnologia" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_dificil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_tecnologia_dificil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_dificil_v2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_tecnologia_dificil_v3'
    FROM (VALUES
      ('Qual é a principal finalidade de uma arquitetura de microsserviços?'),
      ('O que é computação em nuvem híbrida?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_dificil_v2 q
    JOIN (VALUES
      ('Qual é a principal finalidade de uma arquitetura de microsserviços?', 'Dividir uma aplicação grande em pequenos serviços independentes que comunicam entre si', TRUE, 0),
      ('Qual é a principal finalidade de uma arquitetura de microsserviços?', 'Colocar todos os códigos em um único arquivo', FALSE, 1),
      ('Qual é a principal finalidade de uma arquitetura de microsserviços?', 'Eliminar completamente bancos de dados', FALSE, 2),
      ('Qual é a principal finalidade de uma arquitetura de microsserviços?', 'Substituir todos os servidores físicos', FALSE, 3),
      ('O que é computação em nuvem híbrida?', 'Armazenamento somente em dispositivos móveis', FALSE, 0),
      ('O que é computação em nuvem híbrida?', 'Modelo que combina infraestrutura local com serviços de nuvem', TRUE, 1),
      ('O que é computação em nuvem híbrida?', 'Uso apenas de computadores pessoais', FALSE, 2),
      ('O que é computação em nuvem híbrida?', 'Sistema sem conexão com internet', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_dificil_v2;

    RAISE NOTICE '2 perguntas inseridas com sucesso (source=seed_tecnologia_dificil_v3).';
  END IF;
END $$;

COMMIT;
