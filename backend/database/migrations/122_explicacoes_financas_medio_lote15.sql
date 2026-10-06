-- Explicações pedagógicas (BE-004) — Finanças médio lote 15, perguntas 16 a 25 do seed 046 (10 perguntas). Mesmo critério das migrations 109 a
-- 121: só preenche questions.explanation das perguntas que ainda não têm explicação (idempotente,
-- nunca sobrescreve), não altera perguntas nem alternativas e nunca falha se uma pergunta já não existir.
-- O runner já envolve o ficheiro numa transação, por isso não há BEGIN/COMMIT aqui.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_financas_medio_v1', 'O que é uma meta financeira de curto prazo?',
     'Meta de curto prazo é um objetivo que se pode alcançar num período relativamente próximo, como juntar dinheiro para um celular. Não é despesa inesperada nem dívida, e não precisa demorar décadas.'),
    ('seed_financas_medio_v1', 'Qual é uma vantagem de separar dinheiro destinado a diferentes objetivos?',
     'Separar o dinheiro por objetivo facilita ver quanto já foi guardado para cada um. Isso ajuda a manter o foco. Não garante lucro, não elimina riscos e não impede gastos.'),
    ('seed_financas_medio_v1', 'O que é renda ativa?',
     'Renda ativa é a que se recebe em troca de trabalho ou de prestação de serviços, como o salário. Juros, dividendos e dinheiro achado não são renda ativa.'),
    ('seed_financas_medio_v1', 'O que é renda passiva?',
     'Renda passiva é a que vem de bens ou atividades que não pedem trocar tempo por dinheiro a cada recebimento, como o aluguel de um imóvel. Salário obrigatório, despesa ou dinheiro emprestado não são renda passiva.'),
    ('seed_financas_medio_v1', 'Por que depender de uma única fonte de renda pode representar uma vulnerabilidade financeira?',
     'Com uma só fonte de renda, perdê-la afeta muito o dinheiro disponível, como no desemprego. Ter mais de uma fonte dá mais segurança. Depender de uma só não garante prejuízo nem elimina despesas.'),
    ('seed_financas_medio_v1', 'O que é margem de segurança financeira?',
     'Margem de segurança é a folga entre o dinheiro disponível e as obrigações ou gastos necessários. Quanto maior a folga, mais fácil enfrentar imprevistos. Não é imposto, multa nem empréstimo.'),
    ('seed_financas_medio_v1', 'Se uma pessoa recebe 30.000 MZN e seus gastos são 24.000 MZN, qual percentual da renda foi gasto?',
     '24.000 ÷ 30.000 = 0,8, ou seja, 80% da renda foi gasto. Para achar o percentual, divide-se o gasto pela renda e multiplica-se por 100.'),
    ('seed_financas_medio_v1', 'Uma pessoa tinha 5.000 MZN e gastou 1.250 MZN. Quanto restou?',
     '5.000 − 1.250 = 3.750 MZN. Para conferir, some o que restou ao que foi gasto: 3.750 + 1.250 = 5.000.'),
    ('seed_financas_medio_v1', 'O que é patrimônio líquido?',
     'Patrimônio líquido é a diferença entre o que a pessoa possui (ativos) e o que deve (obrigações). Não é a soma das despesas, nem só o salário ou o dinheiro em espécie.'),
    ('seed_financas_medio_v1', 'Por que diversificar pode reduzir a concentração de risco?',
     'Diversificar é espalhar o dinheiro em vários ativos ou categorias, para não depender do desempenho de um só. Reduz a concentração de risco, mas não elimina todos os riscos nem garante lucro.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças médio lote 15, perguntas 16 a 25 do seed 046: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
