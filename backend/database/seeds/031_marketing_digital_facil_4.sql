-- Seed: conteúdo Marketing Digital, nível Fácil (8 perguntas)
-- Fonte: lote fornecido pelo proprietário do projeto (10
-- perguntas nesta categoria+dificuldade), filtrado para conter apenas
-- perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-029).
--
-- Das 10 perguntas do lote original, 2 já existiam
-- palavra-por-palavra no banco — foram descartadas. As 8 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (70 — distinta das seeds 42 a 68 já
-- usadas nos seeds anteriores) e distribuição controlada entre A/B/C/D,
-- reprodutível — o conteúdo pedagógico permanece exatamente como enviado,
-- só a ORDEM de exibição mudou.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v4'
    FROM (VALUES
      ('O que é uma página de captura?'),
      ('Qual informação é normalmente solicitada em uma página de captura?'),
      ('Qual destes é um exemplo de produto digital?'),
      ('O que é uma publicação patrocinada?'),
      ('O que é uma bio em uma rede social?'),
      ('Por que uma empresa deve responder comentários nas redes sociais?'),
      ('O que é um nicho de mercado?'),
      ('O que é uma chamada de atenção em um anúncio?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil4 q
    JOIN (VALUES
      ('O que é uma página de captura?', 'Página de configuração do computador', FALSE, 0),
      ('O que é uma página de captura?', 'Página sem objetivo definido', FALSE, 1),
      ('O que é uma página de captura?', 'Página criada para recolher informações de potenciais clientes', TRUE, 2),
      ('O que é uma página de captura?', 'Página usada para apagar dados', FALSE, 3),
      ('Qual informação é normalmente solicitada em uma página de captura?', 'Código do computador', FALSE, 0),
      ('Qual informação é normalmente solicitada em uma página de captura?', 'Senha do banco', FALSE, 1),
      ('Qual informação é normalmente solicitada em uma página de captura?', 'Número do processador', FALSE, 2),
      ('Qual informação é normalmente solicitada em uma página de captura?', 'Nome e e-mail do visitante', TRUE, 3),
      ('Qual destes é um exemplo de produto digital?', 'Curso online', TRUE, 0),
      ('Qual destes é um exemplo de produto digital?', 'Teclado físico', FALSE, 1),
      ('Qual destes é um exemplo de produto digital?', 'Mesa de escritório', FALSE, 2),
      ('Qual destes é um exemplo de produto digital?', 'Impressora', FALSE, 3),
      ('O que é uma publicação patrocinada?', 'Conteúdo que recebe investimento para alcançar mais pessoas', TRUE, 0),
      ('O que é uma publicação patrocinada?', 'Arquivo protegido', FALSE, 1),
      ('O que é uma publicação patrocinada?', 'Publicação apagada', FALSE, 2),
      ('O que é uma publicação patrocinada?', 'Mensagem privada', FALSE, 3),
      ('O que é uma bio em uma rede social?', 'Programa de edição', FALSE, 0),
      ('O que é uma bio em uma rede social?', 'Sistema de pagamento', FALSE, 1),
      ('O que é uma bio em uma rede social?', 'Banco de dados', FALSE, 2),
      ('O que é uma bio em uma rede social?', 'Espaço de apresentação de um perfil', TRUE, 3),
      ('Por que uma empresa deve responder comentários nas redes sociais?', 'Para bloquear usuários', FALSE, 0),
      ('Por que uma empresa deve responder comentários nas redes sociais?', 'Para criar relacionamento e confiança com o público', TRUE, 1),
      ('Por que uma empresa deve responder comentários nas redes sociais?', 'Para diminuir alcance', FALSE, 2),
      ('Por que uma empresa deve responder comentários nas redes sociais?', 'Para apagar seguidores', FALSE, 3),
      ('O que é um nicho de mercado?', 'Todos os usuários da internet', FALSE, 0),
      ('O que é um nicho de mercado?', 'Sistema de anúncios', FALSE, 1),
      ('O que é um nicho de mercado?', 'Segmento específico de pessoas com interesses semelhantes', TRUE, 2),
      ('O que é um nicho de mercado?', 'Apenas concorrentes', FALSE, 3),
      ('O que é uma chamada de atenção em um anúncio?', 'Senha', FALSE, 0),
      ('O que é uma chamada de atenção em um anúncio?', 'Elemento usado para despertar interesse do público', TRUE, 1),
      ('O que é uma chamada de atenção em um anúncio?', 'Erro de sistema', FALSE, 2),
      ('O que é uma chamada de atenção em um anúncio?', 'Arquivo oculto', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil4;

    RAISE NOTICE '8 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v4).';
  END IF;
END $$;

COMMIT;
