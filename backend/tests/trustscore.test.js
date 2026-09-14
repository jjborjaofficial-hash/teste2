/**
 * Testes de integração do Trust Score (Doc. Mestre Seção 7, 16.2 | Manual
 * Parte 2, Etapa 6: Validação). A leitura do próprio status vive em
 * /trust-score/me; o ajuste manual (admin_suporte) vive no módulo Admin
 * (/admin/users/:userId/trust-score/adjust) — cobrindo os dois aqui.
 */
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/trust-score/me', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/trust-score/me');
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/admin/users/:userId/trust-score/adjust', () => {
  it('deve rejeitar acesso sem autenticação, mesmo com corpo válido', async () => {
    const res = await request(app)
      .post('/api/v1/admin/users/00000000-0000-0000-0000-000000000000/trust-score/adjust')
      .send({ delta: -10, reason: 'Resposta de quiz abaixo do tempo mínimo humano.' });
    expect(res.status).toBe(401);
  });

  it('deve rejeitar acesso sem autenticação com corpo inválido (401 tem prioridade sobre 400)', async () => {
    const res = await request(app)
      .post('/api/v1/admin/users/00000000-0000-0000-0000-000000000000/trust-score/adjust')
      .send({ delta: 999 }); // fora do range permitido (-100 a 100) e sem "reason"
    expect(res.status).toBe(401);
  });
});
