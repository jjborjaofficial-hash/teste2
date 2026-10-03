/**
 * Teste unitário (sem banco) da regra do item de proteção do streak:
 * perdoa EXATAMENTE um dia perdido. Faltou 2 dias ou mais -> o streak quebra e
 * o item continua guardado. Mesma regra do CRON enforceStreakExpiry e de
 * reconcileExpiredStreak.
 */
jest.mock('../src/modules/gamification/repositories/gamificationRepository', () => ({
  getStreak: jest.fn(),
  updateStreak: jest.fn(),
}));
jest.mock('../src/modules/gamification/services/xpService', () => ({ addXpAndPoints: jest.fn() }));
jest.mock('../src/common/repositories/systemConfigRepository', () => ({
  getConfigValues: jest.fn().mockResolvedValue({}),
}));
jest.mock('../src/modules/wallet/services/walletService', () => ({ creditReward: jest.fn() }));
jest.mock('../src/modules/notifications/services/notificationsService', () => ({
  notifyMilestoneReached: jest.fn(),
}));
jest.mock('../src/common/cache/userCache', () => ({ invalidateStreak: jest.fn() }));
jest.mock('../src/common/time/platformTimezone', () => ({
  ...jest.requireActual('../src/common/time/platformTimezone'),
  todayInPlatformTz: () => '2026-10-10',
}));

const repository = require('../src/modules/gamification/repositories/gamificationRepository');
const { registerDailyActivity } = require('../src/modules/gamification/services/streakService');

function streakRow({ lastActivity, protection, current = 20 }) {
  return {
    user_id: 'u1',
    current_streak_days: current,
    longest_streak_days: current,
    last_activity_date: new Date(`${lastActivity}T00:00:00Z`),
    protection_active: protection,
    broken_at: null,
    pre_break_streak_days: null,
  };
}

describe('registerDailyActivity — item de proteção do streak', () => {
  beforeEach(() => jest.clearAllMocks());

  it('sem faltar: segue o streak e mantém a proteção', async () => {
    repository.getStreak.mockResolvedValue(streakRow({ lastActivity: '2026-10-09', protection: true }));
    const r = await registerDailyActivity({}, 'u1');
    expect(r.streak.currentStreakDays).toBe(21);
    expect(r.streak.protectionConsumedToday).toBe(false);
    expect(repository.updateStreak.mock.calls[0][1].protectionActive).toBe(true);
  });

  it('faltou 1 dia com proteção: perdoa, segue o streak e consome o item', async () => {
    repository.getStreak.mockResolvedValue(streakRow({ lastActivity: '2026-10-08', protection: true }));
    const r = await registerDailyActivity({}, 'u1');
    expect(r.streak.currentStreakDays).toBe(21);
    expect(r.streak.protectionConsumedToday).toBe(true);
    expect(repository.updateStreak.mock.calls[0][1].protectionActive).toBe(false);
  });

  it('faltou 1 dia sem proteção: quebra', async () => {
    repository.getStreak.mockResolvedValue(streakRow({ lastActivity: '2026-10-08', protection: false }));
    const r = await registerDailyActivity({}, 'u1');
    expect(r.streak.currentStreakDays).toBe(1);
    expect(r.streak.protectionConsumedToday).toBe(false);
  });

  it.each([3, 4, 10])('última atividade há %i dias (faltou 2+ dias) com proteção: quebra e guarda o item', async (daysSince) => {
    const d = new Date('2026-10-10T00:00:00Z');
    d.setUTCDate(d.getUTCDate() - daysSince);
    repository.getStreak.mockResolvedValue(
      streakRow({ lastActivity: d.toISOString().slice(0, 10), protection: true })
    );
    const r = await registerDailyActivity({}, 'u1');
    expect(r.streak.currentStreakDays).toBe(1);
    expect(r.streak.protectionConsumedToday).toBe(false);
    expect(repository.updateStreak.mock.calls[0][1].protectionActive).toBe(true);
  });
});
