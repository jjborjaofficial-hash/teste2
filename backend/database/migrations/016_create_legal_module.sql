-- Migration 016: Módulo Jurídico e Compliance
-- Referência: "final jur.. do aprenda e ganhe.docx" Partes 5-24 e Manual do
-- Desenvolvedor Parte 4 (Modelagem de Dados). Substitui o mecanismo simples de
-- terms_version (migration 001) por um sistema completo de documentos
-- versionados, consentimento, cookies, reclamações e recursos.

-- --- Papel administrativo dedicado (docx Parte 11: "Painel Administrativo —
-- Módulo Jurídico e Compliance") ---
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users
    ADD CONSTRAINT users_role_check
        CHECK (role IN ('user', 'admin_master', 'admin_financeiro', 'admin_suporte', 'admin_juridico'));

-- --- Documentos Jurídicos Oficiais (docx Parte 18: legal_documents) ---
CREATE TABLE IF NOT EXISTS legal_documents (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type                VARCHAR(30) NOT NULL UNIQUE
                         CHECK (type IN ('termos', 'privacidade', 'cookies', 'recompensas', 'comunidade', 'aviso_legal')),
    title               VARCHAR(160) NOT NULL,
    -- Se true, o usuário precisa aceitar a versão vigente para poder usar a plataforma
    -- (Termos e Privacidade, conforme print da "Jornada do De Acordo" — checkbox único).
    requires_acceptance BOOLEAN NOT NULL DEFAULT FALSE,
    status              VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
    -- Aponta para a versão vigente publicada. NULL até a primeira versão ser publicada.
    current_version_id UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- --- Versões dos Documentos (docx Parte 6: nunca substituir, sempre versionar) ---
CREATE TABLE IF NOT EXISTS legal_document_versions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id     UUID NOT NULL REFERENCES legal_documents(id) ON DELETE RESTRICT,
    version         VARCHAR(10) NOT NULL,
    content         TEXT NOT NULL,
    -- Rascunho até published_at ser preenchido (docx Parte 11.1: criar, editar,
    -- publicar, arquivar versões antigas).
    effective_date  DATE,
    published_at    TIMESTAMPTZ,
    created_by      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (document_id, version)
);

ALTER TABLE legal_documents
    ADD CONSTRAINT fk_legal_documents_current_version
        FOREIGN KEY (current_version_id) REFERENCES legal_document_versions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_legal_document_versions_document ON legal_document_versions (document_id);

CREATE TRIGGER trg_legal_documents_updated_at
    BEFORE UPDATE ON legal_documents
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --- Registro de Consentimento (docx Parte 5: user_legal_acceptances) ---
CREATE TABLE IF NOT EXISTS user_legal_acceptances (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_version_id UUID NOT NULL REFERENCES legal_document_versions(id) ON DELETE RESTRICT,
    accepted_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_address          VARCHAR(45),
    user_agent          TEXT,
    UNIQUE (user_id, document_version_id)
);

CREATE INDEX IF NOT EXISTS idx_user_legal_acceptances_user ON user_legal_acceptances (user_id);
CREATE INDEX IF NOT EXISTS idx_user_legal_acceptances_version ON user_legal_acceptances (document_version_id);

-- Consentimento é prova jurídica: nunca pode ser alterado ou apagado depois de criado.
CREATE TRIGGER trg_user_legal_acceptances_no_update
    BEFORE UPDATE OR DELETE ON user_legal_acceptances
    FOR EACH ROW EXECUTE FUNCTION prevent_audit_mutation();

-- --- Preferências de Cookies (docx Parte 8) ---
CREATE TABLE IF NOT EXISTS cookie_preferences (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    essential       BOOLEAN NOT NULL DEFAULT TRUE, -- sempre true, não é opcional
    preferences     BOOLEAN NOT NULL DEFAULT FALSE,
    analytics       BOOLEAN NOT NULL DEFAULT FALSE,
    advertising     BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_cookie_preferences_updated_at
    BEFORE UPDATE ON cookie_preferences
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --- Central de Reclamações (docx Parte 11.4) ---
CREATE TABLE IF NOT EXISTS legal_requests (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category            VARCHAR(30) NOT NULL
                         CHECK (category IN ('saques', 'recompensas', 'conta_bloqueada', 'privacidade', 'publicidade', 'problemas_tecnicos', 'conteudo')),
    description         TEXT NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'aberta'
                         CHECK (status IN ('aberta', 'em_analise', 'aguardando_usuario', 'resolvida', 'encerrada')),
    responsible_admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    response            TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_legal_requests_user ON legal_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_legal_requests_status ON legal_requests (status);

CREATE TRIGGER trg_legal_requests_updated_at
    BEFORE UPDATE ON legal_requests
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --- Sistema de Recursos e Contestação (docx Parte 12) ---
CREATE TABLE IF NOT EXISTS legal_appeals (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    protocol        VARCHAR(20) NOT NULL UNIQUE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    related_action  VARCHAR(30) NOT NULL
                    CHECK (related_action IN ('conta_suspensa', 'conta_banida', 'recompensa_removida', 'saque_rejeitado', 'trust_score_reduzido')),
    description     TEXT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'aberto'
                    CHECK (status IN ('aberto', 'em_analise', 'deferido', 'indeferido')),
    decision        TEXT,
    decided_by      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_legal_appeals_user ON legal_appeals (user_id);
CREATE INDEX IF NOT EXISTS idx_legal_appeals_status ON legal_appeals (status);

COMMENT ON TABLE legal_documents IS 'Fonte oficial dos 6 documentos da Central Jurídica (docx Parte 2).';
COMMENT ON TABLE user_legal_acceptances IS 'Prova de consentimento append-only (docx Parte 5 e 13).';
