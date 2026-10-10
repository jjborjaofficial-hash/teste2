-- Alternativas (BE-003, regularização) — Produtividade médio lote 4: 25 perguntas ativas de Produtividade médio (v3 2, v4 20, v5 2, v6 1; ordem de inserção) ainda sem explicação.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda; só o texto das
-- alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis, sem absolutos só nas erradas).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, tarefas importantes, mas não urgentes, devem ser:', 1, 'Delegadas obrigatoriamente', 'Delegadas'),
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 0, 'Delegada sempre', 'Delegada a alguém'),
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 1, 'Eliminada', 'Eliminada da lista'),
    ('seed_produtividade_medio_v3', 'Na Matriz de Eisenhower, uma tarefa importante e urgente deve ser:', 3, 'Adiada indefinidamente', 'Adiada para a semana'),
    ('seed_produtividade_medio_v4', 'Qual pode ser a vantagem de agrupar tarefas semelhantes?', 0, 'Garante que nenhuma tarefa será concluída', 'Pode aumentar o tempo gasto a preparar cada tarefa'),
    ('seed_produtividade_medio_v4', 'Qual pode ser a vantagem de agrupar tarefas semelhantes?', 1, 'Aumenta obrigatoriamente as interrupções', 'Pode reduzir a necessidade de rever prioridades'),
    ('seed_produtividade_medio_v4', 'Qual pode ser a vantagem de agrupar tarefas semelhantes?', 2, 'Elimina todos os prazos', 'Pode aumentar mudanças frequentes de ferramenta'),
    ('seed_produtividade_medio_v4', 'O que é mudança de contexto no trabalho?', 0, 'Trabalhar sempre na mesma atividade', 'Mudar de local de trabalho várias vezes ao longo do mesmo dia'),
    ('seed_produtividade_medio_v4', 'O que é mudança de contexto no trabalho?', 2, 'Organizar documentos', 'Reorganizar os documentos de uma atividade para outra pasta'),
    ('seed_produtividade_medio_v4', 'O que é mudança de contexto no trabalho?', 3, 'Definir uma meta', 'Alterar a meta de uma atividade antes de a terminar'),
    ('seed_produtividade_medio_v4', 'O que é uma margem de segurança no planejamento do tempo?', 0, 'Tempo eliminado do calendário', 'Tempo reservado para tarefas fixas e repetidas'),
    ('seed_produtividade_medio_v4', 'O que é uma margem de segurança no planejamento do tempo?', 1, 'Tempo destinado exclusivamente a distrações', 'Tempo adicional reservado para reuniões ou encontros sociais'),
    ('seed_produtividade_medio_v4', 'O que é uma margem de segurança no planejamento do tempo?', 3, 'Tempo que nunca pode ser utilizado', 'Tempo adicional reservado para tarefas que podem ser delegadas'),
    ('seed_produtividade_medio_v4', 'Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 1, 'Mantê-la obrigatoriamente no topo', 'Mantê-la no topo até acabar'),
    ('seed_produtividade_medio_v4', 'Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 2, 'Ignorar a mudança', 'Adiar a decisão por uns dias'),
    ('seed_produtividade_medio_v4', 'Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 3, 'Duplicar a tarefa', 'Dividir a tarefa em duas'),
    ('seed_produtividade_medio_v4', 'O que é uma interrupção planejada?', 0, 'Uma distração inesperada', 'Uma pausa que surge sem aviso durante o trabalho'),
    ('seed_produtividade_medio_v4', 'O que é uma interrupção planejada?', 2, 'Um erro de comunicação', 'Uma mudança de atividade pedida de surpresa por um colega'),
    ('seed_produtividade_medio_v4', 'O que é uma interrupção planejada?', 3, 'Uma tarefa esquecida', 'Uma reunião que ocupa a agenda da equipa inteira'),
    ('seed_produtividade_medio_v4', 'O que significa dizer "não" a uma tarefa que não é prioritária?', 1, 'Recusar sempre qualquer responsabilidade', 'Mostrar falta de interesse pelas atividades da equipa'),
    ('seed_produtividade_medio_v4', 'O que significa dizer "não" a uma tarefa que não é prioritária?', 2, 'Evitar todo trabalho', 'Reduzir o volume de trabalho que se faz durante o dia'),
    ('seed_produtividade_medio_v4', 'O que significa dizer "não" a uma tarefa que não é prioritária?', 3, 'Cancelar todos os objetivos', 'Dar prioridade às tarefas mais fáceis e rápidas de fazer'),
    ('seed_produtividade_medio_v4', 'Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 1, 'Todas as tarefas serão concluídas mais cedo', 'As tarefas podem acabar antes do prazo previsto'),
    ('seed_produtividade_medio_v4', 'Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 2, 'A quantidade de trabalho desaparecerá', 'O calendário pode ficar com muitos espaços livres'),
    ('seed_produtividade_medio_v4', 'Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 3, 'Os prazos deixarão de existir', 'As tarefas podem ser concluídas sem esforço'),
    ('seed_produtividade_medio_v4', 'Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 0, 'Garante que todas as tarefas serão mais rápidas', 'Ajuda a reduzir o número de tarefas a fazer por dia'),
    ('seed_produtividade_medio_v4', 'Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 1, 'Elimina a necessidade de planeamento', 'Ajuda a evitar que as tarefas tenham prazos definidos'),
    ('seed_produtividade_medio_v4', 'Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 2, 'Impede a aprendizagem com experiências anteriores', 'Ajuda a escolher tarefas mais fáceis e mais rápidas'),
    ('seed_produtividade_medio_v4', 'O que é uma estimativa de esforço?', 0, 'Uma garantia de que não haverá dificuldades', 'Uma medição exata do tempo realmente gasto por cada pessoa numa atividade concluída'),
    ('seed_produtividade_medio_v4', 'O que é uma estimativa de esforço?', 1, 'Uma forma de eliminar tarefas', 'Uma previsão do número de pessoas necessárias para supervisionar e concluir uma atividade complexa'),
    ('seed_produtividade_medio_v4', 'O que é uma estimativa de esforço?', 3, 'Uma previsão do salário', 'Uma comparação entre o orçamento disponível e o custo total de uma atividade'),
    ('seed_produtividade_medio_v4', 'Por que evitar preencher cada minuto do dia pode ser útil?', 0, 'Impede qualquer produtividade', 'Permite trabalhar mais depressa nas tarefas'),
    ('seed_produtividade_medio_v4', 'Por que evitar preencher cada minuto do dia pode ser útil?', 1, 'Garante mais atrasos', 'Permite reduzir o número de reuniões'),
    ('seed_produtividade_medio_v4', 'Por que evitar preencher cada minuto do dia pode ser útil?', 2, 'Elimina prioridades', 'Permite ignorar os prazos da semana'),
    ('seed_produtividade_medio_v4', 'Qual é o principal objetivo de uma matriz de prioridades?', 0, 'Eliminar todas as tarefas', 'Registrar atividades segundo critérios como duração e custo previsto'),
    ('seed_produtividade_medio_v4', 'Qual é o principal objetivo de uma matriz de prioridades?', 2, 'Aumentar o número de reuniões', 'Dividir atividades segundo critérios como departamento e função'),
    ('seed_produtividade_medio_v4', 'Qual é o principal objetivo de uma matriz de prioridades?', 3, 'Substituir todos os calendários', 'Agendar atividades segundo critérios como hora e local disponível'),
    ('seed_produtividade_medio_v4', 'Por que mudanças constantes de contexto podem prejudicar a produtividade?', 0, 'Tornam a concentração automaticamente maior', 'Podem exigir mais tempo para escolher e aprender a usar cada nova ferramenta de trabalho'),
    ('seed_produtividade_medio_v4', 'Por que mudanças constantes de contexto podem prejudicar a produtividade?', 1, 'Eliminam todas as distrações', 'Podem reduzir o esforço mental ao dividir a atenção'),
    ('seed_produtividade_medio_v4', 'Por que mudanças constantes de contexto podem prejudicar a produtividade?', 3, 'Reduzem sempre a quantidade de trabalho', 'Podem exigir mais reuniões para coordenar cada atividade'),
    ('seed_produtividade_medio_v4', 'Qual é uma característica de uma reunião produtiva?', 0, 'Não possui finalidade', 'Possui muitos participantes e convidados externos'),
    ('seed_produtividade_medio_v4', 'Qual é uma característica de uma reunião produtiva?', 2, 'Não possui participantes definidos', 'Possui duração livre e horário aberto'),
    ('seed_produtividade_medio_v4', 'Qual é uma característica de uma reunião produtiva?', 3, 'Dura obrigatoriamente várias horas', 'Possui temas livres e flexíveis'),
    ('seed_produtividade_medio_v4', 'O que significa estimar a duração de uma tarefa?', 0, 'Definir obrigatoriamente o resultado', 'Definir a hora exata a que ela poderá terminar'),
    ('seed_produtividade_medio_v4', 'O que significa estimar a duração de uma tarefa?', 1, 'Eliminar o prazo', 'Medir quanto tempo ela exigiu depois de concluída'),
    ('seed_produtividade_medio_v4', 'O que significa estimar a duração de uma tarefa?', 3, 'Ignorar experiências anteriores', 'Escolher quem poderá ser responsável por a realizar'),
    ('seed_produtividade_medio_v4', 'Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 1, 'Ignorá-la permanentemente', 'Delegá-la antes que alguém a peça'),
    ('seed_produtividade_medio_v4', 'Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 2, 'Fazê-la apenas depois de perder o prazo', 'Deixá-la para o fim do dia quando houver tempo'),
    ('seed_produtividade_medio_v4', 'Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 3, 'Eliminá-la automaticamente', 'Esperar que outra pessoa a faça primeiro'),
    ('seed_produtividade_medio_v4', 'O que significa revisar prioridades?', 0, 'Manter todas as prioridades iguais para sempre', 'Registrar quais tarefas foram concluídas e quanto tempo demoraram com base nos resultados atuais'),
    ('seed_produtividade_medio_v4', 'O que significa revisar prioridades?', 1, 'Apagar todas as tarefas', 'Escolher quais tarefas merecem delegação com base nas regras da equipa'),
    ('seed_produtividade_medio_v4', 'O que significa revisar prioridades?', 3, 'Evitar qualquer alteração no planejamento', 'Comparar quais tarefas demoraram mais com base nos tempos registados'),
    ('seed_produtividade_medio_v4', 'Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 0, 'Iniciar ainda mais tarefas', 'Aumentar o número de tarefas em simultâneo para aproveitar melhor o tempo disponível'),
    ('seed_produtividade_medio_v4', 'Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 1, 'Evitar qualquer prazo', 'Evitar fixar prazos curtos para não sentir pressão'),
    ('seed_produtividade_medio_v4', 'Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 2, 'Trabalhar sem lista', 'Trabalhar sem lista para ter mais flexibilidade'),
    ('seed_produtividade_medio_v4', 'Por que uma agenda de reunião pode aumentar a produtividade?', 0, 'Impede qualquer participação', 'Ajuda a reduzir o tempo de preparação dos participantes'),
    ('seed_produtividade_medio_v4', 'Por que uma agenda de reunião pode aumentar a produtividade?', 2, 'Elimina todas as decisões', 'Ajuda a aumentar a duração prevista da reunião'),
    ('seed_produtividade_medio_v4', 'Por que uma agenda de reunião pode aumentar a produtividade?', 3, 'Obriga todos a falar durante o mesmo tempo', 'Ajuda a dividir a palavra em partes iguais entre todos os participantes'),
    ('seed_produtividade_medio_v5', 'Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 0, 'Aumentar o número de notificações', 'Responder às notificações assim que aparecem, para não acumularem'),
    ('seed_produtividade_medio_v5', 'Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 1, 'Alternar entre a tarefa e todas as notificações', 'Verificar as notificações a cada poucos minutos durante a tarefa para não perder nada'),
    ('seed_produtividade_medio_v5', 'Uma pessoa possui uma tarefa importante que exige concentração, mas costuma receber muitas notificações durante o trabalho. Qual estratégia é mais adequada?', 2, 'Trabalhar sem qualquer objetivo', 'Deixar o telemóvel à vista para responder com rapidez quando tocar'),
    ('seed_produtividade_medio_v5', 'Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 0, 'Adiar também as tarefas fáceis', 'Concentrar o tempo nas tarefas fáceis e começar a difícil perto do prazo final'),
    ('seed_produtividade_medio_v5', 'Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 1, 'Remover todas as tarefas do calendário', 'Aumentar o prazo da tarefa difícil e deixar o trabalho para quando houver mais vontade e tempo'),
    ('seed_produtividade_medio_v5', 'Um estudante percebe que sempre deixa as tarefas mais difíceis para o último momento. Qual estratégia pode ajudar a corrigir esse comportamento?', 3, 'Esperar até sentir vontade de começar', 'Escolher o dia mais livre da semana e fazer tudo de uma só vez no final'),
    ('seed_produtividade_medio_v6', 'Qual característica é desejável em um KPI?', 0, 'Não possuir relação com objetivos', 'Estar relacionado a um objetivo geral e ser medido de forma ocasional'),
    ('seed_produtividade_medio_v6', 'Qual característica é desejável em um KPI?', 1, 'Ser escolhido apenas por ser fácil de medir', 'Ser fácil de calcular e ser comparável com os indicadores de outras empresas do mesmo setor'),
    ('seed_produtividade_medio_v6', 'Qual característica é desejável em um KPI?', 2, 'Mudar diariamente sem critério', 'Estar relacionado a um objetivo recente e ser revisto de forma diária'),
    ('seed_produtividade_medio_v6', 'Por que o custo de oportunidade é relevante para a produtividade?', 0, 'Porque transforma tarefas em despesas financeiras', 'Porque cada escolha de tempo significa pagar um valor em dinheiro por cada hora gasta'),
    ('seed_produtividade_medio_v6', 'Por que o custo de oportunidade é relevante para a produtividade?', 1, 'Porque todas as tarefas possuem o mesmo valor', 'Porque cada escolha de tempo significa que as atividades passam a ter o mesmo valor e prazo'),
    ('seed_produtividade_medio_v6', 'Por que o custo de oportunidade é relevante para a produtividade?', 3, 'Porque elimina a necessidade de prioridades', 'Porque cada escolha de tempo significa que o plano é refeito e as prioridades deixam de ser necessárias')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 70).', v_updated;
END $$;
