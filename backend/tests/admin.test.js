const request = require('supertest');
const app = require('../src/app');

describe('Rotas do Admin — controle de acesso', () => {
  it('deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/withdrawals');
    expect(res.status).toBe(401);
  });

  it('deve rejeitar corpo inválido em rejeição de saque mesmo sem autenticação (401 primeiro)', async () => {
    const res = await request(app)
      .post('/api/v1/admin/withdrawals/00000000-0000-0000-0000-000000000000/reject')
      .send({});
    expect(res.status).toBe(401);
  });

  it('deve rejeitar acesso à rota de mudança de papel sem autenticação', async () => {
    const res = await request(app)
      .post('/api/v1/admin/users/00000000-0000-0000-0000-000000000000/role')
      .send({ role: 'admin_suporte' });
    expect(res.status).toBe(401);
  });
});
