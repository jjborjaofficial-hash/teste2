-- Migration/seed: conteúdo Marketing Digital, nível Difícil (25 perguntas)
-- Fonte: lote de 80 perguntas de Marketing Digital fornecido pelo proprietário
-- do projeto (perguntas 56–80 do lote, marcadas como "Difícil"). Ver
-- 007_marketing_digital_facil.sql para o contexto completo do lote.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos arquivos
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (48 — distinta das seeds
-- 42/43/44/45/46/47 já usadas) e distribuição controlada entre A/B/C/D,
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_dificil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_dificil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_dificil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_marketing_digital_dificil_v1'
    FROM (VALUES
      ('O que é LTV?'),
      ('Por que comparar LTV e CAC pode ser importante?'),
      ('O que é retenção de clientes?'),
      ('O que é churn?'),
      ('Por que churn elevado pode ser um problema?'),
      ('O que é atribuição de marketing?'),
      ('Por que atribuição pode ser complexa?'),
      ('O que é jornada do cliente?'),
      ('O que significa omnichannel?'),
      ('O que é personalização em marketing?'),
      ('Qual é um risco de personalização mal aplicada?'),
      ('O que é automação de marketing?'),
      ('Qual é um exemplo de automação de marketing?'),
      ('O que é remarketing baseado em comportamento?'),
      ('O que é SEO técnico?'),
      ('Por que velocidade de carregamento pode influenciar uma estratégia digital?'),
      ('O que é intenção de busca?'),
      ('Por que compreender a intenção de busca é importante para SEO?'),
      ('O que é autoridade de domínio em SEO?'),
      ('O que são backlinks?'),
      ('Por que backlinks relevantes podem ser importantes para SEO?'),
      ('O que é marketing baseado em dados?'),
      ('Por que uma campanha com muitos cliques pode ainda ser considerada ruim?'),
      ('O que é otimização de conversão?'),
      ('Qual é uma estratégia mais sustentável para crescimento digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_dificil q
    JOIN (VALUES
      ('O que é LTV?', 'Valor de uma publicação', FALSE, 0),
      ('O que é LTV?', 'Número de seguidores', FALSE, 1),
      ('O que é LTV?', 'Estimativa do valor que um cliente pode gerar para uma empresa durante seu relacionamento com ela', TRUE, 2),
      ('O que é LTV?', 'Custo de uma campanha', FALSE, 3),
      ('Por que comparar LTV e CAC pode ser importante?', 'Para escolher uma cor de logotipo', FALSE, 0),
      ('Por que comparar LTV e CAC pode ser importante?', 'Para calcular o número de seguidores', FALSE, 1),
      ('Por que comparar LTV e CAC pode ser importante?', 'Para medir o tamanho do site', FALSE, 2),
      ('Por que comparar LTV e CAC pode ser importante?', 'Para avaliar se o valor gerado pelos clientes pode justificar o custo de adquiri-los', TRUE, 3),
      ('O que é retenção de clientes?', 'Número de anúncios publicados', FALSE, 0),
      ('O que é retenção de clientes?', 'Número de visitantes únicos', FALSE, 1),
      ('O que é retenção de clientes?', 'Capacidade de manter clientes ativos ou relacionados com a empresa ao longo do tempo', TRUE, 2),
      ('O que é retenção de clientes?', 'Quantidade de novos seguidores', FALSE, 3),
      ('O que é churn?', 'Taxa de cliques', FALSE, 0),
      ('O que é churn?', 'Custo por impressão', FALSE, 1),
      ('O que é churn?', 'Taxa de abertura de email', FALSE, 2),
      ('O que é churn?', 'Taxa ou ocorrência de clientes que deixam de utilizar ou cancelar determinado serviço em um período', TRUE, 3),
      ('Por que churn elevado pode ser um problema?', 'Pode indicar dificuldade em manter clientes e aumentar o custo necessário para substituir os que saem', TRUE, 0),
      ('Por que churn elevado pode ser um problema?', 'Porque sempre aumenta o lucro', FALSE, 1),
      ('Por que churn elevado pode ser um problema?', 'Porque reduz o custo de aquisição', FALSE, 2),
      ('Por que churn elevado pode ser um problema?', 'Porque aumenta automaticamente o alcance', FALSE, 3),
      ('O que é atribuição de marketing?', 'Criação de logotipos', FALSE, 0),
      ('O que é atribuição de marketing?', 'Processo de analisar quais canais ou pontos de contato recebem crédito por uma conversão segundo determinado modelo', TRUE, 1),
      ('O que é atribuição de marketing?', 'Gestão de servidores', FALSE, 2),
      ('O que é atribuição de marketing?', 'Distribuição de salários', FALSE, 3),
      ('Por que atribuição pode ser complexa?', 'Porque cada cliente usa apenas um canal', FALSE, 0),
      ('Por que atribuição pode ser complexa?', 'Porque um cliente pode interagir com vários canais antes de converter', TRUE, 1),
      ('Por que atribuição pode ser complexa?', 'Porque anúncios não possuem dados', FALSE, 2),
      ('Por que atribuição pode ser complexa?', 'Porque conversões nunca podem ser medidas', FALSE, 3),
      ('O que é jornada do cliente?', 'Apenas uma campanha', FALSE, 0),
      ('O que é jornada do cliente?', 'Apenas o momento da compra', FALSE, 1),
      ('O que é jornada do cliente?', 'Conjunto de etapas e interações que uma pessoa pode percorrer desde o primeiro contato até o pós-venda', TRUE, 2),
      ('O que é jornada do cliente?', 'Apenas uma visita ao site', FALSE, 3),
      ('O que significa omnichannel?', 'Uso de apenas uma rede social', FALSE, 0),
      ('O que significa omnichannel?', 'Uso exclusivo de anúncios pagos', FALSE, 1),
      ('O que significa omnichannel?', 'Venda apenas presencial', FALSE, 2),
      ('O que significa omnichannel?', 'Estratégia que busca integrar diferentes canais de interação para proporcionar uma experiência mais consistente', TRUE, 3),
      ('O que é personalização em marketing?', 'Adaptação de conteúdos, ofertas ou experiências com base em informações relevantes sobre o usuário', TRUE, 0),
      ('O que é personalização em marketing?', 'Exclusão de clientes antigos', FALSE, 1),
      ('O que é personalização em marketing?', 'Envio da mesma mensagem para todos', FALSE, 2),
      ('O que é personalização em marketing?', 'Publicação aleatória', FALSE, 3),
      ('Qual é um risco de personalização mal aplicada?', 'Garante sempre maior confiança', FALSE, 0),
      ('Qual é um risco de personalização mal aplicada?', 'Pode gerar experiências invasivas, inadequadas ou levantar preocupações de privacidade', TRUE, 1),
      ('Qual é um risco de personalização mal aplicada?', 'Impede qualquer segmentação', FALSE, 2),
      ('Qual é um risco de personalização mal aplicada?', 'Elimina todos os custos', FALSE, 3),
      ('O que é automação de marketing?', 'Uso de ferramentas para automatizar determinadas tarefas de marketing com base em regras ou eventos', TRUE, 0),
      ('O que é automação de marketing?', 'Criação de anúncios físicos', FALSE, 1),
      ('O que é automação de marketing?', 'Exclusão de leads', FALSE, 2),
      ('O que é automação de marketing?', 'Trabalho exclusivamente manual', FALSE, 3),
      ('Qual é um exemplo de automação de marketing?', 'Imprimir um cartaz', FALSE, 0),
      ('Qual é um exemplo de automação de marketing?', 'Entregar um folheto', FALSE, 1),
      ('Qual é um exemplo de automação de marketing?', 'Fazer uma chamada manual', FALSE, 2),
      ('Qual é um exemplo de automação de marketing?', 'Enviar automaticamente uma sequência de emails após uma ação específica de um usuário', TRUE, 3),
      ('O que é remarketing baseado em comportamento?', 'Criação de anúncios sem dados', FALSE, 0),
      ('O que é remarketing baseado em comportamento?', 'Personalização de campanhas para pessoas com base em interações anteriores, dentro das regras e permissões aplicáveis', TRUE, 1),
      ('O que é remarketing baseado em comportamento?', 'Exclusão de visitantes', FALSE, 2),
      ('O que é remarketing baseado em comportamento?', 'Envio da mesma campanha para todos', FALSE, 3),
      ('O que é SEO técnico?', 'Parte do SEO relacionada a aspectos técnicos do site que podem influenciar rastreamento, indexação, desempenho e experiência', TRUE, 0),
      ('O que é SEO técnico?', 'Apenas design de logotipo', FALSE, 1),
      ('O que é SEO técnico?', 'Apenas publicidade paga', FALSE, 2),
      ('O que é SEO técnico?', 'Apenas criação de textos', FALSE, 3),
      ('Por que velocidade de carregamento pode influenciar uma estratégia digital?', 'Sites lentos podem prejudicar a experiência do usuário e determinados resultados de desempenho', TRUE, 0),
      ('Por que velocidade de carregamento pode influenciar uma estratégia digital?', 'Sites lentos sempre aumentam vendas', FALSE, 1),
      ('Por que velocidade de carregamento pode influenciar uma estratégia digital?', 'Velocidade nunca importa', FALSE, 2),
      ('Por que velocidade de carregamento pode influenciar uma estratégia digital?', 'Velocidade só importa em anúncios físicos', FALSE, 3),
      ('O que é intenção de busca?', 'Palavra-passe do usuário', FALSE, 0),
      ('O que é intenção de busca?', 'Localização do servidor', FALSE, 1),
      ('O que é intenção de busca?', 'Objetivo ou necessidade que o usuário procura satisfazer ao realizar uma pesquisa', TRUE, 2),
      ('O que é intenção de busca?', 'Nome do navegador', FALSE, 3),
      ('Por que compreender a intenção de busca é importante para SEO?', 'Permite criar conteúdo mais alinhado com aquilo que o usuário realmente procura', TRUE, 0),
      ('Por que compreender a intenção de busca é importante para SEO?', 'Elimina todos os concorrentes', FALSE, 1),
      ('Por que compreender a intenção de busca é importante para SEO?', 'Garante primeira posição', FALSE, 2),
      ('Por que compreender a intenção de busca é importante para SEO?', 'Impede alterações no algoritmo', FALSE, 3),
      ('O que é autoridade de domínio em SEO?', 'Número de usuários registrados', FALSE, 0),
      ('O que é autoridade de domínio em SEO?', 'Valor do domínio', FALSE, 1),
      ('O que é autoridade de domínio em SEO?', 'Conceito usado em algumas ferramentas para estimar a força ou autoridade relativa de um domínio, não sendo uma métrica oficial universal dos mecanismos de busca', TRUE, 2),
      ('O que é autoridade de domínio em SEO?', 'Senha do administrador', FALSE, 3),
      ('O que são backlinks?', 'Links que só funcionam offline', FALSE, 0),
      ('O que são backlinks?', 'Links de outros sites que apontam para uma página ou domínio', TRUE, 1),
      ('O que são backlinks?', 'Links enviados exclusivamente por email', FALSE, 2),
      ('O que são backlinks?', 'Links dentro de um aplicativo bancário', FALSE, 3),
      ('Por que backlinks relevantes podem ser importantes para SEO?', 'Garantem automaticamente a primeira posição', FALSE, 0),
      ('Por que backlinks relevantes podem ser importantes para SEO?', 'Garantem milhões de visitas', FALSE, 1),
      ('Por que backlinks relevantes podem ser importantes para SEO?', 'Eliminam a necessidade de conteúdo', FALSE, 2),
      ('Por que backlinks relevantes podem ser importantes para SEO?', 'Podem contribuir para sinais de autoridade e descoberta, dependendo da qualidade e contexto dos links', TRUE, 3),
      ('O que é marketing baseado em dados?', 'Marketing sem objetivos', FALSE, 0),
      ('O que é marketing baseado em dados?', 'Marketing sem qualquer medição', FALSE, 1),
      ('O que é marketing baseado em dados?', 'Marketing exclusivamente presencial', FALSE, 2),
      ('O que é marketing baseado em dados?', 'Utilização de dados e métricas para orientar decisões de marketing', TRUE, 3),
      ('Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 'Porque cliques não significam necessariamente conversões, receita ou retorno positivo', TRUE, 0),
      ('Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 'Porque toda campanha deve evitar cliques', FALSE, 1),
      ('Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 'Porque cliques reduzem automaticamente as vendas', FALSE, 2),
      ('Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 'Porque cliques nunca têm valor', FALSE, 3),
      ('O que é otimização de conversão?', 'Processo de eliminar visitantes', FALSE, 0),
      ('O que é otimização de conversão?', 'Processo de melhorar elementos da experiência ou jornada para aumentar a proporção de usuários que realizam uma ação desejada', TRUE, 1),
      ('O que é otimização de conversão?', 'Processo de aumentar somente seguidores', FALSE, 2),
      ('O que é otimização de conversão?', 'Processo de reduzir todo o conteúdo', FALSE, 3),
      ('Qual é uma estratégia mais sustentável para crescimento digital?', 'Copiar integralmente os concorrentes', FALSE, 0),
      ('Qual é uma estratégia mais sustentável para crescimento digital?', 'Comprar seguidores falsos', FALSE, 1),
      ('Qual é uma estratégia mais sustentável para crescimento digital?', 'Combinar conteúdo relevante, compreensão do público, testes, análise de dados, melhoria contínua e construção de confiança', TRUE, 2),
      ('Qual é uma estratégia mais sustentável para crescimento digital?', 'Prometer resultados garantidos', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_dificil;

    RAISE NOTICE '25 perguntas inseridas com sucesso (source=seed_marketing_digital_dificil_v1).';
  END IF;
END $$;

COMMIT;
