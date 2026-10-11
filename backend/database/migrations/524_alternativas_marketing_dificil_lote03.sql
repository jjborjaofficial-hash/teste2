-- Alternativas (BE-003, regularização) — Marketing Digital difícil lote 3: as perguntas ativas v3#2 a v3#26 do seed dificil_v3 (migration 059).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono: a resposta CERTA NÃO muda; só o texto das alternativas
-- ERRADAS é ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital difícil usa a faixa de migrations 520+ (reservada no PENDENTE.md).
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
    ('seed_marketing_digital_dificil_v3', 'O que caracteriza um Growth Hacker?', 0, 'Designer especializado em logotipos', 'Profissional focado em identidade visual através de logotipos, cores e tipografia'),
    ('seed_marketing_digital_dificil_v3', 'O que caracteriza um Growth Hacker?', 1, 'Vendedor exclusivamente presencial', 'Profissional focado em atendimento presencial através de visitas, reuniões e contratos'),
    ('seed_marketing_digital_dificil_v3', 'O que caracteriza um Growth Hacker?', 3, 'Pessoa que cria vírus para empresas', 'Profissional focado em infraestrutura através de servidores, redes e backups'),
    ('seed_marketing_digital_dificil_v3', 'O que é CRO (Conversion Rate Optimization)?', 0, 'Exclusão de campanhas', 'Processo de excluir campanhas e anúncios para reduzir investimentos'),
    ('seed_marketing_digital_dificil_v3', 'O que é CRO (Conversion Rate Optimization)?', 1, 'Redução de visitantes', 'Processo de ampliar públicos e visitantes para aumentar impressões'),
    ('seed_marketing_digital_dificil_v3', 'O que é CRO (Conversion Rate Optimization)?', 2, 'Criação de anúncios sem análise', 'Processo de criar anúncios e conteúdos para aumentar seguidores e curtidas'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o objetivo principal de uma landing page otimizada?', 0, 'Apenas apresentar imagens bonitas', 'Apresentar imagens e textos sobre a empresa'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o objetivo principal de uma landing page otimizada?', 1, 'Substituir todas as redes sociais', 'Substituir redes sociais e anúncios da empresa'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o objetivo principal de uma landing page otimizada?', 3, 'Aumentar o tamanho do site', 'Aumentar o tamanho e o número de páginas do site'),
    ('seed_marketing_digital_dificil_v3', 'O que é um funil de vendas avançado?', 1, 'Uma ferramenta de edição', 'Ferramenta que organiza diferentes etapas do trabalho da equipe de vendas'),
    ('seed_marketing_digital_dificil_v3', 'O que é um funil de vendas avançado?', 2, 'Um banco de dados', 'Banco de dados que armazena diferentes etapas do cadastro do consumidor'),
    ('seed_marketing_digital_dificil_v3', 'O que é um funil de vendas avançado?', 3, 'Apenas uma página de venda', 'Página de vendas que apresenta diferentes etapas da oferta ao consumidor'),
    ('seed_marketing_digital_dificil_v3', 'O que significa LTV no Marketing Digital?', 0, 'Número de seguidores', 'Número total de visitas que um anúncio gera durante seu período na plataforma'),
    ('seed_marketing_digital_dificil_v3', 'O que significa LTV no Marketing Digital?', 2, 'Tempo de carregamento do site', 'Tempo total de carregamento que um site leva durante seu acesso pelo usuário'),
    ('seed_marketing_digital_dificil_v3', 'O que significa LTV no Marketing Digital?', 3, 'Quantidade de anúncios', 'Quantidade total de anúncios que uma empresa publica durante seu ciclo de campanhas'),
    ('seed_marketing_digital_dificil_v3', 'Qual relação é geralmente desejável entre LTV e CAC?', 0, 'Nenhum deles importa', 'LTV deve ser igual ao CAC'),
    ('seed_marketing_digital_dificil_v3', 'Qual relação é geralmente desejável entre LTV e CAC?', 1, 'Devem sempre ser iguais', 'LTV deve ser menor que CAC'),
    ('seed_marketing_digital_dificil_v3', 'Qual relação é geralmente desejável entre LTV e CAC?', 3, 'CAC deve sempre ser maior que LTV', 'LTV deve ser indiferente ao CAC'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição de conversão?', 0, 'Aumentar seguidores falsos', 'Processo de decidir quais canais receberão verba para uma campanha'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição de conversão?', 1, 'Criar novos produtos', 'Processo de medir quais anúncios geraram cliques para uma campanha'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição de conversão?', 2, 'Apagar dados', 'Processo de registrar quais vendas geraram comissões para uma equipe'),
    ('seed_marketing_digital_dificil_v3', 'O que é modelo de atribuição last click?', 1, 'Modelo baseado apenas em seguidores', 'Modelo que atribui a conversão ao primeiro canal antes da compra'),
    ('seed_marketing_digital_dificil_v3', 'O que é modelo de atribuição last click?', 2, 'Modelo que ignora todos os canais', 'Modelo que divide a conversão entre os canais antes da compra'),
    ('seed_marketing_digital_dificil_v3', 'O que é modelo de atribuição last click?', 3, 'Modelo sem dados', 'Modelo que atribui a conversão ao canal mais caro antes da compra'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição baseada em dados?', 0, 'Modelo manual sem análise', 'Modelo que utiliza regras fixas para atribuir crédito ao último ponto de contato'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição baseada em dados?', 2, 'Modelo sem métricas', 'Modelo que utiliza estimativas de verba para distribuir crédito entre canais pagos'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição baseada em dados?', 3, 'Modelo aleatório', 'Modelo que utiliza sorteio simples para distribuir crédito entre pontos de contato'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Journey Mapping?', 0, 'Controle financeiro', 'Mapeamento dos custos da empresa desde produção até entrega final'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Journey Mapping?', 2, 'Criação de mapas físicos', 'Mapeamento dos canais do anúncio desde planejamento até medição final'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Journey Mapping?', 3, 'Desenvolvimento de aplicativos', 'Mapeamento das tarefas da equipe desde contratação até entrega final'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização em Marketing Digital?', 0, 'Remover informações dos clientes', 'Remover informações e registros de diferentes usuários'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização em Marketing Digital?', 1, 'Evitar análise de dados', 'Ampliar volume e frequência para diferentes usuários'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização em Marketing Digital?', 3, 'Enviar a mesma mensagem para todos', 'Padronizar mensagens e ofertas para diferentes usuários'),
    ('seed_marketing_digital_dificil_v3', 'O que é automação baseada em comportamento?', 1, 'Publicação manual diária', 'Envio manual de ações conforme calendário da equipe'),
    ('seed_marketing_digital_dificil_v3', 'O que é automação baseada em comportamento?', 2, 'Criação de hardware', 'Criação automática de relatórios conforme pedido da equipe'),
    ('seed_marketing_digital_dificil_v3', 'O que é automação baseada em comportamento?', 3, 'Bloqueio de usuários', 'Bloqueio automático de ações conforme regras do sistema'),
    ('seed_marketing_digital_dificil_v3', 'O que é lead scoring?', 1, 'Contagem de seguidores', 'Sistema de contagem para medir alcance dos seguidores'),
    ('seed_marketing_digital_dificil_v3', 'O que é lead scoring?', 2, 'Avaliação de anúncios físicos', 'Sistema de avaliação para medir qualidade dos anúncios'),
    ('seed_marketing_digital_dificil_v3', 'O que é lead scoring?', 3, 'Criação de vídeos', 'Sistema de produção para criar variedade dos vídeos'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a finalidade do lead scoring?', 0, 'Substituir vendedores', 'Substituir a equipe de vendas por automação'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a finalidade do lead scoring?', 1, 'Eliminar todos os contatos', 'Eliminar contatos antigos da base de dados'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a finalidade do lead scoring?', 2, 'Aumentar custos', 'Aumentar o número de contatos na base de dados'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma campanha de remarketing dinâmico?', 0, 'Publicação aleatória', 'Exibição padronizada de produtos ou conteúdos conforme calendário comercial'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma campanha de remarketing dinâmico?', 1, 'Anúncio offline', 'Exibição impressa de produtos ou conteúdos conforme região de distribuição'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma campanha de remarketing dinâmico?', 3, 'Campanha sem dados', 'Exibição ampliada de produtos ou conteúdos conforme orçamento disponível'),
    ('seed_marketing_digital_dificil_v3', 'O que é segmentação lookalike?', 0, 'Copiar anúncios concorrentes', 'Encontrar novos anúncios semelhantes aos melhores concorrentes existentes'),
    ('seed_marketing_digital_dificil_v3', 'O que é segmentação lookalike?', 2, 'Remover públicos', 'Remover usuários inativos semelhantes aos piores clientes existentes'),
    ('seed_marketing_digital_dificil_v3', 'O que é segmentação lookalike?', 3, 'Criar produtos iguais', 'Criar produtos novos semelhantes aos mais vendidos existentes'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma audiência personalizada?', 0, 'Público escolhido aleatoriamente', 'Público escolhido usando dados demográficos ou interesses amplos'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma audiência personalizada?', 1, 'Público sem informações', 'Público criado usando regras de orçamento ou prazos definidos'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma audiência personalizada?', 3, 'Público bloqueado', 'Público comprado usando listas de contatos de terceiros'),
    ('seed_marketing_digital_dificil_v3', 'O que é ROAS?', 0, 'Número de seguidores', 'Número de visitas geradas especificamente por anúncios'),
    ('seed_marketing_digital_dificil_v3', 'O que é ROAS?', 1, 'Quantidade de publicações', 'Quantidade de cliques gerados especificamente por anúncios'),
    ('seed_marketing_digital_dificil_v3', 'O que é ROAS?', 2, 'Velocidade do site', 'Custo financeiro gerado especificamente por anúncios'),
    ('seed_marketing_digital_dificil_v3', 'Qual fórmula representa ROAS?', 0, 'Clientes ÷ funcionários', 'Investimento em anúncios ÷ receita gerada pelos anúncios'),
    ('seed_marketing_digital_dificil_v3', 'Qual fórmula representa ROAS?', 1, 'Custos ÷ visitas', 'Lucro gerado pelos anúncios ÷ investimento em anúncios'),
    ('seed_marketing_digital_dificil_v3', 'Qual fórmula representa ROAS?', 2, 'Seguidores ÷ curtidas', 'Cliques gerados pelos anúncios ÷ investimento em anúncios'),
    ('seed_marketing_digital_dificil_v3', 'Um CTR baixo em um anúncio geralmente indica:', 0, 'Excelente segmentação sempre', 'Excelente segmentação ou grande interesse do público'),
    ('seed_marketing_digital_dificil_v3', 'Um CTR baixo em um anúncio geralmente indica:', 1, 'Muitas vendas garantidas', 'Muitas vendas ou alto retorno sobre o investimento'),
    ('seed_marketing_digital_dificil_v3', 'Um CTR baixo em um anúncio geralmente indica:', 3, 'Nenhuma necessidade de alteração', 'Pouca necessidade de alteração ou revisão do anúncio'),
    ('seed_marketing_digital_dificil_v3', 'O que é Quality Score em anúncios?', 1, 'Tamanho do anúncio', 'Avaliação do preço e orçamento de anúncios e campanhas relacionadas'),
    ('seed_marketing_digital_dificil_v3', 'O que é Quality Score em anúncios?', 2, 'Quantidade de seguidores', 'Contagem de cliques e impressões de anúncios e páginas relacionadas'),
    ('seed_marketing_digital_dificil_v3', 'O que é Quality Score em anúncios?', 3, 'Número de funcionários', 'Classificação do alcance e frequência de anúncios e públicos relacionados'),
    ('seed_marketing_digital_dificil_v3', 'O que é remarketing baseado em pixel?', 1, 'Criação de imagens', 'Uso de imagens de produtos para identificar clientes e criar públicos'),
    ('seed_marketing_digital_dificil_v3', 'O que é remarketing baseado em pixel?', 2, 'Sistema operacional', 'Uso de sistemas internos de vendas para identificar vendedores e criar metas'),
    ('seed_marketing_digital_dificil_v3', 'O que é remarketing baseado em pixel?', 3, 'Banco físico', 'Uso de cadastros em papel para identificar clientes e criar listas'),
    ('seed_marketing_digital_dificil_v3', 'O que é um pixel de rastreamento?', 0, 'Arquivo de imagem', 'Imagem usada para exibir informações sobre produtos dos anúncios'),
    ('seed_marketing_digital_dificil_v3', 'O que é um pixel de rastreamento?', 2, 'Parte da tela do computador', 'Texto usado para descrever informações sobre páginas dos sites'),
    ('seed_marketing_digital_dificil_v3', 'O que é um pixel de rastreamento?', 3, 'Tipo de anúncio', 'Anúncio usado para divulgar informações sobre ofertas dos clientes'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição multicanal?', 0, 'Uso de apenas um anúncio', 'Análise de um único canal que participou da campanha'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição multicanal?', 1, 'Bloqueio de usuários', 'Análise de vários públicos que participaram da pesquisa'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição multicanal?', 2, 'Exclusão de dados', 'Análise de vários anúncios que participaram do leilão')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital difícil lote 3: as perguntas ativas v3#2 a v3#26 do seed dificil_v3 (migration 059): % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
