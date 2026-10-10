-- Alternativas (BE-003, regularização) — Produtividade médio lote 5: 25 perguntas ativas de Produtividade médio (v1 1, v6 24; ordem de inserção) ainda sem explicação.
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
    ('seed_produtividade_medio_v1', 'Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 0, 'Adiada para o próximo mês', 'Adiada para outro mês'),
    ('seed_produtividade_medio_v1', 'Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 1, 'Delegada sempre', 'Delegada a subordinados'),
    ('seed_produtividade_medio_v1', 'Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 3, 'Ignorada', 'Ignorada completamente'),
    ('seed_produtividade_medio_v6', 'O que é uma interrupção autoinduzida?', 1, 'Uma interrupção causada por uma emergência externa', 'Uma interrupção causada por fatores externos, como uma visita inesperada ao escritório'),
    ('seed_produtividade_medio_v6', 'O que é uma interrupção autoinduzida?', 2, 'Uma reunião previamente agendada', 'Uma interrupção prevista pela equipa, como uma reunião marcada na agenda'),
    ('seed_produtividade_medio_v6', 'O que é uma interrupção autoinduzida?', 3, 'Uma pausa obrigatória', 'Uma pausa exigida pela empresa, como o intervalo de almoço do dia'),
    ('seed_produtividade_medio_v6', 'Uma tarefa pode ser urgente, mas pouco importante?', 0, 'Apenas em tarefas financeiras', 'Sim, mas em tarefas financeiras e em contratos com prazo muito curto'),
    ('seed_produtividade_medio_v6', 'Uma tarefa pode ser urgente, mas pouco importante?', 1, 'Não, todas as tarefas urgentes são estratégicas', 'Não, todas as tarefas urgentes são estratégicas e têm grande impacto sobre os objetivos principais'),
    ('seed_produtividade_medio_v6', 'Uma tarefa pode ser urgente, mas pouco importante?', 2, 'Não, urgência sempre significa importância', 'Não, porque urgência significa importância para os objetivos principais'),
    ('seed_produtividade_medio_v6', 'O que é uma prioridade estratégica?', 0, 'Uma atividade necessariamente rápida', 'Uma atividade necessariamente rápida de concluir e que exige pouco esforço da pessoa'),
    ('seed_produtividade_medio_v6', 'O que é uma prioridade estratégica?', 2, 'Qualquer tarefa urgente', 'Qualquer tarefa urgente que apareça durante o dia de trabalho'),
    ('seed_produtividade_medio_v6', 'O que é uma prioridade estratégica?', 3, 'Uma tarefa escolhida aleatoriamente', 'Uma tarefa escolhida aleatoriamente entre as que estão na lista'),
    ('seed_produtividade_medio_v6', 'O que é revisão de prioridades?', 0, 'Exclusão automática de todas as tarefas', 'Processo de eliminar as tarefas atuais que estejam atrasadas em relação aos prazos e às metas definidas'),
    ('seed_produtividade_medio_v6', 'O que é revisão de prioridades?', 1, 'Aumento obrigatório da carga de trabalho', 'Processo de aumentar a carga de trabalho conforme os objetivos e prazos'),
    ('seed_produtividade_medio_v6', 'O que é revisão de prioridades?', 3, 'Execução de todas as tarefas simultaneamente', 'Processo de executar as tarefas atuais em paralelo, conforme os objetivos'),
    ('seed_produtividade_medio_v6', 'O que significa "tempo de trabalho profundo" (deep work)?', 1, 'Trabalho realizado exclusivamente durante a noite', 'Períodos de trabalho realizados exclusivamente durante a noite, com poucas pessoas por perto'),
    ('seed_produtividade_medio_v6', 'O que significa "tempo de trabalho profundo" (deep work)?', 2, 'Períodos destinados apenas a reuniões', 'Períodos destinados a reuniões e conversas longas, com participação de várias pessoas'),
    ('seed_produtividade_medio_v6', 'O que significa "tempo de trabalho profundo" (deep work)?', 3, 'Trabalho que envolve necessariamente atividades físicas', 'Períodos de trabalho que envolvem atividades físicas intensas, com poucas pausas'),
    ('seed_produtividade_medio_v6', 'O que significa reduzir o atrito de uma tarefa?', 0, 'Adiar seu início', 'Adiar o início da tarefa por meio da preparação de outras mais urgentes'),
    ('seed_produtividade_medio_v6', 'O que significa reduzir o atrito de uma tarefa?', 1, 'Aumentar sua complexidade', 'Aumentar a complexidade da execução da tarefa por meio de etapas adicionais'),
    ('seed_produtividade_medio_v6', 'O que significa reduzir o atrito de uma tarefa?', 3, 'Adicionar etapas desnecessárias', 'Adicionar etapas ao início da tarefa por meio de aprovações e revisões formais adicionais'),
    ('seed_produtividade_medio_v6', 'Por que checklists são úteis em tarefas repetitivas?', 0, 'Tornam qualquer tarefa automática', 'Tornam automática a escolha das tarefas mais importantes'),
    ('seed_produtividade_medio_v6', 'Por que checklists são úteis em tarefas repetitivas?', 1, 'Eliminam a necessidade de conhecimento', 'Eliminam a necessidade de conhecer as etapas da tarefa'),
    ('seed_produtividade_medio_v6', 'Por que checklists são úteis em tarefas repetitivas?', 2, 'Garantem que nenhum erro ocorrerá', 'Garantem que nenhum erro ocorrerá nas etapas da tarefa'),
    ('seed_produtividade_medio_v6', 'O que é um indicador-chave de desempenho (KPI)?', 0, 'Uma lista de tarefas', 'Uma lista de tarefas selecionadas para acompanhar o trabalho em relação a prazos'),
    ('seed_produtividade_medio_v6', 'O que é um indicador-chave de desempenho (KPI)?', 1, 'Qualquer número registrado', 'Qualquer número registrado para acompanhar o desempenho em relação a gastos'),
    ('seed_produtividade_medio_v6', 'O que é um indicador-chave de desempenho (KPI)?', 2, 'Uma técnica de concentração', 'Uma técnica de concentração selecionada para melhorar o desempenho em relação a distrações e prazos'),
    ('seed_produtividade_medio_v6', 'Qual exemplo representa uma intenção de implementação?', 0, '"Quero estudar mais."', '"Quero estudar mais, porque as notas me preocupam."'),
    ('seed_produtividade_medio_v6', 'Qual exemplo representa uma intenção de implementação?', 2, '"Estudar é importante."', '"Estudar é importante, por isso vou tentar mais vezes."'),
    ('seed_produtividade_medio_v6', 'Qual exemplo representa uma intenção de implementação?', 3, '"Talvez eu estude algum dia."', '"Talvez eu estude, se tiver tempo e vontade durante a semana."'),
    ('seed_produtividade_medio_v6', 'Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 0, 'Evitar qualquer alteração na rotina', 'Comparar tarefas com as de outras pessoas e evitar alterações na rotina'),
    ('seed_produtividade_medio_v6', 'Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 1, 'Aumentar obrigatoriamente a carga horária', 'Comparar horários com o tempo real e aumentar obrigatoriamente a carga horária'),
    ('seed_produtividade_medio_v6', 'Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 2, 'Eliminar todas as tarefas', 'Comparar tarefas com as metas e eliminar as que demoram mais tempo'),
    ('seed_produtividade_medio_v6', 'O que é uma tarefa de baixa prioridade?', 0, 'Uma tarefa que nunca deve ser concluída', 'Uma atividade cujo impacto é tão pequeno que só deve ser feita se sobrar tempo'),
    ('seed_produtividade_medio_v6', 'O que é uma tarefa de baixa prioridade?', 1, 'Uma tarefa necessariamente inútil', 'Uma atividade cujo impacto é nulo e que se torna inútil para a pessoa e para toda a equipa'),
    ('seed_produtividade_medio_v6', 'O que é uma tarefa de baixa prioridade?', 3, 'Uma tarefa sempre difícil', 'Uma atividade cuja dificuldade é maior em comparação com outras responsabilidades'),
    ('seed_produtividade_medio_v6', 'O que é uma lista "Não Fazer" (Not-to-do list)?', 1, 'Uma lista de tarefas urgentes', 'Uma lista de tarefas ou atividades que devem ser feitas com urgência para cumprir prazos'),
    ('seed_produtividade_medio_v6', 'O que é uma lista "Não Fazer" (Not-to-do list)?', 2, 'Uma lista de objetivos financeiros', 'Uma lista de objetivos ou metas que devem ser alcançados para melhorar as finanças'),
    ('seed_produtividade_medio_v6', 'O que é uma lista "Não Fazer" (Not-to-do list)?', 3, 'Uma agenda de reuniões', 'Uma agenda de reuniões ou compromissos que devem ser confirmados com antecedência'),
    ('seed_produtividade_medio_v6', 'Qual comportamento é mais compatível com uma sessão de deep work?', 1, 'Responder mensagens a cada minuto', 'Responder mensagens a cada minuto durante uma tarefa importante'),
    ('seed_produtividade_medio_v6', 'Qual comportamento é mais compatível com uma sessão de deep work?', 2, 'Participar de várias conversas simultaneamente', 'Participar de várias conversas enquanto trabalha numa tarefa importante'),
    ('seed_produtividade_medio_v6', 'Qual é a vantagem de possuir um plano alternativo?', 0, 'Aumenta obrigatoriamente a quantidade de trabalho', 'Permite aumentar a quantidade de trabalho quando o plano principal pode ser executado'),
    ('seed_produtividade_medio_v6', 'Qual é a vantagem de possuir um plano alternativo?', 1, 'Elimina todas as prioridades', 'Permite eliminar prioridades quando o plano principal não é importante'),
    ('seed_produtividade_medio_v6', 'Qual é a vantagem de possuir um plano alternativo?', 2, 'Garante que imprevistos nunca acontecerão', 'Permite evitar imprevistos quando o plano principal pode ser bem executado'),
    ('seed_produtividade_medio_v6', 'O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 1, 'A produtividade aumenta automaticamente', 'Pode aumentar a produtividade, a motivação e a satisfação com o trabalho'),
    ('seed_produtividade_medio_v6', 'O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 2, 'O tempo disponível aumenta', 'Pode aumentar o tempo disponível, a energia e a capacidade de concentração'),
    ('seed_produtividade_medio_v6', 'O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 3, 'Todas as tarefas tornam-se mais fáceis', 'Reduz as dificuldades, os atrasos e o esforço necessário nas tarefas'),
    ('seed_produtividade_medio_v6', 'O que é uma estimativa de tempo?', 0, 'Definição da prioridade de uma tarefa', 'Definição de qual prioridade uma tarefa poderá receber na lista'),
    ('seed_produtividade_medio_v6', 'O que é uma estimativa de tempo?', 1, 'Lista de pessoas envolvidas', 'Lista de quantas pessoas uma atividade poderá envolver na equipa'),
    ('seed_produtividade_medio_v6', 'O que é uma estimativa de tempo?', 3, 'Registro do tempo já utilizado', 'Registro do tempo que uma atividade já utilizou até agora'),
    ('seed_produtividade_medio_v6', 'O que é uma retrospectiva pessoal?', 0, 'Uma previsão do futuro sem dados', 'Uma previsão do que acontecerá, sem dados nem análise do que pode mudar'),
    ('seed_produtividade_medio_v6', 'O que é uma retrospectiva pessoal?', 1, 'Uma técnica para evitar feedback', 'Uma técnica para evitar feedback, mesmo quando pode ajudar a melhorar o trabalho'),
    ('seed_produtividade_medio_v6', 'O que é uma retrospectiva pessoal?', 2, 'Uma lista de tarefas urgentes', 'Uma lista de tarefas urgentes, do que falta e do que pode ser adiado'),
    ('seed_produtividade_medio_v6', 'O que é um checklist?', 1, 'Uma lista exclusivamente de objetivos anuais', 'Uma lista de objetivos anuais que devem ser alcançados'),
    ('seed_produtividade_medio_v6', 'O que é um checklist?', 2, 'Um relatório financeiro', 'Um relatório financeiro com itens que devem ser aprovados pelo gestor'),
    ('seed_produtividade_medio_v6', 'O que é um checklist?', 3, 'Um calendário de feriados', 'Um calendário de feriados e datas que devem ser respeitadas por todos'),
    ('seed_produtividade_medio_v6', 'Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 1, 'Preencher o maior número possível de horários', 'Garantir que o maior número possível de horários fique preenchido'),
    ('seed_produtividade_medio_v6', 'Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 2, 'Evitar qualquer planejamento', 'Garantir que o planejamento seja evitado até o fim do dia'),
    ('seed_produtividade_medio_v6', 'Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 3, 'Escolher sempre a tarefa mais fácil', 'Garantir que a tarefa mais fácil receba atenção antes das demais'),
    ('seed_produtividade_medio_v6', 'Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 0, 'Faz todas as tarefas terem a mesma prioridade', 'Permite que todas as tarefas tenham a mesma prioridade e o mesmo tempo'),
    ('seed_produtividade_medio_v6', 'Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 1, 'Impede a realização de tarefas simples', 'Permite impedir a realização de tarefas simples e rápidas durante todo o dia de trabalho'),
    ('seed_produtividade_medio_v6', 'Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 3, 'Elimina tarefas administrativas', 'Permite eliminar tarefas administrativas de maior exigência da rotina'),
    ('seed_produtividade_medio_v6', 'Por que as estimativas de tempo podem apresentar erros?', 0, 'Porque todas as tarefas são imprevisíveis', 'Porque as tarefas podem ser imprevisíveis, urgentes e impossíveis de estimar'),
    ('seed_produtividade_medio_v6', 'Por que as estimativas de tempo podem apresentar erros?', 1, 'Porque o tempo nunca pode ser medido', 'Porque o tempo pode ser medido, mas apenas por quem usa relógios digitais'),
    ('seed_produtividade_medio_v6', 'Por que as estimativas de tempo podem apresentar erros?', 2, 'Porque os relógios não são confiáveis', 'Porque os relógios podem atrasar, adiantar e falhar durante o trabalho'),
    ('seed_produtividade_medio_v6', 'O que é planejamento por cenários?', 0, 'Evitar estabelecer objetivos', 'Considerar os cenários mais favoráveis, para preparar respostas a mudanças ou imprevistos'),
    ('seed_produtividade_medio_v6', 'O que é planejamento por cenários?', 2, 'Fazer apenas um plano rígido', 'Fazer apenas um plano detalhado para preparar a equipa e evitar mudanças'),
    ('seed_produtividade_medio_v6', 'O que é planejamento por cenários?', 3, 'Ignorar riscos', 'Ignorar riscos pouco prováveis para preparar respostas rápidas a imprevistos'),
    ('seed_produtividade_medio_v6', 'O que é feedback no contexto da produtividade?', 0, 'Uma interrupção aleatória', 'Informação sobre o horário que pode ser usada para marcar reuniões futuras'),
    ('seed_produtividade_medio_v6', 'O que é feedback no contexto da produtividade?', 2, 'Uma tarefa concluída', 'Uma tarefa concluída que pode ser usada como modelo para ações futuras'),
    ('seed_produtividade_medio_v6', 'O que é feedback no contexto da produtividade?', 3, 'Uma recompensa financeira obrigatória', 'Uma recompensa financeira que pode ser exigida após cada ação concluída'),
    ('seed_produtividade_medio_v6', 'Qual exemplo reduz o atrito para estudar?', 1, 'Manter várias distrações abertas', 'Manter várias distrações abertas perto do local de estudo'),
    ('seed_produtividade_medio_v6', 'Qual exemplo reduz o atrito para estudar?', 2, 'Alterar constantemente o local de estudo', 'Alterar constantemente o local e o horário de estudo'),
    ('seed_produtividade_medio_v6', 'Qual exemplo reduz o atrito para estudar?', 3, 'Procurar os materiais somente quando começar', 'Procurar os materiais necessários somente quando começar')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade médio lote 5: % alternativa(s) errada(s) atualizada(s) (esperado: 74).', v_updated;
END $$;
