-- Alternativas (BE-003, regularização) — Marketing Digital médio lote 2: 25 perguntas ativas ainda sem explicação, de v1#27 a v2#22 (seeds 038 e 049).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital usa a faixa de migrations 500+
-- para não colidir com as outras categorias (Finanças 144+, Produtividade 200+, Tecnologia 300+, IA 400+).
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
    ('seed_marketing_digital_medio_v1', 'O que é calendário editorial?', 0, 'Lista de clientes inadimplentes', 'Registro organizado dos gastos que serão aprovados e pagos em cada mês'),
    ('seed_marketing_digital_medio_v1', 'O que é calendário editorial?', 1, 'Calendário bancário', 'Calendário de feriados e datas comemorativas usado para fechar o escritório'),
    ('seed_marketing_digital_medio_v1', 'O que é calendário editorial?', 3, 'Lista de salários', 'Lista organizada dos contatos que serão chamados e atendidos pela equipe'),
    ('seed_marketing_digital_medio_v1', 'Qual é uma vantagem de um calendário editorial?', 0, 'Garante milhões de seguidores', 'Ajuda a organizar preços, descontos, prazos e condições de pagamento'),
    ('seed_marketing_digital_medio_v1', 'Qual é uma vantagem de um calendário editorial?', 2, 'Elimina a necessidade de criatividade', 'Ajuda a organizar cargos, horários, salários e escalas de trabalho'),
    ('seed_marketing_digital_medio_v1', 'Qual é uma vantagem de um calendário editorial?', 3, 'Garante vendas', 'Ajuda a organizar fornecedores, estoques, entregas e prazos de compra'),
    ('seed_marketing_digital_medio_v1', 'O que é nutrição de leads?', 1, 'Alimentação física dos clientes', 'Processo de manter contato com clientes antigos por meio de descontos e cobranças periódicas'),
    ('seed_marketing_digital_medio_v1', 'O que é nutrição de leads?', 2, 'Criação de anúncios sem público', 'Processo de criar anúncios para pessoas desconhecidas por meio de orçamentos e metas diárias'),
    ('seed_marketing_digital_medio_v1', 'O que é nutrição de leads?', 3, 'Exclusão de contatos', 'Processo de atualizar a lista de contatos por meio de exclusões e verificações de cadastro'),
    ('seed_marketing_digital_medio_v2', 'O que é uma persona de marketing?', 0, 'Qualquer funcionário da empresa', 'Representação visual da marca criada com base em cores, formas e símbolos distintivos'),
    ('seed_marketing_digital_medio_v2', 'O que é uma persona de marketing?', 1, 'Um concorrente', 'Descrição detalhada de um concorrente direto baseada em preços e estratégias comerciais'),
    ('seed_marketing_digital_medio_v2', 'O que é uma persona de marketing?', 3, 'Um anúncio pago', 'Resumo de um anúncio pago baseado em orçamento, alcance e resultados esperados'),
    ('seed_marketing_digital_medio_v2', 'Por que uma empresa deve conhecer os problemas do seu público?', 0, 'Para eliminar comentários', 'Para reduzir o número de mensagens recebidas diariamente'),
    ('seed_marketing_digital_medio_v2', 'Por que uma empresa deve conhecer os problemas do seu público?', 1, 'Para evitar criar produtos', 'Para evitar mudanças nos produtos já vendidos hoje'),
    ('seed_marketing_digital_medio_v2', 'Por que uma empresa deve conhecer os problemas do seu público?', 3, 'Para aumentar impostos', 'Para aumentar o preço das ofertas mais procuradas'),
    ('seed_marketing_digital_medio_v2', 'O que é posicionamento de marca?', 0, 'Número de funcionários', 'Forma como uma marca organiza os departamentos e as equipes responsáveis pelas vendas'),
    ('seed_marketing_digital_medio_v2', 'O que é posicionamento de marca?', 2, 'Apenas localização física da empresa', 'Lugar onde uma marca instala as lojas e os escritórios em relação aos concorrentes'),
    ('seed_marketing_digital_medio_v2', 'O que é posicionamento de marca?', 3, 'Quantidade de produtos no estoque', 'Quantidade de produtos que uma marca mantém disponíveis em relação à procura do público'),
    ('seed_marketing_digital_medio_v2', 'O que é proposta de valor?', 0, 'Um documento fiscal', 'Descrição do prazo ou da garantia que uma loja pretende cumprir em cada entrega'),
    ('seed_marketing_digital_medio_v2', 'O que é proposta de valor?', 1, 'Apenas o preço de um produto', 'Indicação do preço ou do desconto que uma empresa pretende aplicar a cada produto'),
    ('seed_marketing_digital_medio_v2', 'O que é proposta de valor?', 2, 'Uma lista de funcionários', 'Relação dos cargos ou das funções que uma equipe pretende ocupar em cada projeto'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de produzir conteúdo educativo?', 0, 'Impede críticas', 'Pode reduzir a visibilidade da marca nas buscas online'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de produzir conteúdo educativo?', 2, 'Elimina todos os concorrentes', 'Pode aumentar o preço cobrado por produtos populares'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de produzir conteúdo educativo?', 3, 'Garante vendas instantâneas', 'Pode dispensar o acompanhamento dos resultados da campanha'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de entretenimento?', 0, 'Formulário de pagamento', 'Conteúdo desenvolvido principalmente para registrar pagamentos de maneira rápida e segura nas lojas'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de entretenimento?', 1, 'Documento financeiro', 'Conteúdo desenvolvido principalmente para apresentar contas e balanços de maneira técnica e detalhada'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de entretenimento?', 2, 'Contrato comercial', 'Conteúdo desenvolvido principalmente para formalizar acordos e obrigações de maneira jurídica e precisa'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de prova social?', 0, 'Apenas propaganda institucional', 'Conteúdo que demonstra preços, descontos ou condições de pagamento da loja'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de prova social?', 1, 'Conteúdo sem relação com consumidores', 'Conteúdo que demonstra bastidores, processos ou rotinas internas da equipe'),
    ('seed_marketing_digital_medio_v2', 'O que é conteúdo de prova social?', 2, 'Um relatório bancário', 'Conteúdo que demonstra metas, orçamentos ou previsões financeiras da empresa'),
    ('seed_marketing_digital_medio_v2', 'O que é taxa de cliques?', 1, 'Valor total das vendas', 'Percentual de pessoas que compram determinado produto após visitá-lo'),
    ('seed_marketing_digital_medio_v2', 'O que é taxa de cliques?', 2, 'Número de funcionários', 'Percentual de pessoas que abandonam determinada página após abri-la'),
    ('seed_marketing_digital_medio_v2', 'O que é taxa de cliques?', 3, 'Quantidade de produtos', 'Percentual de pessoas que seguem determinado perfil após conhecê-lo'),
    ('seed_marketing_digital_medio_v2', 'Por que a taxa de cliques pode ser importante?', 0, 'Garante conversão', 'Ajuda a medir se um produto ou serviço está gerando lucro líquido'),
    ('seed_marketing_digital_medio_v2', 'Por que a taxa de cliques pode ser importante?', 2, 'Mede apenas o lucro', 'Ajuda a verificar se um estoque ou armazém está recebendo pedidos'),
    ('seed_marketing_digital_medio_v2', 'Por que a taxa de cliques pode ser importante?', 3, 'Mede diretamente a qualidade do produto', 'Ajuda a confirmar se uma venda ou pagamento está sendo processado'),
    ('seed_marketing_digital_medio_v2', 'O que significa conversão em uma campanha?', 0, 'Exclusivamente curtida', 'Reação positiva dos usuários ao conteúdo da campanha'),
    ('seed_marketing_digital_medio_v2', 'O que significa conversão em uma campanha?', 2, 'Apenas visualização de um anúncio', 'Exibição do anúncio para o público definido na campanha'),
    ('seed_marketing_digital_medio_v2', 'O que significa conversão em uma campanha?', 3, 'Apenas abertura de uma página', 'Abertura da página inicial indicada no anúncio da campanha'),
    ('seed_marketing_digital_medio_v2', 'O que é custo por clique?', 1, 'Salário de um funcionário', 'Valor médio recebido por cada venda concluída em uma campanha'),
    ('seed_marketing_digital_medio_v2', 'O que é custo por clique?', 2, 'Valor total de todos os produtos', 'Custo total das impressões de um anúncio em determinado período'),
    ('seed_marketing_digital_medio_v2', 'O que é custo por clique?', 3, 'Preço de venda do produto', 'Preço médio cobrado por cada seguidor adquirido na campanha'),
    ('seed_marketing_digital_medio_v2', 'O que significa alcance orgânico?', 1, 'Número de funcionários', 'Pessoas alcançadas por meio de anúncios pagos direcionados para aquela distribuição'),
    ('seed_marketing_digital_medio_v2', 'O que significa alcance orgânico?', 2, 'Pessoas que compraram o produto', 'Pessoas que realizaram compras após receber desconto direto para aquela distribuição'),
    ('seed_marketing_digital_medio_v2', 'O que significa alcance orgânico?', 3, 'Pessoas alcançadas somente por anúncios pagos', 'Pessoas alcançadas por parceiros pagos para divulgar a marca nesse período'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de combinar tráfego orgânico e pago?', 0, 'Impede concorrência', 'Permite reduzir custos de produção enquanto promoções frequentes podem esgotar o estoque mais rapidamente'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de combinar tráfego orgânico e pago?', 1, 'Garante lucro em qualquer campanha', 'Permite concentrar vendas em um só canal enquanto campanhas pagas podem reduzir o alcance mais rapidamente'),
    ('seed_marketing_digital_medio_v2', 'Qual é uma vantagem de combinar tráfego orgânico e pago?', 2, 'Elimina a necessidade de conteúdo', 'Permite evitar o uso de anúncios enquanto conteúdos orgânicos podem substituir a equipe mais rapidamente'),
    ('seed_marketing_digital_medio_v2', 'Por que analisar o desempenho de uma publicação?', 0, 'Para apagar automaticamente o conteúdo', 'Para decidir quais seguidores devem ser removidos da página'),
    ('seed_marketing_digital_medio_v2', 'Por que analisar o desempenho de uma publicação?', 1, 'Para eliminar seguidores', 'Para comparar o salário da equipe com o de concorrentes'),
    ('seed_marketing_digital_medio_v2', 'Por que analisar o desempenho de uma publicação?', 2, 'Para garantir viralização', 'Para registrar quantas vezes a página foi apagada ou editada'),
    ('seed_marketing_digital_medio_v2', 'Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 1, 'Para garantir que ambas as versões sejam idênticas', 'Para assegurar que as duas versões tenham o mesmo custo de produção e de divulgação'),
    ('seed_marketing_digital_medio_v2', 'Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 2, 'Para aumentar custos', 'Para aumentar o número de versões testadas ao mesmo tempo e comparar vários públicos'),
    ('seed_marketing_digital_medio_v2', 'Em um teste A/B, por que é importante alterar uma variável relevante de cada vez quando possível?', 3, 'Para eliminar os dados', 'Para reduzir o tempo de preparação do teste e dispensar a análise dos resultados'),
    ('seed_marketing_digital_medio_v2', 'Por que clientes recorrentes podem ser importantes?', 0, 'Nunca fazem novas compras', 'Podem gerar custos contínuos e aumentar a dependência de descontos constantes para novos clientes'),
    ('seed_marketing_digital_medio_v2', 'Por que clientes recorrentes podem ser importantes?', 2, 'Não interagem com a marca', 'Podem gerar reclamações contínuas e reduzir a necessidade de atendimento aos clientes atuais'),
    ('seed_marketing_digital_medio_v2', 'Por que clientes recorrentes podem ser importantes?', 3, 'Sempre exigem produtos gratuitos', 'Podem gerar receita pontual e aumentar a dependência de campanhas pagas de curta duração'),
    ('seed_marketing_digital_medio_v2', 'O que é aquisição de clientes?', 0, 'Processo de pagar impostos', 'Processo de atender e fidelizar clientes antigos'),
    ('seed_marketing_digital_medio_v2', 'O que é aquisição de clientes?', 1, 'Processo de cancelar anúncios', 'Processo de definir e ajustar preços de produtos'),
    ('seed_marketing_digital_medio_v2', 'O que é aquisição de clientes?', 2, 'Processo de excluir clientes', 'Processo de registrar e arquivar contratos de vendas'),
    ('seed_marketing_digital_medio_v2', 'O que é custo de aquisição de cliente, ou CAC?', 1, 'Salário de todos os funcionários', 'Custo médio associado à produção de um novo produto'),
    ('seed_marketing_digital_medio_v2', 'O que é custo de aquisição de cliente, ou CAC?', 2, 'Receita total da empresa', 'Receita média associada à compra de um novo cliente'),
    ('seed_marketing_digital_medio_v2', 'O que é custo de aquisição de cliente, ou CAC?', 3, 'Valor do estoque', 'Custo médio associado à manutenção de um cliente antigo'),
    ('seed_marketing_digital_medio_v2', 'O que é relacionamento com o cliente?', 0, 'Exclusivamente publicidade', 'Estratégias e campanhas utilizadas para divulgar e aumentar o alcance de produtos novos'),
    ('seed_marketing_digital_medio_v2', 'O que é relacionamento com o cliente?', 1, 'Apenas venda única', 'Procedimentos e registros utilizados para cobrar e controlar pagamentos de consumidores'),
    ('seed_marketing_digital_medio_v2', 'O que é relacionamento com o cliente?', 3, 'Apenas cobrança', 'Contratos e acordos utilizados para vender e entregar produtos a consumidores'),
    ('seed_marketing_digital_medio_v2', 'O que significa personalizar uma comunicação?', 0, 'Remover informações', 'Resumir a mensagem de acordo com o espaço ou formato disponível em cada canal'),
    ('seed_marketing_digital_medio_v2', 'O que significa personalizar uma comunicação?', 2, 'Enviar exatamente a mesma mensagem para todos', 'Repetir a mensagem em intervalos curtos para reforçar a lembrança do público'),
    ('seed_marketing_digital_medio_v2', 'O que significa personalizar uma comunicação?', 3, 'Esconder o produto', 'Traduzir a mensagem para vários idiomas independentemente do público atingido')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital médio lote 2: 25 perguntas ativas ainda sem explicação, de v1#27 a v2#22 (seeds 038 e 049): % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
