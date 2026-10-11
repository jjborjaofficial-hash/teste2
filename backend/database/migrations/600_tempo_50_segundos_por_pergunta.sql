-- O dono pediu 50 segundos por pergunta (antes 30; migration 104).
-- O servidor é a fonte do tempo: o cronómetro do quiz (quizTimerService) e a regra
-- antifraude usam time_limit_seconds de cada pergunta, e o frontend lê esse valor.
ALTER TABLE questions ALTER COLUMN time_limit_seconds SET DEFAULT 50;
UPDATE questions SET time_limit_seconds = 50 WHERE time_limit_seconds <> 50;
