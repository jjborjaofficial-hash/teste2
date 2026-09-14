-- Migration/seed: conteúdo Marketing Digital, nível Médio (30 perguntas)
-- Fonte: lote de 80 perguntas de Marketing Digital fornecido pelo proprietário
-- do projeto (perguntas 26–55 do lote, marcadas como "Médio"). Ver
-- 007_marketing_digital_facil.sql para o contexto completo do lote.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos arquivos
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (47 — distinta das seeds
-- 42/43/44/45/46 já usadas) e distribuição controlada entre A/B/C/D,
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v1'
    FROM (VALUES
      ('O que é persona?'),
      ('Por que criar uma persona pode ajudar no marketing?'),
      ('O que é funil de vendas?'),
      ('Qual pode ser uma etapa inicial de um funil?'),
      ('O que é conversão?'),
      ('Qual destas pode ser uma conversão?'),
      ('O que é taxa de conversão?'),
      ('O que é CTR?'),
      ('Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?'),
      ('O que é CPC?'),
      ('O que é CPM?'),
      ('O que é CPA?'),
      ('O que é CAC?'),
      ('O que é ROI em marketing?'),
      ('O que é segmentação de público?'),
      ('Por que segmentar campanhas?'),
      ('O que é remarketing?'),
      ('O que é teste A/B?'),
      ('Qual é um exemplo de teste A/B?'),
      ('O que é copywriting?'),
      ('O que é prova social?'),
      ('Qual é um exemplo de prova social?'),
      ('O que é autoridade de marca?'),
      ('O que é marketing de influência?'),
      ('O que é conteúdo viral?'),
      ('Uma publicação viral garante lucro?'),
      ('O que é calendário editorial?'),
      ('Qual é uma vantagem de um calendário editorial?'),
      ('O que é nutrição de leads?'),
      ('O que é lead?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio q
    JOIN (VALUES
      ('O que é persona?', 'Programa de edição', FALSE, 0),
      ('O que é persona?', 'Representação semifictícia de um cliente ideal baseada em características e informações relevantes', TRUE, 1),
      ('O que é persona?', 'Concorrente direto', FALSE, 2),
      ('O que é persona?', 'Funcionário de uma empresa', FALSE, 3),
      ('Por que criar uma persona pode ajudar no marketing?', 'Garante vendas', FALSE, 0),
      ('Por que criar uma persona pode ajudar no marketing?', 'Pode facilitar a criação de mensagens e ofertas mais relevantes para determinado público', TRUE, 1),
      ('Por que criar uma persona pode ajudar no marketing?', 'Elimina todos os concorrentes', FALSE, 2),
      ('Por que criar uma persona pode ajudar no marketing?', 'Impede alterações na estratégia', FALSE, 3),
      ('O que é funil de vendas?', 'Sistema de pagamento', FALSE, 0),
      ('O que é funil de vendas?', 'Banco de dados', FALSE, 1),
      ('O que é funil de vendas?', 'Ferramenta de edição de vídeo', FALSE, 2),
      ('O que é funil de vendas?', 'Modelo que representa etapas pelas quais potenciais clientes podem passar até uma conversão', TRUE, 3),
      ('Qual pode ser uma etapa inicial de um funil?', 'Cancelamento', FALSE, 0),
      ('Qual pode ser uma etapa inicial de um funil?', 'Pós-venda obrigatório', FALSE, 1),
      ('Qual pode ser uma etapa inicial de um funil?', 'Reembolso', FALSE, 2),
      ('Qual pode ser uma etapa inicial de um funil?', 'Descoberta ou conscientização', TRUE, 3),
      ('O que é conversão?', 'Apenas uma curtida', FALSE, 0),
      ('O que é conversão?', 'Apenas uma impressão', FALSE, 1),
      ('O que é conversão?', 'Apenas uma visita', FALSE, 2),
      ('O que é conversão?', 'Realização da ação definida como objetivo de uma campanha ou página', TRUE, 3),
      ('Qual destas pode ser uma conversão?', 'Apenas ligar o telefone', FALSE, 0),
      ('Qual destas pode ser uma conversão?', 'Apenas abrir o navegador', FALSE, 1),
      ('Qual destas pode ser uma conversão?', 'Apenas visualizar um anúncio', FALSE, 2),
      ('Qual destas pode ser uma conversão?', 'Realizar uma compra', TRUE, 3),
      ('O que é taxa de conversão?', 'Número de anúncios publicados', FALSE, 0),
      ('O que é taxa de conversão?', 'Número total de seguidores', FALSE, 1),
      ('O que é taxa de conversão?', 'Valor total das vendas', FALSE, 2),
      ('O que é taxa de conversão?', 'Percentual de usuários que realizam determinada ação em relação ao total considerado', TRUE, 3),
      ('O que é CTR?', 'Taxa de cliques em relação às impressões de determinado anúncio ou elemento', TRUE, 0),
      ('O que é CTR?', 'Taxa de lucro anual', FALSE, 1),
      ('O que é CTR?', 'Número de seguidores', FALSE, 2),
      ('O que é CTR?', 'Custo de produção', FALSE, 3),
      ('Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 'Qualidade da página de destino, oferta, público e alinhamento entre anúncio e produto', TRUE, 0),
      ('Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 'Apenas o número de seguidores', FALSE, 1),
      ('Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 'Apenas o nome da empresa', FALSE, 2),
      ('Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 'Apenas o tamanho do logotipo', FALSE, 3),
      ('O que é CPC?', 'Conversão por campanha', FALSE, 0),
      ('O que é CPC?', 'Conteúdo por canal', FALSE, 1),
      ('O que é CPC?', 'Custo por cliente anual', FALSE, 2),
      ('O que é CPC?', 'Custo por clique', TRUE, 3),
      ('O que é CPM?', 'Custo por mensagem', FALSE, 0),
      ('O que é CPM?', 'Conversão por mês', FALSE, 1),
      ('O que é CPM?', 'Custo por mil impressões', TRUE, 2),
      ('O que é CPM?', 'Custo por produto', FALSE, 3),
      ('O que é CPA?', 'Custo por aquisição ou ação, conforme o objetivo definido na campanha', TRUE, 0),
      ('O que é CPA?', 'Custo por audiência', FALSE, 1),
      ('O que é CPA?', 'Conversão por aplicativo', FALSE, 2),
      ('O que é CPA?', 'Custo por anúncio', FALSE, 3),
      ('O que é CAC?', 'Conversão automática de campanha', FALSE, 0),
      ('O que é CAC?', 'Custo de anúncio clicado', FALSE, 1),
      ('O que é CAC?', 'Custo de aquisição de cliente', TRUE, 2),
      ('O que é CAC?', 'Custo anual de conteúdo', FALSE, 3),
      ('O que é ROI em marketing?', 'Relação entre o retorno obtido e o investimento realizado', TRUE, 0),
      ('O que é ROI em marketing?', 'Número de seguidores', FALSE, 1),
      ('O que é ROI em marketing?', 'Quantidade de comentários', FALSE, 2),
      ('O que é ROI em marketing?', 'Número de publicações', FALSE, 3),
      ('O que é segmentação de público?', 'Exclusão de todos os clientes', FALSE, 0),
      ('O que é segmentação de público?', 'Criação de uma única mensagem para qualquer pessoa', FALSE, 1),
      ('O que é segmentação de público?', 'Divisão do público em grupos com características ou comportamentos semelhantes', TRUE, 2),
      ('O que é segmentação de público?', 'Publicação sem estratégia', FALSE, 3),
      ('Por que segmentar campanhas?', 'Para tentar apresentar mensagens mais relevantes a diferentes grupos', TRUE, 0),
      ('Por que segmentar campanhas?', 'Para garantir conversão de 100%', FALSE, 1),
      ('Por que segmentar campanhas?', 'Para eliminar todos os anúncios', FALSE, 2),
      ('Por que segmentar campanhas?', 'Para impedir qualquer alcance', FALSE, 3),
      ('O que é remarketing?', 'Estratégia de alcançar novamente pessoas que já tiveram alguma interação com uma marca ou oferta', TRUE, 0),
      ('O que é remarketing?', 'Criação de um novo produto', FALSE, 1),
      ('O que é remarketing?', 'Estratégia de eliminar antigos clientes', FALSE, 2),
      ('O que é remarketing?', 'Publicação sem segmentação', FALSE, 3),
      ('O que é teste A/B?', 'Teste de velocidade da internet', FALSE, 0),
      ('O que é teste A/B?', 'Teste de bateria', FALSE, 1),
      ('O que é teste A/B?', 'Teste de segurança física', FALSE, 2),
      ('O que é teste A/B?', 'Comparação de duas versões de um elemento para verificar qual apresenta melhor desempenho segundo uma métrica', TRUE, 3),
      ('Qual é um exemplo de teste A/B?', 'Comparar duas versões de um título de landing page', TRUE, 0),
      ('Qual é um exemplo de teste A/B?', 'Publicar o mesmo conteúdo sem medir resultados', FALSE, 1),
      ('Qual é um exemplo de teste A/B?', 'Apagar uma campanha', FALSE, 2),
      ('Qual é um exemplo de teste A/B?', 'Alterar o computador', FALSE, 3),
      ('O que é copywriting?', 'Técnica de criação de bancos de dados', FALSE, 0),
      ('O que é copywriting?', 'Técnica de programação', FALSE, 1),
      ('O que é copywriting?', 'Técnica de escrever textos com objetivo de comunicar, persuadir ou estimular determinada ação', TRUE, 2),
      ('O que é copywriting?', 'Técnica de edição de áudio', FALSE, 3),
      ('O que é prova social?', 'Contrato de publicidade', FALSE, 0),
      ('O que é prova social?', 'Evidência de outras pessoas utilizando, recomendando ou avaliando positivamente uma solução', TRUE, 1),
      ('O que é prova social?', 'Documento bancário', FALSE, 2),
      ('O que é prova social?', 'Algoritmo de pesquisa', FALSE, 3),
      ('Qual é um exemplo de prova social?', 'Código-fonte', FALSE, 0),
      ('Qual é um exemplo de prova social?', 'Senha de administrador', FALSE, 1),
      ('Qual é um exemplo de prova social?', 'Depoimento de um cliente', TRUE, 2),
      ('Qual é um exemplo de prova social?', 'Endereço IP', FALSE, 3),
      ('O que é autoridade de marca?', 'Número de funcionários', FALSE, 0),
      ('O que é autoridade de marca?', 'Percepção de conhecimento, credibilidade ou experiência de uma marca em determinado assunto', TRUE, 1),
      ('O que é autoridade de marca?', 'Valor do aluguel', FALSE, 2),
      ('O que é autoridade de marca?', 'Quantidade de computadores', FALSE, 3),
      ('O que é marketing de influência?', 'Marketing apenas presencial', FALSE, 0),
      ('O que é marketing de influência?', 'Estratégia que utiliza pessoas com audiência ou influência para comunicar uma marca, produto ou serviço', TRUE, 1),
      ('O que é marketing de influência?', 'Marketing exclusivamente por email', FALSE, 2),
      ('O que é marketing de influência?', 'Marketing sem conteúdo', FALSE, 3),
      ('O que é conteúdo viral?', 'Conteúdo privado', FALSE, 0),
      ('O que é conteúdo viral?', 'Conteúdo que obrigatoriamente gera vendas', FALSE, 1),
      ('O que é conteúdo viral?', 'Conteúdo que se espalha rapidamente entre muitas pessoas por meio de compartilhamentos e outras formas de distribuição', TRUE, 2),
      ('O que é conteúdo viral?', 'Conteúdo publicado apenas uma vez', FALSE, 3),
      ('Uma publicação viral garante lucro?', 'Sim, quando tem mais de 100 visualizações', FALSE, 0),
      ('Uma publicação viral garante lucro?', 'Não', TRUE, 1),
      ('Uma publicação viral garante lucro?', 'Sim, automaticamente', FALSE, 2),
      ('Uma publicação viral garante lucro?', 'Sim, sempre', FALSE, 3),
      ('O que é calendário editorial?', 'Lista de clientes inadimplentes', FALSE, 0),
      ('O que é calendário editorial?', 'Calendário bancário', FALSE, 1),
      ('O que é calendário editorial?', 'Planeamento organizado dos conteúdos que serão produzidos e publicados', TRUE, 2),
      ('O que é calendário editorial?', 'Lista de salários', FALSE, 3),
      ('Qual é uma vantagem de um calendário editorial?', 'Garante milhões de seguidores', FALSE, 0),
      ('Qual é uma vantagem de um calendário editorial?', 'Ajuda a organizar temas, formatos, datas e frequência de publicação', TRUE, 1),
      ('Qual é uma vantagem de um calendário editorial?', 'Elimina a necessidade de criatividade', FALSE, 2),
      ('Qual é uma vantagem de um calendário editorial?', 'Garante vendas', FALSE, 3),
      ('O que é nutrição de leads?', 'Processo de manter relacionamento com potenciais clientes por meio de conteúdos e comunicações relevantes', TRUE, 0),
      ('O que é nutrição de leads?', 'Alimentação física dos clientes', FALSE, 1),
      ('O que é nutrição de leads?', 'Criação de anúncios sem público', FALSE, 2),
      ('O que é nutrição de leads?', 'Exclusão de contatos', FALSE, 3),
      ('O que é lead?', 'Apenas um concorrente', FALSE, 0),
      ('O que é lead?', 'Pessoa ou organização que demonstrou interesse e forneceu algum meio de contato ou identificação, conforme o contexto', TRUE, 1),
      ('O que é lead?', 'Apenas um funcionário', FALSE, 2),
      ('O que é lead?', 'Qualquer pessoa na internet', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio;

    RAISE NOTICE '30 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v1).';
  END IF;
END $$;

COMMIT;
