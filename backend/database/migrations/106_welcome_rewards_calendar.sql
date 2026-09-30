-- Migration 106: Calendário de recompensas de boas-vindas (7 primeiros dias da conta).
--
-- Regras:
--  * O dia N da conta (dia do cadastro = dia 1, fuso de Moçambique) só pode ser
--    coletado NESSE dia. Se o utilizador faltar, o dia fica BLOQUEADO (perdido)
--    e o calendário segue para o dia seguinte, que tem a sua própria recompensa.
--  * Dia 1 = 2,00 MZN. Valores dos outros dias em system_config (ajustáveis sem deploy).
--  * É uma promoção única de aquisição: NÃO conta no teto diário de 7,20 MZN e é
--    totalmente independente de missões e streak.
--  * PRIMARY KEY (user_id, day_number): cada dia só pode ser coletado uma vez,
--    mesmo com cliques/pedidos simultâneos.
CREATE TABLE IF NOT EXISTS welcome_rewards (
    user_id      UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_number   SMALLINT      NOT NULL CHECK (day_number BETWEEN 1 AND 7),
    amount_mzn   NUMERIC(10,2) NOT NULL CHECK (amount_mzn > 0),
    claimed_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, day_number)
);

INSERT INTO system_config (key, value, description) VALUES
  ('welcome_rewards_enabled', 'true', 'Liga/desliga o calendário de boas-vindas dos 7 primeiros dias'),
  ('welcome_rewards_mzn', '[2.00, 1.00, 1.00, 1.50, 1.50, 2.00, 3.00]',
   'MZN por dia (dia 1 a 7) do calendário de boas-vindas. Dia 1 = 2,00 MZN.')
ON CONFLICT (key) DO NOTHING;
