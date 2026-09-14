/**
 * Testes de integração da Loja de Pontos e do Inventário ("Meus Recursos")
 * (docx "SISTEMA DE ECONOMIA E RECOMPENSAS" | Manual Parte 2, Etapa 6).
 * Toda rota de /shop, /admin/shop e /inventory exige autenticação
 * (router.use(authenticate) no topo de cada arquivo de rotas) — os testes
 * abaixo confirmam isso sem depender de dados específicos no banco.
 */
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/v1/shop/items', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/shop/items');
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/shop/purchase', () => {
  it('deve exigir autenticação mesmo com corpo válido', async () => {
    const res = await request(app).post('/api/v1/shop/purchase').send({ itemKey: 'streak_freeze' });
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/shop/equip e /unequip', () => {
  it('equip deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/shop/equip').send({ itemKey: 'frame_gold' });
    expect(res.status).toBe(401);
  });

  it('unequip deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/shop/unequip').send({ slot: 'frame' });
    expect(res.status).toBe(401);
  });
});

describe('GET /api/v1/shop/inventory e /points-ledger', () => {
  it('inventory deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/shop/inventory');
    expect(res.status).toBe(401);
  });

  it('points-ledger deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/shop/points-ledger');
    expect(res.status).toBe(401);
  });
});

describe('GET /api/v1/inventory ("Meus Recursos")', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/inventory');
    expect(res.status).toBe(401);
  });

  it('deve exigir autenticação mesmo com ?sort= informado', async () => {
    const res = await request(app).get('/api/v1/inventory?sort=category');
    expect(res.status).toBe(401);
  });

  it('POST /:id/activate deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/inventory/00000000-0000-0000-0000-000000000000/activate');
    expect(res.status).toBe(401);
  });

  it('POST /:id/use deve exigir autenticação', async () => {
    const res = await request(app).post('/api/v1/inventory/00000000-0000-0000-0000-000000000000/use');
    expect(res.status).toBe(401);
  });
});

describe('Painel Administrativo da Loja — exclusivo de admin_financeiro', () => {
  it('GET /admin/shop/items deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/shop/items');
    expect(res.status).toBe(401);
  });

  it('POST /admin/shop/items deve rejeitar acesso sem autenticação mesmo com corpo válido', async () => {
    const res = await request(app).post('/api/v1/admin/shop/items').send({
      key: 'novo_item',
      category: 'cosmetic',
      name: 'Item de Teste',
      pricePoints: 100,
    });
    expect(res.status).toBe(401);
  });

  it('GET /admin/shop/purchases deve rejeitar acesso sem autenticação', async () => {
    const res = await request(app).get('/api/v1/admin/shop/purchases');
    expect(res.status).toBe(401);
  });
});
