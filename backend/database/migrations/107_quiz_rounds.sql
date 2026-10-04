-- Migration 107: Rodadas de quiz persistentes (10 perguntas por rodada).
--
-- Até aqui a "rodada" existia só no estado de navegação do React: perdia-se ao
-- recarregar e o servidor não sabia quantas perguntas já tinham sido respondidas.
-- Agora o servidor é a fonte de verdade do progresso (instrução mestre, secção 9).
--
-- Aditiva e não destrutiva: nenhuma coluna existente é alterada. As tentativas antigas
-- continuam válidas com round_id NULL.

BEGIN;

CREATE TABLE IF NOT EXISTS quiz_rounds (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id       UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    target_questions  SMALLINT NOT NULL DEFAULT 10 CHECK (target_questions > 0),
    status            VARCHAR(15) NOT NULL DEFAULT 'in_progress'
                      CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    -- Checkpoint técnico (5 perguntas): só marca que o progresso foi gravado/verificado,
    -- não encerra a rodada nem gera resumo.
    checkpoint_at     TIMESTAMPTZ,
    started_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at      TIMESTAMPTZ,
    summary_shown_at  TIMESTAMPTZ
);

-- No máximo UMA rodada em andamento por utilizador e categoria (evita rodadas
-- duplicadas por cliques duplos ou duas abas abertas).
CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_round_in_progress
    ON quiz_rounds (user_id, category_id) WHERE status = 'in_progress';

CREATE INDEX IF NOT EXISTS idx_quiz_rounds_user ON quiz_rounds (user_id, started_at DESC);

CREATE TRIGGER trg_quiz_rounds_updated_at
    BEFORE UPDATE ON quiz_rounds
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE quiz_attempts
    ADD COLUMN IF NOT EXISTS round_id UUID REFERENCES quiz_rounds(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_round ON quiz_attempts (round_id) WHERE round_id IS NOT NULL;

COMMENT ON TABLE quiz_rounds IS
  'Rodada de quiz: 10 perguntas de uma categoria. O servidor é a fonte de verdade do progresso.';
COMMENT ON COLUMN quiz_rounds.checkpoint_at IS
  'Instante em que a 5.ª pergunta foi respondida (checkpoint técnico de persistência; sem resumo).';

COMMIT;
