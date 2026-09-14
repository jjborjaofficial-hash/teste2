/**
 * Testes de integração do módulo de Missões (Doc. Mestre Seção 4, 5, 8, 12
 * | Manual Parte 2, Etapa 6). O lado do usuário exige autenticação simples;
 * o lado administrativo exige o papel admin_suporte.
 */
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/missions (minhas missões)', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/missions');
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/missions/:userMissionId/claim', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).post(
      '/api/v1/missions/00000000-0000-0000-0000-000000000000/claim'
    );
    expect(res.status).toBe(401);
  });
});

describe('Painel Administrativo de Missões — exclusivo de admin_suporte', () => {
  it('GET /admin/missions deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/missions');
    expect(res.status).toBe(401);
  });

  it('POST /admin/missions deve rejeitar acesso sem autenticação mesmo com corpo válido', async () => {
    const res = await request(app).post('/api/v1/admin/missions').send({
      title: 'Complete 3 quizzes de Finanças',
      type: 'daily',
      targetQuizCount: 3,
      xpReward: 50,
    });
    expect(res.status).toBe(401);
  });

  it('POST /admin/missions/:id deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app)
      .post('/api/v1/admin/missions/00000000-0000-0000-0000-000000000000')
      .send({ isActive: false });
    expect(res.status).toBe(401);
  });
});
