-- Explicações pedagógicas (BE-004) — Marketing Digital fácil lote 2: 25 perguntas ativas seguintes (seed v2#3 a v2#26 e v3#1).
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
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 'Publicar com regularidade é manter uma frequência planejada, por exemplo uma ou duas vezes por semana, para o público se habituar a ver a marca. Publicar ao acaso ou deixar longos períodos parados faz o público esquecer.'),
    ('seed_marketing_digital_facil_v2', 'O que é uma hashtag?', 'Hashtag é uma palavra ou expressão precedida do símbolo # que serve para agrupar e encontrar conteúdos sobre um mesmo assunto. Quem pesquisa a hashtag vê todas as publicações que a usaram.'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 'O perfil de uma empresa é a sua vitrine na rede social: apresenta a marca, os produtos, os serviços e os conteúdos ao público. É por ali que muitos clientes têm o primeiro contato com o negócio.'),
    ('seed_marketing_digital_facil_v2', 'O que significa interação nas redes sociais?', 'Interação são as ações do público sobre um conteúdo, como comentar, curtir, compartilhar ou responder. Quanto maior a interação, maior o sinal de que o conteúdo despertou interesse.'),
    ('seed_marketing_digital_facil_v2', 'O que é um comentário?', 'Comentário é uma manifestação escrita ou uma reação deixada num conteúdo. É por ele que o público dá opinião, tira dúvidas e conversa com a marca.'),
    ('seed_marketing_digital_facil_v2', 'O que significa compartilhar uma publicação?', 'Compartilhar uma publicação é distribuí-la para outras pessoas ou espaços da plataforma, como o próprio perfil ou um grupo. Assim o conteúdo chega a quem não segue o autor.'),
    ('seed_marketing_digital_facil_v2', 'O que é um produto digital?', 'Produto digital é aquele entregue principalmente em formato digital, como um curso online, um aplicativo ou um e-book. Não precisa de estoque físico nem de transporte.'),
    ('seed_marketing_digital_facil_v2', 'Qual é um exemplo de produto digital?', 'O e-book é um livro em formato digital, por isso é um produto digital. Sapatos, cadeiras e mesas são produtos físicos.'),
    ('seed_marketing_digital_facil_v2', 'O que significa vender pela internet?', 'Vender pela internet é usar canais online, como site, redes sociais ou aplicativos, para apresentar e comercializar produtos ou serviços. O cliente pode ver, escolher e comprar sem ir à loja.'),
    ('seed_marketing_digital_facil_v2', 'O que é uma oferta?', 'Oferta é a proposta feita ao consumidor para adquirir um produto ou serviço, normalmente com preço e condições. É o convite concreto para a compra.'),
    ('seed_marketing_digital_facil_v2', 'O que é desconto?', 'Desconto é a redução aplicada sobre um preço ou valor. É usado para incentivar a compra, mas precisa ser calculado para a empresa continuar a ter lucro.'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 'A descrição do produto é o texto que apresenta as características, os benefícios e as informações do produto. Numa loja online, ela faz o papel do vendedor que explica o que se está a comprar.'),
    ('seed_marketing_digital_facil_v2', 'Por que uma descrição clara pode ajudar nas vendas?', 'Uma descrição clara ajuda o cliente a entender o que está a ser oferecido, e quem entende bem tem mais segurança para comprar. Ela não garante a venda, mas reduz as dúvidas.'),
    ('seed_marketing_digital_facil_v2', 'O que é uma audiência digital?', 'Audiência digital é o conjunto de pessoas alcançadas ou interessadas num conteúdo, marca ou tema, como seguidores, visitantes e inscritos. Conhecê-la ajuda a decidir o que publicar.'),
    ('seed_marketing_digital_facil_v2', 'O que significa criar conteúdo?', 'Criar conteúdo é produzir materiais como textos, vídeos, imagens ou áudios com um objetivo, por exemplo informar, ensinar ou atrair clientes. Sem objetivo definido, o conteúdo tende a não gerar resultado.'),
    ('seed_marketing_digital_facil_v2', 'Para que serve uma chamada para ação, conhecida como CTA?', 'A chamada para ação, ou CTA, orienta o usuário sobre a ação desejada, como comprar, cadastrar-se ou saber mais. Ela mostra o próximo passo em vez de deixar a pessoa sem saber o que fazer.'),
    ('seed_marketing_digital_facil_v2', 'Qual destas é uma CTA?', '"Saiba mais" é uma CTA porque convida a pessoa a fazer algo: clicar para obter mais informação. As outras expressões só nomeiam um campo ou um dado e não pedem nenhuma ação.'),
    ('seed_marketing_digital_facil_v2', 'O que é conteúdo relevante?', 'Conteúdo relevante é o que responde às necessidades e aos interesses do público. Se o conteúdo não interessa a quem o vê, não gera interação nem confiança.'),
    ('seed_marketing_digital_facil_v2', 'Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 'As visualizações mostram quantas vezes um conteúdo foi visto, por exemplo um vídeo ou uma página. Cliques, seguidores e margem de lucro medem outras coisas.'),
    ('seed_marketing_digital_facil_v2', 'Por que testar diferentes anúncios pode ser útil?', 'Testar diferentes anúncios permite descobrir quais versões têm melhor desempenho antes de investir mais dinheiro. Assim o orçamento é usado no que realmente funciona.'),
    ('seed_marketing_digital_facil_v2', 'O que significa alcance?', 'Alcance é o número de pessoas ou contas que foram expostas a um conteúdo, contadas uma só vez cada uma. Mostra o tamanho do público que realmente viu a mensagem.'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma característica de um bom título?', 'Um bom título desperta interesse e comunica claramente o assunto, para a pessoa perceber logo do que se trata e decidir se continua a ler ou a ver. Um título confuso ou sem relação com o conteúdo afasta o público.'),
    ('seed_marketing_digital_facil_v2', 'Qual é uma vantagem de analisar dados de uma campanha?', 'Analisar os dados de uma campanha permite tomar decisões baseadas em resultados, como o que manter, melhorar ou parar. Não garante vendas, mas reduz o risco de gastar sem saber.'),
    ('seed_marketing_digital_facil_v2', 'Por que conhecer a persona é importante?', 'A persona é um retrato do cliente ideal. Conhecê-la ajuda a produzir uma comunicação mais adequada ao público, com a linguagem, o tema e o canal certos. Ela não garante lucro por si só.'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 'O principal objetivo do marketing digital é atrair, comunicar e converter clientes pela internet: chamar a atenção, falar com o público e transformar o interesse em compra ou contato.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital fácil lote 2: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
