-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 01 (5 perguntas).
-- Preenche questions.explanation (coluna criada na migration 022) com o "Por quê?" de
-- cada pergunta: linguagem simples e curta, conforme docs/quiz-v2-rodadas-e-feedback.md.
-- Só atualiza perguntas do seed 'seed_financas_facil_v1' que ainda não têm explicação,
-- então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir (ex.: removida por deduplicação), ela
-- é simplesmente ignorada: esta migration nunca falha por isso, para não impedir o
-- arranque do backend (as migrations correm no deploy). O runner já envolve o ficheiro
-- numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('O que é receita?',
     'Receita é todo o dinheiro que entra, como salário, vendas ou pagamentos recebidos. A despesa é o contrário: dinheiro que sai. Separar o que entra do que sai é o primeiro passo para organizar as finanças.'),
    ('O que é despesa?',
     'Despesa é o dinheiro que sai para pagar algo, como contas, compras ou serviços. É o oposto da receita, que é o dinheiro que entra. Saber quanto se gasta ajuda a não gastar mais do que se ganha.'),
    ('Se uma pessoa recebe 10.000 MZN e gasta 7.000 MZN, quanto sobra?',
     'Para saber quanto sobra, subtrai-se a despesa da receita: 10.000 − 7.000 = 3.000 MZN. Esse valor que sobra pode ser guardado ou usado para alcançar um objetivo.'),
    ('O que significa ter saldo positivo?',
     'Saldo positivo quer dizer que entrou mais dinheiro do que saiu. É o resultado de manter as despesas abaixo da receita, e a diferença pode ser guardada. O contrário, o saldo negativo, aparece quando se gasta mais do que se recebe.'),
    ('Qual destas opções representa uma necessidade básica?',
     'Necessidades básicas são as coisas essenciais para viver, como alimentação, moradia e saúde. Videogame, viagem de férias e joias são desejos: dão prazer, mas dá para viver sem eles. Num orçamento, as necessidades vêm primeiro.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v1'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 01: % pergunta(s) atualizada(s) (esperado: 5).', v_updated;
END $$;
