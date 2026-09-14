-- Migration/seed: conteúdo Produtividade, nível Fácil (25 perguntas)
-- Fonte: lote de 80 perguntas de Produtividade fornecido pelo proprietário do
-- projeto (perguntas 1–25 do lote, marcadas como "Fácil"). O documento
-- recebido está incompleto: a pergunta 80 (nível Difícil) foi cortada a meio
-- da alternativa B e não trouxe C, D, Resposta nem Dificuldade. Por isso,
-- apenas as perguntas 1–79 deste lote foram inseridas (aqui e em
-- 013_produtividade_medio.sql / 014_produtividade_dificil.sql); a pergunta 80
-- fica pendente até o restante ser enviado.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): no lote original, as respostas corretas eram
-- TODAS a alternativa "A" — decorável sem conhecimento real. A posição da
-- alternativa correta foi redistribuída por pergunta com seed fixa (51 —
-- distinta das seeds 42 a 50 já usadas) e distribuição controlada entre
-- A/B/C/D, reprodutível — o conteúdo pedagógico permanece exatamente como
-- enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Produtividade" (slug: produtividade) já existe desde a migration
-- 021 — esta é a primeira leva de perguntas para ela.
--
-- Verificado: nenhuma das perguntas deste lote colide (mesmo enunciado) com
-- as já existentes nas outras categorias.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_facil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_facil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_facil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_produtividade_facil_v1'
    FROM (VALUES
      ('O que significa ser produtivo?'),
      ('O que é uma tarefa?'),
      ('Para que serve uma lista de tarefas?'),
      ('O que significa priorizar?'),
      ('Qual destas é uma ferramenta que pode ajudar na organização?'),
      ('O que é uma meta?'),
      ('Por que estabelecer metas pode ser útil?'),
      ('O que é organização pessoal?'),
      ('O que é uma rotina?'),
      ('Qual é uma vantagem de ter uma rotina?'),
      ('O que significa cumprir um prazo?'),
      ('O que é uma distração?'),
      ('Qual destas pode ser uma distração durante os estudos?'),
      ('O que significa concentrar-se?'),
      ('Por que pequenas pausas podem ser úteis?'),
      ('O que é procrastinação?'),
      ('Qual atitude pode ajudar a combater a procrastinação?'),
      ('O que significa planejar o dia?'),
      ('O que é um calendário?'),
      ('O que é um compromisso?'),
      ('Qual é uma vantagem de organizar o espaço de trabalho?'),
      ('O que significa terminar uma tarefa?'),
      ('O que é foco?'),
      ('Qual é uma boa prática antes de começar um trabalho importante?'),
      ('O que significa organizar informações?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_facil q
    JOIN (VALUES
      ('O que significa ser produtivo?', 'Evitar qualquer descanso', FALSE, 0),
      ('O que significa ser produtivo?', 'Fazer várias coisas ao mesmo tempo', FALSE, 1),
      ('O que significa ser produtivo?', 'Trabalhar sem parar', FALSE, 2),
      ('O que significa ser produtivo?', 'Realizar tarefas importantes de forma eficiente', TRUE, 3),
      ('O que é uma tarefa?', 'Atividade que precisa ser realizada', TRUE, 0),
      ('O que é uma tarefa?', 'Um período de descanso', FALSE, 1),
      ('O que é uma tarefa?', 'Apenas uma reunião', FALSE, 2),
      ('O que é uma tarefa?', 'Uma ferramenta digital', FALSE, 3),
      ('Para que serve uma lista de tarefas?', 'Aumentar o número de tarefas', FALSE, 0),
      ('Para que serve uma lista de tarefas?', 'Substituir o descanso', FALSE, 1),
      ('Para que serve uma lista de tarefas?', 'Organizar as atividades que precisam ser realizadas', TRUE, 2),
      ('Para que serve uma lista de tarefas?', 'Evitar planejamento', FALSE, 3),
      ('O que significa priorizar?', 'Definir quais atividades devem receber atenção primeiro', TRUE, 0),
      ('O que significa priorizar?', 'Fazer tudo ao mesmo tempo', FALSE, 1),
      ('O que significa priorizar?', 'Escolher apenas as tarefas mais fáceis', FALSE, 2),
      ('O que significa priorizar?', 'Adiar todas as tarefas', FALSE, 3),
      ('Qual destas é uma ferramenta que pode ajudar na organização?', 'Agenda', TRUE, 0),
      ('Qual destas é uma ferramenta que pode ajudar na organização?', 'Coluna de som', FALSE, 1),
      ('Qual destas é uma ferramenta que pode ajudar na organização?', 'Televisão', FALSE, 2),
      ('Qual destas é uma ferramenta que pode ajudar na organização?', 'Máquina fotográfica', FALSE, 3),
      ('O que é uma meta?', 'Resultado que se pretende alcançar', TRUE, 0),
      ('O que é uma meta?', 'Um problema', FALSE, 1),
      ('O que é uma meta?', 'Uma pausa', FALSE, 2),
      ('O que é uma meta?', 'Uma distração', FALSE, 3),
      ('Por que estabelecer metas pode ser útil?', 'Ajuda a orientar os esforços para um resultado desejado', TRUE, 0),
      ('Por que estabelecer metas pode ser útil?', 'Evita qualquer necessidade de ação', FALSE, 1),
      ('Por que estabelecer metas pode ser útil?', 'Garante sucesso imediato', FALSE, 2),
      ('Por que estabelecer metas pode ser útil?', 'Elimina automaticamente todas as dificuldades', FALSE, 3),
      ('O que é organização pessoal?', 'Forma de organizar tempo, tarefas, informações e responsabilidades', TRUE, 0),
      ('O que é organização pessoal?', 'Fazer tudo simultaneamente', FALSE, 1),
      ('O que é organização pessoal?', 'Evitar listas', FALSE, 2),
      ('O que é organização pessoal?', 'Trabalhar sem planejamento', FALSE, 3),
      ('O que é uma rotina?', 'Um período sem atividades', FALSE, 0),
      ('O que é uma rotina?', 'Conjunto de atividades realizadas regularmente', TRUE, 1),
      ('O que é uma rotina?', 'Um objetivo financeiro', FALSE, 2),
      ('O que é uma rotina?', 'Uma tarefa feita apenas uma vez', FALSE, 3),
      ('Qual é uma vantagem de ter uma rotina?', 'Impede mudanças', FALSE, 0),
      ('Qual é uma vantagem de ter uma rotina?', 'Garante produtividade máxima', FALSE, 1),
      ('Qual é uma vantagem de ter uma rotina?', 'Elimina todos os problemas', FALSE, 2),
      ('Qual é uma vantagem de ter uma rotina?', 'Pode reduzir a necessidade de decidir repetidamente o que fazer', TRUE, 3),
      ('O que significa cumprir um prazo?', 'Adiar indefinidamente', FALSE, 0),
      ('O que significa cumprir um prazo?', 'Concluir uma atividade dentro do período estabelecido', TRUE, 1),
      ('O que significa cumprir um prazo?', 'Cancelar uma tarefa', FALSE, 2),
      ('O que significa cumprir um prazo?', 'Começar uma tarefa depois do prazo', FALSE, 3),
      ('O que é uma distração?', 'Um resultado', FALSE, 0),
      ('O que é uma distração?', 'Uma meta', FALSE, 1),
      ('O que é uma distração?', 'Uma prioridade', FALSE, 2),
      ('O que é uma distração?', 'Algo que desvia a atenção da atividade principal', TRUE, 3),
      ('Qual destas pode ser uma distração durante os estudos?', 'Exercício relacionado à matéria', FALSE, 0),
      ('Qual destas pode ser uma distração durante os estudos?', 'Material de estudo', FALSE, 1),
      ('Qual destas pode ser uma distração durante os estudos?', 'Notificações constantes do telemóvel', TRUE, 2),
      ('Qual destas pode ser uma distração durante os estudos?', 'Caderno', FALSE, 3),
      ('O que significa concentrar-se?', 'Trabalhar sem objetivo', FALSE, 0),
      ('O que significa concentrar-se?', 'Realizar várias atividades simultaneamente', FALSE, 1),
      ('O que significa concentrar-se?', 'Direcionar a atenção para determinada atividade', TRUE, 2),
      ('O que significa concentrar-se?', 'Ignorar todas as tarefas', FALSE, 3),
      ('Por que pequenas pausas podem ser úteis?', 'Porque tornam o trabalho desnecessário', FALSE, 0),
      ('Por que pequenas pausas podem ser úteis?', 'Podem ajudar a recuperar a atenção e reduzir a fadiga', TRUE, 1),
      ('Por que pequenas pausas podem ser úteis?', 'Porque substituem o planejamento', FALSE, 2),
      ('Por que pequenas pausas podem ser úteis?', 'Porque eliminam todas as tarefas', FALSE, 3),
      ('O que é procrastinação?', 'Concluir uma tarefa antecipadamente', FALSE, 0),
      ('O que é procrastinação?', 'Organizar documentos', FALSE, 1),
      ('O que é procrastinação?', 'Adiar desnecessariamente uma tarefa que deveria ser realizada', TRUE, 2),
      ('O que é procrastinação?', 'Planejar uma atividade', FALSE, 3),
      ('Qual atitude pode ajudar a combater a procrastinação?', 'Aumentar as distrações', FALSE, 0),
      ('Qual atitude pode ajudar a combater a procrastinação?', 'Dividir uma tarefa grande em etapas menores', TRUE, 1),
      ('Qual atitude pode ajudar a combater a procrastinação?', 'Adiar todas as atividades', FALSE, 2),
      ('Qual atitude pode ajudar a combater a procrastinação?', 'Ignorar completamente a tarefa', FALSE, 3),
      ('O que significa planejar o dia?', 'Evitar qualquer organização', FALSE, 0),
      ('O que significa planejar o dia?', 'Definir antecipadamente as principais atividades e prioridades', TRUE, 1),
      ('O que significa planejar o dia?', 'Fazer tarefas aleatoriamente', FALSE, 2),
      ('O que significa planejar o dia?', 'Trabalhar sem horários', FALSE, 3),
      ('O que é um calendário?', 'Uma técnica de memorização', FALSE, 0),
      ('O que é um calendário?', 'Apenas uma lista de compras', FALSE, 1),
      ('O que é um calendário?', 'Um aplicativo financeiro', FALSE, 2),
      ('O que é um calendário?', 'Ferramenta usada para organizar datas e compromissos', TRUE, 3),
      ('O que é um compromisso?', 'Um período de sono', FALSE, 0),
      ('O que é um compromisso?', 'Uma distração obrigatória', FALSE, 1),
      ('O que é um compromisso?', 'Uma tarefa sem prazo', FALSE, 2),
      ('O que é um compromisso?', 'Atividade ou obrigação previamente combinada ou programada', TRUE, 3),
      ('Qual é uma vantagem de organizar o espaço de trabalho?', 'Garante sucesso automático', FALSE, 0),
      ('Qual é uma vantagem de organizar o espaço de trabalho?', 'Elimina todas as tarefas', FALSE, 1),
      ('Qual é uma vantagem de organizar o espaço de trabalho?', 'Aumenta obrigatoriamente o tempo de trabalho', FALSE, 2),
      ('Qual é uma vantagem de organizar o espaço de trabalho?', 'Pode facilitar o acesso aos materiais e reduzir distrações', TRUE, 3),
      ('O que significa terminar uma tarefa?', 'Concluir aquilo que precisava ser realizado', TRUE, 0),
      ('O que significa terminar uma tarefa?', 'Apenas começar', FALSE, 1),
      ('O que significa terminar uma tarefa?', 'Adiar', FALSE, 2),
      ('O que significa terminar uma tarefa?', 'Ignorar', FALSE, 3),
      ('O que é foco?', 'Tempo de descanso', FALSE, 0),
      ('O que é foco?', 'Quantidade de tarefas realizadas simultaneamente', FALSE, 1),
      ('O que é foco?', 'Capacidade de manter a atenção em uma atividade ou objetivo', TRUE, 2),
      ('O que é foco?', 'Número de aplicativos instalados', FALSE, 3),
      ('Qual é uma boa prática antes de começar um trabalho importante?', 'Abrir várias redes sociais', FALSE, 0),
      ('Qual é uma boa prática antes de começar um trabalho importante?', 'Começar sem saber o objetivo', FALSE, 1),
      ('Qual é uma boa prática antes de começar um trabalho importante?', 'Definir o que precisa ser feito', TRUE, 2),
      ('Qual é uma boa prática antes de começar um trabalho importante?', 'Ignorar o prazo', FALSE, 3),
      ('O que significa organizar informações?', 'Misturar documentos aleatoriamente', FALSE, 0),
      ('O que significa organizar informações?', 'Estruturar dados de maneira que sejam mais fáceis de encontrar e utilizar', TRUE, 1),
      ('O que significa organizar informações?', 'Apagar todas as informações', FALSE, 2),
      ('O que significa organizar informações?', 'Guardar tudo sem identificação', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_facil;

    RAISE NOTICE '25 perguntas inseridas com sucesso (source=seed_produtividade_facil_v1).';
  END IF;
END $$;

COMMIT;
