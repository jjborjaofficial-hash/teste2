-- Explicações pedagógicas (BE-004) — Finanças difícil lote 25, perguntas 16 a 25 do seed 047 (10 perguntas). Mesmo critério das migrations 109 a
-- 131: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v1', 'Por que a taxa de inflação é importante para decisões financeiras de longo prazo?',
     'A inflação reduz o poder de compra do dinheiro ao longo do tempo: a mesma quantia compra menos daqui a anos. Por isso, em decisões de longo prazo, como poupar para a reforma, é preciso que o dinheiro renda mais do que a inflação. Ela não aumenta o poder de compra, afeta os preços e não elimina os juros.'),
    ('seed_financas_dificil_v1', 'O que é taxa nominal?',
     'Taxa nominal é a taxa expressa sem descontar o efeito da inflação, ou seja, o número "de contrato". Para saber o ganho de verdade, é preciso compará-la com a inflação e chegar à taxa real. Uma taxa nominal alta pode dar ganho real pequeno ou até negativo, e ela pode mudar, como as taxas variáveis.'),
    ('seed_financas_dificil_v1', 'Qual é a relação entre risco e retorno em investimentos?',
     'Em geral, quem busca retornos potenciais maiores precisa aceitar riscos maiores, porque o risco é o preço desse possível ganho. Mas é uma relação de tendência: maior risco não garante maior lucro, e pode trazer perdas. Também não é verdade que menor risco rende mais.'),
    ('seed_financas_dificil_v1', 'O que significa liquidação de uma dívida?',
     'Liquidar uma dívida é pagar toda a obrigação, de modo que ela deixa de existir. Difere da amortização, que reduz a dívida aos poucos. Não é criar nova dívida, aumentar o prazo nem suspender o pagamento.'),
    ('seed_financas_dificil_v1', 'O que é solvência?',
     'Solvência é a capacidade de cumprir as obrigações financeiras no longo prazo, ou seja, ter bens e recursos suficientes para pagar o que se deve. Quem tem mais bens do que dívidas é solvente, mesmo que num dado momento falte dinheiro em caixa. Não é só dinheiro em espécie nem capacidade de fazer uma compra.'),
    ('seed_financas_dificil_v1', 'Qual é a diferença entre liquidez e solvência?',
     'Liquidez olha para o curto prazo: há dinheiro ou algo facilmente convertível para pagar as contas que vencem já. Solvência olha para o longo prazo: no total, os bens cobrem as dívidas. Uma pessoa ou empresa pode ter muitos bens (solvente) e faltar dinheiro agora (pouca liquidez), e o inverso também acontece.'),
    ('seed_financas_dificil_v1', 'O que significa análise de fluxo de caixa?',
     'Análise de fluxo de caixa é avaliar as entradas e saídas de dinheiro durante um período. Mostra se há dinheiro para pagar as contas e quando faltará ou sobrará. É mais ampla do que olhar só as vendas, os impostos ou o patrimônio.'),
    ('seed_financas_dificil_v1', 'Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?',
     'O lucro contábil registra as vendas quando acontecem, mas o dinheiro pode entrar só depois, se o cliente pagar a prazo. Enquanto isso, as contas vencem. Por isso lucro e fluxo de caixa são coisas diferentes: uma empresa pode ter lucro e faltar dinheiro. Inflação, diversificação e patrimônio líquido não explicam esse caso.'),
    ('seed_financas_dificil_v1', 'O que é capital de giro?',
     'Capital de giro é o dinheiro necessário para sustentar as operações correntes de uma empresa, como pagar fornecedores, salários e contas do dia a dia, enquanto aguarda receber das vendas. Se falta capital de giro, a empresa pode ter problemas mesmo vendendo bem. Não é só o patrimônio do dono, o caixa físico ou o dinheiro de investimentos de longo prazo.'),
    ('seed_financas_dificil_v1', 'O que é margem de lucro?',
     'Margem de lucro é a relação entre o lucro e a receita, em geral em percentual. Por exemplo, lucro de 20 sobre receita de 100 dá margem de 20%. Permite comparar a rentabilidade de negócios de tamanhos diferentes. Não é número de funcionários, total de ativos nem soma das dívidas.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 25, perguntas 16 a 25 do seed 047: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
