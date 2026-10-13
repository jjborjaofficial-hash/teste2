-- Anti-duplicação de identidades (12/10/2026).
-- 1) Ao ELIMINAR uma conta, o telefone, o e-mail e o Google dela são libertados (anonimização). Sem memória disso, dava para
--    criar conta, receber o bónus de boas-vindas (até 12 MZN), eliminar e criar de novo com o mesmo número. Guardamos só um
--    HASH com chave secreta (HMAC) de cada identidade libertada, nunca o número nem o e-mail. Quem volta pode usar a
--    plataforma, mas a conta nova fica marcada (`identity_recycled`) e não recebe bónus de boas-vindas nem convites.
-- 2) E-mails do Gmail ignoram pontos e tudo depois de "+" (joao.jose+1@gmail.com é a caixa de joaojose@gmail.com).
--    `email_normalized` guarda a forma única e passa a ser única por conta ativa.
-- Idempotente e à prova de dados existentes: o índice único só é criado se não houver duplicados (não parte o arranque).

CREATE TABLE IF NOT EXISTS used_identities (
  id           BIGSERIAL PRIMARY KEY,
  kind         TEXT NOT NULL CHECK (kind IN ('phone', 'email', 'google')),
  identity_hash TEXT NOT NULL,
  released_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_used_identities UNIQUE (kind, identity_hash)
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS identity_recycled BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_normalized TEXT;

UPDATE users
   SET email_normalized = CASE
         WHEN lower(email) ~ '@(gmail|googlemail)\.com$'
           THEN replace(split_part(split_part(lower(email), '@', 1), '+', 1), '.', '') || '@gmail.com'
         ELSE lower(email)
       END
 WHERE email IS NOT NULL AND email_normalized IS NULL;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM users
     WHERE email_normalized IS NOT NULL AND deleted_at IS NULL
     GROUP BY email_normalized HAVING count(*) > 1
  ) THEN
    RAISE NOTICE 'Há e-mails duplicados depois de normalizar: o índice único NÃO foi criado (a verificação no código continua ativa). Resolver à mão e voltar a correr.';
  ELSE
    CREATE UNIQUE INDEX IF NOT EXISTS uq_users_email_normalized_active
      ON users (email_normalized)
      WHERE email_normalized IS NOT NULL AND deleted_at IS NULL;
  END IF;
END $$;
