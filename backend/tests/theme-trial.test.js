/**
 * Tema Noite emprestado por 10 minutos (GER-002): regra de tempo (pura) e serviço com o banco simulado.
 */
jest.mock('../src/config/database', () => ({ query: jest.fn() }));
jest.mock('../src/common/cache/userCache', () => ({ invalidateProfile: jest.fn().mockResolvedValue(undefined) }));

const db = require('../src/config/database');
const userCache = require('../src/common/cache/userCache');
const { computeTrial, TRIAL_MS } = require('../src/modules/shop/themeTrial');
const service = require('../src/modules/shop/services/themeTrialService');

const T0 = new Date('2026-10-12T10:00:00.000Z');
const at = (ms) => new Date(T0.getTime() + ms);

describe('computeTrial — estado calculado na hora', () => {
  it('conta nova que ainda não usou: available', () => {
    const s = computeTrial({ eligible: true, startedAt: null, introSeenAt: null }, T0);
    expect(s).toMatchObject({ status: 'available', endsAt: null, secondsLeft: 0, introSeen: false, durationSeconds: 600 });
  });

  it('conta antiga (não elegível): unavailable', () => {
    expect(computeTrial({ eligible: false, startedAt: null }, T0).status).toBe('unavailable');
  });

  it('quem já tem o Tema Noite equipado não recebe a oferta', () => {
    expect(computeTrial({ eligible: true, startedAt: null, equippedTheme: 'theme_night' }, T0).status).toBe('unavailable');
  });

  it('ativo: fim = início + 10 minutos e secondsLeft desce', () => {
    const started = T0;
    const s1 = computeTrial({ eligible: true, startedAt: started }, at(0));
    expect(s1.status).toBe('active');
    expect(s1.secondsLeft).toBe(600);
    expect(s1.endsAt).toBe(new Date(T0.getTime() + TRIAL_MS).toISOString());
    const s2 = computeTrial({ eligible: true, startedAt: started }, at(4 * 60 * 1000 + 30 * 1000));
    expect(s2.secondsLeft).toBe(330);
  });

  it('exatamente aos 10 minutos já está expirado (volta ao tema claro)', () => {
    expect(computeTrial({ eligible: true, startedAt: T0 }, at(TRIAL_MS - 1)).status).toBe('active');
    const s = computeTrial({ eligible: true, startedAt: T0 }, at(TRIAL_MS));
    expect(s.status).toBe('expired');
    expect(s.secondsLeft).toBe(0);
  });

  it('aceita a data como texto (perfil vindo da cache em JSON)', () => {
    const s = computeTrial({ eligible: true, startedAt: T0.toISOString() }, at(1000));
    expect(s.status).toBe('active');
    expect(s.secondsLeft).toBe(599);
  });

  it('ecrãs de informação já vistos: introSeen true', () => {
    expect(computeTrial({ eligible: true, introSeenAt: T0 }, T0).introSeen).toBe(true);
  });
});

describe('themeTrialService', () => {
  beforeEach(() => jest.clearAllMocks());

  it('start: conta elegível começa o empréstimo, grava a hora do servidor e limpa a cache do perfil', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ eligible: true, startedAt: T0, introSeenAt: T0, equippedTheme: null }] });
    const s = await service.start('u1', T0);
    expect(s.status).toBe('active');
    expect(s.secondsLeft).toBe(600);
    const [sql, params] = db.query.mock.calls[0];
    expect(sql).toMatch(/theme_trial_started_at IS NULL/);
    expect(sql).toMatch(/theme_trial_eligible = TRUE/);
    expect(params).toEqual(['u1', T0]);
    expect(userCache.invalidateProfile).toHaveBeenCalledWith('u1');
  });

  it('start de novo durante o empréstimo: devolve o estado atual e NÃO reinicia', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] }) // UPDATE não apanhou (já começou)
      .mockResolvedValueOnce({ rows: [{ eligible: true, startedAt: T0, introSeenAt: T0, equippedTheme: null }] });
    const s = await service.start('u1', at(2 * 60 * 1000));
    expect(s.status).toBe('active');
    expect(s.secondsLeft).toBe(480);
    expect(db.query).toHaveBeenCalledTimes(2);
    expect(userCache.invalidateProfile).not.toHaveBeenCalled();
  });

  it('start depois de expirar: 409', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [{ eligible: true, startedAt: T0, introSeenAt: T0, equippedTheme: null }] });
    await expect(service.start('u1', at(TRIAL_MS + 1000))).rejects.toMatchObject({ statusCode: 409 });
  });

  it('start numa conta antiga (não elegível): 403', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [{ eligible: false, startedAt: null, introSeenAt: null, equippedTheme: null }] });
    await expect(service.start('u1', T0)).rejects.toMatchObject({ statusCode: 403 });
  });

  it('start por quem já comprou e equipou o Tema Noite: 409', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [{ eligible: true, startedAt: null, introSeenAt: null, equippedTheme: 'theme_night' }] });
    await expect(service.start('u1', T0)).rejects.toMatchObject({ statusCode: 409 });
  });

  it('start com utilizador inexistente/apagado: 404', async () => {
    db.query.mockResolvedValueOnce({ rows: [] }).mockResolvedValueOnce({ rows: [] });
    await expect(service.start('u1', T0)).rejects.toMatchObject({ statusCode: 404 });
  });

  it('dismissIntro: "Modo claro" só marca os ecrãs como vistos; a oferta continua disponível', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] }) // UPDATE
      .mockResolvedValueOnce({ rows: [{ eligible: true, startedAt: null, introSeenAt: T0, equippedTheme: null }] });
    const s = await service.dismissIntro('u1', T0);
    expect(s).toMatchObject({ status: 'available', introSeen: true });
    expect(db.query.mock.calls[0][0]).not.toMatch(/theme_trial_started_at\s*=/);
    expect(userCache.invalidateProfile).toHaveBeenCalledWith('u1');
  });
});

describe('cadastro marca a conta como elegível', () => {
  it('createUser e createUserFromGoogle gravam theme_trial_eligible = TRUE', async () => {
    jest.resetModules();
    const queries = [];
    jest.doMock('../src/config/database', () => ({ query: jest.fn(async (sql) => { queries.push(sql); return { rows: [{ id: 'x' }] }; }) }));
    const repo = require('../src/modules/auth/repositories/authRepository');
    await repo.createUser({ name: 'A', phone: '841234567', phoneProvider: 'mpesa', passwordHash: 'h', isAdultDeclared: true, termsVersion: '1' });
    await repo.createUserFromGoogle({ name: 'A', email: 'a@a.com', googleId: 'g', avatarUrl: null });
    expect(queries).toHaveLength(2);
    queries.forEach((q) => expect(q).toMatch(/theme_trial_eligible[\s\S]*TRUE/));
  });
});
