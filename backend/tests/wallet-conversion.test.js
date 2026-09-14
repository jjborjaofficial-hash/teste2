/**
 * Testes de integração da Conversão de Pontos em Dinheiro (docx "SISTEMA DE
 * ECONOMIA E RECOMPENSAS", Seção 6.1 | migration 028). Mesmo padrão dos
 * demais testes de carteira/loja: confirmam a guarda de autenticação
 * (router.use nada aqui, mas cada rota usa `authenticate` — ver
 * walletRoutes.js) sem depender de dados específicos no banco.
 */
const request = require('supertest');
const app = require('../src/app');
const { conversionSchema } = require('../src/modules/wallet/validators/walletValidators');

describe('GET /api/v1/wallet/convert-points/rate', () => {
  it('deve exigir autenticação', async () => {
    const res = await request(app).get('/api/v1/wallet/convert-points/rate');
    expect(res.status).toBe(401);
  });
});

describe('POST /api/v1/wallet/convert-points', () => {
  it('deve exigir autenticação mesmo com corpo válido', async () => {
    const res = await request(app)
      .post('/api/v1/wallet/convert-points')
      .send({ pointsAmount: 1000 });
    expect(res.status).toBe(401);
  });
});

describe('conversionSchema (validators/walletValidators.js)', () => {
  it('aceita uma quantidade inteira e positiva de Pontos', () => {
    const result = conversionSchema.safeParse({ pointsAmount: 1000 });
    expect(result.success).toBe(true);
  });

  it('rejeita valores não inteiros', () => {
    const result = conversionSchema.safeParse({ pointsAmount: 1000.5 });
    expect(result.success).toBe(false);
  });

  it('rejeita valores negativos ou zero', () => {
    expect(conversionSchema.safeParse({ pointsAmount: 0 }).success).toBe(false);
    expect(conversionSchema.safeParse({ pointsAmount: -500 }).success).toBe(false);
  });

  it('rejeita quando pointsAmount não é enviado', () => {
    const result = conversionSchema.safeParse({});
    expect(result.success).toBe(false);
  });

  // Nota: a regra de "múltiplo exato da taxa vigente" (ex.: múltiplos de
  // 1.000 Pontos) depende de `system_config` e é aplicada em
  // walletService.convertPointsToMoney, não no schema — por isso não é
  // testada aqui (mesmo padrão dos demais testes deste arquivo: só
  // guarda de rota e validação de formato, sem tocar o banco).
});
