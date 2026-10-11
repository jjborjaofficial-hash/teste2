-- Explicações pedagógicas (BE-004) — Marketing Digital difícil lote 4: as perguntas ativas v3#27 a v3#44 do seed dificil_v3 (migration 059) e as 12 do dificil_v4 (migration 063).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e relação entre conceitos, nível difícil, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 526. Só atualiza perguntas
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
    ('seed_marketing_digital_dificil_v3', 'O que é teste multivariado?', 'O teste multivariado testa várias combinações de elementos, como título, imagem e botão, ao mesmo tempo, para descobrir qual combinação tem melhor desempenho. Difere do teste A/B, que compara só duas versões. Não é testar públicos, plataformas nem uma única versão.'),
    ('seed_marketing_digital_dificil_v3', 'O que é personalização baseada em IA?', 'A personalização baseada em IA usa inteligência artificial para adaptar experiências ao usuário, aprendendo com o comportamento dele. Regras manuais, automação simples ou segmentação básica não aprendem sozinhas nem se ajustam a cada pessoa.'),
    ('seed_marketing_digital_dificil_v3', 'O que é análise preditiva no marketing?', 'A análise preditiva usa dados para prever comportamentos futuros dos consumidores, como quem provavelmente vai comprar. É diferente de resumir o passado, pesquisar opiniões atuais ou comparar resultados antigos.'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia omnichannel?', 'A estratégia omnichannel integra vários canais para oferecer uma experiência consistente ao cliente, que muda de canal sem perder o contexto. Excluir canais, separá-los ou apenas ampliar canais pagos não gera essa consistência.'),
    ('seed_marketing_digital_dificil_v3', 'O que é Customer Experience (CX)?', 'Customer Experience (CX) é a experiência completa do cliente com a marca, em todos os contatos, e não só o preço, o atendimento ou o número de contatos. É a soma de todas as interações, antes e depois da compra.'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia de reativação?', 'A estratégia de reativação reúne ações para recuperar clientes inativos, que já compraram e pararam. É diferente de remover esses clientes, atrair novos ou fidelizar quem já está ativo.'),
    ('seed_marketing_digital_dificil_v3', 'O que é marketing viral planejado?', 'O marketing viral planejado é uma estratégia criada para estimular compartilhamentos e alcance orgânico, com conteúdo que as pessoas queiram passar adiante. Comprar seguidores, disparar mensagens ou pagar influenciadores não é viralização.'),
    ('seed_marketing_digital_dificil_v3', 'O que é autoridade digital?', 'Autoridade digital é o nível de confiança e reconhecimento de uma marca online. Cresce com reputação e conteúdo útil, e não com investimento, seguidores ou faturamento, que são outros indicadores.'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de comunidade?', 'Uma estratégia de comunidade constrói relacionamento contínuo com usuários em torno da marca, com interação e valor ao longo do tempo. Campanhas pontuais, vendas de produtos ou apenas aumentar seguidores não criam comunidade.'),
    ('seed_marketing_digital_dificil_v3', 'O que é social listening?', 'O social listening é o monitoramento de conversas e opiniões sobre uma marca na internet, para entender a percepção e identificar oportunidades ou crises. Publicar, medir cliques ou moderar comentários são tarefas diferentes.'),
    ('seed_marketing_digital_dificil_v3', 'O que é estratégia de conteúdo baseada em dados?', 'Uma estratégia de conteúdo baseada em dados cria conteúdos usando informações sobre desempenho e público, em vez de intuição, modelos prontos ou calendários fixos. Os dados mostram o que funciona e para quem.'),
    ('seed_marketing_digital_dificil_v3', 'O que é escalabilidade em Marketing Digital?', 'Escalabilidade em marketing é a capacidade de aumentar resultados mantendo a eficiência: crescer sem que o custo por resultado dispare. Aumentar o investimento, reduzir custos ou ampliar canais não garante isso.'),
    ('seed_marketing_digital_dificil_v3', 'O que é um MVP em uma estratégia digital?', 'O MVP é a versão inicial de uma solução, usada para testar uma ideia com o mínimo de esforço e aprender com os usuários. Não é a versão final ou completa, nem um plano de negócios.'),
    ('seed_marketing_digital_dificil_v3', 'O que é validação de mercado?', 'A validação de mercado testa se existe interesse real por uma solução antes de investir muito nela. Calcular orçamento, comparar soluções ou definir o preço não prova que haja procura.'),
    ('seed_marketing_digital_dificil_v3', 'O que é experimentação contínua?', 'A experimentação contínua é a realização constante de testes para melhorar resultados, aprendendo com cada um. Testes ocasionais, repetir ações ou apenas registrar dados não geram melhoria contínua.'),
    ('seed_marketing_digital_dificil_v3', 'O que é uma estratégia data-driven?', 'Uma estratégia data-driven toma decisões com base em dados, e não em opiniões, tradição ou intuição. Isso permite medir, comparar e ajustar o que foi feito.'),
    ('seed_marketing_digital_dificil_v3', 'Qual é a importância da análise de dados no Marketing Digital avançado?', 'A análise de dados no marketing avançado permite otimizar investimentos e melhorar resultados, ao mostrar o que funciona. Não reduz o planejamento, não padroniza resultados e não substitui produtos.'),
    ('seed_marketing_digital_dificil_v3', 'Qual é um dos maiores objetivos do Marketing Digital moderno?', 'Um grande objetivo do marketing moderno é criar crescimento sustentável através de dados, relacionamento e tecnologia, porque resultados que se repetem pedem mais do que promoções, curtidas ou volume de anúncios.'),
    ('seed_marketing_digital_dificil_v4', 'O que é Marketing baseado em contas (ABM)?', 'O ABM, marketing baseado em contas, é uma estratégia focada em empresas ou clientes específicos de alto valor, tratados como mercados individuais. É o oposto de mirar mercados amplos de baixo custo.'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição linear em marketing?', 'Na atribuição linear, o crédito da conversão é distribuído igualmente entre os vários pontos de contato. Difere do primeiro ou do último clique, que dão todo o crédito a um ponto, e da atribuição baseada em posição.'),
    ('seed_marketing_digital_dificil_v4', 'O que é uma métrica North Star?', 'A métrica North Star é o indicador principal que representa o valor entregue ao cliente, e orienta toda a equipe. Não é um indicador secundário, visual ou de lucro dos sócios.'),
    ('seed_marketing_digital_dificil_v4', 'O que é análise de coorte?', 'A análise de coorte estuda grupos de usuários com características ou períodos semelhantes, como quem se cadastrou no mesmo mês, para ver como se comportam ao longo do tempo. Não compara preços nem remove usuários.'),
    ('seed_marketing_digital_dificil_v4', 'O que é um mapa de calor (Heatmap)?', 'O mapa de calor, ou heatmap, é uma ferramenta que mostra como usuários interagem com uma página, por exemplo onde clicam ou até onde rolam. Não conta visitas, nem localiza acessos, nem registra o momento da compra.'),
    ('seed_marketing_digital_dificil_v4', 'O que é intenção de busca no SEO?', 'A intenção de busca é o motivo pelo qual uma pessoa realiza determinada pesquisa, como comprar, aprender ou comparar. Não é o local, o aparelho nem o resultado encontrado.'),
    ('seed_marketing_digital_dificil_v4', 'O que é SEO semântico?', 'O SEO semântico otimiza conteúdos considerando o significado e o contexto das pesquisas, e não apenas as palavras exatas. Repetir palavras-chave, comprar anúncios ou remover textos não é SEO semântico.'),
    ('seed_marketing_digital_dificil_v4', 'O que é cannibalização de palavras-chave?', 'A canibalização de palavras-chave acontece quando várias páginas do mesmo site competem pela mesma palavra-chave e se prejudicam. Concorrência entre sites diferentes é concorrência comum, e repetir palavras no texto não é canibalização.'),
    ('seed_marketing_digital_dificil_v4', 'O que é atribuição baseada em posição?', 'Na atribuição baseada em posição, o maior peso vai para os primeiros e últimos contatos da jornada, os que iniciam e fecham a conversão. É diferente da linear, que dá a mesma importância a todos, e de dar mais peso a contatos caros ou presenciais.'),
    ('seed_marketing_digital_dificil_v4', 'O que é personalização preditiva?', 'A personalização preditiva usa dados e inteligência artificial para antecipar necessidades do usuário, em vez de reagir só ao que ele já fez. Regras fixas, pesquisas ou promoções não antecipam necessidades.'),
    ('seed_marketing_digital_dificil_v4', 'O que é experimentação de crescimento?', 'A experimentação de crescimento é um processo contínuo de testar hipóteses para encontrar oportunidades de crescimento, medindo e repetindo o que funciona. Testar produtos de forma pontual ou copiar tendências não é isso.'),
    ('seed_marketing_digital_dificil_v4', 'O que é marketing orientado por dados?', 'O marketing orientado por dados toma decisões com base em informações e análises reais, em vez de opiniões, experiências pessoais, modelos populares ou intuição. Isso reduz o erro e permite aprender com os resultados.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital difícil lote 4: as perguntas ativas v3#27 a v3#44 do seed dificil_v3 (migration 059) e as 12 do dificil_v4 (migration 063): % pergunta(s) atualizada(s) (esperado: 30).', v_updated;
END $$;
