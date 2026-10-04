-- Migration 108: campos de aprendizagem opcionais em questions.
--
-- Hoje só existe questions.explanation (vazia em todas as perguntas). O feedback
-- pedagógico precisa de duas peças a mais, conforme a instrução mestre (secção 5):
--   learn_point : "Aprenda:" (acerto) / "O que aprender:" (erro) - o conceito principal
--   memory_tip  : "Dica:" - pequena dica de memorização (mostrada ao errar)
-- Aditiva e não destrutiva: colunas anuláveis, nenhuma existente é alterada.

BEGIN;

ALTER TABLE questions
    ADD COLUMN IF NOT EXISTS learn_point TEXT,
    ADD COLUMN IF NOT EXISTS memory_tip  TEXT;

COMMENT ON COLUMN questions.explanation IS 'Por quê? / Para complementar: a explicação da resposta correta.';
COMMENT ON COLUMN questions.learn_point IS 'Aprenda: / O que aprender: o conceito principal a reter.';
COMMENT ON COLUMN questions.memory_tip  IS 'Dica: pequena dica de memorização (mostrada ao errar).';

COMMIT;
