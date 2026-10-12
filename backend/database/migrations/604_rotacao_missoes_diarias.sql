-- Rotação das missões diárias (pedido do dono, 12/10).
-- missions.weekdays: dias da semana (ISO: 1 = segunda ... 7 = domingo) em que a missão aparece; NULL = todos os dias.
-- Sempre 6 missões por dia (3 fixas + 3 que rodam) = 7,20 MZN (o teto diário).
--   Fixas (weekdays NULL): Fazer login, 20 minutos de estudo, Acerte 50 perguntas
--   Rodam: Acerte 30 em 3 categorias [seg, qua, qui, sex, sáb, dom]
--          Sequência de 6              [seg, ter, qua, sex, sáb, dom]
--          Explorador                  [seg, ter, qua, qui, sex, dom]
--          Convide um amigo            [ter, qui, sáb]  (3 dias por semana: dinheiro + risco de contas falsas)
ALTER TABLE missions ADD COLUMN IF NOT EXISTS weekdays SMALLINT[] NULL;

UPDATE missions SET weekdays = ARRAY[1,3,4,5,6,7]::smallint[] WHERE type = 'daily' AND title = 'Acerte 30 em 3 categorias';
UPDATE missions SET weekdays = ARRAY[1,2,3,5,6,7]::smallint[] WHERE type = 'daily' AND title = 'Sequência de 6';
UPDATE missions SET weekdays = ARRAY[2,4,6]::smallint[]       WHERE type = 'daily' AND title = 'Convide um amigo';
-- O Explorador volta a ficar ativo, agora só nos seus dias.
UPDATE missions SET is_active = TRUE, weekdays = ARRAY[1,2,3,4,5,7]::smallint[]
 WHERE type = 'daily' AND activity_type = 'category_exploration' AND title = 'Explorador';
