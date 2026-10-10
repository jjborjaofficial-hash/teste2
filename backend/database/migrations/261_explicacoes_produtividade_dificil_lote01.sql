-- Explicações pedagógicas (BE-004) — Produtividade difícil lote 1: perguntas 1 a 24 do seed v1 (migration 044) e a 1 do seed v2 (migration 078).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 260. Só atualiza perguntas
-- que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não impedir o arranque
-- do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_dificil_v1', 'O que é a Lei de Parkinson?', 'A Lei de Parkinson diz que o trabalho se expande para preencher o tempo disponível: com mais prazo, a tarefa tende a ficar mais lenta, e não mais bem feita. As outras opções são nomes e regras de outras áreas, sem relação com o uso do tempo.'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 'Como o trabalho tende a ocupar todo o tempo dado, prazos excessivamente longos favorecem a expansão desnecessária das tarefas. Por isso é melhor definir prazos realistas e, se preciso, mais curtos. Mais tempo não garante mais qualidade.'),
    ('seed_produtividade_dificil_v1', 'O que é custo de contexto?', 'O custo de contexto é a eficiência que se perde cada vez que o cérebro precisa mudar de um tipo de tarefa para outro: leva tempo para retomar o raciocínio. Não é um custo em dinheiro, e sim um desgaste de atenção e de tempo.'),
    ('seed_produtividade_dificil_v1', 'Qual estratégia pode reduzir o custo de contexto?', 'Agrupar tarefas semelhantes em blocos reduz as trocas de contexto, porque a mente continua no mesmo tipo de raciocínio. Alternar de tarefa a toda hora ou manter tudo aberto faz exatamente o contrário.'),
    ('seed_produtividade_dificil_v1', 'O que é trabalho profundo?', 'Trabalho profundo é um período de concentração intensa numa atividade que exige muito do raciocínio, com poucas distrações. É nesses períodos que se produzem os resultados mais difíceis e valiosos.'),
    ('seed_produtividade_dificil_v1', 'Qual é um obstáculo comum ao trabalho profundo?', 'Interrupções frequentes quebram a concentração e obrigam a mente a recomeçar. Por isso são o principal obstáculo ao trabalho profundo. Períodos protegidos, ambiente organizado e objetivos claros ajudam a concentrar.'),
    ('seed_produtividade_dificil_v1', 'O que é carga cognitiva?', 'Carga cognitiva é a quantidade de informação e de esforço mental que a memória de trabalho precisa processar ao mesmo tempo. Quando passa do limite, a pessoa erra mais e rende menos. Dinheiro, internet ou número de pessoas são outras coisas.'),
    ('seed_produtividade_dificil_v1', 'Por que dividir informações complexas em partes pode ajudar?', 'Dividir informações complexas em partes pode reduzir a carga cognitiva, porque a memória de trabalho lida com menos coisas de cada vez. Dividir não elimina o conteúdo nem o estudo: só o organiza em passos mais fáceis de processar.'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 'Intenção de implementação é planejar no formato "se acontecer X, então farei Y", ligando uma situação a uma ação. Não tem relação com vendas, finanças ou compras.'),
    ('seed_produtividade_dificil_v1', 'Por que uma intenção de implementação pode ajudar na execução?', 'Ao definir antes a resposta para uma situação prevista, a pessoa não precisa decidir na hora e age quase no automático, o que ajuda a executar. Isso não impede os imprevistos nem aumenta o tempo disponível: só prepara a reação.'),
    ('seed_produtividade_dificil_v1', 'O que é efeito Zeigarnik?', 'O efeito Zeigarnik é a tendência de tarefas incompletas ficarem mais acessíveis na memória do que algumas já concluídas. Por isso uma pendência em aberto continua "pesando" na cabeça até ser resolvida ou registrada.'),
    ('seed_produtividade_dificil_v1', 'Como o efeito Zeigarnik pode afetar a produtividade?', 'Pendências mal organizadas continuam ocupando a atenção mental e distraem do que está sendo feito. Anotá-las num lugar de confiança e decidir quando serão feitas libera a mente, o que melhora o foco.'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 'Planejamento de capacidade é avaliar quanto trabalho a equipe consegue realmente fazer com o tempo e os recursos que tem, para não prometer mais do que é possível. As outras opções são tarefas administrativas diferentes.'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 'Uma agenda lotada não deixa folga para imprevistos: qualquer atraso empurra o resto, a pressão aumenta e surgem mais atrasos. Planejar com margem protege o ritmo e a qualidade do trabalho.'),
    ('seed_produtividade_dificil_v1', 'O que é gargalo em um processo?', 'Gargalo é a etapa que limita a capacidade de todo o processo: o fluxo não passa mais depressa do que ela. Como a velocidade do conjunto depende desse ponto mais lento, é nele que se deve agir.'),
    ('seed_produtividade_dificil_v1', 'Por que identificar gargalos é importante?', 'O desempenho do processo é limitado pelo gargalo, então melhorá-lo aumenta o resultado de todo o conjunto. Melhorar etapas que já são rápidas não muda o ritmo final.'),
    ('seed_produtividade_dificil_v1', 'O que é otimização prematura?', 'Otimização prematura é gastar esforço em melhorar detalhes antes de entender ou resolver os problemas que mais pesam. O erro está na ordem: primeiro o que importa, depois os ajustes finos.'),
    ('seed_produtividade_dificil_v1', 'Por que a otimização prematura pode ser prejudicial?', 'Otimizar cedo demais pode consumir tempo em melhorias de baixo impacto enquanto os problemas importantes continuam sem solução. Não quer dizer que otimizar seja ruim: o ponto é escolher a hora e o alvo certos.'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 'O princípio de Pareto observa que uma parcela pequena das causas costuma gerar uma parcela grande dos resultados, em certos contextos. Os números 80 e 20 são uma referência aproximada, não uma regra exata nem um método de orçamento ou de estudo.'),
    ('seed_produtividade_dificil_v1', 'Como o princípio 80/20 pode ser aplicado à produtividade?', 'Aplicar o 80/20 é identificar as poucas atividades que geram grande parte dos resultados e dar prioridade a elas. Cortar tarefas ao acaso ou seguir porcentagens fixas ignora o que realmente traz resultado.'),
    ('seed_produtividade_dificil_v1', 'O que significa trabalhar de forma eficiente?', 'Ser eficiente é usar bem o tempo e os recursos para chegar ao resultado. Trabalhar mais horas, fazer várias coisas ao mesmo tempo ou não descansar gasta mais energia e costuma piorar o resultado.'),
    ('seed_produtividade_dificil_v1', 'Qual é a diferença entre eficiência e eficácia?', 'Eficiência é fazer bem com os recursos que se tem; eficácia é alcançar o resultado pretendido. Dá para ser eficiente e não eficaz, por exemplo fazer muito bem uma tarefa que não leva ao objetivo.'),
    ('seed_produtividade_dificil_v1', 'Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 'Concluir muitas tarefas mostra eficiência na execução, mas se quase nenhuma serve ao objetivo principal falta eficácia. Quantidade de tarefas não é sinal de resultado: o que conta é o quanto contribuem para o objetivo.'),
    ('seed_produtividade_dificil_v1', 'O que é melhoria contínua?', 'Melhoria contínua é avaliar e aperfeiçoar métodos e resultados aos poucos, de forma constante. Mudar tudo todos os dias sem análise ou acabar com as rotinas não é melhorar: é recomeçar sem aprender.'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui 20 tarefas, mas apenas cinco contribuem diretamente para o objetivo principal do projeto. Qual abordagem é mais adequada?', 'Só cinco das 20 tarefas contribuem diretamente para o objetivo, então elas devem vir primeiro, por serem as de maior contribuição. Dividir o tempo por igual ou começar pelas mais rápidas gasta esforço no que pouco ajuda.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade difícil lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
