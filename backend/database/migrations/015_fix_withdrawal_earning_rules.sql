-- Migration 015: Correção das regras econômicas de saque
-- Referência: decisão do proprietário do projeto.
--
-- CORREÇÃO IMPORTANTE: o valor de 7,20 MZN NÃO é um teto de saque — é o teto de
-- QUANTO O USUÁRIO PODE GANHAR em dinheiro real por dia (via missões/streak).
-- O saque em si não tem teto diário: o usuário pode sacar a qualquer momento,
-- qualquer valor, desde que tenha atingido o mínimo de 100 MZN acumulado.
--
-- O usuário NUNCA deposita ou transfere dinheiro para a plataforma. A
-- plataforma NUNCA cobra valor monetário de ninguém. O único fluxo de dinheiro
-- é da plataforma para o usuário (saque).

UPDATE system_config
SET value = '100.00', description = 'Valor mínimo acumulado para poder solicitar saque (MZN). Sem depósito — só o que já foi ganho na plataforma.'
WHERE key = 'withdrawal_min_mzn';

-- Renomeia semanticamente: este valor limita GANHO diário, não SAQUE diário.
UPDATE system_config
SET key = 'daily_earning_cap_mzn',
    value = '7.20',
    description = 'Teto de quanto em MZN reais o usuário pode GANHAR por dia via missões/streak (não é teto de saque).'
WHERE key = 'withdrawal_daily_cap_mzn';
