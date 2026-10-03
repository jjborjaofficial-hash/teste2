/**
 * BE-001: o teto de ganho diário (7,20 MZN) vale SÓ para as missões.
 * Testes unitários (sem banco): prémio de streak em dinheiro e conversão de
 * Pontos ficam fora do teto; sumEarningsToday soma apenas `mission_reward`.
 */
jest.mock('../src/config/database', () => ({ query: jest.fn(), getClient: jest.fn() }));
jest.mock('../src/common/repositories/systemConfigRepository', () => ({
  getConfigValue: jest.fn(),
  getConfigValues: jest.fn(),
}));
jest.mock('../src/modules/gamification/repositories/pointsLedgerRepository', () => ({
  debitPoints: jest.fn(),
}));
jest.mock('../src/modules/notifications/services/notificationsService', () => ({
  notifyPointsConverted: jest.fn(),
  notifyDailyEarningCapReached: jest.fn(),
  notifyMilestoneReached: jest.fn(),
}));
jest.mock('../src/common/cache/userCache', () => ({
  invalidateProfile: jest.fn(),
  invalidateStreak: jest.fn(),
}));

const db = require('../src/config/database');
const configRepository = require('../src/common/repositories/systemConfigRepository');
const pointsLedgerRepository = require('../src/modules/gamification/repositories/pointsLedgerRepository');
const walletRepository = require('../src/modules/wallet/repositories/walletRepository');

describe('walletRepository.sumEarningsToday', () => {
  it('soma só mission_reward (streak, conversão e boas-vindas ficam fora)', async () => {
    const executor = { query: jest.fn().mockResolvedValue({ rows: [{ total: '3.60' }] }) };
    const total = await walletRepository.sumEarningsToday('u1', executor);
    expect(total).toBe(3.6);
    const sql = executor.query.mock.calls[0][0];
    expect(sql).toContain("source = 'mission_reward'");
    expect(sql).not.toContain('points_conversion');
    expect(sql).not.toContain('streak_milestone');
  });
});

describe('walletService.convertPointsToMoney — fora do teto diário', () => {
  it('converte mesmo com o teto das missões já atingido (7,20 ganhos hoje)', async () => {
    const walletService = require('../src/modules/wallet/services/walletService');
    const sumSpy = jest.spyOn(walletRepository, 'sumEarningsToday').mockResolvedValue(7.2);
    jest.spyOn(walletRepository, 'getUserStatusAndTrustScore').mockResolvedValue({ status: 'active', trust_score: 80 });
    jest.spyOn(walletRepository, 'creditWallet').mockResolvedValue({ balance_after: '17.20', created_at: 'agora' });
    configRepository.getConfigValue.mockImplementation(async (key) =>
      ({ points_conversion_rate_points: 1000, points_conversion_rate_mzn: 10, min_trust_score_for_conversion: 60 })[key]
    );
    pointsLedgerRepository.debitPoints.mockResolvedValue({ id: 'p1', balanceAfter: 0 });
    const client = { query: jest.fn().mockResolvedValue({}), release: jest.fn() };
    db.getClient.mockResolvedValue(client);

    const result = await walletService.convertPointsToMoney({ userId: 'u1', pointsAmount: 1000 });

    expect(result.amountMzn).toBe(10);
    expect(sumSpy).not.toHaveBeenCalled(); // nem consulta o teto
    expect(walletRepository.creditWallet).toHaveBeenCalled();
  });
});

describe('streak: prémio em dinheiro fora do teto', () => {
  it('chama creditReward com ignoreDailyCap: true no marco de 30 dias', async () => {
    jest.resetModules();
    jest.doMock('../src/modules/gamification/repositories/gamificationRepository', () => ({
      getStreak: jest.fn().mockResolvedValue({
        user_id: 'u1',
        current_streak_days: 29,
        longest_streak_days: 29,
        last_activity_date: new Date('2026-10-09T00:00:00Z'),
        protection_active: false,
        broken_at: null,
        pre_break_streak_days: null,
      }),
      updateStreak: jest.fn(),
    }));
    jest.doMock('../src/modules/gamification/services/xpService', () => ({ addXpAndPoints: jest.fn() }));
    jest.doMock('../src/common/repositories/systemConfigRepository', () => ({
      getConfigValues: jest.fn().mockResolvedValue({
        streak_milestone_30_points: '150',
        streak_milestone_30_money_mzn: '2.00',
      }),
    }));
    const creditReward = jest.fn();
    jest.doMock('../src/modules/wallet/services/walletService', () => ({ creditReward }));
    jest.doMock('../src/common/time/platformTimezone', () => ({
      ...jest.requireActual('../src/common/time/platformTimezone'),
      todayInPlatformTz: () => '2026-10-10',
    }));

    const { registerDailyActivity } = require('../src/modules/gamification/services/streakService');
    const r = await registerDailyActivity({}, 'u1');

    expect(r.milestoneReached.moneyGrantedMzn).toBe(2);
    expect(creditReward).toHaveBeenCalledWith(
      expect.objectContaining({ amountMzn: 2, source: 'streak_milestone_30', ignoreDailyCap: true }),
      expect.anything()
    );
  });
});
