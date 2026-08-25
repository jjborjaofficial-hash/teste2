-- Extensão do banco de perguntas e missões (Manual Parte 4: migrations sempre
-- versionadas, nunca alteração direta em produção).
--
-- PRINCÍPIO DESTA MIGRATION: aditiva, não destrutiva. Nenhuma coluna existente
-- é removida ou renomeada — o código atual (quizService, missionsService)
-- continua funcionando sem alteração. As colunas novas habilitam o modelo
-- ampliado de missões (login, tempo ativo, microaula, quiz, exploração,
-- desafio) pedido na especificação, para ser consumido pelas próximas etapas
-- (motor de progresso, CRON de atribuição diária).

BEGIN;

-- ============================================================
-- QUESTIONS: banco de perguntas inteligente (Passo 1 da spec)
-- ============================================================

ALTER TABLE questions
  ADD COLUMN explanation TEXT,
  ADD COLUMN tags TEXT[] NOT NULL DEFAULT '{}',
  ADD COLUMN created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  ADD COLUMN source VARCHAR(120);

-- Índice GIN para busca por tag (Passo 25 da spec: "necessidade de indexação
-- de Categoria, Nível e Tag").
CREATE INDEX idx_questions_tags ON questions USING GIN (tags);

COMMENT ON COLUMN questions.explanation IS
  'Explicação pedagógica exibida após a resposta — a aprendizagem é o núcleo da plataforma (Doc. Mestre Seção 1), não só o clique pela recompensa.';
COMMENT ON COLUMN questions.tags IS
  'Tags livres para busca/filtro no admin (Passo 1: "Filtrar por tags").';

-- ============================================================
-- MISSIONS: tipo de atividade (o que conta progresso), além do
-- tipo temporal (daily/weekly/special/sponsored) que já existe.
-- ============================================================

ALTER TABLE missions
  ADD COLUMN activity_type VARCHAR(30) NOT NULL DEFAULT 'quiz_count',
  ADD CONSTRAINT missions_activity_type_check CHECK (
    activity_type = ANY (ARRAY[
      'login',              -- Missão 1: login diário válido
      'time_active_minutes',-- Missão 2: minutos de atividade real (heartbeat)
      'lesson_complete',    -- Missão 3: concluir microaula
      'quiz_count',         -- Missão 4 / modelo atual: quantidade de quizzes
      'category_exploration', -- Missão 5: visitar categoria(s) diferentes
      'challenge'           -- Missão 6: desafio composto/rotativo do dia
    ])
  );

-- Linhas existentes já nasceram como "quiz_count" (era o único tipo antes
-- desta migration) — o DEFAULT acima já cobre isso para o backfill.

COMMENT ON COLUMN missions.activity_type IS
  'O que conta para o progresso desta missão — independente do tipo temporal (type: daily/weekly/special/sponsored). Usado pelo motor de progresso (missionProgressService) para saber qual evento incrementa a missão.';

-- ============================================================
-- USER_MISSIONS: data do período (para permitir 1 atribuição por
-- dia/semana por usuário+missão) e alvo congelado no momento da
-- atribuição (se o admin mudar o alvo da missão depois, não afeta
-- quem já está com a missão em andamento).
-- ============================================================

ALTER TABLE user_missions
  ADD COLUMN period_date DATE NOT NULL DEFAULT CURRENT_DATE,
  ADD COLUMN target_snapshot INTEGER;

-- Alvo congelado = o target_quiz_count da missão no momento da atribuição.
-- Preenche o histórico existente (se houver) a partir da missão atual.
UPDATE user_missions um
SET target_snapshot = m.target_quiz_count
FROM missions m
WHERE m.id = um.mission_id AND um.target_snapshot IS NULL;

ALTER TABLE user_missions
  ALTER COLUMN target_snapshot SET NOT NULL;

-- Impede duas atribuições da mesma missão para o mesmo usuário no mesmo
-- período (Passo 4 da spec: "nunca criar duas vezes a mesma missão para o
-- mesmo usuário e mesmo período" — a UNIQUE parcial que já existia só
-- cobria "uma ativa por vez", não "uma por dia").
CREATE UNIQUE INDEX uq_user_mission_per_period
  ON user_missions (user_id, mission_id, period_date);

CREATE INDEX idx_user_missions_period ON user_missions (period_date);

COMMENT ON COLUMN user_missions.period_date IS
  'Data (no fuso da plataforma — ver common/time/platformTimezone.js) a que esta atribuição pertence. Junto com a UNIQUE(user_id, mission_id, period_date), garante que o CRON de atribuição diária é idempotente (Passo 22 da spec).';

COMMIT;
