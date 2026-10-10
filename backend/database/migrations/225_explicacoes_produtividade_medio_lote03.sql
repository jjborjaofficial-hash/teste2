-- Explicações pedagógicas (BE-004) — Produtividade médio lote 3: Produtividade médio lote 3.
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 224. Só atualiza perguntas
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
    ('seed_produtividade_medio_v3', 'Qual prática ajuda a reduzir o custo de troca de contexto?', 'Agrupar atividades semelhantes reduz o custo de troca de contexto, porque a mente continua no mesmo tipo de raciocínio. Alternar de tarefa ou manter notificações faz a atenção recomeçar a cada vez.'),
    ('seed_produtividade_medio_v3', 'Quando a delegação é especialmente útil?', 'A delegação é especialmente útil quando outra pessoa tem a competência ou os recursos adequados para executar a tarefa, e assim ela é feita melhor ou mais depressa. Delegar para quem não sabe ou não pode piora o resultado.'),
    ('seed_produtividade_medio_v3', 'O que é automação de tarefas?', 'Automação de tarefas é usar ferramentas ou sistemas para executar atividades repetitivas sem intervenção manual a cada vez. Poupa tempo e reduz erros em tarefas que se repetem.'),
    ('seed_produtividade_medio_v3', 'Qual tarefa é uma boa candidata à automação?', 'Uma boa candidata à automação é uma atividade repetitiva baseada em regras claras, porque a máquina consegue segui-las. Conversas emocionais, decisões subjetivas e negociações imprevisíveis precisam de julgamento humano.'),
    ('seed_produtividade_medio_v3', 'O que é uma rotina produtiva?', 'Uma rotina produtiva é um conjunto estruturado de comportamentos e atividades repetidos de forma planejada. A repetição planejada cria hábitos e poupa esforço.'),
    ('seed_produtividade_medio_v3', 'Por que rotinas podem melhorar a produtividade?', 'As rotinas reduzem a necessidade de decidir a toda a hora o que fazer em situações recorrentes, e assim poupam energia mental. Isso deixa mais atenção para o que é novo e importante.'),
    ('seed_produtividade_medio_v3', 'O que é energia mental no contexto da produtividade?', 'Energia mental é a capacidade disponível para manter a atenção, raciocinar e tomar decisões. Ela gasta-se ao longo do dia, e por isso vale a pena usá-la no que mais importa.'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 'A capacidade de concentração varia ao longo do dia, e por isso convém pôr as tarefas mais exigentes nos períodos de maior energia. Não quer dizer que o cérebro só funcione de manhã.'),
    ('seed_produtividade_medio_v3', 'O que é fadiga decisória?', 'A fadiga decisória é a redução da qualidade ou da disposição para decidir depois de muitas decisões acumuladas. Quanto mais se decide, mais cansa decidir.'),
    ('seed_produtividade_medio_v3', 'Qual prática pode reduzir a fadiga decisória?', 'Criar rotinas e padronizar decisões recorrentes reduz a quantidade de decisões novas, e por isso diminui a fadiga decisória. Mais escolhas ou mudanças constantes só aumentam o cansaço.'),
    ('seed_produtividade_medio_v3', 'O que é uma revisão diária?', 'A revisão diária é uma avaliação breve do que foi feito, do que ficou pendente e do que precisa ser ajustado. Prepara o dia seguinte e evita esquecer pendências.'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 'A revisão semanal serve para analisar resultados, identificar pendências e planejar a próxima semana. Assim os desvios são corrigidos antes de crescerem.'),
    ('seed_produtividade_medio_v3', 'O que é backlog de tarefas?', 'O backlog é o conjunto de tarefas pendentes que aguardam execução ou priorização. É a fila do que ainda falta fazer.'),
    ('seed_produtividade_medio_v3', 'Por que um backlog excessivamente grande pode ser prejudicial?', 'Um backlog muito grande pode aumentar a sensação de sobrecarga e dificultar a definição de prioridades, porque é difícil ver o que importa no meio de tanto. Convém revê-lo e podá-lo.'),
    ('seed_produtividade_medio_v3', 'Qual é uma consequência de aceitar compromissos em excesso?', 'Aceitar compromissos em excesso aumenta a sobrecarga e reduz a capacidade de cumprir as prioridades. Com mais coisas assumidas, menos tempo sobra para cada uma.'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 'Uma tarefa de alto impacto é uma atividade que pode produzir uma contribuição significativa para um objetivo importante. O impacto não depende de ser difícil nem demorada.'),
    ('seed_produtividade_medio_v3', 'Por que estar ocupado não significa necessariamente ser produtivo?', 'Estar ocupado é fazer muitas coisas; ser produtivo é avançar em objetivos relevantes. É possível trabalhar muito e avançar pouco, se as atividades não levam ao que importa.'),
    ('seed_produtividade_medio_v3', 'O que é a regra dos dois minutos, associada ao método GTD?', 'A regra dos dois minutos do GTD diz que, se uma ação pode ser concluída rapidamente, pode ser mais eficiente fazê-la logo, porque registrá-la e voltar a ela custaria mais. Aplica-se só a ações curtas.'),
    ('seed_produtividade_medio_v3', 'No método GTD, qual é uma etapa fundamental?', 'Capturar compromissos e informações que exigem atenção é uma etapa fundamental do GTD: tira as coisas da cabeça e coloca-as num sistema confiável. Assim a mente fica livre para trabalhar.'),
    ('seed_produtividade_medio_v3', 'O que é um sistema externo de organização?', 'Um sistema externo de organização é uma ferramenta, como uma lista, agenda ou aplicativo, que guarda e acompanha informações que não precisam ficar só na memória. Poupa a memória e reduz esquecimentos.'),
    ('seed_produtividade_medio_v3', 'Qual é uma vantagem de utilizar um calendário para compromissos?', 'O calendário permite visualizar as atividades ligadas a datas e horários específicos, e assim ver o que está marcado e os conflitos. Não impede mudanças nem substitui as prioridades.'),
    ('seed_produtividade_medio_v3', 'O que caracteriza uma boa sessão de foco?', 'Uma boa sessão de foco tem objetivo definido, ambiente com poucas distrações e período delimitado de concentração. Com estes três elementos, o tempo rende mais.'),
    ('seed_produtividade_medio_v3', 'Por que estimar o tempo das tarefas pode melhorar o planejamento?', 'Estimar o tempo das tarefas ajuda a comparar a carga de trabalho disponível com o tempo realmente necessário, para não prometer mais do que cabe. Não elimina imprevistos nem garante prazos.'),
    ('seed_produtividade_medio_v3', 'Qual é uma característica de um sistema de produtividade sustentável?', 'Um sistema de produtividade sustentável permite alcançar resultados mantendo equilíbrio entre execução, recuperação e capacidade pessoal. Se esgota a pessoa, deixa de funcionar a longo prazo.'),
    ('seed_produtividade_medio_v4', 'Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 'Duas tarefas com prazo hoje e impacto elevado são urgentes e importantes, por isso devem ser as primeiras. Começar pela mais fácil, sortear ou adiar deixa o que mais conta por fazer.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 3: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
