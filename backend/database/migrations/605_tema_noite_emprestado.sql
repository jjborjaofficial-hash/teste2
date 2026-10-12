-- Migration 605: Tema Noite emprestado por 10 minutos logo depois de criar a conta (GER-002).
-- O utilizador novo experimenta o modo escuro por 10 minutos e depois volta ao tema claro; o Tema Noite
-- continua à venda na Loja (theme_night). O empréstimo NÃO é uma compra: não entra no inventário nem em
-- equipped_theme. Quem manda no tempo é o servidor (fim = início + 10 minutos).
--   theme_trial_eligible      TRUE só nas contas criadas depois desta migration (o cadastro grava TRUE);
--                             as contas antigas ficam FALSE e não recebem a oferta.
--   theme_trial_started_at    quando o utilizador escolheu "Modo escuro" (NULL = ainda não usou).
--   theme_trial_intro_seen_at quando viu os ecrãs de informação/escolha (para não voltarem a aparecer).
-- Idempotente (IF NOT EXISTS) e sem tocar em dados existentes.

ALTER TABLE users ADD COLUMN IF NOT EXISTS theme_trial_eligible BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS theme_trial_started_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS theme_trial_intro_seen_at TIMESTAMPTZ;
