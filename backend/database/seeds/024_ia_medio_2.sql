-- Migration/seed: conteúdo Inteligência Artificial, nível Médio (5 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 5 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (63 — distinta das seeds 42 a
-- 62 já usadas nos seeds anteriores) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_medio_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_medio_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_medio2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_ia_medio_v2'
    FROM (VALUES
      ('O que é reconhecimento de padrões?'),
      ('O que é viés em IA?'),
      ('O que é automação com IA?'),
      ('O que significa treinamento de um modelo?'),
      ('Qual é uma preocupação importante ao utilizar IA com dados pessoais?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_medio2 q
    JOIN (VALUES
      ('O que é reconhecimento de padrões?', 'Identificação de regularidades em dados', TRUE, 0),
      ('O que é reconhecimento de padrões?', 'Formatação de computadores', FALSE, 1),
      ('O que é reconhecimento de padrões?', 'Criação manual de documentos', FALSE, 2),
      ('O que é reconhecimento de padrões?', 'Exclusão de informações', FALSE, 3),
      ('O que é viés em IA?', 'Tipo de teclado', FALSE, 0),
      ('O que é viés em IA?', 'Aumento da memória RAM', FALSE, 1),
      ('O que é viés em IA?', 'Tendência sistemática que pode influenciar resultados', TRUE, 2),
      ('O que é viés em IA?', 'Velocidade de internet', FALSE, 3),
      ('O que é automação com IA?', 'Remover dados', FALSE, 0),
      ('O que é automação com IA?', 'Uso de IA para executar ou apoiar processos automaticamente', TRUE, 1),
      ('O que é automação com IA?', 'Criar cabos', FALSE, 2),
      ('O que é automação com IA?', 'Desligar computadores', FALSE, 3),
      ('O que significa treinamento de um modelo?', 'Processo de ajustar o modelo utilizando dados', TRUE, 0),
      ('O que significa treinamento de um modelo?', 'Criação de uma conta bancária', FALSE, 1),
      ('O que significa treinamento de um modelo?', 'Limpeza física do computador', FALSE, 2),
      ('O que significa treinamento de um modelo?', 'Instalação de um teclado', FALSE, 3),
      ('Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 'Cor do computador', FALSE, 0),
      ('Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 'Tamanho da tela', FALSE, 1),
      ('Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 'Marca do teclado', FALSE, 2),
      ('Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 'Privacidade e proteção dos dados', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_medio2;

    RAISE NOTICE '5 perguntas inseridas com sucesso (source=seed_ia_medio_v2).';
  END IF;
END $$;

COMMIT;
