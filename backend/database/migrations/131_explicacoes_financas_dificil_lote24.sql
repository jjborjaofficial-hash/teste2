-- Explicações pedagógicas (BE-004) — Finanças difícil lote 24, perguntas 6 a 15 do seed 047 (10 perguntas). Mesmo critério das migrations 109 a
-- 130: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_dificil_v1', 'O que é custo de oportunidade de manter dinheiro parado?',
     'Custo de oportunidade é o benefício que se deixa de ter por não escolher a melhor alternativa. Com dinheiro parado, é o rendimento que ele poderia ter dado se estivesse aplicado, ainda mais com a inflação a corroer o seu valor. Não é multa, taxa obrigatória nem inflação, embora a inflação aumente esse custo.'),
    ('seed_financas_dificil_v1', 'O que é alocação de ativos?',
     'Alocação de ativos é decidir como dividir o dinheiro entre classes de ativos, como renda fixa, ações e imóveis. Essa divisão define, em boa parte, o risco e o retorno esperados da carteira, e depende do perfil e dos objetivos do investidor. Não é pagar dívida nem registrar despesas.'),
    ('seed_financas_dificil_v1', 'Por que correlação entre ativos pode ser relevante na diversificação?',
     'Correlação mostra se dois ativos tendem a se mover juntos. Se sobem e descem ao mesmo tempo, diversificar entre eles protege pouco. Ativos com comportamentos diferentes reduzem a concentração do risco, porque a perda de um pode ser compensada por outro. Mesmo assim, a diversificação não elimina todas as perdas nem garante rendimento.'),
    ('seed_financas_dificil_v1', 'O que significa volatilidade?',
     'Volatilidade mede a intensidade e a frequência das variações do preço ou do retorno de um ativo. Quanto maior, mais o valor oscila e mais incerto é o resultado no curto prazo. Por isso costuma ser usada como medida de risco. Não é imposto, valor fixo nem garantia de lucro.'),
    ('seed_financas_dificil_v1', 'Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?',
     'Ter ativos de categorias diferentes distribui o risco entre várias fontes de exposição, de modo que um problema numa delas não derrube toda a carteira. Isso não garante que nenhum ativo perca valor, não dispensa acompanhamento e não assegura rendimento fixo.'),
    ('seed_financas_dificil_v1', 'O que é liquidez de um investimento?',
     'Liquidez é a facilidade e a rapidez de transformar o investimento em dinheiro sem perda significativa de valor. Depende do mercado: um ativo muito negociado é líquido, e um raro ou de resgate lento não é. Por isso a liquidez pesa na escolha de onde guardar a reserva de emergência.'),
    ('seed_financas_dificil_v1', 'Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?',
     'Em geral, quem aceita prender o dinheiro por mais tempo ou abrir mão de resgate fácil pode receber um retorno maior, como compensação. Já o investimento de resgate imediato costuma render menos. Assim, é preciso equilibrar quanto se precisa do dinheiro e quanto se quer render. Não é verdade que investimentos líquidos nunca rendem.'),
    ('seed_financas_dificil_v1', 'O que é risco de crédito?',
     'Risco de crédito é a possibilidade de quem deve (a contraparte) não cumprir suas obrigações financeiras, ou seja, de não pagar o combinado. Afeta quem empresta dinheiro ou compra títulos de dívida e é uma razão pela qual quem tem mais risco paga juros maiores. Não é inflação nem aumento de salário.'),
    ('seed_financas_dificil_v1', 'O que é risco de mercado?',
     'Risco de mercado é a possibilidade de perdas por mudanças nos preços ou nas condições do mercado, como juros, câmbio ou cotações. Atinge quase todos os investimentos e não pode ser evitado por completo, só reduzido, por exemplo, com diversificação. Não é risco de atraso salarial, de roubo ou de esquecer uma senha.'),
    ('seed_financas_dificil_v1', 'O que é risco de liquidez?',
     'Risco de liquidez é não conseguir vender ou resgatar um ativo rapidamente sem causar impacto relevante no preço. Quem precisa do dinheiro com urgência pode ter de aceitar um preço menor. Não é risco de receber salário, de pagar uma conta nem apenas de inflação.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 24, perguntas 6 a 15 do seed 047: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
