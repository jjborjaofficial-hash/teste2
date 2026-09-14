/**
 * Testes de integração do módulo de Convites/Indicações (Doc. Mestre Seção 15
 * — "Visão de Futuro"; listado como módulo oficial na Parte 3 do Manual).
 */
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/referrals/me/code', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/referrals/me/code');
    expect(res.status).toBe(401);
  });
});

describe('GET /api/v1/referrals/me', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/referrals/me');
    expect(res.status).toBe(401);
  });
});
