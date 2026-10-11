-- Explicações pedagógicas (BE-004) — Marketing Digital difícil lote 3: as perguntas ativas v3#2 a v3#26 do seed dificil_v3 (migration 059).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e relação entre conceitos, nível difícil, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 524. Só atualiza perguntas
-- que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não impedir o arranque
-- do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_marketing_digital_dificil_v3', 'O que caracteriza um Growth Hacker?', 'O Growth Hacker é o profissional focado em crescimento: testa hipóteses rápidas, decide com dados e inova para escalar o que funciona. Não é só identidade visual, atendimento presencial ou infraestrutura, que são outras funções.'),
    ('seed_marketing_digital_dificil_v3', 'O que é CRO (Conversion Rate Optimization)?', 'CRO é o processo de otimizar páginas e experiências para aumentar a taxa de conversão: testa-se e melhora-se o que já recebe tráfego. Não é excluir campanhas, ampliar públicos nem criar anúncios para ganhar seguidores.'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o objetivo principal de uma landing page otimizada?', 'O objetivo de uma landing page otimizada é transformar visitantes em leads ou clientes, com uma mensagem e uma ação claras. Não serve para apresentar a empresa em geral, substituir redes sociais nem aumentar o site.'),
    ('seed_marketing_digital_dificil_v3', 'O que é um funil de vendas avançado?', 'O funil de vendas avançado acompanha as diferentes etapas do comportamento do consumidor, permitindo ver onde ele avança ou abandona. Não é uma ferramenta de organização de equipe, um banco de dados nem uma página de vendas.'),
    ('seed_marketing_digital_dificil_v3', 'O que significa LTV no Marketing Digital?', 'O LTV é o valor total que um cliente gera durante o relacionamento com a empresa, e por isso pesa mais do que uma única compra. Visitas, tempo de carregamento ou número de anúncios são outras métricas.'),
    ('seed_marketing_digital_dificil_v3', 'O que significa CAC?', 'CAC significa custo de aquisição de cliente: quanto a empresa gasta, em média, para conquistar um novo cliente. Comparado com o LTV, mostra se a aquisição compensa. As outras siglas não existem como métricas de marketing.'),
    ('seed_marketing_digital_dificil_v3', 'Qual relação é geralmente desejável entre LTV e CAC?', 'Em geral, o LTV deve ser maior que o CAC, para que o valor que o cliente gera cubra, e supere, o custo de o conquistar. Se for igual, não sobra margem, e se for menor, a aquisição dá prejuízo.'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição de conversão?', 'Atribuição de conversão é o processo de identificar quais canais contribuíram para uma conversão e quanto crédito merece cada um. Não decide verbas nem mede cliques ou comissões, embora ajude a decidir onde investir.'),
    ('seed_marketing_digital_dificil_v3', 'O que é modelo de atribuição last click?', 'No modelo last click, o crédito da conversão vai para o último canal antes da compra, e os canais anteriores ficam sem crédito. É simples, mas ignora o resto da jornada. Dividir o crédito entre os canais é o modelo linear.'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição baseada em dados?', 'A atribuição baseada em dados usa informações reais de comportamento para distribuir o crédito entre os pontos de contato, em vez de regras fixas ou sorteios. Por isso reflete melhor a contribuição de cada canal.'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Journey Mapping?', 'O Customer Journey Mapping mapeia a experiência do cliente, desde a descoberta até o pós-compra, mostrando pontos de contato e dificuldades. Não é um mapa de custos, de canais de anúncio nem de tarefas da equipe.'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização em Marketing Digital?', 'Personalização é adaptar mensagens e experiências para diferentes usuários, em vez de tratar todos igual. Não é remover dados, ampliar volume nem padronizar mensagens, que é o oposto.'),
    ('seed_marketing_digital_dificil_v3', 'O que é automação baseada em comportamento?', 'A automação baseada em comportamento envia ações automaticamente conforme o comportamento do usuário, como um email depois de abandonar o carrinho. Envios manuais, relatórios ou bloqueios por regras do sistema são outra coisa.'),
    ('seed_marketing_digital_dificil_v3', 'O que é lead scoring?', 'Lead scoring é um sistema de pontuação que avalia a qualidade dos leads, somando pontos por ações e perfil. Não conta seguidores, não avalia anúncios nem produz vídeos.'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a finalidade do lead scoring?', 'A finalidade do lead scoring é priorizar os leads com maior possibilidade de compra, para a equipe de vendas focar neles. Não substitui vendedores, nem elimina contatos, nem aumenta a base por si só.'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma campanha de remarketing dinâmico?', 'O remarketing dinâmico exibe, de forma personalizada, produtos ou conteúdos conforme o comportamento anterior do usuário, como mostrar o produto que ele viu. Exibição padronizada, impressa ou apenas por orçamento não é dinâmica.'),
    ('seed_marketing_digital_dificil_v3', 'O que é segmentação lookalike?', 'A segmentação lookalike encontra novos usuários semelhantes aos melhores clientes existentes, usando as características deles. Não copia concorrentes, não remove usuários e não cria produtos.'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma audiência personalizada?', 'A audiência personalizada é um público criado a partir de dados de clientes ou visitantes existentes, como uma lista de emails ou o pixel. Não é um público amplo por interesses, nem regras de orçamento, nem listas compradas.'),
    ('seed_marketing_digital_dificil_v3', 'O que é ROAS?', 'O ROAS é o retorno financeiro gerado especificamente por anúncios, relacionado ao que se investiu neles. Visitas, cliques ou custos são outras métricas e não medem o retorno financeiro.'),
    ('seed_marketing_digital_dificil_v3', 'Qual fórmula representa ROAS?', 'O ROAS é a receita gerada pelos anúncios dividida pelo investimento em anúncios: um ROAS de 4 significa que cada unidade investida gerou 4 de receita. A inversão da fração, o lucro ou os cliques não definem o ROAS.'),
    ('seed_marketing_digital_dificil_v3', 'Um CTR baixo em um anúncio geralmente indica:', 'Um CTR baixo indica que poucas pessoas que viram o anúncio clicaram, em geral por baixa relevância ou pouco interesse do público. Por isso pede revisão da mensagem, do criativo ou da segmentação.'),
    ('seed_marketing_digital_dificil_v3', 'O que é Quality Score em anúncios?', 'O Quality Score avalia a relevância e a qualidade dos anúncios e das páginas relacionadas, e influencia o custo e a posição dos anúncios. Não é uma avaliação de preço, de cliques isolados nem de alcance.'),
    ('seed_marketing_digital_dificil_v3', 'O que é remarketing baseado em pixel?', 'O remarketing baseado em pixel usa um código de rastreamento para identificar visitantes e criar públicos que se pode impactar de novo. Não depende de imagens de produtos, de sistemas de vendas nem de cadastros em papel.'),
    ('seed_marketing_digital_dificil_v3', 'O que é um pixel de rastreamento?', 'O pixel de rastreamento é um código usado para coletar informações sobre as ações dos usuários, como visitas e compras, e alimenta o remarketing e a medição. Não é uma imagem nem um texto descritivo.'),
    ('seed_marketing_digital_dificil_v3', 'O que é atribuição multicanal?', 'A atribuição multicanal analisa vários canais que participaram da conversão, em vez de olhar para um só. Assim se vê o papel de cada ponto de contato. Não analisa um único canal, públicos de pesquisa nem leilões de anúncios.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital difícil lote 3: as perguntas ativas v3#2 a v3#26 do seed dificil_v3 (migration 059): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
