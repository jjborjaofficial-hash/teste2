-- Seed de conteúdo real: 42 pergunta(s) — Produtividade — Fácil (lote 4, deduplicado)
-- NÃO é uma migration — script de seed, idempotente via coluna `source`
-- (migration 022). Rodar manualmente: psql $DATABASE_URL -f database/seeds/057_produtividade_facil_4.sql
--
-- DEDUPLICAÇÃO APLICADA: o lote original tinha 50 perguntas; 8 já existiam (texto idêntico) nos seeds 012, 021, 013 ou 022 — removidas deste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): posição da resposta correta redistribuída com
-- seed fixa (95 — distinta das seeds 42 a 94 já usadas) e distribuição
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_q_produtividade_facil_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v4'
    FROM (VALUES
      ('O que é uma lista de tarefas?'),
      ('Qual é uma vantagem de definir prioridades?'),
      ('Por que dividir uma tarefa grande em etapas menores pode ajudar?'),
      ('Qual prática pode ajudar a reduzir a procrastinação?'),
      ('O que é um prazo?'),
      ('Qual ferramenta pode ser usada para organizar compromissos por datas?'),
      ('Qual é uma característica de uma meta clara?'),
      ('O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?'),
      ('O que é concentração?'),
      ('Qual destes pode ser uma distração durante o estudo?'),
      ('Por que organizar o espaço de trabalho pode ser útil?'),
      ('Qual é o objetivo de uma agenda?'),
      ('Por que uma rotina pode contribuir para a produtividade?'),
      ('O que significa cumprir uma tarefa?'),
      ('Qual ação ajuda a acompanhar o progresso de um projeto?'),
      ('Por que limitar interrupções durante uma tarefa importante pode ser útil?'),
      ('O que significa organizar tarefas por ordem de importância?'),
      ('Qual é uma boa prática antes de iniciar um projeto?'),
      ('O que é produtividade?'),
      ('Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?'),
      ('O que é um lembrete?'),
      ('Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?'),
      ('Qual é uma vantagem de nomear corretamente arquivos?'),
      ('O que é uma pausa?'),
      ('Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?'),
      ('O que significa revisar uma tarefa?'),
      ('Qual pode ser o benefício de revisar um documento antes de enviá-lo?'),
      ('O que é um objetivo de curto prazo?'),
      ('O que caracteriza uma tarefa urgente?'),
      ('Qual é a diferença básica entre importante e urgente?'),
      ('Por que estimar o tempo necessário para uma tarefa pode ser útil?'),
      ('O que significa cumprir uma rotina de estudos?'),
      ('Qual prática pode melhorar a organização dos estudos?'),
      ('O que significa preparar materiais antes de iniciar uma tarefa?'),
      ('Qual é uma vantagem de ter um espaço de trabalho organizado?'),
      ('Qual exemplo representa uma tarefa recorrente?'),
      ('O que significa acompanhar uma meta?'),
      ('Qual é uma vantagem de registar tarefas concluídas?'),
      ('O que é uma tarefa pendente?'),
      ('Por que é útil atualizar uma lista de tarefas?'),
      ('O que significa trabalhar de forma organizada?'),
      ('Qual atitude contribui para uma boa gestão do tempo?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_q_produtividade_facil_v4 q
    JOIN (VALUES
      ('O que é uma lista de tarefas?', 'Um relatório financeiro', FALSE, 0),
      ('O que é uma lista de tarefas?', 'Um calendário de feriados', FALSE, 1),
      ('O que é uma lista de tarefas?', 'Um arquivo de fotografias', FALSE, 2),
      ('O que é uma lista de tarefas?', 'Uma relação organizada de atividades que precisam ser realizadas', TRUE, 3),
      ('Qual é uma vantagem de definir prioridades?', 'Fazer todas as tarefas ao mesmo tempo', FALSE, 0),
      ('Qual é uma vantagem de definir prioridades?', 'Evitar qualquer planejamento', FALSE, 1),
      ('Qual é uma vantagem de definir prioridades?', 'Aumentar o número de tarefas', FALSE, 2),
      ('Qual é uma vantagem de definir prioridades?', 'Identificar o que merece atenção primeiro', TRUE, 3),
      ('Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Pode facilitar a organização e o acompanhamento do progresso', TRUE, 0),
      ('Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Torna a tarefa necessariamente mais longa', FALSE, 1),
      ('Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Elimina a necessidade de realizar a tarefa', FALSE, 2),
      ('Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Impede a conclusão do projeto', FALSE, 3),
      ('Qual prática pode ajudar a reduzir a procrastinação?', 'Adiar continuamente', FALSE, 0),
      ('Qual prática pode ajudar a reduzir a procrastinação?', 'Começar por uma pequena parte da tarefa', TRUE, 1),
      ('Qual prática pode ajudar a reduzir a procrastinação?', 'Ignorar os prazos', FALSE, 2),
      ('Qual prática pode ajudar a reduzir a procrastinação?', 'Criar mais distrações', FALSE, 3),
      ('O que é um prazo?', 'O tempo máximo ou data definida para concluir algo', TRUE, 0),
      ('O que é um prazo?', 'Uma pausa durante o trabalho', FALSE, 1),
      ('O que é um prazo?', 'Uma ferramenta de comunicação', FALSE, 2),
      ('O que é um prazo?', 'Uma categoria de documentos', FALSE, 3),
      ('Qual ferramenta pode ser usada para organizar compromissos por datas?', 'Calculadora', FALSE, 0),
      ('Qual ferramenta pode ser usada para organizar compromissos por datas?', 'Editor de imagens', FALSE, 1),
      ('Qual ferramenta pode ser usada para organizar compromissos por datas?', 'Calendário', TRUE, 2),
      ('Qual ferramenta pode ser usada para organizar compromissos por datas?', 'Reprodutor de música', FALSE, 3),
      ('Qual é uma característica de uma meta clara?', 'Não possui qualquer objetivo', FALSE, 0),
      ('Qual é uma característica de uma meta clara?', 'Indica de forma compreensível o que se pretende alcançar', TRUE, 1),
      ('Qual é uma característica de uma meta clara?', 'Não pode ser acompanhada', FALSE, 2),
      ('Qual é uma característica de uma meta clara?', 'É sempre impossível de alcançar', FALSE, 3),
      ('O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 'A qualidade aumenta sempre', FALSE, 0),
      ('O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 'Todas as tarefas ficam automaticamente concluídas', FALSE, 1),
      ('O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 'O tempo deixa de ser relevante', FALSE, 2),
      ('O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 'Pode perder concentração e cometer mais erros', TRUE, 3),
      ('O que é concentração?', 'Capacidade de manter a atenção numa atividade', TRUE, 0),
      ('O que é concentração?', 'Capacidade de fazer várias coisas sem atenção', FALSE, 1),
      ('O que é concentração?', 'Ato de interromper constantemente uma tarefa', FALSE, 2),
      ('O que é concentração?', 'Forma de evitar objetivos', FALSE, 3),
      ('Qual destes pode ser uma distração durante o estudo?', 'Um plano de estudo', FALSE, 0),
      ('Qual destes pode ser uma distração durante o estudo?', 'Um objetivo definido', FALSE, 1),
      ('Qual destes pode ser uma distração durante o estudo?', 'Uma lista de tarefas', FALSE, 2),
      ('Qual destes pode ser uma distração durante o estudo?', 'Uma notificação constante do telefone', TRUE, 3),
      ('Por que organizar o espaço de trabalho pode ser útil?', 'Elimina todas as tarefas', FALSE, 0),
      ('Por que organizar o espaço de trabalho pode ser útil?', 'Impede a concentração', FALSE, 1),
      ('Por que organizar o espaço de trabalho pode ser útil?', 'Aumenta obrigatoriamente o tempo de trabalho', FALSE, 2),
      ('Por que organizar o espaço de trabalho pode ser útil?', 'Pode facilitar o acesso aos materiais necessários', TRUE, 3),
      ('Qual é o objetivo de uma agenda?', 'Ajudar a organizar compromissos e atividades ao longo do tempo', TRUE, 0),
      ('Qual é o objetivo de uma agenda?', 'Substituir todas as ferramentas digitais', FALSE, 1),
      ('Qual é o objetivo de uma agenda?', 'Armazenar apenas fotografias', FALSE, 2),
      ('Qual é o objetivo de uma agenda?', 'Servir exclusivamente para entretenimento', FALSE, 3),
      ('Por que uma rotina pode contribuir para a produtividade?', 'Elimina automaticamente todos os problemas', FALSE, 0),
      ('Por que uma rotina pode contribuir para a produtividade?', 'Impede qualquer mudança', FALSE, 1),
      ('Por que uma rotina pode contribuir para a produtividade?', 'Pode reduzir a necessidade de decidir constantemente o que fazer', TRUE, 2),
      ('Por que uma rotina pode contribuir para a produtividade?', 'Garante que nenhuma tarefa será difícil', FALSE, 3),
      ('O que significa cumprir uma tarefa?', 'Ignorá-la', FALSE, 0),
      ('O que significa cumprir uma tarefa?', 'Adiá-la sem motivo', FALSE, 1),
      ('O que significa cumprir uma tarefa?', 'Transferi-la sempre para outra pessoa', FALSE, 2),
      ('O que significa cumprir uma tarefa?', 'Realizá-la conforme o objetivo estabelecido', TRUE, 3),
      ('Qual ação ajuda a acompanhar o progresso de um projeto?', 'Apagar os objetivos', FALSE, 0),
      ('Qual ação ajuda a acompanhar o progresso de um projeto?', 'Evitar qualquer registo', FALSE, 1),
      ('Qual ação ajuda a acompanhar o progresso de um projeto?', 'Alterar constantemente o plano sem necessidade', FALSE, 2),
      ('Qual ação ajuda a acompanhar o progresso de um projeto?', 'Marcar as etapas concluídas', TRUE, 3),
      ('Por que limitar interrupções durante uma tarefa importante pode ser útil?', 'Reduz obrigatoriamente a qualidade', FALSE, 0),
      ('Por que limitar interrupções durante uma tarefa importante pode ser útil?', 'Impede qualquer comunicação necessária', FALSE, 1),
      ('Por que limitar interrupções durante uma tarefa importante pode ser útil?', 'Pode ajudar a manter a concentração', TRUE, 2),
      ('Por que limitar interrupções durante uma tarefa importante pode ser útil?', 'Elimina os objetivos', FALSE, 3),
      ('O que significa organizar tarefas por ordem de importância?', 'Ignorar tarefas', FALSE, 0),
      ('O que significa organizar tarefas por ordem de importância?', 'Priorizar tarefas', TRUE, 1),
      ('O que significa organizar tarefas por ordem de importância?', 'Randomizar tarefas', FALSE, 2),
      ('O que significa organizar tarefas por ordem de importância?', 'Cancelar tarefas', FALSE, 3),
      ('Qual é uma boa prática antes de iniciar um projeto?', 'Começar sem saber o resultado desejado', FALSE, 0),
      ('Qual é uma boa prática antes de iniciar um projeto?', 'Definir objetivos e etapas principais', TRUE, 1),
      ('Qual é uma boa prática antes de iniciar um projeto?', 'Ignorar recursos necessários', FALSE, 2),
      ('Qual é uma boa prática antes de iniciar um projeto?', 'Evitar qualquer prazo', FALSE, 3),
      ('O que é produtividade?', 'Quantidade de horas passadas sem produzir', FALSE, 0),
      ('O que é produtividade?', 'Número de pausas realizadas', FALSE, 1),
      ('O que é produtividade?', 'Capacidade de utilizar recursos e tempo de forma eficaz para alcançar resultados', TRUE, 2),
      ('O que é produtividade?', 'Quantidade de distrações durante o trabalho', FALSE, 3),
      ('Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?', 'Distração', FALSE, 0),
      ('Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?', 'Procrastinação', FALSE, 1),
      ('Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?', 'Improvisação', FALSE, 2),
      ('Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?', 'Priorização', TRUE, 3),
      ('O que é um lembrete?', 'Uma tarefa eliminada', FALSE, 0),
      ('O que é um lembrete?', 'Um relatório financeiro', FALSE, 1),
      ('O que é um lembrete?', 'Um aviso destinado a ajudar alguém a recordar uma atividade ou compromisso', TRUE, 2),
      ('O que é um lembrete?', 'Um tipo de descanso', FALSE, 3),
      ('Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?', 'Editor de fotografias', FALSE, 0),
      ('Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?', 'Calculadora científica', FALSE, 1),
      ('Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?', 'Alarme ou lembrete', TRUE, 2),
      ('Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?', 'Leitor de música', FALSE, 3),
      ('Qual é uma vantagem de nomear corretamente arquivos?', 'Facilita a identificação e localização posterior', TRUE, 0),
      ('Qual é uma vantagem de nomear corretamente arquivos?', 'Aumenta automaticamente o espaço disponível', FALSE, 1),
      ('Qual é uma vantagem de nomear corretamente arquivos?', 'Elimina a necessidade de pastas', FALSE, 2),
      ('Qual é uma vantagem de nomear corretamente arquivos?', 'Impede o acesso aos documentos', FALSE, 3),
      ('O que é uma pausa?', 'Uma tarefa obrigatória', FALSE, 0),
      ('O que é uma pausa?', 'Um período curto de interrupção planejada de uma atividade', TRUE, 1),
      ('O que é uma pausa?', 'Uma meta', FALSE, 2),
      ('O que é uma pausa?', 'Um prazo', FALSE, 3),
      ('Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 'Podem ajudar a recuperar a atenção e reduzir a fadiga', TRUE, 0),
      ('Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 'Eliminam a necessidade de trabalhar', FALSE, 1),
      ('Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 'Garantem produtividade infinita', FALSE, 2),
      ('Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 'Tornam todas as tarefas mais difíceis', FALSE, 3),
      ('O que significa revisar uma tarefa?', 'Apagar o trabalho', FALSE, 0),
      ('O que significa revisar uma tarefa?', 'Evitar qualquer correção', FALSE, 1),
      ('O que significa revisar uma tarefa?', 'Verificar o trabalho realizado antes de considerá-lo concluído', TRUE, 2),
      ('O que significa revisar uma tarefa?', 'Começar outro projeto', FALSE, 3),
      ('Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 'Identificar possíveis erros', TRUE, 0),
      ('Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 'Aumentar os erros', FALSE, 1),
      ('Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 'Eliminar o conteúdo', FALSE, 2),
      ('Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 'Impedir a comunicação', FALSE, 3),
      ('O que é um objetivo de curto prazo?', 'Um objetivo que nunca pode ser concluído', FALSE, 0),
      ('O que é um objetivo de curto prazo?', 'Um resultado planejado para ser alcançado num período relativamente próximo', TRUE, 1),
      ('O que é um objetivo de curto prazo?', 'Uma atividade sem finalidade', FALSE, 2),
      ('O que é um objetivo de curto prazo?', 'Uma tarefa já terminada', FALSE, 3),
      ('O que caracteriza uma tarefa urgente?', 'Pode sempre esperar indefinidamente', FALSE, 0),
      ('O que caracteriza uma tarefa urgente?', 'Nunca possui prazo', FALSE, 1),
      ('O que caracteriza uma tarefa urgente?', 'Não possui qualquer consequência', FALSE, 2),
      ('O que caracteriza uma tarefa urgente?', 'Necessita de atenção em pouco tempo', TRUE, 3),
      ('Qual é a diferença básica entre importante e urgente?', 'São sempre exatamente a mesma coisa', FALSE, 0),
      ('Qual é a diferença básica entre importante e urgente?', 'Algo importante tem impacto relevante; algo urgente exige atenção rápida', TRUE, 1),
      ('Qual é a diferença básica entre importante e urgente?', 'Algo importante nunca precisa ser realizado', FALSE, 2),
      ('Qual é a diferença básica entre importante e urgente?', 'Algo urgente nunca possui prazo', FALSE, 3),
      ('Por que estimar o tempo necessário para uma tarefa pode ser útil?', 'Garante que a tarefa será fácil', FALSE, 0),
      ('Por que estimar o tempo necessário para uma tarefa pode ser útil?', 'Elimina todos os imprevistos', FALSE, 1),
      ('Por que estimar o tempo necessário para uma tarefa pode ser útil?', 'Impede qualquer alteração no plano', FALSE, 2),
      ('Por que estimar o tempo necessário para uma tarefa pode ser útil?', 'Ajuda a organizar melhor o calendário', TRUE, 3),
      ('O que significa cumprir uma rotina de estudos?', 'Estudar somente quando houver vontade', FALSE, 0),
      ('O que significa cumprir uma rotina de estudos?', 'Nunca estabelecer horários', FALSE, 1),
      ('O que significa cumprir uma rotina de estudos?', 'Seguir regularmente horários ou práticas planejadas para estudar', TRUE, 2),
      ('O que significa cumprir uma rotina de estudos?', 'Evitar revisar conteúdos', FALSE, 3),
      ('Qual prática pode melhorar a organização dos estudos?', 'Estudar todos os conteúdos ao mesmo tempo', FALSE, 0),
      ('Qual prática pode melhorar a organização dos estudos?', 'Evitar qualquer planeamento', FALSE, 1),
      ('Qual prática pode melhorar a organização dos estudos?', 'Ignorar avaliações próximas', FALSE, 2),
      ('Qual prática pode melhorar a organização dos estudos?', 'Definir horários e conteúdos a estudar', TRUE, 3),
      ('O que significa preparar materiais antes de iniciar uma tarefa?', 'Adiar a tarefa', FALSE, 0),
      ('O que significa preparar materiais antes de iniciar uma tarefa?', 'Organizar previamente os recursos necessários', TRUE, 1),
      ('O que significa preparar materiais antes de iniciar uma tarefa?', 'Eliminar os materiais', FALSE, 2),
      ('O que significa preparar materiais antes de iniciar uma tarefa?', 'Aumentar as distrações', FALSE, 3),
      ('Qual é uma vantagem de ter um espaço de trabalho organizado?', 'Impede qualquer concentração', FALSE, 0),
      ('Qual é uma vantagem de ter um espaço de trabalho organizado?', 'Torna todas as tarefas mais demoradas', FALSE, 1),
      ('Qual é uma vantagem de ter um espaço de trabalho organizado?', 'Pode reduzir o tempo gasto procurando objetos e documentos', TRUE, 2),
      ('Qual é uma vantagem de ter um espaço de trabalho organizado?', 'Elimina a necessidade de planeamento', FALSE, 3),
      ('Qual exemplo representa uma tarefa recorrente?', 'Verificar diariamente o e-mail profissional', TRUE, 0),
      ('Qual exemplo representa uma tarefa recorrente?', 'Comprar um computador uma única vez', FALSE, 1),
      ('Qual exemplo representa uma tarefa recorrente?', 'Fazer uma apresentação uma única vez', FALSE, 2),
      ('Qual exemplo representa uma tarefa recorrente?', 'Entregar um documento específico uma única vez', FALSE, 3),
      ('O que significa acompanhar uma meta?', 'Esquecer completamente o objetivo', FALSE, 0),
      ('O que significa acompanhar uma meta?', 'Verificar regularmente se o progresso está de acordo com o objetivo', TRUE, 1),
      ('O que significa acompanhar uma meta?', 'Alterar a meta todos os dias sem motivo', FALSE, 2),
      ('O que significa acompanhar uma meta?', 'Evitar medir qualquer resultado', FALSE, 3),
      ('Qual é uma vantagem de registar tarefas concluídas?', 'Impede novas tarefas', FALSE, 0),
      ('Qual é uma vantagem de registar tarefas concluídas?', 'Permite visualizar o progresso realizado', TRUE, 1),
      ('Qual é uma vantagem de registar tarefas concluídas?', 'Aumenta automaticamente o tempo disponível', FALSE, 2),
      ('Qual é uma vantagem de registar tarefas concluídas?', 'Elimina qualquer necessidade de organização', FALSE, 3),
      ('O que é uma tarefa pendente?', 'Uma tarefa já eliminada', FALSE, 0),
      ('O que é uma tarefa pendente?', 'Uma tarefa concluída há muito tempo', FALSE, 1),
      ('O que é uma tarefa pendente?', 'Uma tarefa que ainda precisa ser concluída', TRUE, 2),
      ('O que é uma tarefa pendente?', 'Uma tarefa que não possui qualquer finalidade', FALSE, 3),
      ('Por que é útil atualizar uma lista de tarefas?', 'Para manter o planeamento alinhado com a situação atual', TRUE, 0),
      ('Por que é útil atualizar uma lista de tarefas?', 'Para aumentar tarefas desnecessariamente', FALSE, 1),
      ('Por que é útil atualizar uma lista de tarefas?', 'Para apagar todas as prioridades', FALSE, 2),
      ('Por que é útil atualizar uma lista de tarefas?', 'Para impedir alterações no plano', FALSE, 3),
      ('O que significa trabalhar de forma organizada?', 'Seguir uma estrutura que facilita a realização das atividades', TRUE, 0),
      ('O que significa trabalhar de forma organizada?', 'Fazer tudo aleatoriamente', FALSE, 1),
      ('O que significa trabalhar de forma organizada?', 'Evitar qualquer prioridade', FALSE, 2),
      ('O que significa trabalhar de forma organizada?', 'Ignorar os prazos', FALSE, 3),
      ('Qual atitude contribui para uma boa gestão do tempo?', 'Adiar sempre as tarefas importantes', FALSE, 0),
      ('Qual atitude contribui para uma boa gestão do tempo?', 'Definir prioridades e distribuir as atividades ao longo do tempo', TRUE, 1),
      ('Qual atitude contribui para uma boa gestão do tempo?', 'Trabalhar sem objetivos', FALSE, 2),
      ('Qual atitude contribui para uma boa gestão do tempo?', 'Aceitar todas as distrações', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_q_produtividade_facil_v4;

    RAISE NOTICE '42 pergunta(s) inserida(s) com sucesso (source=seed_produtividade_facil_v4).';
  END IF;
END $$;

COMMIT;