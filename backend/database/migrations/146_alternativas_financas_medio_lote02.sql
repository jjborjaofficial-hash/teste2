-- Alternativas (BE-003, regularização) — Finanças médio lote 2: perguntas 26 a 38 do seed 046 e 1 a 12 do seed 065.
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
    ('seed_financas_medio_v1', 'O que significa investir de acordo com o próprio perfil de risco?', 0, 'Investir apenas por recomendação de desconhecidos', 'Seguir apenas as recomendações de conhecidos, sem analisar a própria situação financeira'),
    ('seed_financas_medio_v1', 'O que significa investir de acordo com o próprio perfil de risco?', 1, 'Evitar analisar investimentos', 'Evitar analisar os investimentos e aplicar o dinheiro onde outras pessoas estão a aplicar'),
    ('seed_financas_medio_v1', 'O que significa investir de acordo com o próprio perfil de risco?', 2, 'Escolher sempre o investimento de maior risco', 'Escolher o investimento de maior risco para tentar obter o maior retorno possível'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?', 0, 'Transforma a dívida em poupança', 'Reduz o custo total do empréstimo ao longo do prazo'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?', 2, 'Elimina a dívida', 'Cancela parte da dívida no fim do prazo'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?', 3, 'Sempre reduz o valor devido', 'Mantém o valor devido igual ao valor emprestado'),
    ('seed_financas_medio_v1', 'O que significa pagar uma dívida antecipadamente?', 0, 'Aumentar automaticamente a dívida', 'Pagar a dívida apenas no último dia do prazo combinado com o credor'),
    ('seed_financas_medio_v1', 'O que significa pagar uma dívida antecipadamente?', 1, 'Contrair outro empréstimo', 'Renegociar a dívida para ter mais tempo para pagar, com prestações mensais menores'),
    ('seed_financas_medio_v1', 'O que significa pagar uma dívida antecipadamente?', 2, 'Cancelar uma compra futura', 'Pedir um novo empréstimo para pagar a prestação que vence no mês seguinte'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?', 0, 'Garantem lucro', 'Dão direito a um desconto na próxima compra'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?', 1, 'Aumentam automaticamente o saldo', 'Dispensam a necessidade de declarar impostos'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?', 2, 'Eliminam impostos', 'Obrigam o vendedor a devolver o dinheiro'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 1, 'A dívida desaparece automaticamente', 'A dívida fica congelada, sem juros, até a pessoa voltar a pagar'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 2, 'O dinheiro aumenta', 'O credor perdoa a dívida depois de alguns meses de atraso'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 3, 'O credor paga a dívida', 'O banco passa a cobrar menos juros por causa do atraso'),
    ('seed_financas_medio_v1', 'O que é inflação?', 0, 'Aumento automático dos salários', 'Aumento do salário mínimo decidido pelo governo'),
    ('seed_financas_medio_v1', 'O que é inflação?', 1, 'Redução da quantidade de dinheiro', 'Redução da quantidade de dinheiro em circulação'),
    ('seed_financas_medio_v1', 'O que é inflação?', 3, 'Redução geral dos preços', 'Queda geral dos preços ao longo do tempo'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 0, 'Colocar todo o dinheiro em um único ativo', 'Concentrar todo o dinheiro num só investimento seguro'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 1, 'Não investir nunca', 'Guardar todo o dinheiro numa única conta bancária'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 3, 'Investir apenas em dinheiro físico', 'Investir apenas em ações de uma mesma empresa'),
    ('seed_financas_medio_v1', 'O que é juros?', 0, 'Um imposto obrigatório sobre qualquer compra', 'Um imposto obrigatório cobrado pelo governo sobre o valor de cada compra feita'),
    ('seed_financas_medio_v1', 'O que é juros?', 1, 'Um salário adicional garantido', 'Um pagamento extra garantido que o patrão faz todos os meses'),
    ('seed_financas_medio_v1', 'O que é juros?', 2, 'Um desconto permanente', 'Um desconto permanente dado pelo banco aos clientes antigos'),
    ('seed_financas_medio_v1', 'Qual é um possível risco de um investimento?', 0, 'Ganhar sempre', 'Ter o dinheiro devolvido sem qualquer variação'),
    ('seed_financas_medio_v1', 'Qual é um possível risco de um investimento?', 2, 'Nunca sofrer variação', 'Receber o mesmo valor, independentemente do mercado'),
    ('seed_financas_medio_v1', 'Qual é um possível risco de um investimento?', 3, 'Ter lucro garantido', 'Ter um lucro garantido pelo governo ou pelo banco'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:', 0, 'Apenas o nome do funcionário', 'A simpatia de quem atende'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:', 1, 'Apenas a aparência do banco', 'O tamanho da agência do banco'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:', 2, 'Somente a publicidade', 'O prémio que o banco oferece'),
    ('seed_financas_medio_v1', 'O que é patrimônio?', 0, 'Apenas salário mensal', 'Conjunto de rendimentos que uma pessoa recebe ao longo do mês'),
    ('seed_financas_medio_v1', 'O que é patrimônio?', 2, 'Apenas dívidas', 'Conjunto de dívidas e empréstimos que uma pessoa ou entidade tem de pagar'),
    ('seed_financas_medio_v1', 'O que é patrimônio?', 3, 'Apenas dinheiro disponível na carteira', 'Dinheiro disponível numa pessoa ou entidade, em notas e moedas'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 1, 'Nunca muda', 'Permanece igual'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 2, 'Sempre aumenta', 'Aumenta junto com os preços'),
    ('seed_financas_medio_v1', 'Por que é importante verificar a origem de uma oportunidade de investimento?', 0, 'Para garantir lucro de 100%', 'Para garantir o retorno prometido'),
    ('seed_financas_medio_v1', 'Por que é importante verificar a origem de uma oportunidade de investimento?', 2, 'Para aumentar automaticamente o investimento', 'Para receber um desconto no valor investido'),
    ('seed_financas_medio_v1', 'Por que é importante verificar a origem de uma oportunidade de investimento?', 3, 'Para evitar qualquer imposto', 'Para ficar isento de pagar impostos'),
    ('seed_financas_medio_v2', 'O que é diversificação de investimentos?', 1, 'Colocar todo dinheiro em um único investimento', 'Concentrar todo o dinheiro num único investimento que pareça seguro'),
    ('seed_financas_medio_v2', 'O que é diversificação de investimentos?', 2, 'Gastar todo o dinheiro disponível', 'Guardar todo o dinheiro disponível numa conta de poupança'),
    ('seed_financas_medio_v2', 'O que é diversificação de investimentos?', 3, 'Evitar qualquer investimento', 'Escolher o investimento que rendeu mais no último ano'),
    ('seed_financas_medio_v2', 'Qual é a principal finalidade de uma reserva de emergência?', 0, 'Aumentar gastos mensais', 'Pagar as despesas de rotina do mês, como alimentação e renda'),
    ('seed_financas_medio_v2', 'Qual é a principal finalidade de uma reserva de emergência?', 1, 'Comprar produtos de luxo', 'Comprar produtos em promoção quando surgir uma boa oferta'),
    ('seed_financas_medio_v2', 'Qual é a principal finalidade de uma reserva de emergência?', 3, 'Fazer investimentos de alto risco', 'Fazer investimentos de alto risco para tentar ganhar mais'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?', 0, 'Impedem investimentos', 'Fazem o dinheiro render o mesmo valor fixo em cada ano'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?', 1, 'Eliminam qualquer lucro', 'Reduzem o valor investido quando o prazo é muito longo'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?', 3, 'Sempre reduzem o valor investido', 'Só funcionam para investimentos de curto prazo, com duração até um ano'),
    ('seed_financas_medio_v2', 'O que significa um investimento de alta liquidez?', 0, 'Possui prazo infinito', 'Só pode ser vendido no fim de vários anos'),
    ('seed_financas_medio_v2', 'O que significa um investimento de alta liquidez?', 1, 'Não pode ser vendido', 'Garante lucro a quem o vender depressa'),
    ('seed_financas_medio_v2', 'O que significa um investimento de alta liquidez?', 3, 'Sempre apresenta prejuízo', 'Tem um prazo mínimo de dez anos para o dinheiro poder sair'),
    ('seed_financas_medio_v2', 'O que é risco financeiro?', 0, 'Ausência de decisões', 'Situação em que uma pessoa não tem dinheiro para pagar as dívidas'),
    ('seed_financas_medio_v2', 'O que é risco financeiro?', 2, 'Aumento automático do dinheiro', 'Situação em que o dinheiro aumenta automaticamente sem decisões'),
    ('seed_financas_medio_v2', 'O que é risco financeiro?', 3, 'Garantia de lucro', 'Garantia dada pelo banco de que o dinheiro investido será devolvido no prazo'),
    ('seed_financas_medio_v2', 'O que é retorno de investimento?', 1, 'Conta mensal', 'Valor pago todos os meses por um empréstimo'),
    ('seed_financas_medio_v2', 'O que é retorno de investimento?', 2, 'Valor perdido', 'Valor que se devolve ao banco depois de um empréstimo'),
    ('seed_financas_medio_v2', 'O que é retorno de investimento?', 3, 'Dívida bancária', 'Comissão que o banco cobra por guardar o dinheiro'),
    ('seed_financas_medio_v2', 'O que é perfil de investidor?', 0, 'Número de contas bancárias', 'Quantidade de contas que o investidor tem em bancos e corretoras diferentes'),
    ('seed_financas_medio_v2', 'O que é perfil de investidor?', 2, 'Nome do banco', 'Nome do banco ou da corretora onde se faz o investimento'),
    ('seed_financas_medio_v2', 'O que é perfil de investidor?', 3, 'Quantidade de dinheiro gasto', 'Valor total que o investidor tem disponível para investir'),
    ('seed_financas_medio_v2', 'Quais são exemplos de perfis de investidores?', 0, 'Pequeno, médio e grande', 'Curto, médio e longo prazo'),
    ('seed_financas_medio_v2', 'Quais são exemplos de perfis de investidores?', 2, 'Simples e complexo', 'Nacional, regional e estrangeiro'),
    ('seed_financas_medio_v2', 'Quais são exemplos de perfis de investidores?', 3, 'Nacional e internacional', 'Privado, público e misto'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor conservador?', 0, 'Busca sempre o maior risco', 'Procura o maior risco possível para conseguir maiores retornos'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor conservador?', 2, 'Aceita qualquer risco', 'Aceita riscos moderados para equilibrar segurança e retorno'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor conservador?', 3, 'Investe sem analisar', 'Investe seguindo a opinião de amigos, sem analisar'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor agressivo?', 0, 'Não analisa oportunidades', 'Prefere segurança, mesmo com menos retorno'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor agressivo?', 1, 'Evita totalmente investimentos', 'Aceita riscos moderados para equilibrar retorno'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor agressivo?', 2, 'Guarda apenas dinheiro físico', 'Guarda o dinheiro em casa para evitar perdas'),
    ('seed_financas_medio_v2', 'O que é mercado financeiro?', 0, 'Um banco específico', 'Local onde as pessoas compram e vendem produtos do dia a dia'),
    ('seed_financas_medio_v2', 'O que é mercado financeiro?', 2, 'Um aplicativo', 'Aplicativo do banco usado para consultar o saldo das contas'),
    ('seed_financas_medio_v2', 'O que é mercado financeiro?', 3, 'Apenas lojas comerciais', 'Conjunto de empresas que vendem produtos ao público'),
    ('seed_financas_medio_v2', 'O que é uma ação?', 0, 'Um empréstimo bancário', 'Um título que representa um empréstimo feito a uma empresa'),
    ('seed_financas_medio_v2', 'O que é uma ação?', 1, 'Uma despesa', 'Um empréstimo que a empresa pede a um banco'),
    ('seed_financas_medio_v2', 'O que é uma ação?', 3, 'Uma conta mensal', 'Um documento que comprova o pagamento de um imposto')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças médio lote 2: perguntas 26 a 38 do seed 046 e 1 a 12 do seed 065: % alternativa(s) errada(s) atualizada(s) (esperado: 74).', v_updated;
END $$;

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.new_explanation
  FROM (VALUES
    ('seed_financas_medio_v1', 'O que significa investir de acordo com o próprio perfil de risco?', 'Investir conforme o perfil de risco é escolher aplicações compatíveis com a sua capacidade e disposição de lidar com perdas e oscilações. Seguir desconhecidos, não analisar ou escolher sempre o maior risco são erros.', 'Investir conforme o perfil de risco é escolher aplicações compatíveis com a sua capacidade e disposição de lidar com perdas e oscilações. Quem tolera pouco risco não deve copiar quem tolera muito: o investimento certo para uma pessoa pode ser inadequado para outra.'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?', 'Os juros aumentam o custo total do empréstimo: no fim, paga-se mais do que o valor emprestado. Os juros não eliminam a dívida, não a transformam em poupança e não reduzem o valor devido.', 'Os juros aumentam o custo total do empréstimo: no fim, paga-se mais do que o valor emprestado, e quanto maior a taxa ou o prazo, maior o custo. Por isso vale comparar taxas antes de pedir crédito.'),
    ('seed_financas_medio_v1', 'O que significa pagar uma dívida antecipadamente?', 'Pagar antecipadamente é quitar a dívida, toda ou em parte, antes do prazo previsto. Não aumenta a dívida nem é contrair outro empréstimo, e pode reduzir os juros que se pagariam.', 'Pagar antecipadamente é quitar a dívida, toda ou em parte, antes do prazo previsto, e pode reduzir os juros que se pagariam. Renegociar para ter mais tempo ou pedir outro empréstimo não é pagar antes: é adiar ou trocar uma dívida por outra.'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?', 'O comprovativo serve como prova de que o pagamento foi feito, útil se houver dúvida ou cobrança indevida. Não aumenta o saldo, não elimina impostos e não garante lucro.', 'O comprovativo serve como prova de que o pagamento foi feito, útil se houver dúvida ou cobrança indevida. Não dá descontos, não dispensa obrigações fiscais e não obriga a devolução: é só evidência.'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 'Ignorar as obrigações financeiras pode acumular encargos, atrasos e outros problemas. A dívida não desaparece sozinha e o credor não a paga no lugar da pessoa.', 'Ignorar as obrigações financeiras pode acumular encargos, atrasos e outros problemas. A dívida não fica congelada, não é perdoada sozinha e atrasar não faz baixar os juros: o custo tende a crescer.'),
    ('seed_financas_medio_v1', 'O que é inflação?', 'Inflação é o aumento geral dos preços ao longo do tempo. Com ela, a mesma quantia compra menos. Não é aumento automático dos salários nem queda dos preços.', 'Inflação é o aumento geral dos preços ao longo do tempo. Com ela, a mesma quantia compra menos. É diferente de um aumento de salários e é o contrário de uma queda geral dos preços.'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 'Diversificar é distribuir o dinheiro entre diferentes investimentos, para não depender de um só. Pôr tudo num único ativo, ou não investir, não é diversificar.', 'Diversificar é distribuir o dinheiro entre diferentes investimentos, para não depender de um só. Concentrar tudo num único investimento, mesmo que seguro, ou numa só conta, não é diversificar.'),
    ('seed_financas_medio_v1', 'O que é juros?', 'Juros são o valor ligado ao uso ou ao rendimento do dinheiro ao longo do tempo: quem pede emprestado paga juros, e quem aplica pode receber. Não são imposto sobre compras, salário extra nem desconto.', 'Juros são o valor ligado ao uso ou ao rendimento do dinheiro ao longo do tempo: quem pede emprestado paga juros, e quem aplica pode receber. Não são imposto, pagamento do patrão nem desconto.'),
    ('seed_financas_medio_v1', 'Qual é um possível risco de um investimento?', 'Um risco de investir é perder parte ou todo o capital aplicado. Lucro garantido, ganhar sempre ou nunca variar não existem em investimentos com risco.', 'Um risco de investir é perder parte ou todo o capital aplicado. Investimentos com risco não garantem a devolução do valor, nem um retorno fixo, nem lucro garantido por ninguém.'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:', 'Antes de contratar um empréstimo, confira as taxas, o prazo e o custo total, para saber quanto vai pagar. A aparência do banco, a publicidade ou o nome do funcionário não dizem isso.', 'Antes de contratar um empréstimo, confira as taxas, o prazo e o custo total, para saber quanto vai pagar. A simpatia do atendimento, o tamanho da agência ou os brindes não dizem nada sobre isso.'),
    ('seed_financas_medio_v1', 'O que é patrimônio?', 'Patrimônio é o conjunto de bens, direitos e obrigações de uma pessoa ou entidade. Não é só o salário, só as dívidas ou só o dinheiro que se leva na carteira.', 'Patrimônio é o conjunto de bens, direitos e obrigações de uma pessoa ou entidade. Não é só o rendimento do mês, só as dívidas ou só o dinheiro vivo disponível.'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 'Quando os preços sobem muito, o poder de compra pode diminuir: a mesma quantia compra menos coisas. Ele não fica igual, não aumenta sempre e não duplica sozinho.', 'Quando os preços sobem muito, o poder de compra pode diminuir: a mesma quantia compra menos coisas. Ele não fica igual, não acompanha os preços sozinho e não duplica.'),
    ('seed_financas_medio_v1', 'Por que é importante verificar a origem de uma oportunidade de investimento?', 'Verificar a origem da oportunidade ajuda a reduzir o risco de cair em fraude. Não garante lucro nem isenta de impostos. Desconfie de ofertas de quem você não conhece ou não consegue confirmar.', 'Verificar a origem da oportunidade ajuda a reduzir o risco de cair em fraude. Isso não garante retorno, não dá desconto e não isenta de impostos. Desconfie de ofertas de quem você não conhece ou não consegue confirmar.'),
    ('seed_financas_medio_v2', 'O que é diversificação de investimentos?', 'Diversificar é distribuir o dinheiro em diferentes tipos de investimento para reduzir riscos. Pôr tudo num só investimento, gastar tudo ou evitar investir não é diversificar.', 'Diversificar é distribuir o dinheiro em diferentes tipos de investimento para reduzir riscos. Concentrar tudo num só investimento, mesmo que pareça seguro, ou escolher só o que rendeu mais, não é diversificar.'),
    ('seed_financas_medio_v2', 'Qual é a principal finalidade de uma reserva de emergência?', 'A reserva de emergência serve para cobrir situações inesperadas sem precisar recorrer a dívidas. Não é para gastos mensais, produtos de luxo nem investimentos de alto risco.', 'A reserva de emergência serve para cobrir situações inesperadas sem precisar recorrer a dívidas. Não é para as despesas normais do mês, nem para aproveitar promoções ou arriscar em investimentos.'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?', 'Nos juros compostos, os juros rendem também sobre os juros anteriores. Em longo prazo, isso pode aumentar muito o crescimento do dinheiro. Eles não eliminam o lucro nem reduzem sempre o valor investido.', 'Nos juros compostos, os juros rendem também sobre os juros anteriores. Em longo prazo, isso pode aumentar muito o crescimento do dinheiro. Não é um rendimento fixo por ano (isso seriam juros simples) e funciona melhor quanto maior o prazo.'),
    ('seed_financas_medio_v2', 'O que significa um investimento de alta liquidez?', 'Alta liquidez significa que o investimento pode ser convertido em dinheiro rapidamente. Não quer dizer prazo infinito, impossibilidade de venda nem prejuízo.', 'Alta liquidez significa que o investimento pode ser convertido em dinheiro rapidamente. Não tem a ver com prazos longos de saída nem com garantia de lucro: liquidez é rapidez para virar dinheiro.'),
    ('seed_financas_medio_v2', 'O que é risco financeiro?', 'Risco financeiro é a possibilidade de perder dinheiro ou de não alcançar o resultado esperado. Não é ausência de decisões, aumento automático do dinheiro nem garantia de lucro.', 'Risco financeiro é a possibilidade de perder dinheiro ou de não alcançar o resultado esperado. Não é uma situação de dívidas, nem um aumento automático, nem uma garantia de devolução.'),
    ('seed_financas_medio_v2', 'O que é retorno de investimento?', 'Retorno é o ganho ou resultado obtido depois de aplicar dinheiro. Pode ser positivo ou negativo. Não é conta mensal, valor perdido nem dívida bancária.', 'Retorno é o ganho ou resultado obtido depois de aplicar dinheiro. Pode ser positivo ou negativo. Não é prestação de empréstimo nem comissão do banco.'),
    ('seed_financas_medio_v2', 'O que é perfil de investidor?', 'Perfil de investidor são as características da pessoa ligadas à tolerância ao risco, por exemplo se é mais cautelosa ou mais arrojada. Ajuda a escolher investimentos adequados. Não é o nome do banco nem o número de contas.', 'Perfil de investidor são as características da pessoa ligadas à tolerância ao risco, por exemplo se é mais cautelosa ou mais arrojada. Ajuda a escolher investimentos adequados. Não é o número de contas, o nome do banco nem o valor disponível.'),
    ('seed_financas_medio_v2', 'Quais são exemplos de perfis de investidores?', 'Os perfis de investidor mais comuns são conservador, moderado e agressivo, conforme a tolerância ao risco. Pequeno, médio, grande, simples, complexo, nacional ou internacional não são perfis de investidor.', 'Os perfis de investidor mais comuns são conservador, moderado e agressivo, conforme a tolerância ao risco. Curto, médio e longo prazo descrevem prazos, e as outras opções descrevem a origem ou o tipo de entidade, não o perfil de risco.'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor conservador?', 'O investidor conservador prefere segurança, mesmo que isso signifique ter menos chance de retorno. Ele não busca sempre o maior risco, não aceita qualquer risco e não investe sem analisar.', 'O investidor conservador prefere segurança, mesmo que isso signifique ter menos chance de retorno. Quem procura o maior risco é o agressivo, quem equilibra segurança e retorno é o moderado, e investir só pela opinião de outros não é um perfil.'),
    ('seed_financas_medio_v2', 'O que caracteriza um investidor agressivo?', 'O investidor agressivo aceita riscos maiores em busca de retornos maiores. Mesmo assim, analisa as oportunidades: não evita investir nem guarda só dinheiro físico.', 'O investidor agressivo aceita riscos maiores em busca de retornos maiores. Quem prefere segurança é o conservador, quem equilibra é o moderado, e guardar o dinheiro em casa não é um perfil de investimento.'),
    ('seed_financas_medio_v2', 'O que é mercado financeiro?', 'Mercado financeiro é o ambiente onde acontecem operações com dinheiro e investimentos, como compra e venda de ações e títulos. Não é um banco específico, um aplicativo ou só lojas comerciais.', 'Mercado financeiro é o ambiente onde acontecem operações com dinheiro e investimentos, como compra e venda de ações e títulos. Não é o comércio de produtos do dia a dia, um aplicativo bancário nem um conjunto de lojas.'),
    ('seed_financas_medio_v2', 'O que é uma ação?', 'Ação é uma pequena parte da propriedade de uma empresa. Quem a compra passa a ser sócio dela. Não é empréstimo bancário, despesa nem conta mensal.', 'Ação é uma pequena parte da propriedade de uma empresa. Quem a compra passa a ser sócio dela. Não é um título de dívida, nem um empréstimo, nem um comprovativo de imposto.')
  ) AS v(source, statement, old_explanation, new_explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation = v.old_explanation;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações coerentes com as novas alternativas (Finanças médio lote 2: perguntas 26 a 38 do seed 046 e 1 a 12 do seed 065): % atualizada(s) (previstas: 25).', v_updated;
END $$;
