-- Seed: conteúdo Marketing Digital, nível Médio (31 perguntas)
-- Fonte: lote "MARKETING DIGITAL — MÉDIO (42
-- questões)" fornecido pelo proprietário do projeto, filtrado para conter
-- apenas perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-026).
--
-- Das 42 perguntas do lote original, 11 já existiam
-- palavra-por-palavra no banco (repetições de seeds anteriores de Marketing
-- Digital) — foram descartadas. As 31 restantes são genuinamente novas e
-- entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (67 — distinta das seeds 42 a 65 já
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_medio_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_medio_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_medio3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_marketing_digital_medio_v3'
    FROM (VALUES
      ('Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?'),
      ('O que é uma persona no Marketing Digital?'),
      ('Qual é a principal finalidade de criar uma persona?'),
      ('O que representa o topo do funil de vendas?'),
      ('O que acontece normalmente no fundo do funil?'),
      ('O que é CPC em anúncios digitais?'),
      ('O que significa CPM?'),
      ('O que significa CPA no Marketing Digital?'),
      ('Qual é a vantagem principal de anúncios segmentados?'),
      ('Qual é a função principal do Google Analytics?'),
      ('Qual é o objetivo principal de uma boa copy?'),
      ('O que é CTA em uma página de vendas?'),
      ('Qual é uma vantagem da automação de marketing?'),
      ('O que é CRM?'),
      ('O que é inbound marketing?'),
      ('O que é outbound marketing?'),
      ('Qual é a função do SEO técnico?'),
      ('O que são palavras-chave?'),
      ('Por que as palavras-chave são importantes no SEO?'),
      ('O que é link building?'),
      ('O que é autoridade de domínio?'),
      ('O que é taxa de rejeição (bounce rate)?'),
      ('O que é uma campanha de conversão?'),
      ('O que é ROI?'),
      ('Por que medir ROI é importante?'),
      ('O que é branding digital?'),
      ('O que são métricas de vaidade?'),
      ('Qual métrica geralmente indica melhor resultado comercial?'),
      ('O que é calendário de conteúdo?'),
      ('O que é estratégia de conteúdo?'),
      ('Por que uma empresa deve analisar dados de marketing?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_medio3 q
    JOIN (VALUES
      ('Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 'Marketing Digital não utiliza dados', FALSE, 0),
      ('Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 'Marketing Tradicional funciona apenas com computadores', FALSE, 1),
      ('Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 'Marketing Digital não precisa de estratégia', FALSE, 2),
      ('Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 'Marketing Digital utiliza canais online e permite maior medição de resultados', TRUE, 3),
      ('O que é uma persona no Marketing Digital?', 'Perfil detalhado do cliente ideal baseado em dados e características', TRUE, 0),
      ('O que é uma persona no Marketing Digital?', 'Uma ferramenta de edição', FALSE, 1),
      ('O que é uma persona no Marketing Digital?', 'Nome de uma campanha publicitária', FALSE, 2),
      ('O que é uma persona no Marketing Digital?', 'Um tipo de anúncio', FALSE, 3),
      ('Qual é a principal finalidade de criar uma persona?', 'Aumentar o preço dos produtos', FALSE, 0),
      ('Qual é a principal finalidade de criar uma persona?', 'Eliminar concorrentes', FALSE, 1),
      ('Qual é a principal finalidade de criar uma persona?', 'Criar campanhas mais direcionadas ao público correto', TRUE, 2),
      ('Qual é a principal finalidade de criar uma persona?', 'Criar softwares', FALSE, 3),
      ('O que representa o topo do funil de vendas?', 'Pós-venda', FALSE, 0),
      ('O que representa o topo do funil de vendas?', 'Pagamento final', FALSE, 1),
      ('O que representa o topo do funil de vendas?', 'Fase de atração e descoberta', TRUE, 2),
      ('O que representa o topo do funil de vendas?', 'Cancelamento', FALSE, 3),
      ('O que acontece normalmente no fundo do funil?', 'O cliente está mais próximo da decisão de compra', TRUE, 0),
      ('O que acontece normalmente no fundo do funil?', 'A pessoa ainda não conhece a marca', FALSE, 1),
      ('O que acontece normalmente no fundo do funil?', 'O conteúdo é sempre educativo', FALSE, 2),
      ('O que acontece normalmente no fundo do funil?', 'Não existe contato com cliente', FALSE, 3),
      ('O que é CPC em anúncios digitais?', 'Conversão por cliente', FALSE, 0),
      ('O que é CPC em anúncios digitais?', 'Custo por clique', TRUE, 1),
      ('O que é CPC em anúncios digitais?', 'Criação de publicação', FALSE, 2),
      ('O que é CPC em anúncios digitais?', 'Controle de página comercial', FALSE, 3),
      ('O que significa CPM?', 'Custo por mercado', FALSE, 0),
      ('O que significa CPM?', 'Custo por mil impressões', TRUE, 1),
      ('O que significa CPM?', 'Controle de marketing', FALSE, 2),
      ('O que significa CPM?', 'Conversão por mensagem', FALSE, 3),
      ('O que significa CPA no Marketing Digital?', 'Custo por aquisição', TRUE, 0),
      ('O que significa CPA no Marketing Digital?', 'Controle de página automática', FALSE, 1),
      ('O que significa CPA no Marketing Digital?', 'Custo por anúncio', FALSE, 2),
      ('O que significa CPA no Marketing Digital?', 'Comunicação pública avançada', FALSE, 3),
      ('Qual é a vantagem principal de anúncios segmentados?', 'Permitem alcançar pessoas com características específicas', TRUE, 0),
      ('Qual é a vantagem principal de anúncios segmentados?', 'Eliminam todos os custos', FALSE, 1),
      ('Qual é a vantagem principal de anúncios segmentados?', 'Garantem vendas automaticamente', FALSE, 2),
      ('Qual é a vantagem principal de anúncios segmentados?', 'Substituem produtos', FALSE, 3),
      ('Qual é a função principal do Google Analytics?', 'Criar senhas', FALSE, 0),
      ('Qual é a função principal do Google Analytics?', 'Criar computadores', FALSE, 1),
      ('Qual é a função principal do Google Analytics?', 'Analisar comportamento e dados dos visitantes', TRUE, 2),
      ('Qual é a função principal do Google Analytics?', 'Editar vídeos', FALSE, 3),
      ('Qual é o objetivo principal de uma boa copy?', 'Aumentar arquivos', FALSE, 0),
      ('Qual é o objetivo principal de uma boa copy?', 'Gerar interesse e levar o público a tomar uma ação', TRUE, 1),
      ('Qual é o objetivo principal de uma boa copy?', 'Criar aplicativos', FALSE, 2),
      ('Qual é o objetivo principal de uma boa copy?', 'Apenas informar sem objetivo', FALSE, 3),
      ('O que é CTA em uma página de vendas?', 'Sistema de pagamento', FALSE, 0),
      ('O que é CTA em uma página de vendas?', 'Código de programação', FALSE, 1),
      ('O que é CTA em uma página de vendas?', 'Elemento que incentiva o visitante a realizar uma ação', TRUE, 2),
      ('O que é CTA em uma página de vendas?', 'Banco de dados', FALSE, 3),
      ('Qual é uma vantagem da automação de marketing?', 'Impedir vendas', FALSE, 0),
      ('Qual é uma vantagem da automação de marketing?', 'Remover dados', FALSE, 1),
      ('Qual é uma vantagem da automação de marketing?', 'Eliminar todos os funcionários', FALSE, 2),
      ('Qual é uma vantagem da automação de marketing?', 'Economizar tempo e melhorar relacionamento com clientes', TRUE, 3),
      ('O que é CRM?', 'Rede social', FALSE, 0),
      ('O que é CRM?', 'Linguagem de programação', FALSE, 1),
      ('O que é CRM?', 'Sistema para gerenciar relacionamento com clientes', TRUE, 2),
      ('O que é CRM?', 'Sistema operacional', FALSE, 3),
      ('O que é inbound marketing?', 'Estratégia para atrair clientes através de conteúdo relevante', TRUE, 0),
      ('O que é inbound marketing?', 'Bloqueio de publicidade', FALSE, 1),
      ('O que é inbound marketing?', 'Apenas anúncios impressos', FALSE, 2),
      ('O que é inbound marketing?', 'Venda porta a porta', FALSE, 3),
      ('O que é outbound marketing?', 'Banco de dados', FALSE, 0),
      ('O que é outbound marketing?', 'Estratégia em que a empresa busca ativamente alcançar clientes', TRUE, 1),
      ('O que é outbound marketing?', 'Sistema operacional', FALSE, 2),
      ('O que é outbound marketing?', 'Cliente procurando sozinho', FALSE, 3),
      ('Qual é a função do SEO técnico?', 'Criar logotipos', FALSE, 0),
      ('Qual é a função do SEO técnico?', 'Melhorar aspectos técnicos de um site para mecanismos de busca', TRUE, 1),
      ('Qual é a função do SEO técnico?', 'Gerenciar pagamentos', FALSE, 2),
      ('Qual é a função do SEO técnico?', 'Criar vídeos', FALSE, 3),
      ('O que são palavras-chave?', 'Códigos de programação', FALSE, 0),
      ('O que são palavras-chave?', 'Termos utilizados pelos usuários em pesquisas online', TRUE, 1),
      ('O que são palavras-chave?', 'Arquivos ocultos', FALSE, 2),
      ('O que são palavras-chave?', 'Senhas de clientes', FALSE, 3),
      ('Por que as palavras-chave são importantes no SEO?', 'Criam aplicativos', FALSE, 0),
      ('Por que as palavras-chave são importantes no SEO?', 'Aumentam memória do computador', FALSE, 1),
      ('Por que as palavras-chave são importantes no SEO?', 'Ajudam conteúdos a serem encontrados pelos usuários', TRUE, 2),
      ('Por que as palavras-chave são importantes no SEO?', 'Eliminam concorrência', FALSE, 3),
      ('O que é link building?', 'Estratégia de obter links de outros sites para melhorar autoridade', TRUE, 0),
      ('O que é link building?', 'Criação de imagens', FALSE, 1),
      ('O que é link building?', 'Venda de produtos', FALSE, 2),
      ('O que é link building?', 'Bloqueio de páginas', FALSE, 3),
      ('O que é autoridade de domínio?', 'Tipo de navegador', FALSE, 0),
      ('O que é autoridade de domínio?', 'Nome do proprietário', FALSE, 1),
      ('O que é autoridade de domínio?', 'Número de computadores', FALSE, 2),
      ('O que é autoridade de domínio?', 'Indicador relacionado à confiança e relevância de um site', TRUE, 3),
      ('O que é taxa de rejeição (bounce rate)?', 'Número de vendas', FALSE, 0),
      ('O que é taxa de rejeição (bounce rate)?', 'Quantidade de anúncios', FALSE, 1),
      ('O que é taxa de rejeição (bounce rate)?', 'Valor do produto', FALSE, 2),
      ('O que é taxa de rejeição (bounce rate)?', 'Percentual de visitantes que saem sem realizar interação significativa', TRUE, 3),
      ('O que é uma campanha de conversão?', 'Página de erro', FALSE, 0),
      ('O que é uma campanha de conversão?', 'Campanha criada para gerar uma ação específica como compra ou cadastro', TRUE, 1),
      ('O que é uma campanha de conversão?', 'Apenas publicação gratuita', FALSE, 2),
      ('O que é uma campanha de conversão?', 'Campanha sem objetivo', FALSE, 3),
      ('O que é ROI?', 'Rede online integrada', FALSE, 0),
      ('O que é ROI?', 'Resultado de impressão online', FALSE, 1),
      ('O que é ROI?', 'Registro operacional interno', FALSE, 2),
      ('O que é ROI?', 'Retorno sobre investimento', TRUE, 3),
      ('Por que medir ROI é importante?', 'Para saber se o investimento trouxe retorno', TRUE, 0),
      ('Por que medir ROI é importante?', 'Para criar sistemas', FALSE, 1),
      ('Por que medir ROI é importante?', 'Para eliminar anúncios', FALSE, 2),
      ('Por que medir ROI é importante?', 'Para aumentar seguidores automaticamente', FALSE, 3),
      ('O que é branding digital?', 'Gestão de servidores', FALSE, 0),
      ('O que é branding digital?', 'Criação de vírus', FALSE, 1),
      ('O que é branding digital?', 'Venda de computadores', FALSE, 2),
      ('O que é branding digital?', 'Construção e fortalecimento de uma marca no ambiente online', TRUE, 3),
      ('O que são métricas de vaidade?', 'Informações privadas', FALSE, 0),
      ('O que são métricas de vaidade?', 'Dados financeiros obrigatórios', FALSE, 1),
      ('O que são métricas de vaidade?', 'Dados que parecem importantes mas não mostram necessariamente resultados reais', TRUE, 2),
      ('O que são métricas de vaidade?', 'Dados de segurança', FALSE, 3),
      ('Qual métrica geralmente indica melhor resultado comercial?', 'Cor da publicação', FALSE, 0),
      ('Qual métrica geralmente indica melhor resultado comercial?', 'Conversões', TRUE, 1),
      ('Qual métrica geralmente indica melhor resultado comercial?', 'Apenas curtidas', FALSE, 2),
      ('Qual métrica geralmente indica melhor resultado comercial?', 'Número de emojis', FALSE, 3),
      ('O que é calendário de conteúdo?', 'Planejamento organizado das publicações', TRUE, 0),
      ('O que é calendário de conteúdo?', 'Banco de dados', FALSE, 1),
      ('O que é calendário de conteúdo?', 'Programa antivírus', FALSE, 2),
      ('O que é calendário de conteúdo?', 'Sistema operacional', FALSE, 3),
      ('O que é estratégia de conteúdo?', 'Apenas postar qualquer coisa', FALSE, 0),
      ('O que é estratégia de conteúdo?', 'Bloquear seguidores', FALSE, 1),
      ('O que é estratégia de conteúdo?', 'Apagar publicações', FALSE, 2),
      ('O que é estratégia de conteúdo?', 'Planejamento de criação e distribuição de conteúdos para alcançar objetivos', TRUE, 3),
      ('Por que uma empresa deve analisar dados de marketing?', 'Para eliminar clientes', FALSE, 0),
      ('Por que uma empresa deve analisar dados de marketing?', 'Para parar campanhas', FALSE, 1),
      ('Por que uma empresa deve analisar dados de marketing?', 'Para melhorar decisões e otimizar resultados', TRUE, 2),
      ('Por que uma empresa deve analisar dados de marketing?', 'Para substituir produtos', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_medio3;

    RAISE NOTICE '31 perguntas inseridas com sucesso (source=seed_marketing_digital_medio_v3).';
  END IF;
END $$;

COMMIT;
