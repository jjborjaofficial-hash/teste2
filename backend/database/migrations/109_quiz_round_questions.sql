-- Migration 109: as perguntas de cada rodada, em ordem.
--
-- A rodada passa a ter as suas 10 perguntas selecionadas de uma vez, ao iniciar, e
-- guardadas aqui com a posição (1 a 10). Isto permite: servir a pergunta pela posição,
-- retomar a rodada depois de recarregar sem duplicar nem trocar perguntas, e mais tarde
-- evitar repetir perguntas vistas recentemente (histórico por utilizador).
--
-- Aditiva: rodadas já existentes (migration 107) ficam sem linhas aqui e continuam a
-- funcionar pelo caminho antigo (pergunta aleatória sem repetição na rodada).

BEGIN;

CREATE TABLE IF NOT EXISTS quiz_round_questions (
    round_id     UUID NOT NULL REFERENCES quiz_rounds(id) ON DELETE CASCADE,
    position     SMALLINT NOT NULL CHECK (position > 0),
    question_id  UUID NOT NULL REFERENCES questions(id) ON DELETE RESTRICT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (round_id, position),
    -- Nunca a mesma pergunta duas vezes na mesma rodada.
    CONSTRAINT uq_quiz_round_question UNIQUE (round_id, question_id)
);

-- Para consultar "perguntas vistas recentemente por um utilizador" via rodadas.
CREATE INDEX IF NOT EXISTS idx_quiz_round_questions_question ON quiz_round_questions (question_id);

COMMENT ON TABLE quiz_round_questions IS
  'As perguntas de uma rodada, na ordem em que são servidas (position 1..N).';

COMMIT;
