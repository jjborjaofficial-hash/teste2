-- Explicações pedagógicas (BE-004) — Finanças difícil lote 28, perguntas 15 a 24 do seed 073 (10 perguntas). Mesmo critério das migrations 109 a
-- 134: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v2', 'O que é hedge financeiro?',
     'Hedge é uma estratégia para proteger investimentos contra variações desfavoráveis de preço, como um exportador que fixa a taxa de câmbio para não perder se a moeda cair. Reduz o risco, mas não elimina todos os riscos e tem um custo. Não é uma forma de aumentar despesas nem um imposto.'),
    ('seed_financas_dificil_v2', 'O que é gestão de risco financeiro?',
     'Gestão de risco é o processo de identificar, analisar e controlar os riscos financeiros. Parte do princípio de que não dá para eliminar o risco, mas dá para conhecê-lo e mantê-lo num nível aceitável. Evitar planejamento, investir ao acaso ou ignorar riscos é o contrário.'),
    ('seed_financas_dificil_v2', 'O que é governança corporativa?',
     'Governança corporativa é o sistema de regras e práticas para administrar empresas com transparência e responsabilidade, protegendo sócios, investidores e outros interessados. Empresas bem governadas costumam inspirar mais confiança. Não é método de venda, só controle de funcionários nem sistema bancário.'),
    ('seed_financas_dificil_v2', 'O que é compliance financeiro?',
     'Compliance é o conjunto de práticas que garante o cumprimento das normas e leis financeiras, evitando multas, sanções e prejuízo de reputação. Não é redução de funcionários, aumento automático de lucro nem criação de dívidas.'),
    ('seed_financas_dificil_v2', 'O que é lavagem de dinheiro?',
     'Lavagem de dinheiro é o processo ilegal de ocultar a origem de recursos obtidos de forma criminosa, para que pareçam legítimos. É um crime, e o compliance financeiro existe, em parte, para detectá-lo e preveni-lo. Não é investimento legítimo, economia pessoal nem pagamento de impostos.'),
    ('seed_financas_dificil_v2', 'O que é planejamento sucessório?',
     'Planejamento sucessório é organizar a transferência do patrimônio para as futuras gerações, definindo antecipadamente quem recebe o quê. Evita conflitos e reduz custos e atrasos depois. Não é criar dívidas, planejar compras nem controlar salário.'),
    ('seed_financas_dificil_v2', 'O que é taxa interna de retorno (TIR)?',
     'A TIR é a taxa que mostra a rentabilidade esperada de um investimento, considerando o dinheiro que entra e sai ao longo do tempo. Compara-se com o custo de capital: se a TIR for maior, o projeto tende a compensar. Não é custo operacional, preço de mercado nem valor de uma dívida.'),
    ('seed_financas_dificil_v2', 'O que é valor presente líquido (VPL)?',
     'O VPL traz para o valor de hoje os fluxos de caixa futuros de um investimento e subtrai o que foi investido, considerando o valor do dinheiro no tempo. Se for positivo, o projeto tende a ser viável. Não é uma soma simples de despesas, salário nem número de clientes.'),
    ('seed_financas_dificil_v2', 'O que significa valor do dinheiro no tempo?',
     'Uma quantia recebida hoje pode ser aplicada e render, por isso tem maior capacidade de gerar retorno do que a mesma quantia no futuro. É a base dos juros e de métodos como o VPL. O dinheiro muda de valor, o futuro não vale sempre mais e os juros existem.'),
    ('seed_financas_dificil_v2', 'O que é custo de capital?',
     'Custo de capital é o que uma empresa paga para obter recursos financeiros, seja em juros de dívidas, seja no retorno esperado pelos sócios. Um projeto só compensa se render mais do que esse custo. Não é imposto de consumo, salário dos trabalhadores nem valor do produto final.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 28, perguntas 15 a 24 do seed 073: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
