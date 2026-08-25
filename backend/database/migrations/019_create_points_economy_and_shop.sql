-- Migration 019: Economia de Pontos (livro-razão) + Loja
-- Referência: "DOCUMENTO OFICIAL — SISTEMA DE ECONOMIA E RECOMPENSAS" (Seções 3, 8, 9)
-- e catálogo de loja aprovado em conversa com o proprietário do projeto.
--
-- Decisão de arquitetura: NÃO recriamos users_xp/user_virtual_currency/wallet_mzn
-- como tabelas separadas (o documento original sugeria isso). xp_total e
-- points_balance continuam como colunas em `users` (leitura rápida, já
-- cacheada — ver common/cache/userCache.js); o que faltava e este migration
-- adiciona é o LIVRO-RAZÃO de Pontos (auditoria), no mesmo padrão já usado e
-- validado em `wallet_transactions`.

-- --- Livro-razão de Pontos (append-only, mesmo padrão de wallet_transactions) ---
CREATE TABLE IF NOT EXISTS points_ledger (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(10) NOT NULL CHECK (type IN ('credit', 'debit')),
    source          VARCHAR(50) NOT NULL,
    amount_points   INTEGER NOT NULL CHECK (amount_points > 0),
    balance_after   INTEGER NOT NULL CHECK (balance_after >= 0),
    reference_id    UUID,
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_points_ledger_user ON points_ledger (user_id, created_at DESC);

-- Auditoria financeira/econômica nunca pode ser editada ou apagada depois de
-- criada (reaproveita a mesma trigger já usada em audit_logs e
-- user_legal_acceptances — Manual Parte 4).
CREATE TRIGGER trg_points_ledger_no_update
    BEFORE UPDATE OR DELETE ON points_ledger
    FOR EACH ROW EXECUTE FUNCTION prevent_audit_mutation();

-- --- Suporte a Recuperação de Streak (item funcional da loja) ---
-- broken_at: quando o streak quebrou (por inatividade), preenchido tanto pelo
-- fluxo reativo (streakService.registerDailyActivity) quanto pelo CRON
-- enforceStreakExpiry.js. pre_break_streak_days: quantos dias o usuário tinha
-- ANTES de quebrar — é o valor restaurado pela compra de "Recuperar Streak",
-- só dentro da janela de 24h (checada em tempo de compra, não aqui).
ALTER TABLE streaks ADD COLUMN IF NOT EXISTS broken_at TIMESTAMPTZ;
ALTER TABLE streaks ADD COLUMN IF NOT EXISTS pre_break_streak_days INTEGER NOT NULL DEFAULT 0;

-- --- Suporte a cosméticos (itens de personalização visual) ---
ALTER TABLE users ADD COLUMN IF NOT EXISTS equipped_avatar_frame VARCHAR(40);
ALTER TABLE users ADD COLUMN IF NOT EXISTS equipped_theme VARCHAR(40);

-- --- Catálogo da Loja ---
CREATE TABLE IF NOT EXISTS shop_items (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key                 VARCHAR(40) NOT NULL UNIQUE,
    category            VARCHAR(20) NOT NULL CHECK (category IN ('functional', 'cosmetic', 'prestige')),
    name                VARCHAR(120) NOT NULL,
    description         TEXT,
    price_points        INTEGER NOT NULL CHECK (price_points > 0),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    -- Efeito aplicado no momento da compra (ex: 'streak_protection',
    -- 'streak_recovery'). NULL para cosméticos/prestígio — a própria posse já
    -- é o efeito (equipar é uma ação separada, sem custo adicional).
    effect_key          VARCHAR(40),
    -- Pré-requisito de elegibilidade checado em tempo de compra (ex:
    -- 'top10_ranking'). NULL = qualquer usuário pode comprar.
    eligibility_rule    VARCHAR(40),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_shop_items_updated_at
    BEFORE UPDATE ON shop_items
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --- Histórico de Compras ---
CREATE TABLE IF NOT EXISTS user_purchases (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shop_item_id        UUID NOT NULL REFERENCES shop_items(id) ON DELETE RESTRICT,
    price_paid_points   INTEGER NOT NULL,
    points_ledger_id    BIGINT REFERENCES points_ledger(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_purchases_user ON user_purchases (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_purchases_item ON user_purchases (shop_item_id);

-- Registro de compra também é prova de transação econômica — não pode ser
-- editado nem apagado depois de criado.
CREATE TRIGGER trg_user_purchases_no_update
    BEFORE UPDATE OR DELETE ON user_purchases
    FOR EACH ROW EXECUTE FUNCTION prevent_audit_mutation();

-- --- Teto diário de Pontos (docx "SISTEMA DE ECONOMIA", Seção 8) ---
INSERT INTO system_config (key, value, description) VALUES
    ('daily_points_cap', '5000',
     'Máximo de Pontos que um usuário pode GANHAR por dia (missões + streak + indicações). Não afeta gastos na loja.')
ON CONFLICT (key) DO NOTHING;
