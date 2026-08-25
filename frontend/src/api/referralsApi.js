import { api } from './client';

/**
 * Convites/Indicações (Manual Parte 3). Ambos os endpoints já existiam prontos
 * no backend — o gap era 100% de frontend: nada aqui chamava essa API ainda.
 */
export const referralsApi = {
  getMyCode: () => api.get('/referrals/me/code'),
  listMyReferrals: () => api.get('/referrals/me'),
};
