-- Migration 006: Missões
-- Referência: Doc. Mestre Seção 4, 5, 8, 12 (/play) | Manual Parte 4

CREATE TABLE IF NOT EXISTS missions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(120) NOT NULL,
    description         TEXT,
    type                VARCHAR(20) NOT NULL DEFAULT 'daily'
                        CHECK (type IN ('daily', 'weekly', 'special', 'sponsored')),
    category_id         UUID REFERENCES categories(id) ON DELETE SET NULL,
    target_quiz_count    INTEGER NOT NULL DEFAULT 1 CHECK (target_quiz_count > 0),
    xp_reward           INTEGER NOT NULL DEFAULT 0 CHECK (xp_reward >= 0),
    points_reward        INTEGER NOT NULL DEFAULT 0 CHECK (points_reward >= 0),
    money_reward_mzn     NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (money_reward_mzn >= 0),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    starts_at           TIMESTAMPTZ,
    ends_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_missions_active_window ON missions (is_active, starts_at, ends_at);

-- Progresso do usuário em cada missão atribuída (Seção 4: Missões -> XP)
CREATE TABLE IF NOT EXISTS user_missions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mission_id      UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
    progress_count  INTEGER NOT NULL DEFAULT 0 CHECK (progress_count >= 0),
    status          VARCHAR(20) NOT NULL DEFAULT 'in_progress'
                    CHECK (status IN ('in_progress', 'completed', 'reward_claimed', 'expired')),
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at    TIMESTAMPTZ,
    claimed_at      TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_user_mission_active
    ON user_missions (user_id, mission_id) WHERE status IN ('in_progress', 'completed');

CREATE INDEX IF NOT EXISTS idx_user_missions_user_status ON user_missions (user_id, status);
