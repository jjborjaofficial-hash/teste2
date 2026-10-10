-- Alternativas (BE-003, regularização) — Marketing Digital difícil lote 1: as 24 perguntas ativas do seed dificil_v1 (migration 039) e a 1.ª do dificil_v2 (migration 050).
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
    ('seed_marketing_digital_dificil_v1', 'O que é LTV?', 0, 'Valor de uma publicação', 'Estimativa do custo que uma empresa pode ter para atrair um cliente durante uma campanha de anúncios'),
    ('seed_marketing_digital_dificil_v1', 'O que é LTV?', 1, 'Número de seguidores', 'Estimativa do número de clientes que uma empresa pode atrair para o site durante uma campanha'),
    ('seed_marketing_digital_dificil_v1', 'O que é LTV?', 3, 'Custo de uma campanha', 'Estimativa do retorno que um anúncio pode gerar para uma empresa durante o período de veiculação dele'),
    ('seed_marketing_digital_dificil_v1', 'Por que comparar LTV e CAC pode ser importante?', 0, 'Para escolher uma cor de logotipo', 'Para avaliar se o número de seguidores pode justificar o custo de produzir os conteúdos'),
    ('seed_marketing_digital_dificil_v1', 'Por que comparar LTV e CAC pode ser importante?', 1, 'Para calcular o número de seguidores', 'Para estimar se o tempo de carregamento do site pode justificar o custo de hospedar as páginas'),
    ('seed_marketing_digital_dificil_v1', 'Por que comparar LTV e CAC pode ser importante?', 2, 'Para medir o tamanho do site', 'Para decidir se o orçamento de mídia pode justificar o custo de contratar mais fornecedores'),
    ('seed_marketing_digital_dificil_v1', 'O que é retenção de clientes?', 0, 'Número de anúncios publicados', 'Capacidade de atrair novos visitantes ou seguidores para a empresa ao longo do tempo'),
    ('seed_marketing_digital_dificil_v1', 'O que é retenção de clientes?', 1, 'Número de visitantes únicos', 'Capacidade de aumentar o preço dos produtos ou serviços da empresa ao longo do tempo'),
    ('seed_marketing_digital_dificil_v1', 'O que é retenção de clientes?', 3, 'Quantidade de novos seguidores', 'Capacidade de reduzir os custos de anúncios ou campanhas da empresa ao longo do tempo'),
    ('seed_marketing_digital_dificil_v1', 'O que é churn?', 0, 'Taxa de cliques', 'Taxa ou ocorrência de visitantes que deixam de clicar ou abrir determinado anúncio em um período'),
    ('seed_marketing_digital_dificil_v1', 'O que é churn?', 1, 'Custo por impressão', 'Taxa ou ocorrência de clientes que passam a comprar ou renovar determinado serviço em um período'),
    ('seed_marketing_digital_dificil_v1', 'O que é churn?', 2, 'Taxa de abertura de email', 'Taxa ou ocorrência de pedidos que deixam de ser pagos ou entregues em determinado canal em um período'),
    ('seed_marketing_digital_dificil_v1', 'Por que churn elevado pode ser um problema?', 1, 'Porque sempre aumenta o lucro', 'Pode indicar facilidade em atrair clientes e reduzir o custo necessário para fidelizar os que entram'),
    ('seed_marketing_digital_dificil_v1', 'Por que churn elevado pode ser um problema?', 2, 'Porque reduz o custo de aquisição', 'Pode indicar dificuldade em atrair visitantes e aumentar o custo necessário para manter os anúncios no ar'),
    ('seed_marketing_digital_dificil_v1', 'Por que churn elevado pode ser um problema?', 3, 'Porque aumenta automaticamente o alcance', 'Pode indicar excesso de clientes e aumentar o custo necessário para atender os que ficam'),
    ('seed_marketing_digital_dificil_v1', 'O que é atribuição de marketing?', 0, 'Criação de logotipos', 'Processo de definir quais canais ou pontos de venda recebem verba por uma campanha segundo determinado orçamento'),
    ('seed_marketing_digital_dificil_v1', 'O que é atribuição de marketing?', 2, 'Gestão de servidores', 'Processo de medir quais anúncios ou páginas de destino recebem cliques por uma campanha segundo determinado período'),
    ('seed_marketing_digital_dificil_v1', 'O que é atribuição de marketing?', 3, 'Distribuição de salários', 'Processo de registrar quais vendedores ou parceiros recebem comissão por uma venda segundo determinado contrato'),
    ('seed_marketing_digital_dificil_v1', 'O que é jornada do cliente?', 0, 'Apenas uma campanha', 'Conjunto de canais e anúncios que uma empresa pode utilizar desde o planejamento da campanha até o resultado'),
    ('seed_marketing_digital_dificil_v1', 'O que é jornada do cliente?', 1, 'Apenas o momento da compra', 'Conjunto de métricas e relatórios que uma equipe pode consultar desde a veiculação do anúncio até o encerramento'),
    ('seed_marketing_digital_dificil_v1', 'O que é jornada do cliente?', 3, 'Apenas uma visita ao site', 'Conjunto de etapas e tarefas que uma equipe pode executar desde a contratação até a entrega do projeto'),
    ('seed_marketing_digital_dificil_v1', 'O que significa omnichannel?', 0, 'Uso de apenas uma rede social', 'Estratégia que busca concentrar um único canal de interação para proporcionar uma experiência mais simples'),
    ('seed_marketing_digital_dificil_v1', 'O que significa omnichannel?', 1, 'Uso exclusivo de anúncios pagos', 'Estratégia que busca ampliar diferentes canais de anúncios para proporcionar um alcance mais abrangente'),
    ('seed_marketing_digital_dificil_v1', 'O que significa omnichannel?', 2, 'Venda apenas presencial', 'Estratégia que busca separar diferentes canais de atendimento para proporcionar uma gestão mais independente'),
    ('seed_marketing_digital_dificil_v1', 'O que é personalização em marketing?', 1, 'Exclusão de clientes antigos', 'Padronização de conteúdos, ofertas ou campanhas com base em modelos aprovados pela empresa'),
    ('seed_marketing_digital_dificil_v1', 'O que é personalização em marketing?', 2, 'Envio da mesma mensagem para todos', 'Automatização de conteúdos, anúncios ou relatórios com base em regras definidas pela equipe'),
    ('seed_marketing_digital_dificil_v1', 'O que é personalização em marketing?', 3, 'Publicação aleatória', 'Segmentação de públicos, canais ou orçamentos com base em metas definidas pela empresa'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um risco de personalização mal aplicada?', 0, 'Garante sempre maior confiança', 'Pode gerar experiências mais relevantes, úteis ou aumentar o interesse dos usuários'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um risco de personalização mal aplicada?', 2, 'Impede qualquer segmentação', 'Pode gerar resultados mais rápidos, simples ou reduzir a necessidade de testes'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um risco de personalização mal aplicada?', 3, 'Elimina todos os custos', 'Pode gerar campanhas mais baratas, curtas ou eliminar a necessidade de dados'),
    ('seed_marketing_digital_dificil_v1', 'O que é automação de marketing?', 1, 'Criação de anúncios físicos', 'Uso de profissionais para executar determinadas tarefas de marketing com base em briefings ou prazos'),
    ('seed_marketing_digital_dificil_v1', 'O que é automação de marketing?', 2, 'Exclusão de leads', 'Uso de relatórios para acompanhar determinadas métricas de marketing com base em metas ou períodos'),
    ('seed_marketing_digital_dificil_v1', 'O que é automação de marketing?', 3, 'Trabalho exclusivamente manual', 'Uso de anúncios para divulgar determinados produtos de marketing com base em orçamentos ou públicos'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um exemplo de automação de marketing?', 0, 'Imprimir um cartaz', 'Enviar manualmente uma mensagem de email para cada contato de uma base, um por um'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um exemplo de automação de marketing?', 1, 'Entregar um folheto', 'Publicar manualmente uma sequência de posts após uma reunião específica da equipe de marketing'),
    ('seed_marketing_digital_dificil_v1', 'Qual é um exemplo de automação de marketing?', 2, 'Fazer uma chamada manual', 'Revisar manualmente uma sequência de anúncios após uma queda específica nos resultados'),
    ('seed_marketing_digital_dificil_v1', 'O que é remarketing baseado em comportamento?', 0, 'Criação de anúncios sem dados', 'Criação de campanhas genéricas para pessoas sem interações anteriores, ignorando regras e permissões aplicáveis'),
    ('seed_marketing_digital_dificil_v1', 'O que é remarketing baseado em comportamento?', 2, 'Exclusão de visitantes', 'Exclusão de campanhas antigas para pessoas com base em interações anteriores, dentro dos prazos e orçamentos aplicáveis'),
    ('seed_marketing_digital_dificil_v1', 'O que é remarketing baseado em comportamento?', 3, 'Envio da mesma campanha para todos', 'Envio de campanhas iguais para pessoas com base em listas compradas, dentro de planos e preços aplicáveis'),
    ('seed_marketing_digital_dificil_v1', 'O que é SEO técnico?', 1, 'Apenas design de logotipo', 'Parte do SEO relacionada a aspectos visuais do site que podem influenciar identidade, logotipo, cores e tipografia'),
    ('seed_marketing_digital_dificil_v1', 'O que é SEO técnico?', 2, 'Apenas publicidade paga', 'Parte do SEO relacionada a anúncios pagos do site que podem influenciar orçamento, lances, cliques e conversões'),
    ('seed_marketing_digital_dificil_v1', 'O que é SEO técnico?', 3, 'Apenas criação de textos', 'Parte do SEO relacionada a textos editoriais do site que podem influenciar leitura, estilo, tom e originalidade'),
    ('seed_marketing_digital_dificil_v1', 'Por que velocidade de carregamento pode influenciar uma estratégia digital?', 1, 'Sites lentos sempre aumentam vendas', 'Sites rápidos podem prejudicar a experiência do usuário e determinados resultados de segurança'),
    ('seed_marketing_digital_dificil_v1', 'Por que velocidade de carregamento pode influenciar uma estratégia digital?', 2, 'Velocidade nunca importa', 'Sites lentos podem melhorar a experiência do usuário e determinados resultados de desempenho'),
    ('seed_marketing_digital_dificil_v1', 'Por que velocidade de carregamento pode influenciar uma estratégia digital?', 3, 'Velocidade só importa em anúncios físicos', 'Sites simples podem substituir a experiência do usuário e determinados resultados de desempenho'),
    ('seed_marketing_digital_dificil_v1', 'O que é intenção de busca?', 0, 'Palavra-passe do usuário', 'Local ou dispositivo que o usuário utiliza para acessar ao realizar uma pesquisa'),
    ('seed_marketing_digital_dificil_v1', 'O que é intenção de busca?', 1, 'Localização do servidor', 'Termo ou frase que o usuário digita para localizar um resultado ao realizar uma pesquisa'),
    ('seed_marketing_digital_dificil_v1', 'O que é intenção de busca?', 3, 'Nome do navegador', 'Resultado ou página que o buscador apresenta para exibir ao realizar uma pesquisa'),
    ('seed_marketing_digital_dificil_v1', 'Por que compreender a intenção de busca é importante para SEO?', 1, 'Elimina todos os concorrentes', 'Permite escolher palavras mais populares do que aquilo que o usuário realmente digita'),
    ('seed_marketing_digital_dificil_v1', 'Por que compreender a intenção de busca é importante para SEO?', 2, 'Garante primeira posição', 'Permite comprar anúncios mais baratos do que aquilo que o concorrente realmente paga'),
    ('seed_marketing_digital_dificil_v1', 'Por que compreender a intenção de busca é importante para SEO?', 3, 'Impede alterações no algoritmo', 'Permite copiar conteúdo mais antigo do que aquilo que o buscador realmente indexa'),
    ('seed_marketing_digital_dificil_v1', 'O que é autoridade de domínio em SEO?', 0, 'Número de usuários registrados', 'Métrica oficial usada pelos principais mecanismos de busca para determinar a posição de um domínio nos resultados, divulgada publicamente'),
    ('seed_marketing_digital_dificil_v1', 'O que é autoridade de domínio em SEO?', 1, 'Valor do domínio', 'Conceito usado em algumas empresas para estimar o valor financeiro ou preço de venda de um domínio, não sendo uma métrica oficial dos registradores'),
    ('seed_marketing_digital_dificil_v1', 'O que é autoridade de domínio em SEO?', 3, 'Senha do administrador', 'Conceito usado em alguns servidores para estimar a velocidade ou capacidade de resposta de um domínio, não sendo uma métrica oficial dos provedores de hospedagem'),
    ('seed_marketing_digital_dificil_v1', 'O que são backlinks?', 0, 'Links que só funcionam offline', 'Links internos do mesmo site que levam para outras páginas ou seções'),
    ('seed_marketing_digital_dificil_v1', 'O que são backlinks?', 2, 'Links enviados exclusivamente por email', 'Links de anúncios pagos que levam para uma página ou domínio'),
    ('seed_marketing_digital_dificil_v1', 'O que são backlinks?', 3, 'Links dentro de um aplicativo bancário', 'Links de emails enviados que abrem uma página ou domínio'),
    ('seed_marketing_digital_dificil_v1', 'Por que backlinks relevantes podem ser importantes para SEO?', 0, 'Garantem automaticamente a primeira posição', 'Podem contribuir para sinais de velocidade e carregamento, dependendo do tamanho e formato das imagens'),
    ('seed_marketing_digital_dificil_v1', 'Por que backlinks relevantes podem ser importantes para SEO?', 1, 'Garantem milhões de visitas', 'Podem contribuir para sinais de segurança e privacidade, dependendo da criptografia e certificado dos sites'),
    ('seed_marketing_digital_dificil_v1', 'Por que backlinks relevantes podem ser importantes para SEO?', 2, 'Eliminam a necessidade de conteúdo', 'Podem contribuir para sinais de popularidade e alcance, dependendo da quantidade e frequência dos anúncios'),
    ('seed_marketing_digital_dificil_v1', 'O que é marketing baseado em dados?', 0, 'Marketing sem objetivos', 'Utilização de intuição e opinião para orientar decisões de marketing'),
    ('seed_marketing_digital_dificil_v1', 'O que é marketing baseado em dados?', 1, 'Marketing sem qualquer medição', 'Utilização de modelos e tendências para copiar decisões de marketing'),
    ('seed_marketing_digital_dificil_v1', 'O que é marketing baseado em dados?', 2, 'Marketing exclusivamente presencial', 'Utilização de bancos e planilhas para armazenar decisões de marketing'),
    ('seed_marketing_digital_dificil_v1', 'Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 1, 'Porque toda campanha deve evitar cliques', 'Porque cliques significam automaticamente conversões, receita ou retorno positivo em qualquer campanha'),
    ('seed_marketing_digital_dificil_v1', 'Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 2, 'Porque cliques reduzem automaticamente as vendas', 'Porque cliques reduzem normalmente impressões, alcance ou retorno de anúncios veiculados'),
    ('seed_marketing_digital_dificil_v1', 'Por que uma campanha com muitos cliques pode ainda ser considerada ruim?', 3, 'Porque cliques nunca têm valor', 'Porque cliques geram normalmente penalidades, bloqueios ou perda de seguidores nas redes'),
    ('seed_marketing_digital_dificil_v1', 'O que é otimização de conversão?', 0, 'Processo de eliminar visitantes', 'Processo de ampliar elementos da campanha ou orçamento para aumentar o número de usuários que visualizam um anúncio desejado'),
    ('seed_marketing_digital_dificil_v1', 'O que é otimização de conversão?', 2, 'Processo de aumentar somente seguidores', 'Processo de reduzir elementos da página ou conteúdo para diminuir a proporção de usuários que abandonam um site inicial'),
    ('seed_marketing_digital_dificil_v1', 'O que é otimização de conversão?', 3, 'Processo de reduzir todo o conteúdo', 'Processo de testar elementos da marca ou logotipo para aumentar a lembrança de usuários que reconhecem uma identidade visual'),
    ('seed_marketing_digital_dificil_v1', 'Qual é uma estratégia mais sustentável para crescimento digital?', 0, 'Copiar integralmente os concorrentes', 'Combinar conteúdo popular, imitação dos concorrentes, volume de postagens, anúncios constantes e promoções frequentes'),
    ('seed_marketing_digital_dificil_v1', 'Qual é uma estratégia mais sustentável para crescimento digital?', 1, 'Comprar seguidores falsos', 'Combinar seguidores comprados, promessas atraentes, preços baixos, anúncios agressivos e urgência nas ofertas'),
    ('seed_marketing_digital_dificil_v1', 'Qual é uma estratégia mais sustentável para crescimento digital?', 3, 'Prometer resultados garantidos', 'Combinar resultados rápidos, cópia de modelos, reaproveitamento de textos, cortes de custos e ofertas limitadas'),
    ('seed_marketing_digital_dificil_v2', 'O que é LTV no marketing?', 0, 'Número de visitantes', 'Estimativa do número de clientes que uma campanha pode atrair durante seu período de veiculação'),
    ('seed_marketing_digital_dificil_v2', 'O que é LTV no marketing?', 2, 'Quantidade de seguidores', 'Estimativa do retorno que um anúncio pode gerar durante seu período de exibição para a empresa'),
    ('seed_marketing_digital_dificil_v2', 'O que é LTV no marketing?', 3, 'Custo de um anúncio', 'Estimativa do tempo que um cliente pode levar durante seu processo de compra com a empresa')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital difícil lote 1: as 24 perguntas ativas do seed dificil_v1 (migration 039) e a 1.ª do dificil_v2 (migration 050): % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
