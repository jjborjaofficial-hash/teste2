-- Seed: conteúdo Marketing Digital, nível Difícil (44 perguntas)
-- Fonte: lote "MARKETING DIGITAL — DIFÍCIL (50
-- questões)" fornecido pelo proprietário do projeto, filtrado para conter
-- apenas perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-026).
--
-- Das 50 perguntas do lote original, 6 já existiam
-- palavra-por-palavra no banco (repetições de seeds anteriores de Marketing
-- Digital) — foram descartadas. As 44 restantes são genuinamente novas e
-- entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (68 — distinta das seeds 42 a 65 já
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_dificil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_dificil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_dificil3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_marketing_digital_dificil_v3'
    FROM (VALUES
      ('Qual é o principal objetivo de uma estratégia de Growth Marketing?'),
      ('O que caracteriza um Growth Hacker?'),
      ('O que é CRO (Conversion Rate Optimization)?'),
      ('Qual é o objetivo principal de uma landing page otimizada?'),
      ('O que é um funil de vendas avançado?'),
      ('O que significa LTV no Marketing Digital?'),
      ('O que significa CAC?'),
      ('Qual relação é geralmente desejável entre LTV e CAC?'),
      ('O que é atribuição de conversão?'),
      ('O que é modelo de atribuição last click?'),
      ('O que é atribuição baseada em dados?'),
      ('O que é Customer Journey Mapping?'),
      ('O que é personalização em Marketing Digital?'),
      ('O que é automação baseada em comportamento?'),
      ('O que é lead scoring?'),
      ('Qual é a finalidade do lead scoring?'),
      ('O que é uma campanha de remarketing dinâmico?'),
      ('O que é segmentação lookalike?'),
      ('O que é uma audiência personalizada?'),
      ('O que é ROAS?'),
      ('Qual fórmula representa ROAS?'),
      ('Um CTR baixo em um anúncio geralmente indica:'),
      ('O que é Quality Score em anúncios?'),
      ('O que é remarketing baseado em pixel?'),
      ('O que é um pixel de rastreamento?'),
      ('O que é atribuição multicanal?'),
      ('O que é teste multivariado?'),
      ('O que é personalização baseada em IA?'),
      ('O que é análise preditiva no marketing?'),
      ('O que é uma estratégia omnichannel?'),
      ('O que é Customer Experience (CX)?'),
      ('O que é uma estratégia de reativação?'),
      ('O que é marketing viral planejado?'),
      ('O que é autoridade digital?'),
      ('O que é estratégia de comunidade?'),
      ('O que é social listening?'),
      ('O que é estratégia de conteúdo baseada em dados?'),
      ('O que é escalabilidade em Marketing Digital?'),
      ('O que é um MVP em uma estratégia digital?'),
      ('O que é validação de mercado?'),
      ('O que é experimentação contínua?'),
      ('O que é uma estratégia data-driven?'),
      ('Qual é a importância da análise de dados no Marketing Digital avançado?'),
      ('Qual é um dos maiores objetivos do Marketing Digital moderno?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_dificil3 q
    JOIN (VALUES
      ('Qual é o principal objetivo de uma estratégia de Growth Marketing?', 'Apenas criar publicações nas redes sociais', FALSE, 0),
      ('Qual é o principal objetivo de uma estratégia de Growth Marketing?', 'Fazer somente anúncios tradicionais', FALSE, 1),
      ('Qual é o principal objetivo de uma estratégia de Growth Marketing?', 'Aumentar seguidores sem analisar resultados', FALSE, 2),
      ('Qual é o principal objetivo de uma estratégia de Growth Marketing?', 'Encontrar formas escaláveis de crescimento usando dados e experimentação', TRUE, 3),
      ('O que caracteriza um Growth Hacker?', 'Designer especializado em logotipos', FALSE, 0),
      ('O que caracteriza um Growth Hacker?', 'Vendedor exclusivamente presencial', FALSE, 1),
      ('O que caracteriza um Growth Hacker?', 'Profissional focado em crescimento através de testes, dados e inovação', TRUE, 2),
      ('O que caracteriza um Growth Hacker?', 'Pessoa que cria vírus para empresas', FALSE, 3),
      ('O que é CRO (Conversion Rate Optimization)?', 'Exclusão de campanhas', FALSE, 0),
      ('O que é CRO (Conversion Rate Optimization)?', 'Redução de visitantes', FALSE, 1),
      ('O que é CRO (Conversion Rate Optimization)?', 'Criação de anúncios sem análise', FALSE, 2),
      ('O que é CRO (Conversion Rate Optimization)?', 'Processo de otimizar páginas e experiências para aumentar conversões', TRUE, 3),
      ('Qual é o objetivo principal de uma landing page otimizada?', 'Apenas apresentar imagens bonitas', FALSE, 0),
      ('Qual é o objetivo principal de uma landing page otimizada?', 'Substituir todas as redes sociais', FALSE, 1),
      ('Qual é o objetivo principal de uma landing page otimizada?', 'Transformar visitantes em leads ou clientes', TRUE, 2),
      ('Qual é o objetivo principal de uma landing page otimizada?', 'Aumentar o tamanho do site', FALSE, 3),
      ('O que é um funil de vendas avançado?', 'Modelo que acompanha diferentes etapas do comportamento do consumidor', TRUE, 0),
      ('O que é um funil de vendas avançado?', 'Uma ferramenta de edição', FALSE, 1),
      ('O que é um funil de vendas avançado?', 'Um banco de dados', FALSE, 2),
      ('O que é um funil de vendas avançado?', 'Apenas uma página de venda', FALSE, 3),
      ('O que significa LTV no Marketing Digital?', 'Número de seguidores', FALSE, 0),
      ('O que significa LTV no Marketing Digital?', 'Valor total que um cliente gera durante seu relacionamento com a empresa', TRUE, 1),
      ('O que significa LTV no Marketing Digital?', 'Tempo de carregamento do site', FALSE, 2),
      ('O que significa LTV no Marketing Digital?', 'Quantidade de anúncios', FALSE, 3),
      ('O que significa CAC?', 'Controle automático de campanha', FALSE, 0),
      ('O que significa CAC?', 'Custo de criação de conteúdo', FALSE, 1),
      ('O que significa CAC?', 'Custo de aquisição de cliente', TRUE, 2),
      ('O que significa CAC?', 'Conversão de anúncio comercial', FALSE, 3),
      ('Qual relação é geralmente desejável entre LTV e CAC?', 'Nenhum deles importa', FALSE, 0),
      ('Qual relação é geralmente desejável entre LTV e CAC?', 'Devem sempre ser iguais', FALSE, 1),
      ('Qual relação é geralmente desejável entre LTV e CAC?', 'LTV deve ser maior que CAC', TRUE, 2),
      ('Qual relação é geralmente desejável entre LTV e CAC?', 'CAC deve sempre ser maior que LTV', FALSE, 3),
      ('O que é atribuição de conversão?', 'Aumentar seguidores falsos', FALSE, 0),
      ('O que é atribuição de conversão?', 'Criar novos produtos', FALSE, 1),
      ('O que é atribuição de conversão?', 'Apagar dados', FALSE, 2),
      ('O que é atribuição de conversão?', 'Processo de identificar quais canais contribuíram para uma conversão', TRUE, 3),
      ('O que é modelo de atribuição last click?', 'Modelo que atribui a conversão ao último canal antes da compra', TRUE, 0),
      ('O que é modelo de atribuição last click?', 'Modelo baseado apenas em seguidores', FALSE, 1),
      ('O que é modelo de atribuição last click?', 'Modelo que ignora todos os canais', FALSE, 2),
      ('O que é modelo de atribuição last click?', 'Modelo sem dados', FALSE, 3),
      ('O que é atribuição baseada em dados?', 'Modelo manual sem análise', FALSE, 0),
      ('O que é atribuição baseada em dados?', 'Modelo que utiliza informações reais para distribuir crédito entre pontos de contato', TRUE, 1),
      ('O que é atribuição baseada em dados?', 'Modelo sem métricas', FALSE, 2),
      ('O que é atribuição baseada em dados?', 'Modelo aleatório', FALSE, 3),
      ('O que é Customer Journey Mapping?', 'Controle financeiro', FALSE, 0),
      ('O que é Customer Journey Mapping?', 'Mapeamento da experiência do cliente desde descoberta até pós-compra', TRUE, 1),
      ('O que é Customer Journey Mapping?', 'Criação de mapas físicos', FALSE, 2),
      ('O que é Customer Journey Mapping?', 'Desenvolvimento de aplicativos', FALSE, 3),
      ('O que é personalização em Marketing Digital?', 'Remover informações dos clientes', FALSE, 0),
      ('O que é personalização em Marketing Digital?', 'Evitar análise de dados', FALSE, 1),
      ('O que é personalização em Marketing Digital?', 'Adaptar mensagens e experiências para diferentes usuários', TRUE, 2),
      ('O que é personalização em Marketing Digital?', 'Enviar a mesma mensagem para todos', FALSE, 3),
      ('O que é automação baseada em comportamento?', 'Envio automático de ações conforme comportamento do usuário', TRUE, 0),
      ('O que é automação baseada em comportamento?', 'Publicação manual diária', FALSE, 1),
      ('O que é automação baseada em comportamento?', 'Criação de hardware', FALSE, 2),
      ('O que é automação baseada em comportamento?', 'Bloqueio de usuários', FALSE, 3),
      ('O que é lead scoring?', 'Sistema de pontuação para avaliar qualidade dos leads', TRUE, 0),
      ('O que é lead scoring?', 'Contagem de seguidores', FALSE, 1),
      ('O que é lead scoring?', 'Avaliação de anúncios físicos', FALSE, 2),
      ('O que é lead scoring?', 'Criação de vídeos', FALSE, 3),
      ('Qual é a finalidade do lead scoring?', 'Substituir vendedores', FALSE, 0),
      ('Qual é a finalidade do lead scoring?', 'Eliminar todos os contatos', FALSE, 1),
      ('Qual é a finalidade do lead scoring?', 'Aumentar custos', FALSE, 2),
      ('Qual é a finalidade do lead scoring?', 'Priorizar leads com maior possibilidade de compra', TRUE, 3),
      ('O que é uma campanha de remarketing dinâmico?', 'Publicação aleatória', FALSE, 0),
      ('O que é uma campanha de remarketing dinâmico?', 'Anúncio offline', FALSE, 1),
      ('O que é uma campanha de remarketing dinâmico?', 'Exibição personalizada de produtos ou conteúdos conforme comportamento anterior', TRUE, 2),
      ('O que é uma campanha de remarketing dinâmico?', 'Campanha sem dados', FALSE, 3),
      ('O que é segmentação lookalike?', 'Copiar anúncios concorrentes', FALSE, 0),
      ('O que é segmentação lookalike?', 'Encontrar novos usuários semelhantes aos melhores clientes existentes', TRUE, 1),
      ('O que é segmentação lookalike?', 'Remover públicos', FALSE, 2),
      ('O que é segmentação lookalike?', 'Criar produtos iguais', FALSE, 3),
      ('O que é uma audiência personalizada?', 'Público escolhido aleatoriamente', FALSE, 0),
      ('O que é uma audiência personalizada?', 'Público sem informações', FALSE, 1),
      ('O que é uma audiência personalizada?', 'Público criado usando dados de clientes ou visitantes existentes', TRUE, 2),
      ('O que é uma audiência personalizada?', 'Público bloqueado', FALSE, 3),
      ('O que é ROAS?', 'Número de seguidores', FALSE, 0),
      ('O que é ROAS?', 'Quantidade de publicações', FALSE, 1),
      ('O que é ROAS?', 'Velocidade do site', FALSE, 2),
      ('O que é ROAS?', 'Retorno financeiro gerado especificamente por anúncios', TRUE, 3),
      ('Qual fórmula representa ROAS?', 'Clientes ÷ funcionários', FALSE, 0),
      ('Qual fórmula representa ROAS?', 'Custos ÷ visitas', FALSE, 1),
      ('Qual fórmula representa ROAS?', 'Seguidores ÷ curtidas', FALSE, 2),
      ('Qual fórmula representa ROAS?', 'Receita gerada pelos anúncios ÷ investimento em anúncios', TRUE, 3),
      ('Um CTR baixo em um anúncio geralmente indica:', 'Excelente segmentação sempre', FALSE, 0),
      ('Um CTR baixo em um anúncio geralmente indica:', 'Muitas vendas garantidas', FALSE, 1),
      ('Um CTR baixo em um anúncio geralmente indica:', 'Baixa relevância ou pouco interesse do público', TRUE, 2),
      ('Um CTR baixo em um anúncio geralmente indica:', 'Nenhuma necessidade de alteração', FALSE, 3),
      ('O que é Quality Score em anúncios?', 'Avaliação da relevância e qualidade de anúncios e páginas relacionadas', TRUE, 0),
      ('O que é Quality Score em anúncios?', 'Tamanho do anúncio', FALSE, 1),
      ('O que é Quality Score em anúncios?', 'Quantidade de seguidores', FALSE, 2),
      ('O que é Quality Score em anúncios?', 'Número de funcionários', FALSE, 3),
      ('O que é remarketing baseado em pixel?', 'Uso de código de rastreamento para identificar visitantes e criar públicos', TRUE, 0),
      ('O que é remarketing baseado em pixel?', 'Criação de imagens', FALSE, 1),
      ('O que é remarketing baseado em pixel?', 'Sistema operacional', FALSE, 2),
      ('O que é remarketing baseado em pixel?', 'Banco físico', FALSE, 3),
      ('O que é um pixel de rastreamento?', 'Arquivo de imagem', FALSE, 0),
      ('O que é um pixel de rastreamento?', 'Código usado para coletar informações sobre ações dos usuários', TRUE, 1),
      ('O que é um pixel de rastreamento?', 'Parte da tela do computador', FALSE, 2),
      ('O que é um pixel de rastreamento?', 'Tipo de anúncio', FALSE, 3),
      ('O que é atribuição multicanal?', 'Uso de apenas um anúncio', FALSE, 0),
      ('O que é atribuição multicanal?', 'Bloqueio de usuários', FALSE, 1),
      ('O que é atribuição multicanal?', 'Exclusão de dados', FALSE, 2),
      ('O que é atribuição multicanal?', 'Análise de vários canais que participaram da conversão', TRUE, 3),
      ('O que é teste multivariado?', 'Remover páginas', FALSE, 0),
      ('O que é teste multivariado?', 'Teste de várias combinações de elementos para identificar melhor desempenho', TRUE, 1),
      ('O que é teste multivariado?', 'Apenas alterar uma cor', FALSE, 2),
      ('O que é teste multivariado?', 'Criar uma nova empresa', FALSE, 3),
      ('O que é personalização baseada em IA?', 'Bloqueio de dados', FALSE, 0),
      ('O que é personalização baseada em IA?', 'Uso de inteligência artificial para adaptar experiências ao usuário', TRUE, 1),
      ('O que é personalização baseada em IA?', 'Criação física de produtos', FALSE, 2),
      ('O que é personalização baseada em IA?', 'Envio manual de mensagens', FALSE, 3),
      ('O que é análise preditiva no marketing?', 'Uso de dados para prever comportamentos futuros dos consumidores', TRUE, 0),
      ('O que é análise preditiva no marketing?', 'Apagar históricos', FALSE, 1),
      ('O que é análise preditiva no marketing?', 'Criar anúncios impressos', FALSE, 2),
      ('O que é análise preditiva no marketing?', 'Substituir clientes', FALSE, 3),
      ('O que é uma estratégia omnichannel?', 'Integração de vários canais para oferecer experiência consistente ao cliente', TRUE, 0),
      ('O que é uma estratégia omnichannel?', 'Exclusão de canais digitais', FALSE, 1),
      ('O que é uma estratégia omnichannel?', 'Uso de apenas uma rede social', FALSE, 2),
      ('O que é uma estratégia omnichannel?', 'Venda apenas presencial', FALSE, 3),
      ('O que é Customer Experience (CX)?', 'Sistema de pagamento', FALSE, 0),
      ('O que é Customer Experience (CX)?', 'Experiência completa do cliente com a marca', TRUE, 1),
      ('O que é Customer Experience (CX)?', 'Apenas preço do produto', FALSE, 2),
      ('O que é Customer Experience (CX)?', 'Número de anúncios', FALSE, 3),
      ('O que é uma estratégia de reativação?', 'Apagar dados', FALSE, 0),
      ('O que é uma estratégia de reativação?', 'Criar novos computadores', FALSE, 1),
      ('O que é uma estratégia de reativação?', 'Ações para recuperar clientes inativos', TRUE, 2),
      ('O que é uma estratégia de reativação?', 'Bloquear usuários', FALSE, 3),
      ('O que é marketing viral planejado?', 'Divulgação sem objetivo', FALSE, 0),
      ('O que é marketing viral planejado?', 'Ataque digital', FALSE, 1),
      ('O que é marketing viral planejado?', 'Spam', FALSE, 2),
      ('O que é marketing viral planejado?', 'Estratégia criada para estimular compartilhamentos e alcance orgânico', TRUE, 3),
      ('O que é autoridade digital?', 'Nível de confiança e reconhecimento de uma marca online', TRUE, 0),
      ('O que é autoridade digital?', 'Número de computadores', FALSE, 1),
      ('O que é autoridade digital?', 'Quantidade de funcionários', FALSE, 2),
      ('O que é autoridade digital?', 'Tamanho do escritório', FALSE, 3),
      ('O que é estratégia de comunidade?', 'Evitar interação', FALSE, 0),
      ('O que é estratégia de comunidade?', 'Construção de relacionamento contínuo com usuários em torno da marca', TRUE, 1),
      ('O que é estratégia de comunidade?', 'Apenas vender uma vez', FALSE, 2),
      ('O que é estratégia de comunidade?', 'Remover seguidores', FALSE, 3),
      ('O que é social listening?', 'Monitoramento de conversas e opiniões sobre uma marca na internet', TRUE, 0),
      ('O que é social listening?', 'Criação de músicas', FALSE, 1),
      ('O que é social listening?', 'Edição de vídeos', FALSE, 2),
      ('O que é social listening?', 'Bloqueio de comentários', FALSE, 3),
      ('O que é estratégia de conteúdo baseada em dados?', 'Publicar sem planejamento', FALSE, 0),
      ('O que é estratégia de conteúdo baseada em dados?', 'Copiar concorrentes', FALSE, 1),
      ('O que é estratégia de conteúdo baseada em dados?', 'Criar conteúdos usando informações sobre desempenho e público', TRUE, 2),
      ('O que é estratégia de conteúdo baseada em dados?', 'Ignorar métricas', FALSE, 3),
      ('O que é escalabilidade em Marketing Digital?', 'Reduzir alcance', FALSE, 0),
      ('O que é escalabilidade em Marketing Digital?', 'Diminuir clientes', FALSE, 1),
      ('O que é escalabilidade em Marketing Digital?', 'Parar campanhas', FALSE, 2),
      ('O que é escalabilidade em Marketing Digital?', 'Capacidade de aumentar resultados mantendo eficiência', TRUE, 3),
      ('O que é um MVP em uma estratégia digital?', 'Sistema operacional', FALSE, 0),
      ('O que é um MVP em uma estratégia digital?', 'Produto final obrigatório', FALSE, 1),
      ('O que é um MVP em uma estratégia digital?', 'Banco de dados', FALSE, 2),
      ('O que é um MVP em uma estratégia digital?', 'Versão inicial de uma solução usada para testar uma ideia', TRUE, 3),
      ('O que é validação de mercado?', 'Remover clientes', FALSE, 0),
      ('O que é validação de mercado?', 'Processo de testar se existe interesse real por uma solução', TRUE, 1),
      ('O que é validação de mercado?', 'Copiar concorrentes', FALSE, 2),
      ('O que é validação de mercado?', 'Criar anúncios sem público', FALSE, 3),
      ('O que é experimentação contínua?', 'Cancelar campanhas', FALSE, 0),
      ('O que é experimentação contínua?', 'Manter tudo igual', FALSE, 1),
      ('O que é experimentação contínua?', 'Realização constante de testes para melhorar resultados', TRUE, 2),
      ('O que é experimentação contínua?', 'Evitar mudanças', FALSE, 3),
      ('O que é uma estratégia data-driven?', 'Decisões apenas por opinião', FALSE, 0),
      ('O que é uma estratégia data-driven?', 'Estratégia sem métricas', FALSE, 1),
      ('O que é uma estratégia data-driven?', 'Marketing sem objetivo', FALSE, 2),
      ('O que é uma estratégia data-driven?', 'Tomada de decisões baseada em dados', TRUE, 3),
      ('Qual é a importância da análise de dados no Marketing Digital avançado?', 'Permite otimizar investimentos e melhorar resultados', TRUE, 0),
      ('Qual é a importância da análise de dados no Marketing Digital avançado?', 'Elimina necessidade de planejamento', FALSE, 1),
      ('Qual é a importância da análise de dados no Marketing Digital avançado?', 'Impede crescimento', FALSE, 2),
      ('Qual é a importância da análise de dados no Marketing Digital avançado?', 'Substitui produtos', FALSE, 3),
      ('Qual é um dos maiores objetivos do Marketing Digital moderno?', 'Vender sem conhecer clientes', FALSE, 0),
      ('Qual é um dos maiores objetivos do Marketing Digital moderno?', 'Criar crescimento sustentável através de dados, relacionamento e tecnologia', TRUE, 1),
      ('Qual é um dos maiores objetivos do Marketing Digital moderno?', 'Apenas conseguir curtidas', FALSE, 2),
      ('Qual é um dos maiores objetivos do Marketing Digital moderno?', 'Fazer anúncios sem estratégia', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_dificil3;

    RAISE NOTICE '44 perguntas inseridas com sucesso (source=seed_marketing_digital_dificil_v3).';
  END IF;
END $$;

COMMIT;
