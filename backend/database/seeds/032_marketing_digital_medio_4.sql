-- Seed: conteúdo Marketing Digital, nível Médio (9 perguntas)
-- Fonte: lote fornecido pelo proprietário do projeto (10
-- perguntas nesta categoria+dificuldade), filtrado para conter apenas
-- perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-029).
--
-- Das 10 perguntas do lote original, 1 já existiam
-- palavra-por-palavra no banco — foram descartadas. As 9 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (71 — distinta das seeds 42 a 68 já
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v4'
    FROM (VALUES
      ('Qual é a função principal de um funil de marketing?'),
      ('O que é uma isca digital?'),
      ('O que é uma sequência de e-mails automatizada?'),
      ('O que é taxa de abertura de e-mail?'),
      ('O que é taxa de cliques em e-mail marketing?'),
      ('O que é uma estratégia de remarketing eficiente?'),
      ('O que é otimização de anúncios?'),
      ('O que é frequência em anúncios digitais?'),
      ('O que é alcance orgânico?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio4 q
    JOIN (VALUES
      ('Qual é a função principal de um funil de marketing?', 'Guiar o público desde o conhecimento da marca até a conversão', TRUE, 0),
      ('Qual é a função principal de um funil de marketing?', 'Apagar dados', FALSE, 1),
      ('Qual é a função principal de um funil de marketing?', 'Criar computadores', FALSE, 2),
      ('Qual é a função principal de um funil de marketing?', 'Bloquear visitantes', FALSE, 3),
      ('O que é uma isca digital?', 'Vírus de computador', FALSE, 0),
      ('O que é uma isca digital?', 'Produto físico obrigatório', FALSE, 1),
      ('O que é uma isca digital?', 'Anúncio sem objetivo', FALSE, 2),
      ('O que é uma isca digital?', 'Material gratuito oferecido para captar leads', TRUE, 3),
      ('O que é uma sequência de e-mails automatizada?', 'Exclusão de contatos', FALSE, 0),
      ('O que é uma sequência de e-mails automatizada?', 'Envio aleatório de mensagens', FALSE, 1),
      ('O que é uma sequência de e-mails automatizada?', 'Bloqueio de clientes', FALSE, 2),
      ('O que é uma sequência de e-mails automatizada?', 'Série de mensagens enviadas automaticamente conforme uma estratégia', TRUE, 3),
      ('O que é taxa de abertura de e-mail?', 'Número de produtos vendidos', FALSE, 0),
      ('O que é taxa de abertura de e-mail?', 'Quantidade de seguidores', FALSE, 1),
      ('O que é taxa de abertura de e-mail?', 'Percentual de pessoas que abriram uma mensagem enviada', TRUE, 2),
      ('O que é taxa de abertura de e-mail?', 'Valor investido', FALSE, 3),
      ('O que é taxa de cliques em e-mail marketing?', 'Percentual de pessoas que clicaram em links da mensagem', TRUE, 0),
      ('O que é taxa de cliques em e-mail marketing?', 'Tamanho do arquivo', FALSE, 1),
      ('O que é taxa de cliques em e-mail marketing?', 'Quantidade de e-mails criados', FALSE, 2),
      ('O que é taxa de cliques em e-mail marketing?', 'Número de funcionários', FALSE, 3),
      ('O que é uma estratégia de remarketing eficiente?', 'Remover públicos', FALSE, 0),
      ('O que é uma estratégia de remarketing eficiente?', 'Mostrar mensagens relevantes para pessoas que já demonstraram interesse', TRUE, 1),
      ('O que é uma estratégia de remarketing eficiente?', 'Enviar anúncios sem critério', FALSE, 2),
      ('O que é uma estratégia de remarketing eficiente?', 'Ignorar visitantes anteriores', FALSE, 3),
      ('O que é otimização de anúncios?', 'Apagar campanhas', FALSE, 0),
      ('O que é otimização de anúncios?', 'Aumentar custos sem análise', FALSE, 1),
      ('O que é otimização de anúncios?', 'Processo de melhorar campanhas para obter melhores resultados', TRUE, 2),
      ('O que é otimização de anúncios?', 'Criar anúncios aleatórios', FALSE, 3),
      ('O que é frequência em anúncios digitais?', 'Quantidade média de vezes que uma pessoa vê um anúncio', TRUE, 0),
      ('O que é frequência em anúncios digitais?', 'Quantidade de funcionários', FALSE, 1),
      ('O que é frequência em anúncios digitais?', 'Número de computadores', FALSE, 2),
      ('O que é frequência em anúncios digitais?', 'Velocidade da internet', FALSE, 3),
      ('O que é alcance orgânico?', 'Anúncios pagos', FALSE, 0),
      ('O que é alcance orgânico?', 'Pessoas alcançadas sem investimento direto em publicidade', TRUE, 1),
      ('O que é alcance orgânico?', 'Pessoas compradas', FALSE, 2),
      ('O que é alcance orgânico?', 'Usuários falsos', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio4;

    RAISE NOTICE '9 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v4).';
  END IF;
END $$;

COMMIT;
