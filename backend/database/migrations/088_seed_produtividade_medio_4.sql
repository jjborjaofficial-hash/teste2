-- Seed de conteúdo real: 20 pergunta(s) — Produtividade — Médio (lote 4, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/058_produtividade_medio_4.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original tinha 22 perguntas; 2 já existiam (texto idêntico) no seed 013 — removidas deste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (96 — distinta das seeds 42 a 94 já usadas) e distribuição
-- controlada entre A/B/C/D, reprodutível — conteúdo pedagógico inalterado, só
-- a ORDEM de exibição mudou.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_medio_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_medio_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_medio_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_produtividade_medio_v4'
    FROM (VALUES
      ('Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?'),
      ('Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:'),
      ('Qual é o principal objetivo de uma matriz de prioridades?'),
      ('Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?'),
      ('Qual pode ser a vantagem de agrupar tarefas semelhantes?'),
      ('O que é mudança de contexto no trabalho?'),
      ('Por que mudanças constantes de contexto podem prejudicar a produtividade?'),
      ('O que significa estimar a duração de uma tarefa?'),
      ('Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?'),
      ('O que é uma margem de segurança no planejamento do tempo?'),
      ('Por que evitar preencher cada minuto do dia pode ser útil?'),
      ('O que significa dizer "não" a uma tarefa que não é prioritária?'),
      ('Qual é uma característica de uma reunião produtiva?'),
      ('Por que uma agenda de reunião pode aumentar a produtividade?'),
      ('O que é uma interrupção planejada?'),
      ('Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?'),
      ('O que significa revisar prioridades?'),
      ('Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?'),
      ('O que é uma estimativa de esforço?'),
      ('Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_medio_v4 q
    JOIN (VALUES
      ('Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 'Começar pela tarefa mais fácil', FALSE, 0),
      ('Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 'Escolher aleatoriamente', FALSE, 1),
      ('Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 'Adiar ambas', FALSE, 2),
      ('Uma pessoa tem cinco tarefas, mas duas possuem prazo para hoje e impacto elevado. Qual abordagem é mais adequada?', 'Priorizar as tarefas urgentes e importantes', TRUE, 3),
      ('Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:', 'Time blocking', TRUE, 0),
      ('Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:', 'Delegação', FALSE, 1),
      ('Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:', 'Procrastinação', FALSE, 2),
      ('Uma pessoa reserva das 14h às 15h exclusivamente para estudar. Isso é um exemplo de:', 'Multitarefa', FALSE, 3),
      ('Qual é o principal objetivo de uma matriz de prioridades?', 'Eliminar todas as tarefas', FALSE, 0),
      ('Qual é o principal objetivo de uma matriz de prioridades?', 'Classificar atividades segundo critérios como importância e urgência', TRUE, 1),
      ('Qual é o principal objetivo de uma matriz de prioridades?', 'Aumentar o número de reuniões', FALSE, 2),
      ('Qual é o principal objetivo de uma matriz de prioridades?', 'Substituir todos os calendários', FALSE, 3),
      ('Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 'Planejá-la antes que se torne urgente', TRUE, 0),
      ('Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 'Ignorá-la permanentemente', FALSE, 1),
      ('Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 'Fazê-la apenas depois de perder o prazo', FALSE, 2),
      ('Uma tarefa é importante, mas não é urgente. O que geralmente é recomendável?', 'Eliminá-la automaticamente', FALSE, 3),
      ('Qual pode ser a vantagem de agrupar tarefas semelhantes?', 'Garante que nenhuma tarefa será concluída', FALSE, 0),
      ('Qual pode ser a vantagem de agrupar tarefas semelhantes?', 'Aumenta obrigatoriamente as interrupções', FALSE, 1),
      ('Qual pode ser a vantagem de agrupar tarefas semelhantes?', 'Elimina todos os prazos', FALSE, 2),
      ('Qual pode ser a vantagem de agrupar tarefas semelhantes?', 'Pode reduzir mudanças frequentes de contexto', TRUE, 3),
      ('O que é mudança de contexto no trabalho?', 'Trabalhar sempre na mesma atividade', FALSE, 0),
      ('O que é mudança de contexto no trabalho?', 'Passar repetidamente de uma atividade ou tipo de tarefa para outro', TRUE, 1),
      ('O que é mudança de contexto no trabalho?', 'Organizar documentos', FALSE, 2),
      ('O que é mudança de contexto no trabalho?', 'Definir uma meta', FALSE, 3),
      ('Por que mudanças constantes de contexto podem prejudicar a produtividade?', 'Tornam a concentração automaticamente maior', FALSE, 0),
      ('Por que mudanças constantes de contexto podem prejudicar a produtividade?', 'Eliminam todas as distrações', FALSE, 1),
      ('Por que mudanças constantes de contexto podem prejudicar a produtividade?', 'Podem exigir tempo e esforço mental para retomar cada atividade', TRUE, 2),
      ('Por que mudanças constantes de contexto podem prejudicar a produtividade?', 'Reduzem sempre a quantidade de trabalho', FALSE, 3),
      ('O que significa estimar a duração de uma tarefa?', 'Definir obrigatoriamente o resultado', FALSE, 0),
      ('O que significa estimar a duração de uma tarefa?', 'Eliminar o prazo', FALSE, 1),
      ('O que significa estimar a duração de uma tarefa?', 'Prever aproximadamente quanto tempo ela poderá exigir', TRUE, 2),
      ('O que significa estimar a duração de uma tarefa?', 'Ignorar experiências anteriores', FALSE, 3),
      ('Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 'O calendário pode ficar sobrecarregado', TRUE, 0),
      ('Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 'Todas as tarefas serão concluídas mais cedo', FALSE, 1),
      ('Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 'A quantidade de trabalho desaparecerá', FALSE, 2),
      ('Uma pessoa subestima constantemente o tempo das tarefas. Qual consequência pode ocorrer?', 'Os prazos deixarão de existir', FALSE, 3),
      ('O que é uma margem de segurança no planejamento do tempo?', 'Tempo eliminado do calendário', FALSE, 0),
      ('O que é uma margem de segurança no planejamento do tempo?', 'Tempo destinado exclusivamente a distrações', FALSE, 1),
      ('O que é uma margem de segurança no planejamento do tempo?', 'Tempo adicional reservado para imprevistos ou atrasos', TRUE, 2),
      ('O que é uma margem de segurança no planejamento do tempo?', 'Tempo que nunca pode ser utilizado', FALSE, 3),
      ('Por que evitar preencher cada minuto do dia pode ser útil?', 'Impede qualquer produtividade', FALSE, 0),
      ('Por que evitar preencher cada minuto do dia pode ser útil?', 'Garante mais atrasos', FALSE, 1),
      ('Por que evitar preencher cada minuto do dia pode ser útil?', 'Elimina prioridades', FALSE, 2),
      ('Por que evitar preencher cada minuto do dia pode ser útil?', 'Permite lidar melhor com imprevistos', TRUE, 3),
      ('O que significa dizer "não" a uma tarefa que não é prioritária?', 'Proteger tempo e atenção para atividades mais importantes', TRUE, 0),
      ('O que significa dizer "não" a uma tarefa que não é prioritária?', 'Recusar sempre qualquer responsabilidade', FALSE, 1),
      ('O que significa dizer "não" a uma tarefa que não é prioritária?', 'Evitar todo trabalho', FALSE, 2),
      ('O que significa dizer "não" a uma tarefa que não é prioritária?', 'Cancelar todos os objetivos', FALSE, 3),
      ('Qual é uma característica de uma reunião produtiva?', 'Não possui finalidade', FALSE, 0),
      ('Qual é uma característica de uma reunião produtiva?', 'Possui objetivo e pauta claros', TRUE, 1),
      ('Qual é uma característica de uma reunião produtiva?', 'Não possui participantes definidos', FALSE, 2),
      ('Qual é uma característica de uma reunião produtiva?', 'Dura obrigatoriamente várias horas', FALSE, 3),
      ('Por que uma agenda de reunião pode aumentar a produtividade?', 'Impede qualquer participação', FALSE, 0),
      ('Por que uma agenda de reunião pode aumentar a produtividade?', 'Ajuda a manter a discussão focada nos assuntos previstos', TRUE, 1),
      ('Por que uma agenda de reunião pode aumentar a produtividade?', 'Elimina todas as decisões', FALSE, 2),
      ('Por que uma agenda de reunião pode aumentar a produtividade?', 'Obriga todos a falar durante o mesmo tempo', FALSE, 3),
      ('O que é uma interrupção planejada?', 'Uma distração inesperada', FALSE, 0),
      ('O que é uma interrupção planejada?', 'Uma pausa ou mudança de atividade definida antecipadamente', TRUE, 1),
      ('O que é uma interrupção planejada?', 'Um erro de comunicação', FALSE, 2),
      ('O que é uma interrupção planejada?', 'Uma tarefa esquecida', FALSE, 3),
      ('Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 'Iniciar ainda mais tarefas', FALSE, 0),
      ('Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 'Evitar qualquer prazo', FALSE, 1),
      ('Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 'Trabalhar sem lista', FALSE, 2),
      ('Qual estratégia pode ajudar alguém que costuma começar muitas tarefas e terminar poucas?', 'Limitar o número de tarefas simultâneas e definir prioridades', TRUE, 3),
      ('O que significa revisar prioridades?', 'Manter todas as prioridades iguais para sempre', FALSE, 0),
      ('O que significa revisar prioridades?', 'Apagar todas as tarefas', FALSE, 1),
      ('O que significa revisar prioridades?', 'Reavaliar quais tarefas merecem atenção com base nas circunstâncias atuais', TRUE, 2),
      ('O que significa revisar prioridades?', 'Evitar qualquer alteração no planejamento', FALSE, 3),
      ('Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 'Reavaliar sua prioridade', TRUE, 0),
      ('Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 'Mantê-la obrigatoriamente no topo', FALSE, 1),
      ('Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 'Ignorar a mudança', FALSE, 2),
      ('Uma tarefa inicialmente prioritária deixou de ser relevante devido a uma mudança no projeto. O que fazer?', 'Duplicar a tarefa', FALSE, 3),
      ('O que é uma estimativa de esforço?', 'Uma garantia de que não haverá dificuldades', FALSE, 0),
      ('O que é uma estimativa de esforço?', 'Uma forma de eliminar tarefas', FALSE, 1),
      ('O que é uma estimativa de esforço?', 'Uma avaliação aproximada da quantidade de trabalho necessária para concluir uma atividade', TRUE, 2),
      ('O que é uma estimativa de esforço?', 'Uma previsão do salário', FALSE, 3),
      ('Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 'Garante que todas as tarefas serão mais rápidas', FALSE, 0),
      ('Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 'Elimina a necessidade de planeamento', FALSE, 1),
      ('Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 'Impede a aprendizagem com experiências anteriores', FALSE, 2),
      ('Por que comparar o tempo estimado com o tempo realmente gasto pode ser útil?', 'Ajuda a melhorar futuras estimativas e planejamento', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_medio_v4;

    RAISE NOTICE '20 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_medio_v4).';
  END IF;
END $$;

COMMIT;