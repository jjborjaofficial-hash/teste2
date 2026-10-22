-- Senha própria do administrador (diferente da senha de login normal). Guardada só como hash (bcrypt).
ALTER TABLE users ADD COLUMN IF NOT EXISTS admin_password_hash TEXT;
