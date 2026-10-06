-- Explicações pedagógicas (BE-004) — Finanças, nível Médio, lote 14 (10 perguntas): da 6.ª à 15.ª
-- do seed 046 (source 'seed_financas_medio_v1'). Mesmo critério das migrations 109 a 120: só preenche
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
    ('seed_financas_medio_v1', 'O que é crédito?',
     'Crédito é a possibilidade de usar dinheiro ou recursos agora, com a obrigação de pagar depois, nas condições combinadas. Não é dinheiro de graça, imposto nem salário.'),
    ('seed_financas_medio_v1', 'Por que o prazo de um empréstimo influencia seu custo?',
     'O prazo muda por quanto tempo se pagam juros e outros encargos. Em geral, quanto mais longo o prazo, mais juros se pagam no total, mesmo com prestações menores. O prazo não elimina juros nem transforma dívida em renda.'),
    ('seed_financas_medio_v1', 'O que significa capacidade de pagamento?',
     'Capacidade de pagamento é poder cumprir as obrigações financeiras com o dinheiro que se tem. Antes de pedir um empréstimo, convém ver se as prestações cabem no orçamento sem faltar para o essencial.'),
    ('seed_financas_medio_v1', 'O que é orçamento deficitário?',
     'Orçamento deficitário é aquele em que as despesas planejadas superam as receitas, ou seja, falta dinheiro. O contrário, receitas maiores que despesas, é um orçamento com sobra.'),
    ('seed_financas_medio_v1', 'Por que registrar pequenos gastos pode ser importante?',
     'Vários gastos pequenos, somados, podem pesar muito no orçamento do mês. Registrá-los mostra para onde o dinheiro vai e ajuda a cortar excessos. Anotar não poupa sozinho, mas dá o controle para poupar.'),
    ('seed_financas_medio_v1', 'O que significa risco financeiro?',
     'Risco financeiro é a possibilidade de perder dinheiro ou de o resultado ser diferente do esperado. Quase toda aplicação tem algum risco; garantia total de lucro ou ausência de incerteza não existem.'),
    ('seed_financas_medio_v1', 'Por que uma pessoa deve desconfiar de investimentos que prometem retornos muito altos e garantidos?',
     'Retorno muito alto e garantido é um sinal de alerta: costuma indicar risco elevado ou fraude. Em geral, quanto maior o retorno prometido, maior o risco. Vale pesquisar antes e desconfiar de promessas fáceis.'),
    ('seed_financas_medio_v1', 'O que é custo total de uma compra financiada?',
     'O custo total é o valor principal somado aos juros e outros encargos. Por isso quem compra a prazo costuma pagar mais do que o preço anunciado. Compare sempre o total, e não só a prestação.'),
    ('seed_financas_medio_v1', 'Qual fator deve ser considerado ao comparar dois empréstimos?',
     'Ao comparar empréstimos, olhe taxas, encargos, prazo e custo total, e não só a prestação. Nome da instituição, cor do cartão ou publicidade não dizem quanto o empréstimo realmente custa.'),
    ('seed_financas_medio_v1', 'O que acontece quando uma pessoa reduz despesas desnecessárias sem reduzir necessidades essenciais?',
     'Cortar o que é desnecessário, mantendo o essencial, libera dinheiro e pode aumentar a capacidade de poupar. Não reduz o salário nem elimina a renda, e não aumenta as dívidas.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 14: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
