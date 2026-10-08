/**
 * Pagamento (claimReward): mesmo que exista por alguma via uma missão "completar rodada" com dinheiro,
 * o resgate NUNCA credita dinheiro por ela (só XP e Pontos). Quizzes continuam a pagar.
 * Unitário, com mocks (a regra do banco impede criar o caso real, então aqui simulamos que falhou).
 */
const mockClient = { query: jest.fn().mockResolvedValue({}), release: jest.fn() };
jest.mock('../src/config/database', () => ({ getClient: jest.fn(async () => mockClient), query: jest.fn() }));
jest.mock('../src/modules/missions/repositories/missionsRepository', () => ({
  getUserMissionById: jest.fn(),
  markRewardClaimed: jest.fn(),
}));
jest.mock('../src/modules/gamification/services/xpService', () => ({
  addXpAndPoints: jest.fn().mockResolvedValue({ xpCredited: 10, pointsCredited: 5, pointsBoostApplied: false }),
}));
jest.mock('../src/modules/wallet/services/walletService', () => ({
  creditReward: jest.fn().mockResolvedValue({ amountCreditedMzn: 2 }),
}));

const repository = require('../src/modules/missions/repositories/missionsRepository');
const walletService = require('../src/modules/wallet/services/walletService');
const missionsService = require('../src/modules/missions/services/missionsService');

const mission = (activity_type) => ({
  id: 'um1', status: 'completed', title: 'M', activity_type, xp_reward: 10, points_reward: 5, money_reward_mzn: '2.00',
});

beforeEach(() => jest.clearAllMocks());

describe('claimReward e dinheiro', () => {
  it('missão de rodada com dinheiro (caso impossível, simulado): paga XP e Pontos, mas NÃO dinheiro', async () => {
    repository.getUserMissionById.mockResolvedValue(mission('round_complete'));
    const r = await missionsService.claimReward('u1', 'um1');
    expect(walletService.creditReward).not.toHaveBeenCalled();
    expect(r.rewardsGranted.moneyMzn).toBe(0);
    expect(r.rewardsGranted.moneyNominalMzn).toBe(0);
    expect(r.rewardsGranted.xp).toBe(10);
    expect(r.rewardsGranted.points).toBe(5);
  });

  it('missão de quizzes com dinheiro: continua a pagar (controlo, nada foi quebrado)', async () => {
    repository.getUserMissionById.mockResolvedValue(mission('quiz_count'));
    const r = await missionsService.claimReward('u1', 'um1');
    expect(walletService.creditReward).toHaveBeenCalledWith(expect.objectContaining({ amountMzn: 2, source: 'mission_reward' }), mockClient);
    expect(r.rewardsGranted.moneyMzn).toBe(2);
  });
});
