-- BE-005 (b): novo tipo de missão "completar uma rodada" (activity_type = 'round_complete').
-- Só estende a lista permitida do CHECK de missions.activity_type (migration 022). NÃO cria nenhuma missão:
-- missões pagam dinheiro real (teto diário de 7,20 MZN) e o catálogo é decisão do dono, criado pelo admin.
-- Como conta: +1 no progresso quando uma rodada do quiz (10 perguntas) termina por completo (status 'completed');
-- rodadas abandonadas não contam. O alvo é `target_quiz_count` (nº de rodadas) e, se a missão tiver categoria,
-- só conta rodadas dessa categoria. Idempotente. O runner já envolve o ficheiro numa transação.

ALTER TABLE missions DROP CONSTRAINT IF EXISTS missions_activity_type_check;

ALTER TABLE missions
  ADD CONSTRAINT missions_activity_type_check CHECK (
    activity_type = ANY (ARRAY[
      'login',
      'time_active_minutes',
      'lesson_complete',
      'quiz_count',
      'category_exploration',
      'challenge',
      'round_complete'       -- completar uma rodada do quiz (BE-005 b)
    ])
  );
