-- Alternativas (BE-003, regularização) — Marketing Digital difícil lote 4: as perguntas ativas v3#27 a v3#44 do seed dificil_v3 (migration 059) e as 12 do dificil_v4 (migration 063).
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
    ('seed_marketing_digital_dificil_v3', 'O que é teste multivariado?', 0, 'Remover páginas', 'Teste de duas versões de uma página para identificar melhor desempenho'),
    ('seed_marketing_digital_dificil_v3', 'O que é teste multivariado?', 2, 'Apenas alterar uma cor', 'Teste de vários públicos de anúncios para identificar melhor localização'),
    ('seed_marketing_digital_dificil_v3', 'O que é teste multivariado?', 3, 'Criar uma nova empresa', 'Teste de várias plataformas de hospedagem para identificar melhor servidor do site'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização baseada em IA?', 0, 'Bloqueio de dados', 'Uso de regras manuais para padronizar experiências do usuário'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização baseada em IA?', 2, 'Criação física de produtos', 'Uso de automação simples para enviar mensagens iguais ao usuário'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização baseada em IA?', 3, 'Envio manual de mensagens', 'Uso de segmentação básica para restringir experiências ao usuário'),
    ('seed_marketing_digital_dificil_v3', 'O que é análise preditiva no marketing?', 1, 'Apagar históricos', 'Uso de dados para resumir comportamentos passados dos consumidores'),
    ('seed_marketing_digital_dificil_v3', 'O que é análise preditiva no marketing?', 2, 'Criar anúncios impressos', 'Uso de pesquisas para descrever opiniões atuais dos consumidores'),
    ('seed_marketing_digital_dificil_v3', 'O que é análise preditiva no marketing?', 3, 'Substituir clientes', 'Uso de relatórios para comparar resultados anteriores dos consumidores'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia omnichannel?', 1, 'Exclusão de canais digitais', 'Exclusão de canais digitais para oferecer experiência simplificada ao cliente'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia omnichannel?', 2, 'Uso de apenas uma rede social', 'Separação de vários canais para oferecer experiência independente ao cliente'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia omnichannel?', 3, 'Venda apenas presencial', 'Ampliação de canais pagos para oferecer visibilidade constante ao cliente'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Experience (CX)?', 0, 'Sistema de pagamento', 'Satisfação pontual do cliente com o preço'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Experience (CX)?', 2, 'Apenas preço do produto', 'Atendimento telefônico da marca com o cliente'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Experience (CX)?', 3, 'Número de anúncios', 'Quantidade de contatos do cliente com a marca'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia de reativação?', 0, 'Apagar dados', 'Ações para remover clientes inativos'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia de reativação?', 1, 'Criar novos computadores', 'Ações para atrair novos clientes potenciais'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia de reativação?', 3, 'Bloquear usuários', 'Ações para fidelizar clientes já ativos'),
    ('seed_marketing_digital_dificil_v3', 'O que é marketing viral planejado?', 0, 'Divulgação sem objetivo', 'Estratégia criada para comprar seguidores e ampliar alcance imediato'),
    ('seed_marketing_digital_dificil_v3', 'O que é marketing viral planejado?', 1, 'Ataque digital', 'Estratégia criada para disparar mensagens e ampliar alcance massivo'),
    ('seed_marketing_digital_dificil_v3', 'O que é marketing viral planejado?', 2, 'Spam', 'Estratégia criada para pagar influenciadores e alcance garantido'),
    ('seed_marketing_digital_dificil_v3', 'O que é autoridade digital?', 1, 'Número de computadores', 'Nível de investimento e de frequência de uma marca online'),
    ('seed_marketing_digital_dificil_v3', 'O que é autoridade digital?', 2, 'Quantidade de funcionários', 'Número de seguidores e curtidas de uma marca online'),
    ('seed_marketing_digital_dificil_v3', 'O que é autoridade digital?', 3, 'Tamanho do escritório', 'Volume de vendas e faturamento de uma marca online'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de comunidade?', 0, 'Evitar interação', 'Realização de campanhas pontuais com usuários em torno da marca'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de comunidade?', 2, 'Apenas vender uma vez', 'Venda de produtos exclusivos para usuários em torno da marca'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de comunidade?', 3, 'Remover seguidores', 'Aumento de seguidores novos entre usuários em torno da marca'),
    ('seed_marketing_digital_dificil_v3', 'O que é social listening?', 1, 'Criação de músicas', 'Publicação de conteúdos e anúncios sobre uma marca na internet'),
    ('seed_marketing_digital_dificil_v3', 'O que é social listening?', 2, 'Edição de vídeos', 'Medição de cliques e impressões sobre uma marca na internet'),
    ('seed_marketing_digital_dificil_v3', 'O que é social listening?', 3, 'Bloqueio de comentários', 'Moderação de comentários e respostas públicas sobre uma marca na internet'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de conteúdo baseada em dados?', 0, 'Publicar sem planejamento', 'Criar conteúdos usando intuição sobre tendências e concorrentes'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de conteúdo baseada em dados?', 1, 'Copiar concorrentes', 'Criar conteúdos usando modelos prontos sobre produtos e preços'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de conteúdo baseada em dados?', 3, 'Ignorar métricas', 'Criar conteúdos usando calendários fixos sobre datas e eventos'),
    ('seed_marketing_digital_dificil_v3', 'O que é escalabilidade em Marketing Digital?', 0, 'Reduzir alcance', 'Capacidade de aumentar investimento mantendo equipe'),
    ('seed_marketing_digital_dificil_v3', 'O que é escalabilidade em Marketing Digital?', 1, 'Diminuir clientes', 'Capacidade de reduzir custos mantendo qualidade'),
    ('seed_marketing_digital_dificil_v3', 'O que é escalabilidade em Marketing Digital?', 2, 'Parar campanhas', 'Capacidade de ampliar canais mantendo identidade'),
    ('seed_marketing_digital_dificil_v3', 'O que é um MVP em uma estratégia digital?', 0, 'Sistema operacional', 'Versão final de uma solução usada para lançar uma marca'),
    ('seed_marketing_digital_dificil_v3', 'O que é um MVP em uma estratégia digital?', 1, 'Produto final obrigatório', 'Versão completa de uma solução usada para vender uma ideia'),
    ('seed_marketing_digital_dificil_v3', 'O que é um MVP em uma estratégia digital?', 2, 'Banco de dados', 'Plano de negócios de uma solução usado para financiar uma ideia'),
    ('seed_marketing_digital_dificil_v3', 'O que é validação de mercado?', 0, 'Remover clientes', 'Processo de calcular se existe orçamento real para uma solução'),
    ('seed_marketing_digital_dificil_v3', 'O que é validação de mercado?', 2, 'Copiar concorrentes', 'Processo de comparar se existe diferença real entre soluções'),
    ('seed_marketing_digital_dificil_v3', 'O que é validação de mercado?', 3, 'Criar anúncios sem público', 'Processo de definir se existe preço ideal para uma solução'),
    ('seed_marketing_digital_dificil_v3', 'O que é experimentação contínua?', 0, 'Cancelar campanhas', 'Realização ocasional de testes para confirmar resultados'),
    ('seed_marketing_digital_dificil_v3', 'O que é experimentação contínua?', 1, 'Manter tudo igual', 'Repetição constante de ações para manter resultados'),
    ('seed_marketing_digital_dificil_v3', 'O que é experimentação contínua?', 3, 'Evitar mudanças', 'Registro constante de dados para arquivar resultados'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia data-driven?', 0, 'Decisões apenas por opinião', 'Tomada de decisões baseada em opiniões'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia data-driven?', 1, 'Estratégia sem métricas', 'Tomada de decisões baseada em tradição'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia data-driven?', 2, 'Marketing sem objetivo', 'Tomada de decisões baseada em intuição'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a importância da análise de dados no Marketing Digital avançado?', 1, 'Elimina necessidade de planejamento', 'Permite reduzir planejamento e antecipar resultados'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a importância da análise de dados no Marketing Digital avançado?', 2, 'Impede crescimento', 'Permite padronizar investimentos e simplificar resultados'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a importância da análise de dados no Marketing Digital avançado?', 3, 'Substitui produtos', 'Permite substituir produtos e acelerar resultados'),
    ('seed_marketing_digital_dificil_v3', 'Qual é um dos maiores objetivos do Marketing Digital moderno?', 0, 'Vender sem conhecer clientes', 'Criar crescimento acelerado através de promoções, descontos e urgência'),
    ('seed_marketing_digital_dificil_v3', 'Qual é um dos maiores objetivos do Marketing Digital moderno?', 2, 'Apenas conseguir curtidas', 'Criar crescimento visível através de curtidas, seguidores e alcance'),
    ('seed_marketing_digital_dificil_v3', 'Qual é um dos maiores objetivos do Marketing Digital moderno?', 3, 'Fazer anúncios sem estratégia', 'Criar crescimento imediato através de anúncios, volume e repetição'),
    ('seed_marketing_digital_dificil_v4', 'O que é Marketing baseado em contas (ABM)?', 1, 'Publicidade offline', 'Estratégia focada em mercados ou públicos amplos de baixo custo'),
    ('seed_marketing_digital_dificil_v4', 'O que é Marketing baseado em contas (ABM)?', 2, 'Venda sem segmentação', 'Estratégia focada em vendas ou contratos recorrentes de baixo valor'),
    ('seed_marketing_digital_dificil_v4', 'O que é Marketing baseado em contas (ABM)?', 3, 'Divulgação aleatória para todos', 'Estratégia focada em parceiros ou fornecedores específicos de alto custo'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição linear em marketing?', 0, 'Modelo sem dados', 'Modelo que atribui crédito ao primeiro ponto de contato da jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição linear em marketing?', 1, 'Modelo que ignora clientes', 'Modelo que atribui crédito ao último ponto de contato da jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição linear em marketing?', 2, 'Modelo que considera apenas o último clique', 'Modelo que atribui mais crédito aos pontos de contato intermediários da jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é uma métrica North Star?', 0, 'Quantidade de anúncios', 'Indicador secundário que representa o custo investido pela empresa'),
    ('seed_marketing_digital_dificil_v4', 'O que é uma métrica North Star?', 1, 'Número de seguidores', 'Indicador visual que representa o alcance obtido pela marca'),
    ('seed_marketing_digital_dificil_v4', 'O que é uma métrica North Star?', 3, 'Número de computadores', 'Indicador mensal que representa o lucro obtido pelos sócios'),
    ('seed_marketing_digital_dificil_v4', 'O que é análise de coorte?', 0, 'Alteração de preços', 'Comparação de preços de produtos com características ou períodos semelhantes'),
    ('seed_marketing_digital_dificil_v4', 'O que é análise de coorte?', 1, 'Exclusão de clientes antigos', 'Remoção de usuários inativos com características ou períodos semelhantes'),
    ('seed_marketing_digital_dificil_v4', 'O que é análise de coorte?', 2, 'Criação de anúncios', 'Criação de anúncios para públicos com características ou interesses semelhantes'),
    ('seed_marketing_digital_dificil_v4', 'O que é um mapa de calor (Heatmap)?', 1, 'Rede social', 'Ferramenta que mostra quantos usuários visitam uma página'),
    ('seed_marketing_digital_dificil_v4', 'O que é um mapa de calor (Heatmap)?', 2, 'Sistema de segurança física', 'Ferramenta que mostra de onde usuários acessam uma página'),
    ('seed_marketing_digital_dificil_v4', 'O que é um mapa de calor (Heatmap)?', 3, 'Banco de dados', 'Ferramenta que mostra quando usuários compram em uma página inicial'),
    ('seed_marketing_digital_dificil_v4', 'O que é intenção de busca no SEO?', 0, 'Tamanho da página', 'Local de onde uma pessoa realiza determinada pesquisa'),
    ('seed_marketing_digital_dificil_v4', 'O que é intenção de busca no SEO?', 1, 'Quantidade de palavras digitadas', 'Aparelho com o qual uma pessoa realiza determinada pesquisa'),
    ('seed_marketing_digital_dificil_v4', 'O que é intenção de busca no SEO?', 2, 'Velocidade do navegador', 'Resultado que uma pessoa encontra em determinada pesquisa'),
    ('seed_marketing_digital_dificil_v4', 'O que é SEO semântico?', 0, 'Apenas repetir palavras-chave', 'Estratégia de otimizar conteúdos repetindo palavras-chave e termos exatos das pesquisas'),
    ('seed_marketing_digital_dificil_v4', 'O que é SEO semântico?', 1, 'Criar anúncios pagos', 'Estratégia de promover conteúdos comprando anúncios e posições de destaque nas pesquisas'),
    ('seed_marketing_digital_dificil_v4', 'O que é SEO semântico?', 3, 'Apagar conteúdos', 'Estratégia de simplificar conteúdos removendo textos antigos e imagens das pesquisas'),
    ('seed_marketing_digital_dificil_v4', 'O que é cannibalização de palavras-chave?', 1, 'Quando um site fecha', 'Quando vários sites de empresas diferentes competem pela mesma palavra-chave'),
    ('seed_marketing_digital_dificil_v4', 'O que é cannibalização de palavras-chave?', 2, 'Quando um anúncio viraliza', 'Quando várias palavras do mesmo texto repetem a mesma palavra-chave'),
    ('seed_marketing_digital_dificil_v4', 'O que é cannibalização de palavras-chave?', 3, 'Quando aumenta seguidores', 'Quando várias páginas do mesmo site perdem a mesma palavra-chave'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição baseada em posição?', 0, 'Modelo sem análise', 'Modelo que dá maior importância aos contatos mais caros da jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição baseada em posição?', 2, 'Modelo aleatório', 'Modelo que dá a mesma importância aos contatos de toda a jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição baseada em posição?', 3, 'Modelo apenas offline', 'Modelo que dá maior importância aos contatos presenciais da jornada'),
    ('seed_marketing_digital_dificil_v4', 'O que é personalização preditiva?', 0, 'Envio igual para todos', 'Uso de regras e segmentos fixos para padronizar necessidades do usuário'),
    ('seed_marketing_digital_dificil_v4', 'O que é personalização preditiva?', 1, 'Publicação manual', 'Uso de pesquisas e entrevistas para registrar necessidades do usuário'),
    ('seed_marketing_digital_dificil_v4', 'O que é personalização preditiva?', 3, 'Remoção de dados', 'Uso de promoções e descontos para estimular necessidades do usuário'),
    ('seed_marketing_digital_dificil_v4', 'O que é experimentação de crescimento?', 0, 'Copiar concorrentes', 'Processo pontual de testar produtos para encontrar defeitos de funcionamento'),
    ('seed_marketing_digital_dificil_v4', 'O que é experimentação de crescimento?', 2, 'Fazer campanhas sem medir', 'Processo contínuo de repetir campanhas para manter resultados de crescimento'),
    ('seed_marketing_digital_dificil_v4', 'O que é experimentação de crescimento?', 3, 'Evitar mudanças', 'Processo contínuo de copiar tendências para encontrar ideias de crescimento'),
    ('seed_marketing_digital_dificil_v4', 'O que é marketing orientado por dados?', 0, 'Decisões apenas por opinião', 'Tomada de decisões baseada em opiniões e experiências pessoais'),
    ('seed_marketing_digital_dificil_v4', 'O que é marketing orientado por dados?', 2, 'Publicação sem objetivo', 'Tomada de decisões baseada em modelos e tendências populares'),
    ('seed_marketing_digital_dificil_v4', 'O que é marketing orientado por dados?', 3, 'Estratégia sem métricas', 'Tomada de decisões baseada em intuição e histórico da equipe')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital difícil lote 4: as perguntas ativas v3#27 a v3#44 do seed dificil_v3 (migration 059) e as 12 do dificil_v4 (migration 063): % alternativa(s) errada(s) atualizada(s) (esperado: 90).', v_updated;
END $$;
