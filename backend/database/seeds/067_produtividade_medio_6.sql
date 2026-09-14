-- Seed de conteúdo real: 48 perguntas — Produtividade — Médio (lote 6)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/067_produtividade_medio_6.sql
--
-- ORIGEM: continuação (questões 51-100) do mesmo documento cujas questões
-- 1-50 formaram 052_produtividade_medio_3.sql — nível Médio confirmado
-- diretamente com o proprietário do projeto para aquele lote. Processado em
-- outra ramificação do projeto, com o `source` original
-- 'seed_produtividade_medio_v4' — que já colide com o v4 desta árvore
-- (arquivo 058, conteúdo diferente). Renomeado para v6 (próxima versão
-- livre; v5 já usada no arquivo 060).
--
-- DEDUPLICAÇÃO: das 50 perguntas originais do lote, 2 já tinham sido
-- descartadas na ramificação de origem (contra o lote 052 recém-inserido
-- naquele momento: "O que é intenção de implementação?" e "O que é uma
-- tarefa recorrente?"). Reconferidas as 48 restantes contra TODO o banco
-- desta árvore (1.614 perguntas, incluindo lotes que a ramificação de
-- origem nunca viu) — zero novas duplicatas encontradas. Todas as 48 são
-- inéditas nesta árvore.
--
-- CORREÇÃO DE QUALIDADE: este lote veio quase todo em "A" (48 A, 2 B) na
-- fonte original. A posição da alternativa correta (preservando o texto e a
-- letra corretos do documento original) foi redistribuída com seed
-- reprodutível própria da ramificação de origem, resultando em distribuição
-- perfeitamente equilibrada (12/12/12/12 entre A/B/C/D). A ordem das
-- alternativas abaixo é herdada exatamente como recebida.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v6') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_medio_v6) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_produtividade_medio6 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v6'
    FROM (VALUES
      ('Qual é a principal finalidade de definir uma prioridade máxima para o dia?'),
      ('O que significa "tempo de trabalho profundo" (deep work)?'),
      ('Qual comportamento é mais compatível com uma sessão de deep work?'),
      ('O que é trabalho superficial (shallow work)?'),
      ('Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?'),
      ('O que é uma interrupção autoinduzida?'),
      ('Qual estratégia ajuda a reduzir interrupções autoinduzidas?'),
      ('O que significa "custo de oportunidade" na gestão do tempo?'),
      ('Por que o custo de oportunidade é relevante para a produtividade?'),
      ('O que é capacidade de trabalho?'),
      ('O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?'),
      ('O que é planejamento baseado em capacidade?'),
      ('Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?'),
      ('O que é uma estimativa de tempo?'),
      ('Por que as estimativas de tempo podem apresentar erros?'),
      ('O que é planejamento por cenários?'),
      ('Qual é a vantagem de possuir um plano alternativo?'),
      ('O que significa buffer de tempo?'),
      ('Por que deixar espaços vazios na agenda pode ser produtivo?'),
      ('O que é planejamento rígido?'),
      ('Qual é o risco de um planejamento excessivamente rígido?'),
      ('O que é uma prioridade estratégica?'),
      ('Qual é a diferença entre urgência e importância?'),
      ('Uma tarefa pode ser urgente, mas pouco importante?'),
      ('O que é uma tarefa de baixa prioridade?'),
      ('O que é uma lista "Não Fazer" (Not-to-do list)?'),
      ('Qual é a principal utilidade de uma Not-to-do list?'),
      ('O que significa reduzir o atrito de uma tarefa?'),
      ('Qual exemplo reduz o atrito para estudar?'),
      ('O que significa aumentar o atrito de um comportamento indesejado?'),
      ('Qual prática pode aumentar o atrito para evitar distrações digitais?'),
      ('Qual exemplo representa uma intenção de implementação?'),
      ('O que é uma meta de resultado?'),
      ('O que é uma meta de processo?'),
      ('Por que metas de processo podem ser úteis?'),
      ('O que é feedback no contexto da produtividade?'),
      ('Por que feedback rápido pode ser útil?'),
      ('O que é um indicador-chave de desempenho (KPI)?'),
      ('Qual característica é desejável em um KPI?'),
      ('O que é revisão de prioridades?'),
      ('Por que as prioridades devem ser revisadas periodicamente?'),
      ('Qual é uma estratégia eficiente para lidar com tarefas recorrentes?'),
      ('O que é um checklist?'),
      ('Por que checklists são úteis em tarefas repetitivas?'),
      ('O que é uma retrospectiva pessoal?'),
      ('Qual pergunta é adequada para uma retrospectiva de produtividade?'),
      ('O que significa otimizar um sistema de produtividade?'),
      ('Qual princípio melhor representa uma produtividade de alto nível?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_produtividade_medio6 q
    JOIN (VALUES
      ('Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 'Garantir que a tarefa mais relevante receba atenção antes das demais', TRUE, 0),
      ('Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 'Preencher o maior número possível de horários', FALSE, 1),
      ('Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 'Evitar qualquer planejamento', FALSE, 2),
      ('Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 'Escolher sempre a tarefa mais fácil', FALSE, 3),
      ('O que significa "tempo de trabalho profundo" (deep work)?', 'Períodos de concentração intensa em atividades cognitivamente exigentes, com poucas distrações', TRUE, 0),
      ('O que significa "tempo de trabalho profundo" (deep work)?', 'Trabalho realizado exclusivamente durante a noite', FALSE, 1),
      ('O que significa "tempo de trabalho profundo" (deep work)?', 'Períodos destinados apenas a reuniões', FALSE, 2),
      ('O que significa "tempo de trabalho profundo" (deep work)?', 'Trabalho que envolve necessariamente atividades físicas', FALSE, 3),
      ('Qual comportamento é mais compatível com uma sessão de deep work?', 'Trabalhar em uma tarefa importante com notificações reduzidas', TRUE, 0),
      ('Qual comportamento é mais compatível com uma sessão de deep work?', 'Responder mensagens a cada minuto', FALSE, 1),
      ('Qual comportamento é mais compatível com uma sessão de deep work?', 'Participar de várias conversas simultaneamente', FALSE, 2),
      ('Qual comportamento é mais compatível com uma sessão de deep work?', 'Alternar frequentemente entre redes sociais e documentos', FALSE, 3),
      ('O que é trabalho superficial (shallow work)?', 'Trabalho que não possui nenhum objetivo', FALSE, 0),
      ('O que é trabalho superficial (shallow work)?', 'Atividades geralmente menos exigentes cognitivamente e que podem ser realizadas com atenção mais fragmentada', TRUE, 1),
      ('O que é trabalho superficial (shallow work)?', 'Atividade exclusivamente acadêmica', FALSE, 2),
      ('O que é trabalho superficial (shallow work)?', 'Trabalho que exige concentração máxima durante várias horas', FALSE, 3),
      ('Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 'Faz todas as tarefas terem a mesma prioridade', FALSE, 0),
      ('Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 'Impede a realização de tarefas simples', FALSE, 1),
      ('Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 'Permite reservar períodos de maior concentração para atividades de maior exigência', TRUE, 2),
      ('Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 'Elimina tarefas administrativas', FALSE, 3),
      ('O que é uma interrupção autoinduzida?', 'Uma interrupção causada pelo próprio indivíduo, como verificar mensagens sem necessidade', TRUE, 0),
      ('O que é uma interrupção autoinduzida?', 'Uma interrupção causada por uma emergência externa', FALSE, 1),
      ('O que é uma interrupção autoinduzida?', 'Uma reunião previamente agendada', FALSE, 2),
      ('O que é uma interrupção autoinduzida?', 'Uma pausa obrigatória', FALSE, 3),
      ('Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 'Definir momentos específicos para verificar mensagens', TRUE, 0),
      ('Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 'Alternar tarefas a cada minuto', FALSE, 1),
      ('Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 'Conferir notificações continuamente', FALSE, 2),
      ('Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 'Manter o celular sempre aberto', FALSE, 3),
      ('O que significa "custo de oportunidade" na gestão do tempo?', 'Tempo necessário para iniciar o computador', FALSE, 0),
      ('O que significa "custo de oportunidade" na gestão do tempo?', 'Custo financeiro de uma tarefa', FALSE, 1),
      ('O que significa "custo de oportunidade" na gestão do tempo?', 'Tempo usado para descansar', FALSE, 2),
      ('O que significa "custo de oportunidade" na gestão do tempo?', 'Benefício potencial perdido ao escolher uma atividade em vez de outra', TRUE, 3),
      ('Por que o custo de oportunidade é relevante para a produtividade?', 'Porque transforma tarefas em despesas financeiras', FALSE, 0),
      ('Por que o custo de oportunidade é relevante para a produtividade?', 'Porque todas as tarefas possuem o mesmo valor', FALSE, 1),
      ('Por que o custo de oportunidade é relevante para a produtividade?', 'Porque cada escolha de tempo significa deixar outras atividades para depois ou não realizá-las', TRUE, 2),
      ('Por que o custo de oportunidade é relevante para a produtividade?', 'Porque elimina a necessidade de prioridades', FALSE, 3),
      ('O que é capacidade de trabalho?', 'Número máximo de tarefas que podem ser colocadas numa lista', FALSE, 0),
      ('O que é capacidade de trabalho?', 'Quantidade de horas existentes em um dia', FALSE, 1),
      ('O que é capacidade de trabalho?', 'Número de reuniões possíveis', FALSE, 2),
      ('O que é capacidade de trabalho?', 'Quantidade realista de atividades que uma pessoa consegue realizar considerando tempo, energia e recursos disponíveis', TRUE, 3),
      ('O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 'Aumenta a probabilidade de atrasos, sobrecarga e queda de qualidade', TRUE, 0),
      ('O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 'A produtividade aumenta automaticamente', FALSE, 1),
      ('O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 'O tempo disponível aumenta', FALSE, 2),
      ('O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 'Todas as tarefas tornam-se mais fáceis', FALSE, 3),
      ('O que é planejamento baseado em capacidade?', 'Trabalhar apenas quando houver urgência', FALSE, 0),
      ('O que é planejamento baseado em capacidade?', 'Planejar tarefas considerando o tempo e os recursos realmente disponíveis', TRUE, 1),
      ('O que é planejamento baseado em capacidade?', 'Escolher tarefas aleatoriamente', FALSE, 2),
      ('O que é planejamento baseado em capacidade?', 'Planejar assumindo que todos os dias possuem capacidade ilimitada', FALSE, 3),
      ('Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 'Evitar qualquer alteração na rotina', FALSE, 0),
      ('Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 'Aumentar obrigatoriamente a carga horária', FALSE, 1),
      ('Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 'Eliminar todas as tarefas', FALSE, 2),
      ('Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 'Comparar estimativas com o tempo real e melhorar futuros planejamentos', TRUE, 3),
      ('O que é uma estimativa de tempo?', 'Definição da prioridade de uma tarefa', FALSE, 0),
      ('O que é uma estimativa de tempo?', 'Lista de pessoas envolvidas', FALSE, 1),
      ('O que é uma estimativa de tempo?', 'Previsão aproximada de quanto tempo uma atividade poderá exigir', TRUE, 2),
      ('O que é uma estimativa de tempo?', 'Registro do tempo já utilizado', FALSE, 3),
      ('Por que as estimativas de tempo podem apresentar erros?', 'Porque todas as tarefas são imprevisíveis', FALSE, 0),
      ('Por que as estimativas de tempo podem apresentar erros?', 'Porque o tempo nunca pode ser medido', FALSE, 1),
      ('Por que as estimativas de tempo podem apresentar erros?', 'Porque os relógios não são confiáveis', FALSE, 2),
      ('Por que as estimativas de tempo podem apresentar erros?', 'Porque tarefas podem conter incertezas, interrupções e complexidades não previstas', TRUE, 3),
      ('O que é planejamento por cenários?', 'Evitar estabelecer objetivos', FALSE, 0),
      ('O que é planejamento por cenários?', 'Considerar diferentes possibilidades para preparar respostas adequadas a mudanças ou imprevistos', TRUE, 1),
      ('O que é planejamento por cenários?', 'Fazer apenas um plano rígido', FALSE, 2),
      ('O que é planejamento por cenários?', 'Ignorar riscos', FALSE, 3),
      ('Qual é a vantagem de possuir um plano alternativo?', 'Aumenta obrigatoriamente a quantidade de trabalho', FALSE, 0),
      ('Qual é a vantagem de possuir um plano alternativo?', 'Elimina todas as prioridades', FALSE, 1),
      ('Qual é a vantagem de possuir um plano alternativo?', 'Garante que imprevistos nunca acontecerão', FALSE, 2),
      ('Qual é a vantagem de possuir um plano alternativo?', 'Permite adaptar-se melhor quando o plano principal não pode ser executado', TRUE, 3),
      ('O que significa buffer de tempo?', 'Tempo que deve ser sempre desperdiçado', FALSE, 0),
      ('O que significa buffer de tempo?', 'Tempo adicional reservado para absorver atrasos, imprevistos ou transições', TRUE, 1),
      ('O que significa buffer de tempo?', 'Tempo dedicado exclusivamente a reuniões', FALSE, 2),
      ('O que significa buffer de tempo?', 'Tempo usado apenas para tarefas concluídas', FALSE, 3),
      ('Por que deixar espaços vazios na agenda pode ser produtivo?', 'Impede qualquer planejamento', FALSE, 0),
      ('Por que deixar espaços vazios na agenda pode ser produtivo?', 'Reduz sempre a produtividade', FALSE, 1),
      ('Por que deixar espaços vazios na agenda pode ser produtivo?', 'Cria flexibilidade para imprevistos e evita uma programação excessivamente rígida', TRUE, 2),
      ('Por que deixar espaços vazios na agenda pode ser produtivo?', 'Significa falta de objetivos', FALSE, 3),
      ('O que é planejamento rígido?', 'Um planejamento com pouca margem para alterações', TRUE, 0),
      ('O que é planejamento rígido?', 'Uma agenda completamente vazia', FALSE, 1),
      ('O que é planejamento rígido?', 'Uma lista de tarefas sem prazos', FALSE, 2),
      ('O que é planejamento rígido?', 'Um planejamento sem objetivos', FALSE, 3),
      ('Qual é o risco de um planejamento excessivamente rígido?', 'A produtividade torna-se automaticamente maior', FALSE, 0),
      ('Qual é o risco de um planejamento excessivamente rígido?', 'Pequenos imprevistos podem comprometer toda a programação', TRUE, 1),
      ('Qual é o risco de um planejamento excessivamente rígido?', 'A agenda passa a ter mais flexibilidade', FALSE, 2),
      ('Qual é o risco de um planejamento excessivamente rígido?', 'Todas as tarefas tornam-se mais fáceis', FALSE, 3),
      ('O que é uma prioridade estratégica?', 'Uma atividade necessariamente rápida', FALSE, 0),
      ('O que é uma prioridade estratégica?', 'Uma atividade diretamente relacionada a objetivos de maior importância', TRUE, 1),
      ('O que é uma prioridade estratégica?', 'Qualquer tarefa urgente', FALSE, 2),
      ('O que é uma prioridade estratégica?', 'Uma tarefa escolhida aleatoriamente', FALSE, 3),
      ('Qual é a diferença entre urgência e importância?', 'Urgência depende apenas da dificuldade', FALSE, 0),
      ('Qual é a diferença entre urgência e importância?', 'Urgência está relacionada à necessidade de ação rápida; importância está relacionada ao impacto sobre objetivos', TRUE, 1),
      ('Qual é a diferença entre urgência e importância?', 'São exatamente a mesma coisa', FALSE, 2),
      ('Qual é a diferença entre urgência e importância?', 'Importância depende apenas do prazo', FALSE, 3),
      ('Uma tarefa pode ser urgente, mas pouco importante?', 'Apenas em tarefas financeiras', FALSE, 0),
      ('Uma tarefa pode ser urgente, mas pouco importante?', 'Não, todas as tarefas urgentes são estratégicas', FALSE, 1),
      ('Uma tarefa pode ser urgente, mas pouco importante?', 'Não, urgência sempre significa importância', FALSE, 2),
      ('Uma tarefa pode ser urgente, mas pouco importante?', 'Sim, quando exige atenção rápida, mas tem pouco impacto sobre os objetivos principais', TRUE, 3),
      ('O que é uma tarefa de baixa prioridade?', 'Uma tarefa que nunca deve ser concluída', FALSE, 0),
      ('O que é uma tarefa de baixa prioridade?', 'Uma tarefa necessariamente inútil', FALSE, 1),
      ('O que é uma tarefa de baixa prioridade?', 'Uma atividade cujo impacto ou urgência é menor em comparação com outras responsabilidades', TRUE, 2),
      ('O que é uma tarefa de baixa prioridade?', 'Uma tarefa sempre difícil', FALSE, 3),
      ('O que é uma lista "Não Fazer" (Not-to-do list)?', 'Uma lista de comportamentos ou atividades que devem ser evitados para proteger o foco', TRUE, 0),
      ('O que é uma lista "Não Fazer" (Not-to-do list)?', 'Uma lista de tarefas urgentes', FALSE, 1),
      ('O que é uma lista "Não Fazer" (Not-to-do list)?', 'Uma lista de objetivos financeiros', FALSE, 2),
      ('O que é uma lista "Não Fazer" (Not-to-do list)?', 'Uma agenda de reuniões', FALSE, 3),
      ('Qual é a principal utilidade de uma Not-to-do list?', 'Aumentar o número de tarefas', FALSE, 0),
      ('Qual é a principal utilidade de uma Not-to-do list?', 'Substituir todas as metas', FALSE, 1),
      ('Qual é a principal utilidade de uma Not-to-do list?', 'Reduzir comportamentos que consomem tempo sem contribuir significativamente para os objetivos', TRUE, 2),
      ('Qual é a principal utilidade de uma Not-to-do list?', 'Eliminar períodos de descanso', FALSE, 3),
      ('O que significa reduzir o atrito de uma tarefa?', 'Adiar seu início', FALSE, 0),
      ('O que significa reduzir o atrito de uma tarefa?', 'Aumentar sua complexidade', FALSE, 1),
      ('O que significa reduzir o atrito de uma tarefa?', 'Tornar o início ou a execução da tarefa mais fácil por meio da preparação adequada', TRUE, 2),
      ('O que significa reduzir o atrito de uma tarefa?', 'Adicionar etapas desnecessárias', FALSE, 3),
      ('Qual exemplo reduz o atrito para estudar?', 'Deixar previamente organizados os materiais necessários', TRUE, 0),
      ('Qual exemplo reduz o atrito para estudar?', 'Manter várias distrações abertas', FALSE, 1),
      ('Qual exemplo reduz o atrito para estudar?', 'Alterar constantemente o local de estudo', FALSE, 2),
      ('Qual exemplo reduz o atrito para estudar?', 'Procurar os materiais somente quando começar', FALSE, 3),
      ('O que significa aumentar o atrito de um comportamento indesejado?', 'Aumentar suas recompensas', FALSE, 0),
      ('O que significa aumentar o atrito de um comportamento indesejado?', 'Colocá-lo como prioridade', FALSE, 1),
      ('O que significa aumentar o atrito de um comportamento indesejado?', 'Torná-lo automático', FALSE, 2),
      ('O que significa aumentar o atrito de um comportamento indesejado?', 'Tornar esse comportamento menos fácil ou menos acessível', TRUE, 3),
      ('Qual prática pode aumentar o atrito para evitar distrações digitais?', 'Ativar todas as notificações', FALSE, 0),
      ('Qual prática pode aumentar o atrito para evitar distrações digitais?', 'Abrir redes sociais antes de cada tarefa', FALSE, 1),
      ('Qual prática pode aumentar o atrito para evitar distrações digitais?', 'Remover atalhos de aplicativos distrativos ou desativar notificações desnecessárias', TRUE, 2),
      ('Qual prática pode aumentar o atrito para evitar distrações digitais?', 'Colocar os aplicativos na tela inicial', FALSE, 3),
      ('Qual exemplo representa uma intenção de implementação?', '"Quero estudar mais."', FALSE, 0),
      ('Qual exemplo representa uma intenção de implementação?', '"Se terminar o jantar, então estudarei durante 30 minutos."', TRUE, 1),
      ('Qual exemplo representa uma intenção de implementação?', '"Estudar é importante."', FALSE, 2),
      ('Qual exemplo representa uma intenção de implementação?', '"Talvez eu estude algum dia."', FALSE, 3),
      ('O que é uma meta de resultado?', 'Uma meta exclusivamente relacionada ao número de horas trabalhadas', FALSE, 0),
      ('O que é uma meta de resultado?', 'Uma rotina automática', FALSE, 1),
      ('O que é uma meta de resultado?', 'Uma meta focada no resultado final desejado', TRUE, 2),
      ('O que é uma meta de resultado?', 'Uma tarefa sem objetivo', FALSE, 3),
      ('O que é uma meta de processo?', 'Uma meta baseada exclusivamente em resultados financeiros', FALSE, 0),
      ('O que é uma meta de processo?', 'Uma meta baseada nas ações ou comportamentos necessários para alcançar determinado resultado', TRUE, 1),
      ('O que é uma meta de processo?', 'Uma meta sem ações concretas', FALSE, 2),
      ('O que é uma meta de processo?', 'Uma meta que não pode ser medida', FALSE, 3),
      ('Por que metas de processo podem ser úteis?', 'Porque eliminam todos os resultados', FALSE, 0),
      ('Por que metas de processo podem ser úteis?', 'Porque concentram a atenção em ações que estão sob maior controle da pessoa', TRUE, 1),
      ('Por que metas de processo podem ser úteis?', 'Porque garantem resultados independentemente das circunstâncias', FALSE, 2),
      ('Por que metas de processo podem ser úteis?', 'Porque dispensam planejamento', FALSE, 3),
      ('O que é feedback no contexto da produtividade?', 'Uma interrupção aleatória', FALSE, 0),
      ('O que é feedback no contexto da produtividade?', 'Informação sobre o desempenho que pode ser usada para ajustar ações futuras', TRUE, 1),
      ('O que é feedback no contexto da produtividade?', 'Uma tarefa concluída', FALSE, 2),
      ('O que é feedback no contexto da produtividade?', 'Uma recompensa financeira obrigatória', FALSE, 3),
      ('Por que feedback rápido pode ser útil?', 'Elimina a necessidade de aprendizagem', FALSE, 0),
      ('Por que feedback rápido pode ser útil?', 'Permite identificar erros e ajustar o comportamento mais cedo', TRUE, 1),
      ('Por que feedback rápido pode ser útil?', 'Impede qualquer mudança', FALSE, 2),
      ('Por que feedback rápido pode ser útil?', 'Garante resultados perfeitos', FALSE, 3),
      ('O que é um indicador-chave de desempenho (KPI)?', 'Uma lista de tarefas', FALSE, 0),
      ('O que é um indicador-chave de desempenho (KPI)?', 'Qualquer número registrado', FALSE, 1),
      ('O que é um indicador-chave de desempenho (KPI)?', 'Uma técnica de concentração', FALSE, 2),
      ('O que é um indicador-chave de desempenho (KPI)?', 'Uma métrica selecionada para acompanhar aspectos relevantes do desempenho em relação a objetivos', TRUE, 3),
      ('Qual característica é desejável em um KPI?', 'Não possuir relação com objetivos', FALSE, 0),
      ('Qual característica é desejável em um KPI?', 'Ser escolhido apenas por ser fácil de medir', FALSE, 1),
      ('Qual característica é desejável em um KPI?', 'Mudar diariamente sem critério', FALSE, 2),
      ('Qual característica é desejável em um KPI?', 'Estar relacionado a um objetivo relevante e ser mensurável de forma consistente', TRUE, 3),
      ('O que é revisão de prioridades?', 'Exclusão automática de todas as tarefas', FALSE, 0),
      ('O que é revisão de prioridades?', 'Aumento obrigatório da carga de trabalho', FALSE, 1),
      ('O que é revisão de prioridades?', 'Processo de verificar se as tarefas atuais continuam alinhadas aos objetivos e às circunstâncias', TRUE, 2),
      ('O que é revisão de prioridades?', 'Execução de todas as tarefas simultaneamente', FALSE, 3),
      ('Por que as prioridades devem ser revisadas periodicamente?', 'Porque todo planejamento deve ser abandonado', FALSE, 0),
      ('Por que as prioridades devem ser revisadas periodicamente?', 'Porque tarefas tornam-se automaticamente urgentes', FALSE, 1),
      ('Por que as prioridades devem ser revisadas periodicamente?', 'Porque prazos, informações, recursos e objetivos podem mudar', TRUE, 2),
      ('Por que as prioridades devem ser revisadas periodicamente?', 'Porque prioridades nunca são importantes', FALSE, 3),
      ('Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 'Fazer sempre de maneira diferente', FALSE, 0),
      ('Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 'Ignorá-las até se tornarem urgentes', FALSE, 1),
      ('Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 'Criar uma rotina, checklist ou automação quando apropriado', TRUE, 2),
      ('Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 'Replanejá-las do zero todos os dias', FALSE, 3),
      ('O que é um checklist?', 'Uma lista estruturada de itens ou etapas que devem ser verificados', TRUE, 0),
      ('O que é um checklist?', 'Uma lista exclusivamente de objetivos anuais', FALSE, 1),
      ('O que é um checklist?', 'Um relatório financeiro', FALSE, 2),
      ('O que é um checklist?', 'Um calendário de feriados', FALSE, 3),
      ('Por que checklists são úteis em tarefas repetitivas?', 'Tornam qualquer tarefa automática', FALSE, 0),
      ('Por que checklists são úteis em tarefas repetitivas?', 'Eliminam a necessidade de conhecimento', FALSE, 1),
      ('Por que checklists são úteis em tarefas repetitivas?', 'Garantem que nenhum erro ocorrerá', FALSE, 2),
      ('Por que checklists são úteis em tarefas repetitivas?', 'Reduzem a probabilidade de esquecer etapas importantes', TRUE, 3),
      ('O que é uma retrospectiva pessoal?', 'Uma previsão do futuro sem dados', FALSE, 0),
      ('O que é uma retrospectiva pessoal?', 'Uma técnica para evitar feedback', FALSE, 1),
      ('O que é uma retrospectiva pessoal?', 'Uma lista de tarefas urgentes', FALSE, 2),
      ('O que é uma retrospectiva pessoal?', 'Uma análise do que funcionou, do que não funcionou e do que pode ser melhorado', TRUE, 3),
      ('Qual pergunta é adequada para uma retrospectiva de produtividade?', '"O que posso mudar na próxima semana para trabalhar melhor?"', TRUE, 0),
      ('Qual pergunta é adequada para uma retrospectiva de produtividade?', '"Como posso eliminar todos os períodos de descanso?"', FALSE, 1),
      ('Qual pergunta é adequada para uma retrospectiva de produtividade?', '"Como posso evitar qualquer mudança?"', FALSE, 2),
      ('Qual pergunta é adequada para uma retrospectiva de produtividade?', '"Como posso preencher mais horários?"', FALSE, 3),
      ('O que significa otimizar um sistema de produtividade?', 'Eliminar todo planejamento', FALSE, 0),
      ('O que significa otimizar um sistema de produtividade?', 'Trabalhar mais horas em qualquer circunstância', FALSE, 1),
      ('O que significa otimizar um sistema de produtividade?', 'Fazer mais tarefas independentemente do resultado', FALSE, 2),
      ('O que significa otimizar um sistema de produtividade?', 'Ajustar métodos e processos para melhorar resultados, eficiência e sustentabilidade', TRUE, 3),
      ('Qual princípio melhor representa uma produtividade de alto nível?', 'Concentrar recursos nas atividades certas, executar com eficiência e revisar continuamente o sistema', TRUE, 0),
      ('Qual princípio melhor representa uma produtividade de alto nível?', 'Evitar mudanças na rotina', FALSE, 1),
      ('Qual princípio melhor representa uma produtividade de alto nível?', 'Manter-se ocupado durante todo o dia', FALSE, 2),
      ('Qual princípio melhor representa uma produtividade de alto nível?', 'Fazer mais coisas a qualquer custo', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_produtividade_medio6;

    RAISE NOTICE '48 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_medio_v6).';
  END IF;
END $$;

COMMIT;
