-- Missões de "completar rodada" (activity_type = 'round_complete') NÃO podem pagar dinheiro.
--
-- Porquê: a rodada conta como concluída mesmo com 0 acertos, por isso pagar dinheiro real por ela
-- premiaria responder ao acaso. Missões de quizzes (quiz_count) só contam respostas certas e continuam
-- a poder pagar. Decisão do dono (2026-10-08).
--
-- 1) Zera o dinheiro das missões de rodada que já existam (XP e Pontos ficam como estão).
-- 2) Acrescenta uma regra no banco que impede o caso daqui para a frente, venha o pedido da API,
--    de um script ou de um UPDATE feito à mão. A API e o pagamento (claimReward) também o recusam.

BEGIN;

UPDATE missions
   SET money_reward_mzn = 0
 WHERE activity_type = 'round_complete'
   AND money_reward_mzn > 0;

ALTER TABLE missions DROP CONSTRAINT IF EXISTS missions_round_complete_sem_dinheiro_check;
ALTER TABLE missions
  ADD CONSTRAINT missions_round_complete_sem_dinheiro_check
  CHECK (activity_type <> 'round_complete' OR money_reward_mzn = 0);

COMMIT;
