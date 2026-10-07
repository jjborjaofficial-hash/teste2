-- Alternativas (BE-003, regularização) — Finanças fácil lote 4: perguntas 43 a 59 do seed 064, as 3 do seed 068, a do 094 e as 4 do 099 (fecha Finanças fácil).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda;
-- só o texto das alternativas ERRADAS é ajustado para ter tamanho parecido ao da certa.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order nem perguntas. O runner já envolve o ficheiro numa transação.
-- Regra 9 do padrão: as explicações que citavam as alternativas erradas antigas ("Não é X, Y nem Z") são reescritas
-- no segundo bloco, também só se o texto atual ainda for exatamente o original.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de curto prazo?', 0, 'Uma dívida permanente', 'Meta que exige vários anos de planejamento'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de curto prazo?', 1, 'Meta para muitos anos obrigatoriamente', 'Gasto previsto que se repete todos os meses'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de curto prazo?', 2, 'Um gasto sem planejamento', 'Quantia guardada para a reforma no futuro'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de longo prazo?', 0, 'Compra imediata sem análise', 'Meta que se alcança em poucas semanas de trabalho'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de longo prazo?', 2, 'Pequeno gasto diário', 'Pagamento de uma conta de valor baixo que vence no próximo mês'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de longo prazo?', 3, 'Pagamento de uma conta simples', 'Gasto pequeno e frequente que acontece todos os dias'),
    ('seed_financas_facil_v2', 'Por que é importante definir metas financeiras?', 1, 'Para aumentar dívidas', 'Para saber quanto o banco cobra de juros todo mês'),
    ('seed_financas_facil_v2', 'Por que é importante definir metas financeiras?', 2, 'Para gastar sem controle', 'Para substituir a necessidade de ter uma fonte de renda'),
    ('seed_financas_facil_v2', 'Por que é importante definir metas financeiras?', 3, 'Para evitar economizar', 'Para comparar o salário com o de outras pessoas'),
    ('seed_financas_facil_v2', 'O que é disciplina financeira?', 0, 'Gastar todos os recursos disponíveis', 'Habilidade de conseguir descontos nas compras feitas durante o mês'),
    ('seed_financas_facil_v2', 'O que é disciplina financeira?', 1, 'Evitar qualquer controle', 'Conhecimento sobre as moedas usadas em outros países'),
    ('seed_financas_facil_v2', 'O que é disciplina financeira?', 2, 'Fazer compras constantes', 'Preferência por gastar o salário logo que ele é recebido'),
    ('seed_financas_facil_v2', 'O que é educação financeira?', 0, 'Aprender apenas matemática', 'Técnica para ganhar mais dinheiro em menos tempo'),
    ('seed_financas_facil_v2', 'O que é educação financeira?', 1, 'Criar contas bancárias', 'Curso obrigatório oferecido pelos bancos aos clientes'),
    ('seed_financas_facil_v2', 'O que é educação financeira?', 3, 'Guardar documentos', 'Ciência que estuda o preço dos produtos nas lojas'),
    ('seed_financas_facil_v2', 'Por que a educação financeira é importante?', 0, 'Elimina todos os riscos', 'Faz com que o salário aumente com o passar dos anos'),
    ('seed_financas_facil_v2', 'Por que a educação financeira é importante?', 2, 'Impede qualquer gasto', 'Dá desconto automático nas compras feitas a prazo'),
    ('seed_financas_facil_v2', 'Por que a educação financeira é importante?', 3, 'Faz todas as compras gratuitas', 'Permite pagar as contas sem precisar de dinheiro'),
    ('seed_financas_facil_v2', 'O que é um hábito financeiro?', 0, 'Um cartão físico', 'Escolha feita uma única vez ao abrir uma conta'),
    ('seed_financas_facil_v2', 'O que é um hábito financeiro?', 2, 'Um investimento obrigatório', 'Regra definida pelo banco para as contas dos clientes antigos'),
    ('seed_financas_facil_v2', 'O que é um hábito financeiro?', 3, 'Uma dívida bancária', 'Decisão tomada pelo governo sobre os impostos'),
    ('seed_financas_facil_v2', 'Qual hábito ajuda na organização financeira?', 1, 'Fazer dívidas sem análise', 'Pagar o mínimo das contas'),
    ('seed_financas_facil_v2', 'Qual hábito ajuda na organização financeira?', 2, 'Ignorar contas', 'Comprar itens em promoção'),
    ('seed_financas_facil_v2', 'Qual hábito ajuda na organização financeira?', 3, 'Gastar sem acompanhar', 'Zerar o saldo da conta'),
    ('seed_financas_facil_v2', 'O que é controle financeiro?', 0, 'Guardar apenas cartões', 'Pagamento antecipado das contas do próximo ano'),
    ('seed_financas_facil_v2', 'O que é controle financeiro?', 1, 'Evitar qualquer pagamento', 'Redução do valor cobrado pelos bancos nas contas'),
    ('seed_financas_facil_v2', 'O que é controle financeiro?', 3, 'Gastar sem limites', 'Aumento da quantidade de dinheiro em circulação'),
    ('seed_financas_facil_v2', 'O que é planejamento de gastos?', 0, 'Gastar sem pensar', 'Anotar depois de gastar tudo o que foi comprado no mês'),
    ('seed_financas_facil_v2', 'O que é planejamento de gastos?', 2, 'Criar dívidas', 'Escolher o banco que cobra menos taxas mensais'),
    ('seed_financas_facil_v2', 'O que é planejamento de gastos?', 3, 'Evitar qualquer compra', 'Comparar o preço do mesmo produto em várias lojas'),
    ('seed_financas_facil_v2', 'O que é uma fonte de renda?', 0, 'Uma dívida', 'Lugar onde uma pessoa guarda o dinheiro'),
    ('seed_financas_facil_v2', 'O que é uma fonte de renda?', 2, 'Um imposto', 'Motivo pelo qual uma pessoa faz compras'),
    ('seed_financas_facil_v2', 'O que é uma fonte de renda?', 3, 'Uma despesa', 'Valor pago por uma pessoa ao governo'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma fonte de renda?', 1, 'Conta de energia', 'Aluguel ou prestação do carro'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma fonte de renda?', 2, 'Compra de roupa', 'Compras ou passeios do mês'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma fonte de renda?', 3, 'Pagamento de dívida', 'Dívidas ou multas atrasadas'),
    ('seed_financas_facil_v2', 'O que é renda extra?', 0, 'Uma dívida adicional', 'Dinheiro guardado para emergências futuras'),
    ('seed_financas_facil_v2', 'O que é renda extra?', 1, 'Uma despesa fixa', 'Dinheiro pedido emprestado ao banco'),
    ('seed_financas_facil_v2', 'O que é renda extra?', 3, 'Um imposto', 'Dinheiro gasto além do orçamento do mês'),
    ('seed_financas_facil_v2', 'Qual é uma forma de aumentar a renda?', 0, 'Gastar mais dinheiro', 'Reduzir as despesas fixas da casa'),
    ('seed_financas_facil_v2', 'Qual é uma forma de aumentar a renda?', 2, 'Ignorar oportunidades', 'Pagar as dívidas antes do vencimento'),
    ('seed_financas_facil_v2', 'Qual é uma forma de aumentar a renda?', 3, 'Fazer dívidas', 'Comprar produtos em promoção'),
    ('seed_financas_facil_v2', 'O que é responsabilidade financeira?', 0, 'Evitar qualquer controle', 'Pedir dinheiro emprestado quando o salário acaba cedo'),
    ('seed_financas_facil_v2', 'O que é responsabilidade financeira?', 1, 'Comprar sempre por impulso', 'Deixar as contas para pagar no último dia'),
    ('seed_financas_facil_v2', 'O que é responsabilidade financeira?', 3, 'Gastar sem limites', 'Gastar na mesma medida que os amigos gastam'),
    ('seed_financas_facil_v2', 'O que é segurança financeira?', 1, 'Não possuir planejamento', 'Situação em que uma pessoa recebe um salário acima da média do seu país'),
    ('seed_financas_facil_v2', 'O que é segurança financeira?', 2, 'Ter muitas dívidas', 'Situação em que uma pessoa já pagou as dívidas que tinha'),
    ('seed_financas_facil_v2', 'O que é segurança financeira?', 3, 'Gastar todo dinheiro', 'Situação em que uma pessoa tem contas abertas em mais de um banco ao mesmo tempo'),
    ('seed_financas_facil_v2', 'Qual é o primeiro passo para melhorar a vida financeira?', 0, 'Ignorar receitas e despesas', 'Pedir um empréstimo para começar bem'),
    ('seed_financas_facil_v2', 'Qual é o primeiro passo para melhorar a vida financeira?', 2, 'Gastar sem analisar', 'Trocar de emprego para ganhar mais'),
    ('seed_financas_facil_v2', 'Qual é o primeiro passo para melhorar a vida financeira?', 3, 'Fazer muitas dívidas', 'Cancelar os cartões que estão em uso'),
    ('seed_financas_facil_v3', 'O que é uma conta de poupança?', 1, 'Cartão de crédito', 'Conta destinada a pagar salários e fornecedores'),
    ('seed_financas_facil_v3', 'O que é uma conta de poupança?', 2, 'Tipo de empréstimo', 'Conta destinada a receber o crédito de um empréstimo'),
    ('seed_financas_facil_v3', 'O que é uma conta de poupança?', 3, 'Conta usada apenas para fazer dívidas', 'Conta destinada a pagar as faturas mensais do cartão de crédito'),
    ('seed_financas_facil_v3', 'Por que é importante guardar parte da renda?', 0, 'Para evitar qualquer planejamento', 'Para pagar menos impostos ao governo no final de cada ano'),
    ('seed_financas_facil_v3', 'Por que é importante guardar parte da renda?', 1, 'Para perder poder de compra', 'Para ter dinheiro suficiente e comprar o que se deseja sem planejar'),
    ('seed_financas_facil_v3', 'Por que é importante guardar parte da renda?', 3, 'Para aumentar despesas', 'Para conseguir um salário maior no próximo emprego'),
    ('seed_financas_facil_v3', 'O que é uma despesa desnecessária?', 0, 'Pagamento obrigatório', 'Gasto feito com a compra de alimentos e remédios da família'),
    ('seed_financas_facil_v3', 'O que é uma despesa desnecessária?', 2, 'Investimento importante', 'Gasto que não pode ser adiado por causa de um prazo previsto em lei'),
    ('seed_financas_facil_v3', 'O que é uma despesa desnecessária?', 3, 'Conta essencial', 'Gasto necessário para manter a casa em bom funcionamento'),
    ('seed_financas_facil_v4', 'O que é uma conta poupança?', 0, 'Um documento usado para pagar impostos', 'Um tipo de conta bancária destinada a pagar as despesas diárias, geralmente com cartão e sem render juros'),
    ('seed_financas_facil_v4', 'O que é uma conta poupança?', 2, 'Um cartão utilizado exclusivamente para fazer compras a crédito', 'Um tipo de conta bancária destinada a receber salários, geralmente cobrando taxas mensais ao cliente'),
    ('seed_financas_facil_v4', 'O que é uma conta poupança?', 3, 'Um tipo de empréstimo bancário', 'Um tipo de empréstimo bancário concedido a clientes, geralmente pago em prestações ao longo do tempo'),
    ('seed_financas_facil_v5', 'O que é uma fatura?', 0, 'Um tipo de investimento', 'Documento que comprova o pagamento de um produto ou serviço'),
    ('seed_financas_facil_v5', 'O que é uma fatura?', 1, 'Um cartão bancário', 'Documento que autoriza o banco a emitir um novo cartão ao cliente'),
    ('seed_financas_facil_v5', 'O que é uma fatura?', 3, 'Uma taxa de juro', 'Documento que mostra as entradas e saídas de uma conta bancária'),
    ('seed_financas_facil_v5', 'O que é câmbio de moeda?', 0, 'Aumento automático do salário', 'Compra de um produto estrangeiro, geralmente pagando taxas alfandegárias'),
    ('seed_financas_facil_v5', 'O que é câmbio de moeda?', 2, 'Um tipo de imposto', 'Envio de dinheiro para outro país, geralmente por meio de um banco'),
    ('seed_financas_facil_v5', 'O que é câmbio de moeda?', 3, 'Uma forma de poupança obrigatória', 'Cobrança de juros sobre um empréstimo, geralmente calculados ao mês'),
    ('seed_financas_facil_v5', 'O que é um cheque?', 1, 'Um cartão de crédito', 'Documento que comprova o depósito de um valor em uma conta bancária'),
    ('seed_financas_facil_v5', 'O que é um cheque?', 2, 'Uma aplicação financeira', 'Documento que autoriza o banco a conceder um empréstimo ao cliente da agência'),
    ('seed_financas_facil_v5', 'O que é um cheque?', 3, 'Um comprovativo de poupança', 'Documento que informa o saldo disponível de uma conta bancária ao cliente'),
    ('seed_financas_facil_v5', 'O que é uma prestação (parcela) de um empréstimo?', 0, 'O valor total do empréstimo', 'Cada um dos juros cobrados pelo banco ao longo do empréstimo'),
    ('seed_financas_facil_v5', 'O que é uma prestação (parcela) de um empréstimo?', 1, 'Uma multa por atraso', 'Cada um dos descontos concedidos ao cliente por pagar em dia'),
    ('seed_financas_facil_v5', 'O que é uma prestação (parcela) de um empréstimo?', 2, 'Um tipo de investimento', 'Cada uma das taxas cobradas na hora de abrir uma conta')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças fácil lote 4: perguntas 43 a 59 do seed 064, seed 068, 094 e 099: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de curto prazo?', 'Objetivo financeiro de curto prazo é uma meta que dá para alcançar em pouco tempo, como juntar dinheiro para um telemóvel ou pagar uma conta pequena. Não é uma dívida permanente nem um gasto sem planejamento.', 'Objetivo financeiro de curto prazo é uma meta que dá para alcançar em pouco tempo, como juntar dinheiro para um telemóvel ou pagar uma conta pequena. Metas que exigem vários anos são de longo prazo, e gastos que se repetem todo mês são despesas, não metas.'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de longo prazo?', 'Objetivo financeiro de longo prazo é uma meta que exige mais tempo e planejamento, como comprar uma casa ou montar um negócio. Compra imediata, pequeno gasto diário e conta simples não são metas de longo prazo.', 'Objetivo financeiro de longo prazo é uma meta que exige mais tempo e planejamento, como comprar uma casa ou montar um negócio. Metas que se alcançam em poucas semanas são de curto prazo.'),
    ('seed_financas_facil_v2', 'O que é disciplina financeira?', 'Disciplina financeira é a capacidade de seguir um planejamento ligado ao dinheiro, mesmo quando dá vontade de gastar. Gastar tudo, evitar qualquer controle e comprar sem parar são o contrário.', 'Disciplina financeira é a capacidade de seguir um planejamento ligado ao dinheiro, mesmo quando dá vontade de gastar. Conseguir descontos, conhecer moedas ou gastar o salário assim que chega não é disciplina: o que conta é manter o plano.'),
    ('seed_financas_facil_v2', 'O que é educação financeira?', 'Educação financeira é o conhecimento para administrar melhor o dinheiro: orçar, poupar, usar crédito com cuidado e evitar dívidas. Não é só matemática nem tem a ver com abrir contas ou guardar documentos.', 'Educação financeira é o conhecimento para administrar melhor o dinheiro: orçar, poupar, usar crédito com cuidado e evitar dívidas. Não é uma técnica para ganhar depressa, um curso dos bancos ou o estudo dos preços nas lojas.'),
    ('seed_financas_facil_v2', 'Por que a educação financeira é importante?', 'A educação financeira ajuda a tomar melhores decisões sobre o dinheiro. Ela não elimina riscos, não impede gastos nem torna compras gratuitas, mas reduz erros que custam caro.', 'A educação financeira ajuda a tomar melhores decisões sobre o dinheiro. Ela não faz o salário subir sozinho, não dá descontos nem substitui o dinheiro, mas reduz erros que custam caro.'),
    ('seed_financas_facil_v2', 'O que é um hábito financeiro?', 'Hábito financeiro é um comportamento repetido relacionado ao uso do dinheiro, como anotar os gastos ou guardar uma parte do que se ganha. Cartão, investimento obrigatório e dívida bancária não são hábitos.', 'Hábito financeiro é um comportamento repetido relacionado ao uso do dinheiro, como anotar os gastos ou guardar uma parte do que se ganha. Uma escolha feita uma única vez, uma regra do banco ou uma decisão do governo não são hábitos.'),
    ('seed_financas_facil_v2', 'Qual hábito ajuda na organização financeira?', 'Registrar receitas e despesas ajuda a organizar as finanças, porque mostra para onde o dinheiro vai. Fazer dívidas sem análise, ignorar contas e gastar sem acompanhar desorganizam o orçamento.', 'Registrar receitas e despesas ajuda a organizar as finanças, porque mostra para onde o dinheiro vai. Pagar só o mínimo, comprar por causa de promoções ou deixar o saldo zerado não organizam o orçamento.'),
    ('seed_financas_facil_v2', 'O que é controle financeiro?', 'Controle financeiro é acompanhar a entrada e a saída de dinheiro: o que se recebe, o que se gasta e o que sobra. Evitar pagamentos ou gastar sem limites não é controle.', 'Controle financeiro é acompanhar a entrada e a saída de dinheiro: o que se recebe, o que se gasta e o que sobra. Antecipar pagamentos ou mexer nas taxas dos bancos não é controle.'),
    ('seed_financas_facil_v2', 'O que é uma fonte de renda?', 'Fonte de renda é a origem de onde uma pessoa recebe dinheiro, como um salário ou um negócio. Dívida, imposto e despesa são dinheiro que se deve ou que sai, não de onde o dinheiro vem.', 'Fonte de renda é a origem de onde uma pessoa recebe dinheiro, como um salário ou um negócio. O lugar onde se guarda o dinheiro, o motivo das compras e o que se paga ao governo não são fontes de renda.'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma fonte de renda?', 'Salário ou negócio próprio são fontes de renda, porque trazem dinheiro para quem trabalha. Conta de energia, compra de roupa e pagamento de dívida são despesas: dinheiro que sai.', 'Salário ou negócio próprio são fontes de renda, porque trazem dinheiro para quem trabalha. Aluguel, compras e dívidas são despesas: dinheiro que sai.'),
    ('seed_financas_facil_v2', 'O que é renda extra?', 'Renda extra é o dinheiro recebido além da renda principal, como um trabalho ocasional ou a venda de algo. Ajuda a alcançar objetivos ou a reforçar a reserva. Não é dívida, despesa fixa nem imposto.', 'Renda extra é o dinheiro recebido além da renda principal, como um trabalho ocasional ou a venda de algo. Ajuda a alcançar objetivos ou a reforçar a reserva. Dinheiro guardado, emprestado ou gasto além do orçamento não é renda extra.'),
    ('seed_financas_facil_v2', 'Qual é uma forma de aumentar a renda?', 'Uma forma de aumentar a renda é criar novas fontes de ganhos, como um trabalho extra ou um pequeno negócio. Gastar mais, ignorar oportunidades ou fazer dívidas não aumenta a renda.', 'Uma forma de aumentar a renda é criar novas fontes de ganhos, como um trabalho extra ou um pequeno negócio. Reduzir despesas, pagar dívidas antes do prazo ou comprar em promoção ajuda o orçamento, mas não aumenta o que se ganha.'),
    ('seed_financas_facil_v2', 'O que é responsabilidade financeira?', 'Responsabilidade financeira é usar o dinheiro de forma consciente e planejada, cumprindo compromissos e guardando uma parte. Evitar controle, comprar por impulso e gastar sem limites é o contrário.', 'Responsabilidade financeira é usar o dinheiro de forma consciente e planejada, cumprindo compromissos e guardando uma parte. Pedir emprestado quando falta, deixar as contas para o último dia ou gastar como os outros gastam é o contrário.'),
    ('seed_financas_facil_v2', 'O que é segurança financeira?', 'Segurança financeira é a situação em que a pessoa tem mais controle e estabilidade com o dinheiro e consegue enfrentar imprevistos sem sufoco. Ter muitas dívidas, não planejar ou gastar tudo afasta dessa segurança.', 'Segurança financeira é a situação em que a pessoa tem mais controle e estabilidade com o dinheiro e consegue enfrentar imprevistos sem sufoco. Um salário alto, ter pago dívidas antigas ou ter contas em vários bancos não garantem essa segurança sozinhos.'),
    ('seed_financas_facil_v2', 'Qual é o primeiro passo para melhorar a vida financeira?', 'O primeiro passo é conhecer a situação financeira atual: quanto se ganha, quanto se gasta e quanto se deve. Só com esse retrato dá para planejar. Ignorar receitas e despesas ou fazer mais dívidas piora a situação.', 'O primeiro passo é conhecer a situação financeira atual: quanto se ganha, quanto se gasta e quanto se deve. Só com esse retrato dá para planejar. Pedir empréstimo, trocar de emprego ou cancelar cartões antes de conhecer a situação pode piorar tudo.'),
    ('seed_financas_facil_v3', 'O que é uma conta de poupança?', 'Conta de poupança é uma conta feita para guardar dinheiro e receber rendimentos. Não é cartão de crédito nem empréstimo, e não serve para fazer dívidas. É um lugar para juntar dinheiro para os seus objetivos.', 'Conta de poupança é uma conta feita para guardar dinheiro e receber rendimentos. Pagar salários e fornecedores, receber um empréstimo ou pagar a fatura do cartão são funções de outros tipos de conta. É um lugar para juntar dinheiro para os seus objetivos.'),
    ('seed_financas_facil_v3', 'O que é uma despesa desnecessária?', 'Despesa desnecessária é o gasto que pode ser evitado sem prejudicar as necessidades básicas. Pagamento obrigatório, conta essencial e investimento importante não são desnecessários. Cortar o que é desnecessário libera dinheiro para guardar.', 'Despesa desnecessária é o gasto que pode ser evitado sem prejudicar as necessidades básicas. Alimentos, remédios, a manutenção da casa e os gastos exigidos por lei são necessários. Cortar o que é desnecessário libera dinheiro para guardar.'),
    ('seed_financas_facil_v4', 'O que é uma conta poupança?', 'Conta poupança é uma conta bancária feita para guardar dinheiro e, em geral, render juros com o tempo. Não é imposto, cartão de crédito nem empréstimo. É um lugar para juntar dinheiro para os seus objetivos.', 'Conta poupança é uma conta bancária feita para guardar dinheiro e, em geral, render juros com o tempo. A conta para despesas diárias, a conta para receber salário e o empréstimo são coisas diferentes. É um lugar para juntar dinheiro para os seus objetivos.'),
    ('seed_financas_facil_v5', 'O que é uma fatura?', 'Fatura é o documento que detalha o que se deve pagar por um produto ou serviço, com os valores cobrados. Não é investimento, cartão bancário nem taxa de juro. Guardar as faturas ajuda a controlar as despesas.', 'Fatura é o documento que detalha o que se deve pagar por um produto ou serviço, com os valores cobrados. O recibo comprova um pagamento já feito, e o extrato mostra as entradas e saídas da conta. Guardar as faturas ajuda a controlar as despesas.'),
    ('seed_financas_facil_v5', 'O que é câmbio de moeda?', 'Câmbio é a troca de uma moeda por outra, feita a uma taxa de conversão que muda com o tempo. Não é aumento de salário, imposto nem poupança obrigatória.', 'Câmbio é a troca de uma moeda por outra, feita a uma taxa de conversão que muda com o tempo. Comprar produtos de fora, enviar dinheiro para o exterior ou cobrar juros de um empréstimo são operações diferentes.'),
    ('seed_financas_facil_v5', 'O que é um cheque?', 'Cheque é um documento que ordena ao banco pagar um valor a partir da conta de quem o emite. Não é cartão de crédito, aplicação financeira nem comprovativo de poupança.', 'Cheque é um documento que ordena ao banco pagar um valor a partir da conta de quem o emite. Comprovar um depósito, autorizar um empréstimo ou informar o saldo são funções de outros documentos.'),
    ('seed_financas_facil_v5', 'O que é uma prestação (parcela) de um empréstimo?', 'Prestação é cada pagamento periódico feito para quitar um empréstimo aos poucos. Não é o valor total do empréstimo nem uma multa por atraso. Pagar em dia evita multas.', 'Prestação é cada pagamento periódico feito para quitar um empréstimo aos poucos. Juros, descontos por pagar em dia e taxas de abertura de conta são outras coisas. Pagar em dia evita multas.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (lote 4 de Finanças fácil): % atualizada(s) (previstas: 22).', v_updated;
END $$;
