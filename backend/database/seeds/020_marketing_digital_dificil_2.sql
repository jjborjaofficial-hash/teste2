-- Migration/seed: conteúdo Marketing Digital, nível Difícil (25 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 25 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (59 — distinta das seeds 42 a
-- 58 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Marketing Digital" (slug: marketing-digital) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_dificil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_dificil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_dificil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_marketing_digital_dificil_v2'
    FROM (VALUES
      ('O que é LTV no marketing?'),
      ('Por que comparar LTV e CAC pode ser útil?'),
      ('Uma empresa possui CAC de 500 MZN e estima LTV de 2.000 MZN por cliente. Qual é a relação LTV/CAC?'),
      ('Por que a atribuição pode ser complexa?'),
      ('O que é modelo de atribuição de último clique?'),
      ('O que é funil de marketing?'),
      ('Por que analisar cada etapa do funil?'),
      ('Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?'),
      ('Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?'),
      ('O que é taxa de abandono?'),
      ('O que é segmentação comportamental?'),
      ('Qual é um risco de segmentar excessivamente uma campanha?'),
      ('O que é canibalização entre campanhas?'),
      ('O que significa saturação de audiência?'),
      ('Por que a frequência de exposição deve ser monitorada em campanhas?'),
      ('O que é fadiga criativa?'),
      ('O que é marketing de conteúdo baseado em intenção?'),
      ('Por que a intenção de busca é importante no SEO?'),
      ('O que é palavra-chave de cauda longa?'),
      ('Por que palavras-chave de cauda longa podem ser úteis?'),
      ('O que é autoridade de domínio em termos gerais de SEO?'),
      ('Por que links relevantes de outros sites podem ser importantes para SEO?'),
      ('O que é taxa de engajamento?'),
      ('Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?'),
      ('Por que correlação não significa necessariamente causalidade em marketing?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_dificil2 q
    JOIN (VALUES
      ('O que é LTV no marketing?', 'Número de visitantes', FALSE, 0),
      ('O que é LTV no marketing?', 'Estimativa do valor que um cliente pode gerar durante seu relacionamento com a empresa', TRUE, 1),
      ('O que é LTV no marketing?', 'Quantidade de seguidores', FALSE, 2),
      ('O que é LTV no marketing?', 'Custo de um anúncio', FALSE, 3),
      ('Por que comparar LTV e CAC pode ser útil?', 'Para determinar o tamanho do logotipo', FALSE, 0),
      ('Por que comparar LTV e CAC pode ser útil?', 'Para avaliar a relação entre valor potencial do cliente e custo de aquisição', TRUE, 1),
      ('Por que comparar LTV e CAC pode ser útil?', 'Para escolher uma senha', FALSE, 2),
      ('Por que comparar LTV e CAC pode ser útil?', 'Para calcular o número de funcionários', FALSE, 3),
      ('Uma empresa possui CAC de 500 MZN e estima LTV de 2.000 MZN por cliente. Qual é a relação LTV/CAC?', '3', FALSE, 0),
      ('Uma empresa possui CAC de 500 MZN e estima LTV de 2.000 MZN por cliente. Qual é a relação LTV/CAC?', '5', FALSE, 1),
      ('Uma empresa possui CAC de 500 MZN e estima LTV de 2.000 MZN por cliente. Qual é a relação LTV/CAC?', '2', FALSE, 2),
      ('Uma empresa possui CAC de 500 MZN e estima LTV de 2.000 MZN por cliente. Qual é a relação LTV/CAC?', '4', TRUE, 3),
      ('Por que a atribuição pode ser complexa?', 'Porque clientes utilizam apenas um canal', FALSE, 0),
      ('Por que a atribuição pode ser complexa?', 'Porque um cliente pode interagir com vários canais antes de converter', TRUE, 1),
      ('Por que a atribuição pode ser complexa?', 'Porque campanhas nunca possuem dados', FALSE, 2),
      ('Por que a atribuição pode ser complexa?', 'Porque conversões não podem ser medidas', FALSE, 3),
      ('O que é modelo de atribuição de último clique?', 'Modelo que ignora todos os cliques', FALSE, 0),
      ('O que é modelo de atribuição de último clique?', 'Modelo que considera apenas o primeiro anúncio', FALSE, 1),
      ('O que é modelo de atribuição de último clique?', 'Modelo que divide igualmente todas as conversões', FALSE, 2),
      ('O que é modelo de atribuição de último clique?', 'Modelo que atribui a conversão principalmente ao último ponto de contato considerado', TRUE, 3),
      ('O que é funil de marketing?', 'Modelo que representa etapas pelas quais potenciais clientes podem passar desde descoberta até conversão e relacionamento', TRUE, 0),
      ('O que é funil de marketing?', 'Ferramenta de edição', FALSE, 1),
      ('O que é funil de marketing?', 'Sistema de estoque', FALSE, 2),
      ('O que é funil de marketing?', 'Sistema bancário', FALSE, 3),
      ('Por que analisar cada etapa do funil?', 'Para remover clientes antigos', FALSE, 0),
      ('Por que analisar cada etapa do funil?', 'Para impedir vendas', FALSE, 1),
      ('Por que analisar cada etapa do funil?', 'Para identificar onde potenciais clientes estão abandonando o processo', TRUE, 2),
      ('Por que analisar cada etapa do funil?', 'Para eliminar campanhas', FALSE, 3),
      ('Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 'Apenas o salário da equipe', FALSE, 0),
      ('Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 'Apenas o estoque físico', FALSE, 1),
      ('Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 'Relevância da mensagem, criativo, oferta e chamada para ação', TRUE, 2),
      ('Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 'Apenas o endereço da empresa', FALSE, 3),
      ('Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 'O produto necessariamente é gratuito', FALSE, 0),
      ('Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 'Pode existir problema na oferta, página de destino, público ou processo de conversão', TRUE, 1),
      ('Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 'A campanha deve ser encerrada sem análise', FALSE, 2),
      ('Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 'O anúncio necessariamente é perfeito', FALSE, 3),
      ('O que é taxa de abandono?', 'Número de seguidores novos', FALSE, 0),
      ('O que é taxa de abandono?', 'Total de comentários', FALSE, 1),
      ('O que é taxa de abandono?', 'Valor investido em publicidade', FALSE, 2),
      ('O que é taxa de abandono?', 'Percentual de usuários que iniciam determinado processo, mas não o concluem', TRUE, 3),
      ('O que é segmentação comportamental?', 'Segmentação baseada exclusivamente no nome', FALSE, 0),
      ('O que é segmentação comportamental?', 'Segmentação apenas por cor favorita', FALSE, 1),
      ('O que é segmentação comportamental?', 'Segmentação sem qualquer critério', FALSE, 2),
      ('O que é segmentação comportamental?', 'Segmentação baseada em comportamentos ou interações observáveis relevantes', TRUE, 3),
      ('Qual é um risco de segmentar excessivamente uma campanha?', 'O público pode ficar pequeno demais e limitar alcance ou dados para otimização', TRUE, 0),
      ('Qual é um risco de segmentar excessivamente uma campanha?', 'A campanha sempre ficará mais barata', FALSE, 1),
      ('Qual é um risco de segmentar excessivamente uma campanha?', 'O anúncio será exibido para todos', FALSE, 2),
      ('Qual é um risco de segmentar excessivamente uma campanha?', 'As conversões serão garantidas', FALSE, 3),
      ('O que é canibalização entre campanhas?', 'Situação em que campanhas ou estratégias acabam competindo parcialmente pelo mesmo público ou demanda', TRUE, 0),
      ('O que é canibalização entre campanhas?', 'Aumento automático das vendas', FALSE, 1),
      ('O que é canibalização entre campanhas?', 'Redução dos custos de produção', FALSE, 2),
      ('O que é canibalização entre campanhas?', 'Exclusão de concorrentes', FALSE, 3),
      ('O que significa saturação de audiência?', 'Situação em que o mesmo público recebe exposição excessiva a uma comunicação', TRUE, 0),
      ('O que significa saturação de audiência?', 'Aumento da qualidade do produto', FALSE, 1),
      ('O que significa saturação de audiência?', 'Ausência total de publicidade', FALSE, 2),
      ('O que significa saturação de audiência?', 'Crescimento automático do mercado', FALSE, 3),
      ('Por que a frequência de exposição deve ser monitorada em campanhas?', 'Porque anúncios devem aparecer infinitamente', FALSE, 0),
      ('Por que a frequência de exposição deve ser monitorada em campanhas?', 'Porque frequência não pode ser medida', FALSE, 1),
      ('Por que a frequência de exposição deve ser monitorada em campanhas?', 'Exposição excessiva pode causar fadiga e reduzir a eficiência da comunicação', TRUE, 2),
      ('Por que a frequência de exposição deve ser monitorada em campanhas?', 'Porque toda exposição adicional sempre aumenta conversões', FALSE, 3),
      ('O que é fadiga criativa?', 'Aumento permanente das conversões', FALSE, 0),
      ('O que é fadiga criativa?', 'Falha de conexão do servidor', FALSE, 1),
      ('O que é fadiga criativa?', 'Problema bancário', FALSE, 2),
      ('O que é fadiga criativa?', 'Redução do desempenho de um criativo após exposição repetida ou perda de novidade', TRUE, 3),
      ('O que é marketing de conteúdo baseado em intenção?', 'Produção aleatória', FALSE, 0),
      ('O que é marketing de conteúdo baseado em intenção?', 'Produção de conteúdo alinhado ao que o público busca ou pretende resolver', TRUE, 1),
      ('O que é marketing de conteúdo baseado em intenção?', 'Publicidade sem objetivo', FALSE, 2),
      ('O que é marketing de conteúdo baseado em intenção?', 'Conteúdo criado apenas para funcionários', FALSE, 3),
      ('Por que a intenção de busca é importante no SEO?', 'Elimina a necessidade de conteúdo', FALSE, 0),
      ('Por que a intenção de busca é importante no SEO?', 'Garante primeira posição', FALSE, 1),
      ('Por que a intenção de busca é importante no SEO?', 'Ajuda a alinhar o conteúdo com aquilo que o usuário realmente procura', TRUE, 2),
      ('Por que a intenção de busca é importante no SEO?', 'Impede concorrentes', FALSE, 3),
      ('O que é palavra-chave de cauda longa?', 'Palavra usada apenas em anúncios impressos', FALSE, 0),
      ('O que é palavra-chave de cauda longa?', 'Consulta de busca geralmente mais específica e composta por várias palavras', TRUE, 1),
      ('O que é palavra-chave de cauda longa?', 'Palavra com muitas letras obrigatoriamente', FALSE, 2),
      ('O que é palavra-chave de cauda longa?', 'Nome de uma rede social', FALSE, 3),
      ('Por que palavras-chave de cauda longa podem ser úteis?', 'Podem apresentar intenção mais específica e, em alguns contextos, menor concorrência', TRUE, 0),
      ('Por que palavras-chave de cauda longa podem ser úteis?', 'Garantem vendas', FALSE, 1),
      ('Por que palavras-chave de cauda longa podem ser úteis?', 'Sempre possuem milhões de pesquisas', FALSE, 2),
      ('Por que palavras-chave de cauda longa podem ser úteis?', 'Não precisam de conteúdo relevante', FALSE, 3),
      ('O que é autoridade de domínio em termos gerais de SEO?', 'Conceito usado para representar a força ou autoridade percebida de um domínio, embora diferentes ferramentas utilizem métricas próprias', TRUE, 0),
      ('O que é autoridade de domínio em termos gerais de SEO?', 'Número de funcionários', FALSE, 1),
      ('O que é autoridade de domínio em termos gerais de SEO?', 'Senha do domínio', FALSE, 2),
      ('O que é autoridade de domínio em termos gerais de SEO?', 'Valor do domínio no banco', FALSE, 3),
      ('Por que links relevantes de outros sites podem ser importantes para SEO?', 'Aumentam automaticamente o salário', FALSE, 0),
      ('Por que links relevantes de outros sites podem ser importantes para SEO?', 'Eliminam todo conteúdo', FALSE, 1),
      ('Por que links relevantes de outros sites podem ser importantes para SEO?', 'Podem funcionar como sinais de autoridade ou referência, dependendo da qualidade e contexto', TRUE, 2),
      ('Por que links relevantes de outros sites podem ser importantes para SEO?', 'Garantem primeira posição', FALSE, 3),
      ('O que é taxa de engajamento?', 'Métrica que relaciona interações com alguma base de exposição ou audiência, conforme a fórmula utilizada', TRUE, 0),
      ('O que é taxa de engajamento?', 'Custo de produção', FALSE, 1),
      ('O que é taxa de engajamento?', 'Número de funcionários', FALSE, 2),
      ('O que é taxa de engajamento?', 'Valor total das vendas', FALSE, 3),
      ('Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 'Porque qualquer número significa a mesma coisa', FALSE, 0),
      ('Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 'Porque métricas não precisam de contexto', FALSE, 1),
      ('Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 'Porque diferentes fórmulas e bases podem produzir resultados diferentes', TRUE, 2),
      ('Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 'Porque todas as métricas possuem sempre a mesma fórmula', FALSE, 3),
      ('Por que correlação não significa necessariamente causalidade em marketing?', 'Porque campanhas não possuem resultados', FALSE, 0),
      ('Por que correlação não significa necessariamente causalidade em marketing?', 'Porque dados nunca podem ser analisados', FALSE, 1),
      ('Por que correlação não significa necessariamente causalidade em marketing?', 'Porque toda relação é causal', FALSE, 2),
      ('Por que correlação não significa necessariamente causalidade em marketing?', 'Porque duas variáveis podem variar juntas sem que uma seja necessariamente responsável pela outra', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_dificil2;

    RAISE NOTICE '25 perguntas inseridas com sucesso (source=seed_marketing_digital_dificil_v2).';
  END IF;
END $$;

COMMIT;
