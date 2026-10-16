-- Ajuste de alternativas (BE-003, resíduo de pistas) — Finanças: 71 alternativas erradas reescritas em 57 perguntas que só tinham avisos de pista.
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é ajustado (comprimento/palavras).
-- O nome `*_ajuste_alternativas_*` diz ao teste dos lotes que este texto substitui o do lote.
-- Segurança: só altera question_alternatives.label, só de erradas (is_correct = FALSE), e só se o texto atual ainda for exatamente
-- o original (idempotente; nunca sobrescreve edição posterior). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_financas_dificil_v2', 'O que é balanço patrimonial?', 0, 'Controle dos funcionários contratados e dos salários pagos', 'Controle dos funcionários contratados, dos salários e das férias'),
    ('seed_financas_facil_v1', 'Qual atitude representa consumo consciente?', 0, 'Comprar o que está em destaque na vitrine da loja', 'Seguir a moda, a publicidade e as sugestões do vendedor'),
    ('seed_financas_facil_v1', 'Qual é a principal finalidade de um orçamento pessoal?', 3, 'Evitar qualquer tipo de gasto', 'Garantir lucro nos investimentos'),
    ('seed_financas_dificil_v1', 'Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 1, 'Os rendimentos ficam fixos e não aumentam com o tempo', 'Os rendimentos costumam ficar fixos e não aumentar com o tempo'),
    ('seed_financas_dificil_v1', 'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 2, 'As vendas cobrem os custos sozinhas', 'As vendas costumam cobrir os custos por si'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 0, 'A fixa muda todos os meses conforme o mercado; a variável permanece igual durante o contrato', 'A fixa muda a cada mês conforme o mercado; a variável permanece igual durante o contrato'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?', 1, 'As duas permanecem iguais durante o contrato, e a diferença está só no valor da prestação', 'As duas costumam permanecer iguais durante o contrato, e a diferença está no valor da prestação'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de comparar preços antes de comprar?', 2, 'Obriga a loja a baixar o preço do produto', 'Costuma obrigar a loja a baixar o preço do produto'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 0, 'Todo investimento oferece liquidez máxima e rentabilidade máxima ao mesmo tempo, em qualquer mercado', 'Investimentos de resgate imediato costumam oferecer também a maior rentabilidade do mercado financeiro'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 1, 'Investimentos líquidos não rendem nada, e só os investimentos de longo prazo dão retorno', 'Investimentos líquidos não rendem nada, e os de longo prazo dão retorno'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 0, 'Gastar todos os recursos da empresa em novos investimentos', 'Distribuir os lucros da empresa entre os sócios'),
    ('seed_financas_medio_v2', 'O que é sustentabilidade financeira?', 3, 'Evitar o planejamento para decidir só quando surgem problemas', 'Evitar o planejamento para decidir quando surgem problemas'),
    ('seed_financas_facil_v1', 'O que caracteriza uma despesa variável?', 0, 'É sempre uma dívida contraída junto do banco', 'É uma dívida contraída junto do banco'),
    ('seed_financas_facil_v1', 'O que caracteriza uma despesa variável?', 1, 'Só precisa de ser paga uma vez em toda a vida', 'Precisa de ser paga uma vez em toda a vida'),
    ('seed_financas_facil_v1', 'O que caracteriza uma despesa variável?', 3, 'Possui sempre exatamente o mesmo valor', 'Costuma manter exatamente o mesmo valor'),
    ('seed_financas_medio_v2', 'O que é orçamento empresarial?', 0, 'Lista dos funcionários e dos salários que a empresa paga em cada mês do ano', 'Lista dos funcionários, dos cargos e dos salários da empresa'),
    ('seed_financas_facil_v2', 'O que acontece quando alguém atrasa um pagamento?', 1, 'A dívida é cancelada pelo banco', 'Pode ser cancelada pelo banco'),
    ('seed_financas_dificil_v3', 'O que é EBITDA?', 2, 'Salário empresarial pago aos administradores e diretores da empresa', 'Salário empresarial, pago em cada período aos administradores e diretores da empresa'),
    ('seed_financas_dificil_v2', 'O que é demonstração de resultados?', 2, 'Lista dos investimentos pessoais feitos pelos sócios ao longo da vida', 'Lista dos investimentos pessoais, feitos pelos sócios ao longo da vida'),
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?', 2, 'Dinheiro presente não pode ser investido porque só rende depois de um período longo', 'Dinheiro presente não pode ser investido e rende após um período longo'),
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?', 3, 'Todo dinheiro mantém o mesmo valor em qualquer momento porque a moeda não muda', 'Uma quantia hoje e a mesma quantia no futuro têm exatamente o mesmo valor econômico'),
    ('seed_financas_dificil_v2', 'O que é derivativo financeiro?', 2, 'Cartão de crédito com limite definido pelo banco emissor, usado para comprar a prazo nas lojas', 'Cartão de crédito com limite definido pelo banco emissor'),
    ('seed_financas_facil_v2', 'O que é uma despesa fixa?', 0, 'Despesa que muda de valor todos os meses do ano', 'Despesa que muda de valor a cada mês do ano'),
    ('seed_financas_facil_v2', 'O que é uma despesa fixa?', 2, 'Despesa feita uma só vez, sem se repetir no tempo', 'Despesa feita uma vez, sem se repetir no tempo'),
    ('seed_financas_facil_v2', 'O que é um objetivo financeiro de curto prazo?', 0, 'Meta que exige vários anos de planejamento', 'Meta que pode exigir vários anos de planejamento'),
    ('seed_financas_medio_v2', 'O que é deflação?', 1, 'Aumento do valor das dívidas por causa dos juros', 'Elevação do valor das dívidas por causa dos juros'),
    ('seed_financas_dificil_v2', 'O que é análise fundamentalista de empresas?', 1, 'Escolha de ações baseada na campanha publicitária feita pela empresa', 'Escolha de ações, baseada na campanha publicitária feita pela empresa'),
    ('seed_financas_medio_v2', 'O que é renda variável?', 1, 'Imposto cobrado sobre os lucros obtidos com investimentos', 'Imposto que pode ser cobrado sobre os lucros obtidos com investimentos'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?', 1, 'Relação entre o número de funcionários e a receita total da empresa', 'Relação entre o número de funcionários e a receita, geralmente expressa por pessoa'),
    ('seed_financas_facil_v1', 'Qual destes é um exemplo de despesa fixa?', 3, 'Compra ocasional de roupa', 'Compra de roupa'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 0, 'Compra regular de produtos com preço fixo todos os meses', 'Compra regular de produtos com preço fixo a cada mês'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 1, 'Despesa mensal cujo valor permanece igual todos os meses', 'Despesa mensal cujo valor permanece igual de mês para mês'),
    ('seed_financas_medio_v2', 'O que é renda fixa?', 2, 'Investimento em que o retorno muda todos os dias conforme o mercado', 'Investimento em que o retorno muda a cada dia conforme o mercado'),
    ('seed_financas_medio_v2', 'Por que o cheque especial deve ser usado com cuidado?', 2, 'Porque aumenta o salário de quem o utiliza', 'Porque costuma aumentar o salário de quem o utiliza'),
    ('seed_financas_medio_v1', 'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?', 3, 'Duplica depressa', 'Costuma duplicar depressa'),
    ('seed_financas_dificil_v3', 'O que é análise de viabilidade financeira?', 3, 'Publicidade empresarial feita para apresentar o projeto', 'Publicidade empresarial que costuma apresentar o projeto ao público'),
    ('seed_financas_facil_v2', 'O que é uma despesa variável?', 0, 'Gasto que tem o mesmo valor todos os meses', 'Gasto que costuma ter o mesmo valor a cada mês'),
    ('seed_financas_medio_v2', 'Por que um bom score de crédito é importante?', 0, 'Garante que a pessoa ficará rica com o passar do tempo', 'Costuma garantir que a pessoa ficará rica com o passar do tempo'),
    ('seed_financas_dificil_v1', 'Por que correlação entre ativos pode ser relevante na diversificação?', 1, 'Porque ativos com comportamentos diferentes impedem qualquer oscilação no valor da carteira', 'Porque ativos com comportamentos diferentes costumam impedir oscilações no valor da carteira'),
    ('seed_financas_medio_v4', 'Por que manter um bom histórico de pagamentos pode ser importante?', 1, 'Dá direito a uma isenção de impostos todos os anos', 'Costuma dar direito a isenção de impostos a cada ano'),
    ('seed_financas_medio_v2', 'Qual é uma boa prática para melhorar a saúde financeira?', 2, 'Fazer dívidas constantemente para manter o padrão de vida', 'Fazer dívidas constantes, sem planejar o futuro'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?', 1, 'Aumento garantido dos lucros das empresas em todos os setores', 'Aumento garantido dos lucros das empresas nos setores produtivos'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?', 2, 'Redução dos impostos em todos os períodos de crise', 'Redução dos impostos nos períodos de crise'),
    ('seed_financas_dificil_v3', 'O que é custo fixo?', 0, 'Custo que muda sempre que a empresa aumenta o preço de venda', 'Custo que varia conforme a empresa aumenta o preço de venda'),
    ('seed_financas_dificil_v1', 'Qual é a relação entre risco e retorno em investimentos?', 3, 'Maior risco garante maior lucro, porque o investidor assume mais responsabilidade', 'Em geral, maior risco garante maior lucro a quem assume mais responsabilidade'),
    ('seed_financas_medio_v1', 'Qual é o efeito de uma taxa de juros sobre uma dívida?', 2, 'Cancela parte da dívida no fim do prazo', 'Costuma cancelar parte da dívida no fim do prazo'),
    ('seed_financas_medio_v2', 'O que é um ativo financeiro?', 1, 'Valor pago ao governo sobre os rendimentos ou as compras', 'Valor que pode ser pago ao governo sobre rendimentos ou compras'),
    ('seed_financas_medio_v2', 'O que é uma ação?', 1, 'Um empréstimo que a empresa pede a um banco', 'Empréstimo que a empresa pede a um banco'),
    ('seed_financas_dificil_v2', 'O que é risco não sistêmico?', 0, 'Risco que atinge todos os mercados ao mesmo tempo e não depende da carteira', 'Risco que atinge os mercados ao mesmo tempo e não depende da carteira'),
    ('seed_financas_dificil_v2', 'O que é risco não sistêmico?', 2, 'Risco ligado a alterações do câmbio ou da inflação que afetam todas as empresas', 'Risco ligado a alterações do câmbio ou da inflação que afetam as empresas'),
    ('seed_financas_dificil_v2', 'O que é risco não sistêmico?', 3, 'Risco que aumenta quando o investidor divide o dinheiro por vários ativos', 'Risco que costuma aumentar quando o investidor divide o dinheiro por vários ativos'),
    ('seed_financas_dificil_v1', 'O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?', 2, 'Reduz os riscos porque a pessoa age com confiança e rapidez', 'Costuma reduzir os riscos porque a pessoa age com confiança e rapidez'),
    ('seed_financas_dificil_v1', 'Qual é uma característica de uma decisão financeira bem fundamentada?', 2, 'Deixa de lado os riscos para focar apenas no ganho esperado', 'Deixa os riscos de lado, para focar no ganho esperado'),
    ('seed_financas_facil_v1', 'O que acontece quando uma pessoa gasta continuamente mais do que recebe?', 1, 'Reduz seus gastos', 'Costuma reduzir seus gastos'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?', 3, 'O prazo máximo que a pessoa tem para pagar a fatura', 'O prazo máximo que a pessoa costuma ter para pagar a fatura'),
    ('seed_financas_medio_v2', 'Qual é o efeito dos juros compostos em investimentos de longo prazo?', 0, 'Fazem o dinheiro render o mesmo valor fixo em cada ano', 'Costumam fazer o dinheiro render o mesmo valor fixo em cada ano'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 0, 'Concentrar todo o dinheiro num só investimento seguro', 'Concentrar todo o dinheiro num investimento seguro'),
    ('seed_financas_medio_v1', 'O que significa diversificar investimentos?', 3, 'Investir apenas em ações de uma mesma empresa', 'Investir em ações de uma mesma empresa'),
    ('seed_financas_medio_v1', 'Por que é importante guardar comprovativos de pagamentos relevantes?', 0, 'Dão direito a um desconto na próxima compra', 'Costumam dar direito a um desconto na próxima compra'),
    ('seed_financas_dificil_v1', 'O que é liquidez de um investimento?', 2, 'Valor do investimento inicial somado aos rendimentos obtidos até o momento da venda, que depende do mercado', 'Valor do investimento inicial somado aos rendimentos obtidos até o momento da venda, que pode variar com o mercado'),
    ('seed_financas_medio_v1', 'Por que uma reserva de emergência deve ser relativamente acessível?', 0, 'Porque deve render o máximo possível a cada mês', 'Porque costuma render o máximo possível a cada mês'),
    ('seed_financas_dificil_v3', 'O que é previsão financeira?', 1, 'Controle do estoque de produtos guardados no armazém', 'Controle do estoque, dos produtos e do armazém'),
    ('seed_financas_dificil_v1', 'Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 1, 'Porque aumenta o poder de compra das quantias ao longo do tempo', 'Porque costuma aumentar o poder de compra das quantias ao longo do tempo'),
    ('seed_financas_facil_v1', 'Qual destes pode ser considerado um gasto com transporte?', 1, 'Compra de alimentos', 'Despesa com alimentos'),
    ('seed_financas_medio_v1', 'O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?', 3, 'O banco passa a cobrar menos juros por causa do atraso', 'O banco costuma cobrar menos juros por causa do atraso'),
    ('seed_financas_dificil_v2', 'O que é gestão de risco financeiro?', 3, 'Decisão de ignorar riscos pequenos para focar nos lucros e nos ganhos de curto prazo', 'Decisão de ignorar riscos pequenos, para focar nos lucros'),
    ('seed_financas_facil_v2', 'Como a inflação pode afetar o dinheiro?', 2, 'Aumenta o valor do dinheiro guardado', 'Costuma aumentar o valor do dinheiro guardado'),
    ('seed_financas_dificil_v1', 'O que é ponto de equilíbrio financeiro de uma atividade?', 0, 'Quantidade mínima de vendas que a empresa precisa de manter para pagar apenas os salários dos funcionários', 'Quantidade mínima de vendas que a empresa precisa manter para pagar os salários dos funcionários'),
    ('seed_financas_dificil_v1', 'O que é ponto de equilíbrio financeiro de uma atividade?', 2, 'Valor total das vendas previstas para o ano, considerando todos os custos e despesas', 'Valor total das vendas previstas para o ano, considerando os custos e as despesas'),
    ('seed_financas_medio_v1', 'Antes de contratar um empréstimo, é importante verificar:', 0, 'A simpatia de quem atende', 'Simpatia, brindes e decoração'),
    ('seed_financas_facil_v2', 'O que é um desejo financeiro?', 0, 'Algo essencial para a vida de uma pessoa', 'Algo que precisamos, por ser essencial')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Finanças (pistas): % alternativa(s) errada(s) atualizada(s) (esperado: 71).', v_updated;
END $$;
