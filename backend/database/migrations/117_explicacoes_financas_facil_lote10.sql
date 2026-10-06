-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 10 (10 perguntas: 33 a 42 do
-- seed 064, source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 116: só preenche
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
    ('O que é extrato bancário?',
     'O extrato bancário é o documento que mostra as movimentações de uma conta: entradas, saídas e saldo. Serve para conferir se está tudo certo e para acompanhar os gastos.'),
    ('O que é transferência bancária?',
     'Transferência bancária é o envio de dinheiro de uma conta para outra. O dinheiro sai da conta de quem envia e entra na de quem recebe. Não cria dinheiro novo nem é um empréstimo.'),
    ('O que é pagamento digital?',
     'Pagamento digital é o pagamento feito por meios eletrônicos, como aplicativo, cartão ou dinheiro móvel, sem usar notas e moedas. É prático, mas vale conferir os valores antes de confirmar.'),
    ('Qual é um exemplo de pagamento digital?',
     'Pagar por um aplicativo bancário é um pagamento digital, porque é feito por meio eletrônico. Troca de moedas antigas, documento impresso ou pagamento sem valor não são pagamentos digitais.'),
    ('O que é carteira digital?',
     'Carteira digital é um aplicativo que permite guardar e movimentar valores pelo telemóvel. Não é um cartão de memória nem uma carteira física de documentos.'),
    ('O que é M-Pesa?',
     'M-Pesa é um serviço de dinheiro móvel que permite fazer pagamentos e transferências pelo telemóvel. Não é uma rede social, um cartão de computador nem um investimento.'),
    ('O que é uma transação financeira?',
     'Transação financeira é qualquer operação que movimenta dinheiro, como pagar, receber, transferir ou levantar. Instalar programas ou guardar documentos não movimenta dinheiro, por isso não é transação financeira.'),
    ('O que é compra por impulso?',
     'Compra por impulso é a feita sem planejamento prévio, só porque deu vontade na hora. Costuma gerar gastos desnecessários. Quem compra com orçamento definido faz o contrário.'),
    ('Por que comparar preços é importante?',
     'Comparar preços é importante para encontrar as melhores opções e economizar, pagando só o que vale. Não serve para evitar planejamento, aumentar gastos nem criar dívidas.'),
    ('O que é promoção financeira?',
     'Promoção é uma oferta temporária que reduz o preço ou dá uma vantagem. Só ajuda se for algo que você já precisava comprar. Não é um empréstimo, uma conta bancária nem um investimento.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v2'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 10: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
