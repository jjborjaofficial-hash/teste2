const express = require('express');
const request = require('supertest');

jest.mock('../src/common/logger', () => ({ info: jest.fn(), warn: jest.fn(), error: jest.fn(), debug: jest.fn() }));

function load() {
  jest.resetModules();
  return { logger: require('../src/common/logger'), ipDiagnostic: require('../src/middleware/ipDiagnostic') };
}
function appWith(ipDiagnostic) {
  const app = express();
  app.set('trust proxy', 2);
  app.use(ipDiagnostic);
  app.use((req, res) => res.json({ ok: true }));
  return app;
}

afterEach(() => { delete process.env.IP_DIAGNOSTIC; delete process.env.IP_DIAGNOSTIC_MAX; });

test('desligado por omissão: não regista nada', async () => {
  const { logger, ipDiagnostic } = load();
  await request(appWith(ipDiagnostic)).get('/api/v1/quiz/x').expect(200);
  expect(logger.info).not.toHaveBeenCalled();
});

test('ligado: regista IPs e o caminho, sem query nem cookies/tokens', async () => {
  process.env.IP_DIAGNOSTIC = '1';
  const { logger, ipDiagnostic } = load();
  await request(appWith(ipDiagnostic)).get('/api/v1/auth/login?telefone=84123')
    .set('X-Forwarded-For', '41.1.2.3, 10.0.0.9').set('Cookie', 'refresh=segredo').set('Authorization', 'Bearer segredo')
    .expect(200);
  expect(logger.info).toHaveBeenCalledTimes(1);
  const [msg, data] = logger.info.mock.calls[0];
  expect(msg).toBe('IP-DIAGNOSTICO');
  expect(data.path).toBe('/api/v1/auth/login');
  expect(data.xForwardedFor).toBe('41.1.2.3, 10.0.0.9');
  expect(data.reqIp).toBe('41.1.2.3');
  expect(JSON.stringify(data)).not.toMatch(/segredo|84123/);
});

test('só /api e no máximo IP_DIAGNOSTIC_MAX registos', async () => {
  process.env.IP_DIAGNOSTIC = '1';
  process.env.IP_DIAGNOSTIC_MAX = '2';
  const { logger, ipDiagnostic } = load();
  const app = appWith(ipDiagnostic);
  await request(app).get('/health');
  for (let i = 0; i < 5; i += 1) await request(app).get('/api/v1/quiz/x');
  expect(logger.info).toHaveBeenCalledTimes(2);
});
