/**
 * BE-001: a missão "Entrar na plataforma" nunca completava porque nada chamava
 * `updateAfterLogin`. Testes unitários (sem banco) do fluxo corrigido.
 */
jest.mock('../src/config/database', () => ({ query: jest.fn() }));
jest.mock('../src/common/cache/cacheService', () => ({
  getOrSet: jest.fn(async (_key, _ttl, fn) => fn()),
  invalidate: jest.fn(),
}));
jest.mock('../src/modules/missions/repositories/missionsRepository', () => ({
  listActiveMissions: jest.fn().mockResolvedValue([
    { id: 'm1', type: 'daily', target_quiz_count: 1 },
    { id: 'm2', type: 'weekly', target_quiz_count: 5 },
  ]),
  assignMissionIfNotPresent: jest.fn(),
  expireStaleDailyForUser: jest.fn().mockResolvedValue(undefined),
  completeLoginMissions: jest.fn().mockResolvedValue([{ id: 'um1', title: 'Entrar na plataforma' }]),
}));
jest.mock('../src/modules/notifications/services/notificationsService', () => ({
  notifyMissionCompleted: jest.fn(),
}));
jest.mock('../src/modules/gamification/services/xpService', () => ({}));
jest.mock('../src/modules/wallet/services/walletService', () => ({}));

const repository = require('../src/modules/missions/repositories/missionsRepository');
const cacheService = require('../src/common/cache/cacheService');
const notifications = require('../src/modules/notifications/services/notificationsService');
const missionsService = require('../src/modules/missions/services/missionsService');

describe('missionsService.registerPresence (missão de login)', () => {
  beforeEach(() => jest.clearAllMocks());

  it('atribui as missões diárias de hoje e completa a de login', async () => {
    await missionsService.registerPresence('u1');
    // só a missão 'daily' é atribuída
    expect(repository.assignMissionIfNotPresent).toHaveBeenCalledTimes(1);
    expect(repository.assignMissionIfNotPresent.mock.calls[0][1]).toMatchObject({ userId: 'u1', missionId: 'm1' });
    expect(repository.completeLoginMissions).toHaveBeenCalledWith(expect.anything(), { userId: 'u1' });
    expect(notifications.notifyMissionCompleted).toHaveBeenCalledWith(expect.anything(), 'u1', 'Entrar na plataforma');
  });

  it('no refresh usa a chave diária no Redis (uma execução por utilizador por dia)', async () => {
    await missionsService.registerPresenceOncePerDay('u1');
    const [key, ttl] = cacheService.getOrSet.mock.calls[0];
    expect(key).toMatch(/^missions:presence:u1:\d{4}-\d{2}-\d{2}$/);
    expect(ttl).toBe(86400);
    expect(repository.completeLoginMissions).toHaveBeenCalledTimes(1);
  });
});
