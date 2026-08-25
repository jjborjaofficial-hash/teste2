/**
 * Testes de integração do módulo de Autenticação (Manual Parte 2, Etapa 6: Validação).
 * Requer um banco de teste real (ver README) com as migrations aplicadas.
 */
const request = require('supertest');
const app = require('../src/app');

describe('POST /api/v1/auth/register', () => {
  it('deve rejeitar registro sem aceitar os termos de uso', async () => {
    const res = await request(app).post('/api/v1/auth/register').send({
      name: 'Maria Teste',
      phone: '841234567',
      password: 'senhaSegura123',
      isAdultDeclared: true,
      termsAccepted: false,
    });

    expect(res.status).toBe(400);
    expect(res.body.status).toBe('error');
  });

  it('deve rejeitar telefone fora do padrão M-Pesa/e-Mola', async () => {
    const res = await request(app).post('/api/v1/auth/register').send({
      name: 'João Teste',
      phone: '821234567', // prefixo inválido
      password: 'senhaSegura123',
      isAdultDeclared: true,
      termsAccepted: true,
    });

    expect(res.status).toBe(400);
  });
});

describe('POST /api/v1/auth/login', () => {
  it('deve rejeitar login com telefone inexistente', async () => {
    const res = await request(app).post('/api/v1/auth/login').send({
      phone: '849999999',
      password: 'qualquercoisa',
    });

    expect([400, 401]).toContain(res.status);
  });
});

describe('GET /health', () => {
  it('deve responder 200 ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
