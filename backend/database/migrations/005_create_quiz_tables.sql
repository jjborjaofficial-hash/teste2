-- Migration 005: Categorias, Perguntas e Alternativas
-- Referência: Doc. Mestre Seção 5 (categorias) e 11 | Manual Parte 4

CREATE TABLE IF NOT EXISTS categories (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(60) NOT NULL,
    slug            VARCHAR(60) NOT NULL,
    description     TEXT,
    icon_key        VARCHAR(40), -- referencia a ficha técnica de ícone (Seção 13.5)
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_categories_slug ON categories (slug);

CREATE TABLE IF NOT EXISTS questions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id     UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    difficulty      VARCHAR(10) NOT NULL DEFAULT 'medium'
                    CHECK (difficulty IN ('easy', 'medium', 'hard')),
    statement       TEXT NOT NULL,
    time_limit_seconds SMALLINT NOT NULL DEFAULT 15 CHECK (time_limit_seconds > 0),
    xp_reward       INTEGER NOT NULL DEFAULT 10 CHECK (xp_reward >= 0),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_questions_category ON questions (category_id, is_active);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions (difficulty);

CREATE TRIGGER trg_questions_updated_at
    BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS question_alternatives (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id     UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    label           TEXT NOT NULL,
    is_correct      BOOLEAN NOT NULL DEFAULT FALSE,
    display_order   SMALLINT NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_alternatives_question ON question_alternatives (question_id);

-- Garante exatamente uma alternativa correta por pergunta (checado na aplicação também,
-- mas reforçado aqui via índice parcial único)
CREATE UNIQUE INDEX IF NOT EXISTS uq_one_correct_per_question
    ON question_alternatives (question_id) WHERE is_correct = TRUE;

-- Sessões de estudo / respostas do usuário (medida antifraude — Seção 7 e 11)
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    question_id     UUID NOT NULL REFERENCES questions(id) ON DELETE RESTRICT,
    alternative_id  UUID REFERENCES question_alternatives(id),
    is_correct      BOOLEAN NOT NULL,
    response_time_ms INTEGER NOT NULL CHECK (response_time_ms >= 0),
    xp_awarded      INTEGER NOT NULL DEFAULT 0 CHECK (xp_awarded >= 0),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_time ON quiz_attempts (user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_question ON quiz_attempts (question_id);
