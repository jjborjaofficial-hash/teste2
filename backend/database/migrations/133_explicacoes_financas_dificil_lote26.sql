-- Explicações pedagógicas (BE-004) — Finanças difícil, lote 26 (10 perguntas): fecha o seed 047
-- (as 6 últimas, source 'seed_financas_dificil_v1') e abre o seed 073 (as 4 primeiras, source
-- 'seed_financas_dificil_v2'). Mesmo critério das migrations 109 a 132: só preenche
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
    ('seed_financas_dificil_v1', 'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?',
     'Vender mais não basta: o lucro depende da diferença entre a receita e os custos. Se os custos sobem mais depressa do que as vendas, sobra menos por cada unidade vendida, e a margem de lucro pode diminuir, até virar prejuízo. A empresa não fica mais eficiente, os custos não desaparecem e o lucro não dobra.'),
    ('seed_financas_dificil_v1', 'O que é ponto de equilíbrio financeiro de uma atividade?',
     'Ponto de equilíbrio é o nível de vendas em que as receitas cobrem os custos e despesas considerados: nem lucro, nem prejuízo. É uma referência para saber quanto é preciso vender antes de começar a lucrar. Não é o lucro máximo, o total de funcionários nem o valor máximo das vendas.'),
    ('seed_financas_dificil_v1', 'Por que separar despesas pessoais das despesas de um negócio é importante?',
     'Misturar as contas esconde o desempenho real do negócio: não se sabe se ele dá lucro ou se está a ser sustentado pelo dinheiro pessoal. Separar facilita o controle financeiro e a análise. Não elimina impostos, não garante lucro e não aumenta vendas.'),
    ('seed_financas_dificil_v1', 'O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?',
     'Decisões guiadas só pela emoção, como medo ou euforia, tendem a ser impulsivas: comprar por impulso ou vender em pânico, por exemplo. Isso aumenta a chance de decisões inadequadas. A emoção não garante melhores investimentos, nem lucro, e não elimina riscos.'),
    ('seed_financas_dificil_v1', 'Qual é uma característica de uma decisão financeira bem fundamentada?',
     'Uma boa decisão financeira considera os objetivos, os custos, os riscos, as alternativas e a capacidade financeira de quem decide. Ignorar riscos, seguir rumores ou depender só de publicidade são sinais de uma decisão mal fundamentada.'),
    ('seed_financas_dificil_v1', 'O que é custo de oportunidade?',
     'Custo de oportunidade é o benefício perdido ao escolher uma alternativa em vez de outra. Todo uso do dinheiro ou do tempo tem esse custo: gastar 1.000 MZN em algo é abrir mão do que esse dinheiro renderia aplicado, por exemplo. Não é salário, imposto nem conta de eletricidade.'),
    ('seed_financas_dificil_v2', 'O que é alocação estratégica de ativos?',
     'Alocação estratégica é a distribuição planejada dos investimentos entre classes de ativos para atingir objetivos de longo prazo. Define-se uma divisão-alvo e ela é revista de vez em quando, em vez de mudar a cada notícia. Não é guardar tudo em casa, vender tudo nem comprar ao acaso.'),
    ('seed_financas_dificil_v2', 'O que é volatilidade em investimentos?',
     'Volatilidade mede quanto o preço de um ativo varia ao longo do tempo. Quanto mais varia, mais incerto é o valor no curto prazo, por isso é usada como medida de risco. Não é lucro constante, valor inicial investido nem taxa fixa de rendimento.'),
    ('seed_financas_dificil_v2', 'O que é risco sistêmico?',
     'Risco sistêmico é o que afeta todo o mercado ou o sistema financeiro, como uma crise económica. Como atinge tudo ao mesmo tempo, a diversificação não o elimina. Difere do risco de uma só empresa, que se pode reduzir com diversificação.'),
    ('seed_financas_dificil_v2', 'O que é risco não sistêmico?',
     'Risco não sistêmico é o específico de uma empresa ou setor, como um problema de gestão ou a perda de um cliente importante. Pode ser reduzido pela diversificação, porque a perda numa empresa é compensada por outras. Alterações cambiais globais e inflação mundial afetam todo o sistema e são sistêmicas.')
  ) AS v(source, statement, explanation)
  WHERE q.statement = v.statement
    AND q.source = v.source
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Finanças difícil lote 26: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
