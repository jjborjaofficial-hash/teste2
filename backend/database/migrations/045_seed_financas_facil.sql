-- Migration/seed: conteúdo Finanças, nível Fácil (33 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 33 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (54 — distinta das seeds 42 a
-- 53 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Finanças" (slug: financas) já existe desde a
-- migration 021.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_facil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_facil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_facil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_financas_facil_v1'
    FROM (VALUES
      ('O que é receita?'),
      ('O que é despesa?'),
      ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?'),
      ('O que significa ter saldo positivo?'),
      ('Qual destas opções representa uma necessidade básica?'),
      ('O que é consumo?'),
      ('Para que serve uma conta bancária?'),
      ('O que é um recibo?'),
      ('O que significa economizar?'),
      ('Qual é a melhor atitude antes de fazer uma compra não planejada?'),
      ('O que é preço?'),
      ('O que significa gastar por impulso?'),
      ('Qual destes pode ser considerado um gasto com transporte?'),
      ('O que é dinheiro?'),
      ('Qual é uma vantagem de guardar parte da renda?'),
      ('O que é uma compra planejada?'),
      ('O que significa preço promocional?'),
      ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?'),
      ('O que é um objetivo financeiro?'),
      ('Qual é um exemplo de objetivo financeiro?'),
      ('Qual é a principal finalidade de um orçamento pessoal?'),
      ('O que significa poupar dinheiro?'),
      ('Qual destes é um exemplo de despesa fixa?'),
      ('O que caracteriza uma despesa variável?'),
      ('Para que serve uma reserva de emergência?'),
      ('O que acontece quando uma pessoa gasta continuamente mais do que recebe?'),
      ('Qual é uma vantagem de comparar preços antes de comprar?'),
      ('O que é uma dívida?'),
      ('Qual comportamento pode ajudar no controle financeiro?'),
      ('O que é renda?'),
      ('Qual atitude representa consumo consciente?'),
      ('Qual é uma boa razão para estabelecer metas financeiras?'),
      ('Qual destas práticas pode melhorar a saúde financeira?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_facil q
    JOIN (VALUES
      ('O que é receita?', 'Um imposto', FALSE, 0),
      ('O que é receita?', 'Dinheiro que sai', FALSE, 1),
      ('O que é receita?', 'Uma dívida', FALSE, 2),
      ('O que é receita?', 'Dinheiro que entra', TRUE, 3),
      ('O que é despesa?', 'Dinheiro recebido', FALSE, 0),
      ('O que é despesa?', 'Lucro', FALSE, 1),
      ('O que é despesa?', 'Dinheiro investido obrigatoriamente', FALSE, 2),
      ('O que é despesa?', 'Dinheiro gasto para pagar algo', TRUE, 3),
      ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?', '4.000 MZN', FALSE, 0),
      ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?', '7.000 MZN', FALSE, 1),
      ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?', '3.000 MZN', TRUE, 2),
      ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?', '2.000 MZN', FALSE, 3),
      ('O que significa ter saldo positivo?', 'Não possuir dinheiro', FALSE, 0),
      ('O que significa ter saldo positivo?', 'Receber mais do que gasta', TRUE, 1),
      ('O que significa ter saldo positivo?', 'Gastar mais do que recebe', FALSE, 2),
      ('O que significa ter saldo positivo?', 'Ter apenas dívidas', FALSE, 3),
      ('Qual destas opções representa uma necessidade básica?', 'Videogame novo', FALSE, 0),
      ('Qual destas opções representa uma necessidade básica?', 'Alimentação', TRUE, 1),
      ('Qual destas opções representa uma necessidade básica?', 'Viagem de férias', FALSE, 2),
      ('Qual destas opções representa uma necessidade básica?', 'Joia de luxo', FALSE, 3),
      ('O que é consumo?', 'Apenas pedir empréstimo', FALSE, 0),
      ('O que é consumo?', 'Utilização de bens ou serviços', TRUE, 1),
      ('O que é consumo?', 'Apenas guardar dinheiro', FALSE, 2),
      ('O que é consumo?', 'Apenas investir', FALSE, 3),
      ('Para que serve uma conta bancária?', 'Guardar e movimentar dinheiro por meio de serviços financeiros', TRUE, 0),
      ('Para que serve uma conta bancária?', 'Somente pagar impostos', FALSE, 1),
      ('Para que serve uma conta bancária?', 'Apenas receber mensagens', FALSE, 2),
      ('Para que serve uma conta bancária?', 'Apenas comprar roupas', FALSE, 3),
      ('O que é um recibo?', 'Um investimento', FALSE, 0),
      ('O que é um recibo?', 'Uma moeda', FALSE, 1),
      ('O que é um recibo?', 'Documento que comprova uma transação ou pagamento', TRUE, 2),
      ('O que é um recibo?', 'Uma dívida', FALSE, 3),
      ('O que significa economizar?', 'Pedir dinheiro emprestado', FALSE, 0),
      ('O que significa economizar?', 'Reduzir ou controlar gastos para preservar recursos', TRUE, 1),
      ('O que significa economizar?', 'Gastar tudo imediatamente', FALSE, 2),
      ('O que significa economizar?', 'Aumentar dívidas', FALSE, 3),
      ('Qual é a melhor atitude antes de fazer uma compra não planejada?', 'Ignorar o preço', FALSE, 0),
      ('Qual é a melhor atitude antes de fazer uma compra não planejada?', 'Comprar imediatamente', FALSE, 1),
      ('Qual é a melhor atitude antes de fazer uma compra não planejada?', 'Pedir dinheiro emprestado sem analisar', FALSE, 2),
      ('Qual é a melhor atitude antes de fazer uma compra não planejada?', 'Verificar se há dinheiro disponível e se a compra é necessária', TRUE, 3),
      ('O que é preço?', 'Quantidade de dinheiro guardada', FALSE, 0),
      ('O que é preço?', 'Valor de uma dívida', FALSE, 1),
      ('O que é preço?', 'Valor sempre recebido pelo trabalhador', FALSE, 2),
      ('O que é preço?', 'Valor cobrado por um produto ou serviço', TRUE, 3),
      ('O que significa gastar por impulso?', 'Comprar sem planejamento ou reflexão suficiente', TRUE, 0),
      ('O que significa gastar por impulso?', 'Comparar preços cuidadosamente', FALSE, 1),
      ('O que significa gastar por impulso?', 'Planejar uma compra com antecedência', FALSE, 2),
      ('O que significa gastar por impulso?', 'Poupar antes de comprar', FALSE, 3),
      ('Qual destes pode ser considerado um gasto com transporte?', 'Passagem de autocarro', TRUE, 0),
      ('Qual destes pode ser considerado um gasto com transporte?', 'Alimento', FALSE, 1),
      ('Qual destes pode ser considerado um gasto com transporte?', 'Caderno', FALSE, 2),
      ('Qual destes pode ser considerado um gasto com transporte?', 'Livro', FALSE, 3),
      ('O que é dinheiro?', 'Apenas papel', FALSE, 0),
      ('O que é dinheiro?', 'Meio utilizado para realizar trocas e pagamentos', TRUE, 1),
      ('O que é dinheiro?', 'Apenas crédito bancário', FALSE, 2),
      ('O que é dinheiro?', 'Apenas moeda metálica', FALSE, 3),
      ('Qual é uma vantagem de guardar parte da renda?', 'Ter recursos disponíveis para objetivos futuros', TRUE, 0),
      ('Qual é uma vantagem de guardar parte da renda?', 'Aumentar automaticamente as despesas', FALSE, 1),
      ('Qual é uma vantagem de guardar parte da renda?', 'Garantir riqueza imediata', FALSE, 2),
      ('Qual é uma vantagem de guardar parte da renda?', 'Eliminar todos os impostos', FALSE, 3),
      ('O que é uma compra planejada?', 'Compra feita sem verificar o preço', FALSE, 0),
      ('O que é uma compra planejada?', 'Compra feita sempre com empréstimo', FALSE, 1),
      ('O que é uma compra planejada?', 'Compra decidida previamente após considerar necessidade e recursos', TRUE, 2),
      ('O que é uma compra planejada?', 'Compra realizada por pressão', FALSE, 3),
      ('O que significa preço promocional?', 'Preço reduzido ou condição especial oferecida durante uma promoção', TRUE, 0),
      ('O que significa preço promocional?', 'Preço de um empréstimo', FALSE, 1),
      ('O que significa preço promocional?', 'Preço obrigatoriamente mais alto', FALSE, 2),
      ('O que significa preço promocional?', 'Valor de um salário', FALSE, 3),
      ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 'Comprar tudo imediatamente', FALSE, 0),
      ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 'Nunca verificar o orçamento', FALSE, 1),
      ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 'Ignorar promoções e preços', FALSE, 2),
      ('Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 'Comparar produtos e preços antes de comprar', TRUE, 3),
      ('O que é um objetivo financeiro?', 'Uma compra aleatória', FALSE, 0),
      ('O que é um objetivo financeiro?', 'Resultado relacionado ao dinheiro que uma pessoa pretende alcançar', TRUE, 1),
      ('O que é um objetivo financeiro?', 'Uma dívida obrigatória', FALSE, 2),
      ('O que é um objetivo financeiro?', 'Um imposto', FALSE, 3),
      ('Qual é um exemplo de objetivo financeiro?', 'Juntar dinheiro para comprar um computador', TRUE, 0),
      ('Qual é um exemplo de objetivo financeiro?', 'Gastar todo o salário', FALSE, 1),
      ('Qual é um exemplo de objetivo financeiro?', 'Aumentar uma dívida', FALSE, 2),
      ('Qual é um exemplo de objetivo financeiro?', 'Ignorar as despesas', FALSE, 3),
      ('Qual é a principal finalidade de um orçamento pessoal?', 'Eliminar todos os impostos', FALSE, 0),
      ('Qual é a principal finalidade de um orçamento pessoal?', 'Aumentar automaticamente o salário', FALSE, 1),
      ('Qual é a principal finalidade de um orçamento pessoal?', 'Controlar receitas e despesas', TRUE, 2),
      ('Qual é a principal finalidade de um orçamento pessoal?', 'Evitar qualquer tipo de gasto', FALSE, 3),
      ('O que significa poupar dinheiro?', 'Comprar apenas produtos caros', FALSE, 0),
      ('O que significa poupar dinheiro?', 'Pedir dinheiro emprestado', FALSE, 1),
      ('O que significa poupar dinheiro?', 'Guardar parte do dinheiro para uso futuro', TRUE, 2),
      ('O que significa poupar dinheiro?', 'Gastar todo o dinheiro disponível', FALSE, 3),
      ('Qual destes é um exemplo de despesa fixa?', 'Lanche eventual', FALSE, 0),
      ('Qual destes é um exemplo de despesa fixa?', 'Passeio', FALSE, 1),
      ('Qual destes é um exemplo de despesa fixa?', 'Aluguel', TRUE, 2),
      ('Qual destes é um exemplo de despesa fixa?', 'Compra ocasional de roupa', FALSE, 3),
      ('O que caracteriza uma despesa variável?', 'É sempre uma dívida', FALSE, 0),
      ('O que caracteriza uma despesa variável?', 'Nunca precisa ser paga', FALSE, 1),
      ('O que caracteriza uma despesa variável?', 'Pode mudar de valor de um período para outro', TRUE, 2),
      ('O que caracteriza uma despesa variável?', 'Possui sempre exatamente o mesmo valor', FALSE, 3),
      ('Para que serve uma reserva de emergência?', 'Para comprar produtos de luxo', FALSE, 0),
      ('Para que serve uma reserva de emergência?', 'Para aumentar despesas mensais', FALSE, 1),
      ('Para que serve uma reserva de emergência?', 'Para cobrir despesas inesperadas', TRUE, 2),
      ('Para que serve uma reserva de emergência?', 'Para evitar trabalhar', FALSE, 3),
      ('O que acontece quando uma pessoa gasta continuamente mais do que recebe?', 'Aumenta automaticamente seu patrimônio', FALSE, 0),
      ('O que acontece quando uma pessoa gasta continuamente mais do que recebe?', 'Reduz seus gastos', FALSE, 1),
      ('O que acontece quando uma pessoa gasta continuamente mais do que recebe?', 'Aumenta sua poupança', FALSE, 2),
      ('O que acontece quando uma pessoa gasta continuamente mais do que recebe?', 'Pode acumular dívidas', TRUE, 3),
      ('Qual é uma vantagem de comparar preços antes de comprar?', 'Pode ajudar a encontrar melhor custo-benefício', TRUE, 0),
      ('Qual é uma vantagem de comparar preços antes de comprar?', 'Garante que o produto seja gratuito', FALSE, 1),
      ('Qual é uma vantagem de comparar preços antes de comprar?', 'Aumenta automaticamente o salário', FALSE, 2),
      ('Qual é uma vantagem de comparar preços antes de comprar?', 'Elimina todos os riscos financeiros', FALSE, 3),
      ('O que é uma dívida?', 'Um tipo de salário', FALSE, 0),
      ('O que é uma dívida?', 'Uma forma de investimento garantido', FALSE, 1),
      ('O que é uma dívida?', 'Dinheiro que nunca precisa ser devolvido', FALSE, 2),
      ('O que é uma dívida?', 'Dinheiro que uma pessoa ou entidade deve a outra', TRUE, 3),
      ('Qual comportamento pode ajudar no controle financeiro?', 'Ignorar todas as despesas', FALSE, 0),
      ('Qual comportamento pode ajudar no controle financeiro?', 'Comprar por impulso', FALSE, 1),
      ('Qual comportamento pode ajudar no controle financeiro?', 'Utilizar todo o salário imediatamente', FALSE, 2),
      ('Qual comportamento pode ajudar no controle financeiro?', 'Registrar receitas e gastos', TRUE, 3),
      ('O que é renda?', 'Apenas dinheiro encontrado na rua', FALSE, 0),
      ('O que é renda?', 'Recursos financeiros recebidos por uma pessoa ou entidade', TRUE, 1),
      ('O que é renda?', 'Somente dinheiro guardado', FALSE, 2),
      ('O que é renda?', 'Apenas dinheiro emprestado', FALSE, 3),
      ('Qual atitude representa consumo consciente?', 'Comprar sem verificar necessidade', FALSE, 0),
      ('Qual atitude representa consumo consciente?', 'Avaliar necessidade, preço e qualidade antes da compra', TRUE, 1),
      ('Qual atitude representa consumo consciente?', 'Comprar tudo em promoção', FALSE, 2),
      ('Qual atitude representa consumo consciente?', 'Comprar sempre o produto mais caro', FALSE, 3),
      ('Qual é uma boa razão para estabelecer metas financeiras?', 'Ter uma direção para o uso e crescimento do dinheiro', TRUE, 0),
      ('Qual é uma boa razão para estabelecer metas financeiras?', 'Aumentar dívidas', FALSE, 1),
      ('Qual é uma boa razão para estabelecer metas financeiras?', 'Evitar qualquer planejamento', FALSE, 2),
      ('Qual é uma boa razão para estabelecer metas financeiras?', 'Gastar mais rapidamente', FALSE, 3),
      ('Qual destas práticas pode melhorar a saúde financeira?', 'Planejar gastos antes de receber o dinheiro', TRUE, 0),
      ('Qual destas práticas pode melhorar a saúde financeira?', 'Ignorar dívidas', FALSE, 1),
      ('Qual destas práticas pode melhorar a saúde financeira?', 'Pedir empréstimos para despesas desnecessárias', FALSE, 2),
      ('Qual destas práticas pode melhorar a saúde financeira?', 'Gastar primeiro e calcular depois', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_facil;

    RAISE NOTICE '33 perguntas inseridas com sucesso (source=seed_financas_facil_v1).';
  END IF;
END $$;

COMMIT;
