-- 6.ª missão diária (pedido do dono, 12/10): "Acertar 6 perguntas seguidas numa rodada".
-- Substitui o Explorador (que fica desativado, com a lógica intacta).
ALTER TABLE missions DROP CONSTRAINT IF EXISTS missions_activity_type_check;
ALTER TABLE missions ADD CONSTRAINT missions_activity_type_check CHECK (activity_type::text = ANY (ARRAY[
  'login','time_active_minutes','lesson_complete','quiz_count','category_exploration','challenge','round_complete','referral','round_streak'
]::text[]));

UPDATE missions SET is_active = FALSE
 WHERE type = 'daily' AND activity_type = 'category_exploration' AND title = 'Explorador';

INSERT INTO missions (title, description, type, category_id, target_quiz_count, xp_reward, points_reward,
                      money_reward_mzn, is_active, activity_type)
SELECT 'Sequência de 6', 'Acerte 6 perguntas seguidas na mesma rodada, sem errar nenhuma entre elas.',
       'daily', NULL, 6, 30, 15, 1.20, TRUE, 'round_streak'
WHERE NOT EXISTS (SELECT 1 FROM missions WHERE title = 'Sequência de 6');
