import { api } from './client';

/**
 * Loja de Pontos (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 3).
 */
export const shopApi = {
  listItems: () => api.get('/shop/items'),
  purchase: (itemKey) => api.post('/shop/purchase', { itemKey }),
  equip: (itemKey) => api.post('/shop/equip', { itemKey }),
  unequip: (slot) => api.post('/shop/unequip', { slot }),
  getInventory: () => api.get('/shop/inventory'),
  getPointsLedger: () => api.get('/shop/points-ledger'),
  // Tema Noite emprestado por 10 minutos (GER-002)
  getThemeTrial: () => api.get('/shop/theme-trial'),
  startThemeTrial: () => api.post('/shop/theme-trial/start'),
  dismissThemeTrialIntro: () => api.post('/shop/theme-trial/dismiss'),
};
