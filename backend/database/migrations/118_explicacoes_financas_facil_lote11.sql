-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 11 (10 perguntas: 43 a 52 do
-- seed 064, source 'seed_financas_facil_v2'). Mesmo critério das migrations 109 a 117: só preenche
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
    ('O que é um objetivo financeiro de curto prazo?',
     'Objetivo financeiro de curto prazo é uma meta que dá para alcançar em pouco tempo, como juntar dinheiro para um telemóvel ou pagar uma conta pequena. Não é uma dívida permanente nem um gasto sem planejamento.'),
    ('O que é um objetivo financeiro de longo prazo?',
     'Objetivo financeiro de longo prazo é uma meta que exige mais tempo e planejamento, como comprar uma casa ou montar um negócio. Compra imediata, pequeno gasto diário e conta simples não são metas de longo prazo.'),
    ('Por que é importante definir metas financeiras?',
     'Definir metas financeiras orienta o uso do dinheiro e facilita as decisões, porque você sabe para onde quer ir. Sem metas, é fácil gastar sem controle e deixar de guardar.'),
    ('O que é disciplina financeira?',
     'Disciplina financeira é a capacidade de seguir um planejamento ligado ao dinheiro, mesmo quando dá vontade de gastar. Gastar tudo, evitar qualquer controle e comprar sem parar são o contrário.'),
    ('O que é educação financeira?',
     'Educação financeira é o conhecimento para administrar melhor o dinheiro: orçar, poupar, usar crédito com cuidado e evitar dívidas. Não é só matemática nem tem a ver com abrir contas ou guardar documentos.'),
    ('Por que a educação financeira é importante?',
     'A educação financeira ajuda a tomar melhores decisões sobre o dinheiro. Ela não elimina riscos, não impede gastos nem torna compras gratuitas, mas reduz erros que custam caro.'),
    ('O que é um hábito financeiro?',
     'Hábito financeiro é um comportamento repetido relacionado ao uso do dinheiro, como anotar os gastos ou guardar uma parte do que se ganha. Cartão, investimento obrigatório e dívida bancária não são hábitos.'),
    ('Qual hábito ajuda na organização financeira?',
     'Registrar receitas e despesas ajuda a organizar as finanças, porque mostra para onde o dinheiro vai. Fazer dívidas sem análise, ignorar contas e gastar sem acompanhar desorganizam o orçamento.'),
    ('O que é controle financeiro?',
     'Controle financeiro é acompanhar a entrada e a saída de dinheiro: o que se recebe, o que se gasta e o que sobra. Evitar pagamentos ou gastar sem limites não é controle.'),
    ('O que é planejamento de gastos?',
     'Planejamento de gastos é definir antecipadamente como o dinheiro será usado, antes de gastar. Isso evita compras de última hora e ajuda a separar o que vai para as contas, os desejos e a poupança.')
  ) AS v(statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = 'seed_financas_facil_v2'
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 11: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
