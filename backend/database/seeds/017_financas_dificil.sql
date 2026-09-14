-- Migration/seed: conteúdo Finanças, nível Difícil (31 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 31 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (56 — distinta das seeds 42 a
-- 55 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Finanças" (slug: financas) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'financas';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "financas" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_financas_dificil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_financas_dificil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_fin_dificil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_financas_dificil_v1'
    FROM (VALUES
      ('O que representa o valor do dinheiro no tempo?'),
      ('O que é juros compostos?'),
      ('Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?'),
      ('O que é retorno real de um investimento?'),
      ('Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:'),
      ('O que é custo de oportunidade de manter dinheiro parado?'),
      ('O que é alocação de ativos?'),
      ('Por que correlação entre ativos pode ser relevante na diversificação?'),
      ('O que significa volatilidade?'),
      ('Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?'),
      ('O que é liquidez de um investimento?'),
      ('Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?'),
      ('O que é risco de crédito?'),
      ('O que é risco de mercado?'),
      ('O que é risco de liquidez?'),
      ('Por que a taxa de inflação é importante para decisões financeiras de longo prazo?'),
      ('O que é taxa nominal?'),
      ('Qual é a relação entre risco e retorno em investimentos?'),
      ('O que significa liquidação de uma dívida?'),
      ('O que é solvência?'),
      ('Qual é a diferença entre liquidez e solvência?'),
      ('O que significa análise de fluxo de caixa?'),
      ('Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?'),
      ('O que é capital de giro?'),
      ('O que é margem de lucro?'),
      ('Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?'),
      ('O que é ponto de equilíbrio financeiro de uma atividade?'),
      ('Por que separar despesas pessoais das despesas de um negócio é importante?'),
      ('O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?'),
      ('Qual é uma característica de uma decisão financeira bem fundamentada?'),
      ('O que é custo de oportunidade?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_fin_dificil q
    JOIN (VALUES
      ('O que representa o valor do dinheiro no tempo?', 'Dinheiro futuro sempre vale mais', FALSE, 0),
      ('O que representa o valor do dinheiro no tempo?', 'Uma quantia disponível hoje pode ter valor econômico diferente da mesma quantia recebida no futuro', TRUE, 1),
      ('O que representa o valor do dinheiro no tempo?', 'Dinheiro presente nunca pode ser investido', FALSE, 2),
      ('O que representa o valor do dinheiro no tempo?', 'Todo dinheiro mantém exatamente o mesmo valor em qualquer momento', FALSE, 3),
      ('O que é juros compostos?', 'Juros calculados também sobre juros acumulados anteriormente', TRUE, 0),
      ('O que é juros compostos?', 'Um desconto comercial', FALSE, 1),
      ('O que é juros compostos?', 'Juros calculados apenas uma vez', FALSE, 2),
      ('O que é juros compostos?', 'Um imposto sobre compras', FALSE, 3),
      ('Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 'O capital necessariamente diminui', FALSE, 0),
      ('Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 'Os rendimentos desaparecem', FALSE, 1),
      ('Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 'Os rendimentos podem passar a gerar novos rendimentos', TRUE, 2),
      ('Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?', 'O investimento deixa de existir', FALSE, 3),
      ('O que é retorno real de um investimento?', 'Apenas os impostos pagos', FALSE, 0),
      ('O que é retorno real de um investimento?', 'Retorno considerado após levar em conta o efeito da inflação', TRUE, 1),
      ('O que é retorno real de um investimento?', 'Apenas o valor nominal recebido', FALSE, 2),
      ('O que é retorno real de um investimento?', 'O valor inicialmente investido', FALSE, 3),
      ('Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 'O retorno nominal e o retorno real são exatamente iguais', FALSE, 0),
      ('Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 'A inflação não interfere', FALSE, 1),
      ('Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 'O poder de compra do rendimento deve ser analisado considerando a inflação', TRUE, 2),
      ('Se um investimento rende 12% ao ano e a inflação no mesmo período é 8%, podemos concluir que:', 'O investimento perdeu necessariamente 12%', FALSE, 3),
      ('O que é custo de oportunidade de manter dinheiro parado?', 'É sempre uma multa', FALSE, 0),
      ('O que é custo de oportunidade de manter dinheiro parado?', 'É o possível benefício que poderia ser obtido por uma alternativa de uso ou investimento não escolhida', TRUE, 1),
      ('O que é custo de oportunidade de manter dinheiro parado?', 'É o mesmo que inflação', FALSE, 2),
      ('O que é custo de oportunidade de manter dinheiro parado?', 'É uma taxa bancária obrigatória', FALSE, 3),
      ('O que é alocação de ativos?', 'Distribuição dos recursos entre diferentes classes de ativos', TRUE, 0),
      ('O que é alocação de ativos?', 'Pagamento de uma dívida', FALSE, 1),
      ('O que é alocação de ativos?', 'Registro de despesas', FALSE, 2),
      ('O que é alocação de ativos?', 'Retirada de todo o dinheiro do banco', FALSE, 3),
      ('Por que correlação entre ativos pode ser relevante na diversificação?', 'Porque garante rendimento positivo', FALSE, 0),
      ('Por que correlação entre ativos pode ser relevante na diversificação?', 'Porque impede qualquer oscilação', FALSE, 1),
      ('Por que correlação entre ativos pode ser relevante na diversificação?', 'Porque ativos com comportamentos diferentes podem reduzir a concentração do risco da carteira', TRUE, 2),
      ('Por que correlação entre ativos pode ser relevante na diversificação?', 'Porque elimina completamente perdas', FALSE, 3),
      ('O que significa volatilidade?', 'Taxa de imposto', FALSE, 0),
      ('O que significa volatilidade?', 'Valor fixo de um ativo', FALSE, 1),
      ('O que significa volatilidade?', 'Intensidade e frequência das variações de um preço ou retorno ao longo do tempo', TRUE, 2),
      ('O que significa volatilidade?', 'Garantia de lucro', FALSE, 3),
      ('Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 'Distribuir o risco entre diferentes fontes de exposição', TRUE, 0),
      ('Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 'Garantir que nenhum ativo perderá valor', FALSE, 1),
      ('Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 'Eliminar a necessidade de acompanhamento', FALSE, 2),
      ('Uma carteira possui ativos de diferentes categorias. Qual é a principal finalidade dessa estratégia?', 'Garantir rendimento fixo', FALSE, 3),
      ('O que é liquidez de um investimento?', 'Taxa de juros', FALSE, 0),
      ('O que é liquidez de um investimento?', 'Facilidade e rapidez com que o investimento pode ser convertido em dinheiro sem perda significativa de valor, dependendo do mercado', TRUE, 1),
      ('O que é liquidez de um investimento?', 'Valor do investimento inicial', FALSE, 2),
      ('O que é liquidez de um investimento?', 'Garantia de lucro', FALSE, 3),
      ('Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 'Todo investimento possui liquidez máxima', FALSE, 0),
      ('Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 'Investimentos líquidos nunca rendem', FALSE, 1),
      ('Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 'Um investimento mais rentável pode exigir prazo maior ou apresentar menor facilidade de resgate', TRUE, 2),
      ('Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?', 'Rentabilidade e liquidez são sempre iguais', FALSE, 3),
      ('O que é risco de crédito?', 'Aumento da inflação', FALSE, 0),
      ('O que é risco de crédito?', 'Possibilidade de uma contraparte não cumprir suas obrigações financeiras', TRUE, 1),
      ('O que é risco de crédito?', 'Aumento de salário', FALSE, 2),
      ('O que é risco de crédito?', 'Possibilidade de um produto ficar barato', FALSE, 3),
      ('O que é risco de mercado?', 'Apenas risco de atraso salarial', FALSE, 0),
      ('O que é risco de mercado?', 'Apenas risco de roubo físico', FALSE, 1),
      ('O que é risco de mercado?', 'Risco de esquecer uma senha', FALSE, 2),
      ('O que é risco de mercado?', 'Possibilidade de perdas devido a mudanças nos preços ou condições do mercado', TRUE, 3),
      ('O que é risco de liquidez?', 'Risco de receber salário', FALSE, 0),
      ('O que é risco de liquidez?', 'Risco de pagar uma conta', FALSE, 1),
      ('O que é risco de liquidez?', 'Risco de inflação exclusivamente', FALSE, 2),
      ('O que é risco de liquidez?', 'Risco de não conseguir vender ou resgatar um ativo rapidamente sem impacto relevante no preço', TRUE, 3),
      ('Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 'Porque pode reduzir o poder de compra das quantias ao longo do tempo', TRUE, 0),
      ('Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 'Porque sempre aumenta o poder de compra', FALSE, 1),
      ('Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 'Porque não afeta preços', FALSE, 2),
      ('Por que a taxa de inflação é importante para decisões financeiras de longo prazo?', 'Porque elimina os juros', FALSE, 3),
      ('O que é taxa nominal?', 'Taxa que sempre representa ganho real', FALSE, 0),
      ('O que é taxa nominal?', 'Taxa que não pode mudar', FALSE, 1),
      ('O que é taxa nominal?', 'Taxa expressa sem necessariamente descontar o efeito da inflação', TRUE, 2),
      ('O que é taxa nominal?', 'Taxa exclusivamente de impostos', FALSE, 3),
      ('Qual é a relação entre risco e retorno em investimentos?', 'Risco e retorno não possuem qualquer relação', FALSE, 0),
      ('Qual é a relação entre risco e retorno em investimentos?', 'Menor risco sempre significa maior retorno', FALSE, 1),
      ('Qual é a relação entre risco e retorno em investimentos?', 'Em geral, maiores retornos potenciais costumam estar associados a maiores riscos', TRUE, 2),
      ('Qual é a relação entre risco e retorno em investimentos?', 'Maior risco sempre significa maior lucro', FALSE, 3),
      ('O que significa liquidação de uma dívida?', 'Criação de uma nova dívida', FALSE, 0),
      ('O que significa liquidação de uma dívida?', 'Aumento do prazo', FALSE, 1),
      ('O que significa liquidação de uma dívida?', 'Suspensão do pagamento', FALSE, 2),
      ('O que significa liquidação de uma dívida?', 'Pagamento total da obrigação', TRUE, 3),
      ('O que é solvência?', 'Quantidade de dinheiro em espécie', FALSE, 0),
      ('O que é solvência?', 'Capacidade de fazer uma compra', FALSE, 1),
      ('O que é solvência?', 'Valor de um produto', FALSE, 2),
      ('O que é solvência?', 'Capacidade de cumprir obrigações financeiras no longo prazo', TRUE, 3),
      ('Qual é a diferença entre liquidez e solvência?', 'Liquidez mede apenas lucro', FALSE, 0),
      ('Qual é a diferença entre liquidez e solvência?', 'São exatamente a mesma coisa', FALSE, 1),
      ('Qual é a diferença entre liquidez e solvência?', 'Solvência mede apenas inflação', FALSE, 2),
      ('Qual é a diferença entre liquidez e solvência?', 'Liquidez está relacionada à capacidade de cumprir obrigações de curto prazo; solvência está relacionada à capacidade financeira de longo prazo', TRUE, 3),
      ('O que significa análise de fluxo de caixa?', 'Análise apenas das vendas', FALSE, 0),
      ('O que significa análise de fluxo de caixa?', 'Avaliação das entradas e saídas de dinheiro durante determinado período', TRUE, 1),
      ('O que significa análise de fluxo de caixa?', 'Cálculo apenas dos impostos', FALSE, 2),
      ('O que significa análise de fluxo de caixa?', 'Avaliação apenas do patrimônio', FALSE, 3),
      ('Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 'Diferença entre lucro e fluxo de caixa', TRUE, 0),
      ('Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 'Inflação', FALSE, 1),
      ('Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 'Diversificação', FALSE, 2),
      ('Uma empresa apresenta lucro contábil, mas enfrenta falta de dinheiro para pagar contas imediatas. Qual conceito ajuda a explicar essa situação?', 'Patrimônio líquido', FALSE, 3),
      ('O que é capital de giro?', 'Apenas patrimônio pessoal do proprietário', FALSE, 0),
      ('O que é capital de giro?', 'Recursos necessários para sustentar as operações correntes de uma empresa', TRUE, 1),
      ('O que é capital de giro?', 'Somente dinheiro em caixa físico', FALSE, 2),
      ('O que é capital de giro?', 'Apenas dinheiro destinado a investimentos de longo prazo', FALSE, 3),
      ('O que é margem de lucro?', 'Relação entre o lucro e a receita, geralmente expressa em percentual', TRUE, 0),
      ('O que é margem de lucro?', 'Quantidade de funcionários', FALSE, 1),
      ('O que é margem de lucro?', 'Valor total dos ativos', FALSE, 2),
      ('O que é margem de lucro?', 'Soma de todas as dívidas', FALSE, 3),
      ('Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 'A margem de lucro pode diminuir', TRUE, 0),
      ('Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 'A empresa necessariamente fica mais eficiente', FALSE, 1),
      ('Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 'Os custos deixam de existir', FALSE, 2),
      ('Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?', 'O lucro necessariamente dobra', FALSE, 3),
      ('O que é ponto de equilíbrio financeiro de uma atividade?', 'Quantidade de funcionários', FALSE, 0),
      ('O que é ponto de equilíbrio financeiro de uma atividade?', 'Momento em que a empresa sempre obtém lucro máximo', FALSE, 1),
      ('O que é ponto de equilíbrio financeiro de uma atividade?', 'Valor máximo das vendas', FALSE, 2),
      ('O que é ponto de equilíbrio financeiro de uma atividade?', 'Nível em que receitas são suficientes para cobrir determinados custos e despesas considerados', TRUE, 3),
      ('Por que separar despesas pessoais das despesas de um negócio é importante?', 'Facilita o controle financeiro e a análise real do desempenho do negócio', TRUE, 0),
      ('Por que separar despesas pessoais das despesas de um negócio é importante?', 'Elimina impostos', FALSE, 1),
      ('Por que separar despesas pessoais das despesas de um negócio é importante?', 'Garante lucro', FALSE, 2),
      ('Por que separar despesas pessoais das despesas de um negócio é importante?', 'Aumenta automaticamente as vendas', FALSE, 3),
      ('O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?', 'Garante melhores investimentos', FALSE, 0),
      ('O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?', 'Pode aumentar a probabilidade de decisões impulsivas e inadequadas', TRUE, 1),
      ('O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?', 'Elimina riscos', FALSE, 2),
      ('O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?', 'Garante lucro', FALSE, 3),
      ('Qual é uma característica de uma decisão financeira bem fundamentada?', 'Ignora riscos', FALSE, 0),
      ('Qual é uma característica de uma decisão financeira bem fundamentada?', 'Baseia-se apenas em rumores', FALSE, 1),
      ('Qual é uma característica de uma decisão financeira bem fundamentada?', 'Depende exclusivamente de publicidade', FALSE, 2),
      ('Qual é uma característica de uma decisão financeira bem fundamentada?', 'Considera objetivos, custos, riscos, alternativas e capacidade financeira', TRUE, 3),
      ('O que é custo de oportunidade?', 'Um tipo de salário', FALSE, 0),
      ('O que é custo de oportunidade?', 'Um imposto bancário', FALSE, 1),
      ('O que é custo de oportunidade?', 'O benefício perdido ao escolher uma alternativa em vez de outra', TRUE, 2),
      ('O que é custo de oportunidade?', 'Uma conta de eletricidade', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_fin_dificil;

    RAISE NOTICE '31 perguntas inseridas com sucesso (source=seed_financas_dificil_v1).';
  END IF;
END $$;

COMMIT;
