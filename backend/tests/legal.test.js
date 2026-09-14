/**
 * Testes de integração do módulo Jurídico (docx "final jur.. do aprenda e
 * ganhe", Partes 1-11 | Manual Parte 2, Etapa 6: Validação).
 * Requer um banco de teste real com as migrations aplicadas — as migrations
 * 016/017 criam e semeiam os documentos ('termos', 'privacidade', 'cookies',
 * 'recompensas', 'comunidade', 'aviso_legal') usados abaixo.
 */
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/legal/documents (público)', () => {
  it('deve listar os documentos legais sem exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/legal/documents');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data ?? res.body)).toBe(true);
  });
});

describe('GET /api/v1/legal/documents/:type (público)', () => {
  it('deve retornar o documento de Termos de Uso já semeado (migration 017)', async () => {
    const res = await request(app).get('/api/v1/legal/documents/termos');
    expect(res.status).toBe(200);
  });

  it('deve retornar 404 para um tipo de documento inexistente', async () => {
    const res = await request(app).get('/api/v1/legal/documents/tipo-que-nao-existe');
    expect(res.status).toBe(404);
  });
});

describe('Rotas autenticadas do módulo Jurídico — exigem token', () => {
  it('GET /legal/pending deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/legal/pending');
    expect(res.status).toBe(401);
  });

  it('POST /legal/accept deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/legal/accept').send({});
    expect(res.status).toBe(401);
  });

  it('POST /legal/cookies deve exigir autenticação mesmo com corpo válido', async () => {
    const res = await request(app)
      .post('/api/v1/legal/cookies')
      .send({ preferences: true, analytics: false, advertising: false });
    expect(res.status).toBe(401);
  });

  it('POST /legal/requests deve exigir autenticação', async () => {
    const res = await request(app)
      .post('/api/v1/legal/requests')
      .send({ category: 'saques', description: 'Meu saque não foi processado ainda.' });
    expect(res.status).toBe(401);
  });

  it('POST /legal/appeals deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/legal/appeals').send({});
    expect(res.status).toBe(401);
  });
});

describe('Painel Administrativo Jurídico — exclusivo de admin_juridico', () => {
  it('GET /admin/legal/documents deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/legal/documents');
    expect(res.status).toBe(401);
  });

  it('GET /admin/legal/requests deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/legal/requests');
    expect(res.status).toBe(401);
  });

  it('GET /admin/legal/appeals deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/legal/appeals');
    expect(res.status).toBe(401);
  });
});
