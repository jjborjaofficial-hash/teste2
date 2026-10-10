-- Alternativas (BE-003, regularização) — Produtividade fácil lote 5: perguntas 26 a 42 do seed v4 (migration 087, 17 perguntas).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_facil_v4', 'O que significa revisar uma tarefa?', 0, 'Apagar o trabalho', 'Entregar o trabalho realizado antes de conferir o seu conteúdo'),
    ('seed_produtividade_facil_v4', 'O que significa revisar uma tarefa?', 1, 'Evitar qualquer correção', 'Guardar o trabalho realizado antes de decidir se vale a pena'),
    ('seed_produtividade_facil_v4', 'O que significa revisar uma tarefa?', 3, 'Começar outro projeto', 'Copiar o trabalho realizado antes de compartilhá-lo com a equipe'),
    ('seed_produtividade_facil_v4', 'Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 1, 'Aumentar os erros', 'Adiar o envio para outro dia'),
    ('seed_produtividade_facil_v4', 'Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 2, 'Eliminar o conteúdo', 'Reduzir o tamanho do documento'),
    ('seed_produtividade_facil_v4', 'Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 3, 'Impedir a comunicação', 'Aumentar o número de páginas'),
    ('seed_produtividade_facil_v4', 'O que é um objetivo de curto prazo?', 0, 'Um objetivo que nunca pode ser concluído', 'Um resultado planejado para ser alcançado num período relativamente distante'),
    ('seed_produtividade_facil_v4', 'O que é um objetivo de curto prazo?', 2, 'Uma atividade sem finalidade', 'Uma atividade realizada de forma contínua ao longo de vários anos'),
    ('seed_produtividade_facil_v4', 'O que é um objetivo de curto prazo?', 3, 'Uma tarefa já terminada', 'Uma tarefa concluída recentemente e registrada no relatório do mês'),
    ('seed_produtividade_facil_v4', 'O que caracteriza uma tarefa urgente?', 0, 'Pode sempre esperar indefinidamente', 'Tem um prazo distante e flexível'),
    ('seed_produtividade_facil_v4', 'O que caracteriza uma tarefa urgente?', 1, 'Nunca possui prazo', 'Depende da vontade de quem a faz'),
    ('seed_produtividade_facil_v4', 'O que caracteriza uma tarefa urgente?', 2, 'Não possui qualquer consequência', 'Não traz efeito sobre o resultado final'),
    ('seed_produtividade_facil_v4', 'Qual é a diferença básica entre importante e urgente?', 0, 'São sempre exatamente a mesma coisa', 'Algo importante tem prazo curto; algo urgente tem impacto relevante'),
    ('seed_produtividade_facil_v4', 'Qual é a diferença básica entre importante e urgente?', 2, 'Algo importante nunca precisa ser realizado', 'Algo importante exige atenção rápida; algo urgente tem prazo distante'),
    ('seed_produtividade_facil_v4', 'Qual é a diferença básica entre importante e urgente?', 3, 'Algo urgente nunca possui prazo', 'Algo importante depende de terceiros; algo urgente depende da equipe'),
    ('seed_produtividade_facil_v4', 'Por que estimar o tempo necessário para uma tarefa pode ser útil?', 0, 'Garante que a tarefa será fácil', 'Reduz o número de compromissos do dia'),
    ('seed_produtividade_facil_v4', 'Por que estimar o tempo necessário para uma tarefa pode ser útil?', 1, 'Elimina todos os imprevistos', 'Dispensa a revisão do plano semanal'),
    ('seed_produtividade_facil_v4', 'Por que estimar o tempo necessário para uma tarefa pode ser útil?', 2, 'Impede qualquer alteração no plano', 'Aumenta a duração prevista das tarefas'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma rotina de estudos?', 0, 'Estudar somente quando houver vontade', 'Estudar nos dias em que houver mais tempo livre durante a semana'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma rotina de estudos?', 1, 'Nunca estabelecer horários', 'Escolher a cada dia um conteúdo diferente sem plano definido'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma rotina de estudos?', 3, 'Evitar revisar conteúdos', 'Memorizar os conteúdos na véspera de cada avaliação marcada'),
    ('seed_produtividade_facil_v4', 'Qual prática pode melhorar a organização dos estudos?', 0, 'Estudar todos os conteúdos ao mesmo tempo', 'Estudar vários conteúdos ao mesmo tempo'),
    ('seed_produtividade_facil_v4', 'Qual prática pode melhorar a organização dos estudos?', 1, 'Evitar qualquer planeamento', 'Deixar o planejamento para a véspera da prova'),
    ('seed_produtividade_facil_v4', 'Qual prática pode melhorar a organização dos estudos?', 2, 'Ignorar avaliações próximas', 'Escolher conteúdos de acordo com a vontade'),
    ('seed_produtividade_facil_v4', 'O que significa preparar materiais antes de iniciar uma tarefa?', 0, 'Adiar a tarefa', 'Adiar o início da tarefa por alguns dias'),
    ('seed_produtividade_facil_v4', 'O que significa preparar materiais antes de iniciar uma tarefa?', 2, 'Eliminar os materiais', 'Eliminar os materiais já utilizados em outras tarefas'),
    ('seed_produtividade_facil_v4', 'O que significa preparar materiais antes de iniciar uma tarefa?', 3, 'Aumentar as distrações', 'Aumentar a quantidade de tarefas do dia'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de ter um espaço de trabalho organizado?', 0, 'Impede qualquer concentração', 'Pode aumentar o tempo gasto organizando o próprio horário de trabalho'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de ter um espaço de trabalho organizado?', 1, 'Torna todas as tarefas mais demoradas', 'Pode dispensar o uso de listas e agendas pessoais'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de ter um espaço de trabalho organizado?', 3, 'Elimina a necessidade de planeamento', 'Pode reduzir a necessidade de definir prioridades diárias'),
    ('seed_produtividade_facil_v4', 'Qual exemplo representa uma tarefa recorrente?', 1, 'Comprar um computador uma única vez', 'Comprar um computador novo para o escritório'),
    ('seed_produtividade_facil_v4', 'Qual exemplo representa uma tarefa recorrente?', 2, 'Fazer uma apresentação uma única vez', 'Fazer uma apresentação para um cliente novo'),
    ('seed_produtividade_facil_v4', 'Qual exemplo representa uma tarefa recorrente?', 3, 'Entregar um documento específico uma única vez', 'Entregar o relatório final de um projeto'),
    ('seed_produtividade_facil_v4', 'O que significa acompanhar uma meta?', 0, 'Esquecer completamente o objetivo', 'Comparar o progresso com o de colegas antes de definir o objetivo'),
    ('seed_produtividade_facil_v4', 'O que significa acompanhar uma meta?', 2, 'Alterar a meta todos os dias sem motivo', 'Anotar o objetivo no início e abandoná-lo ao fim do primeiro mês'),
    ('seed_produtividade_facil_v4', 'O que significa acompanhar uma meta?', 3, 'Evitar medir qualquer resultado', 'Aumentar o tamanho do objetivo à medida que o prazo se aproxima'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de registar tarefas concluídas?', 0, 'Impede novas tarefas', 'Reduz o tempo necessário para novas tarefas'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de registar tarefas concluídas?', 2, 'Aumenta automaticamente o tempo disponível', 'Aumenta o tempo disponível durante o dia'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de registar tarefas concluídas?', 3, 'Elimina qualquer necessidade de organização', 'Dispensa a definição de metas pessoais'),
    ('seed_produtividade_facil_v4', 'O que é uma tarefa pendente?', 0, 'Uma tarefa já eliminada', 'Uma tarefa que foi retirada da lista de afazeres'),
    ('seed_produtividade_facil_v4', 'O que é uma tarefa pendente?', 1, 'Uma tarefa concluída há muito tempo', 'Uma tarefa que foi concluída há algum tempo'),
    ('seed_produtividade_facil_v4', 'O que é uma tarefa pendente?', 3, 'Uma tarefa que não possui qualquer finalidade', 'Uma tarefa que pertence a outra equipe de trabalho'),
    ('seed_produtividade_facil_v4', 'Por que é útil atualizar uma lista de tarefas?', 1, 'Para aumentar tarefas desnecessariamente', 'Para aumentar o número de tarefas previstas na semana seguinte'),
    ('seed_produtividade_facil_v4', 'Por que é útil atualizar uma lista de tarefas?', 2, 'Para apagar todas as prioridades', 'Para esconder as prioridades definidas no início'),
    ('seed_produtividade_facil_v4', 'Por que é útil atualizar uma lista de tarefas?', 3, 'Para impedir alterações no plano', 'Para manter as tarefas antigas sem revisão periódica'),
    ('seed_produtividade_facil_v4', 'O que significa trabalhar de forma organizada?', 1, 'Fazer tudo aleatoriamente', 'Fazer as atividades na ordem em que surgem durante o dia'),
    ('seed_produtividade_facil_v4', 'O que significa trabalhar de forma organizada?', 2, 'Evitar qualquer prioridade', 'Escolher as atividades de acordo com o humor de cada momento'),
    ('seed_produtividade_facil_v4', 'O que significa trabalhar de forma organizada?', 3, 'Ignorar os prazos', 'Deixar as atividades em aberto até que alguém peça resultado'),
    ('seed_produtividade_facil_v4', 'Qual atitude contribui para uma boa gestão do tempo?', 0, 'Adiar sempre as tarefas importantes', 'Adiar as tarefas importantes para o final do período disponível'),
    ('seed_produtividade_facil_v4', 'Qual atitude contribui para uma boa gestão do tempo?', 2, 'Trabalhar sem objetivos', 'Trabalhar sem objetivos definidos e sem prazos estabelecidos'),
    ('seed_produtividade_facil_v4', 'Qual atitude contribui para uma boa gestão do tempo?', 3, 'Aceitar todas as distrações', 'Aceitar as distrações que aparecem para manter o ritmo do dia')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 5: perguntas 26 a 42 do seed v4 (migration 087, 17 perguntas): % alternativa(s) errada(s) atualizada(s) (esperado: 51).', v_updated;
END $$;
