const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/quiz/categories', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/quiz/categories');
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/quiz/answers', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/quiz/answers').send({});
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/wallet/withdrawals', () => {
  it('deve rejeitar método de saque inválido mesmo sem autenticação (401 tem prioridade)', async () => {
    const res = await request(app)
      .post('/api/v1/wallet/withdrawals')
      .send({ amountMzn: 5, method: 'paypal' });
    // Sem token, a autenticação barra antes mesmo da validação do corpo.
    expect(res.status).toBe(401);
  });
});

describe('GET /api/v1/ranking/weekly', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/ranking/weekly');
    expect(res.status).toBe(401);
  });
});
