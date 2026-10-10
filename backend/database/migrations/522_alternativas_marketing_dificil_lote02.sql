-- Alternativas (BE-003, regularização) — Marketing Digital difícil lote 2: as perguntas ativas v2#2 a v2#25 do seed dificil_v2 (migration 050) e a 1.ª do dificil_v3 (migration 059).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono: a resposta CERTA NÃO muda; só o texto das alternativas
-- ERRADAS é ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital difícil usa a faixa de migrations 520+ (reservada no PENDENTE.md).
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
    ('seed_marketing_digital_dificil_v2', 'Por que comparar LTV e CAC pode ser útil?', 0, 'Para determinar o tamanho do logotipo', 'Para determinar a relação entre alcance potencial do anúncio e custo de produção'),
    ('seed_marketing_digital_dificil_v2', 'Por que comparar LTV e CAC pode ser útil?', 2, 'Para escolher uma senha', 'Para comparar a relação entre tráfego potencial do site e custo de hospedagem'),
    ('seed_marketing_digital_dificil_v2', 'Por que comparar LTV e CAC pode ser útil?', 3, 'Para calcular o número de funcionários', 'Para medir a relação entre número de funcionários e custo de treinamento'),
    ('seed_marketing_digital_dificil_v2', 'Por que a atribuição pode ser complexa?', 0, 'Porque clientes utilizam apenas um canal', 'Porque um cliente pode ficar em um único canal depois de converter'),
    ('seed_marketing_digital_dificil_v2', 'Por que a atribuição pode ser complexa?', 2, 'Porque campanhas nunca possuem dados', 'Porque um canal pode ter vários orçamentos antes de investir'),
    ('seed_marketing_digital_dificil_v2', 'Por que a atribuição pode ser complexa?', 3, 'Porque conversões não podem ser medidas', 'Porque um relatório pode ter vários formatos antes de exportar'),
    ('seed_marketing_digital_dificil_v2', 'O que é modelo de atribuição de último clique?', 0, 'Modelo que ignora todos os cliques', 'Modelo que atribui a conversão principalmente ao primeiro ponto de contato considerado'),
    ('seed_marketing_digital_dificil_v2', 'O que é modelo de atribuição de último clique?', 1, 'Modelo que considera apenas o primeiro anúncio', 'Modelo que divide a conversão proporcionalmente entre os pontos de contato considerados'),
    ('seed_marketing_digital_dificil_v2', 'O que é modelo de atribuição de último clique?', 2, 'Modelo que divide igualmente todas as conversões', 'Modelo que atribui a conversão principalmente ao ponto de contato mais caro considerado'),
    ('seed_marketing_digital_dificil_v2', 'O que é funil de marketing?', 1, 'Ferramenta de edição', 'Modelo que representa canais pelos quais anúncios podem passar desde planejamento até veiculação, medição e relatório'),
    ('seed_marketing_digital_dificil_v2', 'O que é funil de marketing?', 2, 'Sistema de estoque', 'Modelo que representa tarefas pelas quais equipes podem passar desde contratação até entrega, cobrança e faturamento'),
    ('seed_marketing_digital_dificil_v2', 'O que é funil de marketing?', 3, 'Sistema bancário', 'Modelo que representa etapas pelas quais produtos podem passar desde produção até estoque, transporte e distribuição'),
    ('seed_marketing_digital_dificil_v2', 'Por que analisar cada etapa do funil?', 0, 'Para remover clientes antigos', 'Para identificar onde potenciais anúncios estão perdendo o orçamento'),
    ('seed_marketing_digital_dificil_v2', 'Por que analisar cada etapa do funil?', 1, 'Para impedir vendas', 'Para identificar onde potenciais fornecedores estão aumentando o preço'),
    ('seed_marketing_digital_dificil_v2', 'Por que analisar cada etapa do funil?', 3, 'Para eliminar campanhas', 'Para identificar onde potenciais funcionários estão deixando a empresa'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 0, 'Apenas o salário da equipe', 'Estoque do produto, prazo de entrega, embalagem e frete'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 1, 'Apenas o estoque físico', 'Cadastro da empresa, endereço do escritório, telefone e logotipo'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio recebe muitas visualizações, mas poucos cliques. O que pode ser investigado primeiro?', 3, 'Apenas o endereço da empresa', 'Velocidade do servidor, formato do arquivo, domínio e certificado'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 0, 'O produto necessariamente é gratuito', 'Pode existir problema no alcance, número de impressões, orçamento ou horário de veiculação'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 2, 'A campanha deve ser encerrada sem análise', 'Pode existir problema no logotipo, cor do anúncio, fonte ou tamanho da imagem de divulgação'),
    ('seed_marketing_digital_dificil_v2', 'Um anúncio possui muitos cliques, mas poucas conversões. Qual hipótese merece investigação?', 3, 'O anúncio necessariamente é perfeito', 'Pode existir problema nas impressões, taxa de cliques, posição do anúncio ou dispositivo do usuário'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de abandono?', 0, 'Número de seguidores novos', 'Percentual de usuários que concluem determinado processo, mas não voltam a comprar'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de abandono?', 1, 'Total de comentários', 'Percentual de usuários que visualizam determinado anúncio, mas não o clicam'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de abandono?', 2, 'Valor investido em publicidade', 'Percentual de usuários que abrem determinado email, mas não o respondem'),
    ('seed_marketing_digital_dificil_v2', 'O que é segmentação comportamental?', 0, 'Segmentação baseada exclusivamente no nome', 'Segmentação baseada em características demográficas ou localização geográfica relevantes'),
    ('seed_marketing_digital_dificil_v2', 'O que é segmentação comportamental?', 1, 'Segmentação apenas por cor favorita', 'Segmentação baseada em idade ou rendimento declarados em cadastros relevantes'),
    ('seed_marketing_digital_dificil_v2', 'O que é segmentação comportamental?', 2, 'Segmentação sem qualquer critério', 'Segmentação baseada em preferências ou respostas fornecidas em pesquisas relevantes'),
    ('seed_marketing_digital_dificil_v2', 'Qual é um risco de segmentar excessivamente uma campanha?', 1, 'A campanha sempre ficará mais barata', 'O público pode ficar grande demais e limitar orçamento ou prazos para publicação'),
    ('seed_marketing_digital_dificil_v2', 'Qual é um risco de segmentar excessivamente uma campanha?', 2, 'O anúncio será exibido para todos', 'O público pode ficar parecido demais e limitar criativos ou formatos para divulgação'),
    ('seed_marketing_digital_dificil_v2', 'Qual é um risco de segmentar excessivamente uma campanha?', 3, 'As conversões serão garantidas', 'O público pode ficar distante demais e limitar contas ou perfis para configuração'),
    ('seed_marketing_digital_dificil_v2', 'O que é canibalização entre campanhas?', 1, 'Aumento automático das vendas', 'Situação em que campanhas ou estratégias acabam repetindo parcialmente o mesmo orçamento ou formato'),
    ('seed_marketing_digital_dificil_v2', 'O que é canibalização entre campanhas?', 2, 'Redução dos custos de produção', 'Situação em que concorrentes ou parceiros acabam competindo diretamente pelo mesmo espaço ou preço'),
    ('seed_marketing_digital_dificil_v2', 'O que é canibalização entre campanhas?', 3, 'Exclusão de concorrentes', 'Situação em que produtos ou serviços acabam substituindo completamente o mesmo cliente ou contrato'),
    ('seed_marketing_digital_dificil_v2', 'O que significa saturação de audiência?', 1, 'Aumento da qualidade do produto', 'Situação em que o mesmo público recebe pouca exposição a uma comunicação'),
    ('seed_marketing_digital_dificil_v2', 'O que significa saturação de audiência?', 2, 'Ausência total de publicidade', 'Situação em que o mesmo anúncio recebe verba excessiva em uma plataforma'),
    ('seed_marketing_digital_dificil_v2', 'O que significa saturação de audiência?', 3, 'Crescimento automático do mercado', 'Situação em que o mesmo mercado recebe concorrência excessiva de uma categoria'),
    ('seed_marketing_digital_dificil_v2', 'Por que a frequência de exposição deve ser monitorada em campanhas?', 0, 'Porque anúncios devem aparecer infinitamente', 'Exposição reduzida pode causar fadiga e reduzir a eficiência da comunicação'),
    ('seed_marketing_digital_dificil_v2', 'Por que a frequência de exposição deve ser monitorada em campanhas?', 1, 'Porque frequência não pode ser medida', 'Exposição excessiva pode causar economia e reduzir o custo da comunicação'),
    ('seed_marketing_digital_dificil_v2', 'Por que a frequência de exposição deve ser monitorada em campanhas?', 3, 'Porque toda exposição adicional sempre aumenta conversões', 'Exposição adicional pode garantir conversões e aumentar a eficiência da comunicação'),
    ('seed_marketing_digital_dificil_v2', 'O que é fadiga criativa?', 0, 'Aumento permanente das conversões', 'Aumento do desempenho de um criativo após exposição repetida ou ganho de novidade'),
    ('seed_marketing_digital_dificil_v2', 'O que é fadiga criativa?', 1, 'Falha de conexão do servidor', 'Redução do orçamento de um criativo após aprovação inicial ou perda de verba'),
    ('seed_marketing_digital_dificil_v2', 'O que é fadiga criativa?', 2, 'Problema bancário', 'Redução da equipe de criação após entregas repetidas ou perda de um contrato'),
    ('seed_marketing_digital_dificil_v2', 'O que é marketing de conteúdo baseado em intenção?', 0, 'Produção aleatória', 'Produção de conteúdo alinhado ao que a empresa vende ou pretende divulgar'),
    ('seed_marketing_digital_dificil_v2', 'O que é marketing de conteúdo baseado em intenção?', 2, 'Publicidade sem objetivo', 'Produção de conteúdo alinhado ao que o concorrente publica ou pretende copiar'),
    ('seed_marketing_digital_dificil_v2', 'O que é marketing de conteúdo baseado em intenção?', 3, 'Conteúdo criado apenas para funcionários', 'Produção de conteúdo alinhado ao que o algoritmo premia ou pretende priorizar'),
    ('seed_marketing_digital_dificil_v2', 'Por que a intenção de busca é importante no SEO?', 0, 'Elimina a necessidade de conteúdo', 'Ajuda a escolher o domínio mais parecido com aquilo que o usuário digita'),
    ('seed_marketing_digital_dificil_v2', 'Por que a intenção de busca é importante no SEO?', 1, 'Garante primeira posição', 'Ajuda a copiar o conteúdo mais parecido com aquilo que o concorrente publica'),
    ('seed_marketing_digital_dificil_v2', 'Por que a intenção de busca é importante no SEO?', 3, 'Impede concorrentes', 'Ajuda a pagar o anúncio mais parecido com aquilo que o anunciante oferece'),
    ('seed_marketing_digital_dificil_v2', 'O que é palavra-chave de cauda longa?', 0, 'Palavra usada apenas em anúncios impressos', 'Consulta de busca geralmente mais genérica e composta por uma ou duas palavras'),
    ('seed_marketing_digital_dificil_v2', 'O que é palavra-chave de cauda longa?', 2, 'Palavra com muitas letras obrigatoriamente', 'Consulta de busca geralmente mais antiga e composta por palavras com muitas letras'),
    ('seed_marketing_digital_dificil_v2', 'O que é palavra-chave de cauda longa?', 3, 'Nome de uma rede social', 'Consulta de busca geralmente mais cara e composta por termos de marcas conhecidas'),
    ('seed_marketing_digital_dificil_v2', 'Por que palavras-chave de cauda longa podem ser úteis?', 1, 'Garantem vendas', 'Podem apresentar volume mais elevado e, em alguns contextos, maior concorrência'),
    ('seed_marketing_digital_dificil_v2', 'Por que palavras-chave de cauda longa podem ser úteis?', 2, 'Sempre possuem milhões de pesquisas', 'Podem apresentar intenção mais genérica e, em alguns contextos, menor relevância'),
    ('seed_marketing_digital_dificil_v2', 'Por que palavras-chave de cauda longa podem ser úteis?', 3, 'Não precisam de conteúdo relevante', 'Podem apresentar custo mais baixo e, em alguns contextos, menor necessidade de conteúdo'),
    ('seed_marketing_digital_dificil_v2', 'O que é autoridade de domínio em termos gerais de SEO?', 1, 'Número de funcionários', 'Conceito usado para representar o valor ou preço negociado de um domínio, embora diferentes registradores utilizem tabelas próprias'),
    ('seed_marketing_digital_dificil_v2', 'O que é autoridade de domínio em termos gerais de SEO?', 2, 'Senha do domínio', 'Conceito usado para representar a idade ou data de registo de um domínio, embora diferentes servidores utilizem formatos próprios'),
    ('seed_marketing_digital_dificil_v2', 'O que é autoridade de domínio em termos gerais de SEO?', 3, 'Valor do domínio no banco', 'Conceito usado para representar a velocidade ou desempenho técnico de um domínio, embora diferentes provedores utilizem medidas próprias'),
    ('seed_marketing_digital_dificil_v2', 'Por que links relevantes de outros sites podem ser importantes para SEO?', 0, 'Aumentam automaticamente o salário', 'Podem funcionar como sinais de velocidade ou carregamento, dependendo do tamanho e formato'),
    ('seed_marketing_digital_dificil_v2', 'Por que links relevantes de outros sites podem ser importantes para SEO?', 1, 'Eliminam todo conteúdo', 'Podem funcionar como sinais de segurança ou privacidade, dependendo da senha e certificado'),
    ('seed_marketing_digital_dificil_v2', 'Por que links relevantes de outros sites podem ser importantes para SEO?', 3, 'Garantem primeira posição', 'Podem funcionar como sinais de popularidade ou volume, dependendo da frequência e horário'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de engajamento?', 1, 'Custo de produção', 'Métrica que relaciona custos com alguma base de produção ou vendas, conforme o cálculo utilizado'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de engajamento?', 2, 'Número de funcionários', 'Métrica que relaciona conversões com alguma base de visitas ou cliques, conforme a ferramenta utilizada'),
    ('seed_marketing_digital_dificil_v2', 'O que é taxa de engajamento?', 3, 'Valor total das vendas', 'Métrica que relaciona receita com alguma base de investimento ou orçamento, conforme o modelo utilizado'),
    ('seed_marketing_digital_dificil_v2', 'Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 0, 'Porque qualquer número significa a mesma coisa', 'Porque diferentes fórmulas e bases podem produzir resultados idênticos'),
    ('seed_marketing_digital_dificil_v2', 'Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 1, 'Porque métricas não precisam de contexto', 'Porque diferentes nomes e unidades podem produzir resultados idênticos'),
    ('seed_marketing_digital_dificil_v2', 'Por que é importante conhecer a fórmula usada para calcular uma métrica de marketing?', 3, 'Porque todas as métricas possuem sempre a mesma fórmula', 'Porque diferentes equipes e cargos podem produzir resultados diferentes'),
    ('seed_marketing_digital_dificil_v2', 'Por que correlação não significa necessariamente causalidade em marketing?', 0, 'Porque campanhas não possuem resultados', 'Porque duas variáveis podem variar separadas sem que uma seja medida corretamente pela outra'),
    ('seed_marketing_digital_dificil_v2', 'Por que correlação não significa necessariamente causalidade em marketing?', 1, 'Porque dados nunca podem ser analisados', 'Porque duas campanhas podem variar juntas sem que uma tenha orçamento próprio definido pela outra'),
    ('seed_marketing_digital_dificil_v2', 'Por que correlação não significa necessariamente causalidade em marketing?', 2, 'Porque toda relação é causal', 'Porque duas métricas podem variar juntas sem que uma seja registrada no mesmo relatório da outra'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o principal objetivo de uma estratégia de Growth Marketing?', 0, 'Apenas criar publicações nas redes sociais', 'Criar publicações constantes nas redes sociais usando criatividade e frequência'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o principal objetivo de uma estratégia de Growth Marketing?', 1, 'Fazer somente anúncios tradicionais', 'Contratar anúncios tradicionais em vários meios usando orçamento e alcance'),
    ('seed_marketing_digital_dificil_v3', 'Qual é o principal objetivo de uma estratégia de Growth Marketing?', 2, 'Aumentar seguidores sem analisar resultados', 'Aumentar seguidores rapidamente nas plataformas usando promoções e sorteios')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital difícil lote 2: as perguntas ativas v2#2 a v2#25 do seed dificil_v2 (migration 050) e a 1.ª do dificil_v3 (migration 059): % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
