-- Migration 025: Sistema de Inventário ("Meus Recursos") — itens
-- consumíveis (quantidade) e temporários (expiram por tempo real, contados
-- pelo servidor, nunca pelo relógio do cliente).
--
-- DECISÃO DE ECONOMIA (resolvendo conflito com a spec original que usava
-- "XP Boost 2x" como exemplo): nenhum item deste inventário multiplica ou
-- acelera XP — isso criaria uma trilha indireta de pagar-para-vencer no
-- ranking/streak, contra o princípio já estabelecido nas migrations 020/023
-- ("nunca acelerar XP nem dinheiro real diretamente") e o espírito
-- "aprendizagem vem primeiro" do Doc. Mestre Seção 1. O equivalente aqui é
-- o Coin Boost, que multiplica apenas Pontos (moeda soft, sem efeito
-- competitivo em ranking/streak/prestígio).
--
-- Os itens permanentes equipáveis (molduras, selos) e os efeitos instantâneos
-- já existentes (streak_protection, streak_recovery) continuam funcionando
-- exatamente como estão — não foram tocados nesta migration, para não
-- arriscar regressão em código já testado. O inventário aqui é para os
-- tipos de item GENUINAMENTE novos: consumíveis com estoque e temporários
-- com contagem regressiva.

BEGIN;

ALTER TABLE shop_items
  ADD COLUMN is_consumable BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN duration_seconds INTEGER;

COMMENT ON COLUMN shop_items.is_consumable IS
  'TRUE = item de estoque (ex.: Streak Shield), consumido via POST /inventory/:id/use. FALSE + duration_seconds definido = item temporário, ativado via POST /inventory/:id/activate.';
COMMENT ON COLUMN shop_items.duration_seconds IS
  'Duração em segundos a partir da ativação (REAL_TIME — corre mesmo com o usuário offline, spec Seção 52). NULL para itens permanentes ou consumíveis sem prazo.';

CREATE TABLE user_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES shop_items(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'owned'
        CHECK (status IN ('owned', 'active', 'expired', 'used')),
    source VARCHAR(30) NOT NULL DEFAULT 'shop'
        CHECK (source IN ('shop', 'mission', 'event', 'admin', 'system')),
    reference_id UUID,
    acquired_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    activated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_inventory_user ON user_inventory (user_id, status);
CREATE INDEX idx_user_inventory_expiry ON user_inventory (expires_at) WHERE status = 'active';

COMMENT ON TABLE user_inventory IS
  'Página "Meus Recursos" (spec Seções 34-60). Itens consumíveis (quantity, status owned/used) e temporários (activated_at/expires_at, status owned/active/expired). Nunca confiar no frontend para expiração — sempre revalidar expires_at <= now() no backend antes de conceder qualquer efeito (spec Seção 55).';
COMMENT ON COLUMN user_inventory.reference_id IS
  'Rastreabilidade da origem: purchase_id se source=shop, user_mission_id se source=mission, etc.';

-- Função utilitária: um item "active" cujo expires_at já passou deve ser
-- tratado como expirado mesmo antes do CRON de limpeza rodar (defesa em
-- profundidade — a leitura nunca deve mostrar um item como ativo passado
-- da hora, mesmo que o UPDATE de limpeza ainda não tenha rodado).
CREATE OR REPLACE FUNCTION effective_inventory_status(status VARCHAR, expires_at TIMESTAMPTZ)
RETURNS VARCHAR AS $$
BEGIN
    IF status = 'active' AND expires_at IS NOT NULL AND expires_at <= now() THEN
        RETURN 'expired';
    END IF;
    RETURN status;
END;
$$ LANGUAGE plpgsql STABLE;

COMMIT;
