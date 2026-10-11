-- Alternativas (BE-003, regularização) — Marketing Digital médio lote 3: 25 perguntas ativas ainda sem explicação, de v2#23 a v3#19 (seeds 049 e 058).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital usa a faixa de migrations 500+
-- para não colidir com as outras categorias (Finanças 144+, Produtividade 200+, Tecnologia 300+, IA 400+).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order, perguntas nem explicações. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_marketing_digital_medio_v2', 'Por que a segmentação pode melhorar uma campanha?', 0, 'Elimina custos', 'Pode aumentar o número de produtos disponíveis no estoque'),
    ('seed_marketing_digital_medio_v2', 'Por que a segmentação pode melhorar uma campanha?', 2, 'Impede análise', 'Pode dispensar a análise dos resultados da campanha'),
    ('seed_marketing_digital_medio_v2', 'Por que a segmentação pode melhorar uma campanha?', 3, 'Garante que todos comprem', 'Pode fazer os clientes comprarem na mesma semana'),
    ('seed_marketing_digital_medio_v2', 'O que é remarketing baseado em interação?', 1, 'Comunicação exclusivamente para funcionários', 'Comunicação direcionada a pessoas que ainda não conhecem a marca nem demonstraram interesse'),
    ('seed_marketing_digital_medio_v2', 'O que é remarketing baseado em interação?', 2, 'Publicidade sem dados', 'Publicidade distribuída a pessoas escolhidas ao acaso sem dados sobre o comportamento'),
    ('seed_marketing_digital_medio_v2', 'O que é remarketing baseado em interação?', 3, 'Divulgação sem público definido', 'Divulgação enviada a colaboradores internos que já conhecem os produtos da empresa'),
    ('seed_marketing_digital_medio_v2', 'Qual é o objetivo de uma landing page?', 0, 'Servir apenas como decoração', 'Apresentar o catálogo completo da loja física'),
    ('seed_marketing_digital_medio_v2', 'Qual é o objetivo de uma landing page?', 1, 'Armazenar dinheiro', 'Armazenar dados financeiros de cada visitante'),
    ('seed_marketing_digital_medio_v2', 'Qual é o objetivo de uma landing page?', 2, 'Substituir todas as redes sociais', 'Substituir o site principal e as redes sociais'),
    ('seed_marketing_digital_medio_v2', 'O que é branding?', 0, 'Apenas venda de produtos', 'Gestão do estoque e distribuição de um produto'),
    ('seed_marketing_digital_medio_v2', 'O que é branding?', 1, 'Programação de aplicativos', 'Gestão dos custos e pagamentos de uma empresa'),
    ('seed_marketing_digital_medio_v2', 'O que é branding?', 3, 'Controle de estoque', 'Gestão do software e dos servidores de um site'),
    ('seed_marketing_digital_medio_v2', 'O que caracteriza uma estratégia de conteúdo?', 0, 'Publicar sem objetivo', 'Cálculo de quanto, onde, quando e por que pagar as publicações'),
    ('seed_marketing_digital_medio_v2', 'O que caracteriza uma estratégia de conteúdo?', 1, 'Copiar qualquer conteúdo', 'Registro de quantos, quais, quando e por quem seguiram a página'),
    ('seed_marketing_digital_medio_v2', 'O que caracteriza uma estratégia de conteúdo?', 3, 'Evitar conhecer o público', 'Contagem de curtidas, comentários, cliques e visualizações do perfil'),
    ('seed_marketing_digital_medio_v2', 'O que uma análise de concorrentes pode revelar?', 0, 'Dados bancários privados', 'Salários, contratos e dados bancários privados dos funcionários'),
    ('seed_marketing_digital_medio_v2', 'O que uma análise de concorrentes pode revelar?', 1, 'Informações confidenciais garantidas', 'Contas internas, margens e acordos confidenciais dos concorrentes'),
    ('seed_marketing_digital_medio_v2', 'O que uma análise de concorrentes pode revelar?', 3, 'Senhas dos concorrentes', 'Senhas, acessos e arquivos privados dos sistemas dos concorrentes'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 0, 'Marketing Digital não utiliza dados', 'Marketing Digital utiliza canais impressos e dificulta a medição de resultados'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 1, 'Marketing Tradicional funciona apenas com computadores', 'Marketing Tradicional utiliza canais físicos e permite menor controle de custos'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 2, 'Marketing Digital não precisa de estratégia', 'Marketing Digital utiliza canais gratuitos e dispensa a definição de um público'),
    ('seed_marketing_digital_medio_v3', 'O que é uma persona no Marketing Digital?', 1, 'Uma ferramenta de edição', 'Resumo detalhado do produto ideal baseado em preços e características'),
    ('seed_marketing_digital_medio_v3', 'O que é uma persona no Marketing Digital?', 2, 'Nome de uma campanha publicitária', 'Relatório detalhado da campanha ideal baseado em metas e orçamentos'),
    ('seed_marketing_digital_medio_v3', 'O que é uma persona no Marketing Digital?', 3, 'Um tipo de anúncio', 'Perfil detalhado do concorrente ideal baseado em ofertas e características'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal finalidade de criar uma persona?', 0, 'Aumentar o preço dos produtos', 'Criar produtos mais baratos para o público geral'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal finalidade de criar uma persona?', 1, 'Eliminar concorrentes', 'Criar relatórios mais longos sobre os concorrentes'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal finalidade de criar uma persona?', 3, 'Criar softwares', 'Criar anúncios mais frequentes em vários canais'),
    ('seed_marketing_digital_medio_v3', 'O que representa o topo do funil de vendas?', 0, 'Pós-venda', 'Fase de compra e pagamento'),
    ('seed_marketing_digital_medio_v3', 'O que representa o topo do funil de vendas?', 1, 'Pagamento final', 'Fase de decisão e negociação'),
    ('seed_marketing_digital_medio_v3', 'O que representa o topo do funil de vendas?', 3, 'Cancelamento', 'Fase de fidelização e pós-venda'),
    ('seed_marketing_digital_medio_v3', 'O que acontece normalmente no fundo do funil?', 1, 'A pessoa ainda não conhece a marca', 'A pessoa está começando a conhecer a marca agora'),
    ('seed_marketing_digital_medio_v3', 'O que acontece normalmente no fundo do funil?', 2, 'O conteúdo é sempre educativo', 'O conteúdo é amplo e voltado a quem está explorando'),
    ('seed_marketing_digital_medio_v3', 'O que acontece normalmente no fundo do funil?', 3, 'Não existe contato com cliente', 'A marca ainda não tem contato com o cliente'),
    ('seed_marketing_digital_medio_v3', 'O que é CPC em anúncios digitais?', 0, 'Conversão por cliente', 'Custo por compra'),
    ('seed_marketing_digital_medio_v3', 'O que é CPC em anúncios digitais?', 2, 'Criação de publicação', 'Custo por conversão'),
    ('seed_marketing_digital_medio_v3', 'O que é CPC em anúncios digitais?', 3, 'Controle de página comercial', 'Custo por campanha'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPM?', 0, 'Custo por mercado', 'Custo por mil cliques'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPM?', 2, 'Controle de marketing', 'Custo por mil conversões'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPM?', 3, 'Conversão por mensagem', 'Custo por mil seguidores'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPA no Marketing Digital?', 1, 'Controle de página automática', 'Custo por alcance'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPA no Marketing Digital?', 3, 'Comunicação pública avançada', 'Custo por abertura'),
    ('seed_marketing_digital_medio_v3', 'Qual é a vantagem principal de anúncios segmentados?', 1, 'Eliminam todos os custos', 'Permitem reduzir o preço de produtos para o público'),
    ('seed_marketing_digital_medio_v3', 'Qual é a vantagem principal de anúncios segmentados?', 2, 'Garantem vendas automaticamente', 'Permitem substituir a equipe de vendas da empresa'),
    ('seed_marketing_digital_medio_v3', 'Qual é a vantagem principal de anúncios segmentados?', 3, 'Substituem produtos', 'Permitem dispensar a análise do comportamento do público'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função principal do Google Analytics?', 0, 'Criar senhas', 'Gerenciar contratos e pagamentos dos clientes'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função principal do Google Analytics?', 1, 'Criar computadores', 'Hospedar páginas e arquivos dos visitantes'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função principal do Google Analytics?', 3, 'Editar vídeos', 'Editar textos e imagens dos anúncios'),
    ('seed_marketing_digital_medio_v3', 'Qual é o objetivo principal de uma boa copy?', 0, 'Aumentar arquivos', 'Resumir o produto e levar o público a ler o manual'),
    ('seed_marketing_digital_medio_v3', 'Qual é o objetivo principal de uma boa copy?', 2, 'Criar aplicativos', 'Registrar a marca e levar o público a seguir a página'),
    ('seed_marketing_digital_medio_v3', 'Qual é o objetivo principal de uma boa copy?', 3, 'Apenas informar sem objetivo', 'Informar o preço e deixar o público decidir sozinho'),
    ('seed_marketing_digital_medio_v3', 'O que é CTA em uma página de vendas?', 0, 'Sistema de pagamento', 'Sistema que registra o visitante e guarda o seu histórico'),
    ('seed_marketing_digital_medio_v3', 'O que é CTA em uma página de vendas?', 1, 'Código de programação', 'Código que identifica o visitante e bloqueia o seu acesso'),
    ('seed_marketing_digital_medio_v3', 'O que é CTA em uma página de vendas?', 3, 'Banco de dados', 'Relatório que resume o visitante e mostra as suas compras'),
    ('seed_marketing_digital_medio_v3', 'Qual é uma vantagem da automação de marketing?', 0, 'Impedir vendas', 'Reduzir prazos e substituir relacionamento com clientes'),
    ('seed_marketing_digital_medio_v3', 'Qual é uma vantagem da automação de marketing?', 1, 'Remover dados', 'Apagar dados e dispensar análise de resultados'),
    ('seed_marketing_digital_medio_v3', 'Qual é uma vantagem da automação de marketing?', 2, 'Eliminar todos os funcionários', 'Reduzir a equipe e evitar contato com clientes'),
    ('seed_marketing_digital_medio_v3', 'O que é CRM?', 0, 'Rede social', 'Rede para divulgar produtos junto de clientes'),
    ('seed_marketing_digital_medio_v3', 'O que é CRM?', 1, 'Linguagem de programação', 'Linguagem para programar aplicações de clientes'),
    ('seed_marketing_digital_medio_v3', 'O que é CRM?', 3, 'Sistema operacional', 'Sistema para controlar estoque e entrega de pedidos'),
    ('seed_marketing_digital_medio_v3', 'O que é inbound marketing?', 1, 'Bloqueio de publicidade', 'Estratégia para bloquear anúncios através de filtros do navegador'),
    ('seed_marketing_digital_medio_v3', 'O que é inbound marketing?', 2, 'Apenas anúncios impressos', 'Estratégia para vender produtos através de visitas às residências'),
    ('seed_marketing_digital_medio_v3', 'O que é inbound marketing?', 3, 'Venda porta a porta', 'Estratégia para alcançar clientes através de anúncios impressos'),
    ('seed_marketing_digital_medio_v3', 'O que é outbound marketing?', 0, 'Banco de dados', 'Estratégia em que o cliente busca ativamente encontrar a empresa'),
    ('seed_marketing_digital_medio_v3', 'O que é outbound marketing?', 2, 'Sistema operacional', 'Estratégia em que a empresa aguarda ser encontrada por clientes'),
    ('seed_marketing_digital_medio_v3', 'O que é outbound marketing?', 3, 'Cliente procurando sozinho', 'Estratégia em que a empresa evita contato direto com clientes'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função do SEO técnico?', 0, 'Criar logotipos', 'Melhorar aspectos visuais de um logotipo para materiais impressos'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função do SEO técnico?', 2, 'Gerenciar pagamentos', 'Gerenciar aspectos financeiros de um site para plataformas de pagamento'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função do SEO técnico?', 3, 'Criar vídeos', 'Editar aspectos sonoros de um vídeo para canais de streaming'),
    ('seed_marketing_digital_medio_v3', 'O que são palavras-chave?', 0, 'Códigos de programação', 'Códigos utilizados pelos programadores em sistemas online'),
    ('seed_marketing_digital_medio_v3', 'O que são palavras-chave?', 2, 'Arquivos ocultos', 'Arquivos utilizados pelos administradores em servidores online'),
    ('seed_marketing_digital_medio_v3', 'O que são palavras-chave?', 3, 'Senhas de clientes', 'Senhas utilizadas pelos clientes em contas online'),
    ('seed_marketing_digital_medio_v3', 'Por que as palavras-chave são importantes no SEO?', 0, 'Criam aplicativos', 'Ajudam sites a serem hospedados pelos provedores'),
    ('seed_marketing_digital_medio_v3', 'Por que as palavras-chave são importantes no SEO?', 1, 'Aumentam memória do computador', 'Ajudam computadores a serem protegidos pelos antivírus'),
    ('seed_marketing_digital_medio_v3', 'Por que as palavras-chave são importantes no SEO?', 3, 'Eliminam concorrência', 'Ajudam concorrentes a serem eliminados pelos algoritmos')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital médio lote 3: 25 perguntas ativas ainda sem explicação, de v2#23 a v3#19 (seeds 049 e 058): % alternativa(s) errada(s) atualizada(s) (esperado: 74).', v_updated;
END $$;
