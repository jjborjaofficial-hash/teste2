-- Alternativas (BE-003, regularização) — Marketing Digital fácil lote 2: 25 perguntas ativas seguintes (seed v2#3 a v2#26 e v3#1).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital usa a faixa de migrations 500+
-- (Finanças 144+, Produtividade 200+, Tecnologia 300+, IA 400+), para não colidir com as outras sessões.
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
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 0, 'Publicar apenas quando houver reclamações', 'Publicar conteúdos conforme a vontade de cada dia'),
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 1, 'Nunca publicar', 'Publicar em dias e horas ao acaso'),
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 3, 'Publicar tudo em um único dia', 'Publicar muitos conteúdos de uma vez e depois parar'),
    ('seed_marketing_digital_facil_v2', 'O que é uma hashtag?', 1, 'Um endereço residencial', 'Palavra ou expressão precedida pelo símbolo @ usada para marcar uma pessoa ou página'),
    ('seed_marketing_digital_facil_v2', 'O que é uma hashtag?', 2, 'Uma senha bancária', 'Sequência de números usada para identificar uma conta em uma plataforma social'),
    ('seed_marketing_digital_facil_v2', 'O que é uma hashtag?', 3, 'Um tipo de pagamento', 'Frase curta colocada no fim da publicação para pedir uma ação ao público'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 1, 'Guardar dinheiro', 'Armazenar os dados bancários da empresa para pagar anúncios e fornecedores'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 2, 'Substituir um banco', 'Registar oficialmente a empresa junto das autoridades e dos órgãos públicos'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 3, 'Criar documentos oficiais automaticamente', 'Controlar o estoque e o pagamento dos funcionários da equipe de vendas'),
    ('seed_marketing_digital_facil_v2', 'O que significa interação nas redes sociais?', 1, 'Pagamento de impostos', 'Valores pagos para promover publicações numa plataforma'),
    ('seed_marketing_digital_facil_v2', 'O que significa interação nas redes sociais?', 2, 'Apenas visualização de um computador', 'Número de pessoas que visualizaram o perfil de uma marca'),
    ('seed_marketing_digital_facil_v2', 'O que significa interação nas redes sociais?', 3, 'Criação de contas bancárias', 'Criação de contas novas para marcas, produtos e perfis'),
    ('seed_marketing_digital_facil_v2', 'O que é um comentário?', 0, 'Um tipo de investimento', 'Um tipo de anúncio pago exibido ao lado do conteúdo'),
    ('seed_marketing_digital_facil_v2', 'O que é um comentário?', 1, 'Um contrato', 'Uma mensagem privada enviada ao autor da publicação'),
    ('seed_marketing_digital_facil_v2', 'O que é um comentário?', 2, 'Um anúncio obrigatório', 'Uma etiqueta usada para agrupar conteúdos sobre o mesmo tema'),
    ('seed_marketing_digital_facil_v2', 'O que significa compartilhar uma publicação?', 1, 'Bloquear o autor', 'Impedir que o autor veja e responda às mensagens da publicação'),
    ('seed_marketing_digital_facil_v2', 'O que significa compartilhar uma publicação?', 2, 'Apagar a publicação', 'Remover a publicação da página para que ninguém mais a veja'),
    ('seed_marketing_digital_facil_v2', 'O que significa compartilhar uma publicação?', 3, 'Alterar o preço do produto', 'Alterar o texto da publicação depois de ela já ter sido publicada'),
    ('seed_marketing_digital_facil_v2', 'O que é um produto digital?', 0, 'Apenas dinheiro eletrônico', 'Moeda usada para pagar compras feitas pela internet'),
    ('seed_marketing_digital_facil_v2', 'O que é um produto digital?', 2, 'Produto necessariamente feito de metal', 'Produto feito de metal e usado em equipamentos eletrônicos'),
    ('seed_marketing_digital_facil_v2', 'O que é um produto digital?', 3, 'Apenas produto vendido em loja física', 'Produto vendido em lojas físicas e entregue em mão'),
    ('seed_marketing_digital_facil_v2', 'O que significa vender pela internet?', 0, 'Vender somente em mercados físicos', 'Vender em mercados e feiras físicas, sem usar a internet para divulgar'),
    ('seed_marketing_digital_facil_v2', 'O que significa vender pela internet?', 1, 'Não utilizar comunicação digital', 'Usar a comunicação digital para atender reclamações dos clientes'),
    ('seed_marketing_digital_facil_v2', 'O que significa vender pela internet?', 3, 'Fazer pagamentos apenas em dinheiro físico', 'Receber os pagamentos em dinheiro físico, durante a entrega do produto'),
    ('seed_marketing_digital_facil_v2', 'O que é uma oferta?', 0, 'Um imposto', 'Imposto cobrado sobre a venda de um produto ou serviço'),
    ('seed_marketing_digital_facil_v2', 'O que é uma oferta?', 2, 'Uma senha', 'Senha enviada ao consumidor para acessar um produto ou serviço'),
    ('seed_marketing_digital_facil_v2', 'O que é uma oferta?', 3, 'Apenas uma reclamação', 'Reclamação feita pelo consumidor sobre um produto ou serviço'),
    ('seed_marketing_digital_facil_v2', 'O que é desconto?', 0, 'Uma multa', 'Taxa extra cobrada sobre um preço ou valor'),
    ('seed_marketing_digital_facil_v2', 'O que é desconto?', 1, 'Aumento obrigatório do preço', 'Aumento aplicado sobre um preço ou valor'),
    ('seed_marketing_digital_facil_v2', 'O que é desconto?', 3, 'Um empréstimo', 'Parcelamento aplicado sobre um preço ou valor'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 0, 'Código secreto', 'Código interno que identifica o produto no estoque e na loja virtual'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 2, 'Senha de acesso', 'Senha de acesso usada pela equipe para editar a página do produto'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 3, 'Documento bancário', 'Documento bancário que comprova o pagamento do produto pelo cliente na loja online'),
    ('seed_marketing_digital_facil_v2', 'Por que uma descrição clara pode ajudar nas vendas?', 0, 'Porque garante venda automática', 'Porque faz o produto aparecer automaticamente nos primeiros resultados'),
    ('seed_marketing_digital_facil_v2', 'Por que uma descrição clara pode ajudar nas vendas?', 1, 'Porque elimina concorrentes', 'Porque reduz o preço do produto para o cliente que leia o texto'),
    ('seed_marketing_digital_facil_v2', 'Por que uma descrição clara pode ajudar nas vendas?', 2, 'Porque torna o produto gratuito', 'Porque dispensa o contato entre o cliente e a equipe de atendimento'),
    ('seed_marketing_digital_facil_v2', 'O que é uma audiência digital?', 0, 'Somente concorrentes', 'Conjunto de empresas que competem pelo mesmo público em determinado setor, mercado ou tema'),
    ('seed_marketing_digital_facil_v2', 'O que é uma audiência digital?', 2, 'Apenas funcionários', 'Conjunto de funcionários que trabalham com marketing em determinada empresa'),
    ('seed_marketing_digital_facil_v2', 'O que é uma audiência digital?', 3, 'Apenas investidores', 'Conjunto de investidores que financiam campanhas em determinada marca ou tema'),
    ('seed_marketing_digital_facil_v2', 'O que significa criar conteúdo?', 0, 'Apenas comprar anúncios', 'Comprar espaços de anúncio em sites, redes sociais e outros canais para divulgar a marca'),
    ('seed_marketing_digital_facil_v2', 'O que significa criar conteúdo?', 2, 'Apenas vender produtos', 'Vender produtos em lojas físicas e virtuais, com atendimento direto aos clientes interessados'),
    ('seed_marketing_digital_facil_v2', 'O que significa criar conteúdo?', 3, 'Criar uma conta bancária', 'Abrir contas em plataformas digitais e configurar os dados da empresa para receber pagamentos e mensagens'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma chamada para ação, conhecida como CTA?', 0, 'Diminuir o alcance', 'Reduzir o alcance das publicações da marca'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma chamada para ação, conhecida como CTA?', 1, 'Esconder informações', 'Esconder as informações do perfil da empresa'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma chamada para ação, conhecida como CTA?', 2, 'Apagar comentários', 'Apagar os comentários feitos pelo público'),
    ('seed_marketing_digital_facil_v2', 'O que é conteúdo relevante?', 1, 'Qualquer publicação aleatória', 'Conteúdo publicado com muita frequência, sobre qualquer assunto'),
    ('seed_marketing_digital_facil_v2', 'O que é conteúdo relevante?', 2, 'Conteúdo sem objetivo', 'Conteúdo igual ao que os concorrentes publicam nas redes'),
    ('seed_marketing_digital_facil_v2', 'O que é conteúdo relevante?', 3, 'Apenas publicidade', 'Conteúdo que fala da empresa e dos seus produtos'),
    ('seed_marketing_digital_facil_v2', 'Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 0, 'Salário', 'Cliques'),
    ('seed_marketing_digital_facil_v2', 'Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 1, 'Margem', 'Seguidores'),
    ('seed_marketing_digital_facil_v2', 'Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 2, 'Estoque', 'Margem de lucro'),
    ('seed_marketing_digital_facil_v2', 'Por que testar diferentes anúncios pode ser útil?', 1, 'Para impedir vendas', 'Para impedir que o público veja anúncios rivais'),
    ('seed_marketing_digital_facil_v2', 'Por que testar diferentes anúncios pode ser útil?', 2, 'Para eliminar métricas', 'Para eliminar os dados que mostram os resultados da campanha'),
    ('seed_marketing_digital_facil_v2', 'Por que testar diferentes anúncios pode ser útil?', 3, 'Para aumentar custos sem análise', 'Para aumentar os custos da campanha sem precisar de análise'),
    ('seed_marketing_digital_facil_v2', 'O que significa alcance?', 0, 'Valor de uma campanha', 'Valor total investido em uma campanha de anúncios pagos'),
    ('seed_marketing_digital_facil_v2', 'O que significa alcance?', 1, 'Número de funcionários', 'Número de funcionários envolvidos na criação do conteúdo'),
    ('seed_marketing_digital_facil_v2', 'O que significa alcance?', 2, 'Quantidade de dinheiro recebido', 'Quantidade de dinheiro recebido com as vendas depois do conteúdo'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma característica de um bom título?', 0, 'Deve esconder o tema', 'Deve esconder o tema para criar mistério em volta do conteúdo'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma característica de um bom título?', 1, 'Deve ser sempre enorme', 'Deve ser muito longo, para explicar todo o conteúdo no título'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma característica de um bom título?', 3, 'Não deve ter relação com o conteúdo', 'Deve repetir o título de outros conteúdos'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma vantagem de analisar dados de uma campanha?', 0, 'Garante vendas', 'Permite copiar a campanha dos concorrentes'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma vantagem de analisar dados de uma campanha?', 1, 'Impede alterações', 'Permite alterar os resultados depois de a campanha terminar'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma vantagem de analisar dados de uma campanha?', 2, 'Elimina a necessidade de planejamento', 'Permite dispensar o planejamento das campanhas seguintes'),
    ('seed_marketing_digital_facil_v2', 'Por que conhecer a persona é importante?', 0, 'Elimina concorrentes', 'Ajuda a reduzir o número de seguidores da marca'),
    ('seed_marketing_digital_facil_v2', 'Por que conhecer a persona é importante?', 2, 'Garante lucro', 'Ajuda a definir o preço dos produtos'),
    ('seed_marketing_digital_facil_v2', 'Por que conhecer a persona é importante?', 3, 'Evita criação de conteúdo', 'Ajuda a escolher o nome da empresa e o local da loja'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 0, 'Criar apenas imagens', 'Criar imagens bonitas para publicar nas redes sociais'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 1, 'Desligar anúncios online', 'Desligar os anúncios online para reduzir os custos'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 3, 'Substituir todos os vendedores', 'Substituir os vendedores por atendimento automático')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital fácil lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
