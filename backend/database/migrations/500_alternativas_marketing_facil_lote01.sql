-- Alternativas (BE-003, regularização) — Marketing Digital fácil lote 1: as 25 primeiras perguntas ativas (seed v1, 23, e seed v2#1 e #2).
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
    ('seed_marketing_digital_facil_v1', 'O que é marketing digital?', 1, 'Apenas publicidade na televisão', 'Uso de meios impressos e de rádio para divulgar produtos, serviços ou marcas locais'),
    ('seed_marketing_digital_facil_v1', 'O que é marketing digital?', 2, 'Apenas distribuição de panfletos', 'Conjunto de regras fiscais para a venda de produtos e serviços pela internet'),
    ('seed_marketing_digital_facil_v1', 'O que é marketing digital?', 3, 'Apenas vendas presenciais', 'Criação de sistemas internos para controlar o estoque e as vendas de uma empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é público-alvo?', 0, 'Todas as pessoas do mundo', 'Conjunto de empresas que competem no mesmo mercado e vendem produtos parecidos'),
    ('seed_marketing_digital_facil_v1', 'O que é público-alvo?', 1, 'Apenas concorrentes', 'Equipe interna que planeja e executa as campanhas e os anúncios da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é público-alvo?', 3, 'Apenas funcionários da empresa', 'Número total de pessoas que visitaram o site da empresa durante um período'),
    ('seed_marketing_digital_facil_v1', 'O que é uma marca?', 0, 'Um tipo de anúncio', 'Anúncio pago que apresenta uma empresa, produto ou serviço em um canal digital'),
    ('seed_marketing_digital_facil_v1', 'O que é uma marca?', 1, 'Apenas o preço de um produto', 'Valor cobrado por uma empresa pelo produto ou serviço que coloca no mercado'),
    ('seed_marketing_digital_facil_v1', 'O que é uma marca?', 3, 'Apenas um endereço de email', 'Registro oficial que autoriza uma empresa a vender produtos ou serviços ao público'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo digital?', 1, 'Apenas produtos físicos', 'Aparelho usado para guardar dados em computadores'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo digital?', 2, 'Apenas documentos impressos', 'Material impresso e distribuído em lojas e eventos'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo digital?', 3, 'Apenas anúncios de televisão', 'Propaganda transmitida na televisão e no rádio'),
    ('seed_marketing_digital_facil_v1', 'Qual destes é um exemplo de conteúdo digital?', 0, 'Outdoor físico', 'Cartaz colocado na entrada de uma loja'),
    ('seed_marketing_digital_facil_v1', 'Qual destes é um exemplo de conteúdo digital?', 2, 'Cartaz colocado numa parede', 'Folheto distribuído na rua durante um evento'),
    ('seed_marketing_digital_facil_v1', 'Qual destes é um exemplo de conteúdo digital?', 3, 'Folheto impresso', 'Anúncio impresso numa revista de moda'),
    ('seed_marketing_digital_facil_v1', 'O que é uma publicação nas redes sociais?', 0, 'Apenas uma venda', 'Venda realizada por meio de uma loja virtual'),
    ('seed_marketing_digital_facil_v1', 'O que é uma publicação nas redes sociais?', 1, 'Um contrato', 'Contrato assinado entre a marca e um parceiro'),
    ('seed_marketing_digital_facil_v1', 'O que é uma publicação nas redes sociais?', 2, 'Uma senha', 'Senha usada para acessar o perfil da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que significa engajamento nas redes sociais?', 0, 'Apenas número de anúncios', 'Quantidade de conteúdos publicados pela marca, como fotos, vídeos, stories ou transmissões ao vivo'),
    ('seed_marketing_digital_facil_v1', 'O que significa engajamento nas redes sociais?', 1, 'Apenas número de vendas', 'Número de vendas concluídas depois de um conteúdo, como compras, assinaturas, cadastros ou reservas'),
    ('seed_marketing_digital_facil_v1', 'O que significa engajamento nas redes sociais?', 3, 'Apenas número de seguidores', 'Total de pessoas que passaram a seguir o perfil da marca, como novos seguidores, inscritos ou assinantes do canal'),
    ('seed_marketing_digital_facil_v1', 'O que é alcance?', 0, 'Número de funcionários', 'Quantidade de pessoas ou contas que clicaram em determinado conteúdo'),
    ('seed_marketing_digital_facil_v1', 'O que é alcance?', 2, 'Valor gasto em publicidade', 'Valor total investido para divulgar determinado conteúdo em um período'),
    ('seed_marketing_digital_facil_v1', 'O que é alcance?', 3, 'Quantidade de produtos vendidos', 'Quantidade de produtos vendidos depois da publicação de determinado conteúdo'),
    ('seed_marketing_digital_facil_v1', 'O que são impressões?', 0, 'Número de pessoas que compraram', 'Número de pessoas que compraram depois de ver determinado conteúdo ou anúncio'),
    ('seed_marketing_digital_facil_v1', 'O que são impressões?', 1, 'Número de comentários obrigatórios', 'Número de comentários recebidos em determinado conteúdo ou anúncio'),
    ('seed_marketing_digital_facil_v1', 'O que são impressões?', 3, 'Número de seguidores perdidos', 'Número de seguidores perdidos depois de publicar determinado conteúdo'),
    ('seed_marketing_digital_facil_v1', 'O que é um anúncio digital?', 0, 'Contrato comercial', 'Contrato comercial assinado entre a empresa e clientes'),
    ('seed_marketing_digital_facil_v1', 'O que é um anúncio digital?', 2, 'Documento bancário', 'Documento bancário usado para registar vendas pela internet'),
    ('seed_marketing_digital_facil_v1', 'O que é um anúncio digital?', 3, 'Apenas um cartaz físico', 'Cartaz promocional colocado em lojas e espaços públicos'),
    ('seed_marketing_digital_facil_v1', 'O que é uma chamada para ação?', 1, 'Uma chamada telefônica', 'Ligação telefônica feita pela empresa para os clientes'),
    ('seed_marketing_digital_facil_v1', 'O que é uma chamada para ação?', 2, 'Um tipo de pagamento', 'Forma de pagamento aceita pela loja em compras online'),
    ('seed_marketing_digital_facil_v1', 'O que é uma chamada para ação?', 3, 'Uma mensagem de erro', 'Aviso exibido quando ocorre um problema no site ou no aplicativo'),
    ('seed_marketing_digital_facil_v1', 'O que é uma landing page?', 0, 'Página obrigatória de login', 'Página de entrada de um site que reúne todos os menus, links e informações da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é uma landing page?', 1, 'Página exclusivamente para notícias', 'Página usada para publicar notícias e artigos sobre o setor em que a empresa atua'),
    ('seed_marketing_digital_facil_v1', 'O que é uma landing page?', 2, 'Página sem qualquer objetivo', 'Página de acesso restrito onde clientes cadastrados fazem login'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 1, 'Apenas trânsito de carros', 'Fluxo de veículos que passam diante da loja física da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 2, 'Apenas número de funcionários', 'Número de funcionários da equipe de marketing digital'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 3, 'Apenas quantidade de produtos', 'Quantidade de produtos disponíveis para venda em uma loja virtual'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego orgânico?', 0, 'Visitas geradas por bots', 'Visitas geradas por programas automáticos que simulam o acesso de pessoas'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego orgânico?', 1, 'Visitas feitas apenas por funcionários', 'Visitas feitas pelos próprios funcionários da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego orgânico?', 2, 'Visitas compradas obrigatoriamente', 'Visitas obtidas por meio de anúncios pagos em redes sociais e buscadores'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego pago?', 1, 'Visitas sem internet', 'Visitas obtidas por meio de pesquisas feitas em buscadores sem anúncios'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego pago?', 2, 'Visitas de funcionários', 'Visitas feitas por clientes que já compraram produtos da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego pago?', 3, 'Visitas exclusivamente gratuitas', 'Visitas vindas de indicações espontâneas de amigos'),
    ('seed_marketing_digital_facil_v1', 'O que é SEO?', 0, 'Plataforma de mensagens', 'Conjunto de ferramentas para enviar mensagens automáticas a clientes por aplicativos de conversa e e-mail'),
    ('seed_marketing_digital_facil_v1', 'O que é SEO?', 1, 'Sistema de pagamento', 'Sistema usado para processar pagamentos e registrar as vendas feitas em lojas virtuais e aplicativos'),
    ('seed_marketing_digital_facil_v1', 'O que é SEO?', 3, 'Tipo de banco de dados', 'Tipo de banco de dados usado para armazenar informações de clientes e de produtos de uma loja'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 0, 'Criar uma conta automaticamente', 'Ajudar a criar uma conta automaticamente para cada visitante que acessa o site da empresa'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 2, 'Servir como senha bancária', 'Ajudar a proteger o acesso ao painel de anúncios com uma senha difícil de adivinhar'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 3, 'Substituir o domínio', 'Ajudar a substituir o endereço do site por um nome mais curto e fácil de lembrar'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 0, 'Sistema de pagamentos', 'Sistema usado para registar pagamentos e faturas dos clientes'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 1, 'Envio de mensagens exclusivamente pessoais', 'Troca de mensagens pessoais entre os funcionários de uma mesma empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 2, 'Serviço de armazenamento', 'Serviço usado para guardar arquivos e documentos da empresa na internet'),
    ('seed_marketing_digital_facil_v1', 'O que é uma lista de contatos?', 0, 'Lista de senhas', 'Conjunto de senhas e códigos de acesso da equipe'),
    ('seed_marketing_digital_facil_v1', 'O que é uma lista de contatos?', 1, 'Lista de funcionários públicos', 'Relação de órgãos públicos que a empresa precisa informar sobre suas vendas'),
    ('seed_marketing_digital_facil_v1', 'O que é uma lista de contatos?', 3, 'Lista de produtos físicos', 'Catálogo de produtos físicos disponíveis para venda no estoque da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo educativo no marketing?', 1, 'Apenas anúncios pagos', 'Conteúdo criado para anunciar descontos e promoções por tempo limitado aos clientes'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo educativo no marketing?', 2, 'Conteúdo sem finalidade', 'Conteúdo copiado de outros sites para preencher as páginas da empresa'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo educativo no marketing?', 3, 'Conteúdo exclusivamente promocional', 'Conteúdo feito para entreter o público sem relação com o negócio da marca'),
    ('seed_marketing_digital_facil_v1', 'Qual pode ser uma vantagem de produzir conteúdo educativo?', 0, 'Eliminar concorrentes', 'Dispensar o investimento em anúncios e outras ações de divulgação'),
    ('seed_marketing_digital_facil_v1', 'Qual pode ser uma vantagem de produzir conteúdo educativo?', 2, 'Garantir milhões de visualizações', 'Aumentar de imediato o número de seguidores e de visualizações'),
    ('seed_marketing_digital_facil_v1', 'Qual pode ser uma vantagem de produzir conteúdo educativo?', 3, 'Garantir vendas imediatas', 'Substituir o atendimento aos clientes por conteúdos publicados'),
    ('seed_marketing_digital_facil_v1', 'O que é consistência no marketing de conteúdo?', 1, 'Alterar a marca diariamente', 'Mudar o estilo e a identidade visual da marca a cada nova publicação ou campanha'),
    ('seed_marketing_digital_facil_v1', 'O que é consistência no marketing de conteúdo?', 2, 'Publicar apenas uma vez', 'Publicar muitos conteúdos em um único dia e deixar o perfil parado nas semanas seguintes'),
    ('seed_marketing_digital_facil_v1', 'O que é consistência no marketing de conteúdo?', 3, 'Copiar todos os concorrentes', 'Repetir o mesmo conteúdo em todas as redes sem adaptar o formato ao público'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma imagem em uma publicação?', 0, 'Para substituir obrigatoriamente todo o texto', 'Pode ajudar a reduzir o custo do anúncio e a dispensar o texto'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma imagem em uma publicação?', 1, 'Apenas para aumentar o preço do produto', 'Pode ajudar a aumentar o preço do produto e a valorizar a marca perante o público'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma imagem em uma publicação?', 3, 'Para esconder informações', 'Pode ajudar a esconder informações importantes e a deixar a publicação mais curta'),
    ('seed_marketing_digital_facil_v2', 'O que é um seguidor?', 0, 'Cliente que sempre compra', 'Cliente que já comprou da empresa e voltou a comprar mais de uma vez'),
    ('seed_marketing_digital_facil_v2', 'O que é um seguidor?', 2, 'Funcionário obrigatório da empresa', 'Funcionário contratado pela empresa para gerir as redes sociais'),
    ('seed_marketing_digital_facil_v2', 'O que é um seguidor?', 3, 'Administrador da internet', 'Pessoa ou conta que administra determinado perfil ou página')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital fácil lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
