-- Alternativas (BE-003, regularização) — Marketing Digital médio lote 1: 25 primeiras perguntas ativas do seed médio v1 (v1#2 a v1#26).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital fácil/médio usa a faixa de migrations 500 a 519
-- (o difícil usa 520 a 527), para não colidir com as outras sessões.
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
    ('seed_marketing_digital_medio_v1', 'Por que criar uma persona pode ajudar no marketing?', 0, 'Garante vendas', 'Pode substituir a pesquisa de mercado e a análise dos resultados das campanhas'),
    ('seed_marketing_digital_medio_v1', 'Por que criar uma persona pode ajudar no marketing?', 2, 'Elimina todos os concorrentes', 'Pode aumentar o preço dos produtos e reduzir a necessidade de anúncios pagos'),
    ('seed_marketing_digital_medio_v1', 'Por que criar uma persona pode ajudar no marketing?', 3, 'Impede alterações na estratégia', 'Pode dispensar a segmentação do público e o uso de diferentes canais de divulgação'),
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 0, 'Sistema de pagamento', 'Sistema que registra os pagamentos feitos pelos clientes em cada etapa da compra'),
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 1, 'Banco de dados', 'Banco de dados que armazena o histórico de contatos e compras dos clientes'),
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 2, 'Ferramenta de edição de vídeo', 'Ferramenta de edição usada para cortar vídeos e ajustar imagens antes de publicar nas redes sociais'),
    ('seed_marketing_digital_medio_v1', 'Qual pode ser uma etapa inicial de um funil?', 0, 'Cancelamento', 'Fidelização ou recompra do cliente'),
    ('seed_marketing_digital_medio_v1', 'Qual pode ser uma etapa inicial de um funil?', 1, 'Pós-venda obrigatório', 'Decisão ou negociação da compra'),
    ('seed_marketing_digital_medio_v1', 'Qual pode ser uma etapa inicial de um funil?', 2, 'Reembolso', 'Retenção ou recompra'),
    ('seed_marketing_digital_medio_v1', 'O que é conversão?', 0, 'Apenas uma curtida', 'Contagem de pessoas que viram o anúncio durante o período da campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é conversão?', 1, 'Apenas uma impressão', 'Registro das visitas feitas à página durante o período da campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é conversão?', 2, 'Apenas uma visita', 'Interação do público com a publicação por meio de curtidas ou comentários'),
    ('seed_marketing_digital_medio_v1', 'Qual destas pode ser uma conversão?', 0, 'Apenas ligar o telefone', 'Visualizar um anúncio'),
    ('seed_marketing_digital_medio_v1', 'Qual destas pode ser uma conversão?', 1, 'Apenas abrir o navegador', 'Abrir o navegador'),
    ('seed_marketing_digital_medio_v1', 'Qual destas pode ser uma conversão?', 2, 'Apenas visualizar um anúncio', 'Receber uma notificação'),
    ('seed_marketing_digital_medio_v1', 'O que é taxa de conversão?', 0, 'Número de anúncios publicados', 'Percentual de usuários que visualizam o anúncio em relação ao total de pessoas alcançadas'),
    ('seed_marketing_digital_medio_v1', 'O que é taxa de conversão?', 1, 'Número total de seguidores', 'Número total de usuários que realizam determinada ação durante o período da campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é taxa de conversão?', 2, 'Valor total das vendas', 'Valor médio gasto por usuário em relação ao total investido na campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CTR?', 1, 'Taxa de lucro anual', 'Taxa de conversões em relação às visitas recebidas por determinada página ou campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CTR?', 2, 'Número de seguidores', 'Taxa de compartilhamentos em relação ao alcance de determinada publicação'),
    ('seed_marketing_digital_medio_v1', 'O que é CTR?', 3, 'Custo de produção', 'Taxa de lucro em relação ao investimento em determinado anúncio ou canal'),
    ('seed_marketing_digital_medio_v1', 'Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 1, 'Apenas o número de seguidores', 'Número de seguidores, nome da empresa, tamanho do logotipo e cor do anúncio'),
    ('seed_marketing_digital_medio_v1', 'Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 2, 'Apenas o nome da empresa', 'Horário de funcionamento da loja, preço do frete e forma de pagamento aceita'),
    ('seed_marketing_digital_medio_v1', 'Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 3, 'Apenas o tamanho do logotipo', 'Quantidade de anúncios publicados, número de anunciantes e custo do equipamento'),
    ('seed_marketing_digital_medio_v1', 'O que é CPC?', 0, 'Conversão por campanha', 'Conversão por campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CPC?', 1, 'Conteúdo por canal', 'Custo por canal'),
    ('seed_marketing_digital_medio_v1', 'O que é CPC?', 2, 'Custo por cliente anual', 'Custo por cliente anual'),
    ('seed_marketing_digital_medio_v1', 'O que é CPM?', 0, 'Custo por mensagem', 'Custo por mensagem enviada'),
    ('seed_marketing_digital_medio_v1', 'O que é CPM?', 1, 'Conversão por mês', 'Conversão por mês de campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CPM?', 3, 'Custo por produto', 'Custo por produto'),
    ('seed_marketing_digital_medio_v1', 'O que é CPA?', 1, 'Custo por audiência', 'Custo por audiência ou alcance, conforme o público definido na campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CPA?', 2, 'Conversão por aplicativo', 'Conversão por aplicativo ou site, conforme a plataforma usada na campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é CPA?', 3, 'Custo por anúncio', 'Custo por anúncio ou criativo, conforme o formato definido na campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é ROI em marketing?', 1, 'Número de seguidores', 'Relação entre o número de seguidores e o de publicações feitas'),
    ('seed_marketing_digital_medio_v1', 'O que é ROI em marketing?', 2, 'Quantidade de comentários', 'Relação entre o preço e o custo de produção'),
    ('seed_marketing_digital_medio_v1', 'O que é ROI em marketing?', 3, 'Número de publicações', 'Relação entre o número de comentários e o de curtidas recebidas'),
    ('seed_marketing_digital_medio_v1', 'O que é segmentação de público?', 0, 'Exclusão de todos os clientes', 'Exclusão dos clientes que não compram para reduzir o custo da campanha'),
    ('seed_marketing_digital_medio_v1', 'O que é segmentação de público?', 1, 'Criação de uma única mensagem para qualquer pessoa', 'Criação de uma única mensagem adaptada a qualquer pessoa do público'),
    ('seed_marketing_digital_medio_v1', 'O que é segmentação de público?', 3, 'Publicação sem estratégia', 'Publicação de conteúdos variados sem seguir uma estratégia definida'),
    ('seed_marketing_digital_medio_v1', 'Por que segmentar campanhas?', 1, 'Para garantir conversão de 100%', 'Para tentar obter conversão em todas as visitas recebidas pela página'),
    ('seed_marketing_digital_medio_v1', 'Por que segmentar campanhas?', 2, 'Para eliminar todos os anúncios', 'Para tentar reduzir o número de anúncios exibidos a cada pessoa'),
    ('seed_marketing_digital_medio_v1', 'Por que segmentar campanhas?', 3, 'Para impedir qualquer alcance', 'Para tentar impedir que o público compare preços com os concorrentes'),
    ('seed_marketing_digital_medio_v1', 'O que é remarketing?', 1, 'Criação de um novo produto', 'Estratégia de criar um produto novo a partir das sugestões enviadas pelos clientes da marca'),
    ('seed_marketing_digital_medio_v1', 'O que é remarketing?', 2, 'Estratégia de eliminar antigos clientes', 'Estratégia de reduzir o preço de ofertas antigas para atrair pessoas que nunca viram a marca'),
    ('seed_marketing_digital_medio_v1', 'O que é remarketing?', 3, 'Publicação sem segmentação', 'Estratégia de publicar o mesmo conteúdo em canais diferentes sem escolher o público de cada um deles'),
    ('seed_marketing_digital_medio_v1', 'O que é teste A/B?', 0, 'Teste de velocidade da internet', 'Verificação da velocidade de carregamento de duas páginas para escolher o melhor servidor'),
    ('seed_marketing_digital_medio_v1', 'O que é teste A/B?', 1, 'Teste de bateria', 'Comparação de dois anúncios diferentes para escolher o que tem o menor custo de produção'),
    ('seed_marketing_digital_medio_v1', 'O que é teste A/B?', 2, 'Teste de segurança física', 'Análise de duas campanhas encerradas para decidir qual delas deve ser repetida no ano seguinte, sem medir resultados'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de teste A/B?', 1, 'Publicar o mesmo conteúdo sem medir resultados', 'Publicar o mesmo conteúdo sem medir resultados'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de teste A/B?', 2, 'Apagar uma campanha', 'Pausar uma campanha para economizar o orçamento'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de teste A/B?', 3, 'Alterar o computador', 'Trocar o computador usado pela equipe de anúncios'),
    ('seed_marketing_digital_medio_v1', 'O que é copywriting?', 0, 'Técnica de criação de bancos de dados', 'Técnica de organizar dados de clientes com objetivo de armazenar, filtrar ou proteger informações'),
    ('seed_marketing_digital_medio_v1', 'O que é copywriting?', 1, 'Técnica de programação', 'Técnica de programar sites com objetivo de carregar páginas, organizar menus ou guardar dados'),
    ('seed_marketing_digital_medio_v1', 'O que é copywriting?', 3, 'Técnica de edição de áudio', 'Técnica de editar áudios com objetivo de remover ruídos, ajustar volume ou melhorar a qualidade'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 0, 'Contrato de publicidade', 'Contrato assinado entre a empresa e os anunciantes para divulgar e vender uma solução ao público'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 2, 'Documento bancário', 'Documento emitido por um banco para comprovar o pagamento de uma solução'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 3, 'Algoritmo de pesquisa', 'Algoritmo usado pelos buscadores para ordenar os resultados de uma pesquisa'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de prova social?', 0, 'Código-fonte', 'Anúncio pago da própria marca'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de prova social?', 1, 'Senha de administrador', 'Descrição técnica do produto'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de prova social?', 3, 'Endereço IP', 'Tabela de preços da loja'),
    ('seed_marketing_digital_medio_v1', 'O que é autoridade de marca?', 0, 'Número de funcionários', 'Número de funcionários, filiais ou unidades de uma marca em determinada região'),
    ('seed_marketing_digital_medio_v1', 'O que é autoridade de marca?', 2, 'Valor do aluguel', 'Valor do aluguel, dos impostos ou das taxas pagas por uma marca em determinado mês'),
    ('seed_marketing_digital_medio_v1', 'O que é autoridade de marca?', 3, 'Quantidade de computadores', 'Quantidade de computadores, telas ou equipamentos usados por uma marca em determinado setor'),
    ('seed_marketing_digital_medio_v1', 'O que é marketing de influência?', 0, 'Marketing apenas presencial', 'Estratégia que utiliza anúncios impressos e cartazes para divulgar uma marca, produto ou serviço'),
    ('seed_marketing_digital_medio_v1', 'O que é marketing de influência?', 2, 'Marketing exclusivamente por email', 'Estratégia que utiliza mensagens enviadas por e-mail para comunicar uma marca, produto ou serviço'),
    ('seed_marketing_digital_medio_v1', 'O que é marketing de influência?', 3, 'Marketing sem conteúdo', 'Estratégia que utiliza conteúdos sem objetivo definido para divulgar uma marca, produto ou serviço'),
    ('seed_marketing_digital_medio_v1', 'O que é conteúdo viral?', 0, 'Conteúdo privado', 'Conteúdo que fica restrito a poucas pessoas por meio de convites, listas fechadas e grupos privados'),
    ('seed_marketing_digital_medio_v1', 'O que é conteúdo viral?', 1, 'Conteúdo que obrigatoriamente gera vendas', 'Conteúdo que gera vendas imediatas por meio de anúncios pagos, ofertas limitadas e descontos exclusivos'),
    ('seed_marketing_digital_medio_v1', 'O que é conteúdo viral?', 3, 'Conteúdo publicado apenas uma vez', 'Conteúdo que é publicado uma única vez em um canal e depois removido da internet por completo, sem chegar a novos públicos'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 0, 'Sim, quando tem mais de 100 visualizações', 'Sim, quando alcança muitas visualizações e curtidas'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 2, 'Sim, automaticamente', 'Sim'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 3, 'Sim, sempre', 'Sim, se for compartilhado em vários canais')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital médio lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
