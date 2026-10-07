-- Alternativas (BE-003, regularização) — Finanças médio lote 1: as 25 primeiras perguntas do seed 046 (seed_financas_medio_v1).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda;
-- só o texto das alternativas ERRADAS é ajustado para ter tamanho parecido ao da certa. Erradas que já eram boas
-- (p. ex. números de contas que vêm de erros reais) ficam como estavam.
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
    ('seed_financas_medio_v1', 'Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', 0, '3.000 MZN', '26.500 MZN'),
    ('seed_financas_medio_v1', 'Uma pessoa recebe 15.000 MZN e suas despesas mensais são 11.500 MZN. Qual é o valor disponível antes de outros gastos?', 3, '2.500 MZN', '11.500 MZN'),
    ('seed_financas_medio_v1', 'Qual é a principal diferença entre poupança e investimento?', 1, 'Poupança sempre gera mais rendimento', 'Poupança normalmente prioriza o maior retorno possível, enquanto investimento busca segurança e acesso rápido ao dinheiro'),
    ('seed_financas_medio_v1', 'Qual é a principal diferença entre poupança e investimento?', 2, 'Investimento nunca envolve risco', 'Poupança normalmente exige conhecimento técnico avançado, enquanto investimento é indicado para qualquer perfil de pessoa'),
    ('seed_financas_medio_v1', 'Qual é a principal diferença entre poupança e investimento?', 3, 'São exatamente a mesma coisa', 'Poupança normalmente é destinada a empresas de grande porte, enquanto investimento é destinado a pessoas físicas'),
    ('seed_financas_medio_v1', 'O que é liquidez?', 0, 'Taxa de inflação', 'Capacidade de um ativo valorizar com o tempo'),
    ('seed_financas_medio_v1', 'O que é liquidez?', 1, 'Quantidade de dívidas', 'Facilidade de conseguir um empréstimo bancário'),
    ('seed_financas_medio_v1', 'O que é liquidez?', 3, 'Valor de um imposto', 'Quantidade de dinheiro guardada em uma conta'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?', 0, 'Porque elimina a necessidade de orçamento', 'Porque deve render o máximo possível a cada mês'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?', 1, 'Porque deve ser usada para compras de luxo', 'Porque serve para pagar as compras planejadas do ano'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?', 3, 'Porque precisa ser investida em ativos de alto risco', 'Porque precisa ficar aplicada por vários anos seguidos'),
    ('seed_financas_medio_v1', 'Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', 0, '2.500 MZN', '200 MZN'),
    ('seed_financas_medio_v1', 'Uma pessoa recebe 20.000 MZN e decide poupar 10% da renda. Quanto deverá guardar?', 3, '1.000 MZN', '18.000 MZN'),
    ('seed_financas_medio_v1', 'O que é crédito?', 1, 'Dinheiro sempre gratuito', 'Possibilidade de receber recursos sem obrigação de devolução conforme as regras do banco'),
    ('seed_financas_medio_v1', 'O que é crédito?', 2, 'Um tipo de imposto', 'Obrigação de pagar tributos ao governo conforme as condições previstas na legislação vigente'),
    ('seed_financas_medio_v1', 'O que é crédito?', 3, 'Uma forma de salário', 'Pagamento recebido por um trabalho realizado conforme as condições acordadas com o empregador'),
    ('seed_financas_medio_v1', 'Por que o prazo de um empréstimo influencia seu custo?', 0, 'Porque transforma dívida em renda', 'Porque pode alterar o valor da renda mensal de quem pediu o empréstimo no banco'),
    ('seed_financas_medio_v1', 'Por que o prazo de um empréstimo influencia seu custo?', 1, 'Porque o prazo não influencia nada', 'Porque pode isentar o cliente do pagamento de juros e encargos sobre o valor emprestado'),
    ('seed_financas_medio_v1', 'Por que o prazo de um empréstimo influencia seu custo?', 2, 'Porque elimina os juros', 'Porque pode alterar o valor emprestado que foi liberado no primeiro dia do contrato'),
    ('seed_financas_medio_v1', 'O que significa capacidade de pagamento?', 0, 'Valor de uma promoção', 'Capacidade de obter descontos nas compras usando os recursos disponíveis'),
    ('seed_financas_medio_v1', 'O que significa capacidade de pagamento?', 1, 'Número de contas bancárias', 'Capacidade de abrir contas em vários bancos com os documentos disponíveis'),
    ('seed_financas_medio_v1', 'O que significa capacidade de pagamento?', 3, 'Quantidade de produtos comprados', 'Capacidade de comprar produtos importados com a moeda estrangeira disponível'),
    ('seed_financas_medio_v1', 'O que é orçamento deficitário?', 0, 'Situação sem despesas', 'Situação em que as despesas e as receitas planejadas são iguais'),
    ('seed_financas_medio_v1', 'O que é orçamento deficitário?', 1, 'Situação sem receitas', 'Situação em que as receitas planejadas ainda não foram recebidas'),
    ('seed_financas_medio_v1', 'Por que registrar pequenos gastos pode ser importante?', 0, 'Porque aumenta automaticamente a poupança', 'Porque vários gastos pequenos podem ser pagos com o dinheiro da reserva de emergência'),
    ('seed_financas_medio_v1', 'Por que registrar pequenos gastos pode ser importante?', 1, 'Porque elimina a necessidade de renda', 'Porque os gastos pequenos costumam ser cobrados com juros mais altos pelas lojas e pelos bancos'),
    ('seed_financas_medio_v1', 'Por que registrar pequenos gastos pode ser importante?', 2, 'Porque pequenos gastos nunca importam', 'Porque os gastos pequenos costumam ser descontados do imposto pago ao final do ano'),
    ('seed_financas_medio_v1', 'O que significa risco financeiro?', 0, 'Garantia de retorno', 'Possibilidade de receber um retorno maior do que o valor investido no ano'),
    ('seed_financas_medio_v1', 'O que significa risco financeiro?', 1, 'Garantia de lucro', 'Obrigação de devolver o dinheiro aplicado ao final do contrato'),
    ('seed_financas_medio_v1', 'O que significa risco financeiro?', 3, 'Ausência completa de incerteza', 'Situação em que o dinheiro aplicado fica parado em uma conta sem render'),
    ('seed_financas_medio_v1', 'Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 0, 'Porque bancos não existem', 'Porque promessas desse tipo costumam ser feitas por bancos públicos'),
    ('seed_financas_medio_v1', 'Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 2, 'Porque todo investimento é ilegal', 'Porque promessas desse tipo costumam exigir um depósito mínimo muito alto'),
    ('seed_financas_medio_v1', 'Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?', 3, 'Porque investimentos nunca geram retorno', 'Porque promessas desse tipo costumam ser proibidas pela lei de cada país'),
    ('seed_financas_medio_v1', 'O que é custo total de uma compra financiada?', 0, 'Apenas o imposto', 'Valor principal somado ao imposto e à taxa de entrega da compra'),
    ('seed_financas_medio_v1', 'O que é custo total de uma compra financiada?', 2, 'Apenas o valor anunciado inicialmente', 'Valor anunciado inicialmente subtraído dos descontos aplicáveis'),
    ('seed_financas_medio_v1', 'O que é custo total de uma compra financiada?', 3, 'Apenas o primeiro pagamento', 'Valor da entrada somado ao primeiro mês de prestações pagas'),
    ('seed_financas_medio_v1', 'Qual fator deve ser considerado ao comparar dois empréstimos?', 0, 'Apenas a cor do cartão', 'Marca, nome, logotipo e publicidade do banco'),
    ('seed_financas_medio_v1', 'Qual fator deve ser considerado ao comparar dois empréstimos?', 1, 'Apenas o nome da instituição', 'Localização, horário, atendimento e fila'),
    ('seed_financas_medio_v1', 'Qual fator deve ser considerado ao comparar dois empréstimos?', 2, 'Apenas a publicidade', 'Brindes, sorteios, aplicativo e cor do cartão'),
    ('seed_financas_medio_v1', 'O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 1, 'Reduz automaticamente seu salário', 'Pode reduzir o valor do salário recebido'),
    ('seed_financas_medio_v1', 'O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 2, 'Sempre aumenta as dívidas', 'Pode aumentar o valor das dívidas antigas'),
    ('seed_financas_medio_v1', 'O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?', 3, 'Elimina sua renda', 'Pode eliminar a renda recebida todos os meses'),
    ('seed_financas_medio_v1', 'O que é uma meta financeira de curto prazo?', 1, 'Uma despesa inesperada', 'Objetivo que costuma levar mais de vinte anos para ser alcançado'),
    ('seed_financas_medio_v1', 'O que é uma meta financeira de curto prazo?', 2, 'Objetivo que obrigatoriamente demora décadas', 'Despesa que surge de forma inesperada em um período relativamente curto'),
    ('seed_financas_medio_v1', 'O que é uma meta financeira de curto prazo?', 3, 'Uma dívida permanente', 'Dívida que é assumida em um período relativamente próximo ao atual'),
    ('seed_financas_medio_v1', 'Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 0, 'Garante lucro', 'Aumenta o rendimento do dinheiro guardado em cada objetivo'),
    ('seed_financas_medio_v1', 'Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 2, 'Impede qualquer gasto', 'Dispensa a necessidade de acompanhar as despesas de cada mês'),
    ('seed_financas_medio_v1', 'Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 3, 'Elimina riscos', 'Reduz o valor dos impostos pagos sobre o dinheiro guardado'),
    ('seed_financas_medio_v1', 'O que é renda ativa?', 1, 'Apenas juros bancários', 'Renda normalmente obtida de juros pagos sobre o dinheiro aplicado em uma conta bancária'),
    ('seed_financas_medio_v1', 'O que é renda ativa?', 2, 'Apenas dividendos', 'Renda normalmente obtida do aluguel de imóveis ou do pagamento de dividendos'),
    ('seed_financas_medio_v1', 'O que é renda ativa?', 3, 'Dinheiro encontrado', 'Renda normalmente obtida de prêmios ou presentes recebidos de terceiros'),
    ('seed_financas_medio_v1', 'O que é renda passiva?', 0, 'Salário mensal obrigatório', 'Renda que pode ser recebida de um emprego fixo que exige a mesma troca direta de tempo por dinheiro em cada recebimento'),
    ('seed_financas_medio_v1', 'O que é renda passiva?', 2, 'Uma despesa', 'Renda que pode ser recebida de empréstimos que exigem o pagamento de juros ao banco em cada mês do contrato assinado'),
    ('seed_financas_medio_v1', 'O que é renda passiva?', 3, 'Apenas dinheiro emprestado', 'Renda que pode ser recebida de bônus extraordinários pagos pela empresa uma única vez durante todo o ano de trabalho'),
    ('seed_financas_medio_v1', 'Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 0, 'Porque garante prejuízo', 'Porque a perda dessa fonte pode aumentar significativamente os impostos devidos ao governo'),
    ('seed_financas_medio_v1', 'Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 1, 'Porque aumenta automaticamente os investimentos', 'Porque a perda dessa fonte costuma reduzir significativamente o valor das dívidas existentes'),
    ('seed_financas_medio_v1', 'Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 3, 'Porque elimina despesas', 'Porque essa fonte costuma exigir mais gastos com transporte e alimentação do trabalhador'),
    ('seed_financas_medio_v1', 'O que é margem de segurança financeira?', 0, 'Valor de um imposto', 'Espaço entre o valor emprestado e o valor das prestações ou taxas cobradas'),
    ('seed_financas_medio_v1', 'O que é margem de segurança financeira?', 1, 'Quantidade de empréstimos', 'Espaço entre o preço de venda e o custo de produção ou compra do produto'),
    ('seed_financas_medio_v1', 'O que é margem de segurança financeira?', 3, 'Valor de uma multa', 'Espaço entre a data de recebimento do salário e a data de pagamento das contas'),
    ('seed_financas_medio_v1', 'Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', 1, '60%', '20%'),
    ('seed_financas_medio_v1', 'Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?', 2, '90%', '125%'),
    ('seed_financas_medio_v1', 'Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?', 1, '4.250 MZN', '6.250 MZN'),
    ('seed_financas_medio_v1', 'O que é patrimônio líquido?', 1, 'Soma de todas as despesas mensais', 'Soma entre ativos e obrigações'),
    ('seed_financas_medio_v1', 'O que é patrimônio líquido?', 2, 'Apenas salário', 'Diferença entre receitas e despesas'),
    ('seed_financas_medio_v1', 'O que é patrimônio líquido?', 3, 'Apenas dinheiro em espécie', 'Diferença entre salário e impostos'),
    ('seed_financas_medio_v1', 'Por que diversificar pode reduzir a concentração de risco?', 0, 'Porque elimina todos os riscos', 'Porque os recursos ficam totalmente dependentes do desempenho de um único banco ou instituição'),
    ('seed_financas_medio_v1', 'Por que diversificar pode reduzir a concentração de risco?', 2, 'Porque garante lucro', 'Porque os recursos passam a render o dobro do desempenho médio de cada ativo ou categoria escolhido'),
    ('seed_financas_medio_v1', 'Por que diversificar pode reduzir a concentração de risco?', 3, 'Porque impede perdas em qualquer situação', 'Porque os recursos deixam de pagar impostos sobre o desempenho de cada ativo ou categoria')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças médio lote 1: 25 primeiras perguntas do seed 046: % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_medio_v1', 'Qual é a principal diferença entre poupança e investimento?', 'A poupança prioriza guardar com segurança e poder usar o dinheiro quando precisar. O investimento busca render mais, mas aceita algum risco. A poupança nem sempre rende mais, e todo investimento tem algum risco.', 'A poupança prioriza guardar com segurança e poder usar o dinheiro quando precisar. O investimento busca render mais, mas aceita algum risco. Por isso a diferença está no objetivo: reserva e acesso rápido de um lado, rendimento e risco do outro.'),
    ('seed_financas_medio_v1', 'O que é liquidez?', 'Liquidez é a facilidade de transformar um bem em dinheiro rapidamente, sem perder valor. Dinheiro vivo tem liquidez total; uma casa tem pouca. Nada a ver com inflação, dívidas ou impostos.', 'Liquidez é a facilidade de transformar um bem em dinheiro rapidamente, sem perder valor. Dinheiro vivo tem liquidez total; uma casa tem pouca. Liquidez não é valorização, crédito nem o total guardado em conta.'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?', 'A reserva de emergência pode ser necessária de repente, para despesas inesperadas, por isso deve ser fácil de acessar. Não serve para luxos nem deve ficar presa em ativos de alto risco.', 'A reserva de emergência pode ser necessária de repente, para despesas inesperadas, por isso deve ser fácil de acessar. Ela não serve para render o máximo nem para compras planejadas, e prender o dinheiro por anos tira essa facilidade.'),
    ('seed_financas_medio_v1', 'O que é crédito?', 'Crédito é a possibilidade de usar dinheiro ou recursos agora, com a obrigação de pagar depois, nas condições combinadas. Não é dinheiro de graça, imposto nem salário.', 'Crédito é a possibilidade de usar dinheiro ou recursos agora, com a obrigação de pagar depois, nas condições combinadas. Receber sem devolver, pagar tributos ou receber pelo trabalho são situações diferentes.'),
    ('seed_financas_medio_v1', 'Por que o prazo de um empréstimo influencia seu custo?', 'O prazo muda por quanto tempo se pagam juros e outros encargos. Em geral, quanto mais longo o prazo, mais juros se pagam no total, mesmo com prestações menores. O prazo não elimina juros nem transforma dívida em renda.', 'O prazo muda por quanto tempo se pagam juros e outros encargos. Em geral, quanto mais longo o prazo, mais juros se pagam no total, mesmo com prestações menores. Ele não muda o valor liberado nem a renda de quem pediu, e não isenta de juros.'),
    ('seed_financas_medio_v1', 'O que significa risco financeiro?', 'Risco financeiro é a possibilidade de perder dinheiro ou de o resultado ser diferente do esperado. Quase toda aplicação tem algum risco; garantia total de lucro ou ausência de incerteza não existem.', 'Risco financeiro é a possibilidade de perder dinheiro ou de o resultado ser diferente do esperado. Quase toda aplicação tem algum risco; ele não é o retorno maior, nem a devolução obrigatória, nem o dinheiro parado.'),
    ('seed_financas_medio_v1', 'Qual fator deve ser considerado ao comparar dois empréstimos?', 'Ao comparar empréstimos, olhe taxas, encargos, prazo e custo total, e não só a prestação. Nome da instituição, cor do cartão ou publicidade não dizem quanto o empréstimo realmente custa.', 'Ao comparar empréstimos, olhe taxas, encargos, prazo e custo total, e não só a prestação. Marca, atendimento, brindes ou a aparência do cartão não dizem quanto o empréstimo realmente custa.'),
    ('seed_financas_medio_v1', 'Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?', 'Separar o dinheiro por objetivo facilita ver quanto já foi guardado para cada um. Isso ajuda a manter o foco. Não garante lucro, não elimina riscos e não impede gastos.', 'Separar o dinheiro por objetivo facilita ver quanto já foi guardado para cada um. Isso ajuda a manter o foco. Não aumenta sozinho o rendimento, não dispensa o acompanhamento das despesas nem reduz impostos.'),
    ('seed_financas_medio_v1', 'O que é renda ativa?', 'Renda ativa é a que se recebe em troca de trabalho ou de prestação de serviços, como o salário. Juros, dividendos e dinheiro achado não são renda ativa.', 'Renda ativa é a que se recebe em troca de trabalho ou de prestação de serviços, como o salário. Juros, aluguéis e dividendos vêm de bens e aplicações, e prêmios ou presentes não dependem de trabalho.'),
    ('seed_financas_medio_v1', 'O que é renda passiva?', 'Renda passiva é a que vem de bens ou atividades que não pedem trocar tempo por dinheiro a cada recebimento, como o aluguel de um imóvel. Salário obrigatório, despesa ou dinheiro emprestado não são renda passiva.', 'Renda passiva é a que vem de bens ou atividades que não pedem trocar tempo por dinheiro a cada recebimento, como o aluguel de um imóvel. Emprego fixo, empréstimos com juros a pagar ou um bônus único não são renda passiva.'),
    ('seed_financas_medio_v1', 'Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?', 'Com uma só fonte de renda, perdê-la afeta muito o dinheiro disponível, como no desemprego. Ter mais de uma fonte dá mais segurança. Depender de uma só não garante prejuízo nem elimina despesas.', 'Com uma só fonte de renda, perdê-la afeta muito o dinheiro disponível, como no desemprego. Ter mais de uma fonte dá mais segurança. A perda dessa fonte não reduz as dívidas nem muda os impostos.'),
    ('seed_financas_medio_v1', 'O que é margem de segurança financeira?', 'Margem de segurança é a folga entre o dinheiro disponível e as obrigações ou gastos necessários. Quanto maior a folga, mais fácil enfrentar imprevistos. Não é imposto, multa nem empréstimo.', 'Margem de segurança é a folga entre o dinheiro disponível e as obrigações ou gastos necessários. Quanto maior a folga, mais fácil enfrentar imprevistos. Não é a diferença entre empréstimo e prestação, nem entre preço e custo, nem entre datas.'),
    ('seed_financas_medio_v1', 'O que é patrimônio líquido?', 'Patrimônio líquido é a diferença entre o que a pessoa possui (ativos) e o que deve (obrigações). Não é a soma das despesas, nem só o salário ou o dinheiro em espécie.', 'Patrimônio líquido é a diferença entre o que a pessoa possui (ativos) e o que deve (obrigações). Não é a soma dos dois, nem a diferença entre receitas e despesas do mês, nem o salário depois dos impostos.'),
    ('seed_financas_medio_v1', 'Por que diversificar pode reduzir a concentração de risco?', 'Diversificar é espalhar o dinheiro em vários ativos ou categorias, para não depender do desempenho de um só. Reduz a concentração de risco, mas não elimina todos os riscos nem garante lucro.', 'Diversificar é espalhar o dinheiro em vários ativos ou categorias, para não depender do desempenho de um só. Reduz a concentração de risco. Não faz o dinheiro render o dobro nem livra de impostos.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (lote 1 de Finanças médio): % atualizada(s) (previstas: 14).', v_updated;
END $$;
