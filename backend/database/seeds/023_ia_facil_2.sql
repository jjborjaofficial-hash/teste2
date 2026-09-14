-- Migration/seed: conteúdo Inteligência Artificial, nível Fácil (6 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 6 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (62 — distinta das seeds 42 a
-- 61 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Inteligência Artificial" (slug: inteligencia-artificial) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_facil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v2'
    FROM (VALUES
      ('O que é um prompt?'),
      ('Por que prompts específicos podem produzir respostas melhores?'),
      ('Uma IA pode cometer erros?'),
      ('Por que informações geradas por IA devem ser verificadas em situações importantes?'),
      ('Qual é uma aplicação comum de IA?'),
      ('O que caracteriza uma IA generativa?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_facil2 q
    JOIN (VALUES
      ('O que é um prompt?', 'Um antivírus', FALSE, 0),
      ('O que é um prompt?', 'Uma senha bancária', FALSE, 1),
      ('O que é um prompt?', 'Instrução ou entrada fornecida a um sistema de IA', TRUE, 2),
      ('O que é um prompt?', 'Uma placa de vídeo', FALSE, 3),
      ('Por que prompts específicos podem produzir respostas melhores?', 'Eliminam qualquer possibilidade de erro', FALSE, 0),
      ('Por que prompts específicos podem produzir respostas melhores?', 'Fornecem mais contexto e orientações ao modelo', TRUE, 1),
      ('Por que prompts específicos podem produzir respostas melhores?', 'Mudam o hardware', FALSE, 2),
      ('Por que prompts específicos podem produzir respostas melhores?', 'Aumentam automaticamente a velocidade da internet', FALSE, 3),
      ('Uma IA pode cometer erros?', 'Apenas quando está offline', FALSE, 0),
      ('Uma IA pode cometer erros?', 'Apenas em computadores antigos', FALSE, 1),
      ('Uma IA pode cometer erros?', 'Não, nunca', FALSE, 2),
      ('Uma IA pode cometer erros?', 'Sim', TRUE, 3),
      ('Por que informações geradas por IA devem ser verificadas em situações importantes?', 'Porque modelos podem produzir informações incorretas', TRUE, 0),
      ('Por que informações geradas por IA devem ser verificadas em situações importantes?', 'Porque a internet deixa de funcionar', FALSE, 1),
      ('Por que informações geradas por IA devem ser verificadas em situações importantes?', 'Porque IA nunca produz texto', FALSE, 2),
      ('Por que informações geradas por IA devem ser verificadas em situações importantes?', 'Porque toda informação é necessariamente falsa', FALSE, 3),
      ('Qual é uma aplicação comum de IA?', 'Apenas televisores antigos', FALSE, 0),
      ('Qual é uma aplicação comum de IA?', 'Assistentes virtuais', TRUE, 1),
      ('Qual é uma aplicação comum de IA?', 'Somente relógios analógicos', FALSE, 2),
      ('Qual é uma aplicação comum de IA?', 'Apenas calculadoras mecânicas', FALSE, 3),
      ('O que caracteriza uma IA generativa?', 'Capacidade de gerar conteúdos como texto, imagens, áudio ou código', TRUE, 0),
      ('O que caracteriza uma IA generativa?', 'Apenas armazenar arquivos', FALSE, 1),
      ('O que caracteriza uma IA generativa?', 'Apenas conectar dispositivos', FALSE, 2),
      ('O que caracteriza uma IA generativa?', 'Somente calcular números', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_facil2;

    RAISE NOTICE '6 perguntas inseridas com sucesso (source=seed_ia_facil_v2).';
  END IF;
END $$;

COMMIT;
