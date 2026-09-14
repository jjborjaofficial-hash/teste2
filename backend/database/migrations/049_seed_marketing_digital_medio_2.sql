-- Migration/seed: conteúdo Marketing Digital, nível Médio (28 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 28 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (58 — distinta das seeds 42 a
-- 57 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Marketing Digital" (slug: marketing-digital) já existe desde a
-- migration 021.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v2'
    FROM (VALUES
      ('O que é uma persona de marketing?'),
      ('Por que uma empresa deve conhecer os problemas do seu público?'),
      ('O que é posicionamento de marca?'),
      ('O que é proposta de valor?'),
      ('Qual é uma vantagem de produzir conteúdo educativo?'),
      ('O que é conteúdo de entretenimento?'),
      ('O que é conteúdo de prova social?'),
      ('O que é taxa de cliques?'),
      ('Por que a taxa de cliques pode ser importante?'),
      ('O que significa conversão em uma campanha?'),
      ('Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?'),
      ('O que é custo por clique?'),
      ('O que significa alcance orgânico?'),
      ('Qual é uma vantagem de combinar tráfego orgânico e pago?'),
      ('Por que analisar o desempenho de uma publicação?'),
      ('Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?'),
      ('Por que clientes recorrentes podem ser importantes?'),
      ('O que é aquisição de clientes?'),
      ('O que é custo de aquisição de cliente, ou CAC?'),
      ('Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?'),
      ('O que é relacionamento com o cliente?'),
      ('O que significa personalizar uma comunicação?'),
      ('Por que a segmentação pode melhorar uma campanha?'),
      ('O que é remarketing baseado em interação?'),
      ('Qual é o objetivo de uma landing page?'),
      ('O que é branding?'),
      ('O que caracteriza uma estratégia de conteúdo?'),
      ('O que uma análise de concorrentes pode revelar?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio2 q
    JOIN (VALUES
      ('O que é uma persona de marketing?', 'Qualquer funcionário da empresa', FALSE, 0),
      ('O que é uma persona de marketing?', 'Um concorrente', FALSE, 1),
      ('O que é uma persona de marketing?', 'Representação semifictícia de um cliente ideal baseada em características e necessidades', TRUE, 2),
      ('O que é uma persona de marketing?', 'Um anúncio pago', FALSE, 3),
      ('Por que uma empresa deve conhecer os problemas do seu público?', 'Para eliminar comentários', FALSE, 0),
      ('Por que uma empresa deve conhecer os problemas do seu público?', 'Para evitar criar produtos', FALSE, 1),
      ('Por que uma empresa deve conhecer os problemas do seu público?', 'Para desenvolver comunicação e ofertas mais relevantes', TRUE, 2),
      ('Por que uma empresa deve conhecer os problemas do seu público?', 'Para aumentar impostos', FALSE, 3),
      ('O que é posicionamento de marca?', 'Número de funcionários', FALSE, 0),
      ('O que é posicionamento de marca?', 'Forma como uma marca busca ser percebida na mente do público em relação às alternativas', TRUE, 1),
      ('O que é posicionamento de marca?', 'Apenas localização física da empresa', FALSE, 2),
      ('O que é posicionamento de marca?', 'Quantidade de produtos no estoque', FALSE, 3),
      ('O que é proposta de valor?', 'Um documento fiscal', FALSE, 0),
      ('O que é proposta de valor?', 'Apenas o preço de um produto', FALSE, 1),
      ('O que é proposta de valor?', 'Uma lista de funcionários', FALSE, 2),
      ('O que é proposta de valor?', 'Explicação do valor ou benefício que uma oferta pretende proporcionar ao cliente', TRUE, 3),
      ('Qual é uma vantagem de produzir conteúdo educativo?', 'Impede críticas', FALSE, 0),
      ('Qual é uma vantagem de produzir conteúdo educativo?', 'Pode aumentar autoridade e confiança junto ao público', TRUE, 1),
      ('Qual é uma vantagem de produzir conteúdo educativo?', 'Elimina todos os concorrentes', FALSE, 2),
      ('Qual é uma vantagem de produzir conteúdo educativo?', 'Garante vendas instantâneas', FALSE, 3),
      ('O que é conteúdo de entretenimento?', 'Formulário de pagamento', FALSE, 0),
      ('O que é conteúdo de entretenimento?', 'Documento financeiro', FALSE, 1),
      ('O que é conteúdo de entretenimento?', 'Contrato comercial', FALSE, 2),
      ('O que é conteúdo de entretenimento?', 'Conteúdo desenvolvido principalmente para informar de maneira divertida ou proporcionar entretenimento', TRUE, 3),
      ('O que é conteúdo de prova social?', 'Apenas propaganda institucional', FALSE, 0),
      ('O que é conteúdo de prova social?', 'Conteúdo sem relação com consumidores', FALSE, 1),
      ('O que é conteúdo de prova social?', 'Um relatório bancário', FALSE, 2),
      ('O que é conteúdo de prova social?', 'Conteúdo que demonstra experiências, avaliações ou resultados de clientes', TRUE, 3),
      ('O que é taxa de cliques?', 'Percentual de pessoas que clicam em determinado elemento após vê-lo', TRUE, 0),
      ('O que é taxa de cliques?', 'Valor total das vendas', FALSE, 1),
      ('O que é taxa de cliques?', 'Número de funcionários', FALSE, 2),
      ('O que é taxa de cliques?', 'Quantidade de produtos', FALSE, 3),
      ('Por que a taxa de cliques pode ser importante?', 'Garante conversão', FALSE, 0),
      ('Por que a taxa de cliques pode ser importante?', 'Ajuda a avaliar se uma mensagem ou anúncio está estimulando cliques', TRUE, 1),
      ('Por que a taxa de cliques pode ser importante?', 'Mede apenas o lucro', FALSE, 2),
      ('Por que a taxa de cliques pode ser importante?', 'Mede diretamente a qualidade do produto', FALSE, 3),
      ('O que significa conversão em uma campanha?', 'Exclusivamente curtida', FALSE, 0),
      ('O que significa conversão em uma campanha?', 'Realização da ação definida como objetivo da campanha', TRUE, 1),
      ('O que significa conversão em uma campanha?', 'Apenas visualização de um anúncio', FALSE, 2),
      ('O que significa conversão em uma campanha?', 'Apenas abertura de uma página', FALSE, 3),
      ('Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?', '5%', TRUE, 0),
      ('Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?', '10%', FALSE, 1),
      ('Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?', '20%', FALSE, 2),
      ('Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?', '2%', FALSE, 3),
      ('O que é custo por clique?', 'Valor médio pago por cada clique em uma campanha publicitária', TRUE, 0),
      ('O que é custo por clique?', 'Salário de um funcionário', FALSE, 1),
      ('O que é custo por clique?', 'Valor total de todos os produtos', FALSE, 2),
      ('O que é custo por clique?', 'Preço de venda do produto', FALSE, 3),
      ('O que significa alcance orgânico?', 'Pessoas alcançadas sem pagamento direto por publicidade para aquela distribuição', TRUE, 0),
      ('O que significa alcance orgânico?', 'Número de funcionários', FALSE, 1),
      ('O que significa alcance orgânico?', 'Pessoas que compraram o produto', FALSE, 2),
      ('O que significa alcance orgânico?', 'Pessoas alcançadas somente por anúncios pagos', FALSE, 3),
      ('Qual é uma vantagem de combinar tráfego orgânico e pago?', 'Impede concorrência', FALSE, 0),
      ('Qual é uma vantagem de combinar tráfego orgânico e pago?', 'Garante lucro em qualquer campanha', FALSE, 1),
      ('Qual é uma vantagem de combinar tráfego orgânico e pago?', 'Elimina a necessidade de conteúdo', FALSE, 2),
      ('Qual é uma vantagem de combinar tráfego orgânico e pago?', 'Permite trabalhar crescimento de longo prazo enquanto campanhas pagas podem ampliar o alcance mais rapidamente', TRUE, 3),
      ('Por que analisar o desempenho de uma publicação?', 'Para apagar automaticamente o conteúdo', FALSE, 0),
      ('Por que analisar o desempenho de uma publicação?', 'Para eliminar seguidores', FALSE, 1),
      ('Por que analisar o desempenho de uma publicação?', 'Para garantir viralização', FALSE, 2),
      ('Por que analisar o desempenho de uma publicação?', 'Para entender o que funcionou e orientar futuras decisões', TRUE, 3),
      ('Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 'Para facilitar a identificação do fator que contribuiu para a diferença de desempenho', TRUE, 0),
      ('Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 'Para garantir que ambas as versões sejam idênticas', FALSE, 1),
      ('Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 'Para aumentar custos', FALSE, 2),
      ('Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 'Para eliminar os dados', FALSE, 3),
      ('Por que clientes recorrentes podem ser importantes?', 'Nunca fazem novas compras', FALSE, 0),
      ('Por que clientes recorrentes podem ser importantes?', 'Podem gerar valor contínuo e reduzir a dependência de aquisição constante de novos clientes', TRUE, 1),
      ('Por que clientes recorrentes podem ser importantes?', 'Não interagem com a marca', FALSE, 2),
      ('Por que clientes recorrentes podem ser importantes?', 'Sempre exigem produtos gratuitos', FALSE, 3),
      ('O que é aquisição de clientes?', 'Processo de pagar impostos', FALSE, 0),
      ('O que é aquisição de clientes?', 'Processo de cancelar anúncios', FALSE, 1),
      ('O que é aquisição de clientes?', 'Processo de excluir clientes', FALSE, 2),
      ('O que é aquisição de clientes?', 'Processo de atrair e conquistar novos clientes', TRUE, 3),
      ('O que é custo de aquisição de cliente, ou CAC?', 'Custo médio associado à aquisição de um novo cliente', TRUE, 0),
      ('O que é custo de aquisição de cliente, ou CAC?', 'Salário de todos os funcionários', FALSE, 1),
      ('O que é custo de aquisição de cliente, ou CAC?', 'Receita total da empresa', FALSE, 2),
      ('O que é custo de aquisição de cliente, ou CAC?', 'Valor do estoque', FALSE, 3),
      ('Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?', '1.000 MZN', FALSE, 0),
      ('Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?', '10 MZN', FALSE, 1),
      ('Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?', '100 MZN', TRUE, 2),
      ('Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?', '50 MZN', FALSE, 3),
      ('O que é relacionamento com o cliente?', 'Exclusivamente publicidade', FALSE, 0),
      ('O que é relacionamento com o cliente?', 'Apenas venda única', FALSE, 1),
      ('O que é relacionamento com o cliente?', 'Estratégias e interações utilizadas para construir e manter uma relação com consumidores', TRUE, 2),
      ('O que é relacionamento com o cliente?', 'Apenas cobrança', FALSE, 3),
      ('O que significa personalizar uma comunicação?', 'Remover informações', FALSE, 0),
      ('O que significa personalizar uma comunicação?', 'Adaptar a mensagem de acordo com características ou contexto relevante do público', TRUE, 1),
      ('O que significa personalizar uma comunicação?', 'Enviar exatamente a mesma mensagem para todos', FALSE, 2),
      ('O que significa personalizar uma comunicação?', 'Esconder o produto', FALSE, 3),
      ('Por que a segmentação pode melhorar uma campanha?', 'Elimina custos', FALSE, 0),
      ('Por que a segmentação pode melhorar uma campanha?', 'Pode tornar a mensagem mais relevante para grupos específicos', TRUE, 1),
      ('Por que a segmentação pode melhorar uma campanha?', 'Impede análise', FALSE, 2),
      ('Por que a segmentação pode melhorar uma campanha?', 'Garante que todos comprem', FALSE, 3),
      ('O que é remarketing baseado em interação?', 'Comunicação direcionada a pessoas que já demonstraram algum interesse ou interação', TRUE, 0),
      ('O que é remarketing baseado em interação?', 'Comunicação exclusivamente para funcionários', FALSE, 1),
      ('O que é remarketing baseado em interação?', 'Publicidade sem dados', FALSE, 2),
      ('O que é remarketing baseado em interação?', 'Divulgação sem público definido', FALSE, 3),
      ('Qual é o objetivo de uma landing page?', 'Servir apenas como decoração', FALSE, 0),
      ('Qual é o objetivo de uma landing page?', 'Armazenar dinheiro', FALSE, 1),
      ('Qual é o objetivo de uma landing page?', 'Substituir todas as redes sociais', FALSE, 2),
      ('Qual é o objetivo de uma landing page?', 'Conduzir o visitante para uma ação específica', TRUE, 3),
      ('O que é branding?', 'Apenas venda de produtos', FALSE, 0),
      ('O que é branding?', 'Programação de aplicativos', FALSE, 1),
      ('O que é branding?', 'Gestão da identidade e percepção de uma marca', TRUE, 2),
      ('O que é branding?', 'Controle de estoque', FALSE, 3),
      ('O que caracteriza uma estratégia de conteúdo?', 'Publicar sem objetivo', FALSE, 0),
      ('O que caracteriza uma estratégia de conteúdo?', 'Copiar qualquer conteúdo', FALSE, 1),
      ('O que caracteriza uma estratégia de conteúdo?', 'Planejamento sobre o que, para quem, quando e por que publicar', TRUE, 2),
      ('O que caracteriza uma estratégia de conteúdo?', 'Evitar conhecer o público', FALSE, 3),
      ('O que uma análise de concorrentes pode revelar?', 'Dados bancários privados', FALSE, 0),
      ('O que uma análise de concorrentes pode revelar?', 'Informações confidenciais garantidas', FALSE, 1),
      ('O que uma análise de concorrentes pode revelar?', 'Estratégias, pontos fortes e oportunidades de diferenciação', TRUE, 2),
      ('O que uma análise de concorrentes pode revelar?', 'Senhas dos concorrentes', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio2;

    RAISE NOTICE '28 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v2).';
  END IF;
END $$;

COMMIT;
