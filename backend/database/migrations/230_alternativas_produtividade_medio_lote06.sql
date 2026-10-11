-- Alternativas (BE-003, regularização) — Produtividade médio lote 6: Produtividade médio lote 6.
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (médio: migrations 230 e 231) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_medio_v6', 'O que é trabalho superficial (shallow work)?', 0, 'Trabalho que não possui nenhum objetivo', 'Atividades geralmente muito exigentes cognitivamente e que devem ser realizadas com atenção plena e contínua'),
    ('seed_produtividade_medio_v6', 'O que é trabalho superficial (shallow work)?', 2, 'Atividade exclusivamente acadêmica', 'Atividades geralmente ligadas apenas ao estudo acadêmico e realizadas com pouca atenção ao tempo'),
    ('seed_produtividade_medio_v6', 'O que é trabalho superficial (shallow work)?', 3, 'Trabalho que exige concentração máxima durante várias horas', 'Atividades geralmente realizadas em ambientes silenciosos, com concentração máxima durante várias horas seguidas'),
    ('seed_produtividade_medio_v6', 'Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 1, 'Alternar tarefas a cada minuto', 'Alternar entre tarefas a cada minuto para verificar tudo'),
    ('seed_produtividade_medio_v6', 'Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 2, 'Conferir notificações continuamente', 'Conferir as notificações de forma contínua durante o trabalho'),
    ('seed_produtividade_medio_v6', 'Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 3, 'Manter o celular sempre aberto', 'Manter o celular aberto e à vista para responder depressa'),
    ('seed_produtividade_medio_v6', 'O que significa "custo de oportunidade" na gestão do tempo?', 0, 'Tempo necessário para iniciar o computador', 'Tempo necessário para iniciar o computador e abrir os programas de trabalho'),
    ('seed_produtividade_medio_v6', 'O que significa "custo de oportunidade" na gestão do tempo?', 1, 'Custo financeiro de uma tarefa', 'Custo financeiro direto de uma tarefa registado na contabilidade'),
    ('seed_produtividade_medio_v6', 'O que significa "custo de oportunidade" na gestão do tempo?', 2, 'Tempo usado para descansar', 'Tempo gasto a descansar entre uma atividade e a seguinte do dia'),
    ('seed_produtividade_medio_v6', 'O que é capacidade de trabalho?', 0, 'Número máximo de tarefas que podem ser colocadas numa lista', 'Número máximo de tarefas que podem ser colocadas numa lista, independentemente do tempo, da energia e dos recursos disponíveis a cada dia'),
    ('seed_produtividade_medio_v6', 'O que é capacidade de trabalho?', 1, 'Quantidade de horas existentes em um dia', 'Quantidade de horas existentes em um dia, descontando apenas o tempo de sono e de refeições da pessoa'),
    ('seed_produtividade_medio_v6', 'O que é capacidade de trabalho?', 2, 'Número de reuniões possíveis', 'Número de reuniões possíveis numa semana, considerando a agenda dos colegas e os recursos da equipa'),
    ('seed_produtividade_medio_v6', 'O que é planejamento baseado em capacidade?', 0, 'Trabalhar apenas quando houver urgência', 'Trabalhar somente quando houver urgência, deixando o resto para depois'),
    ('seed_produtividade_medio_v6', 'O que é planejamento baseado em capacidade?', 2, 'Escolher tarefas aleatoriamente', 'Escolher tarefas ao acaso, sem considerar o tempo nem os recursos'),
    ('seed_produtividade_medio_v6', 'O que é planejamento baseado em capacidade?', 3, 'Planejar assumindo que todos os dias possuem capacidade ilimitada', 'Planejar como se cada dia tivesse capacidade ilimitada para executar tarefas'),
    ('seed_produtividade_medio_v6', 'O que significa buffer de tempo?', 0, 'Tempo que deve ser sempre desperdiçado', 'Tempo adicional desperdiçado de propósito para atrasar a conclusão das tarefas'),
    ('seed_produtividade_medio_v6', 'O que significa buffer de tempo?', 2, 'Tempo dedicado exclusivamente a reuniões', 'Tempo adicional dedicado a reuniões longas, com pouca relação com as tarefas'),
    ('seed_produtividade_medio_v6', 'O que significa buffer de tempo?', 3, 'Tempo usado apenas para tarefas concluídas', 'Tempo adicional usado para repetir tarefas já concluídas na semana anterior'),
    ('seed_produtividade_medio_v6', 'Por que deixar espaços vazios na agenda pode ser produtivo?', 0, 'Impede qualquer planejamento', 'Impede o planejamento das atividades e deixa o dia sem estrutura prevista para o trabalho'),
    ('seed_produtividade_medio_v6', 'Por que deixar espaços vazios na agenda pode ser produtivo?', 1, 'Reduz sempre a produtividade', 'Reduz a produtividade porque a pessoa fica com tempo livre demais para trabalhar'),
    ('seed_produtividade_medio_v6', 'Por que deixar espaços vazios na agenda pode ser produtivo?', 3, 'Significa falta de objetivos', 'Significa falta de objetivos e de organização na gestão das tarefas do dia'),
    ('seed_produtividade_medio_v6', 'O que é planejamento rígido?', 1, 'Uma agenda completamente vazia', 'Uma agenda sem compromissos marcados na semana'),
    ('seed_produtividade_medio_v6', 'O que é planejamento rígido?', 2, 'Uma lista de tarefas sem prazos', 'Uma lista de tarefas sem prazos nem prioridades definidas'),
    ('seed_produtividade_medio_v6', 'O que é planejamento rígido?', 3, 'Um planejamento sem objetivos', 'Um planejamento sem objetivos nem resultados esperados'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 0, 'A produtividade torna-se automaticamente maior', 'A produtividade torna-se maior porque há menos decisões a tomar'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 2, 'A agenda passa a ter mais flexibilidade', 'A agenda passa a ter mais flexibilidade para os imprevistos'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 3, 'Todas as tarefas tornam-se mais fáceis', 'As tarefas tornam-se mais fáceis porque a rotina fica fixa'),
    ('seed_produtividade_medio_v6', 'Qual é a diferença entre urgência e importância?', 0, 'Urgência depende apenas da dificuldade', 'Urgência depende apenas da dificuldade da tarefa; importância depende apenas do tempo que ela exige para ser feita'),
    ('seed_produtividade_medio_v6', 'Qual é a diferença entre urgência e importância?', 2, 'São exatamente a mesma coisa', 'São a mesma coisa: ambas indicam que a tarefa tem de ser feita no próprio dia em que é pedida por alguém'),
    ('seed_produtividade_medio_v6', 'Qual é a diferença entre urgência e importância?', 3, 'Importância depende apenas do prazo', 'Importância está relacionada ao prazo da tarefa; urgência está relacionada ao custo financeiro da atividade'),
    ('seed_produtividade_medio_v6', 'Qual é a principal utilidade de uma Not-to-do list?', 0, 'Aumentar o número de tarefas', 'Aumentar o número de tarefas que consomem tempo para ocupar os períodos livres de cada pessoa'),
    ('seed_produtividade_medio_v6', 'Qual é a principal utilidade de uma Not-to-do list?', 1, 'Substituir todas as metas', 'Substituir as metas de longo prazo por uma lista de tarefas pequenas e fáceis de fazer'),
    ('seed_produtividade_medio_v6', 'Qual é a principal utilidade de uma Not-to-do list?', 3, 'Eliminar períodos de descanso', 'Eliminar os períodos de descanso para que sobre mais tempo para as tarefas importantes'),
    ('seed_produtividade_medio_v6', 'O que significa aumentar o atrito de um comportamento indesejado?', 0, 'Aumentar suas recompensas', 'Aumentar as suas recompensas para o tornar mais atraente à pessoa'),
    ('seed_produtividade_medio_v6', 'O que significa aumentar o atrito de um comportamento indesejado?', 1, 'Colocá-lo como prioridade', 'Colocá-lo como prioridade máxima na lista de tarefas do dia'),
    ('seed_produtividade_medio_v6', 'O que significa aumentar o atrito de um comportamento indesejado?', 2, 'Torná-lo automático', 'Torná-lo automático, para que seja feito sem esforço'),
    ('seed_produtividade_medio_v6', 'Qual prática pode aumentar o atrito para evitar distrações digitais?', 0, 'Ativar todas as notificações', 'Ativar as notificações e deixar os aplicativos abertos para responder logo às mensagens'),
    ('seed_produtividade_medio_v6', 'Qual prática pode aumentar o atrito para evitar distrações digitais?', 1, 'Abrir redes sociais antes de cada tarefa', 'Abrir as redes sociais antes de cada tarefa para depois trabalhar com a mente livre'),
    ('seed_produtividade_medio_v6', 'Qual prática pode aumentar o atrito para evitar distrações digitais?', 3, 'Colocar os aplicativos na tela inicial', 'Colocar os aplicativos distrativos na tela inicial, para os encontrar mais depressa quando precisar'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de resultado?', 0, 'Uma meta exclusivamente relacionada ao número de horas trabalhadas', 'Uma meta relacionada ao número de horas trabalhadas'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de resultado?', 1, 'Uma rotina automática', 'Uma rotina automática de trabalho'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de resultado?', 3, 'Uma tarefa sem objetivo', 'Uma tarefa sem objetivo, feita só por obrigação'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de processo?', 0, 'Uma meta baseada exclusivamente em resultados financeiros', 'Uma meta baseada nos resultados financeiros esperados ao fim do ano e nos valores a receber dos clientes'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de processo?', 2, 'Uma meta sem ações concretas', 'Uma meta sem ações concretas, definida apenas como um desejo geral para o futuro da pessoa'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de processo?', 3, 'Uma meta que não pode ser medida', 'Uma meta que não pode ser medida nem acompanhada ao longo das semanas e dos meses de trabalho'),
    ('seed_produtividade_medio_v6', 'Por que metas de processo podem ser úteis?', 0, 'Porque eliminam todos os resultados', 'Porque eliminam os resultados e deixam a pessoa livre de cobranças externas'),
    ('seed_produtividade_medio_v6', 'Por que metas de processo podem ser úteis?', 2, 'Porque garantem resultados independentemente das circunstâncias', 'Porque garantem os resultados desejados mesmo quando as circunstâncias mudam'),
    ('seed_produtividade_medio_v6', 'Por que metas de processo podem ser úteis?', 3, 'Porque dispensam planejamento', 'Porque dispensam o planejamento e a revisão do trabalho ao longo do tempo'),
    ('seed_produtividade_medio_v6', 'Por que feedback rápido pode ser útil?', 0, 'Elimina a necessidade de aprendizagem', 'Elimina a necessidade de aprendizagem, porque o resultado já é conhecido'),
    ('seed_produtividade_medio_v6', 'Por que feedback rápido pode ser útil?', 2, 'Impede qualquer mudança', 'Impede mudanças, porque fixa o método'),
    ('seed_produtividade_medio_v6', 'Por que feedback rápido pode ser útil?', 3, 'Garante resultados perfeitos', 'Garante resultados perfeitos logo na primeira tentativa de cada tarefa'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 0, 'Porque todo planejamento deve ser abandonado', 'Porque o planejamento deve ser abandonado quando surge uma tarefa nova'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 1, 'Porque tarefas tornam-se automaticamente urgentes', 'Porque as tarefas tornam-se urgentes com o tempo'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 3, 'Porque prioridades nunca são importantes', 'Porque as prioridades perdem importância com o passar das semanas'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 0, 'Fazer sempre de maneira diferente', 'Fazer de maneira diferente a cada vez, para evitar o tédio da repetição'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 1, 'Ignorá-las até se tornarem urgentes', 'Ignorá-las até se tornarem urgentes'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 3, 'Replanejá-las do zero todos os dias', 'Replanejá-las do zero a cada dia, sem usar modelos anteriores'),
    ('seed_produtividade_medio_v6', 'Qual pergunta é adequada para uma retrospectiva de produtividade?', 1, '"Como posso eliminar todos os períodos de descanso?"', '"Como posso eliminar os períodos de descanso para trabalhar mais?"'),
    ('seed_produtividade_medio_v6', 'Qual pergunta é adequada para uma retrospectiva de produtividade?', 2, '"Como posso evitar qualquer mudança?"', '"Como posso evitar mudanças no meu sistema?"'),
    ('seed_produtividade_medio_v6', 'Qual pergunta é adequada para uma retrospectiva de produtividade?', 3, '"Como posso preencher mais horários?"', '"Como posso preencher mais horários na minha agenda semanal?"'),
    ('seed_produtividade_medio_v6', 'O que significa otimizar um sistema de produtividade?', 0, 'Eliminar todo planejamento', 'Eliminar o planejamento para trabalhar com mais liberdade e menos controlo sobre o tempo'),
    ('seed_produtividade_medio_v6', 'O que significa otimizar um sistema de produtividade?', 1, 'Trabalhar mais horas em qualquer circunstância', 'Trabalhar mais horas, mantendo os mesmos métodos, mesmo quando os resultados pioram'),
    ('seed_produtividade_medio_v6', 'O que significa otimizar um sistema de produtividade?', 2, 'Fazer mais tarefas independentemente do resultado', 'Fazer mais tarefas por dia, sem avaliar se os resultados e a eficiência do trabalho melhoraram'),
    ('seed_produtividade_medio_v6', 'Qual princípio melhor representa uma produtividade de alto nível?', 1, 'Evitar mudanças na rotina', 'Evitar mudanças na rotina, manter os mesmos métodos e repetir o que já foi feito nas semanas anteriores'),
    ('seed_produtividade_medio_v6', 'Qual princípio melhor representa uma produtividade de alto nível?', 2, 'Manter-se ocupado durante todo o dia', 'Manter-se ocupado durante o dia, aceitando as tarefas que surgem e respondendo depressa a cada pedido'),
    ('seed_produtividade_medio_v6', 'Qual princípio melhor representa uma produtividade de alto nível?', 3, 'Fazer mais coisas a qualquer custo', 'Fazer mais coisas mesmo com cansaço, sem rever o sistema nem descansar entre as tarefas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 6: % alternativa(s) errada(s) atualizada(s) (esperado: 66).', v_updated;
END $$;
