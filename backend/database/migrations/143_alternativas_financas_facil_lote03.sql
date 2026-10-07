-- Alternativas (BE-003, regularização) — Finanças fácil lote 3: perguntas 18 a 42 do seed 064.
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
    ('seed_financas_facil_v2', 'O que é planejamento financeiro?', 1, 'Evitar qualquer controle', 'Deixar as decisões de dinheiro para a última hora'),
    ('seed_financas_facil_v2', 'O que é planejamento financeiro?', 2, 'Gastar sem pensar', 'Comprar a prazo tudo o que o vendedor oferece'),
    ('seed_financas_facil_v2', 'O que é planejamento financeiro?', 3, 'Fazer apenas empréstimos', 'Depender de empréstimos para pagar as despesas'),
    ('seed_financas_facil_v2', 'O que é uma meta financeira?', 1, 'Um cartão bancário', 'Um cartão fornecido pelo banco ao cliente'),
    ('seed_financas_facil_v2', 'O que é uma meta financeira?', 2, 'Uma dívida obrigatória', 'Uma dívida assumida junto de uma instituição'),
    ('seed_financas_facil_v2', 'O que é uma meta financeira?', 3, 'Uma despesa', 'Um gasto que se repete todos os meses'),
    ('seed_financas_facil_v2', 'O que é emergência financeira?', 0, 'Investimento', 'Investimento feito para render no futuro'),
    ('seed_financas_facil_v2', 'O que é emergência financeira?', 1, 'Compra planejada', 'Compra planejada com bastante antecedência'),
    ('seed_financas_facil_v2', 'O que é emergência financeira?', 3, 'Salário mensal', 'Salário recebido no final do mês'),
    ('seed_financas_facil_v2', 'O que é reserva de emergência?', 0, 'Dívida bancária', 'Dinheiro emprestado pelo banco para emergências'),
    ('seed_financas_facil_v2', 'O que é reserva de emergência?', 1, 'Imposto', 'Imposto pago ao governo sobre o rendimento'),
    ('seed_financas_facil_v2', 'O que é reserva de emergência?', 2, 'Dinheiro para gastar rapidamente', 'Dinheiro separado para gastar nas férias'),
    ('seed_financas_facil_v2', 'O que é uma necessidade financeira?', 1, 'Um luxo obrigatório', 'Algo que se compra para acompanhar a moda do momento'),
    ('seed_financas_facil_v2', 'O que é uma necessidade financeira?', 2, 'Um gasto sem importância', 'Um gasto que pode ser adiado sem qualquer prejuízo'),
    ('seed_financas_facil_v2', 'O que é uma necessidade financeira?', 3, 'Uma compra por impulso', 'Uma compra feita porque estava em promoção na loja'),
    ('seed_financas_facil_v2', 'O que é um desejo financeiro?', 0, 'Uma dívida bancária', 'Algo essencial para a vida de uma pessoa'),
    ('seed_financas_facil_v2', 'O que é um desejo financeiro?', 1, 'Uma receita mensal', 'Um valor que se recebe todos os meses'),
    ('seed_financas_facil_v2', 'O que é um desejo financeiro?', 3, 'Uma obrigação de pagamento', 'Uma conta que tem de ser paga no prazo'),
    ('seed_financas_facil_v2', 'Qual é a diferença entre necessidade e desejo?', 0, 'Necessidade sempre custa mais', 'Necessidade é algo opcional; desejo é essencial'),
    ('seed_financas_facil_v2', 'Qual é a diferença entre necessidade e desejo?', 1, 'Desejo sempre é mais importante', 'Necessidade custa mais do que o desejo'),
    ('seed_financas_facil_v2', 'Qual é a diferença entre necessidade e desejo?', 2, 'Não existe diferença', 'Não existe diferença entre as duas coisas'),
    ('seed_financas_facil_v2', 'Como a inflação pode afetar o dinheiro?', 1, 'Elimina despesas', 'Elimina a necessidade de poupar'),
    ('seed_financas_facil_v2', 'Como a inflação pode afetar o dinheiro?', 2, 'Sempre aumenta o valor do dinheiro', 'Aumenta o valor do dinheiro guardado'),
    ('seed_financas_facil_v2', 'O que é poder de compra?', 0, 'Número de cartões bancários', 'Quantidade de dinheiro que uma pessoa guarda no banco'),
    ('seed_financas_facil_v2', 'O que é poder de compra?', 1, 'Valor de uma dívida', 'Valor total que uma pessoa deve pagar às instituições financeiras'),
    ('seed_financas_facil_v2', 'O que é poder de compra?', 2, 'Quantidade de dinheiro guardado', 'Número de produtos que uma loja tem para vender ao público'),
    ('seed_financas_facil_v2', 'O que acontece quando alguém atrasa um pagamento?', 0, 'Recebe sempre desconto', 'Recebe um desconto na próxima compra'),
    ('seed_financas_facil_v2', 'O que acontece quando alguém atrasa um pagamento?', 1, 'A dívida desaparece', 'A dívida é cancelada pelo banco'),
    ('seed_financas_facil_v2', 'O que acontece quando alguém atrasa um pagamento?', 3, 'Ganha investimento', 'Recebe um prémio por pagar tarde'),
    ('seed_financas_facil_v2', 'O que é uma despesa fixa?', 0, 'Investimento', 'Despesa que muda de valor todos os meses do ano'),
    ('seed_financas_facil_v2', 'O que é uma despesa fixa?', 1, 'Receita extra', 'Valor extra recebido além do salário normal do mês'),
    ('seed_financas_facil_v2', 'O que é uma despesa fixa?', 2, 'Despesa que nunca existe', 'Despesa feita uma só vez, sem se repetir no tempo'),
    ('seed_financas_facil_v2', 'O que é uma despesa variável?', 0, 'Salário fixo', 'Gasto que tem o mesmo valor todos os meses'),
    ('seed_financas_facil_v2', 'O que é uma despesa variável?', 1, 'Investimento garantido', 'Valor que se recebe de forma regular por trabalho'),
    ('seed_financas_facil_v2', 'O que é uma despesa variável?', 3, 'Conta bancária', 'Conta aberta num banco para guardar o dinheiro'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma despesa variável?', 1, 'Salário', 'Renda e prestação do carro'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma despesa variável?', 2, 'Mensalidade igual', 'Mensalidade da escola'),
    ('seed_financas_facil_v2', 'Qual exemplo representa uma despesa variável?', 3, 'Contrato fixo', 'Seguro de saúde anual'),
    ('seed_financas_facil_v2', 'O que é saldo bancário?', 0, 'Um imposto', 'Valor cobrado pelo banco por mês'),
    ('seed_financas_facil_v2', 'O que é saldo bancário?', 1, 'Uma dívida', 'Valor devido ao banco numa conta'),
    ('seed_financas_facil_v2', 'O que é extrato bancário?', 0, 'Cartão de crédito', 'Documento que mostra o limite de um cartão'),
    ('seed_financas_facil_v2', 'O que é extrato bancário?', 1, 'Documento escolar', 'Documento que prova a identidade do cliente'),
    ('seed_financas_facil_v2', 'O que é extrato bancário?', 3, 'Contrato de trabalho', 'Contrato assinado para abrir uma conta bancária'),
    ('seed_financas_facil_v2', 'O que é transferência bancária?', 0, 'Empréstimo automático', 'Pedido de empréstimo feito a um banco'),
    ('seed_financas_facil_v2', 'O que é transferência bancária?', 1, 'Criação de dinheiro', 'Troca de moeda estrangeira por moeda local'),
    ('seed_financas_facil_v2', 'O que é transferência bancária?', 3, 'Cancelamento de conta', 'Pagamento de uma compra feita em dinheiro vivo'),
    ('seed_financas_facil_v2', 'O que é pagamento digital?', 0, 'Pagamento apenas em dinheiro físico', 'Pagamento feito com notas e moedas na mão'),
    ('seed_financas_facil_v2', 'O que é pagamento digital?', 1, 'Uma dívida', 'Pagamento feito mais tarde, em prestações'),
    ('seed_financas_facil_v2', 'O que é pagamento digital?', 2, 'Troca de produtos', 'Troca de um produto por outro sem usar dinheiro'),
    ('seed_financas_facil_v2', 'Qual é um exemplo de pagamento digital?', 0, 'Troca de moedas antigas', 'Pagamento em notas no balcão da loja'),
    ('seed_financas_facil_v2', 'Qual é um exemplo de pagamento digital?', 2, 'Documento impresso', 'Cheque preenchido à mão e entregue'),
    ('seed_financas_facil_v2', 'Qual é um exemplo de pagamento digital?', 3, 'Pagamento sem valor', 'Compra paga com notas e moedas'),
    ('seed_financas_facil_v2', 'O que é carteira digital?', 0, 'Cartão de memória', 'Cartão do banco usado para levantar dinheiro'),
    ('seed_financas_facil_v2', 'O que é carteira digital?', 1, 'Banco tradicional somente', 'Agência do banco onde se faz o atendimento presencial'),
    ('seed_financas_facil_v2', 'O que é carteira digital?', 3, 'Carteira física de documentos', 'Carteira de couro para guardar notas e documentos'),
    ('seed_financas_facil_v2', 'O que é M-Pesa?', 0, 'Um cartão de computador', 'Um programa de crédito do governo para pequenos negócios'),
    ('seed_financas_facil_v2', 'O que é M-Pesa?', 2, 'Uma rede social', 'Uma rede social para anunciar e vender produtos online'),
    ('seed_financas_facil_v2', 'O que é M-Pesa?', 3, 'Um investimento', 'Um fundo de investimento para pequenos aforradores'),
    ('seed_financas_facil_v2', 'O que é uma transação financeira?', 0, 'Instalação de programas', 'Instalação de um sistema de segurança na loja'),
    ('seed_financas_facil_v2', 'O que é uma transação financeira?', 1, 'Apenas guardar documentos', 'Arquivo dos documentos fiscais de uma empresa'),
    ('seed_financas_facil_v2', 'O que é uma transação financeira?', 3, 'Criação de contas falsas', 'Registo dos funcionários contratados no mês'),
    ('seed_financas_facil_v2', 'O que é compra por impulso?', 0, 'Compra com orçamento definido', 'Compra feita depois de comparar os preços'),
    ('seed_financas_facil_v2', 'O que é compra por impulso?', 1, 'Pagamento de dívida', 'Compra feita com dinheiro guardado para isso'),
    ('seed_financas_facil_v2', 'O que é compra por impulso?', 3, 'Investimento seguro', 'Compra de um produto básico do dia a dia'),
    ('seed_financas_facil_v2', 'Por que comparar preços é importante?', 0, 'Para evitar planejamento', 'Para ter certeza de que o produto é de marca'),
    ('seed_financas_facil_v2', 'Por que comparar preços é importante?', 2, 'Para aumentar gastos', 'Para obrigar a loja a vender mais barato'),
    ('seed_financas_facil_v2', 'Por que comparar preços é importante?', 3, 'Para criar dívidas', 'Para gastar o dinheiro todo na mesma loja'),
    ('seed_financas_facil_v2', 'O que é promoção financeira?', 1, 'Um empréstimo obrigatório', 'Preço fixo cobrado todos os meses por um serviço'),
    ('seed_financas_facil_v2', 'O que é promoção financeira?', 2, 'Uma conta bancária', 'Taxa cobrada pelo banco em cada transferência feita'),
    ('seed_financas_facil_v2', 'O que é promoção financeira?', 3, 'Um investimento de risco', 'Aumento temporário do preço em épocas de festa')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças fácil lote 3: perguntas 18 a 42 do seed 064: % alternativa(s) errada(s) atualizada(s) (esperado: 70).', v_updated;
END $$;
