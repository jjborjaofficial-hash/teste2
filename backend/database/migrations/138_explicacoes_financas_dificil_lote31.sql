-- Explicações pedagógicas (BE-004) — Finanças difícil lote 31, perguntas 10 a 19 do seed 074 (10 perguntas). Mesmo critério das migrations 109 a
-- 137: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v3', 'O que é uma debênture?',
     'Debênture é um título de dívida emitido por uma empresa para captar recursos: quem a compra empresta dinheiro à empresa e recebe juros. É uma alternativa ao empréstimo bancário e, ao contrário da ação, não dá participação na empresa. Não é imposto empresarial, conta corrente nem cartão de crédito.'),
    ('seed_financas_dificil_v3', 'O que é um título público?',
     'Título público é um instrumento de dívida emitido pelo governo para captar recursos: quem o compra empresta dinheiro ao Estado, que paga juros e devolve o valor no vencimento. Costuma ser visto como de menor risco de crédito, porque quem deve é o governo. Não é ação de empresa privada, salário público nem conta bancária.'),
    ('seed_financas_dificil_v3', 'O que é duration de um título?',
     'Duration é a medida ligada ao prazo do título e à sensibilidade do seu preço às taxas de juros. Quanto maior a duration, mais o preço oscila quando os juros mudam: se os juros sobem, o preço cai, e vice-versa. Não é número de investidores, valor inicial investido nem quantidade de ações.'),
    ('seed_financas_dificil_v3', 'O que é inflação esperada?',
     'Inflação esperada é a previsão de aumento dos preços no futuro. Importa porque influencia decisões, como pedir aumento salarial, fixar preços e definir juros: se se espera inflação alta, os juros pedidos tendem a ser maiores. Não é dinheiro guardado, salário atual nem lucro empresarial.'),
    ('seed_financas_dificil_v3', 'O que é crescimento econômico?',
     'Crescimento econômico é o aumento da produção e da atividade econômica de um país ao longo do tempo. Em geral, mais produção significa mais emprego e renda. Não é apenas aumento de preços (isso é inflação), diminuição da produção nem redução de investimentos.'),
    ('seed_financas_dificil_v3', 'O que é recessão econômica?',
     'Recessão é um período de redução significativa da atividade econômica, com queda da produção, do emprego e do consumo. É a fase contrária ao crescimento. Não traz aumento garantido dos lucros, não significa sempre redução de impostos nem crescimento acelerado.'),
    ('seed_financas_dificil_v3', 'O que é ciclo econômico?',
     'Ciclo econômico é a alternância entre períodos de crescimento e de redução da atividade econômica: expansão, pico, recessão e recuperação. Entender o ciclo ajuda a ver por que juros, emprego e lucros mudam ao longo do tempo. Não é movimento de uma conta bancária, tipo de investimento nem processo de pagamento.'),
    ('seed_financas_dificil_v3', 'O que é produtividade financeira empresarial?',
     'Produtividade empresarial é a capacidade de gerar melhores resultados usando os recursos de forma eficiente, ou seja, produzir mais ou com menos custo com o que se tem. Quando aumenta, tende a melhorar as margens de lucro. Não é eliminar investimentos, reduzir clientes nem aumentar despesas.'),
    ('seed_financas_dificil_v3', 'O que é margem operacional?',
     'Margem operacional é o percentual de lucro obtido depois de considerar os custos operacionais, ou seja, o que a atividade principal da empresa rende em relação à receita. Mostra a eficiência da operação antes de juros e impostos. Não é número de funcionários, só os impostos nem o total das vendas.'),
    ('seed_financas_dificil_v3', 'O que é margem líquida?',
     'Margem líquida é o percentual do lucro final em relação à receita, depois de todos os custos, despesas, juros e impostos. Mostra quanto de cada unidade vendida realmente sobra para a empresa, e é menor ou igual à margem operacional. Não é valor do estoque, total de despesas nem investimento inicial.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 31, perguntas 10 a 19 do seed 074: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
