import { api } from './client';

/**
 * Central Jurídica — consumo público e de usuário autenticado
 * (docx "final jur.." Partes 2, 3, 5, 8, 11.4 e 12).
 */
export const legalApi = {
  listDocuments: () => api.get('/legal/documents', { auth: false }),
  getDocument: (type) => api.get(`/legal/documents/${type}`, { auth: false }),

  getPending: () => api.get('/legal/pending'),
  acceptMandatory: () => api.post('/legal/accept'),
  myAcceptances: () => api.get('/legal/my-acceptances'),

  getCookiePreferences: () => api.get('/legal/cookies'),
  setCookiePreferences: (choices) => api.post('/legal/cookies', choices),

  createRequest: (data) => api.post('/legal/requests', data),
  listMyRequests: () => api.get('/legal/requests'),

  createAppeal: (data) => api.post('/legal/appeals', data),
  listMyAppeals: () => api.get('/legal/appeals'),
};
