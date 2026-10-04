-- Migration 107: Rodadas de quiz (quiz v2 — ver docs/quiz-v2-rodadas-e-feedback.md).
--
-- Ao entrar numa categoria o servidor cria uma RODADA independente com 10 perguntas
-- selecionadas por ele (nunca mais o cliente decide o que vem a seguir). Cada rodada tem o
-- seu próprio progresso e resultado; não existe "quiz completo" nem agrupamento de rodadas.
--
--  * question_ids guarda as perguntas na ORDEM em que serão apresentadas.
--  * answered_count aponta para a pergunta atual (question_ids[answered_count + 1]).
--  * Só pode existir UMA rodada em andamento por utilizador (índice parcial). Iniciar outra
--    categoria abandona a anterior; reabrir a mesma categoria retoma a rodada em andamento
--    (é assim que recarregar a página não perde nem duplica respostas).
--  * quiz_attempts.round_id liga cada resposta à rodada; a UNIQUE parcial impede responder
--    a mesma pergunta duas vezes dentro da mesma rodada (cliques duplos, reenvio).
CREATE TABLE IF NOT EXISTS quiz_rounds (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id          UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id      UUID        NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    status           VARCHAR(12) NOT NULL DEFAULT 'in_progress'
                     CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    total_questions  SMALLINT    NOT NULL DEFAULT 10 CHECK (total_questions > 0),
    question_ids     UUID[]      NOT NULL,
    answered_count   SMALLINT    NOT NULL DEFAULT 0 CHECK (answered_count >= 0),
    correct_count    SMALLINT    NOT NULL DEFAULT 0 CHECK (correct_count >= 0),
    xp_total         INTEGER     NOT NULL DEFAULT 0 CHECK (xp_total >= 0),
    points_total     INTEGER     NOT NULL DEFAULT 0 CHECK (points_total >= 0),
    started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at     TIMESTAMPTZ,
    CHECK (answered_count <= total_questions),
    CHECK (correct_count <= answered_count)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_rounds_one_active_per_user
    ON quiz_rounds (user_id) WHERE status = 'in_progress';

CREATE INDEX IF NOT EXISTS idx_quiz_rounds_user_started
    ON quiz_rounds (user_id, started_at DESC);

ALTER TABLE quiz_attempts
    ADD COLUMN IF NOT EXISTS round_id UUID REFERENCES quiz_rounds(id) ON DELETE SET NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_attempt_round_question
    ON quiz_attempts (round_id, question_id) WHERE round_id IS NOT NULL;

-- Usado pela seleção das 10 perguntas (evitar as que o utilizador viu há pouco).
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_question
    ON quiz_attempts (user_id, question_id, created_at DESC);
