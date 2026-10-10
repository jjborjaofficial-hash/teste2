-- Explicações pedagógicas (BE-004) — Marketing Digital fácil lote 3: 25 perguntas ativas seguintes (seed v3#2 a v3#27, saltando a v3#20 desativada).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md). Só atualiza perguntas que ainda NÃO têm explicação, então é idempotente e
-- nunca sobrescreve texto já escrito. Não altera perguntas nem alternativas. Se alguma pergunta já não existir,
-- é simplesmente ignorada (nunca falha, para não impedir o arranque do backend: as migrations correm no deploy).
-- O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_marketing_digital_facil_v3', 'Qual destes é um canal de Marketing Digital?', 'As redes sociais são um dos principais canais do Marketing Digital, porque permitem falar com o público pela internet. Cartazes, panfletos e rádio são canais tradicionais, fora do ambiente digital.'),
    ('seed_marketing_digital_facil_v3', 'Qual destas plataformas é usada para Marketing Digital?', 'O Instagram é uma plataforma de rede social muito usada para divulgar marcas, produtos e conteúdos. Bloco de notas, calculadora e BIOS são ferramentas do computador, sem relação com divulgação ao público.'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 'Conteúdo é todo material criado para informar, atrair ou envolver o público, como textos, vídeos, imagens e áudios. É ele que dá à pessoa um motivo para acompanhar a marca.'),
    ('seed_marketing_digital_facil_v3', 'O que significa público-alvo?', 'Público-alvo é o grupo de pessoas que a empresa quer alcançar, porque tem mais chance de se interessar pelo que ela oferece. Conhecê-lo ajuda a escolher a mensagem e o canal certos.'),
    ('seed_marketing_digital_facil_v3', 'O que é anúncio online?', 'Anúncio online é a divulgação paga de produtos ou serviços na internet, por exemplo nas redes sociais ou nos buscadores. A empresa paga para o anúncio ser mostrado a mais pessoas.'),
    ('seed_marketing_digital_facil_v3', 'O que é uma campanha digital?', 'Uma campanha digital reúne ações planejadas para alcançar um objetivo, como divulgar um produto ou conseguir novos clientes. Tem começo, meio e fim, e os resultados podem ser medidos.'),
    ('seed_marketing_digital_facil_v3', 'O que significa a sigla SEO?', 'SEO vem do inglês Search Engine Optimization, que significa otimização para mecanismos de busca. São as técnicas para um site aparecer melhor colocado nos resultados de pesquisa, como no Google.'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 'O Google é um mecanismo de pesquisa online: a pessoa escreve o que procura e ele mostra páginas relacionadas. Por isso é tão importante para as marcas aparecerem bem nos seus resultados.'),
    ('seed_marketing_digital_facil_v3', 'O que é uma página de vendas?', 'A página de vendas é criada para apresentar um produto ou serviço e levar a pessoa a comprar. Costuma ter descrição, benefícios, preço e um botão de compra.'),
    ('seed_marketing_digital_facil_v3', 'O que é um cliente?', 'Cliente é a pessoa que compra ou utiliza um produto ou serviço. Todo o trabalho de marketing existe para conquistar clientes e mantê-los satisfeitos.'),
    ('seed_marketing_digital_facil_v3', 'O que é venda online?', 'Venda online é a comercialização de produtos ou serviços pela internet, em lojas virtuais, redes sociais ou aplicativos. O cliente escolhe e compra sem sair de casa.'),
    ('seed_marketing_digital_facil_v3', 'O que é promoção?', 'Promoção é uma estratégia para aumentar o interesse num produto ou serviço, por exemplo com descontos, brindes ou ofertas por tempo limitado. O objetivo é motivar a compra.'),
    ('seed_marketing_digital_facil_v3', 'O que é engajamento?', 'Engajamento é o nível de interação das pessoas com um conteúdo ou marca: curtidas, comentários, compartilhamentos e respostas. Quanto maior, mais o conteúdo interessa ao público.'),
    ('seed_marketing_digital_facil_v3', 'O que é curtida em uma rede social?', 'A curtida é uma forma simples de interação: a pessoa mostra que gostou de um conteúdo com um toque. Não é compra, senha nem arquivo.'),
    ('seed_marketing_digital_facil_v3', 'O que é influenciador digital?', 'Influenciador digital é uma pessoa que tem influência sobre uma audiência online, e por isso suas recomendações podem levar os seguidores a conhecer ou comprar algo.'),
    ('seed_marketing_digital_facil_v3', 'O que é CTA?', 'CTA vem do inglês call to action, ou chamada para ação. É o convite que leva a pessoa a fazer algo, como comprar, assinar ou saber mais.'),
    ('seed_marketing_digital_facil_v3', 'Qual exemplo é uma CTA?', '"Compre agora" é uma chamada para ação porque convida diretamente a pessoa a fazer algo. As outras frases apenas informam uma situação, sem pedir nenhuma ação.'),
    ('seed_marketing_digital_facil_v3', 'O que é um lead?', 'Lead é uma pessoa que demonstrou interesse num produto ou serviço, por exemplo deixando o contato num formulário. É um cliente em potencial que a equipe pode acompanhar até a venda.'),
    ('seed_marketing_digital_facil_v3', 'O que é marketing de conteúdo?', 'Marketing de conteúdo é criar e divulgar conteúdos úteis ou interessantes para atrair e envolver pessoas, em vez de apenas empurrar vendas. Pode ser feito com textos, vídeos, imagens e outros formatos.'),
    ('seed_marketing_digital_facil_v3', 'O que é um blog?', 'Blog é uma plataforma de publicação de conteúdos, normalmente textos organizados do mais recente para o mais antigo. As empresas o usam para ensinar, informar e atrair visitantes.'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 'Persona é uma representação do cliente ideal da empresa, com características como idade, interesses e necessidades. Ajuda a produzir uma comunicação mais adequada ao público.'),
    ('seed_marketing_digital_facil_v3', 'O que é análise de dados no Marketing Digital?', 'Analisar dados é avaliar as informações das campanhas, como alcance e cliques, para tomar melhores decisões. Assim a empresa vê o que funciona e o que precisa mudar.'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 'Métrica é uma medida usada para avaliar resultados, como visualizações, cliques ou vendas. Sem métricas, a empresa não sabe se a campanha deu certo.'),
    ('seed_marketing_digital_facil_v3', 'O que é uma agência digital?', 'Agência digital é uma empresa especializada em estratégias digitais, como gestão de redes sociais, anúncios e criação de conteúdo, que ajuda outras empresas a se promover na internet.'),
    ('seed_marketing_digital_facil_v3', 'O que é comércio eletrônico?', 'Comércio eletrônico é a compra e venda feita pela internet, em lojas virtuais, redes sociais ou aplicativos. Também é chamado de e-commerce.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital fácil lote 3: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
