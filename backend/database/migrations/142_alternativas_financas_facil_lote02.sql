-- Alternativas (BE-003, regularização) — Finanças fácil lote 2: perguntas 26 a 33 do seed 045 e 1 a 17 do seed 064.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA e a explicação NÃO mudam;
-- só o texto das alternativas ERRADAS é ajustado para ter tamanho parecido ao da certa.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order, perguntas nem explicações. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_financas_facil_v1', 'Qual é uma vantagem de comparar preços antes de comprar?', 1, 'Garante que o produto seja gratuito', 'Dá direito a desconto em todas as lojas da cidade'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de comparar preços antes de comprar?', 2, 'Aumenta automaticamente o salário', 'Obriga a loja a baixar o preço do produto'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de comparar preços antes de comprar?', 3, 'Elimina todos os riscos financeiros', 'Dispensa a necessidade de fazer um orçamento'),
    ('seed_financas_facil_v1', 'O que é uma dívida?', 0, 'Um tipo de salário', 'Dinheiro que uma pessoa recebe pelo seu trabalho'),
    ('seed_financas_facil_v1', 'O que é uma dívida?', 1, 'Uma forma de investimento garantido', 'Valor aplicado para render juros ao longo do tempo'),
    ('seed_financas_facil_v1', 'O que é uma dívida?', 2, 'Dinheiro que nunca precisa ser devolvido', 'Dinheiro que fica guardado numa conta de poupança'),
    ('seed_financas_facil_v1', 'O que é renda?', 0, 'Apenas dinheiro encontrado na rua', 'Dinheiro emprestado por um banco para pagar em prestações'),
    ('seed_financas_facil_v1', 'O que é renda?', 2, 'Somente dinheiro guardado', 'Dinheiro guardado pela pessoa numa conta de poupança'),
    ('seed_financas_facil_v1', 'O que é renda?', 3, 'Apenas dinheiro emprestado', 'Bens que uma pessoa ou entidade possui em seu nome'),
    ('seed_financas_facil_v1', 'Qual atitude representa consumo consciente?', 0, 'Comprar sem verificar necessidade', 'Comprar o que está em destaque na vitrine da loja'),
    ('seed_financas_facil_v1', 'Qual atitude representa consumo consciente?', 2, 'Comprar tudo em promoção', 'Comprar tudo o que estiver em promoção na loja'),
    ('seed_financas_facil_v1', 'Qual atitude representa consumo consciente?', 3, 'Comprar sempre o produto mais caro', 'Escolher o produto mais caro por causa da marca'),
    ('seed_financas_facil_v1', 'Qual é uma boa razão para estabelecer metas financeiras?', 1, 'Aumentar dívidas', 'Aumentar as dívidas para conseguir mais crédito no banco'),
    ('seed_financas_facil_v1', 'Qual é uma boa razão para estabelecer metas financeiras?', 2, 'Evitar qualquer planejamento', 'Dispensar o planejamento e decidir só no momento'),
    ('seed_financas_facil_v1', 'Qual é uma boa razão para estabelecer metas financeiras?', 3, 'Gastar mais rapidamente', 'Gastar o dinheiro mais depressa do que se ganha'),
    ('seed_financas_facil_v1', 'Qual destas práticas pode melhorar a saúde financeira?', 1, 'Ignorar dívidas', 'Deixar as dívidas acumularem sem as pagar'),
    ('seed_financas_facil_v2', 'O que são finanças?', 1, 'Apenas guardar documentos', 'Estudo da forma como as empresas fazem publicidade'),
    ('seed_financas_facil_v2', 'O que são finanças?', 2, 'Criar aplicativos', 'Organização dos documentos e arquivos de uma empresa'),
    ('seed_financas_facil_v2', 'O que são finanças?', 3, 'Consertar computadores', 'Produção e venda de bens e serviços ao público'),
    ('seed_financas_facil_v2', 'O que é uma receita financeira?', 1, 'Uma despesa', 'Valor que uma empresa paga aos fornecedores'),
    ('seed_financas_facil_v2', 'O que é uma receita financeira?', 2, 'Valor que uma pessoa perde', 'Valor que uma pessoa deve pagar ao banco'),
    ('seed_financas_facil_v2', 'O que é uma receita financeira?', 3, 'Um empréstimo obrigatório', 'Valor pedido emprestado a um amigo ou ao banco'),
    ('seed_financas_facil_v2', 'O que é uma despesa?', 0, 'Dinheiro recebido', 'Dinheiro recebido pelo trabalho do mês'),
    ('seed_financas_facil_v2', 'O que é uma despesa?', 2, 'Lucro de uma empresa', 'Lucro obtido por uma empresa no fim do ano'),
    ('seed_financas_facil_v2', 'O que é uma despesa?', 3, 'Investimento sempre lucrativo', 'Dinheiro aplicado para render no futuro'),
    ('seed_financas_facil_v2', 'O que significa economizar dinheiro?', 0, 'Fazer dívidas', 'Fazer dívidas para comprar a prazo no banco'),
    ('seed_financas_facil_v2', 'O que significa economizar dinheiro?', 2, 'Evitar qualquer compra', 'Deixar de comprar o que é necessário'),
    ('seed_financas_facil_v2', 'O que significa economizar dinheiro?', 3, 'Gastar tudo imediatamente', 'Gastar o dinheiro assim que ele é recebido'),
    ('seed_financas_facil_v2', 'O que é orçamento pessoal?', 0, 'Programa de computador', 'Lista dos produtos que uma pessoa pretende comprar'),
    ('seed_financas_facil_v2', 'O que é orçamento pessoal?', 2, 'Lista de amigos', 'Registro dos bens que uma pessoa possui em casa'),
    ('seed_financas_facil_v2', 'O que é orçamento pessoal?', 3, 'Documento de identidade', 'Documento do banco com os juros de um empréstimo'),
    ('seed_financas_facil_v2', 'Por que criar um orçamento?', 1, 'Para aumentar despesas', 'Para gastar mais nas compras do dia a dia'),
    ('seed_financas_facil_v2', 'Por que criar um orçamento?', 2, 'Para perder dinheiro', 'Para pagar menos impostos ao governo'),
    ('seed_financas_facil_v2', 'Por que criar um orçamento?', 3, 'Para evitar qualquer rendimento', 'Para receber um salário mais alto no mês seguinte'),
    ('seed_financas_facil_v2', 'O que é poupança?', 0, 'Uma dívida', 'Dinheiro devido a um banco ou a uma loja'),
    ('seed_financas_facil_v2', 'O que é poupança?', 1, 'Um imposto', 'Imposto cobrado pelo governo sobre o salário'),
    ('seed_financas_facil_v2', 'O que é poupança?', 2, 'Dinheiro perdido', 'Dinheiro perdido por causa de uma má compra'),
    ('seed_financas_facil_v2', 'O que é um banco?', 1, 'Loja de computadores', 'Loja que vende e arrenda produtos eletrónicos'),
    ('seed_financas_facil_v2', 'O que é um banco?', 2, 'Empresa de jogos', 'Empresa que presta serviços de transporte público'),
    ('seed_financas_facil_v2', 'O que é um banco?', 3, 'Rede social', 'Organização que cobra impostos em nome do governo'),
    ('seed_financas_facil_v2', 'O que é uma conta bancária?', 0, 'Um documento escolar', 'Documento de identificação usado no banco'),
    ('seed_financas_facil_v2', 'O que é uma conta bancária?', 2, 'Um aplicativo de edição', 'Cartão usado para guardar fotografias e vídeos'),
    ('seed_financas_facil_v2', 'O que é uma conta bancária?', 3, 'Um cartão de memória', 'Contrato de empréstimo assinado com o banco'),
    ('seed_financas_facil_v2', 'O que é cartão de débito?', 0, 'Cartão de internet', 'Cartão usado para comprar crédito de internet'),
    ('seed_financas_facil_v2', 'O que é cartão de débito?', 2, 'Cartão que cria dinheiro', 'Cartão que permite pagar depois, com juros do banco'),
    ('seed_financas_facil_v2', 'O que é cartão de débito?', 3, 'Cartão sem ligação bancária', 'Cartão sem ligação a nenhuma conta bancária'),
    ('seed_financas_facil_v2', 'O que é cartão de crédito?', 0, 'Conta de poupança', 'Conta onde o dinheiro do cliente fica guardado e rende juros'),
    ('seed_financas_facil_v2', 'O que é cartão de crédito?', 1, 'Um investimento', 'Meio de pagamento que só permite gastar o saldo da conta'),
    ('seed_financas_facil_v2', 'O que é cartão de crédito?', 3, 'Dinheiro gratuito', 'Dinheiro oferecido pelo banco ao cliente sem precisar devolver'),
    ('seed_financas_facil_v2', 'O que é dívida?', 1, 'Um lucro', 'Um valor recebido pelo trabalho'),
    ('seed_financas_facil_v2', 'O que é dívida?', 2, 'Um investimento', 'Um valor guardado para o futuro'),
    ('seed_financas_facil_v2', 'O que é lucro?', 0, 'Toda despesa realizada', 'Todo o valor gasto por uma empresa para funcionar'),
    ('seed_financas_facil_v2', 'O que é lucro?', 1, 'Uma perda', 'Resultado negativo quando as despesas superam as receitas'),
    ('seed_financas_facil_v2', 'O que é lucro?', 2, 'Um empréstimo', 'Valor pedido emprestado ao banco para investir'),
    ('seed_financas_facil_v2', 'O que é prejuízo?', 0, 'Economia mensal', 'Dinheiro guardado todos os meses para emergências'),
    ('seed_financas_facil_v2', 'O que é prejuízo?', 1, 'Investimento seguro', 'Resultado positivo quando receitas superam despesas'),
    ('seed_financas_facil_v2', 'O que é prejuízo?', 2, 'Aumento de dinheiro', 'Aumento do dinheiro obtido com um investimento'),
    ('seed_financas_facil_v2', 'O que é investimento?', 0, 'Perder dinheiro propositalmente', 'Gastar dinheiro em coisas de que se gosta muito'),
    ('seed_financas_facil_v2', 'O que é investimento?', 1, 'Fazer compras diárias', 'Guardar dinheiro em casa sem o aplicar em nada'),
    ('seed_financas_facil_v2', 'O que é investimento?', 3, 'Gastar sem objetivo', 'Pagar as contas fixas que vencem todos os meses'),
    ('seed_financas_facil_v2', 'O que é salário?', 0, 'Um empréstimo', 'Dinheiro emprestado por um banco a um cliente'),
    ('seed_financas_facil_v2', 'O que é salário?', 1, 'Um imposto', 'Imposto descontado pelo Estado sobre o rendimento'),
    ('seed_financas_facil_v2', 'O que é salário?', 2, 'Uma dívida', 'Dívida que o trabalhador tem com o empregador'),
    ('seed_financas_facil_v2', 'O que é consumo consciente?', 1, 'Comprar tudo sem planejamento', 'Comprar tudo o que estiver em promoção, mesmo sem precisar'),
    ('seed_financas_facil_v2', 'O que é consumo consciente?', 2, 'Fazer dívidas sempre', 'Comprar a prazo quando o vendedor oferece crédito fácil'),
    ('seed_financas_facil_v2', 'O que é consumo consciente?', 3, 'Gastar todo dinheiro', 'Gastar todo o dinheiro do mês logo na primeira semana')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças fácil lote 2: perguntas 26 a 33 do seed 045 e 1 a 17 do seed 064: % alternativa(s) errada(s) atualizada(s) (esperado: 66).', v_updated;
END $$;
