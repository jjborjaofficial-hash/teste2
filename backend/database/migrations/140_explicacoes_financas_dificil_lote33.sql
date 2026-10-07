-- Explicações pedagógicas (BE-004) — Finanças difícil lote 33 (FECHA Finanças difícil): perguntas 30 a 33 do seed 074 e a única pergunta
-- de cada um dos seeds 075 e 083 (6 perguntas). Mesmo critério das migrations 109 a 139: só preenche
-- questions.explanation das perguntas que ainda não têm explicação (idempotente, nunca sobrescreve),
-- não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v3', 'O que é estratégia financeira empresarial?',
     'Estratégia financeira empresarial é o plano que define como a empresa vai administrar os seus recursos para alcançar objetivos econômicos: de onde virá o dinheiro, onde será aplicado e que riscos aceita correr. Liga as decisões do dia a dia aos objetivos de longo prazo. Não é apenas vender produtos, contratar funcionários nem criar publicidade, que são ações isoladas.'),
    ('seed_financas_dificil_v3', 'O que é previsão financeira?',
     'Previsão financeira é a estimativa de receitas, despesas e resultados para o futuro, feita com base no histórico e nas expectativas do negócio. Permite antecipar faltas de dinheiro e preparar decisões, como pedir crédito ou adiar um investimento. Olhar só para trás não chega: registar despesas passadas apenas não é previsão. Também não é controle de estoque nem lista de clientes.'),
    ('seed_financas_dificil_v3', 'O que é controle interno financeiro?',
     'Controle interno financeiro é o conjunto de processos criados para proteger os recursos da empresa e garantir que as informações financeiras sejam corretas, por exemplo exigir duas assinaturas num pagamento ou conferir o caixa todos os dias. Reduz erros e fraudes. Não é estratégia de marketing, campanha publicitária nem sistema de vendas.'),
    ('seed_financas_dificil_v3', 'O que é inteligência financeira?',
     'Inteligência financeira é a capacidade de tomar decisões financeiras conscientes, usando conhecimento e análise: comparar opções, entender juros e riscos e planejar antes de gastar ou investir. Vale para pessoas e empresas. Não é ignorar informações financeiras, evitar investimentos nem gastar sem planejamento.'),
    ('seed_financas_dificil_v4', 'O que é due diligence financeira?',
     'Due diligence financeira é a investigação e análise detalhada das informações financeiras de uma empresa antes de uma decisão importante, como comprá-la ou investir nela. Verificam-se contas, dívidas, receitas e riscos para não pagar mais do que ela vale nem herdar problemas escondidos. Não é campanha publicitária, controle de funcionários nem aumento automático de preços.'),
    ('seed_financas_dificil_v5', 'Uma pessoa possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano. Aproximadamente quanto deverá após dois anos, sem realizar pagamentos?',
     'Nos juros compostos, os juros do segundo ano incidem também sobre os juros do primeiro. No fim do 1.º ano a dívida é 50.000 × 1,10 = 55.000 MZN; no fim do 2.º é 55.000 × 1,10 = 60.500 MZN (ou 50.000 × 1,10², em uma só conta). Os 55.000 MZN são só um ano, e os 60.000 MZN seriam juros simples, que ignoram os juros sobre juros.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 33 (fecha a categoria): % pergunta(s) atualizada(s) (esperado: 6).', v_updated;
END $$;
