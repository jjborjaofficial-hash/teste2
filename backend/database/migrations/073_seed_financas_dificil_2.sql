-- Migration/seed: conteúdo Finanças, nível Difícil — lote 1/2 (35 perguntas)
-- Fonte: lote "FINANÇAS DIFÍCIL — LOTE 1/2" fornecido pelo proprietário do
-- projeto, parte de um envio maior (35 + lote 2 ainda pendente) para
-- completar Finanças Difícil rumo a 100 perguntas (31 já existentes + 35
-- deste lote = 66; ainda restará completar com o lote 2/2).
--
-- Verificado: nenhuma das 35 perguntas colide (mesmo enunciado) com as 1004
-- perguntas já existentes no banco.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (82 — distinta das
-- seeds 42 a 81 já usadas) e distribuição controlada entre A/B/C/D,
-- reprodutível — conteúdo pedagógico inalterado, só a ORDEM de exibição
-- mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_dificil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_dificil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_dificil_v2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_financas_dificil_v2'
    FROM (VALUES
      ('O que é alocação estratégica de ativos?'),
      ('O que é volatilidade em investimentos?'),
      ('O que é risco sistêmico?'),
      ('O que é risco não sistêmico?'),
      ('O que representa o índice de Sharpe?'),
      ('O que é análise fundamentalista de empresas?'),
      ('O que é análise técnica?'),
      ('O que é valuation?'),
      ('O que é valor intrínseco de uma empresa?'),
      ('O que é uma bolha financeira?'),
      ('O que é especulação financeira?'),
      ('O que é arbitragem financeira?'),
      ('O que é derivativo financeiro?'),
      ('O que é contrato futuro?'),
      ('O que é hedge financeiro?'),
      ('O que é gestão de risco financeiro?'),
      ('O que é governança corporativa?'),
      ('O que é compliance financeiro?'),
      ('O que é lavagem de dinheiro?'),
      ('O que é planejamento sucessório?'),
      ('O que é taxa interna de retorno (TIR)?'),
      ('O que é valor presente líquido (VPL)?'),
      ('O que significa valor do dinheiro no tempo?'),
      ('O que é custo de capital?'),
      ('O que é estrutura de capital?'),
      ('O que é alavancagem financeira?'),
      ('Qual é um risco da alavancagem financeira?'),
      ('O que é fusão empresarial?'),
      ('O que é aquisição empresarial?'),
      ('O que é auditoria financeira?'),
      ('O que é demonstração financeira?'),
      ('O que é balanço patrimonial?'),
      ('O que é demonstração de resultados?'),
      ('O que é liquidez financeira de uma empresa?'),
      ('O que é solvência empresarial?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_dificil_v2 q
    JOIN (VALUES
      ('O que é alocação estratégica de ativos?', 'Guardar todo dinheiro em casa', FALSE, 0),
      ('O que é alocação estratégica de ativos?', 'Venda de todos os ativos financeiros', FALSE, 1),
      ('O que é alocação estratégica de ativos?', 'Distribuição planejada de investimentos entre diferentes classes de ativos visando objetivos de longo prazo', TRUE, 2),
      ('O que é alocação estratégica de ativos?', 'Compra aleatória de qualquer investimento', FALSE, 3),
      ('O que é volatilidade em investimentos?', 'Medida da variação dos preços de um ativo ao longo do tempo', TRUE, 0),
      ('O que é volatilidade em investimentos?', 'Garantia de lucro constante', FALSE, 1),
      ('O que é volatilidade em investimentos?', 'Valor inicial investido', FALSE, 2),
      ('O que é volatilidade em investimentos?', 'Taxa fixa de rendimento', FALSE, 3),
      ('O que é risco sistêmico?', 'Risco causado apenas por uma empresa', FALSE, 0),
      ('O que é risco sistêmico?', 'Risco que afeta todo o mercado ou sistema financeiro', TRUE, 1),
      ('O que é risco sistêmico?', 'Risco de pequenos gastos pessoais', FALSE, 2),
      ('O que é risco sistêmico?', 'Risco eliminado pela diversificação', FALSE, 3),
      ('O que é risco não sistêmico?', 'Risco que afeta todos os mercados', FALSE, 0),
      ('O que é risco não sistêmico?', 'Risco específico de uma empresa ou setor que pode ser reduzido pela diversificação', TRUE, 1),
      ('O que é risco não sistêmico?', 'Alteração cambial global', FALSE, 2),
      ('O que é risco não sistêmico?', 'Inflação mundial', FALSE, 3),
      ('O que representa o índice de Sharpe?', 'Relação entre retorno obtido e risco assumido em um investimento', TRUE, 0),
      ('O que representa o índice de Sharpe?', 'Valor total de uma empresa', FALSE, 1),
      ('O que representa o índice de Sharpe?', 'Quantidade de investidores', FALSE, 2),
      ('O que representa o índice de Sharpe?', 'Taxa de inflação', FALSE, 3),
      ('O que é análise fundamentalista de empresas?', 'Análise de publicidade', FALSE, 0),
      ('O que é análise fundamentalista de empresas?', 'Escolha baseada em sorte', FALSE, 1),
      ('O que é análise fundamentalista de empresas?', 'Avaliação de indicadores financeiros, resultados e perspectivas de uma empresa', TRUE, 2),
      ('O que é análise fundamentalista de empresas?', 'Observação apenas do preço diário', FALSE, 3),
      ('O que é análise técnica?', 'Controle de despesas pessoais', FALSE, 0),
      ('O que é análise técnica?', 'Análise dos funcionários de uma empresa', FALSE, 1),
      ('O que é análise técnica?', 'Estudo de gráficos e movimentos históricos de preços para identificar tendências', TRUE, 2),
      ('O que é análise técnica?', 'Avaliação de impostos', FALSE, 3),
      ('O que é valuation?', 'Controle de salário', FALSE, 0),
      ('O que é valuation?', 'Processo de estimar o valor de uma empresa ou ativo', TRUE, 1),
      ('O que é valuation?', 'Processo de criação de uma dívida', FALSE, 2),
      ('O que é valuation?', 'Redução de impostos', FALSE, 3),
      ('O que é valor intrínseco de uma empresa?', 'Total de despesas', FALSE, 0),
      ('O que é valor intrínseco de uma empresa?', 'Preço definido apenas pelo mercado', FALSE, 1),
      ('O que é valor intrínseco de uma empresa?', 'Valor do salário dos funcionários', FALSE, 2),
      ('O que é valor intrínseco de uma empresa?', 'Estimativa do valor real baseado em fundamentos financeiros', TRUE, 3),
      ('O que é uma bolha financeira?', 'Crescimento garantido', FALSE, 0),
      ('O que é uma bolha financeira?', 'Situação em que preços de ativos aumentam acima do valor real devido à especulação', TRUE, 1),
      ('O que é uma bolha financeira?', 'Economia sem investimentos', FALSE, 2),
      ('O que é uma bolha financeira?', 'Queda normal de preços', FALSE, 3),
      ('O que é especulação financeira?', 'Controle de orçamento pessoal', FALSE, 0),
      ('O que é especulação financeira?', 'Guardar dinheiro sem objetivo', FALSE, 1),
      ('O que é especulação financeira?', 'Compra ou venda buscando lucro com variações de preço no mercado', TRUE, 2),
      ('O que é especulação financeira?', 'Pagamento de impostos', FALSE, 3),
      ('O que é arbitragem financeira?', 'Redução de salários', FALSE, 0),
      ('O que é arbitragem financeira?', 'Aproveitamento de diferenças de preço do mesmo ativo em mercados diferentes', TRUE, 1),
      ('O que é arbitragem financeira?', 'Criação de dinheiro', FALSE, 2),
      ('O que é arbitragem financeira?', 'Cancelamento de investimentos', FALSE, 3),
      ('O que é derivativo financeiro?', 'Conta bancária comum', FALSE, 0),
      ('O que é derivativo financeiro?', 'Instrumento cujo valor depende de outro ativo de referência', TRUE, 1),
      ('O que é derivativo financeiro?', 'Cartão de crédito', FALSE, 2),
      ('O que é derivativo financeiro?', 'Salário mensal', FALSE, 3),
      ('O que é contrato futuro?', 'Acordo para comprar ou vender um ativo em uma data futura por preço definido', TRUE, 0),
      ('O que é contrato futuro?', 'Empréstimo pessoal', FALSE, 1),
      ('O que é contrato futuro?', 'Conta de poupança', FALSE, 2),
      ('O que é contrato futuro?', 'Compra sem contrato', FALSE, 3),
      ('O que é hedge financeiro?', 'Estratégia para aumentar despesas', FALSE, 0),
      ('O que é hedge financeiro?', 'Forma de eliminar todos os riscos', FALSE, 1),
      ('O que é hedge financeiro?', 'Estratégia usada para proteger investimentos contra variações desfavoráveis', TRUE, 2),
      ('O que é hedge financeiro?', 'Tipo de imposto', FALSE, 3),
      ('O que é gestão de risco financeiro?', 'Processo de identificar, analisar e controlar riscos financeiros', TRUE, 0),
      ('O que é gestão de risco financeiro?', 'Evitar qualquer planejamento', FALSE, 1),
      ('O que é gestão de risco financeiro?', 'Fazer investimentos aleatórios', FALSE, 2),
      ('O que é gestão de risco financeiro?', 'Ignorar riscos', FALSE, 3),
      ('O que é governança corporativa?', 'Método de venda', FALSE, 0),
      ('O que é governança corporativa?', 'Apenas controle de funcionários', FALSE, 1),
      ('O que é governança corporativa?', 'Sistema bancário', FALSE, 2),
      ('O que é governança corporativa?', 'Sistema de regras e práticas para administrar empresas com transparência e responsabilidade', TRUE, 3),
      ('O que é compliance financeiro?', 'Conjunto de práticas para garantir cumprimento de normas e leis financeiras', TRUE, 0),
      ('O que é compliance financeiro?', 'Redução de funcionários', FALSE, 1),
      ('O que é compliance financeiro?', 'Aumento automático de lucro', FALSE, 2),
      ('O que é compliance financeiro?', 'Criação de dívidas', FALSE, 3),
      ('O que é lavagem de dinheiro?', 'Processo ilegal de ocultar a origem de recursos obtidos de forma criminosa', TRUE, 0),
      ('O que é lavagem de dinheiro?', 'Investimento legítimo', FALSE, 1),
      ('O que é lavagem de dinheiro?', 'Economia pessoal', FALSE, 2),
      ('O que é lavagem de dinheiro?', 'Pagamento de impostos', FALSE, 3),
      ('O que é planejamento sucessório?', 'Criação de dívidas', FALSE, 0),
      ('O que é planejamento sucessório?', 'Planejamento de compras', FALSE, 1),
      ('O que é planejamento sucessório?', 'Controle de salário', FALSE, 2),
      ('O que é planejamento sucessório?', 'Organização da transferência de patrimônio para futuras gerações', TRUE, 3),
      ('O que é taxa interna de retorno (TIR)?', 'Custo operacional', FALSE, 0),
      ('O que é taxa interna de retorno (TIR)?', 'Taxa que demonstra a rentabilidade esperada de um investimento', TRUE, 1),
      ('O que é taxa interna de retorno (TIR)?', 'Preço de mercado', FALSE, 2),
      ('O que é taxa interna de retorno (TIR)?', 'Valor de uma dívida', FALSE, 3),
      ('O que é valor presente líquido (VPL)?', 'Soma simples de despesas', FALSE, 0),
      ('O que é valor presente líquido (VPL)?', 'Método usado para avaliar a viabilidade financeira de investimentos considerando o valor do dinheiro no tempo', TRUE, 1),
      ('O que é valor presente líquido (VPL)?', 'Valor do salário', FALSE, 2),
      ('O que é valor presente líquido (VPL)?', 'Quantidade de clientes', FALSE, 3),
      ('O que significa valor do dinheiro no tempo?', 'Um valor recebido hoje geralmente possui maior capacidade de gerar retorno que o mesmo valor no futuro', TRUE, 0),
      ('O que significa valor do dinheiro no tempo?', 'Dinheiro nunca muda de valor', FALSE, 1),
      ('O que significa valor do dinheiro no tempo?', 'O futuro sempre vale mais', FALSE, 2),
      ('O que significa valor do dinheiro no tempo?', 'Juros não existem', FALSE, 3),
      ('O que é custo de capital?', 'Imposto de consumo', FALSE, 0),
      ('O que é custo de capital?', 'Salário dos trabalhadores', FALSE, 1),
      ('O que é custo de capital?', 'Valor do produto final', FALSE, 2),
      ('O que é custo de capital?', 'Custo que uma empresa possui para obter recursos financeiros', TRUE, 3),
      ('O que é estrutura de capital?', 'Combinação de recursos próprios e financiamentos utilizados por uma empresa', TRUE, 0),
      ('O que é estrutura de capital?', 'Total de vendas', FALSE, 1),
      ('O que é estrutura de capital?', 'Número de funcionários', FALSE, 2),
      ('O que é estrutura de capital?', 'Apenas dinheiro em caixa', FALSE, 3),
      ('O que é alavancagem financeira?', 'Eliminação de investimentos', FALSE, 0),
      ('O que é alavancagem financeira?', 'Controle de despesas pessoais', FALSE, 1),
      ('O que é alavancagem financeira?', 'Uso de recursos de terceiros para aumentar potencial de retorno', TRUE, 2),
      ('O que é alavancagem financeira?', 'Redução de vendas', FALSE, 3),
      ('Qual é um risco da alavancagem financeira?', 'Garantia de lucro', FALSE, 0),
      ('Qual é um risco da alavancagem financeira?', 'Redução automática de custos', FALSE, 1),
      ('Qual é um risco da alavancagem financeira?', 'Eliminação de dívidas', FALSE, 2),
      ('Qual é um risco da alavancagem financeira?', 'Aumento das perdas quando os resultados esperados não acontecem', TRUE, 3),
      ('O que é fusão empresarial?', 'Venda de produtos', FALSE, 0),
      ('O que é fusão empresarial?', 'Fechamento de uma empresa', FALSE, 1),
      ('O que é fusão empresarial?', 'Redução de impostos', FALSE, 2),
      ('O que é fusão empresarial?', 'União de duas ou mais empresas formando uma nova estrutura', TRUE, 3),
      ('O que é aquisição empresarial?', 'Compra de uma empresa por outra organização', TRUE, 0),
      ('O que é aquisição empresarial?', 'Criação de uma dívida pessoal', FALSE, 1),
      ('O que é aquisição empresarial?', 'Pagamento de salário', FALSE, 2),
      ('O que é aquisição empresarial?', 'Controle bancário', FALSE, 3),
      ('O que é auditoria financeira?', 'Controle de marketing', FALSE, 0),
      ('O que é auditoria financeira?', 'Criação de investimentos', FALSE, 1),
      ('O que é auditoria financeira?', 'Exame das informações financeiras para verificar precisão e conformidade', TRUE, 2),
      ('O que é auditoria financeira?', 'Venda de ações', FALSE, 3),
      ('O que é demonstração financeira?', 'Plano de vendas', FALSE, 0),
      ('O que é demonstração financeira?', 'Contrato de empréstimo', FALSE, 1),
      ('O que é demonstração financeira?', 'Relatório que apresenta informações econômicas e financeiras de uma organização', TRUE, 2),
      ('O que é demonstração financeira?', 'Documento de publicidade', FALSE, 3),
      ('O que é balanço patrimonial?', 'Controle de funcionários', FALSE, 0),
      ('O que é balanço patrimonial?', 'Plano de marketing', FALSE, 1),
      ('O que é balanço patrimonial?', 'Relatório que apresenta ativos, passivos e patrimônio líquido', TRUE, 2),
      ('O que é balanço patrimonial?', 'Lista de clientes', FALSE, 3),
      ('O que é demonstração de resultados?', 'Documento de identidade', FALSE, 0),
      ('O que é demonstração de resultados?', 'Contrato bancário', FALSE, 1),
      ('O que é demonstração de resultados?', 'Lista de investimentos pessoais', FALSE, 2),
      ('O que é demonstração de resultados?', 'Relatório que mostra receitas, custos e lucro ou prejuízo de uma empresa', TRUE, 3),
      ('O que é liquidez financeira de uma empresa?', 'Número de produtos', FALSE, 0),
      ('O que é liquidez financeira de uma empresa?', 'Valor da publicidade', FALSE, 1),
      ('O que é liquidez financeira de uma empresa?', 'Quantidade de funcionários', FALSE, 2),
      ('O que é liquidez financeira de uma empresa?', 'Capacidade de cumprir obrigações de curto prazo', TRUE, 3),
      ('O que é solvência empresarial?', 'Capacidade de vender mais produtos apenas', FALSE, 0),
      ('O que é solvência empresarial?', 'Capacidade de uma empresa cumprir suas obrigações financeiras no longo prazo', TRUE, 1),
      ('O que é solvência empresarial?', 'Número de clientes', FALSE, 2),
      ('O que é solvência empresarial?', 'Quantidade de anúncios', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_dificil_v2;

    RAISE NOTICE '35 perguntas inseridas com sucesso (source=seed_financas_dificil_v2).';
  END IF;
END $$;

COMMIT;
