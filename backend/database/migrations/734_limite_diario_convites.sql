-- Migration 734: limite diário de convites por pessoa.
-- Decisão do dono (2026-10-29): cada utilizador só pode convidar 5 pessoas por dia (dia do fuso Africa/Maputo).
-- Defesa gratuita (sem SMS) contra contas falsas que se convidam a si mesmas para ganhar o bónus de 20%.
-- Passado o limite, quem se regista com o código entra normalmente, mas o convite não fica vinculado a ninguém.
-- O valor fica em system_config para mudar sem deploy (0 desliga o limite).

INSERT INTO system_config (key, value, description) VALUES
    ('referral_daily_invite_limit', '5',
     'Máximo de convites que cada utilizador pode fazer por dia (fuso Africa/Maputo). 0 desliga o limite.')
ON CONFLICT (key) DO NOTHING;
