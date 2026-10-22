-- Migration 731: bónus de boas-vindas passa de 12 MZN para 10 MZN no total dos 7 dias.
-- Decisão do dono em 2026-10-21. Antes: 2,00 / 1,00 / 1,00 / 1,50 / 1,50 / 2,00 / 3,00 (= 12,00).
-- Agora: 2,00 / 1,00 / 1,00 / 1,00 / 1,50 / 1,50 / 2,00 (= 10,00). O dia 1 mantém 2,00 MZN.
-- Só muda a lista `welcome_rewards_mzn` (a mesma chave da migration 106). O app lê os valores do servidor.
-- Quem já coletou dias antes desta migration mantém o que recebeu; os dias ainda por coletar passam a valer o valor novo.
UPDATE system_config
   SET value = '[2.00, 1.00, 1.00, 1.00, 1.50, 1.50, 2.00]'
 WHERE key = 'welcome_rewards_mzn';
