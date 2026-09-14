-- Seed: conteúdo Marketing Digital, nível Difícil (12 perguntas)
-- Fonte: lote fornecido pelo proprietário do projeto (12
-- perguntas nesta categoria+dificuldade), filtrado para conter apenas
-- perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-029).
--
-- Das 12 perguntas do lote original, 0 já existiam
-- palavra-por-palavra no banco — foram descartadas. As 12 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (72 — distinta das seeds 42 a 68 já
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_dificil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_dificil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_dificil4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_marketing_digital_dificil_v4'
    FROM (VALUES
      ('O que é Marketing baseado em contas (ABM)?'),
      ('O que é atribuição linear em marketing?'),
      ('O que é uma métrica North Star?'),
      ('O que é análise de coorte?'),
      ('O que é um mapa de calor (Heatmap)?'),
      ('O que é intenção de busca no SEO?'),
      ('O que é SEO semântico?'),
      ('O que é cannibalização de palavras-chave?'),
      ('O que é atribuição baseada em posição?'),
      ('O que é personalização preditiva?'),
      ('O que é experimentação de crescimento?'),
      ('O que é marketing orientado por dados?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_dificil4 q
    JOIN (VALUES
      ('O que é Marketing baseado em contas (ABM)?', 'Estratégia focada em empresas ou clientes específicos de alto valor', TRUE, 0),
      ('O que é Marketing baseado em contas (ABM)?', 'Publicidade offline', FALSE, 1),
      ('O que é Marketing baseado em contas (ABM)?', 'Venda sem segmentação', FALSE, 2),
      ('O que é Marketing baseado em contas (ABM)?', 'Divulgação aleatória para todos', FALSE, 3),
      ('O que é atribuição linear em marketing?', 'Modelo sem dados', FALSE, 0),
      ('O que é atribuição linear em marketing?', 'Modelo que ignora clientes', FALSE, 1),
      ('O que é atribuição linear em marketing?', 'Modelo que considera apenas o último clique', FALSE, 2),
      ('O que é atribuição linear em marketing?', 'Modelo que distribui crédito igualmente entre vários pontos de contato', TRUE, 3),
      ('O que é uma métrica North Star?', 'Quantidade de anúncios', FALSE, 0),
      ('O que é uma métrica North Star?', 'Número de seguidores', FALSE, 1),
      ('O que é uma métrica North Star?', 'Indicador principal que representa o valor entregue ao cliente', TRUE, 2),
      ('O que é uma métrica North Star?', 'Número de computadores', FALSE, 3),
      ('O que é análise de coorte?', 'Alteração de preços', FALSE, 0),
      ('O que é análise de coorte?', 'Exclusão de clientes antigos', FALSE, 1),
      ('O que é análise de coorte?', 'Criação de anúncios', FALSE, 2),
      ('O que é análise de coorte?', 'Estudo de grupos de usuários com características ou períodos semelhantes', TRUE, 3),
      ('O que é um mapa de calor (Heatmap)?', 'Ferramenta que mostra como usuários interagem com uma página', TRUE, 0),
      ('O que é um mapa de calor (Heatmap)?', 'Rede social', FALSE, 1),
      ('O que é um mapa de calor (Heatmap)?', 'Sistema de segurança física', FALSE, 2),
      ('O que é um mapa de calor (Heatmap)?', 'Banco de dados', FALSE, 3),
      ('O que é intenção de busca no SEO?', 'Tamanho da página', FALSE, 0),
      ('O que é intenção de busca no SEO?', 'Quantidade de palavras digitadas', FALSE, 1),
      ('O que é intenção de busca no SEO?', 'Velocidade do navegador', FALSE, 2),
      ('O que é intenção de busca no SEO?', 'Motivo pelo qual uma pessoa realiza determinada pesquisa', TRUE, 3),
      ('O que é SEO semântico?', 'Apenas repetir palavras-chave', FALSE, 0),
      ('O que é SEO semântico?', 'Criar anúncios pagos', FALSE, 1),
      ('O que é SEO semântico?', 'Estratégia de otimizar conteúdos considerando significado e contexto das pesquisas', TRUE, 2),
      ('O que é SEO semântico?', 'Apagar conteúdos', FALSE, 3),
      ('O que é cannibalização de palavras-chave?', 'Quando várias páginas do mesmo site competem pela mesma palavra-chave', TRUE, 0),
      ('O que é cannibalização de palavras-chave?', 'Quando um site fecha', FALSE, 1),
      ('O que é cannibalização de palavras-chave?', 'Quando um anúncio viraliza', FALSE, 2),
      ('O que é cannibalização de palavras-chave?', 'Quando aumenta seguidores', FALSE, 3),
      ('O que é atribuição baseada em posição?', 'Modelo sem análise', FALSE, 0),
      ('O que é atribuição baseada em posição?', 'Modelo que dá maior importância aos primeiros e últimos contatos da jornada', TRUE, 1),
      ('O que é atribuição baseada em posição?', 'Modelo aleatório', FALSE, 2),
      ('O que é atribuição baseada em posição?', 'Modelo apenas offline', FALSE, 3),
      ('O que é personalização preditiva?', 'Envio igual para todos', FALSE, 0),
      ('O que é personalização preditiva?', 'Publicação manual', FALSE, 1),
      ('O que é personalização preditiva?', 'Uso de dados e inteligência artificial para antecipar necessidades do usuário', TRUE, 2),
      ('O que é personalização preditiva?', 'Remoção de dados', FALSE, 3),
      ('O que é experimentação de crescimento?', 'Copiar concorrentes', FALSE, 0),
      ('O que é experimentação de crescimento?', 'Processo contínuo de testar hipóteses para encontrar oportunidades de crescimento', TRUE, 1),
      ('O que é experimentação de crescimento?', 'Fazer campanhas sem medir', FALSE, 2),
      ('O que é experimentação de crescimento?', 'Evitar mudanças', FALSE, 3),
      ('O que é marketing orientado por dados?', 'Decisões apenas por opinião', FALSE, 0),
      ('O que é marketing orientado por dados?', 'Tomada de decisões baseada em informações e análises reais', TRUE, 1),
      ('O que é marketing orientado por dados?', 'Publicação sem objetivo', FALSE, 2),
      ('O que é marketing orientado por dados?', 'Estratégia sem métricas', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_dificil4;

    RAISE NOTICE '12 perguntas inseridas com sucesso (source=seed_marketing_digital_dificil_v4).';
  END IF;
END $$;

COMMIT;
