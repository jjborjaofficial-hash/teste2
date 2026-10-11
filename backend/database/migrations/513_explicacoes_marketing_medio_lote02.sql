-- Explicações pedagógicas (BE-004) — Marketing Digital médio lote 2: 25 perguntas ativas ainda sem explicação, de v1#27 a v2#22 (seeds 038 e 049).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (médio: explica o raciocínio e contextualiza, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 512. Só atualiza
-- perguntas que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera
-- perguntas nem alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não
-- impedir o arranque do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_marketing_digital_medio_v1', 'O que é calendário editorial?', 'O calendário editorial é o planejamento organizado dos conteúdos que serão produzidos e publicados, com temas, formatos, datas e canais. Funciona como um mapa que evita improvisos e garante consistência na comunicação.'),
    ('seed_marketing_digital_medio_v1', 'Qual é uma vantagem de um calendário editorial?', 'Um calendário editorial ajuda a organizar temas, formatos, datas e frequência de publicação, o que dá regularidade e evita lacunas ou excesso de posts. Não garante seguidores nem vendas, e não substitui a criatividade.'),
    ('seed_marketing_digital_medio_v1', 'O que é nutrição de leads?', 'Nutrição de leads é manter relacionamento com potenciais clientes, ainda não prontos para comprar, por meio de conteúdos e comunicações relevantes. O objetivo é acompanhar a decisão de compra até o momento certo.'),
    ('seed_marketing_digital_medio_v2', 'O que é uma persona de marketing?', 'Uma persona é uma representação semifictícia do cliente ideal, construída a partir de dados e de características como necessidades, dores e comportamentos. Serve para orientar a comunicação e as decisões de produto.'),
    ('seed_marketing_digital_medio_v2', 'Por que uma empresa deve conhecer os problemas do seu público?', 'Conhecer os problemas do público permite desenvolver comunicação e ofertas mais relevantes, porque a empresa passa a falar das necessidades reais das pessoas. Isso aumenta a chance de a mensagem ser notada e valorizada.'),
    ('seed_marketing_digital_medio_v2', 'O que é posicionamento de marca?', 'O posicionamento define a forma como a marca busca ser percebida na mente do público em relação às alternativas do mercado. É uma escolha estratégica sobre o que a marca representa e em que se diferencia.'),
    ('seed_marketing_digital_medio_v2', 'O que é proposta de valor?', 'A proposta de valor explica o valor ou o benefício que uma oferta pretende proporcionar ao cliente e por que ela merece ser escolhida. Vai além do preço: inclui a solução e a vantagem que a pessoa obtém.'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de produzir conteúdo educativo?', 'O conteúdo educativo pode aumentar a autoridade e a confiança junto ao público, porque mostra conhecimento e ajuda a resolver dúvidas antes da compra. Esse efeito constrói-se com o tempo e não garante vendas imediatas.'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de entretenimento?', 'O conteúdo de entretenimento é desenvolvido principalmente para divertir ou proporcionar lazer, e assim aproxima a marca do público de forma leve. Difere do conteúdo educativo, cujo foco é ensinar ou informar.'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de prova social?', 'A prova social é um conteúdo que demonstra experiências, avaliações ou resultados de clientes, como depoimentos e casos de sucesso. Funciona porque as pessoas tendem a confiar na experiência de quem já usou o produto.'),
    ('seed_marketing_digital_medio_v2', 'O que é taxa de cliques?', 'A taxa de cliques (CTR) é o percentual de pessoas que clicam em um elemento, como um anúncio ou link, depois de o verem. Calcula-se dividindo os cliques pelas visualizações e multiplicando por cem.'),
    ('seed_marketing_digital_medio_v2', 'Por que a taxa de cliques pode ser importante?', 'A taxa de cliques ajuda a avaliar se uma mensagem ou anúncio está estimulando cliques, ou seja, se chama a atenção e gera interesse. Não mede lucro nem qualidade do produto, e um clique ainda não é uma conversão.'),
    ('seed_marketing_digital_medio_v2', 'O que significa conversão em uma campanha?', 'Conversão é a realização da ação definida como objetivo da campanha, como uma compra, um cadastro ou um contato. Visualizações, curtidas e aberturas de página medem alcance ou interesse, mas não são, por si só, a conversão.'),
    ('seed_marketing_digital_medio_v2', 'Uma campanha possui 1.000 visitantes e 50 realizam a ação desejada. Qual é a taxa de conversão?', 'A taxa de conversão é a razão entre quem realizou a ação desejada e o total de visitantes: 50 em 1.000 dá 50 ÷ 1.000 = 0,05, ou seja, 5%. Os valores de 10% e 20% implicariam 100 e 200 conversões.'),
    ('seed_marketing_digital_medio_v2', 'O que é custo por clique?', 'O custo por clique (CPC) é o valor médio pago por cada clique em uma campanha publicitária, e calcula-se dividindo o gasto total pelo número de cliques. Serve para comparar a eficiência de anúncios e canais.'),
    ('seed_marketing_digital_medio_v2', 'O que significa alcance orgânico?', 'O alcance orgânico é o número de pessoas alcançadas sem pagamento direto por publicidade para aquela distribuição, por exemplo por seguidores, buscas ou compartilhamentos. Contrasta com o alcance pago, obtido com anúncios.'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de combinar tráfego orgânico e pago?', 'Combinar tráfego orgânico e pago permite trabalhar o crescimento de longo prazo, enquanto as campanhas pagas podem ampliar o alcance mais rapidamente. Uma estratégia complementa a outra, em vez de substituí-la.'),
    ('seed_marketing_digital_medio_v2', 'Por que analisar o desempenho de uma publicação?', 'Analisar o desempenho de uma publicação serve para entender o que funcionou e orientar futuras decisões, como formatos, horários e temas. Sem essa análise, repetem-se erros e perde-se a oportunidade de aprender com os dados.'),
    ('seed_marketing_digital_medio_v2', 'Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 'Num teste A/B, alterar uma variável relevante de cada vez facilita a identificação do fator que contribuiu para a diferença de desempenho. Se várias coisas mudam ao mesmo tempo, não se sabe qual delas causou o resultado.'),
    ('seed_marketing_digital_medio_v2', 'Por que clientes recorrentes podem ser importantes?', 'Clientes recorrentes podem gerar valor contínuo e reduzir a dependência da aquisição constante de novos clientes, que costuma ser mais cara. Por isso a retenção e a fidelização têm grande peso na rentabilidade.'),
    ('seed_marketing_digital_medio_v2', 'O que é aquisição de clientes?', 'A aquisição de clientes é o processo de atrair e conquistar novos clientes, desde o primeiro contato até a primeira compra. Distingue-se da retenção, que se ocupa de manter e fidelizar quem já comprou.'),
    ('seed_marketing_digital_medio_v2', 'O que é custo de aquisição de cliente, ou CAC?', 'O CAC é o custo médio associado à aquisição de um novo cliente, somando os gastos de marketing e de vendas e dividindo pelo número de clientes conquistados. Compara-se com o valor que o cliente gera ao longo do tempo.'),
    ('seed_marketing_digital_medio_v2', 'Se uma empresa gasta 10.000 MZN em marketing e conquista 100 novos clientes, qual é o CAC simplificado?', 'O CAC simplificado divide o investimento pelo número de clientes conquistados: 10.000 MZN ÷ 100 clientes = 100 MZN por cliente. Os outros valores resultam de dividir por números diferentes de clientes.'),
    ('seed_marketing_digital_medio_v2', 'O que é relacionamento com o cliente?', 'O relacionamento com o cliente reúne as estratégias e interações utilizadas para construir e manter uma relação com os consumidores, antes, durante e depois da compra. Visa a confiança e a fidelização, não apenas a venda isolada.'),
    ('seed_marketing_digital_medio_v2', 'O que significa personalizar uma comunicação?', 'Personalizar uma comunicação é adaptar a mensagem de acordo com características ou contexto relevante do público, como interesses, histórico ou momento. Mensagens mais ajustadas tendem a gerar mais atenção e resposta.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital médio lote 2: 25 perguntas ativas ainda sem explicação, de v1#27 a v2#22 (seeds 038 e 049): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
