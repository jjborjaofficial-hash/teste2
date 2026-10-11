-- Explicações pedagógicas (BE-004) — Marketing Digital médio lote 3: 25 perguntas ativas ainda sem explicação, de v2#23 a v3#19 (seeds 049 e 058).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (médio: explica o raciocínio e contextualiza, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 514. Só atualiza
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
    ('seed_marketing_digital_medio_v2', 'Por que a segmentação pode melhorar uma campanha?', 'A segmentação divide o público em grupos com características parecidas, o que pode tornar a mensagem mais relevante para cada grupo e melhorar os resultados. Não elimina custos, não dispensa a análise e não garante que todos comprem.'),
    ('seed_marketing_digital_medio_v2', 'O que é remarketing baseado em interação?', 'O remarketing baseado em interação é a comunicação direcionada a pessoas que já demonstraram algum interesse ou interação com a marca, como visitar o site ou clicar num anúncio. Por já conhecerem a marca, costumam responder melhor.'),
    ('seed_marketing_digital_medio_v2', 'Qual é o objetivo de uma landing page?', 'O objetivo de uma landing page é conduzir o visitante para uma ação específica, como se cadastrar, pedir um orçamento ou comprar. Por isso tem um foco único e poucos elementos que desviem a atenção.'),
    ('seed_marketing_digital_medio_v2', 'O que é branding?', 'Branding é a gestão da identidade e da percepção de uma marca, isto é, de como ela se apresenta e de como o público a vê. Vai além de vender: inclui nome, valores, linguagem e experiência.'),
    ('seed_marketing_digital_medio_v2', 'O que caracteriza uma estratégia de conteúdo?', 'Uma estratégia de conteúdo é um planejamento sobre o que, para quem, quando e por que publicar, ligando cada conteúdo a um objetivo e a um público. Sem esse planejamento, a publicação fica aleatória.'),
    ('seed_marketing_digital_medio_v2', 'O que uma análise de concorrentes pode revelar?', 'Uma análise de concorrentes pode revelar estratégias, pontos fortes e oportunidades de diferenciação, a partir de informações públicas como sites, preços e redes sociais. Dados privados ou confidenciais não fazem parte dela.'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal diferença entre Marketing Digital e Marketing Tradicional?', 'A principal diferença é que o Marketing Digital utiliza canais online e permite maior medição de resultados, como cliques, visitas e conversões. O tradicional usa canais físicos, onde medir o impacto é mais difícil.'),
    ('seed_marketing_digital_medio_v3', 'O que é uma persona no Marketing Digital?', 'Uma persona é um perfil detalhado do cliente ideal, baseado em dados e características como idade, interesses e necessidades. No Marketing Digital serve para orientar a comunicação e as decisões de campanha.'),
    ('seed_marketing_digital_medio_v3', 'Qual é a principal finalidade de criar uma persona?', 'A finalidade de criar uma persona é desenvolver campanhas mais direcionadas ao público correto, falando das necessidades reais das pessoas. Isso melhora a relevância e evita gastar recursos com quem não se interessa.'),
    ('seed_marketing_digital_medio_v3', 'O que representa o topo do funil de vendas?', 'O topo do funil é a fase de atração e descoberta: a pessoa ainda está a conhecer o problema e a marca. Por isso os conteúdos são amplos e educativos, e a compra e a fidelização vêm em fases mais abaixo.'),
    ('seed_marketing_digital_medio_v3', 'O que acontece normalmente no fundo do funil?', 'No fundo do funil, o cliente está mais próximo da decisão de compra e procura confirmar que a oferta é a melhor opção. A comunicação passa a ser mais direta, com provas, demonstrações e condições.'),
    ('seed_marketing_digital_medio_v3', 'O que é CPC em anúncios digitais?', 'CPC significa custo por clique: o valor pago cada vez que alguém clica no anúncio. É um modelo comum em anúncios de busca e de redes sociais, e distingue-se de pagar por impressões ou por conversões.'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPM?', 'CPM significa custo por mil impressões: o valor pago a cada mil vezes que o anúncio é exibido, independentemente de cliques. É usado quando o objetivo é alcance e visibilidade da marca.'),
    ('seed_marketing_digital_medio_v3', 'O que significa CPA no Marketing Digital?', 'CPA significa custo por aquisição: o valor médio gasto para conquistar um cliente ou uma conversão. Permite comparar campanhas pelo resultado final, e não apenas pelos cliques ou pelas impressões.'),
    ('seed_marketing_digital_medio_v3', 'Qual é a vantagem principal de anúncios segmentados?', 'Os anúncios segmentados permitem alcançar pessoas com características específicas, como interesses, localização ou comportamento. Assim a mensagem chega a quem tem mais probabilidade de se interessar, o que melhora o aproveitamento do orçamento.'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função principal do Google Analytics?', 'O Google Analytics serve para analisar o comportamento e os dados dos visitantes de um site, como origem, páginas vistas e tempo de permanência. Esses dados orientam melhorias no site e nas campanhas.'),
    ('seed_marketing_digital_medio_v3', 'Qual é o objetivo principal de uma boa copy?', 'Uma boa copy tem como objetivo gerar interesse e levar o público a tomar uma ação, como clicar, cadastrar-se ou comprar. Informar sem um objetivo claro não basta: o texto deve persuadir.'),
    ('seed_marketing_digital_medio_v3', 'O que é CTA em uma página de vendas?', 'O CTA (call to action) é o elemento que incentiva o visitante a realizar uma ação, como um botão "Comprar agora" ou "Fale conosco". Mostra com clareza o próximo passo que a pessoa deve dar na página.'),
    ('seed_marketing_digital_medio_v3', 'Qual é uma vantagem da automação de marketing?', 'A automação de marketing permite economizar tempo e melhorar o relacionamento com clientes, ao enviar mensagens certas no momento certo de forma automática. Não substitui a análise nem elimina o contato humano.'),
    ('seed_marketing_digital_medio_v3', 'O que é CRM?', 'O CRM é um sistema para gerenciar o relacionamento com clientes: guarda contatos, histórico de interações e oportunidades de venda. Ajuda a equipe a atender melhor e a acompanhar cada cliente ao longo do tempo.'),
    ('seed_marketing_digital_medio_v3', 'O que é inbound marketing?', 'O inbound marketing é a estratégia de atrair clientes através de conteúdo relevante, de modo que eles cheguem à empresa por interesse próprio. Contrasta com o outbound, em que a empresa vai atrás do cliente.'),
    ('seed_marketing_digital_medio_v3', 'O que é outbound marketing?', 'O outbound marketing é a estratégia em que a empresa busca ativamente alcançar clientes, por exemplo com anúncios, chamadas ou e-mails em massa. No inbound, em contraste, é o cliente que encontra a empresa.'),
    ('seed_marketing_digital_medio_v3', 'Qual é a função do SEO técnico?', 'O SEO técnico tem a função de melhorar aspectos técnicos de um site para os mecanismos de busca, como velocidade, estrutura e facilidade de rastreamento. Ajuda o site a ser lido e classificado corretamente.'),
    ('seed_marketing_digital_medio_v3', 'O que são palavras-chave?', 'Palavras-chave são os termos utilizados pelos usuários em pesquisas online. Conhecê-las ajuda a criar conteúdos que respondem ao que as pessoas procuram e a aparecer nos resultados de busca.'),
    ('seed_marketing_digital_medio_v3', 'Por que as palavras-chave são importantes no SEO?', 'As palavras-chave são importantes no SEO porque ajudam os conteúdos a serem encontrados pelos usuários, ligando o que as pessoas pesquisam ao que o site oferece. Usá-las com naturalidade melhora a visibilidade.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital médio lote 3: 25 perguntas ativas ainda sem explicação, de v2#23 a v3#19 (seeds 049 e 058): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
