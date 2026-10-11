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

describe('rota antiga sem rodada (cortada em 11/10)', () => {
  it('next-question já não existe', async () => {
    const res = await request(app).get('/api/v1/quiz/categories/00000000-0000-4000-8000-000000000000/next-question');
    expect(res.status).toBe(404);
  });

  it('o schema de resposta exige roundId', () => {
    const { submitAnswerSchema } = require('../src/modules/quiz/validators/quizValidators');
    const ids = { questionId: '00000000-0000-4000-8000-000000000001', alternativeId: '00000000-0000-4000-8000-000000000002' };
    expect(submitAnswerSchema.safeParse(ids).success).toBe(false);
    expect(submitAnswerSchema.safeParse({ ...ids, roundId: '00000000-0000-4000-8000-000000000003' }).success).toBe(true);
  });

  it('o serviço recusa resposta sem rodada', async () => {
    const quizService = require('../src/modules/quiz/services/quizService');
    await expect(
      quizService.submitAnswer({ userId: 'u', questionId: 'q', alternativeId: 'a' })
    ).rejects.toMatchObject({ statusCode: 422 });
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
