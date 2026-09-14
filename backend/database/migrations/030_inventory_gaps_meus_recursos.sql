-- Migration 030: fecha as lacunas da spec "Meus Recursos" (Seções 34-60)
-- identificadas na auditoria: alerta de expiração proativo (Seção 50) e
-- origens adicionais previstas no documento (Seção 47: Quiz, Campanha,
-- Recompensa — hoje só shop/mission/event/admin/system existiam).
--
-- NÃO incluído aqui (decisão de negócio, não técnica — Manual exige
-- aprovação antes de inventar regra): "indicador de raridade" (spec Seção
-- 57). Implementar isso exigiria decidir quais itens são raros/comuns, o
-- que não está definido em nenhum documento oficial. Fica registrado como
-- pendência explícita, não implementado por padrão arbitrário.

BEGIN;

ALTER TABLE user_inventory DROP CONSTRAINT IF EXISTS user_inventory_source_check;
ALTER TABLE user_inventory
    ADD CONSTRAINT user_inventory_source_check
        CHECK (source IN ('shop', 'mission', 'event', 'admin', 'system', 'quiz', 'campaign', 'reward'));

-- Evita reenviar o alerta "expira em breve" repetidamente para o mesmo item
-- a cada execução do CRON (spec Seção 50: o alerta é um aviso único, não um
-- lembrete repetido a cada poucos minutos).
ALTER TABLE user_inventory ADD COLUMN IF NOT EXISTS expiry_alert_sent BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested', 'withdrawal_new_admin', 'withdrawal_sla_risk',
            'daily_earning_cap_reached', 'points_converted', 'item_expiring_soon'
        ));

COMMIT;
