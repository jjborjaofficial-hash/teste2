-- Migration 110: totais da rodada guardados na própria rodada (P7).
--
-- Até aqui o resumo da rodada somava as tentativas a cada pedido. Agora, ao concluir a
-- rodada, o servidor grava os totais (respostas certas, tempo total, XP e pontos), para
-- que o histórico não dependa de recalcular e fique fixo mesmo que as tentativas mudem.
--
-- Aditiva e não destrutiva: colunas novas, todas opcionais (NULL). Rodadas já concluídas
-- antes desta migração ficam com NULL e o resumo continua a calculá-las a partir das tentativas.
-- Valores de pontos = "brutos" pela dificuldade (os mesmos de quiz_attempts.points_awarded),
-- antes do teto diário; o líquido creditado continua em points_ledger.

BEGIN;

ALTER TABLE quiz_rounds
    ADD COLUMN IF NOT EXISTS correct_count     SMALLINT,
    ADD COLUMN IF NOT EXISTS total_response_ms INTEGER,
    ADD COLUMN IF NOT EXISTS xp_total          INTEGER,
    ADD COLUMN IF NOT EXISTS points_total      INTEGER;

COMMIT;
