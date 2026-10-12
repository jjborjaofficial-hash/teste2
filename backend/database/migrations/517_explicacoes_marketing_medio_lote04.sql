-- Explicações pedagógicas (BE-004) — Marketing Digital médio lote 4: as mesmas 23 perguntas da migration 516 (explicação curta e clara,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_marketing_digital_medio_v3', 'O que é ROI?', 'ROI vem de "Return On Investment", ou retorno sobre investimento. Compara o que se ganhou com o que se gastou, e por isso mostra se uma ação de marketing compensou o dinheiro aplicado.'),
    ('seed_marketing_digital_medio_v3', 'Por que uma empresa deve analisar dados de marketing?', 'Os dados mostram o que funciona e o que não funciona. Com essa informação a empresa decide com base em factos, corta o que rende pouco e reforça o que traz resultado, em vez de agir por palpite.'),
    ('seed_marketing_digital_medio_v3', 'O que é branding digital?', 'Branding é o trabalho de dar identidade e reputação a uma marca. No digital faz-se em sites, redes sociais e anúncios, com o objetivo de a marca ser reconhecida, lembrada e confiável online.'),
    ('seed_marketing_digital_medio_v3', 'O que é uma campanha de conversão?', 'O que define uma campanha de conversão é o objetivo: levar a pessoa a fazer algo concreto, como comprar ou preencher um cadastro. Por isso o sucesso mede-se em ações realizadas, e não só em visualizações.'),
    ('seed_marketing_digital_medio_v3', 'O que é link building?', 'Link building é conseguir que outros sites apontem para o seu. Os motores de busca tratam esses links como recomendações, e quanto mais fortes forem, maior é a autoridade do site e melhor a sua posição nos resultados.'),
    ('seed_marketing_digital_medio_v3', 'Por que medir ROI é importante?', 'Sem medir o ROI não se sabe se o dinheiro gasto voltou com lucro. Medir permite manter o que compensa e cortar ou ajustar o que gasta mais do que devolve.'),
    ('seed_marketing_digital_medio_v3', 'O que é taxa de rejeição (bounce rate)?', 'A taxa de rejeição mostra quantos visitantes chegam a uma página e saem logo, sem clicar nem avançar. Uma taxa alta pode indicar que a página não corresponde ao que a pessoa procurava ou que está confusa.'),
    ('seed_marketing_digital_medio_v3', 'Qual métrica geralmente indica melhor resultado comercial?', 'Conversões contam as ações que geram negócio, como compras e cadastros. Curtidas e seguidores mostram atenção, mas não garantem que alguém comprou, por isso as conversões ligam-se mais ao resultado comercial.'),
    ('seed_marketing_digital_medio_v3', 'O que é autoridade de domínio?', 'A autoridade de domínio estima o quanto um site é confiável e relevante, em grande parte pela quantidade e qualidade dos links que recebe. Sites com mais autoridade tendem a aparecer melhor nas pesquisas.'),
    ('seed_marketing_digital_medio_v3', 'O que é estratégia de conteúdo?', 'Estratégia de conteúdo é decidir antes o que criar, para quem, onde publicar e com que objetivo. Sem esse plano os conteúdos ficam soltos; com ele, cada publicação ajuda a atingir uma meta.'),
    ('seed_marketing_digital_medio_v3', 'O que são métricas de vaidade?', 'Métricas de vaidade, como número de seguidores ou de curtidas, impressionam à primeira vista mas não provam vendas nem lucro. Convém acompanhar também indicadores ligados ao resultado, como as conversões.'),
    ('seed_marketing_digital_medio_v3', 'O que é calendário de conteúdo?', 'O calendário de conteúdo organiza o que será publicado, onde e quando. Ajuda a manter regularidade, evitar improvisos de última hora e distribuir os temas ao longo das semanas.'),
    ('seed_marketing_digital_medio_v4', 'O que é frequência em anúncios digitais?', 'A frequência diz quantas vezes, em média, cada pessoa viu o mesmo anúncio. Pouca frequência pode não ser lembrada; demasiada cansa o público e desperdiça orçamento.'),
    ('seed_marketing_digital_medio_v4', 'O que é uma sequência de e-mails automatizada?', 'Numa sequência automatizada as mensagens são programadas de antemão e saem sozinhas, a partir de um gatilho como a inscrição de alguém. Seguem uma estratégia, por exemplo apresentar a marca e depois fazer uma oferta.'),
    ('seed_marketing_digital_medio_v4', 'O que é alcance orgânico?', 'Alcance orgânico é o número de pessoas que veem o conteúdo de forma natural, por seguidores, partilhas ou pesquisas, sem pagar para o promover. O alcance pago, ao contrário, depende de investir em anúncios.'),
    ('seed_marketing_digital_medio_v4', 'O que é uma isca digital?', 'A isca digital é um material útil e gratuito, como um e-book ou um modelo, dado em troca dos dados de contacto da pessoa. Assim a empresa capta leads, isto é, potenciais clientes interessados no tema.'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de abertura de e-mail?', 'A taxa de abertura é a parte dos destinatários que abriu o e-mail. Depende muito do assunto e do remetente, por isso é usada para avaliar se o título chamou a atenção.'),
    ('seed_marketing_digital_medio_v4', 'O que é otimização de anúncios?', 'Otimizar é ajustar a campanha com base nos dados: testar textos e imagens, refinar o público e mexer no orçamento. O objetivo é conseguir melhores resultados com o mesmo ou menor investimento.'),
    ('seed_marketing_digital_medio_v4', 'O que é taxa de cliques em e-mail marketing?', 'A taxa de cliques mostra a parte dos destinatários que clicou em algum link do e-mail. Indica se o conteúdo e o botão de ação interessaram, indo além de apenas abrir a mensagem.'),
    ('seed_marketing_digital_medio_v4', 'Qual é a função principal de um funil de marketing?', 'O funil representa o caminho do cliente: primeiro descobre a marca, depois considera a oferta e por fim decide comprar. Pensar nele ajuda a escolher a mensagem certa para cada etapa e a levar a pessoa até à conversão.'),
    ('seed_marketing_digital_medio_v4', 'O que é uma estratégia de remarketing eficiente?', 'O remarketing volta a falar com quem já visitou o site ou mostrou interesse, e é mais eficiente quando a mensagem é relevante para esse momento. Quem já conhece a marca tem mais probabilidade de converter do que um desconhecido.'),
    ('seed_marketing_digital_medio_v5', 'Qual é a importância de analisar métricas em uma campanha digital?', 'Analisar métricas mostra o que a campanha está a conseguir de facto. Com esses números é possível corrigir o que falha, reforçar o que funciona e decidir com mais segurança onde investir.'),
    ('seed_marketing_digital_medio_v6', 'O que é segmentação de público em Marketing Digital?', 'Segmentar é separar o público em grupos parecidos, por idade, localização ou interesses. Assim cada grupo recebe uma mensagem mais adequada, o que costuma aumentar o interesse e reduzir o desperdício de anúncios.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital médio lote 4: % pergunta(s) atualizada(s) (esperado: 23).', v_updated;
END $$;
