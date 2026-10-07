-- Alternativas (BE-003, regularização) — Produtividade fácil lote 1: perguntas 1 a 25 do seed v1 (migration 042).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Esta categoria (Produtividade) usa a faixa de migrations 200+
-- para não colidir com as de Finanças (141+), que seguem noutra sessão.
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
    ('seed_produtividade_facil_v1', 'O que significa ser produtivo?', 0, 'Evitar qualquer descanso', 'Trabalhar sem pausas durante todo o dia'),
    ('seed_produtividade_facil_v1', 'O que significa ser produtivo?', 1, 'Fazer várias coisas ao mesmo tempo', 'Concluir o maior número possível de tarefas durante o dia'),
    ('seed_produtividade_facil_v1', 'O que significa ser produtivo?', 2, 'Trabalhar sem parar', 'Fazer várias atividades ao mesmo tempo'),
    ('seed_produtividade_facil_v1', 'O que é uma tarefa?', 1, 'Um período de descanso', 'Intervalo entre duas atividades do dia'),
    ('seed_produtividade_facil_v1', 'O que é uma tarefa?', 2, 'Apenas uma reunião', 'Reunião marcada com outras pessoas'),
    ('seed_produtividade_facil_v1', 'O que é uma tarefa?', 3, 'Uma ferramenta digital', 'Aplicação usada para organizar o tempo'),
    ('seed_produtividade_facil_v1', 'Para que serve uma lista de tarefas?', 0, 'Aumentar o número de tarefas', 'Medir quanto tempo cada tarefa demorou'),
    ('seed_produtividade_facil_v1', 'Para que serve uma lista de tarefas?', 1, 'Substituir o descanso', 'Guardar as ideias para projetos futuros'),
    ('seed_produtividade_facil_v1', 'Para que serve uma lista de tarefas?', 3, 'Evitar planejamento', 'Controlar os gastos e as receitas feitos durante o mês'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 1, 'Fazer tudo ao mesmo tempo', 'Realizar todas as tarefas ao mesmo tempo'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 2, 'Escolher apenas as tarefas mais fáceis', 'Dividir o tempo disponível igualmente entre todas as tarefas'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 3, 'Adiar todas as tarefas', 'Deixar para depois as tarefas mais difíceis'),
    ('seed_produtividade_facil_v1', 'Qual destas é uma ferramenta que pode ajudar na organização?', 1, 'Coluna de som', 'Rede social'),
    ('seed_produtividade_facil_v1', 'Qual destas é uma ferramenta que pode ajudar na organização?', 2, 'Televisão', 'Jogo de vídeo'),
    ('seed_produtividade_facil_v1', 'Qual destas é uma ferramenta que pode ajudar na organização?', 3, 'Máquina fotográfica', 'Rádio'),
    ('seed_produtividade_facil_v1', 'O que é uma meta?', 1, 'Um problema', 'Obstáculo que atrapalha o trabalho'),
    ('seed_produtividade_facil_v1', 'O que é uma meta?', 2, 'Uma pausa', 'Pausa feita entre duas atividades'),
    ('seed_produtividade_facil_v1', 'O que é uma meta?', 3, 'Uma distração', 'Atividade feita só por diversão'),
    ('seed_produtividade_facil_v1', 'Por que estabelecer metas pode ser útil?', 1, 'Evita qualquer necessidade de ação', 'Ajuda a distribuir as tarefas por outras pessoas da equipa'),
    ('seed_produtividade_facil_v1', 'Por que estabelecer metas pode ser útil?', 2, 'Garante sucesso imediato', 'Ajuda a reduzir o tempo gasto em cada tarefa'),
    ('seed_produtividade_facil_v1', 'Por que estabelecer metas pode ser útil?', 3, 'Elimina automaticamente todas as dificuldades', 'Ajuda a manter o espaço de trabalho arrumado'),
    ('seed_produtividade_facil_v1', 'O que é organização pessoal?', 1, 'Fazer tudo simultaneamente', 'Forma de dividir tarefas, cargos, horários e salários'),
    ('seed_produtividade_facil_v1', 'O que é organização pessoal?', 2, 'Evitar listas', 'Forma de arrumar objetos, roupas, móveis e documentos'),
    ('seed_produtividade_facil_v1', 'O que é organização pessoal?', 3, 'Trabalhar sem planejamento', 'Forma de controlar gastos, receitas, dívidas, poupanças e investimentos'),
    ('seed_produtividade_facil_v1', 'O que é uma rotina?', 0, 'Um período sem atividades', 'Período de descanso e lazer depois do trabalho diário'),
    ('seed_produtividade_facil_v1', 'O que é uma rotina?', 2, 'Um objetivo financeiro', 'Resultado final de um projeto'),
    ('seed_produtividade_facil_v1', 'O que é uma rotina?', 3, 'Uma tarefa feita apenas uma vez', 'Atividade realizada uma única vez'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de ter uma rotina?', 0, 'Impede mudanças', 'Pode dispensar a necessidade de cumprir prazos e compromissos'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de ter uma rotina?', 1, 'Garante produtividade máxima', 'Pode tornar desnecessário o descanso ao longo do dia'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de ter uma rotina?', 2, 'Elimina todos os problemas', 'Pode substituir a necessidade de definir objetivos claros'),
    ('seed_produtividade_facil_v1', 'O que significa cumprir um prazo?', 0, 'Adiar indefinidamente', 'Começar a atividade no período estabelecido'),
    ('seed_produtividade_facil_v1', 'O que significa cumprir um prazo?', 2, 'Cancelar uma tarefa', 'Pedir mais tempo ao responsável para concluir a atividade'),
    ('seed_produtividade_facil_v1', 'O que significa cumprir um prazo?', 3, 'Começar uma tarefa depois do prazo', 'Concluir a atividade o mais depressa possível'),
    ('seed_produtividade_facil_v1', 'O que é uma distração?', 0, 'Um resultado', 'Algo que ajuda a terminar mais depressa a atividade principal'),
    ('seed_produtividade_facil_v1', 'O que é uma distração?', 1, 'Uma meta', 'Pausa planeada para recuperar a atenção'),
    ('seed_produtividade_facil_v1', 'O que é uma distração?', 2, 'Uma prioridade', 'Atividade mais importante a fazer no dia'),
    ('seed_produtividade_facil_v1', 'Qual destas pode ser uma distração durante os estudos?', 0, 'Exercício relacionado à matéria', 'Resumo da matéria estudada'),
    ('seed_produtividade_facil_v1', 'Qual destas pode ser uma distração durante os estudos?', 1, 'Material de estudo', 'Silêncio e organização no local de estudo'),
    ('seed_produtividade_facil_v1', 'Qual destas pode ser uma distração durante os estudos?', 3, 'Caderno', 'Horário de estudo definido'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 0, 'Trabalhar sem objetivo', 'Dividir a atenção entre várias atividades'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 1, 'Realizar várias atividades simultaneamente', 'Descansar a mente antes de qualquer atividade'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 3, 'Ignorar todas as tarefas', 'Memorizar todos os detalhes de uma atividade'),
    ('seed_produtividade_facil_v1', 'Por que pequenas pausas podem ser úteis?', 0, 'Porque tornam o trabalho desnecessário', 'Podem ajudar a esquecer as tarefas e os prazos'),
    ('seed_produtividade_facil_v1', 'Por que pequenas pausas podem ser úteis?', 2, 'Porque substituem o planejamento', 'Podem ajudar a substituir o planejamento do dia'),
    ('seed_produtividade_facil_v1', 'Por que pequenas pausas podem ser úteis?', 3, 'Porque eliminam todas as tarefas', 'Podem ajudar a diminuir o número de tarefas pendentes'),
    ('seed_produtividade_facil_v1', 'O que é procrastinação?', 0, 'Concluir uma tarefa antecipadamente', 'Realizar uma tarefa antes do prazo combinado'),
    ('seed_produtividade_facil_v1', 'O que é procrastinação?', 1, 'Organizar documentos', 'Interromper uma tarefa para atender a uma urgência do trabalho'),
    ('seed_produtividade_facil_v1', 'O que é procrastinação?', 3, 'Planejar uma atividade', 'Dedicar muito tempo a uma única tarefa importante'),
    ('seed_produtividade_facil_v1', 'Qual atitude pode ajudar a combater a procrastinação?', 0, 'Aumentar as distrações', 'Esperar até sentir vontade de começar'),
    ('seed_produtividade_facil_v1', 'Qual atitude pode ajudar a combater a procrastinação?', 2, 'Adiar todas as atividades', 'Deixar as tarefas mais difíceis para o final'),
    ('seed_produtividade_facil_v1', 'Qual atitude pode ajudar a combater a procrastinação?', 3, 'Ignorar completamente a tarefa', 'Aumentar o número de tarefas na lista'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 0, 'Evitar qualquer organização', 'Registar no final do dia tudo o que foi feito e o que ficou por fazer'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 2, 'Fazer tarefas aleatoriamente', 'Decidir as atividades à medida que surgem'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 3, 'Trabalhar sem horários', 'Reservar o dia todo para uma só atividade'),
    ('seed_produtividade_facil_v1', 'O que é um calendário?', 0, 'Uma técnica de memorização', 'Ferramenta usada para memorizar textos e conceitos'),
    ('seed_produtividade_facil_v1', 'O que é um calendário?', 1, 'Apenas uma lista de compras', 'Ferramenta usada para guardar documentos e arquivos'),
    ('seed_produtividade_facil_v1', 'O que é um calendário?', 2, 'Um aplicativo financeiro', 'Ferramenta usada para controlar o orçamento mensal'),
    ('seed_produtividade_facil_v1', 'O que é um compromisso?', 0, 'Um período de sono', 'Atividade escolhida livremente, sem hora marcada nem prazo'),
    ('seed_produtividade_facil_v1', 'O que é um compromisso?', 1, 'Uma distração obrigatória', 'Tarefa que se faz apenas quando sobra tempo'),
    ('seed_produtividade_facil_v1', 'O que é um compromisso?', 2, 'Uma tarefa sem prazo', 'Lista das tarefas que ainda não foram concluídas'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de organizar o espaço de trabalho?', 0, 'Garante sucesso automático', 'Pode aumentar o número de materiais e ferramentas disponíveis'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de organizar o espaço de trabalho?', 1, 'Elimina todas as tarefas', 'Pode substituir a necessidade de planejar o dia'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de organizar o espaço de trabalho?', 2, 'Aumenta obrigatoriamente o tempo de trabalho', 'Pode diminuir o número de tarefas a realizar'),
    ('seed_produtividade_facil_v1', 'O que significa terminar uma tarefa?', 1, 'Apenas começar', 'Começar aquilo que precisava ser realizado'),
    ('seed_produtividade_facil_v1', 'O que significa terminar uma tarefa?', 2, 'Adiar', 'Adiar aquilo que precisava ser realizado'),
    ('seed_produtividade_facil_v1', 'O que significa terminar uma tarefa?', 3, 'Ignorar', 'Delegar aquilo que precisava ser realizado'),
    ('seed_produtividade_facil_v1', 'O que é foco?', 0, 'Tempo de descanso', 'Capacidade de realizar várias atividades ao mesmo tempo'),
    ('seed_produtividade_facil_v1', 'O que é foco?', 1, 'Quantidade de tarefas realizadas simultaneamente', 'Capacidade de terminar tarefas no menor tempo possível'),
    ('seed_produtividade_facil_v1', 'O que é foco?', 3, 'Número de aplicativos instalados', 'Capacidade de lembrar todos os compromissos da semana'),
    ('seed_produtividade_facil_v1', 'Qual é uma boa prática antes de começar um trabalho importante?', 0, 'Abrir várias redes sociais', 'Esperar sentir vontade de trabalhar'),
    ('seed_produtividade_facil_v1', 'Qual é uma boa prática antes de começar um trabalho importante?', 1, 'Começar sem saber o objetivo', 'Começar logo pela tarefa mais fácil'),
    ('seed_produtividade_facil_v1', 'Qual é uma boa prática antes de começar um trabalho importante?', 3, 'Ignorar o prazo', 'Adiar o início para o último dia'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 0, 'Misturar documentos aleatoriamente', 'Guardar todos os dados num só ficheiro, sem separação por tema'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 2, 'Apagar todas as informações', 'Reunir o maior número possível de dados antes de qualquer decisão'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 3, 'Guardar tudo sem identificação', 'Copiar dados para vários locais de modo que ocupem menos espaço')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 1: perguntas 1 a 25 do seed v1: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
