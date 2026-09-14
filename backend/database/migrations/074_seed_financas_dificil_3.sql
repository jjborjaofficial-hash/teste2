-- Migration/seed: conteúdo Finanças, nível Difícil — lote 2/2 (33 de 34 perguntas)
-- Fonte: lote "FINANÇAS DIFÍCIL — QUESTÕES 36-69" fornecido pelo proprietário
-- do projeto, complementando 043_financas_dificil_2.sql (lote 1/2, perguntas
-- 1-35) para fechar Finanças Difícil.
--
-- DEDUPLICAÇÃO APLICADA: "O que é risco de crédito?" já existia em
-- 017_financas_dificil.sql e foi REMOVIDA deste arquivo (não inserida de
-- novo). Restaram 33 perguntas novas e únicas.
--
-- Com 31 (originais) + 35 (lote 1/2) + 33 (este lote) = 99 perguntas,
-- Finanças Difícil fica a 1 pergunta de 100.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (83 — distinta das
-- seeds 42 a 82 já usadas) e distribuição controlada entre A/B/C/D,
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_dificil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_dificil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_dificil_v3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_financas_dificil_v3'
    FROM (VALUES
      ('O que é análise de crédito?'),
      ('O que é política monetária?'),
      ('Qual é uma ferramenta de política monetária?'),
      ('O que é política fiscal?'),
      ('O que é taxa básica de juros?'),
      ('O que é câmbio?'),
      ('O que é risco cambial?'),
      ('O que é mercado de capitais?'),
      ('O que são títulos de dívida?'),
      ('O que é uma debênture?'),
      ('O que é um título público?'),
      ('O que é duration de um título?'),
      ('O que é inflação esperada?'),
      ('O que é crescimento econômico?'),
      ('O que é recessão econômica?'),
      ('O que é ciclo econômico?'),
      ('O que é produtividade financeira empresarial?'),
      ('O que é margem operacional?'),
      ('O que é margem líquida?'),
      ('O que é EBITDA?'),
      ('O que é depreciação?'),
      ('O que é amortização contábil?'),
      ('O que é capital próprio?'),
      ('O que é capital de terceiros?'),
      ('O que é análise de viabilidade financeira?'),
      ('O que é orçamento de capital?'),
      ('O que é custo fixo?'),
      ('O que é custo variável?'),
      ('O que é eficiência financeira?'),
      ('O que é estratégia financeira empresarial?'),
      ('O que é previsão financeira?'),
      ('O que é controle interno financeiro?'),
      ('O que é inteligência financeira?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_dificil_v3 q
    JOIN (VALUES
      ('O que é análise de crédito?', 'Venda de produtos financeiros', FALSE, 0),
      ('O que é análise de crédito?', 'Processo de criação de dinheiro', FALSE, 1),
      ('O que é análise de crédito?', 'Processo de avaliação da capacidade de pagamento de uma pessoa ou empresa', TRUE, 2),
      ('O que é análise de crédito?', 'Redução automática de juros', FALSE, 3),
      ('O que é política monetária?', 'Estratégia de vendas de empresas', FALSE, 0),
      ('O que é política monetária?', 'Conjunto de medidas utilizadas pelo banco central para controlar moeda e inflação', TRUE, 1),
      ('O que é política monetária?', 'Controle de salários', FALSE, 2),
      ('O que é política monetária?', 'Planejamento pessoal de gastos', FALSE, 3),
      ('Qual é uma ferramenta de política monetária?', 'Criação de anúncios', FALSE, 0),
      ('Qual é uma ferramenta de política monetária?', 'Venda de produtos', FALSE, 1),
      ('Qual é uma ferramenta de política monetária?', 'Alteração das taxas de juros', TRUE, 2),
      ('Qual é uma ferramenta de política monetária?', 'Redução de funcionários', FALSE, 3),
      ('O que é política fiscal?', 'Controle de investimentos pessoais', FALSE, 0),
      ('O que é política fiscal?', 'Uso de receitas e gastos públicos para influenciar a economia', TRUE, 1),
      ('O que é política fiscal?', 'Gestão de cartões bancários', FALSE, 2),
      ('O que é política fiscal?', 'Estratégia empresarial de marketing', FALSE, 3),
      ('O que é taxa básica de juros?', 'Salário mínimo', FALSE, 0),
      ('O que é taxa básica de juros?', 'Valor de uma ação', FALSE, 1),
      ('O que é taxa básica de juros?', 'Taxa de referência usada para influenciar outras taxas da economia', TRUE, 2),
      ('O que é taxa básica de juros?', 'Preço de um produto', FALSE, 3),
      ('O que é câmbio?', 'Sistema de impostos', FALSE, 0),
      ('O que é câmbio?', 'Tipo de investimento', FALSE, 1),
      ('O que é câmbio?', 'Relação de troca entre diferentes moedas', TRUE, 2),
      ('O que é câmbio?', 'Valor de um imóvel', FALSE, 3),
      ('O que é risco cambial?', 'Possibilidade de perdas devido à variação das moedas', TRUE, 0),
      ('O que é risco cambial?', 'Redução de despesas', FALSE, 1),
      ('O que é risco cambial?', 'Garantia de lucro internacional', FALSE, 2),
      ('O que é risco cambial?', 'Aumento de salário', FALSE, 3),
      ('O que é mercado de capitais?', 'Sistema de pagamentos digitais', FALSE, 0),
      ('O que é mercado de capitais?', 'Mercado de produtos alimentares', FALSE, 1),
      ('O que é mercado de capitais?', 'Mercado de trabalho', FALSE, 2),
      ('O que é mercado de capitais?', 'Mercado onde empresas captam recursos através de valores mobiliários', TRUE, 3),
      ('O que são títulos de dívida?', 'Contas pessoais', FALSE, 0),
      ('O que são títulos de dívida?', 'Instrumentos usados para captar recursos através de empréstimos', TRUE, 1),
      ('O que são títulos de dívida?', 'Cartões bancários', FALSE, 2),
      ('O que são títulos de dívida?', 'Produtos sem valor financeiro', FALSE, 3),
      ('O que é uma debênture?', 'Imposto empresarial', FALSE, 0),
      ('O que é uma debênture?', 'Conta corrente empresarial', FALSE, 1),
      ('O que é uma debênture?', 'Título de dívida emitido por uma empresa para captar recursos', TRUE, 2),
      ('O que é uma debênture?', 'Cartão de crédito', FALSE, 3),
      ('O que é um título público?', 'Ação de uma empresa privada', FALSE, 0),
      ('O que é um título público?', 'Instrumento de dívida emitido pelo governo para captar recursos', TRUE, 1),
      ('O que é um título público?', 'Salário público', FALSE, 2),
      ('O que é um título público?', 'Conta bancária', FALSE, 3),
      ('O que é duration de um título?', 'Medida relacionada ao prazo e sensibilidade do preço de um título às taxas de juros', TRUE, 0),
      ('O que é duration de um título?', 'Número de investidores', FALSE, 1),
      ('O que é duration de um título?', 'Valor inicial investido', FALSE, 2),
      ('O que é duration de um título?', 'Quantidade de ações', FALSE, 3),
      ('O que é inflação esperada?', 'Previsão de aumento dos preços no futuro', TRUE, 0),
      ('O que é inflação esperada?', 'Quantidade de dinheiro guardado', FALSE, 1),
      ('O que é inflação esperada?', 'Valor atual do salário', FALSE, 2),
      ('O que é inflação esperada?', 'Lucro empresarial', FALSE, 3),
      ('O que é crescimento econômico?', 'Apenas aumento dos preços', FALSE, 0),
      ('O que é crescimento econômico?', 'Diminuição da produção', FALSE, 1),
      ('O que é crescimento econômico?', 'Redução dos investimentos', FALSE, 2),
      ('O que é crescimento econômico?', 'Aumento da produção e atividade econômica de um país', TRUE, 3),
      ('O que é recessão econômica?', 'Período de redução significativa da atividade econômica', TRUE, 0),
      ('O que é recessão econômica?', 'Aumento garantido dos lucros', FALSE, 1),
      ('O que é recessão econômica?', 'Redução dos impostos sempre', FALSE, 2),
      ('O que é recessão econômica?', 'Crescimento acelerado da economia', FALSE, 3),
      ('O que é ciclo econômico?', 'Movimento de uma conta bancária', FALSE, 0),
      ('O que é ciclo econômico?', 'Tipo de investimento', FALSE, 1),
      ('O que é ciclo econômico?', 'Alternância entre períodos de crescimento e redução da economia', TRUE, 2),
      ('O que é ciclo econômico?', 'Processo de pagamento', FALSE, 3),
      ('O que é produtividade financeira empresarial?', 'Eliminação de investimentos', FALSE, 0),
      ('O que é produtividade financeira empresarial?', 'Capacidade de gerar melhores resultados utilizando recursos de forma eficiente', TRUE, 1),
      ('O que é produtividade financeira empresarial?', 'Redução de clientes', FALSE, 2),
      ('O que é produtividade financeira empresarial?', 'Aumento de despesas', FALSE, 3),
      ('O que é margem operacional?', 'Quantidade de funcionários', FALSE, 0),
      ('O que é margem operacional?', 'Valor dos impostos apenas', FALSE, 1),
      ('O que é margem operacional?', 'Valor total das vendas', FALSE, 2),
      ('O que é margem operacional?', 'Percentual de lucro obtido após considerar custos operacionais', TRUE, 3),
      ('O que é margem líquida?', 'Valor do estoque', FALSE, 0),
      ('O que é margem líquida?', 'Percentual de lucro final em relação à receita', TRUE, 1),
      ('O que é margem líquida?', 'Total de despesas', FALSE, 2),
      ('O que é margem líquida?', 'Valor do investimento inicial', FALSE, 3),
      ('O que é EBITDA?', 'Taxa de cartão', FALSE, 0),
      ('O que é EBITDA?', 'Valor de uma dívida pessoal', FALSE, 1),
      ('O que é EBITDA?', 'Salário empresarial', FALSE, 2),
      ('O que é EBITDA?', 'Indicador que mostra desempenho operacional antes de juros, impostos, depreciação e amortização', TRUE, 3),
      ('O que é depreciação?', 'Receita extra', FALSE, 0),
      ('O que é depreciação?', 'Lucro financeiro', FALSE, 1),
      ('O que é depreciação?', 'Aumento automático do valor', FALSE, 2),
      ('O que é depreciação?', 'Perda de valor de um ativo ao longo do tempo', TRUE, 3),
      ('O que é amortização contábil?', 'Criação de novos ativos', FALSE, 0),
      ('O que é amortização contábil?', 'Redução gradual do valor de determinados ativos ou direitos ao longo do tempo', TRUE, 1),
      ('O que é amortização contábil?', 'Venda de produtos', FALSE, 2),
      ('O que é amortização contábil?', 'Aumento de impostos', FALSE, 3),
      ('O que é capital próprio?', 'Recursos pertencentes aos proprietários de uma empresa', TRUE, 0),
      ('O que é capital próprio?', 'Dinheiro emprestado pelo banco', FALSE, 1),
      ('O que é capital próprio?', 'Imposto pago', FALSE, 2),
      ('O que é capital próprio?', 'Dívida de clientes', FALSE, 3),
      ('O que é capital de terceiros?', 'Dinheiro pessoal guardado', FALSE, 0),
      ('O que é capital de terceiros?', 'Lucro distribuído', FALSE, 1),
      ('O que é capital de terceiros?', 'Recursos obtidos através de empréstimos ou financiamentos', TRUE, 2),
      ('O que é capital de terceiros?', 'Receita de vendas', FALSE, 3),
      ('O que é análise de viabilidade financeira?', 'Avaliação para saber se um projeto pode gerar resultados positivos', TRUE, 0),
      ('O que é análise de viabilidade financeira?', 'Criação de despesas', FALSE, 1),
      ('O que é análise de viabilidade financeira?', 'Controle de funcionários', FALSE, 2),
      ('O que é análise de viabilidade financeira?', 'Publicidade empresarial', FALSE, 3),
      ('O que é orçamento de capital?', 'Lista de clientes', FALSE, 0),
      ('O que é orçamento de capital?', 'Controle de salários', FALSE, 1),
      ('O que é orçamento de capital?', 'Planejamento de investimentos de longo prazo de uma organização', TRUE, 2),
      ('O que é orçamento de capital?', 'Plano de vendas', FALSE, 3),
      ('O que é custo fixo?', 'Custo que muda sempre', FALSE, 0),
      ('O que é custo fixo?', 'Receita extra', FALSE, 1),
      ('O que é custo fixo?', 'Lucro líquido', FALSE, 2),
      ('O que é custo fixo?', 'Custo que permanece relativamente constante independentemente da produção', TRUE, 3),
      ('O que é custo variável?', 'Custo que varia conforme produção ou vendas', TRUE, 0),
      ('O que é custo variável?', 'Investimento financeiro', FALSE, 1),
      ('O que é custo variável?', 'Custo sempre igual', FALSE, 2),
      ('O que é custo variável?', 'Receita garantida', FALSE, 3),
      ('O que é eficiência financeira?', 'Gastar mais recursos', FALSE, 0),
      ('O que é eficiência financeira?', 'Capacidade de alcançar objetivos utilizando recursos de forma adequada', TRUE, 1),
      ('O que é eficiência financeira?', 'Evitar planejamento', FALSE, 2),
      ('O que é eficiência financeira?', 'Aumentar dívidas', FALSE, 3),
      ('O que é estratégia financeira empresarial?', 'Plano para administrar recursos e alcançar objetivos econômicos', TRUE, 0),
      ('O que é estratégia financeira empresarial?', 'Apenas vender produtos', FALSE, 1),
      ('O que é estratégia financeira empresarial?', 'Contratar funcionários', FALSE, 2),
      ('O que é estratégia financeira empresarial?', 'Criar publicidade', FALSE, 3),
      ('O que é previsão financeira?', 'Estimativa futura de receitas, despesas e resultados financeiros', TRUE, 0),
      ('O que é previsão financeira?', 'Controle de estoque', FALSE, 1),
      ('O que é previsão financeira?', 'Registro de despesas passadas apenas', FALSE, 2),
      ('O que é previsão financeira?', 'Lista de clientes', FALSE, 3),
      ('O que é controle interno financeiro?', 'Estratégia de marketing', FALSE, 0),
      ('O que é controle interno financeiro?', 'Campanha publicitária', FALSE, 1),
      ('O que é controle interno financeiro?', 'Sistema de vendas', FALSE, 2),
      ('O que é controle interno financeiro?', 'Processos criados para proteger recursos e garantir informações corretas', TRUE, 3),
      ('O que é inteligência financeira?', 'Ignorar informações financeiras', FALSE, 0),
      ('O que é inteligência financeira?', 'Evitar investimentos', FALSE, 1),
      ('O que é inteligência financeira?', 'Gastar sem planejamento', FALSE, 2),
      ('O que é inteligência financeira?', 'Capacidade de tomar decisões financeiras conscientes usando conhecimento e análise', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_dificil_v3;

    RAISE NOTICE '33 perguntas inseridas com sucesso (source=seed_financas_dificil_v3).';
  END IF;
END $$;

COMMIT;
