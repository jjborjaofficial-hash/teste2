-- Explicações pedagógicas (BE-004) — Finanças, nível Fácil, lote 12 (10 perguntas): as 7 que
-- faltavam do seed 064 (perguntas 53 a 59, source 'seed_financas_facil_v2') e as 3 do seed 068
-- (source 'seed_financas_facil_v3', seed completo). Mesmo critério das migrations 109 a 118: só
-- preenche questions.explanation das perguntas que ainda não têm explicação (idempotente, nunca
-- sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_facil_v2', 'O que é uma fonte de renda?',
     'Fonte de renda é a origem de onde uma pessoa recebe dinheiro, como um salário ou um negócio. Dívida, imposto e despesa são dinheiro que se deve ou que sai, não de onde o dinheiro vem.'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma fonte de renda?',
     'Salário ou negócio próprio são fontes de renda, porque trazem dinheiro para quem trabalha. Conta de energia, compra de roupa e pagamento de dívida são despesas: dinheiro que sai.'),
    ('seed_financas_facil_v2', 'O que é renda extra?',
     'Renda extra é o dinheiro recebido além da renda principal, como um trabalho ocasional ou a venda de algo. Ajuda a alcançar objetivos ou a reforçar a reserva. Não é dívida, despesa fixa nem imposto.'),
    ('seed_financas_facil_v2', 'Qual é uma forma de aumentar a renda?',
     'Uma forma de aumentar a renda é criar novas fontes de ganhos, como um trabalho extra ou um pequeno negócio. Gastar mais, ignorar oportunidades ou fazer dívidas não aumenta a renda.'),
    ('seed_financas_facil_v2', 'O que é responsabilidade financeira?',
     'Responsabilidade financeira é usar o dinheiro de forma consciente e planejada, cumprindo compromissos e guardando uma parte. Evitar controle, comprar por impulso e gastar sem limites é o contrário.'),
    ('seed_financas_facil_v2', 'O que é segurança financeira?',
     'Segurança financeira é a situação em que a pessoa tem mais controle e estabilidade com o dinheiro e consegue enfrentar imprevistos sem sufoco. Ter muitas dívidas, não planejar ou gastar tudo afasta dessa segurança.'),
    ('seed_financas_facil_v2', 'Qual é o primeiro passo para melhorar a vida financeira?',
     'O primeiro passo é conhecer a situação financeira atual: quanto se ganha, quanto se gasta e quanto se deve. Só com esse retrato dá para planejar. Ignorar receitas e despesas ou fazer mais dívidas piora a situação.'),
    ('seed_financas_facil_v3', 'O que é uma conta de poupança?',
     'Conta de poupança é uma conta feita para guardar dinheiro e receber rendimentos. Não é cartão de crédito nem empréstimo, e não serve para fazer dívidas. É um lugar para juntar dinheiro para os seus objetivos.'),
    ('seed_financas_facil_v3', 'Por que é importante guardar parte da renda?',
     'Guardar parte da renda cria segurança financeira e permite alcançar objetivos futuros, como estudar ou comprar algo importante. Quem guarda também fica menos exposto a imprevistos.'),
    ('seed_financas_facil_v3', 'O que é uma despesa desnecessária?',
     'Despesa desnecessária é o gasto que pode ser evitado sem prejudicar as necessidades básicas. Pagamento obrigatório, conta essencial e investimento importante não são desnecessários. Cortar o que é desnecessário libera dinheiro para guardar.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças fácil lote 12: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
