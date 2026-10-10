-- Explicações pedagógicas (BE-004) — Marketing Digital fácil lote 4: as 23 perguntas ativas que faltam (seed v3#28 a v3#34, v4#1 a v4#8, v5#1 a v5#5, v6#1, v6#2 e v7#1), que fecha o fácil.
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
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 'Plataforma digital é um ambiente online que oferece serviços ou funcionalidades, como redes sociais, lojas virtuais ou sites de vídeo. Cabos, placas e processadores são equipamentos físicos, não ambientes online.'),
    ('seed_marketing_digital_facil_v3', 'Por que empresas usam Marketing Digital?', 'As empresas usam o Marketing Digital para alcançar mais clientes e criar oportunidades de negócio, porque grande parte do público passa o tempo na internet. É uma forma de divulgar e vender com custos que a empresa consegue ajustar.'),
    ('seed_marketing_digital_facil_v3', 'O que é presença digital?', 'Presença digital é a existência e a atuação de uma marca na internet: site, redes sociais, anúncios e outros canais onde o público a encontra. Quanto mais cuidada, mais fácil é a marca ser encontrada.'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo patrocinado?', 'Conteúdo patrocinado é aquele que a marca paga para ser mostrado a mais pessoas, por exemplo numa rede social. O investimento aumenta o alcance do conteúdo.'),
    ('seed_marketing_digital_facil_v3', 'O que é uma publicação?', 'Uma publicação é um conteúdo compartilhado numa plataforma digital, como um texto, uma foto ou um vídeo numa rede social. Peças de computador, programas e senhas não são conteúdo publicado.'),
    ('seed_marketing_digital_facil_v3', 'O que é algoritmo das redes sociais?', 'O algoritmo é o sistema que decide quais conteúdos aparecem para cada pessoa e em que ordem, com base nos seus interesses e no que costuma ver. Por isso um conteúdo relevante e que gera interação tende a chegar a mais gente.'),
    ('seed_marketing_digital_facil_v3', 'O que é estratégia digital?', 'Estratégia digital é um plano organizado para alcançar objetivos usando meios digitais, definindo público, canais, conteúdos e metas. Sem plano, as ações ficam soltas e difíceis de medir.'),
    ('seed_marketing_digital_facil_v4', 'O que é uma página de captura?', 'A página de captura serve para recolher informações de potenciais clientes, como nome e e-mail, normalmente em troca de algo útil, como um e-book. Esses contatos viram leads que a equipe de vendas pode acompanhar.'),
    ('seed_marketing_digital_facil_v4', 'Qual informação é normalmente solicitada em uma página de captura?', 'Numa página de captura pede-se normalmente o nome e o e-mail do visitante, porque bastam para entrar em contato depois. Pedir senha bancária ou dados técnicos do computador não faz sentido e afasta as pessoas.'),
    ('seed_marketing_digital_facil_v4', 'Qual destes é um exemplo de produto digital?', 'Curso online é um produto digital: é entregue pela internet, em vídeo ou texto, sem nenhuma peça física. Teclado, mesa e impressora são objetos físicos.'),
    ('seed_marketing_digital_facil_v4', 'O que é uma publicação patrocinada?', 'Publicação patrocinada é aquela em que a marca investe dinheiro para o conteúdo ser mostrado a mais pessoas além dos seguidores. É diferente de uma publicação normal, que depende do alcance natural.'),
    ('seed_marketing_digital_facil_v4', 'O que é uma bio em uma rede social?', 'A bio é o pequeno espaço de apresentação do perfil, onde a marca diz quem é e o que faz e pode deixar um link. É a primeira coisa que muita gente lê ao visitar o perfil.'),
    ('seed_marketing_digital_facil_v4', 'Por que uma empresa deve responder comentários nas redes sociais?', 'Responder aos comentários mostra que a empresa ouve o público, e isso cria relacionamento e confiança. Ignorar ou bloquear as pessoas afasta os clientes.'),
    ('seed_marketing_digital_facil_v4', 'O que é um nicho de mercado?', 'Nicho de mercado é um segmento específico de pessoas com interesses semelhantes, o que facilita falar diretamente com elas. Quanto mais definido o nicho, mais certeira pode ser a comunicação.'),
    ('seed_marketing_digital_facil_v4', 'O que é uma chamada de atenção em um anúncio?', 'A chamada de atenção é o elemento do anúncio, como uma imagem, uma frase ou uma oferta, que desperta o interesse do público logo à primeira vista. Sem ela, o anúncio passa despercebido.'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 'A marca é a identidade que representa uma empresa, um produto ou um serviço: nome, logotipo, valores e a imagem que fica na cabeça do público. Vai muito além de um anúncio.'),
    ('seed_marketing_digital_facil_v5', 'Qual é a função de uma rede social para uma empresa?', 'Para uma empresa, a rede social serve para criar relacionamento com o público e divulgar produtos ou serviços. É um canal de conversa com as pessoas, não apenas de mensagens privadas.'),
    ('seed_marketing_digital_facil_v5', 'O que é engajamento nas redes sociais?', 'Engajamento nas redes sociais é a interação dos usuários com um conteúdo publicado: curtidas, comentários, compartilhamentos e respostas. Mostra que o público se interessou.'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 'As empresas criam conteúdos para atrair, informar e criar relacionamento com o público. Um conteúdo útil leva a pessoa a conhecer a marca e a confiar nela.'),
    ('seed_marketing_digital_facil_v5', 'O que é uma chamada para ação (CTA)?', 'CTA, ou chamada para ação, é a frase que incentiva o usuário a realizar uma ação, como comprar, assinar ou saber mais. Sem uma CTA clara, a pessoa pode não saber o que fazer a seguir.'),
    ('seed_marketing_digital_facil_v6', 'O que é alcance em uma rede social?', 'Alcance é o número de pessoas que visualizaram determinado conteúdo. Não é dinheiro investido, nem vendas, nem número de funcionários.'),
    ('seed_marketing_digital_facil_v6', 'O que é uma campanha de Marketing Digital?', 'Uma campanha de Marketing Digital é um conjunto de ações planejadas para alcançar um objetivo de marketing na internet, como divulgar um produto. Tem planejamento, prazo e resultados que se medem.'),
    ('seed_marketing_digital_facil_v7', 'O que é uma newsletter?', 'Newsletter é um boletim informativo enviado periodicamente por e-mail para manter contacto com o público, com novidades, dicas ou ofertas. Ajuda a manter a marca presente na cabeça das pessoas.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital fácil lote 4: % pergunta(s) atualizada(s) (esperado: 23).', v_updated;
END $$;
