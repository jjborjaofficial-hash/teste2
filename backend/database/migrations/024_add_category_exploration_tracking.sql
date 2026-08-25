-- Migration 024: suporte a missões do tipo 'category_exploration' e 'login'
-- (Missões 1 e 5 da spec original de missões diárias — só 'quiz_count'
-- funcionava até aqui).
--
-- visited_categories: rastreia QUAIS categorias já contaram para o progresso
-- desta missão específica. Sem isso, visitar a mesma categoria 3 vezes
-- infla o progresso de "visite 2 categorias diferentes" incorretamente —
-- o progresso deve contar categorias DISTINTAS, não visitas.

ALTER TABLE user_missions
  ADD COLUMN visited_categories UUID[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN user_missions.visited_categories IS
  'Usado apenas por missões activity_type=category_exploration: categorias distintas já contadas para o progresso desta atribuição. Evita inflar o progresso revisitando a mesma categoria.';
