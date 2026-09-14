-- Seed: conteúdo Finanças, nível Fácil (4 perguntas)
-- Fonte: perguntas ELABORADAS POR IA (Claude), a pedido do proprietário do
-- projeto, para completar a categoria/dificuldade que ainda não tinha
-- atingido 100 perguntas (estava em 96). Não vieram de um documento
-- fornecido pelo proprietário — recomenda-se revisão humana antes de
-- considerar definitivas.
--
-- Confirmado por comparação de texto normalizado contra as 1.646 perguntas
-- já existentes no banco: nenhuma duplicata.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_facil_v5') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_facil_v5) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_facil5 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_financas_facil_v5'
    FROM (VALUES
      ('O que é uma fatura?'),
      ('O que é câmbio de moeda?'),
      ('O que é um cheque?'),
      ('O que é uma prestação (parcela) de um empréstimo?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_facil5 q
    JOIN (VALUES
      ('O que é uma fatura?', 'Um tipo de investimento', FALSE, 0),
      ('O que é uma fatura?', 'Um cartão bancário', FALSE, 1),
      ('O que é uma fatura?', 'Documento que detalha valores a pagar por um produto ou serviço', TRUE, 2),
      ('O que é uma fatura?', 'Uma taxa de juro', FALSE, 3),

      ('O que é câmbio de moeda?', 'Aumento automático do salário', FALSE, 0),
      ('O que é câmbio de moeda?', 'Troca de uma moeda por outra, geralmente a uma taxa de conversão', TRUE, 1),
      ('O que é câmbio de moeda?', 'Um tipo de imposto', FALSE, 2),
      ('O que é câmbio de moeda?', 'Uma forma de poupança obrigatória', FALSE, 3),

      ('O que é um cheque?', 'Documento que ordena o pagamento de um valor a partir de uma conta bancária', TRUE, 0),
      ('O que é um cheque?', 'Um cartão de crédito', FALSE, 1),
      ('O que é um cheque?', 'Uma aplicação financeira', FALSE, 2),
      ('O que é um cheque?', 'Um comprovativo de poupança', FALSE, 3),

      ('O que é uma prestação (parcela) de um empréstimo?', 'O valor total do empréstimo', FALSE, 0),
      ('O que é uma prestação (parcela) de um empréstimo?', 'Uma multa por atraso', FALSE, 1),
      ('O que é uma prestação (parcela) de um empréstimo?', 'Um tipo de investimento', FALSE, 2),
      ('O que é uma prestação (parcela) de um empréstimo?', 'Cada um dos pagamentos periódicos feitos para quitar um empréstimo', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_facil5;

    RAISE NOTICE '4 perguntas inseridas com sucesso (source=seed_financas_facil_v5).';
  END IF;
END $$;

COMMIT;
