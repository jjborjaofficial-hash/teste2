-- Migration 721: conversão de Pontos em dinheiro passa de 1.000 Pontos = 10,00 MZN para 1.000 Pontos = 5,00 MZN.
-- Decisão do dono em 2026-10-21, depois de ver que o teto de 5.000 Pontos por dia (fora do teto de 7,20 MZN das
-- missões) permitia chegar aos 100 MZN do saque em ~2 dias. Com 5,00 MZN, o teto de Pontos vale no máximo 25 MZN por dia.
-- Só muda a taxa em MZN: `points_conversion_rate_points` (1000) e o teto `daily_points_cap` (5000) ficam como estão.
-- A taxa é lida do servidor (Carteira mostra "Taxa atual"), por isso o app não precisa de alteração.
-- Pontos que o utilizador já tem passam a converter à taxa nova (a conversão usa sempre a taxa do momento).
UPDATE system_config
   SET value = '5.00'
 WHERE key = 'points_conversion_rate_mzn';
