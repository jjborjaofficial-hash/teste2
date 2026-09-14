-- Migration/seed: conteúdo Marketing Digital, nível Fácil — lote "Fase 1 / Lote 1" (5 de 7 perguntas)
-- Fonte: mini-lote "FASE 1 — LOTE 1" fornecido pelo proprietário do projeto
-- para completar categorias específicas rumo à meta de 100 perguntas por
-- categoria+dificuldade.
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra todo o banco já
-- existente e encontrei 2 repetida(s), removida(s) deste arquivo:
--   - "O que é conteúdo digital?"
--   - "O que é um seguidor?"
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (79 — distinta das
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
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil_v5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v5'
    FROM (VALUES
      ('O que é uma marca no Marketing Digital?'),
      ('Qual é a função de uma rede social para uma empresa?'),
      ('O que é engajamento nas redes sociais?'),
      ('Por que uma empresa cria conteúdos na internet?'),
      ('O que é uma chamada para ação (CTA)?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil_v5 q
    JOIN (VALUES
      ('O que é uma marca no Marketing Digital?', 'Um tipo de computador', FALSE, 0),
      ('O que é uma marca no Marketing Digital?', 'Identidade que representa uma empresa, produto ou serviço', TRUE, 1),
      ('O que é uma marca no Marketing Digital?', 'Um método de pagamento', FALSE, 2),
      ('O que é uma marca no Marketing Digital?', 'Apenas um anúncio pago', FALSE, 3),
      ('Qual é a função de uma rede social para uma empresa?', 'Criar relacionamento e divulgar produtos ou serviços', TRUE, 0),
      ('Qual é a função de uma rede social para uma empresa?', 'Apenas enviar mensagens privadas', FALSE, 1),
      ('Qual é a função de uma rede social para uma empresa?', 'Substituir todos os funcionários', FALSE, 2),
      ('Qual é a função de uma rede social para uma empresa?', 'Eliminar clientes', FALSE, 3),
      ('O que é engajamento nas redes sociais?', 'Número de pagamentos realizados', FALSE, 0),
      ('O que é engajamento nas redes sociais?', 'Tamanho da empresa', FALSE, 1),
      ('O que é engajamento nas redes sociais?', 'Quantidade de computadores usados', FALSE, 2),
      ('O que é engajamento nas redes sociais?', 'Interação dos usuários com um conteúdo publicado', TRUE, 3),
      ('Por que uma empresa cria conteúdos na internet?', 'Para evitar comunicação', FALSE, 0),
      ('Por que uma empresa cria conteúdos na internet?', 'Apenas para ocupar espaço', FALSE, 1),
      ('Por que uma empresa cria conteúdos na internet?', 'Para atrair, informar e criar relacionamento com o público', TRUE, 2),
      ('Por que uma empresa cria conteúdos na internet?', 'Para eliminar concorrentes automaticamente', FALSE, 3),
      ('O que é uma chamada para ação (CTA)?', 'Frase que incentiva o usuário a realizar uma ação', TRUE, 0),
      ('O que é uma chamada para ação (CTA)?', 'Sistema financeiro', FALSE, 1),
      ('O que é uma chamada para ação (CTA)?', 'Ferramenta de edição', FALSE, 2),
      ('O que é uma chamada para ação (CTA)?', 'Tipo de vírus digital', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil_v5;

    RAISE NOTICE '5 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v5).';
  END IF;
END $$;

COMMIT;
