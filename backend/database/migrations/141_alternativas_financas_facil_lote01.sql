-- Alternativas (BE-003, regularização) — Finanças fácil lote 1: perguntas 1 a 25 do seed 045 (source seed_financas_facil_v1).
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
    ('seed_financas_facil_v1', 'O que é receita?', 0, 'Um imposto', 'Dinheiro que se deve'),
    ('seed_financas_facil_v1', 'O que é receita?', 2, 'Uma dívida', 'Dinheiro que se poupa'),
    ('seed_financas_facil_v1', 'O que é despesa?', 0, 'Dinheiro recebido', 'Dinheiro recebido pelo trabalho'),
    ('seed_financas_facil_v1', 'O que é despesa?', 1, 'Lucro', 'Dinheiro guardado para o futuro'),
    ('seed_financas_facil_v1', 'O que é despesa?', 2, 'Dinheiro investido obrigatoriamente', 'Dinheiro que sobra no fim do mês'),
    ('seed_financas_facil_v1', 'O que é consumo?', 0, 'Apenas pedir empréstimo', 'Obtenção de crédito num banco'),
    ('seed_financas_facil_v1', 'O que é consumo?', 2, 'Apenas guardar dinheiro', 'Reserva de dinheiro para o futuro'),
    ('seed_financas_facil_v1', 'O que é consumo?', 3, 'Apenas investir', 'Aplicação de dinheiro em ativos'),
    ('seed_financas_facil_v1', 'Para que serve uma conta bancária?', 1, 'Somente pagar impostos', 'Pagar impostos e taxas diretamente às entidades do Estado'),
    ('seed_financas_facil_v1', 'Para que serve uma conta bancária?', 2, 'Apenas receber mensagens', 'Emitir documentos de identificação pessoal e comprovativos'),
    ('seed_financas_facil_v1', 'Para que serve uma conta bancária?', 3, 'Apenas comprar roupas', 'Comprar produtos em lojas com descontos exclusivos'),
    ('seed_financas_facil_v1', 'O que é um recibo?', 0, 'Um investimento', 'Documento que cria uma dívida entre duas pessoas'),
    ('seed_financas_facil_v1', 'O que é um recibo?', 1, 'Uma moeda', 'Documento que fixa o preço de venda de um produto'),
    ('seed_financas_facil_v1', 'O que é um recibo?', 3, 'Uma dívida', 'Documento que autoriza um empréstimo bancário'),
    ('seed_financas_facil_v1', 'O que significa economizar?', 0, 'Pedir dinheiro emprestado', 'Comprar mais produtos para aproveitar descontos'),
    ('seed_financas_facil_v1', 'O que significa economizar?', 2, 'Gastar tudo imediatamente', 'Gastar o salário todo logo no primeiro dia'),
    ('seed_financas_facil_v1', 'O que significa economizar?', 3, 'Aumentar dívidas', 'Pedir crédito para cobrir as despesas do mês'),
    ('seed_financas_facil_v1', 'Qual é a melhor atitude antes de fazer uma compra não planejada?', 0, 'Ignorar o preço', 'Comprar imediatamente para não perder a oferta que está a decorrer'),
    ('seed_financas_facil_v1', 'Qual é a melhor atitude antes de fazer uma compra não planejada?', 1, 'Comprar imediatamente', 'Pedir dinheiro emprestado para comprar o mais depressa possível'),
    ('seed_financas_facil_v1', 'Qual é a melhor atitude antes de fazer uma compra não planejada?', 2, 'Pedir dinheiro emprestado sem analisar', 'Comprar a prazo sem olhar para o valor das parcelas mensais'),
    ('seed_financas_facil_v1', 'O que é preço?', 0, 'Quantidade de dinheiro guardada', 'Quantidade de dinheiro guardada num banco'),
    ('seed_financas_facil_v1', 'O que é preço?', 1, 'Valor de uma dívida', 'Valor devido a quem emprestou dinheiro'),
    ('seed_financas_facil_v1', 'O que é preço?', 2, 'Valor sempre recebido pelo trabalhador', 'Valor pago ao trabalhador no fim do mês'),
    ('seed_financas_facil_v1', 'O que significa gastar por impulso?', 1, 'Comparar preços cuidadosamente', 'Comparar preços em várias lojas antes de decidir'),
    ('seed_financas_facil_v1', 'O que significa gastar por impulso?', 2, 'Planejar uma compra com antecedência', 'Planejar a compra com antecedência e sem pressa'),
    ('seed_financas_facil_v1', 'O que significa gastar por impulso?', 3, 'Poupar antes de comprar', 'Poupar durante vários meses antes de comprar'),
    ('seed_financas_facil_v1', 'Qual destes pode ser considerado um gasto com transporte?', 1, 'Alimento', 'Compra de alimentos'),
    ('seed_financas_facil_v1', 'Qual destes pode ser considerado um gasto com transporte?', 2, 'Caderno', 'Compra de material escolar'),
    ('seed_financas_facil_v1', 'Qual destes pode ser considerado um gasto com transporte?', 3, 'Livro', 'Compra de livros'),
    ('seed_financas_facil_v1', 'O que é dinheiro?', 0, 'Apenas papel', 'Papel impresso e distribuído pelos bancos privados'),
    ('seed_financas_facil_v1', 'O que é dinheiro?', 2, 'Apenas crédito bancário', 'Crédito concedido pelos bancos aos clientes'),
    ('seed_financas_facil_v1', 'O que é dinheiro?', 3, 'Apenas moeda metálica', 'Moedas metálicas guardadas em casa pelas famílias'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de guardar parte da renda?', 1, 'Aumentar automaticamente as despesas', 'Pagar menos impostos no mês seguinte ao da poupança'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de guardar parte da renda?', 2, 'Garantir riqueza imediata', 'Ficar rico logo no mês seguinte ao primeiro depósito'),
    ('seed_financas_facil_v1', 'Qual é uma vantagem de guardar parte da renda?', 3, 'Eliminar todos os impostos', 'Poder gastar mais sem se preocupar com o orçamento'),
    ('seed_financas_facil_v1', 'O que é uma compra planejada?', 0, 'Compra feita sem verificar o preço', 'Compra feita no momento por causa de uma oferta tentadora'),
    ('seed_financas_facil_v1', 'O que é uma compra planejada?', 1, 'Compra feita sempre com empréstimo', 'Compra paga com empréstimo pedido a um banco ou a um amigo'),
    ('seed_financas_facil_v1', 'O que é uma compra planejada?', 3, 'Compra realizada por pressão', 'Compra realizada por pressão de vendedores ou de amigos'),
    ('seed_financas_facil_v1', 'O que significa preço promocional?', 1, 'Preço de um empréstimo', 'Preço pago a prazo, em prestações, ao longo de vários meses'),
    ('seed_financas_facil_v1', 'O que significa preço promocional?', 2, 'Preço obrigatoriamente mais alto', 'Preço mais alto cobrado aos clientes novos de uma loja'),
    ('seed_financas_facil_v1', 'O que significa preço promocional?', 3, 'Valor de um salário', 'Preço fixado pelo governo e igual em todas as lojas'),
    ('seed_financas_facil_v1', 'Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 0, 'Comprar tudo imediatamente', 'Comprar na primeira loja que aparecer pelo caminho'),
    ('seed_financas_facil_v1', 'Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 1, 'Nunca verificar o orçamento', 'Comprar o que está na moda entre os amigos'),
    ('seed_financas_facil_v1', 'Qual destas atitudes pode ajudar a evitar desperdício de dinheiro?', 2, 'Ignorar promoções e preços', 'Escolher o produto pelo anúncio mais visto'),
    ('seed_financas_facil_v1', 'O que é um objetivo financeiro?', 0, 'Uma compra aleatória', 'Compra feita sem planejamento, por vontade do momento e sem prazo'),
    ('seed_financas_facil_v1', 'O que é um objetivo financeiro?', 2, 'Uma dívida obrigatória', 'Dívida assumida com um banco para pagar durante vários anos'),
    ('seed_financas_facil_v1', 'O que é um objetivo financeiro?', 3, 'Um imposto', 'Imposto cobrado pelo Estado sobre o rendimento de cada ano'),
    ('seed_financas_facil_v1', 'Qual é um exemplo de objetivo financeiro?', 1, 'Gastar todo o salário', 'Pagar o aluguel que vence no fim deste mês'),
    ('seed_financas_facil_v1', 'Qual é um exemplo de objetivo financeiro?', 2, 'Aumentar uma dívida', 'Comprar um telemóvel novo por impulso hoje'),
    ('seed_financas_facil_v1', 'Qual é um exemplo de objetivo financeiro?', 3, 'Ignorar as despesas', 'Receber o salário no último dia do mês'),
    ('seed_financas_facil_v1', 'O que significa poupar dinheiro?', 0, 'Comprar apenas produtos caros', 'Comprar produtos em promoção todos os meses'),
    ('seed_financas_facil_v1', 'O que significa poupar dinheiro?', 1, 'Pedir dinheiro emprestado', 'Trocar dinheiro por outra moeda estrangeira'),
    ('seed_financas_facil_v1', 'O que significa poupar dinheiro?', 3, 'Gastar todo o dinheiro disponível', 'Gastar o dinheiro disponível com cuidado'),
    ('seed_financas_facil_v1', 'O que caracteriza uma despesa variável?', 0, 'É sempre uma dívida', 'É sempre uma dívida contraída junto do banco'),
    ('seed_financas_facil_v1', 'O que caracteriza uma despesa variável?', 1, 'Nunca precisa ser paga', 'Só precisa de ser paga uma vez em toda a vida'),
    ('seed_financas_facil_v1', 'Para que serve uma reserva de emergência?', 3, 'Para evitar trabalhar', 'Para deixar de pagar as contas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Finanças fácil lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 56).', v_updated;
END $$;
