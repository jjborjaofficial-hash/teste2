-- Ajuste de alternativas (BE-003, resíduo de pistas) — Produtividade: 56 alternativas erradas reescritas em 27 perguntas que só tinham avisos de pista.
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é ajustado (comprimento/palavras).
-- O nome `*_ajuste_alternativas_*` diz ao teste dos lotes que este texto substitui o do lote.
-- Segurança: só altera question_alternatives.label, só de erradas (is_correct = FALSE), e só se o texto atual ainda for exatamente
-- o original (idempotente; nunca sobrescreve edição posterior). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 0, 'Fazer de maneira diferente a cada vez, para evitar o tédio da repetição', 'Mudar o método a cada vez, só para evitar o tédio'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 1, 'Ignorá-las até se tornarem urgentes', 'Adiá-las até ficarem urgentes, sem as registar'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 3, 'Replanejá-las do zero a cada dia, sem usar modelos anteriores', 'Replanejá-las do zero a cada dia, sem usar modelos'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 0, 'Registar no final do dia tudo o que foi feito e o que ficou por fazer', 'Registar no fim do dia o que foi feito e o que falta'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 2, 'Decidir as atividades à medida que surgem', 'Decidir as atividades uma a uma à medida que surgem'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 3, 'Reservar o dia todo para uma só atividade', 'Reservar o dia todo para uma só atividade principal'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 0, 'A produtividade torna-se maior porque há menos decisões a tomar', 'A produtividade pode aumentar porque há menos decisões a tomar'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 3, 'As tarefas tornam-se mais fáceis porque a rotina fica fixa', 'As tarefas podem tornar-se mais fáceis porque a rotina fica fixa'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 0, 'Manter as notificações ativas no telemóvel', 'Manter notificações sonoras ligadas'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 1, 'Verificar o telefone a cada minuto', 'Verificar mensagens constantemente'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 2, 'Abrir várias redes sociais ao mesmo tempo', 'Abrir várias redes sociais'),
    ('seed_produtividade_dificil_v2', 'Qual é uma consequência direta de requisitos pouco claros?', 3, 'Menor necessidade de comunicação entre os membros da equipa', 'Menor necessidade de comunicação na equipa'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 0, 'Elimina os erros de cálculo', 'Elimina erros de cálculo'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 1, 'Dispensa o planejamento diário', 'Dispensa o planejamento'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 3, 'Aumenta o salário no fim do mês', 'Aumenta o salário mensal'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 1, 'Porque tarefas simples exigem mais concentração do que as complexas', 'Porque tarefas simples podem exigir mais concentração do que as complexas'),
    ('seed_produtividade_medio_v3', 'Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?', 2, 'Porque tarefas difíceis devem ser feitas quando há menos pressão', 'Porque tarefas difíceis podem ser feitas quando há menos pressão'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 0, 'Técnica de vendas usada para fechar negócios com clientes', 'Técnica de vendas, usada para fechar negócios'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 1, 'Meta financeira definida para o fim de cada período do ano', 'Meta financeira, definida para o fim do ano'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 2, 'Lista de compras mensal', 'Lista de compras, ordenada por mês e preço'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 0, 'Porque reduz o tempo de planejamento, mas aumenta o número de tarefas concluídas', 'Porque pode reduzir o tempo de planejamento, mas aumenta o número de tarefas concluídas'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 1, 'Porque reduz a quantidade de reuniões, mas aumenta o tempo gasto com e-mails', 'Porque reduz a quantidade de reuniões, mas pode aumentar o tempo gasto com e-mails'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 0, 'Porque os planos devem ser abandonados quando surgem críticas', 'Porque os planos podem ser abandonados quando surgem críticas'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 1, 'Porque os dados do plano deixam de ser úteis depois de aprovados', 'Porque os dados do plano podem deixar de ser úteis depois de aprovados'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 0, 'Evitar definir prazos e prioridades para as tarefas', 'Evitar definir prazos e prioridades, deixando tudo em aberto'),
    ('seed_produtividade_facil_v7', 'Qual atitude contribui para uma melhor gestão das tarefas?', 2, 'Começar várias tarefas ao mesmo tempo e depois escolher', 'Começar várias tarefas ao mesmo tempo, depois escolher'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 0, 'Método de controle financeiro em que 80% do orçamento deve ser destinado às despesas fixas e 20% às despesas variáveis de cada mês', 'Método de controle financeiro em que 80% do orçamento costuma ser destinado às despesas fixas e 20% às despesas variáveis de cada mês'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 1, 'Regra de que 80% do tempo de trabalho deve ser dedicado a reuniões e 20% à execução das tarefas planejadas pela equipe', 'Regra de que 80% do tempo de trabalho pode ser dedicado a reuniões e 20% à execução das tarefas planejadas pela equipe'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 0, 'Fazer duas coisas juntas', 'Acumular tarefas'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 1, 'Escolher as tarefas mais fáceis', 'Escolher tarefas fáceis'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 2, 'Mais tarefas e mais reuniões de planeamento', 'Mais tarefas, reuniões e planeamento'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 3, 'Menos informação e menos detalhe nos planos', 'Menos informação, menos detalhe nos planos'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 0, 'Prazos mais longos aumentam a produtividade porque dão mais tempo para revisar o trabalho', 'Prazos mais longos podem aumentar a produtividade porque dão mais tempo para revisar o trabalho'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 1, 'Quanto maior for o prazo, menor é a necessidade de planejar as etapas do projeto', 'Quanto maior for o prazo, menor pode ser a necessidade de planejar as etapas do projeto'),
    ('seed_produtividade_medio_v6', 'Qual pergunta é adequada para uma retrospectiva de produtividade?', 2, '"Como posso evitar mudanças no meu sistema?"', '"Que mudanças no meu sistema posso evitar?"'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 1, 'Aumentar a carga horária da semana para recuperar o trabalho em atraso acumulado', 'Aumentar a carga horária da semana, para recuperar o atraso acumulado'),
    ('seed_produtividade_medio_v3', 'Qual é uma finalidade da revisão semanal?', 2, 'Trabalhar a semana seguinte sem ter prioridades definidas à partida', 'Trabalhar a semana seguinte, sem ter prioridades definidas à partida'),
    ('seed_produtividade_dificil_v2', 'Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?', 0, 'Ignorar o processo atual e começar a automatizar as etapas mais lentas', 'Ignorar o processo atual, começar a automatizar as etapas mais lentas'),
    ('seed_produtividade_dificil_v2', 'Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?', 1, 'Automatizar o processo já existente e medir os resultados só depois', 'Automatizar o processo existente, medir os resultados só depois'),
    ('seed_produtividade_dificil_v2', 'O que significa limitar o trabalho em andamento?', 0, 'Aumentar o número de prioridades definidas para a equipa', 'Aumentar o número de prioridades que a equipa pode definir'),
    ('seed_produtividade_dificil_v2', 'O que significa limitar o trabalho em andamento?', 1, 'Trabalhar numa só tarefa até ao fim do dia de trabalho', 'Trabalhar numa só tarefa, se possível, até ao fim do dia'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 0, 'Guardar todos os dados num só ficheiro, sem separação por tema', 'Guardar os dados num ficheiro sem separação por tema'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 2, 'Reunir o maior número possível de dados antes de qualquer decisão', 'Reunir o maior número possível de dados antes de decidir'),
    ('seed_produtividade_dificil_v1', 'Como o efeito Zeigarnik pode afetar a produtividade?', 1, 'Tarefas pendentes deixam de ser lembradas depois de algumas horas', 'As tarefas pendentes deixam de ser lembradas depois de algumas horas'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 1, 'Realizar todas as tarefas ao mesmo tempo', 'Realizar várias tarefas ao mesmo tempo'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 2, 'Dividir o tempo disponível igualmente entre todas as tarefas', 'Dividir o tempo em partes iguais entre tarefas'),
    ('seed_produtividade_dificil_v1', 'O que é trabalho profundo?', 1, 'Trabalho de rotina feito em ritmo constante, com tarefas simples e repetitivas, que exigem pouca decisão', 'Rotina de tarefas simples e repetitivas, feita em ritmo constante, com pouca decisão'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 0, 'Uma atividade que deve ser deixada por último por ter pouca contribuição', 'Uma atividade que pode ser deixada por último por ter pouca contribuição'),
    ('seed_produtividade_medio_v3', 'O que é uma tarefa de alto impacto?', 3, 'Uma tarefa difícil de executar, que exige muita competência técnica', 'Uma tarefa difícil de executar, que pode exigir muita competência técnica'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 1, 'Controle dos salários e dos benefícios pagos à equipe de trabalho em cada período do ano', 'Controle dos salários e dos benefícios que podem ser pagos à equipe em cada período do ano'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 2, 'Definição das senhas e dos acessos de cada membro da equipe aos sistemas e às ferramentas da empresa', 'Definição das senhas e dos acessos que cada membro pode ter aos sistemas da empresa'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 0, 'Porque o planejamento deve ser abandonado quando surge uma tarefa nova', 'Porque o planejamento pode ser abandonado, quando surge uma tarefa nova'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 1, 'Porque as tarefas tornam-se urgentes com o tempo', 'Porque as tarefas podem tornar-se urgentes, com o tempo'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 3, 'Porque as prioridades perdem importância com o passar das semanas', 'Porque as prioridades podem perder importância, com o passar das semanas'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 1, 'Descansar a mente antes de qualquer atividade', 'Descansar a mente antes do trabalho'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 3, 'Memorizar todos os detalhes de uma atividade', 'Memorizar os detalhes de uma atividade')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Produtividade (pistas): % alternativa(s) errada(s) atualizada(s) (esperado: 56).', v_updated;
END $$;
