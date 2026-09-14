-- Migration 032: Tokens de Push (preparação para notificações reais)
--
-- Contexto: até aqui, "notificações" só existiam como linha na tabela
-- `notifications` — só apareciam se o usuário abrisse o app. Não havia
-- nenhuma integração com push real (FCM/APNs) nem SMS.
--
-- Esta migration cria a estrutura necessária para push web/mobile via
-- Firebase Cloud Messaging (FCM). SMS não precisa de tabela própria — usa
-- diretamente `users.phone`, que já existe.
--
-- ⚠️ Isto é infraestrutura, não a integração ativa: enquanto as variáveis de
-- ambiente FIREBASE_* não forem preenchidas (ver .env.example e
-- docs/notificacoes-push-sms.md), `pushService` opera em modo silencioso
-- (grava a intenção no log, não envia nada) — mesmo princípio de degradação
-- graciosa já usado no Redis (common/cache/cacheService.js).

CREATE TABLE IF NOT EXISTS push_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    -- 'web' (navegador via FCM), 'android', 'ios' — hoje só 'web' é usado,
    -- mas o mesmo FCM já cobre os três quando/se existir app nativo.
    platform    VARCHAR(10) NOT NULL DEFAULT 'web' CHECK (platform IN ('web', 'android', 'ios')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Um mesmo token nunca deve ficar associado a dois usuários (ex: dispositivo
-- compartilhado onde outra pessoa logou depois) — ao registrar de novo,
-- REATRIBUÍMOS o token ao novo usuário (ON CONFLICT DO UPDATE), nunca
-- duplicamos.
CREATE UNIQUE INDEX IF NOT EXISTS uq_push_tokens_token ON push_tokens (token);
CREATE INDEX IF NOT EXISTS idx_push_tokens_user ON push_tokens (user_id);
