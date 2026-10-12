-- Alternativas (BE-003, regularização) — Marketing Digital médio lote 4: 23 perguntas ativas de Marketing Digital médio (v3#20 em diante: v3 (12), v4 (9), v5 (1), v6 (1); ordem de inserção) ainda sem explicação.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda; só o texto das
-- alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis, sem absolutos só nas erradas).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_marketing_digital_medio_v3', 'Por que uma empresa deve analisar dados de marketing?', 0, 'Para eliminar clientes', 'Para eliminar clientes antigos do cadastro'),
    ('seed_marketing_digital_medio_v3', 'Por que uma empresa deve analisar dados de marketing?', 1, 'Para parar campanhas', 'Para parar campanhas e cancelar anúncios'),
    ('seed_marketing_digital_medio_v3', 'Por que uma empresa deve analisar dados de marketing?', 3, 'Para substituir produtos', 'Para substituir produtos e trocar o catálogo'),
    ('seed_marketing_digital_medio_v3', 'O que é branding digital?', 0, 'Gestão de servidores', 'Gestão de servidores e de redes de computadores da empresa online'),
    ('seed_marketing_digital_medio_v3', 'O que é branding digital?', 1, 'Criação de vírus', 'Criação de vírus e programas de proteção de dados'),
    ('seed_marketing_digital_medio_v3', 'O que é branding digital?', 2, 'Venda de computadores', 'Venda de computadores e equipamentos no ambiente online'),
    ('seed_marketing_digital_medio_v3', 'O que é uma campanha de conversão?', 0, 'Página de erro', 'Página criada para corrigir erros específicos como links ou imagens'),
    ('seed_marketing_digital_medio_v3', 'O que é uma campanha de conversão?', 2, 'Apenas publicação gratuita', 'Publicação criada para gerar alcance gratuito como curtidas ou partilhas'),
    ('seed_marketing_digital_medio_v3', 'O que é uma campanha de conversão?', 3, 'Campanha sem objetivo', 'Campanha criada para manter a marca sem ação específica nem prazo'),
    ('seed_marketing_digital_medio_v3', 'O que é link building?', 1, 'Criação de imagens', 'Estratégia de criar imagens de outros sites para melhorar o design'),
    ('seed_marketing_digital_medio_v3', 'O que é link building?', 2, 'Venda de produtos', 'Estratégia de vender produtos de outros sites para melhorar lucros'),
    ('seed_marketing_digital_medio_v3', 'O que é link building?', 3, 'Bloqueio de páginas', 'Estratégia de bloquear páginas de outros sites para melhorar segurança'),
    ('seed_marketing_digital_medio_v3', 'Por que medir ROI é importante?', 1, 'Para criar sistemas', 'Para saber quanto o sistema custou em tempo'),
    ('seed_marketing_digital_medio_v3', 'Por que medir ROI é importante?', 2, 'Para eliminar anúncios', 'Para saber se os anúncios foram eliminados'),
    ('seed_marketing_digital_medio_v3', 'O que é taxa de rejeição (bounce rate)?', 0, 'Número de vendas', 'Percentual de vendas realizadas sem desconto promocional ou frete'),
    ('seed_marketing_digital_medio_v3', 'O que é taxa de rejeição (bounce rate)?', 1, 'Quantidade de anúncios', 'Quantidade de anúncios exibidos sem alcançar nenhum visitante'),
    ('seed_marketing_digital_medio_v3', 'O que é taxa de rejeição (bounce rate)?', 2, 'Valor do produto', 'Valor do produto vendido sem incluir os impostos e as taxas'),
    ('seed_marketing_digital_medio_v3', 'Qual métrica geralmente indica melhor resultado comercial?', 0, 'Cor da publicação', 'Cor da página'),
    ('seed_marketing_digital_medio_v3', 'Qual métrica geralmente indica melhor resultado comercial?', 2, 'Apenas curtidas', 'Seguidores'),
    ('seed_marketing_digital_medio_v3', 'Qual métrica geralmente indica melhor resultado comercial?', 3, 'Número de emojis', 'Emojis usados'),
    ('seed_marketing_digital_medio_v3', 'O que é autoridade de domínio?', 0, 'Tipo de navegador', 'Indicador relacionado ao tipo de navegador de um site'),
    ('seed_marketing_digital_medio_v3', 'O que é autoridade de domínio?', 1, 'Nome do proprietário', 'Indicador relacionado ao nome do proprietário de um site'),
    ('seed_marketing_digital_medio_v3', 'O que é autoridade de domínio?', 2, 'Número de computadores', 'Indicador relacionado ao número de computadores de um site'),
    ('seed_marketing_digital_medio_v3', 'O que é estratégia de conteúdo?', 0, 'Apenas postar qualquer coisa', 'Publicação rápida de conteúdos copiados de outras páginas para ativar a página'),
    ('seed_marketing_digital_medio_v3', 'O que é estratégia de conteúdo?', 1, 'Bloquear seguidores', 'Bloqueio de seguidores e de comentários para evitar conflitos'),
    ('seed_marketing_digital_medio_v3', 'O que é estratégia de conteúdo?', 2, 'Apagar publicações', 'Exclusão de publicações antigas para reduzir o espaço na página'),
    ('seed_marketing_digital_medio_v3', 'O que são métricas de vaidade?', 0, 'Informações privadas', 'Informações privadas dos clientes que não devem ser divulgadas'),
    ('seed_marketing_digital_medio_v3', 'O que são métricas de vaidade?', 1, 'Dados financeiros obrigatórios', 'Dados financeiros exigidos por lei e entregues no fim do ano às autoridades fiscais'),
    ('seed_marketing_digital_medio_v3', 'O que são métricas de vaidade?', 3, 'Dados de segurança', 'Dados de segurança que protegem as contas contra acessos indevidos'),
    ('seed_marketing_digital_medio_v3', 'O que é calendário de conteúdo?', 1, 'Banco de dados', 'Banco de dados organizado dos clientes'),
    ('seed_marketing_digital_medio_v3', 'O que é calendário de conteúdo?', 2, 'Programa antivírus', 'Programa organizado de proteção digital'),
    ('seed_marketing_digital_medio_v3', 'O que é calendário de conteúdo?', 3, 'Sistema operacional', 'Sistema operacional dos aparelhos da equipa'),
    ('seed_marketing_digital_medio_v4', 'O que é frequência em anúncios digitais?', 1, 'Quantidade de funcionários', 'Quantidade média de funcionários que criam e publicam um anúncio'),
    ('seed_marketing_digital_medio_v4', 'O que é frequência em anúncios digitais?', 2, 'Número de computadores', 'Número médio de computadores que exibem um anúncio'),
    ('seed_marketing_digital_medio_v4', 'O que é frequência em anúncios digitais?', 3, 'Velocidade da internet', 'Velocidade média da internet que carrega um anúncio'),
    ('seed_marketing_digital_medio_v4', 'O que é uma sequência de e-mails automatizada?', 0, 'Exclusão de contatos', 'Série de exclusões de contatos feitas automaticamente de uma lista'),
    ('seed_marketing_digital_medio_v4', 'O que é uma sequência de e-mails automatizada?', 1, 'Envio aleatório de mensagens', 'Série de mensagens enviadas aleatoriamente sem estratégia alguma'),
    ('seed_marketing_digital_medio_v4', 'O que é uma sequência de e-mails automatizada?', 2, 'Bloqueio de clientes', 'Série de bloqueios de clientes feitos automaticamente por erro'),
    ('seed_marketing_digital_medio_v4', 'O que é alcance orgânico?', 0, 'Anúncios pagos', 'Pessoas alcançadas com investimento direto em anúncios pagos'),
    ('seed_marketing_digital_medio_v4', 'O que é alcance orgânico?', 2, 'Pessoas compradas', 'Pessoas compradas com investimento direto em listas de contatos'),
    ('seed_marketing_digital_medio_v4', 'O que é alcance orgânico?', 3, 'Usuários falsos', 'Usuários falsos criados para simular alcance em publicidade'),
    ('seed_marketing_digital_medio_v4', 'O que é uma isca digital?', 0, 'Vírus de computador', 'Programa malicioso enviado para invadir sistemas'),
    ('seed_marketing_digital_medio_v4', 'O que é uma isca digital?', 1, 'Produto físico obrigatório', 'Produto físico pago oferecido para fechar vendas'),
    ('seed_marketing_digital_medio_v4', 'O que é uma isca digital?', 2, 'Anúncio sem objetivo', 'Anúncio pago exibido para aumentar visualizações'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de abertura de e-mail?', 0, 'Número de produtos vendidos', 'Percentual de pessoas que compraram um produto enviado'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de abertura de e-mail?', 1, 'Quantidade de seguidores', 'Percentual de pessoas que seguiram uma página indicada'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de abertura de e-mail?', 3, 'Valor investido', 'Percentual de valor investido em uma mensagem enviada'),
    ('seed_marketing_digital_medio_v4', 'O que é otimização de anúncios?', 0, 'Apagar campanhas', 'Processo de apagar campanhas antigas para obter mais espaço'),
    ('seed_marketing_digital_medio_v4', 'O que é otimização de anúncios?', 1, 'Aumentar custos sem análise', 'Processo de aumentar custos para obter maior exposição'),
    ('seed_marketing_digital_medio_v4', 'O que é otimização de anúncios?', 3, 'Criar anúncios aleatórios', 'Processo de criar anúncios novos para obter mais cliques'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de cliques em e-mail marketing?', 1, 'Tamanho do arquivo', 'Percentual de espaço que o arquivo anexado ocupa na mensagem enviada'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de cliques em e-mail marketing?', 2, 'Quantidade de e-mails criados', 'Percentual de e-mails criados com links na mensagem'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de cliques em e-mail marketing?', 3, 'Número de funcionários', 'Percentual de funcionários que escreveram a mensagem'),
    ('seed_marketing_digital_medio_v4', 'Qual é a função principal de um funil de marketing?', 1, 'Apagar dados', 'Guiar os dados desde o armazenamento até a eliminação'),
    ('seed_marketing_digital_medio_v4', 'Qual é a função principal de um funil de marketing?', 2, 'Criar computadores', 'Guiar a produção desde o projeto até a entrega do produto'),
    ('seed_marketing_digital_medio_v4', 'Qual é a função principal de um funil de marketing?', 3, 'Bloquear visitantes', 'Guiar os visitantes desde a entrada até o bloqueio da página'),
    ('seed_marketing_digital_medio_v4', 'O que é uma estratégia de remarketing eficiente?', 0, 'Remover públicos', 'Evitar mensagens para as pessoas que já demonstraram interesse'),
    ('seed_marketing_digital_medio_v4', 'O que é uma estratégia de remarketing eficiente?', 2, 'Enviar anúncios sem critério', 'Mostrar anúncios repetidos para pessoas que já compraram o produto'),
    ('seed_marketing_digital_medio_v4', 'O que é uma estratégia de remarketing eficiente?', 3, 'Ignorar visitantes anteriores', 'Mostrar mensagens genéricas para pessoas que ainda não demonstraram interesse'),
    ('seed_marketing_digital_medio_v5', 'Qual é a importância de analisar métricas em uma campanha digital?', 1, 'Serve apenas para aumentar seguidores', 'Permite aumentar seguidores e melhorar publicações'),
    ('seed_marketing_digital_medio_v5', 'Qual é a importância de analisar métricas em uma campanha digital?', 2, 'Substitui completamente o planejamento', 'Permite substituir o planejamento e melhorar prazos'),
    ('seed_marketing_digital_medio_v5', 'Qual é a importância de analisar métricas em uma campanha digital?', 3, 'Impede mudanças na campanha', 'Permite impedir mudanças e manter estratégias'),
    ('seed_marketing_digital_medio_v6', 'O que é segmentação de público em Marketing Digital?', 1, 'Envio da mesma mensagem para todas as pessoas', 'Divisão das mensagens em grupos com tamanhos ou formatos semelhantes'),
    ('seed_marketing_digital_medio_v6', 'O que é segmentação de público em Marketing Digital?', 2, 'Exclusão de clientes antigos', 'Exclusão dos consumidores antigos com características ou interesses diferentes'),
    ('seed_marketing_digital_medio_v6', 'O que é segmentação de público em Marketing Digital?', 3, 'Criação de produtos sem pesquisa', 'Divisão dos produtos em grupos com preços ou marcas semelhantes')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital médio lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 65).', v_updated;
END $$;
