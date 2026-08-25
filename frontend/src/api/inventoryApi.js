import { api } from './client';

/**
 * "Meus Recursos" (spec Seções 34-60). Rota própria /inventory — separada de
 * /shop/inventory, que já existe e mostra histórico de compras/equipados
 * (propósito diferente, nomes parecidos por coincidência — ver backend
 * src/modules/shop/routes/inventoryRoutes.js).
 */
export const inventoryApi = {
  list: () => api.get('/inventory'),
  activate: (inventoryId) => api.post(`/inventory/${inventoryId}/activate`),
  use: (inventoryId) => api.post(`/inventory/${inventoryId}/use`),
};
