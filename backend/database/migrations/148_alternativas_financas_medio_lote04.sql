-- Alternativas (BE-003, regularização) — Finanças médio lote 4: perguntas 38 a 54 do seed 065, 1 a 3 do seed 069 e 1 a 5 do seed 100.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda;
-- só o texto das alternativas ERRADAS é ajustado para ter tamanho parecido ao da certa.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order nem perguntas. O runner já envolve o ficheiro numa transação.
-- Regra 9 do padrão: as explicações que citavam as alternativas erradas antigas são reescritas no segundo bloco,
-- também só se o texto atual ainda for exatamente o original.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_financas_medio_v2', 'O que é imposto?', 1, 'Uma venda', 'Valor pago por um cliente ao comprar um produto numa loja'),
    ('seed_financas_medio_v2', 'O que é imposto?', 2, 'Um salário', 'Valor que o governo paga aos trabalhadores do setor público'),
    ('seed_financas_medio_v2', 'O que é imposto?', 3, 'Um investimento', 'Valor que um banco cobra por manter a conta de um cliente'),
    ('seed_financas_medio_v2', 'O que é capital?', 0, 'Um cartão bancário', 'Valor máximo de crédito que o banco concede a uma pessoa ou a uma empresa por ano'),
    ('seed_financas_medio_v2', 'O que é capital?', 1, 'Uma dívida', 'Dívida contraída por uma empresa para pagar despesas de curto prazo'),
    ('seed_financas_medio_v2', 'O que é capital?', 2, 'Apenas dinheiro perdido', 'Dinheiro que uma pessoa perdeu ao investir num negócio sem sucesso'),
    ('seed_financas_medio_v2', 'O que é empreendedorismo financeiro?', 0, 'Apenas guardar dinheiro', 'Guardar dinheiro numa conta bancária para o usar no futuro'),
    ('seed_financas_medio_v2', 'O que é empreendedorismo financeiro?', 1, 'Evitar qualquer investimento', 'Evitar investimentos para não correr nenhum risco financeiro'),
    ('seed_financas_medio_v2', 'O que é empreendedorismo financeiro?', 3, 'Gastar sem planejamento', 'Gastar o dinheiro disponível em compras sem planejar o orçamento'),
    ('seed_financas_medio_v2', 'O que é preço de venda?', 0, 'Valor do salário', 'Valor pago aos trabalhadores da empresa'),
    ('seed_financas_medio_v2', 'O que é preço de venda?', 2, 'Imposto pago', 'Imposto pago ao governo pela empresa'),
    ('seed_financas_medio_v2', 'O que é preço de venda?', 3, 'Custo de produção apenas', 'Custo de produção de um produto ou serviço'),
    ('seed_financas_medio_v2', 'O que é custo de produção?', 0, 'Investimento bancário', 'Dinheiro aplicado pelo banco para render ao longo do tempo'),
    ('seed_financas_medio_v2', 'O que é custo de produção?', 1, 'Receita recebida', 'Dinheiro que a empresa recebe pela venda de produtos'),
    ('seed_financas_medio_v2', 'O que é custo de produção?', 2, 'Lucro final', 'Valor que sobra depois de pagar todas as despesas'),
    ('seed_financas_medio_v2', 'O que é ponto de equilíbrio financeiro?', 0, 'Quando não existem vendas', 'Momento em que a empresa não tem vendas nem custos'),
    ('seed_financas_medio_v2', 'O que é ponto de equilíbrio financeiro?', 2, 'Momento de maior prejuízo', 'Momento em que o prejuízo da empresa é o maior possível'),
    ('seed_financas_medio_v2', 'O que é ponto de equilíbrio financeiro?', 3, 'Quando todos os gastos aumentam', 'Momento em que todos os gastos da empresa aumentam ao mesmo tempo'),
    ('seed_financas_medio_v2', 'O que é análise de risco financeiro?', 1, 'Evitar informações', 'Escolha de investimentos sem consultar informações sobre eles'),
    ('seed_financas_medio_v2', 'O que é análise de risco financeiro?', 2, 'Gastar todo dinheiro', 'Compra de todos os ativos disponíveis para espalhar o dinheiro'),
    ('seed_financas_medio_v2', 'O que é análise de risco financeiro?', 3, 'Ignorar problemas financeiros', 'Controle do dinheiro que entra e sai da empresa em cada mês'),
    ('seed_financas_medio_v2', 'O que é carteira de investimentos?', 1, 'Lista de despesas', 'Lista dos gastos fixos e variáveis que uma pessoa tem em cada mês'),
    ('seed_financas_medio_v2', 'O que é carteira de investimentos?', 2, 'Conta bancária', 'Conta bancária usada para receber os rendimentos'),
    ('seed_financas_medio_v2', 'O que é carteira de investimentos?', 3, 'Carteira física de documentos', 'Conjunto de documentos de uma empresa em arquivo'),
    ('seed_financas_medio_v2', 'O que é um fundo de investimento?', 0, 'Um cartão bancário', 'Conta aberta num banco para guardar e emprestar o dinheiro de vários clientes'),
    ('seed_financas_medio_v2', 'O que é um fundo de investimento?', 2, 'Uma dívida pessoal', 'Dívida assumida por várias pessoas junto de uma mesma instituição'),
    ('seed_financas_medio_v2', 'O que é um fundo de investimento?', 3, 'Um salário', 'Salário pago por uma instituição a quem trabalha com investimentos'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 0, 'Compra de produtos', 'Compra regular de produtos com preço fixo todos os meses'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 1, 'Despesa mensal', 'Despesa mensal cujo valor permanece igual todos os meses'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 2, 'Investimento sem nenhuma informação', 'Investimento em que o retorno muda todos os dias conforme o mercado'),
    ('seed_financas_medio_v2', 'O que é renda variável?', 0, 'Conta mensal', 'Valor mensal pago a quem trabalha com investimentos'),
    ('seed_financas_medio_v2', 'O que é renda variável?', 1, 'Imposto', 'Imposto cobrado sobre os lucros obtidos com investimentos'),
    ('seed_financas_medio_v2', 'O que é renda variável?', 2, 'Salário fixo', 'Investimento com retorno definido antes de aplicar o dinheiro'),
    ('seed_financas_medio_v2', 'O que é análise fundamentalista?', 0, 'Escolha aleatória de investimentos', 'Escolha de investimentos seguindo o gráfico de preços do ativo'),
    ('seed_financas_medio_v2', 'O que é análise fundamentalista?', 2, 'Controle de despesas pessoais', 'Controle das despesas pessoais para saber quanto sobra'),
    ('seed_financas_medio_v2', 'O que é análise fundamentalista?', 3, 'Criação de cartões', 'Criação de cartões de crédito para clientes de um banco'),
    ('seed_financas_medio_v2', 'O que é planejamento financeiro empresarial?', 1, 'Fazer publicidade', 'Fazer campanhas de publicidade para vender mais produtos'),
    ('seed_financas_medio_v2', 'O que é planejamento financeiro empresarial?', 2, 'Criar produtos', 'Criar novos produtos para vender aos clientes da empresa'),
    ('seed_financas_medio_v2', 'O que é planejamento financeiro empresarial?', 3, 'Apenas controlar vendas', 'Controlar as vendas feitas pela empresa em cada mês'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?', 0, 'Lista de funcionários', 'Lista dos funcionários e dos salários que a empresa paga em cada mês do ano'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?', 1, 'Documento de identidade', 'Documento que identifica a empresa perante o governo'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?', 2, 'Contrato bancário', 'Contrato assinado entre a empresa e o banco para um empréstimo'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 0, 'Gastar todos os recursos', 'Gastar todos os recursos da empresa em novos investimentos'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 1, 'Criar dívidas constantes', 'Criar dívidas constantes para manter a empresa a funcionar'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 3, 'Evitar planejamento', 'Evitar o planejamento para decidir só quando surgem problemas'),
    ('seed_financas_medio_v2', 'O que é independência financeira pessoal?', 0, 'Quando depende sempre de empréstimos', 'Quando uma pessoa depende de empréstimos para pagar as despesas do mês'),
    ('seed_financas_medio_v2', 'O que é independência financeira pessoal?', 1, 'Quando não possui renda', 'Quando uma pessoa não tem rendimentos e vive das ajudas de familiares'),
    ('seed_financas_medio_v2', 'O que é independência financeira pessoal?', 3, 'Quando ignora despesas', 'Quando uma pessoa ignora as despesas e gasta o que tiver disponível'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?', 0, 'Gastar sem acompanhamento', 'Gastar sem acompanhar as despesas ao longo do mês'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?', 1, 'Evitar qualquer organização', 'Deixar a organização do dinheiro para o fim do ano'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?', 2, 'Fazer dívidas constantemente', 'Fazer dívidas constantemente para manter o padrão de vida'),
    ('seed_financas_medio_v3', 'O que é uma taxa de retorno de investimento?', 0, 'Valor da conta bancária', 'Valor que uma pessoa tem disponível na sua conta bancária num certo dia'),
    ('seed_financas_medio_v3', 'O que é uma taxa de retorno de investimento?', 2, 'Número de clientes', 'Número de investidores que aplicam numa mesma instituição'),
    ('seed_financas_medio_v3', 'O que é uma taxa de retorno de investimento?', 3, 'Quantidade de dinheiro gasto', 'Quantidade de dinheiro gasto por uma pessoa num investimento'),
    ('seed_financas_medio_v3', 'Qual é a vantagem de criar uma carteira de investimentos diversificada?', 0, 'Garantir lucro em todos os investimentos', 'Garantir lucro em todos os ativos que fazem parte da carteira'),
    ('seed_financas_medio_v3', 'Qual é a vantagem de criar uma carteira de investimentos diversificada?', 1, 'Evitar qualquer análise financeira', 'Evitar a análise financeira dos ativos que se compram'),
    ('seed_financas_medio_v3', 'Qual é a vantagem de criar uma carteira de investimentos diversificada?', 3, 'Eliminar todos os custos', 'Eliminar os custos de compra e venda dos ativos da carteira'),
    ('seed_financas_medio_v3', 'O que significa viver abaixo das próprias possibilidades financeiras?', 1, 'Gastar todo o salário', 'Gastar todo o salário no mês para aproveitar o presente'),
    ('seed_financas_medio_v3', 'O que significa viver abaixo das próprias possibilidades financeiras?', 2, 'Evitar qualquer planejamento', 'Evitar qualquer planejamento para viver com mais liberdade'),
    ('seed_financas_medio_v3', 'O que significa viver abaixo das próprias possibilidades financeiras?', 3, 'Fazer mais dívidas', 'Fazer mais dívidas para manter o mesmo estilo de vida'),
    ('seed_financas_medio_v4', 'Por que manter um bom histórico de pagamentos pode ser importante?', 0, 'Elimina automaticamente todas as dívidas', 'Faz desaparecer as dívidas antigas quando se paga em dia'),
    ('seed_financas_medio_v4', 'Por que manter um bom histórico de pagamentos pode ser importante?', 1, 'Garante isenção de impostos', 'Dá direito a uma isenção de impostos todos os anos'),
    ('seed_financas_medio_v4', 'Por que manter um bom histórico de pagamentos pode ser importante?', 3, 'Aumenta o salário automaticamente', 'Faz o salário aumentar quando se pagam as contas em dia'),
    ('seed_financas_medio_v4', 'O que é amortização de uma dívida?', 1, 'Aumento do valor total devido', 'Aumento do valor total que se deve por causa dos juros acumulados'),
    ('seed_financas_medio_v4', 'O que é amortização de uma dívida?', 2, 'Cancelamento automático da dívida', 'Cancelamento da dívida depois de pagar uma parte dos juros'),
    ('seed_financas_medio_v4', 'O que é amortização de uma dívida?', 3, 'Um tipo de imposto sobre empréstimos', 'Um imposto cobrado pelo governo sobre os empréstimos do banco'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 0, 'A fixa muda todos os meses; a variável nunca muda', 'A fixa muda todos os meses conforme o mercado; a variável permanece igual durante o contrato'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 1, 'Não existe diferença real entre elas', 'As duas permanecem iguais durante o contrato, e a diferença está só no valor da prestação'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 2, 'A variável é sempre menor que a fixa', 'A variável cobra juros menores do que a fixa e por isso compensa no longo prazo'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?', 0, 'O valor mínimo obrigatório de compra', 'O valor mínimo que tem de ser pago todos os meses na fatura'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?', 2, 'A taxa de juro cobrada mensalmente', 'A taxa de juro que o banco cobra sobre o valor em dívida'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?', 3, 'O prazo de validade do cartão', 'O prazo máximo que a pessoa tem para pagar a fatura')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças médio lote 4: perguntas 38 a 54 do seed 065, 1 a 3 do seed 069 e 1 a 5 do seed 100: % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'O que é imposto?', 'Imposto é um valor cobrado pelo governo para financiar serviços públicos, como saúde, educação e estradas. Não é uma venda, um salário nem um investimento.', 'Imposto é um valor cobrado pelo governo para financiar serviços públicos, como saúde, educação e estradas. Não é o preço de uma compra, o salário pago pelo Estado nem uma taxa de banco.'),
    ('seed_financas_medio_v2', 'O que é capital?', 'Capital são os recursos financeiros usados para iniciar ou desenvolver uma atividade, como um negócio. Não é cartão bancário, dívida nem dinheiro perdido.', 'Capital são os recursos financeiros usados para iniciar ou desenvolver uma atividade, como um negócio. Não é o limite de crédito, uma dívida de curto prazo nem dinheiro perdido num negócio.'),
    ('seed_financas_medio_v2', 'O que é empreendedorismo financeiro?', 'Empreendedorismo financeiro é criar e gerir negócios buscando gerar valor e renda. Não é só guardar dinheiro, evitar investir ou gastar sem planejamento.', 'Empreendedorismo financeiro é criar e gerir negócios buscando gerar valor e renda. Não é só guardar dinheiro, evitar investir ou gastar sem planejar.'),
    ('seed_financas_medio_v2', 'O que é preço de venda?', 'Preço de venda é o valor cobrado por um produto ou serviço. Ele deve cobrir os custos e deixar lucro. Não é salário, imposto pago nem apenas o custo de produção.', 'Preço de venda é o valor cobrado por um produto ou serviço. Ele deve cobrir os custos e deixar lucro. Não é o salário, um imposto nem apenas o custo de produção.'),
    ('seed_financas_medio_v2', 'O que é custo de produção?', 'Custo de produção são os gastos necessários para criar um produto ou serviço, como matéria-prima e mão de obra. Receita e lucro final não são custos, e investimento bancário também não.', 'Custo de produção são os gastos necessários para criar um produto ou serviço, como matéria-prima e mão de obra. O dinheiro das vendas, o lucro final e o dinheiro aplicado não são custos.'),
    ('seed_financas_medio_v2', 'O que é ponto de equilíbrio financeiro?', 'Ponto de equilíbrio é o momento em que as receitas cobrem todos os custos e despesas: nem lucro, nem prejuízo. A partir dele, cada venda a mais gera lucro.', 'Ponto de equilíbrio é o momento em que as receitas cobrem todos os custos e despesas: nem lucro, nem prejuízo. A partir dele, cada venda a mais gera lucro. Não é ficar sem vendas, o maior prejuízo nem o aumento de gastos.'),
    ('seed_financas_medio_v2', 'O que é análise de risco financeiro?', 'Análise de risco financeiro é avaliar as possibilidades de perda antes de decidir. Ajuda a escolher com mais consciência. Evitar informações, gastar tudo ou ignorar problemas é o contrário.', 'Análise de risco financeiro é avaliar as possibilidades de perda antes de decidir. Ajuda a escolher com mais consciência. Decidir sem informação, comprar tudo o que existe ou apenas controlar o fluxo de caixa não é análise de risco.'),
    ('seed_financas_medio_v2', 'O que é carteira de investimentos?', 'Carteira de investimentos é o conjunto de diferentes investimentos de uma pessoa, como ações e títulos. Não é uma lista de despesas, uma conta bancária nem uma carteira física de documentos.', 'Carteira de investimentos é o conjunto de diferentes investimentos de uma pessoa, como ações e títulos. Não é uma lista de gastos, uma conta bancária nem um arquivo de documentos.'),
    ('seed_financas_medio_v2', 'O que é um fundo de investimento?', 'Fundo de investimento reúne o dinheiro de vários investidores, e uma instituição o administra. Assim, cada um participa de uma carteira maior. Não é cartão, dívida pessoal nem salário.', 'Fundo de investimento reúne o dinheiro de vários investidores, e uma instituição o administra. Assim, cada um participa de uma carteira maior. Não é uma conta comum, uma dívida em grupo nem o salário de um gestor.'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 'Renda fixa é um investimento com regras de remuneração definidas antecipadamente, de modo que se sabe como o dinheiro vai render. Não é compra de produtos, despesa mensal nem investimento sem informação.', 'Renda fixa é um investimento com regras de remuneração definidas antecipadamente, de modo que se sabe como o dinheiro vai render. Não é compra regular de produtos nem despesa mensal; o investimento cujo retorno muda com o mercado é a renda variável.'),
    ('seed_financas_medio_v2', 'O que é renda variável?', 'Renda variável é o investimento cujo retorno pode mudar conforme o mercado, como as ações. Pode render mais ou menos do que o esperado. Não é conta mensal, imposto nem salário fixo.', 'Renda variável é o investimento cujo retorno pode mudar conforme o mercado, como as ações. Pode render mais ou menos do que o esperado. O investimento com retorno definido antes é a renda fixa; um imposto ou um pagamento mensal não são renda variável.'),
    ('seed_financas_medio_v2', 'O que é análise fundamentalista?', 'Análise fundamentalista é avaliar os dados financeiros e econômicos de uma empresa para decidir se vale investir nela. Não é escolha aleatória, controle de despesas pessoais nem criação de cartões.', 'Análise fundamentalista é avaliar os dados financeiros e econômicos de uma empresa para decidir se vale investir nela. Olhar só o gráfico de preços é outra técnica (análise técnica); controlar despesas ou criar cartões não é análise de investimentos.'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?', 'Orçamento empresarial é o planejamento das receitas, despesas e investimentos de uma empresa. Não é lista de funcionários, documento de identidade nem contrato bancário.', 'Orçamento empresarial é o planejamento das receitas, despesas e investimentos de uma empresa. Não é uma lista de salários, o documento de identificação da empresa nem um contrato de empréstimo.'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 'Sustentabilidade financeira é a capacidade de manter o equilíbrio financeiro ao longo do tempo. Gastar todos os recursos, ter dívidas constantes ou não planejar põe isso em risco.', 'Sustentabilidade financeira é a capacidade de manter o equilíbrio financeiro ao longo do tempo. Gastar todos os recursos, viver de dívidas ou não planejar põe isso em risco.'),
    ('seed_financas_medio_v2', 'O que é independência financeira pessoal?', 'Independência financeira pessoal é conseguir manter o padrão de vida com os próprios recursos. Depender de empréstimos, não ter renda ou ignorar despesas não é independência.', 'Independência financeira pessoal é conseguir manter o padrão de vida com os próprios recursos. Depender de empréstimos ou da ajuda de familiares, ou gastar sem olhar para as despesas, não é independência.'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?', 'Uma boa prática é controlar os gastos, criar reservas e planejar objetivos. Gastar sem acompanhamento, evitar organização ou fazer dívidas constantes piora a saúde financeira.', 'Uma boa prática é controlar os gastos, criar reservas e planejar objetivos. Gastar sem acompanhar, deixar a organização para depois ou viver de dívidas piora a saúde financeira.'),
    ('seed_financas_medio_v3', 'O que é uma taxa de retorno de investimento?', 'Taxa de retorno é o percentual de ganho ou perda obtido numa aplicação financeira, em relação ao valor investido. Não é o valor da conta bancária, o número de clientes nem o dinheiro gasto.', 'Taxa de retorno é o percentual de ganho ou perda obtido numa aplicação financeira, em relação ao valor investido. Não é o saldo da conta, o número de investidores nem a quantia aplicada.'),
    ('seed_financas_medio_v3', 'Qual é a vantagem de criar uma carteira de investimentos diversificada?', 'Uma carteira diversificada reduz riscos, ao distribuir os recursos em diferentes ativos. Não garante lucro em todos os investimentos, não dispensa análise e não elimina custos.', 'Uma carteira diversificada reduz riscos, ao distribuir os recursos em diferentes ativos. Não garante lucro em todos os ativos, não dispensa análise e não elimina os custos de compra e venda.'),
    ('seed_financas_medio_v3', 'O que significa viver abaixo das próprias possibilidades financeiras?', 'É gastar menos do que se recebe e conseguir guardar recursos. Gastar todo o salário, evitar planejamento ou fazer mais dívidas é o contrário.', 'É gastar menos do que se recebe e conseguir guardar recursos. Gastar todo o salário, evitar planejamento ou fazer dívidas para manter o estilo de vida é o contrário.'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?', 'O limite de crédito é o valor máximo que se pode usar com o cartão. É o banco que o define, com base no perfil da pessoa. Usar quase todo o limite deixa pouca margem para imprevistos e faz crescer a fatura. Não é valor mínimo de compra, taxa de juro nem prazo de validade.', 'O limite de crédito é o valor máximo que se pode usar com o cartão. É o banco que o define, com base no perfil da pessoa. Usar quase todo o limite deixa pouca margem para imprevistos e faz crescer a fatura. Não é o valor mínimo da fatura, a taxa de juro nem o prazo para pagar.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças médio lote 4: perguntas 38 a 54 do seed 065, 1 a 3 do seed 069 e 1 a 5 do seed 100): % atualizada(s) (previstas: 20).', v_updated;
END $$;
