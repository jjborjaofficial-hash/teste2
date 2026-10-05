-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 07 (10 perguntas: 3 a 12 do
-- seed 064, source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 113: só preenche
-- questions.explanation das perguntas que ainda não têm explicação (idempotente, nunca
-- sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('O que é uma despesa?',
     'Despesa é o dinheiro usado para pagar algo, como contas, comida ou transporte. É o contrário da receita, que é o dinheiro que entra. Não é lucro nem investimento: é dinheiro que sai.'),
    ('O que significa economizar dinheiro?',
     'Economizar é guardar parte do dinheiro para usar no futuro, gastando com atenção ao que realmente é necessário. Não é gastar tudo na hora, nem fazer dívidas, nem deixar de comprar o que é essencial.'),
    ('O que é orçamento pessoal?',
     'Orçamento pessoal é o planejamento das receitas e despesas de uma pessoa: quanto entra, quanto sai e quanto sobra. Dá uma visão clara do mês e ajuda a decidir onde gastar e quanto guardar.'),
    ('Por que criar um orçamento?',
     'Criar um orçamento serve para controlar melhor o dinheiro: saber para onde ele vai, evitar gastar mais do que se ganha e separar uma parte para guardar. Sem orçamento é fácil perder o controle sem perceber.'),
    ('O que é poupança?',
     'Poupança é o dinheiro guardado para objetivos futuros ou imprevistos. Não é dívida nem imposto. Guardar com regularidade, mesmo que pouco, cria uma reserva que cresce com o tempo.'),
    ('O que é um banco?',
     'Banco é uma instituição que oferece serviços financeiros, como guardar dinheiro, fazer pagamentos e transferências e conceder empréstimos. Existe para organizar o uso do dinheiro com mais segurança.'),
    ('O que é uma conta bancária?',
     'Conta bancária é um serviço usado para guardar e movimentar dinheiro: receber, pagar, transferir e levantar. Fica num banco e permite acompanhar tudo o que entra e sai.'),
    ('O que é cartão de débito?',
     'O cartão de débito paga com o dinheiro que já está na conta: o valor sai do saldo na hora da compra. Por isso não cria dívida nem dinheiro novo, e só se gasta o que existe de saldo.'),
    ('O que é cartão de crédito?',
     'O cartão de crédito permite comprar usando um limite concedido pelo banco, e o valor é pago depois. Não é dinheiro gratuito nem poupança: o que se gasta precisa ser pago, e atrasos podem gerar juros.'),
    ('O que é dívida?',
     'Dívida é um valor que uma pessoa deve pagar a outra, como um empréstimo ou uma compra a prazo. Não é lucro nem dinheiro de graça. Pagar no prazo evita juros e problemas.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v2'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 07: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
