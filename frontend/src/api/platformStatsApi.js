import { api } from './client';

/**
 * Estatísticas públicas da plataforma (prova social real do Onboarding e
 * do Dashboard). Rota sem autenticação no backend — funciona mesmo antes
 * do login.
 */
export const platformStatsApi = {
  getStats: () => api.get('/platform-stats', { auth: false }),
};
