/**
 * O saque mínimo vem do servidor (system_config `withdrawal_min_mzn`): GET /wallet devolve
 * `withdrawalMinMzn`, e o pedido de saque usa o MESMO valor (uma só fonte).
 */
jest.mock('../src/config/database', () => ({ query: jest.fn(), getClient: jest.fn() }));
jest.mock('../src/common/repositories/systemConfigRepository', () => ({
  getConfigValue: jest.fn(),
  getConfigValues: jest.fn(),
}));
jest.mock('../src/modules/wallet/repositories/walletRepository', () => ({
  getWalletBalance: jest.fn(),
}));

const configRepository = require('../src/common/repositories/systemConfigRepository');
const walletRepository = require('../src/modules/wallet/repositories/walletRepository');
const walletService = require('../src/modules/wallet/services/walletService');

describe('saque mínimo vindo da API', () => {
  beforeEach(() => jest.clearAllMocks());

  it('getBalance devolve o mínimo configurado no servidor', async () => {
    walletRepository.getWalletBalance.mockResolvedValue(42.5);
    configRepository.getConfigValue.mockResolvedValue('150.00');
    const res = await walletService.getBalance('u1');
    expect(configRepository.getConfigValue).toHaveBeenCalledWith('withdrawal_min_mzn');
    expect(res).toEqual({ walletBalanceMzn: 42.5, withdrawalMinMzn: 150 });
  });

  it('sem valor configurado, usa 100 MZN', async () => {
    walletRepository.getWalletBalance.mockResolvedValue(0);
    configRepository.getConfigValue.mockResolvedValue(null);
    const res = await walletService.getBalance('u1');
    expect(res.withdrawalMinMzn).toBe(100);
  });

  it('o pedido de saque abaixo do mínimo configurado é recusado com esse mesmo valor', async () => {
    configRepository.getConfigValue.mockResolvedValue('150.00');
    await expect(
      walletService.requestWithdrawal({ userId: 'u1', amountMzn: 120, method: 'mpesa' })
    ).rejects.toThrow('150.00');
  });
});
