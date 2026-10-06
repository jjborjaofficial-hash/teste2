-- Explicações pedagógicas (BE-004) — lote 23 (10 perguntas): fecha Finanças médio (as 5 do seed 100,
-- source 'seed_financas_medio_v4') e abre Finanças difícil (as 5 primeiras do seed 047, source
-- 'seed_financas_dificil_v1'). Aqui já com a profundidade do docs/quiz-v2-rodadas-e-feedback.md:
-- médio = raciocínio e contexto; difícil = raciocínio e relação entre conceitos. Mesmo critério das
-- migrations 109 a 129: só preenche questions.explanation das perguntas que ainda não têm explicação
-- (idempotente, nunca sobrescreve), não altera perguntas nem alternativas.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v4', 'Uma pessoa poupa 500 MZN por mês durante 6 meses. Quanto terá guardado ao final desse período?',
     'Para saber o total de uma poupança regular, multiplica-se o valor mensal pelo número de meses: 500 × 6 = 3.000 MZN. Aqui não se contam juros, só o que foi guardado. Se a poupança rendesse juros, o total final seria um pouco maior.'),
    ('seed_financas_medio_v4', 'Por que manter um bom histórico de pagamentos pode ser importante?',
     'Quem paga em dia mostra aos bancos que cumpre o que combina, e isso reduz o risco para quem empresta. Por isso, no futuro, pode conseguir crédito com condições melhores, como juros menores. O histórico não apaga dívidas, não dá isenção de impostos e não muda o salário.'),
    ('seed_financas_medio_v4', 'O que é amortização de uma dívida?',
     'Amortizar é reduzir a dívida aos poucos, com os pagamentos feitos: cada parcela paga abate uma parte do que se deve. Por isso, ao pagar mais do que a parcela, ou antecipar pagamentos, a dívida diminui mais depressa e os juros seguintes ficam menores. Não é aumento da dívida, cancelamento automático nem imposto.'),
    ('seed_financas_medio_v4', 'Qual é a diferença entre taxa de juro fixa e taxa de juro variável?',
     'Na taxa fixa, o juro é o mesmo durante todo o contrato, então a prestação é previsível. Na variável, o juro acompanha as condições do mercado e pode subir ou descer, e a prestação muda junto. Nenhuma é sempre menor: a variável pode compensar quando os juros caem e pesar quando sobem.'),
    ('seed_financas_medio_v4', 'O que é o limite de crédito de um cartão?',
     'O limite de crédito é o valor máximo que se pode usar com o cartão. É o banco que o define, com base no perfil da pessoa. Usar quase todo o limite deixa pouca margem para imprevistos e faz crescer a fatura. Não é valor mínimo de compra, taxa de juro nem prazo de validade.'),
    ('seed_financas_dificil_v1', 'O que representa o valor do dinheiro no tempo?',
     'O dinheiro muda de valor com o tempo: uma quantia hoje pode ser aplicada e render, e a inflação reduz o que a mesma quantia compra no futuro. Por isso 1.000 MZN hoje e 1.000 MZN daqui a um ano não valem o mesmo. Esse é o princípio por trás dos juros, do desconto e da comparação de investimentos.'),
    ('seed_financas_dificil_v1', 'O que é juros compostos?',
     'Nos juros compostos, os juros de cada período são calculados sobre o capital mais os juros já acumulados, ou seja, juros sobre juros. Por isso o crescimento acelera com o tempo, ao contrário dos juros simples, calculados só sobre o capital inicial. O mesmo efeito faz uma dívida crescer depressa quando não é paga.'),
    ('seed_financas_dificil_v1', 'Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?',
     'Ao deixar os rendimentos aplicados, eles passam a render também, e o crescimento se acelera. Quanto mais tempo, maior o efeito, e é por isso que começar cedo pesa tanto. Retirar os rendimentos a cada período corta esse efeito e aproxima o resultado dos juros simples.'),
    ('seed_financas_dificil_v1', 'O que é retorno real de um investimento?',
     'Retorno real é o ganho depois de descontar a inflação. O retorno nominal diz quanto o dinheiro cresceu em valor; o real diz quanto o poder de compra cresceu. Um investimento pode render no papel e, ainda assim, perder poder de compra se a inflação for maior.'),
    ('seed_financas_dificil_v1', 'Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:',
     'O rendimento de 12% é nominal. Descontada a inflação de 8%, o ganho real em poder de compra é de cerca de 4% (3,7% pelo cálculo exato). Por isso é preciso analisar a inflação: sem ela, não se sabe quanto o dinheiro realmente rendeu. O investimento não perdeu 12%, e a inflação interfere, sim.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações lote 23 (fecha Finanças médio, abre difícil): % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
