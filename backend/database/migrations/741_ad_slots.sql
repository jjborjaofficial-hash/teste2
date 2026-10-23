-- Anúncios geridos pelo painel admin: um registo por local da plataforma (slot). O Zone ID vem do código colado pelo
-- administrador (só Adcash, validado). A linha '_master' é o interruptor geral (começa DESLIGADO).
CREATE TABLE IF NOT EXISTS ad_slots (
    slot_key    VARCHAR(40) PRIMARY KEY,
    zone_id     VARCHAR(20),
    enabled     BOOLEAN NOT NULL DEFAULT TRUE,
    script_raw  TEXT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by  UUID
);
INSERT INTO ad_slots (slot_key, enabled) VALUES ('_master', FALSE) ON CONFLICT DO NOTHING;
