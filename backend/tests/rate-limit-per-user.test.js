// Limites por utilizador (12/10): na internet móvel, em turmas e campus muita gente partilha o mesmo IP, por isso o
// limite geral conta por utilizador autenticado e o IP fica só como teto contra inundações.
const express = require('express');
const jwt = require('jsonwebtoken');
const request = require('supertest');

process.env.JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'segredo-de-teste';

const token = (sub, secret = process.env.JWT_ACCESS_SECRET) => jwt.sign({ sub, role: 'user' }, secret, { expiresIn: '5m' });
const unico = () => `t${Date.now()}${Math.floor(Math.random() * 1e6)}`;

function appCom(limiter) {
  const app = express();
  app.set('trust proxy', 1);
  app.use(limiter);
  app.use((err, req, res, next) => res.status(err.statusCode || 500).json({ erro: err.message })); // eslint-disable-line no-unused-vars
  app.get('/x', (req, res) => res.json({ ok: true }));
  return app;
}

describe('cota por utilizador', () => {
  const { createRateLimiter, userOrIpKey } = require('../src/middleware/rateLimiter');
  const app = appCom(createRateLimiter({ name: unico(), max: 3, keyGenerator: userOrIpKey }));
  const ip = '203.0.113.10';
  const chamar = (auth) => {
    const r = request(app).get('/x').set('X-Forwarded-For', ip);
    return auth ? r.set('Authorization', `Bearer ${auth}`) : r;
  };

  it('dois utilizadores atrás do mesmo IP não partilham a cota', async () => {
    const a = token('utilizador-a');
    const b = token('utilizador-b');
    for (let i = 0; i < 3; i++) expect((await chamar(a)).status).toBe(200);
    expect((await chamar(a)).status).toBe(429); // A esgotou a sua cota
    expect((await chamar(b)).status).toBe(200); // B, no mesmo IP, continua a poder usar
  });

  it('um token falso não dá uma cota nova: cai na cota do IP', async () => {
    const ipFalso = '203.0.113.20';
    const falso = (n) => request(app).get('/x').set('X-Forwarded-For', ipFalso).set('Authorization', `Bearer ${token(`x${n}`, 'segredo-errado')}`);
    for (let i = 0; i < 3; i++) expect((await falso(i)).status).toBe(200);
    expect((await falso(99)).status).toBe(429); // tokens diferentes e falsos continuam a contar no mesmo IP
  });

  it('sem token, cada IP tem a sua cota', async () => {
    for (let i = 0; i < 3; i++) await request(app).get('/x').set('X-Forwarded-For', '198.51.100.1');
    expect((await request(app).get('/x').set('X-Forwarded-For', '198.51.100.1')).status).toBe(429);
    expect((await request(app).get('/x').set('X-Forwarded-For', '198.51.100.2')).status).toBe(200);
  });
});

describe('limite geral (teto por IP + cota por utilizador)', () => {
  it('o teto por IP continua a travar uma inundação mesmo com utilizadores diferentes', async () => {
    let defaultRateLimiter;
    jest.isolateModules(() => {
      process.env.IP_FLOOD_MAX_REQUESTS = '4';
      process.env.RATE_LIMIT_MAX_REQUESTS = '100';
      ({ defaultRateLimiter } = require('../src/middleware/rateLimiter'));
    });
    const app = appCom(defaultRateLimiter);
    const ip = '203.0.113.30';
    const codigos = [];
    for (let i = 0; i < 6; i++) {
      const r = await request(app).get('/x').set('X-Forwarded-For', ip).set('Authorization', `Bearer ${token(`u${i}`)}`);
      codigos.push(r.status);
    }
    expect(codigos.slice(0, 4).every((c) => c === 200)).toBe(true);
    expect(codigos.slice(4).every((c) => c === 429)).toBe(true);
    delete process.env.IP_FLOOD_MAX_REQUESTS;
    delete process.env.RATE_LIMIT_MAX_REQUESTS;
  });
});

describe('cadastro com limite próprio', () => {
  it('tem um limite por IP mais rígido que o login, mas que permite uma turma', async () => {
    const app = require('../src/app');
    const ip = '203.0.113.40';
    const enviar = () => request(app).post('/api/v1/auth/register').set('X-Forwarded-For', ip).send({});
    let ultimo;
    for (let i = 0; i < 16; i++) ultimo = await enviar(); // corpo vazio: falha na validação, mas conta no limite
    expect(ultimo.status).toBe(429);
    // e o login do mesmo IP não foi gasto pelo cadastro
    const login = await request(app).post('/api/v1/auth/login').set('X-Forwarded-For', ip).send({ phone: '841234567', password: 'x' });
    expect(login.status).not.toBe(429);
  });
});
