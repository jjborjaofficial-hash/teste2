/**
 * O login não pode ser bloqueado por chamadas normais da API nem por outros
 * utilizadores atrás do mesmo proxy (bug: "tentou várias vezes, aguarde 1 minuto"
 * logo na 3.ª tentativa).
 */
const request = require('supertest');
const app = require('../src/app');

describe('rate limit do login', () => {
  it('confia no proxy (req.ip vem de X-Forwarded-For)', () => {
    expect(app.get('trust proxy')).toBeTruthy();
  });

  it('chamadas à API e renovações de sessão não gastam a cota do login', async () => {
    const ip = '203.0.113.77';
    for (let i = 0; i < 12; i++) {
      await request(app).get('/api/v1/quiz/categories').set('X-Forwarded-For', ip);
      await request(app).post('/api/v1/auth/refresh').set('X-Forwarded-For', ip);
    }
    const res = await request(app)
      .post('/api/v1/auth/login')
      .set('X-Forwarded-For', ip)
      .send({ phone: '841234567', password: 'errada12345' });
    expect(res.status).not.toBe(429);
  });

  it('bloqueia o login só depois de 8 tentativas por minuto e por IP', async () => {
    const send = (ip) =>
      request(app).post('/api/v1/auth/login').set('X-Forwarded-For', ip).send({ phone: '841234567', password: 'x' });
    let last;
    for (let i = 0; i < 9; i++) last = await send('203.0.113.88');
    expect(last.status).toBe(429);
    expect((await send('203.0.113.99')).status).not.toBe(429);
  });
});
