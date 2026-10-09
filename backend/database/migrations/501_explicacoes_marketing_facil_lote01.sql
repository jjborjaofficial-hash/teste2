-- Explicações pedagógicas (BE-004) — Marketing Digital fácil lote 1: as 25 primeiras perguntas ativas (seed v1 e seed v2#1 e #2).
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
    ('seed_marketing_digital_facil_v1', 'O que é marketing digital?', 'Marketing digital é usar canais e ferramentas da internet, como redes sociais, e-mail e sites, para divulgar produtos, serviços ou marcas. A diferença para o marketing tradicional é o meio: aqui tudo acontece online e pode ser medido com mais precisão.'),
    ('seed_marketing_digital_facil_v1', 'O que é público-alvo?', 'Público-alvo é o grupo de pessoas que a empresa quer alcançar com a sua oferta ou comunicação. Conhecer esse grupo ajuda a escolher a mensagem, o canal e o momento certos, em vez de falar com toda a gente ao mesmo tempo.'),
    ('seed_marketing_digital_facil_v1', 'O que é uma marca?', 'A marca é a identidade que diferencia uma empresa, um produto ou um serviço na cabeça do público: o nome, o visual, os valores e a reputação. É por ela que as pessoas reconhecem e escolhem.'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo digital?', 'Conteúdo digital é qualquer material produzido e distribuído em meios digitais, como textos, imagens, vídeos e áudios. Ele pode informar, ensinar ou promover algo.'),
    ('seed_marketing_digital_facil_v1', 'Qual destes é um exemplo de conteúdo digital?', 'Um vídeo publicado numa rede social é conteúdo digital, porque foi criado e distribuído num meio digital. Cartazes, folhetos e anúncios impressos são materiais físicos.'),
    ('seed_marketing_digital_facil_v1', 'O que é uma publicação nas redes sociais?', 'Uma publicação é um conteúdo partilhado numa plataforma social, como uma foto, um vídeo ou um texto. É o que o público vê no feed e com o qual pode interagir.'),
    ('seed_marketing_digital_facil_v1', 'O que significa engajamento nas redes sociais?', 'Engajamento mede o quanto o público interage com um conteúdo: curtidas, comentários, compartilhamentos e salvamentos. Quanto mais interações, mais o conteúdo despertou interesse, e não apenas foi visto.'),
    ('seed_marketing_digital_facil_v1', 'O que é alcance?', 'Alcance é a quantidade de pessoas ou contas diferentes que foram expostas a um conteúdo. Se a mesma pessoa vê duas vezes, conta uma só vez no alcance.'),
    ('seed_marketing_digital_facil_v1', 'O que são impressões?', 'Impressões são o número de vezes que um conteúdo ou anúncio foi exibido, mesmo que seja para a mesma pessoa. Por isso as impressões costumam ser maiores que o alcance.'),
    ('seed_marketing_digital_facil_v1', 'O que é um anúncio digital?', 'Anúncio digital é uma mensagem promocional distribuída por canais digitais, como redes sociais, buscadores e sites. Normalmente é pago e pode ser dirigido a um público específico.'),
    ('seed_marketing_digital_facil_v1', 'O que é uma chamada para ação?', 'A chamada para ação (CTA) é a instrução que convida a pessoa a fazer algo, como comprar, cadastrar-se ou saber mais. Sem ela, o público pode gostar do conteúdo mas não saber qual é o próximo passo.'),
    ('seed_marketing_digital_facil_v1', 'Qual destas é uma chamada para ação?', '"Compre agora" é uma chamada para ação porque diz ao cliente exatamente o que fazer. As outras frases só informam e não convidam a nenhuma ação.'),
    ('seed_marketing_digital_facil_v1', 'O que é uma landing page?', 'Landing page é uma página criada com um objetivo específico, como captar contatos ou gerar uma venda. Ao ter um único foco, ajuda o visitante a fazer a ação pedida em vez de se distrair.'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 'Tráfego em marketing digital são as visitas ou acessos recebidos por um site, página ou canal digital. É uma das medidas mais usadas para saber se o público está a chegar.'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego orgânico?', 'Tráfego orgânico são as visitas que chegam sem que a empresa pague por cada acesso, por exemplo vindas de uma pesquisa no buscador ou de uma partilha espontânea. É conquistado com bom conteúdo ao longo do tempo.'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego pago?', 'Tráfego pago são as visitas obtidas por meio de campanhas publicitárias pagas. Dá resultado mais rápido que o orgânico, mas deixa de chegar quando se deixa de pagar.'),
    ('seed_marketing_digital_facil_v1', 'O que é SEO?', 'SEO é o conjunto de práticas para melhorar a visibilidade das páginas nos resultados dos buscadores, como o Google. Quanto melhor a posição, mais visitas orgânicas a página tende a receber.'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 'A palavra-chave representa um termo que as pessoas podem pesquisar. Ela orienta o que escrever e como montar campanhas, para o conteúdo aparecer quando alguém procura aquele assunto.'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 'Email marketing é o uso do e-mail para comunicar, criar relacionamento ou promover produtos junto a contatos que aceitaram receber mensagens. É um canal próprio da empresa e pode ser medido.'),
    ('seed_marketing_digital_facil_v1', 'O que é uma lista de contatos?', 'Lista de contatos é um conjunto organizado de pessoas ou endereços usados para comunicação, como e-mails ou números de telefone. Deve ser construída com a permissão das pessoas.'),
    ('seed_marketing_digital_facil_v1', 'O que é conteúdo educativo no marketing?', 'Conteúdo educativo é feito para ensinar ou informar o público sobre um assunto, como dicas e tutoriais. Em vez de apenas vender, ajuda a pessoa e mostra que a marca entende do tema.'),
    ('seed_marketing_digital_facil_v1', 'Qual pode ser uma vantagem de produzir conteúdo educativo?', 'Quando uma marca ensina de forma útil, o público passa a confiar nela e a vê-la como referência no assunto. Essa confiança e autoridade aumentam as chances de o público escolhê-la mais tarde.'),
    ('seed_marketing_digital_facil_v1', 'O que é consistência no marketing de conteúdo?', 'Consistência é manter uma frequência e um padrão de comunicação relativamente estáveis ao longo do tempo. Quem aparece com regularidade é lembrado e constrói confiança.'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma imagem em uma publicação?', 'Uma imagem pode chamar atenção e comunicar uma mensagem de forma visual, mais rápido que um texto longo. Ela completa o texto, mas não o substitui por completo.'),
    ('seed_marketing_digital_facil_v2', 'O que é um seguidor?', 'Seguidor é uma pessoa ou conta que acompanha um perfil ou página, para ver as suas publicações. Ter seguidores não significa que todos compram, mas mostra interesse na marca.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital fácil lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
