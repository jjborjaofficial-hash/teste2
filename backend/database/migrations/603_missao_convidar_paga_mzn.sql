-- Pedido do dono (12/10): a missão "Convide um amigo" paga em dinheiro como as outras (1,20 MZN).
-- Atenção: convites pagos em dinheiro todos os dias podem ser explorados com contas falsas; a regra de
-- qualificação do convidado (quizzes certos) é a defesa. Total diário das missões = 7,20 MZN (o teto).
UPDATE missions SET money_reward_mzn = 1.20
 WHERE type = 'daily' AND activity_type = 'referral' AND title = 'Convide um amigo';
