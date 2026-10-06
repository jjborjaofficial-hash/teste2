/**
 * Teste de integração (PostgreSQL com migrations): renovações simultâneas do mesmo cookie
 * (F5 repetido, várias abas) não derrubam a sessão; token de logout nunca renova.
 * O utilizador de teste não é apagado (audit_logs é append-only); só os tokens.
 */
const crypto = require('crypto');
const db = require('../src/config/database');
const authService = require('../src/modules/auth/services/authService');
const repository = require('../src/modules/auth/repositories/authRepository');

let userId;
const ctx = { userAgent: 'jest', ipAddress: '127.0.0.1' };

async function newRawToken() {
  const raw = crypto.randomBytes(32).toString('hex');
  await repository.storeRefreshToken({
    userId,
    tokenHash: authService.hashToken(raw),
    userAgent: 'jest',
    ipAddress: '127.0.0.1',
    expiresAt: new Date(Date.now() + 86400000),
  });
  return raw;
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const u = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Refresh', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = u.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
});

afterAll(async () => {
  await db.query('DELETE FROM refresh_tokens WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('renovação do token (bug do F5 repetido)', () => {
  it('5 renovações simultâneas com o mesmo cookie dão todas certo', async () => {
    const raw = await newRawToken();
    const results = await Promise.all(
      Array.from({ length: 5 }, () => authService.refresh({ refreshToken: raw }, ctx))
    );
    results.forEach((r) => {
      expect(r.accessToken).toBeTruthy();
      expect(r.refreshToken).toBeTruthy();
    });
  });

  it('renovar de novo logo depois (cookie antigo, dentro da janela) ainda funciona', async () => {
    const raw = await newRawToken();
    await authService.refresh({ refreshToken: raw }, ctx);
    await expect(authService.refresh({ refreshToken: raw }, ctx)).resolves.toBeTruthy();
  });

  it('token antigo fora da janela é recusado', async () => {
    const raw = await newRawToken();
    await authService.refresh({ refreshToken: raw }, ctx);
    await db.query(
      `UPDATE refresh_tokens SET revoked_at = now() - interval '1 minute' WHERE token_hash = $1`,
      [authService.hashToken(raw)]
    );
    await expect(authService.refresh({ refreshToken: raw }, ctx)).rejects.toThrow();
  });

  it('depois do logout o token nunca mais renova', async () => {
    const raw = await newRawToken();
    await authService.logout({ refreshToken: raw });
    await expect(authService.refresh({ refreshToken: raw }, ctx)).rejects.toThrow();
  });
});
