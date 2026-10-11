/** Rotas internas do agendador: protegidas por segredo; sem CRON_SECRET ficam desligadas. */
const request = require('supertest');

jest.mock('../src/cron/scheduler/runDueJobs', () => ({
  runDueJobs: jest.fn().mockResolvedValue({ skipped: null, results: [{ name: 'x', state: 'ran' }] }),
  getStatus: jest.fn().mockResolvedValue({ timezone: 'Africa/Maputo', jobs: [] }),
  MAX_ATTEMPTS: 3,
}));

const app = require('../src/app');
const redis = require('../src/config/redis');
const { runDueJobs } = require('../src/cron/scheduler/runDueJobs');

const SECRET = 'segredo-de-teste-com-mais-de-24-caracteres';

afterAll(async () => {
  await redis.quit();
});
afterEach(() => {
  delete process.env.CRON_SECRET;
  jest.clearAllMocks();
});

test('sem CRON_SECRET configurado, as rotas ficam desligadas (404)', async () => {
  await request(app).post('/internal/cron/tick').set('x-cron-secret', SECRET).expect(404);
  await request(app).get('/internal/cron/status').expect(404);
  expect(runDueJobs).not.toHaveBeenCalled();
});

test('CRON_SECRET curto demais também deixa desligado', async () => {
  process.env.CRON_SECRET = 'curto';
  await request(app).post('/internal/cron/tick').set('x-cron-secret', 'curto').expect(404);
});

test('segredo errado ou ausente: 401, e nada é executado', async () => {
  process.env.CRON_SECRET = SECRET;
  await request(app).post('/internal/cron/tick').expect(401);
  await request(app).post('/internal/cron/tick').set('x-cron-secret', 'errado').expect(401);
  await request(app).get('/internal/cron/status').set('x-cron-secret', `${SECRET}x`).expect(401);
  expect(runDueJobs).not.toHaveBeenCalled();
});

test('segredo certo: POST /tick responde 202 e dispara as tarefas', async () => {
  process.env.CRON_SECRET = SECRET;
  const res = await request(app).post('/internal/cron/tick').set('x-cron-secret', SECRET).expect(202);
  expect(res.body).toEqual({ accepted: true });
  expect(runDueJobs).toHaveBeenCalledTimes(1);
});

test('?wait=1 espera e devolve o resultado; GET /status devolve o estado', async () => {
  process.env.CRON_SECRET = SECRET;
  const t = await request(app).post('/internal/cron/tick?wait=1').set('x-cron-secret', SECRET).expect(200);
  expect(t.body.results[0]).toEqual({ name: 'x', state: 'ran' });
  const s = await request(app).get('/internal/cron/status').set('x-cron-secret', SECRET).expect(200);
  expect(s.body.timezone).toBe('Africa/Maputo');
});
