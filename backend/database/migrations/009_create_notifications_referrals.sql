-- Migration 009: Notificações e Convites/Indicações
-- Referência: Doc. Mestre Seção 9 (Notificações Inteligentes), Seção 15 (visão de futuro)
-- Manual Parte 3 (módulo Convites/Indicações listado entre os módulos oficiais)

CREATE TABLE IF NOT EXISTS notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(30) NOT NULL
                    CHECK (type IN ('streak_at_risk', 'mission_completed', 'milestone_reached',
                                     'withdrawal_status', 'weekly_ranking', 'system')),
    title           VARCHAR(120) NOT NULL,
    body            TEXT NOT NULL,
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
    ON notifications (user_id, created_at) WHERE read_at IS NULL;

-- Convites / Indicações (mencionado na Parte 3 do Manual como módulo oficial)
CREATE TABLE IF NOT EXISTS referral_codes (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    code            VARCHAR(12) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_referral_codes_code ON referral_codes (code);

CREATE TABLE IF NOT EXISTS referrals (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referred_user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status              VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'qualified', 'rewarded')),
    reward_granted_at   TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Regra: um usuário só pode ter sido indicado uma única vez (evita ciclos/abuso)
CREATE UNIQUE INDEX IF NOT EXISTS uq_referrals_referred_once ON referrals (referred_user_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals (referrer_user_id, status);
