-- Alternativas (BE-003, regularização) — Finanças médio lote 3: perguntas 13 a 37 do seed 065.
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
    ('seed_financas_medio_v2', 'O que significa comprar ações?', 0, 'Pagar impostos', 'Pagar uma taxa para poder negociar na bolsa de valores'),
    ('seed_financas_medio_v2', 'O que significa comprar ações?', 1, 'Fazer uma dívida', 'Fazer um empréstimo à empresa para financiar a sua atividade'),
    ('seed_financas_medio_v2', 'O que significa comprar ações?', 2, 'Comprar dinheiro físico', 'Comprar a moeda de outro país para guardar o dinheiro'),
    ('seed_financas_medio_v2', 'O que é dividendo?', 0, 'Uma dívida', 'Valor que a empresa paga aos fornecedores pelas compras do mês'),
    ('seed_financas_medio_v2', 'O que é dividendo?', 1, 'Uma taxa bancária', 'Taxa que o banco cobra para guardar as ações do cliente'),
    ('seed_financas_medio_v2', 'O que é dividendo?', 3, 'Um imposto', 'Imposto que o acionista paga ao vender as ações com lucro'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?', 0, 'Uma despesa', 'Obrigação de pagar uma quantia a outra pessoa ou entidade'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?', 1, 'Um imposto', 'Valor pago ao governo sobre os rendimentos ou as compras'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?', 2, 'Uma dívida', 'Gasto necessário para manter o funcionamento de uma empresa'),
    ('seed_financas_medio_v2', 'O que é um passivo financeiro?', 1, 'Um investimento', 'Bem que a pessoa possui e pode render ao longo do tempo'),
    ('seed_financas_medio_v2', 'O que é um passivo financeiro?', 2, 'Uma receita', 'Valor que a empresa recebe pelas vendas do período'),
    ('seed_financas_medio_v2', 'O que é um passivo financeiro?', 3, 'Um lucro', 'Resultado positivo depois de pagar todas as despesas'),
    ('seed_financas_medio_v2', 'O que é fluxo de caixa?', 0, 'Um cartão', 'Cartão usado para pagar compras a prazo'),
    ('seed_financas_medio_v2', 'O que é fluxo de caixa?', 2, 'Uma dívida', 'Dívida que uma empresa tem com os fornecedores'),
    ('seed_financas_medio_v2', 'O que é fluxo de caixa?', 3, 'Apenas saldo bancário', 'Valor total que existe numa conta bancária'),
    ('seed_financas_medio_v2', 'Por que acompanhar o fluxo de caixa é importante?', 1, 'Para aumentar despesas', 'Para pagar menos impostos sobre o dinheiro que entra'),
    ('seed_financas_medio_v2', 'Por que acompanhar o fluxo de caixa é importante?', 2, 'Para evitar planejamento', 'Para decidir sem precisar de planejar as contas do mês'),
    ('seed_financas_medio_v2', 'Por que acompanhar o fluxo de caixa é importante?', 3, 'Para perder controle', 'Para garantir que o lucro será positivo no fim do ano'),
    ('seed_financas_medio_v2', 'O que é inadimplência?', 1, 'Economia de dinheiro', 'Pagamento de uma obrigação financeira antes do prazo'),
    ('seed_financas_medio_v2', 'O que é inadimplência?', 2, 'Aumento de investimentos', 'Renegociação das condições de pagamento de uma dívida'),
    ('seed_financas_medio_v2', 'O que é inadimplência?', 3, 'Crescimento da renda', 'Cobrança de juros por um banco sobre um empréstimo'),
    ('seed_financas_medio_v2', 'O que é renegociação de dívida?', 0, 'Aumentar juros sempre', 'Aumentar os juros da dívida para o credor receber mais'),
    ('seed_financas_medio_v2', 'O que é renegociação de dívida?', 1, 'Cancelar todos os pagamentos', 'Cancelar todos os pagamentos e apagar a dívida do registo'),
    ('seed_financas_medio_v2', 'O que é renegociação de dívida?', 3, 'Criar novas dívidas', 'Criar novas dívidas para pagar as anteriores sem alterar as condições'),
    ('seed_financas_medio_v2', 'O que é crédito responsável?', 0, 'Usar todo limite disponível', 'Usar o limite disponível sem controlar as parcelas do mês'),
    ('seed_financas_medio_v2', 'O que é crédito responsável?', 1, 'Fazer empréstimos sem análise', 'Fazer empréstimos sem analisar as condições do contrato'),
    ('seed_financas_medio_v2', 'O que é crédito responsável?', 3, 'Ignorar juros', 'Ignorar os juros e olhar só para o valor da prestação'),
    ('seed_financas_medio_v2', 'O que é planejamento de aposentadoria?', 0, 'Gastar todo dinheiro atual', 'Gastar o dinheiro atual para ter conforto no presente'),
    ('seed_financas_medio_v2', 'O que é planejamento de aposentadoria?', 1, 'Fazer dívidas', 'Fazer dívidas hoje para pagar com a reforma no futuro'),
    ('seed_financas_medio_v2', 'O que é planejamento de aposentadoria?', 3, 'Evitar investimentos', 'Evitar investimentos e guardar todo o dinheiro em casa'),
    ('seed_financas_medio_v2', 'O que é independência financeira?', 0, 'Gastar sem controle', 'Gastar o dinheiro sem controlar as entradas e saídas'),
    ('seed_financas_medio_v2', 'O que é independência financeira?', 2, 'Não possuir renda', 'Situação em que a pessoa não precisa de ter rendimentos'),
    ('seed_financas_medio_v2', 'O que é independência financeira?', 3, 'Ter muitas dívidas', 'Situação em que se tem muitas dívidas mas rendimentos altos'),
    ('seed_financas_medio_v2', 'O que é análise financeira?', 0, 'Fazer compras', 'Compra de produtos e serviços para uso próprio da empresa'),
    ('seed_financas_medio_v2', 'O que é análise financeira?', 2, 'Apenas guardar dinheiro', 'Registo do dinheiro guardado em casa ou na conta bancária'),
    ('seed_financas_medio_v2', 'O que é análise financeira?', 3, 'Criar contas', 'Abertura de contas bancárias para receber o salário'),
    ('seed_financas_medio_v2', 'O que é inflação de demanda?', 0, 'Queda dos investimentos', 'Aumento dos preços causado pela queda dos investimentos das empresas'),
    ('seed_financas_medio_v2', 'O que é inflação de demanda?', 1, 'Diminuição da produção sempre', 'Diminuição da produção por falta de matéria-prima nas fábricas'),
    ('seed_financas_medio_v2', 'O que é inflação de demanda?', 2, 'Redução dos salários', 'Redução dos salários e do consumo causada pela diminuição das vendas'),
    ('seed_financas_medio_v2', 'O que é inflação de custos?', 0, 'Crescimento da poupança', 'Crescimento da poupança causado pelo aumento dos juros'),
    ('seed_financas_medio_v2', 'O que é inflação de custos?', 1, 'Redução dos preços por excesso de produtos', 'Redução dos preços causada por excesso de produtos nas lojas'),
    ('seed_financas_medio_v2', 'O que é inflação de custos?', 2, 'Aumento do salário automaticamente', 'Aumento dos preços causado pelo excesso de procura dos consumidores'),
    ('seed_financas_medio_v2', 'O que é deflação?', 0, 'Aumento dos preços', 'Aumento geral dos preços de produtos e serviços'),
    ('seed_financas_medio_v2', 'O que é deflação?', 1, 'Crescimento das dívidas', 'Aumento do valor das dívidas por causa dos juros'),
    ('seed_financas_medio_v2', 'O que é deflação?', 2, 'Aumento dos juros sempre', 'Aumento dos juros cobrados pelo banco central'),
    ('seed_financas_medio_v2', 'O que é taxa de juros?', 1, 'Preço de um produto', 'Valor total que se deve ao banco depois do empréstimo'),
    ('seed_financas_medio_v2', 'O que é taxa de juros?', 2, 'Valor do salário', 'Valor que o trabalhador recebe pelo seu trabalho mensal'),
    ('seed_financas_medio_v2', 'O que é taxa de juros?', 3, 'Valor de uma conta', 'Imposto cobrado pelo governo sobre uma conta ou serviço'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 0, 'Sempre reduz as dívidas', 'Pode reduzir o valor total das dívidas'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 1, 'Elimina pagamentos', 'Elimina a necessidade de pagar prestações'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 3, 'Aumenta automaticamente a renda', 'Aumenta o rendimento de quem pediu o empréstimo'),
    ('seed_financas_medio_v2', 'O que é amortização?', 1, 'Criação de uma dívida', 'Criação de uma nova dívida para pagar uma dívida anterior'),
    ('seed_financas_medio_v2', 'O que é amortização?', 2, 'Aumento de juros', 'Aumento dos juros cobrados sobre o valor que ainda se deve'),
    ('seed_financas_medio_v2', 'O que é amortização?', 3, 'Perda de investimento', 'Perda de valor de um investimento ao longo do tempo'),
    ('seed_financas_medio_v2', 'O que é financiamento?', 1, 'Dinheiro gratuito', 'Operação em que uma pessoa recebe dinheiro de um amigo para uma compra, sem juros'),
    ('seed_financas_medio_v2', 'O que é financiamento?', 2, 'Uma doação', 'Doação feita por uma instituição para ajudar numa compra, sem devolução'),
    ('seed_financas_medio_v2', 'O que é financiamento?', 3, 'Um investimento sem risco', 'Aplicação de dinheiro numa instituição para receber rendimento no futuro'),
    ('seed_financas_medio_v2', 'Qual a diferença entre financiamento e empréstimo?', 1, 'Empréstimo sempre é gratuito', 'Empréstimo geralmente está ligado a uma finalidade específica; financiamento pode ter uso mais livre'),
    ('seed_financas_medio_v2', 'Qual a diferença entre financiamento e empréstimo?', 2, 'Financiamento não possui pagamento', 'Financiamento geralmente não tem juros; empréstimo geralmente cobra juros mais altos'),
    ('seed_financas_medio_v2', 'Qual a diferença entre financiamento e empréstimo?', 3, 'Não existe diferença', 'Empréstimo só pode ser pedido por empresas; financiamento só pode ser pedido por pessoas'),
    ('seed_financas_medio_v2', 'O que é cheque especial?', 0, 'Reserva de emergência', 'Dinheiro guardado pelo cliente para situações de emergência'),
    ('seed_financas_medio_v2', 'O que é cheque especial?', 1, 'Cartão de débito', 'Cartão do banco que só permite gastar o saldo da conta'),
    ('seed_financas_medio_v2', 'O que é cheque especial?', 3, 'Conta de investimento', 'Conta usada para aplicar dinheiro em investimentos de longo prazo'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?', 1, 'Porque elimina dívidas', 'Porque faz desaparecer as dívidas ao fim do mês'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?', 2, 'Porque aumenta salário', 'Porque aumenta o salário de quem o utiliza'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?', 3, 'Porque é investimento', 'Porque é um investimento com retorno garantido'),
    ('seed_financas_medio_v2', 'O que é score de crédito?', 0, 'Tipo de cartão', 'Tipo de cartão usado para fazer compras a prazo nas lojas'),
    ('seed_financas_medio_v2', 'O que é score de crédito?', 1, 'Salário mensal', 'Valor mensal recebido por uma pessoa pelo seu trabalho'),
    ('seed_financas_medio_v2', 'O que é score de crédito?', 2, 'Valor disponível na conta', 'Quantia disponível na conta de uma pessoa num certo dia'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?', 0, 'Garante riqueza automaticamente', 'Garante que a pessoa ficará rica com o passar do tempo'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?', 1, 'Elimina todos os pagamentos', 'Dispensa a pessoa de pagar as prestações dos empréstimos'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?', 3, 'Substitui investimentos', 'Substitui a necessidade de ter investimentos e poupança'),
    ('seed_financas_medio_v2', 'O que é planejamento tributário?', 0, 'Criar dívidas', 'Criação de dívidas para pagar menos impostos no fim do ano'),
    ('seed_financas_medio_v2', 'O que é planejamento tributário?', 1, 'Cancelar pagamentos', 'Cancelamento dos pagamentos de impostos já vencidos'),
    ('seed_financas_medio_v2', 'O que é planejamento tributário?', 2, 'Evitar todos os impostos ilegalmente', 'Deixar de declarar rendimentos para pagar menos impostos')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças médio lote 3: perguntas 13 a 37 do seed 065: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_medio_v2', 'O que significa comprar ações?', 'Comprar ações é tornar-se parcialmente proprietário de uma empresa, na proporção do que se comprou. Não é pagar imposto, fazer dívida nem comprar dinheiro físico.', 'Comprar ações é tornar-se parcialmente proprietário de uma empresa, na proporção do que se comprou. Não é pagar uma taxa de acesso, emprestar dinheiro à empresa nem comprar moeda estrangeira.'),
    ('seed_financas_medio_v2', 'O que é dividendo?', 'Dividendo é a parte do lucro de uma empresa que é distribuída aos acionistas. Não é dívida, taxa bancária nem imposto.', 'Dividendo é a parte do lucro de uma empresa que é distribuída aos acionistas. Não é pagamento a fornecedores, taxa de custódia nem imposto sobre o lucro da venda de ações.'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?', 'Ativo financeiro é um recurso que tem valor econômico e pode gerar retorno, como uma ação ou dinheiro aplicado. Despesa, imposto e dívida não são ativos.', 'Ativo financeiro é um recurso que tem valor econômico e pode gerar retorno, como uma ação ou dinheiro aplicado. Obrigações a pagar, impostos e gastos de funcionamento não são ativos.'),
    ('seed_financas_medio_v2', 'O que é um passivo financeiro?', 'Passivo financeiro é uma obrigação ou dívida que faz o dinheiro sair. É o contrário do ativo. Investimento, receita e lucro não são passivos.', 'Passivo financeiro é uma obrigação ou dívida que faz o dinheiro sair. É o contrário do ativo. Bens que rendem, vendas recebidas e lucro não são passivos.'),
    ('seed_financas_medio_v2', 'O que é fluxo de caixa?', 'Fluxo de caixa é o controle das entradas e saídas de dinheiro. Mostra se está entrando mais do que sai. Não é um cartão, uma dívida nem apenas o saldo do banco.', 'Fluxo de caixa é o controle das entradas e saídas de dinheiro. Mostra se está entrando mais do que sai. Não é um cartão, uma dívida nem apenas o valor que está na conta do banco.'),
    ('seed_financas_medio_v2', 'Por que acompanhar o fluxo de caixa é importante?', 'Acompanhar o fluxo de caixa mostra quanto entra e quanto sai, ajudando a entender a situação financeira e a decidir melhor. Quem não acompanha perde o controle e planeja pior.', 'Acompanhar o fluxo de caixa mostra quanto entra e quanto sai, ajudando a entender a situação financeira e a decidir melhor. Não reduz impostos nem garante lucro: dá informação para decidir.'),
    ('seed_financas_medio_v2', 'O que é inadimplência?', 'Inadimplência é a falta de pagamento de uma obrigação financeira no prazo. Gera multas e juros e pode prejudicar o acesso a crédito. Não é economia, investimento nem aumento de renda.', 'Inadimplência é a falta de pagamento de uma obrigação financeira no prazo. Gera multas e juros e pode prejudicar o acesso a crédito. Não é pagar antes do prazo, renegociar nem a cobrança normal de juros.'),
    ('seed_financas_medio_v2', 'O que é renegociação de dívida?', 'Renegociar uma dívida é combinar com o credor novas condições de pagamento para facilitar a quitação, como outro prazo ou outras parcelas. Não é cancelar todos os pagamentos nem criar novas dívidas.', 'Renegociar uma dívida é combinar com o credor novas condições de pagamento para facilitar a quitação, como outro prazo ou outras parcelas. Não é aumentar juros, apagar a dívida nem criar novas dívidas para pagar as antigas.'),
    ('seed_financas_medio_v2', 'O que é crédito responsável?', 'Crédito responsável é usar o crédito considerando a capacidade de pagamento, sabendo os juros e quanto pode pagar por mês. Usar todo o limite, pedir empréstimos sem análise ou ignorar juros não é responsável.', 'Crédito responsável é usar o crédito considerando a capacidade de pagamento, sabendo os juros e quanto pode pagar por mês. Usar o limite sem controle, não analisar o contrato ou olhar só para a prestação não é responsável.'),
    ('seed_financas_medio_v2', 'O que é planejamento de aposentadoria?', 'Planejamento de aposentadoria é organizar o dinheiro agora para garantir recursos no futuro, quando já não se trabalhar. Gastar tudo, fazer dívidas ou evitar investir vai no sentido contrário.', 'Planejamento de aposentadoria é organizar o dinheiro agora para garantir recursos no futuro, quando já não se trabalhar. Gastar tudo, fazer dívidas ou guardar tudo em casa vai no sentido contrário.'),
    ('seed_financas_medio_v2', 'O que é independência financeira?', 'Independência financeira é a situação em que os rendimentos conseguem cobrir as despesas, sem depender só de trabalhar. Gastar sem controle, não ter renda ou ter muitas dívidas é o oposto.', 'Independência financeira é a situação em que os rendimentos conseguem cobrir as despesas, sem depender só de trabalhar. Gastar sem controle, dispensar rendimentos ou viver de dívidas não é independência.'),
    ('seed_financas_medio_v2', 'O que é análise financeira?', 'Análise financeira é avaliar informações financeiras, como receitas, despesas e dívidas, para tomar decisões. Não é fazer compras, apenas guardar dinheiro nem criar contas.', 'Análise financeira é avaliar informações financeiras, como receitas, despesas e dívidas, para tomar decisões. Não é fazer compras, apenas registar o dinheiro guardado nem abrir contas.'),
    ('seed_financas_medio_v2', 'O que é inflação de demanda?', 'Inflação de demanda é o aumento dos preços causado por excesso de procura: quando muita gente quer comprar e há pouco para vender, os preços sobem. Não é queda de investimentos nem redução de salários.', 'Inflação de demanda é o aumento dos preços causado por excesso de procura: quando muita gente quer comprar e há pouco para vender, os preços sobem. Não vem da queda dos investimentos, da falta de matéria-prima nem da redução dos salários.'),
    ('seed_financas_medio_v2', 'O que é inflação de custos?', 'Inflação de custos é o aumento dos preços causado pelo aumento dos custos de produção, como matéria-prima ou energia. As empresas repassam o custo maior aos preços. Não é crescimento da poupança nem queda de preços.', 'Inflação de custos é o aumento dos preços causado pelo aumento dos custos de produção, como matéria-prima ou energia. As empresas repassam o custo maior aos preços. Não é o excesso de procura (isso é inflação de demanda) nem a queda dos preços.'),
    ('seed_financas_medio_v2', 'O que é deflação?', 'Deflação é a redução geral dos preços de produtos e serviços, o oposto da inflação. Não é aumento de preços, de dívidas ou de juros.', 'Deflação é a redução geral dos preços de produtos e serviços, o oposto da inflação. Não é aumento de preços, aumento do valor das dívidas nem subida dos juros.'),
    ('seed_financas_medio_v2', 'O que é taxa de juros?', 'Taxa de juros é o percentual cobrado ou pago pelo uso do dinheiro. Quem pede emprestado paga juros, e quem aplica pode receber. Não é o preço de um produto, o salário nem o valor de uma conta.', 'Taxa de juros é o percentual cobrado ou pago pelo uso do dinheiro. Quem pede emprestado paga juros, e quem aplica pode receber. Não é o valor total da dívida, o salário nem um imposto.'),
    ('seed_financas_medio_v2', 'Como uma taxa de juros alta pode afetar empréstimos?', 'Com juros altos, o crédito fica mais caro: paga-se mais pelo mesmo empréstimo. Isso não reduz as dívidas, não elimina pagamentos e não aumenta a renda.', 'Com juros altos, o crédito fica mais caro: paga-se mais pelo mesmo empréstimo. Isso não reduz as dívidas, não dispensa as prestações e não aumenta o rendimento de quem pede.'),
    ('seed_financas_medio_v2', 'O que é amortização?', 'Amortização é a redução gradual de uma dívida por meio dos pagamentos feitos. Cada parcela paga abate parte do que se deve. Não é criar dívida, aumentar juros nem perder investimento.', 'Amortização é a redução gradual de uma dívida por meio dos pagamentos feitos. Cada parcela paga abate parte do que se deve. Não é criar outra dívida, aumentar juros nem perder valor de investimento.'),
    ('seed_financas_medio_v2', 'O que é financiamento?', 'Financiamento é a operação em que uma instituição fornece o dinheiro para uma compra, como um carro ou uma casa, e a pessoa paga depois. Não é dinheiro gratuito, doação nem investimento sem risco.', 'Financiamento é a operação em que uma instituição fornece o dinheiro para uma compra, como um carro ou uma casa, e a pessoa paga depois. Não é um empréstimo de amigo sem juros, uma doação nem uma aplicação para render.'),
    ('seed_financas_medio_v2', 'Qual a diferença entre financiamento e empréstimo?', 'O financiamento costuma ter uma finalidade específica, como comprar um bem, enquanto o empréstimo pode ser usado de forma mais livre. Ambos precisam ser pagos, com juros.', 'O financiamento costuma ter uma finalidade específica, como comprar um bem, enquanto o empréstimo pode ser usado de forma mais livre. Ambos precisam ser pagos, com juros, e podem ser pedidos por pessoas ou empresas.'),
    ('seed_financas_medio_v2', 'O que é cheque especial?', 'Cheque especial é uma linha de crédito que o banco deixa disponível na conta para uso emergencial, quando o saldo acaba. Não é reserva de emergência, cartão de débito nem conta de investimento.', 'Cheque especial é uma linha de crédito que o banco deixa disponível na conta para uso emergencial, quando o saldo acaba. Não é o dinheiro da reserva de emergência, um cartão de débito nem uma conta de investimento.'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?', 'O cheque especial deve ser usado com cuidado porque costuma ter juros elevados, e a dívida cresce rápido. Não elimina dívidas, não aumenta salário e não é investimento.', 'O cheque especial deve ser usado com cuidado porque costuma ter juros elevados, e a dívida cresce rápido. Não faz desaparecer dívidas, não aumenta o salário e não é investimento.'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?', 'Um bom score pode facilitar o acesso a crédito em melhores condições, como juros menores. Não garante riqueza, não elimina pagamentos e não substitui investimentos.', 'Um bom score pode facilitar o acesso a crédito em melhores condições, como juros menores. Não garante riqueza, não dispensa prestações e não substitui poupança nem investimentos.'),
    ('seed_financas_medio_v2', 'O que é planejamento tributário?', 'Planejamento tributário é organizar as obrigações fiscais dentro da lei, para pagar o que é devido da forma mais adequada. Evitar impostos de forma ilegal é crime, e não faz parte do planejamento.', 'Planejamento tributário é organizar as obrigações fiscais dentro da lei, para pagar o que é devido da forma mais adequada. Esconder rendimentos, cancelar impostos vencidos ou criar dívidas para pagar menos não é planejamento: pode ser ilegal.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças médio lote 3: perguntas 13 a 37 do seed 065): % atualizada(s) (previstas: 24).', v_updated;
END $$;
