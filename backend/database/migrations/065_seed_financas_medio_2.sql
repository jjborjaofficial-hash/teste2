-- Migration/seed: conteúdo Finanças, nível Médio — lote 2 (59 de 62 perguntas)
-- Fonte: novo lote de 62 perguntas de Finanças/Médio fornecido pelo
-- proprietário do projeto (numeradas 1–62, em 2 mensagens separadas).
--
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra as 38 perguntas já
-- existentes em 016_financas_medio.sql e encontrei 3 repetidas, que foram
-- REMOVIDAS deste arquivo (não inseridas de novo):
--   - "O que é renda passiva?"
--   - "O que é renda ativa?"
--   - "O que é patrimônio líquido?"
-- Sobraram 59 perguntas novas e únicas, inseridas aqui.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): respostas corretas originalmente
-- TODAS "A" — posição redistribuída com seed fixa (74 — distinta das
-- seeds 42 a 73 já usadas) e distribuição controlada entre A/B/C/D,
-- reprodutível — conteúdo pedagógico inalterado, só a ORDEM de exibição
-- mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.
--
-- CORREÇÃO DE DUPLICATA CRUZADA (rodada de consolidação): 5 perguntas deste
-- arquivo já existiam em 017_financas_dificil.sql — "O que é juros
-- compostos?", "O que é liquidez de um investimento?", "O que é capital
-- de giro?", "O que é margem de lucro?", "O que é custo de
-- oportunidade?". Removidas daqui. 59 → 54 perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_medio_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_medio_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_medio_v2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_financas_medio_v2'
    FROM (VALUES
      ('O que é diversificação de investimentos?'),
      ('Qual é a principal finalidade de uma reserva de emergência?'),
      ('Qual é o efeito dos juros compostos em investimentos de longo prazo?'),
      ('O que significa um investimento de alta liquidez?'),
      ('O que é risco financeiro?'),
      ('O que é retorno de investimento?'),
      ('O que é perfil de investidor?'),
      ('Quais são exemplos de perfis de investidores?'),
      ('O que caracteriza um investidor conservador?'),
      ('O que caracteriza um investidor agressivo?'),
      ('O que é mercado financeiro?'),
      ('O que é uma ação?'),
      ('O que significa comprar ações?'),
      ('O que é dividendo?'),
      ('O que é um ativo financeiro?'),
      ('O que é um passivo financeiro?'),
      ('O que é fluxo de caixa?'),
      ('Por que acompanhar o fluxo de caixa é importante?'),
      ('O que é inadimplência?'),
      ('O que é renegociação de dívida?'),
      ('O que é crédito responsável?'),
      ('O que é planejamento de aposentadoria?'),
      ('O que é independência financeira?'),
      ('O que é análise financeira?'),
      ('O que é inflação de demanda?'),
      ('O que é inflação de custos?'),
      ('O que é deflação?'),
      ('O que é taxa de juros?'),
      ('Como uma taxa de juros alta pode afetar empréstimos?'),
      ('O que é amortização?'),
      ('O que é financiamento?'),
      ('Qual a diferença entre financiamento e empréstimo?'),
      ('O que é cheque especial?'),
      ('Por que o cheque especial deve ser usado com cuidado?'),
      ('O que é score de crédito?'),
      ('Por que um bom score de crédito é importante?'),
      ('O que é planejamento tributário?'),
      ('O que é imposto?'),
      ('O que é capital?'),
      ('O que é empreendedorismo financeiro?'),
      ('O que é preço de venda?'),
      ('O que é custo de produção?'),
      ('O que é ponto de equilíbrio financeiro?'),
      ('O que é análise de risco financeiro?'),
      ('O que é carteira de investimentos?'),
      ('O que é um fundo de investimento?'),
      ('O que é renda fixa?'),
      ('O que é renda variável?'),
      ('O que é análise fundamentalista?'),
      ('O que é planejamento financeiro empresarial?'),
      ('O que é orçamento empresarial?'),
      ('O que é sustentabilidade financeira?'),
      ('O que é independência financeira pessoal?'),
      ('Qual é uma boa prática para melhorar a saúde financeira?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_medio_v2 q
    JOIN (VALUES
      ('O que é diversificação de investimentos?', 'Distribuir dinheiro em diferentes tipos de investimentos para reduzir riscos', TRUE, 0),
      ('O que é diversificação de investimentos?', 'Colocar todo dinheiro em um único investimento', FALSE, 1),
      ('O que é diversificação de investimentos?', 'Gastar todo o dinheiro disponível', FALSE, 2),
      ('O que é diversificação de investimentos?', 'Evitar qualquer investimento', FALSE, 3),
      ('Qual é a principal finalidade de uma reserva de emergência?', 'Aumentar gastos mensais', FALSE, 0),
      ('Qual é a principal finalidade de uma reserva de emergência?', 'Comprar produtos de luxo', FALSE, 1),
      ('Qual é a principal finalidade de uma reserva de emergência?', 'Cobrir situações inesperadas sem precisar recorrer a dívidas', TRUE, 2),
      ('Qual é a principal finalidade de uma reserva de emergência?', 'Fazer investimentos de alto risco', FALSE, 3),
      ('Qual é o efeito dos juros compostos em investimentos de longo prazo?', 'Impedem investimentos', FALSE, 0),
      ('Qual é o efeito dos juros compostos em investimentos de longo prazo?', 'Eliminam qualquer lucro', FALSE, 1),
      ('Qual é o efeito dos juros compostos em investimentos de longo prazo?', 'Podem aumentar significativamente o crescimento do dinheiro', TRUE, 2),
      ('Qual é o efeito dos juros compostos em investimentos de longo prazo?', 'Sempre reduzem o valor investido', FALSE, 3),
      ('O que significa um investimento de alta liquidez?', 'Possui prazo infinito', FALSE, 0),
      ('O que significa um investimento de alta liquidez?', 'Não pode ser vendido', FALSE, 1),
      ('O que significa um investimento de alta liquidez?', 'Pode ser convertido em dinheiro rapidamente', TRUE, 2),
      ('O que significa um investimento de alta liquidez?', 'Sempre apresenta prejuízo', FALSE, 3),
      ('O que é risco financeiro?', 'Ausência de decisões', FALSE, 0),
      ('O que é risco financeiro?', 'Possibilidade de perder dinheiro ou não alcançar o resultado esperado', TRUE, 1),
      ('O que é risco financeiro?', 'Aumento automático do dinheiro', FALSE, 2),
      ('O que é risco financeiro?', 'Garantia de lucro', FALSE, 3),
      ('O que é retorno de investimento?', 'Ganho ou resultado obtido após aplicar dinheiro', TRUE, 0),
      ('O que é retorno de investimento?', 'Conta mensal', FALSE, 1),
      ('O que é retorno de investimento?', 'Valor perdido', FALSE, 2),
      ('O que é retorno de investimento?', 'Dívida bancária', FALSE, 3),
      ('O que é perfil de investidor?', 'Número de contas bancárias', FALSE, 0),
      ('O que é perfil de investidor?', 'Características de uma pessoa relacionadas à tolerância ao risco', TRUE, 1),
      ('O que é perfil de investidor?', 'Nome do banco', FALSE, 2),
      ('O que é perfil de investidor?', 'Quantidade de dinheiro gasto', FALSE, 3),
      ('Quais são exemplos de perfis de investidores?', 'Pequeno, médio e grande', FALSE, 0),
      ('Quais são exemplos de perfis de investidores?', 'Conservador, moderado e agressivo', TRUE, 1),
      ('Quais são exemplos de perfis de investidores?', 'Simples e complexo', FALSE, 2),
      ('Quais são exemplos de perfis de investidores?', 'Nacional e internacional', FALSE, 3),
      ('O que caracteriza um investidor conservador?', 'Busca sempre o maior risco', FALSE, 0),
      ('O que caracteriza um investidor conservador?', 'Prefere segurança mesmo com menor possibilidade de retorno', TRUE, 1),
      ('O que caracteriza um investidor conservador?', 'Aceita qualquer risco', FALSE, 2),
      ('O que caracteriza um investidor conservador?', 'Investe sem analisar', FALSE, 3),
      ('O que caracteriza um investidor agressivo?', 'Não analisa oportunidades', FALSE, 0),
      ('O que caracteriza um investidor agressivo?', 'Evita totalmente investimentos', FALSE, 1),
      ('O que caracteriza um investidor agressivo?', 'Guarda apenas dinheiro físico', FALSE, 2),
      ('O que caracteriza um investidor agressivo?', 'Aceita maiores riscos buscando maiores retornos', TRUE, 3),
      ('O que é mercado financeiro?', 'Um banco específico', FALSE, 0),
      ('O que é mercado financeiro?', 'Ambiente onde acontecem operações envolvendo dinheiro e investimentos', TRUE, 1),
      ('O que é mercado financeiro?', 'Um aplicativo', FALSE, 2),
      ('O que é mercado financeiro?', 'Apenas lojas comerciais', FALSE, 3),
      ('O que é uma ação?', 'Um empréstimo bancário', FALSE, 0),
      ('O que é uma ação?', 'Uma despesa', FALSE, 1),
      ('O que é uma ação?', 'Pequena participação na propriedade de uma empresa', TRUE, 2),
      ('O que é uma ação?', 'Uma conta mensal', FALSE, 3),
      ('O que significa comprar ações?', 'Pagar impostos', FALSE, 0),
      ('O que significa comprar ações?', 'Fazer uma dívida', FALSE, 1),
      ('O que significa comprar ações?', 'Comprar dinheiro físico', FALSE, 2),
      ('O que significa comprar ações?', 'Tornar-se parcialmente proprietário de uma empresa', TRUE, 3),
      ('O que é dividendo?', 'Uma dívida', FALSE, 0),
      ('O que é dividendo?', 'Uma taxa bancária', FALSE, 1),
      ('O que é dividendo?', 'Parte do lucro de uma empresa distribuída aos acionistas', TRUE, 2),
      ('O que é dividendo?', 'Um imposto', FALSE, 3),
      ('O que é um ativo financeiro?', 'Uma despesa', FALSE, 0),
      ('O que é um ativo financeiro?', 'Um imposto', FALSE, 1),
      ('O que é um ativo financeiro?', 'Uma dívida', FALSE, 2),
      ('O que é um ativo financeiro?', 'Recurso que possui valor econômico e pode gerar retorno', TRUE, 3),
      ('O que é um passivo financeiro?', 'Obrigação ou dívida que gera saída de dinheiro', TRUE, 0),
      ('O que é um passivo financeiro?', 'Um investimento', FALSE, 1),
      ('O que é um passivo financeiro?', 'Uma receita', FALSE, 2),
      ('O que é um passivo financeiro?', 'Um lucro', FALSE, 3),
      ('O que é fluxo de caixa?', 'Um cartão', FALSE, 0),
      ('O que é fluxo de caixa?', 'Controle das entradas e saídas de dinheiro', TRUE, 1),
      ('O que é fluxo de caixa?', 'Uma dívida', FALSE, 2),
      ('O que é fluxo de caixa?', 'Apenas saldo bancário', FALSE, 3),
      ('Por que acompanhar o fluxo de caixa é importante?', 'Para entender a situação financeira e tomar decisões melhores', TRUE, 0),
      ('Por que acompanhar o fluxo de caixa é importante?', 'Para aumentar despesas', FALSE, 1),
      ('Por que acompanhar o fluxo de caixa é importante?', 'Para evitar planejamento', FALSE, 2),
      ('Por que acompanhar o fluxo de caixa é importante?', 'Para perder controle', FALSE, 3),
      ('O que é inadimplência?', 'Falta de pagamento de uma obrigação financeira', TRUE, 0),
      ('O que é inadimplência?', 'Economia de dinheiro', FALSE, 1),
      ('O que é inadimplência?', 'Aumento de investimentos', FALSE, 2),
      ('O que é inadimplência?', 'Crescimento da renda', FALSE, 3),
      ('O que é renegociação de dívida?', 'Aumentar juros sempre', FALSE, 0),
      ('O que é renegociação de dívida?', 'Cancelar todos os pagamentos', FALSE, 1),
      ('O que é renegociação de dívida?', 'Processo de alterar condições de pagamento para facilitar a quitação', TRUE, 2),
      ('O que é renegociação de dívida?', 'Criar novas dívidas', FALSE, 3),
      ('O que é crédito responsável?', 'Usar todo limite disponível', FALSE, 0),
      ('O que é crédito responsável?', 'Fazer empréstimos sem análise', FALSE, 1),
      ('O que é crédito responsável?', 'Uso de crédito considerando capacidade de pagamento', TRUE, 2),
      ('O que é crédito responsável?', 'Ignorar juros', FALSE, 3),
      ('O que é planejamento de aposentadoria?', 'Gastar todo dinheiro atual', FALSE, 0),
      ('O que é planejamento de aposentadoria?', 'Fazer dívidas', FALSE, 1),
      ('O que é planejamento de aposentadoria?', 'Organização financeira para garantir recursos no futuro', TRUE, 2),
      ('O que é planejamento de aposentadoria?', 'Evitar investimentos', FALSE, 3),
      ('O que é independência financeira?', 'Gastar sem controle', FALSE, 0),
      ('O que é independência financeira?', 'Situação em que rendimentos conseguem cobrir despesas', TRUE, 1),
      ('O que é independência financeira?', 'Não possuir renda', FALSE, 2),
      ('O que é independência financeira?', 'Ter muitas dívidas', FALSE, 3),
      ('O que é análise financeira?', 'Fazer compras', FALSE, 0),
      ('O que é análise financeira?', 'Avaliação de informações financeiras para tomar decisões', TRUE, 1),
      ('O que é análise financeira?', 'Apenas guardar dinheiro', FALSE, 2),
      ('O que é análise financeira?', 'Criar contas', FALSE, 3),
      ('O que é inflação de demanda?', 'Queda dos investimentos', FALSE, 0),
      ('O que é inflação de demanda?', 'Diminuição da produção sempre', FALSE, 1),
      ('O que é inflação de demanda?', 'Redução dos salários', FALSE, 2),
      ('O que é inflação de demanda?', 'Aumento dos preços causado pelo excesso de procura por produtos e serviços', TRUE, 3),
      ('O que é inflação de custos?', 'Crescimento da poupança', FALSE, 0),
      ('O que é inflação de custos?', 'Redução dos preços por excesso de produtos', FALSE, 1),
      ('O que é inflação de custos?', 'Aumento do salário automaticamente', FALSE, 2),
      ('O que é inflação de custos?', 'Aumento dos preços causado pelo aumento dos custos de produção', TRUE, 3),
      ('O que é deflação?', 'Aumento dos preços', FALSE, 0),
      ('O que é deflação?', 'Crescimento das dívidas', FALSE, 1),
      ('O que é deflação?', 'Aumento dos juros sempre', FALSE, 2),
      ('O que é deflação?', 'Redução geral dos preços de produtos e serviços', TRUE, 3),
      ('O que é taxa de juros?', 'Percentual cobrado ou pago pelo uso do dinheiro', TRUE, 0),
      ('O que é taxa de juros?', 'Preço de um produto', FALSE, 1),
      ('O que é taxa de juros?', 'Valor do salário', FALSE, 2),
      ('O que é taxa de juros?', 'Valor de uma conta', FALSE, 3),
      ('Como uma taxa de juros alta pode afetar empréstimos?', 'Sempre reduz as dívidas', FALSE, 0),
      ('Como uma taxa de juros alta pode afetar empréstimos?', 'Elimina pagamentos', FALSE, 1),
      ('Como uma taxa de juros alta pode afetar empréstimos?', 'Pode tornar o crédito mais caro', TRUE, 2),
      ('Como uma taxa de juros alta pode afetar empréstimos?', 'Aumenta automaticamente a renda', FALSE, 3),
      ('O que é amortização?', 'Processo de redução gradual de uma dívida através de pagamentos', TRUE, 0),
      ('O que é amortização?', 'Criação de uma dívida', FALSE, 1),
      ('O que é amortização?', 'Aumento de juros', FALSE, 2),
      ('O que é amortização?', 'Perda de investimento', FALSE, 3),
      ('O que é financiamento?', 'Operação em que uma instituição fornece recursos para uma compra, com pagamento futuro', TRUE, 0),
      ('O que é financiamento?', 'Dinheiro gratuito', FALSE, 1),
      ('O que é financiamento?', 'Uma doação', FALSE, 2),
      ('O que é financiamento?', 'Um investimento sem risco', FALSE, 3),
      ('Qual a diferença entre financiamento e empréstimo?', 'Financiamento geralmente está ligado a uma finalidade específica; empréstimo pode ter uso mais livre', TRUE, 0),
      ('Qual a diferença entre financiamento e empréstimo?', 'Empréstimo sempre é gratuito', FALSE, 1),
      ('Qual a diferença entre financiamento e empréstimo?', 'Financiamento não possui pagamento', FALSE, 2),
      ('Qual a diferença entre financiamento e empréstimo?', 'Não existe diferença', FALSE, 3),
      ('O que é cheque especial?', 'Reserva de emergência', FALSE, 0),
      ('O que é cheque especial?', 'Cartão de débito', FALSE, 1),
      ('O que é cheque especial?', 'Linha de crédito disponibilizada pelo banco para uso emergencial', TRUE, 2),
      ('O que é cheque especial?', 'Conta de investimento', FALSE, 3),
      ('Por que o cheque especial deve ser usado com cuidado?', 'Porque geralmente possui juros elevados', TRUE, 0),
      ('Por que o cheque especial deve ser usado com cuidado?', 'Porque elimina dívidas', FALSE, 1),
      ('Por que o cheque especial deve ser usado com cuidado?', 'Porque aumenta salário', FALSE, 2),
      ('Por que o cheque especial deve ser usado com cuidado?', 'Porque é investimento', FALSE, 3),
      ('O que é score de crédito?', 'Tipo de cartão', FALSE, 0),
      ('O que é score de crédito?', 'Salário mensal', FALSE, 1),
      ('O que é score de crédito?', 'Valor disponível na conta', FALSE, 2),
      ('O que é score de crédito?', 'Pontuação usada para avaliar histórico financeiro de uma pessoa', TRUE, 3),
      ('Por que um bom score de crédito é importante?', 'Garante riqueza automaticamente', FALSE, 0),
      ('Por que um bom score de crédito é importante?', 'Elimina todos os pagamentos', FALSE, 1),
      ('Por que um bom score de crédito é importante?', 'Pode facilitar acesso a crédito em melhores condições', TRUE, 2),
      ('Por que um bom score de crédito é importante?', 'Substitui investimentos', FALSE, 3),
      ('O que é planejamento tributário?', 'Criar dívidas', FALSE, 0),
      ('O que é planejamento tributário?', 'Cancelar pagamentos', FALSE, 1),
      ('O que é planejamento tributário?', 'Evitar todos os impostos ilegalmente', FALSE, 2),
      ('O que é planejamento tributário?', 'Organização das obrigações fiscais dentro da legislação', TRUE, 3),
      ('O que é imposto?', 'Valor cobrado pelo governo para financiar serviços públicos', TRUE, 0),
      ('O que é imposto?', 'Uma venda', FALSE, 1),
      ('O que é imposto?', 'Um salário', FALSE, 2),
      ('O que é imposto?', 'Um investimento', FALSE, 3),
      ('O que é capital?', 'Um cartão bancário', FALSE, 0),
      ('O que é capital?', 'Uma dívida', FALSE, 1),
      ('O que é capital?', 'Apenas dinheiro perdido', FALSE, 2),
      ('O que é capital?', 'Recursos financeiros utilizados para iniciar ou desenvolver uma atividade', TRUE, 3),
      ('O que é empreendedorismo financeiro?', 'Apenas guardar dinheiro', FALSE, 0),
      ('O que é empreendedorismo financeiro?', 'Evitar qualquer investimento', FALSE, 1),
      ('O que é empreendedorismo financeiro?', 'Criação e gestão de negócios buscando geração de valor e renda', TRUE, 2),
      ('O que é empreendedorismo financeiro?', 'Gastar sem planejamento', FALSE, 3),
      ('O que é preço de venda?', 'Valor do salário', FALSE, 0),
      ('O que é preço de venda?', 'Valor cobrado por um produto ou serviço', TRUE, 1),
      ('O que é preço de venda?', 'Imposto pago', FALSE, 2),
      ('O que é preço de venda?', 'Custo de produção apenas', FALSE, 3),
      ('O que é custo de produção?', 'Investimento bancário', FALSE, 0),
      ('O que é custo de produção?', 'Receita recebida', FALSE, 1),
      ('O que é custo de produção?', 'Lucro final', FALSE, 2),
      ('O que é custo de produção?', 'Gastos necessários para criar um produto ou serviço', TRUE, 3),
      ('O que é ponto de equilíbrio financeiro?', 'Quando não existem vendas', FALSE, 0),
      ('O que é ponto de equilíbrio financeiro?', 'Momento em que receitas cobrem todos os custos e despesas', TRUE, 1),
      ('O que é ponto de equilíbrio financeiro?', 'Momento de maior prejuízo', FALSE, 2),
      ('O que é ponto de equilíbrio financeiro?', 'Quando todos os gastos aumentam', FALSE, 3),
      ('O que é análise de risco financeiro?', 'Avaliação das possibilidades de perdas antes de tomar decisões', TRUE, 0),
      ('O que é análise de risco financeiro?', 'Evitar informações', FALSE, 1),
      ('O que é análise de risco financeiro?', 'Gastar todo dinheiro', FALSE, 2),
      ('O que é análise de risco financeiro?', 'Ignorar problemas financeiros', FALSE, 3),
      ('O que é carteira de investimentos?', 'Conjunto de diferentes investimentos de uma pessoa', TRUE, 0),
      ('O que é carteira de investimentos?', 'Lista de despesas', FALSE, 1),
      ('O que é carteira de investimentos?', 'Conta bancária', FALSE, 2),
      ('O que é carteira de investimentos?', 'Carteira física de documentos', FALSE, 3),
      ('O que é um fundo de investimento?', 'Um cartão bancário', FALSE, 0),
      ('O que é um fundo de investimento?', 'Reunião de recursos de vários investidores administrados por uma instituição', TRUE, 1),
      ('O que é um fundo de investimento?', 'Uma dívida pessoal', FALSE, 2),
      ('O que é um fundo de investimento?', 'Um salário', FALSE, 3),
      ('O que é renda fixa?', 'Compra de produtos', FALSE, 0),
      ('O que é renda fixa?', 'Despesa mensal', FALSE, 1),
      ('O que é renda fixa?', 'Investimento sem nenhuma informação', FALSE, 2),
      ('O que é renda fixa?', 'Investimento com regras de remuneração definidas previamente', TRUE, 3),
      ('O que é renda variável?', 'Conta mensal', FALSE, 0),
      ('O que é renda variável?', 'Imposto', FALSE, 1),
      ('O que é renda variável?', 'Salário fixo', FALSE, 2),
      ('O que é renda variável?', 'Investimento cujo retorno pode variar conforme o mercado', TRUE, 3),
      ('O que é análise fundamentalista?', 'Escolha aleatória de investimentos', FALSE, 0),
      ('O que é análise fundamentalista?', 'Avaliação de dados financeiros e econômicos de uma empresa', TRUE, 1),
      ('O que é análise fundamentalista?', 'Controle de despesas pessoais', FALSE, 2),
      ('O que é análise fundamentalista?', 'Criação de cartões', FALSE, 3),
      ('O que é planejamento financeiro empresarial?', 'Organização dos recursos financeiros de uma empresa', TRUE, 0),
      ('O que é planejamento financeiro empresarial?', 'Fazer publicidade', FALSE, 1),
      ('O que é planejamento financeiro empresarial?', 'Criar produtos', FALSE, 2),
      ('O que é planejamento financeiro empresarial?', 'Apenas controlar vendas', FALSE, 3),
      ('O que é orçamento empresarial?', 'Lista de funcionários', FALSE, 0),
      ('O que é orçamento empresarial?', 'Documento de identidade', FALSE, 1),
      ('O que é orçamento empresarial?', 'Contrato bancário', FALSE, 2),
      ('O que é orçamento empresarial?', 'Planejamento das receitas, despesas e investimentos de uma empresa', TRUE, 3),
      ('O que é sustentabilidade financeira?', 'Gastar todos os recursos', FALSE, 0),
      ('O que é sustentabilidade financeira?', 'Criar dívidas constantes', FALSE, 1),
      ('O que é sustentabilidade financeira?', 'Capacidade de manter equilíbrio financeiro ao longo do tempo', TRUE, 2),
      ('O que é sustentabilidade financeira?', 'Evitar planejamento', FALSE, 3),
      ('O que é independência financeira pessoal?', 'Quando depende sempre de empréstimos', FALSE, 0),
      ('O que é independência financeira pessoal?', 'Quando não possui renda', FALSE, 1),
      ('O que é independência financeira pessoal?', 'Quando uma pessoa consegue manter seu padrão de vida com seus próprios recursos', TRUE, 2),
      ('O que é independência financeira pessoal?', 'Quando ignora despesas', FALSE, 3),
      ('Qual é uma boa prática para melhorar a saúde financeira?', 'Gastar sem acompanhamento', FALSE, 0),
      ('Qual é uma boa prática para melhorar a saúde financeira?', 'Evitar qualquer organização', FALSE, 1),
      ('Qual é uma boa prática para melhorar a saúde financeira?', 'Fazer dívidas constantemente', FALSE, 2),
      ('Qual é uma boa prática para melhorar a saúde financeira?', 'Controlar gastos, criar reservas e planejar objetivos', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_medio_v2;

    RAISE NOTICE '54 perguntas inseridas com sucesso (source=seed_financas_medio_v2).';
  END IF;
END $$;

COMMIT;
