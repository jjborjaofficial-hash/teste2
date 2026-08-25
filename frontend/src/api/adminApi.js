import { api } from './client';

export const adminApi = {
  listWithdrawals: (status = 'pending_review') => api.get(`/admin/withdrawals?status=${status}`),
  getWithdrawalDetail: (id) => api.get(`/admin/withdrawals/${id}`),
  approveWithdrawal: (id) => api.post(`/admin/withdrawals/${id}/approve`),
  rejectWithdrawal: (id, reason) => api.post(`/admin/withdrawals/${id}/reject`, { reason }),
  suspendWithdrawalForReview: (id, reason) => api.post(`/admin/withdrawals/${id}/suspend-for-review`, { reason }),
  cancelWithdrawal: (id, reason) => api.post(`/admin/withdrawals/${id}/cancel`, { reason }),
  markWithdrawalAsPaid: (id) => api.post(`/admin/withdrawals/${id}/mark-paid`),

  listUsers: (search) => api.get(`/admin/users${search ? `?search=${encodeURIComponent(search)}` : ''}`),
  adjustTrustScore: (userId, data) => api.post(`/admin/users/${userId}/trust-score/adjust`, data),
  setUserStatus: (userId, status) => api.post(`/admin/users/${userId}/status`, { status }),
  setUserRole: (userId, role) => api.post(`/admin/users/${userId}/role`, { role }),

  listAuditLogs: () => api.get('/admin/audit-logs'),
  listDailyReports: (limit) => api.get(`/admin/reports/daily${limit ? `?limit=${limit}` : ''}`),
};

// Painel Administrativo — Loja de Pontos (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 14)
export const adminShopApi = {
  listItems: () => api.get('/admin/shop/items'),
  createItem: (data) => api.post('/admin/shop/items', data),
  updateItem: (itemId, data) => api.post(`/admin/shop/items/${itemId}`, data),
  listPurchases: () => api.get('/admin/shop/purchases'),
};

// Painel Administrativo — Gestão de Conteúdo (Categorias e Perguntas do Quiz)
export const adminQuizApi = {
  listCategories: () => api.get('/admin/quiz/categories'),
  createCategory: (data) => api.post('/admin/quiz/categories', data),
  updateCategory: (categoryId, data) => api.post(`/admin/quiz/categories/${categoryId}`, data),
  listQuestions: (categoryId) => api.get(`/admin/quiz/categories/${categoryId}/questions`),
  getQuestion: (questionId) => api.get(`/admin/quiz/questions/${questionId}`),
  createQuestion: (data) => api.post('/admin/quiz/questions', data),
  updateQuestion: (questionId, data) => api.post(`/admin/quiz/questions/${questionId}`, data),
};

// Painel Administrativo — Gestão de Missões
export const adminMissionsApi = {
  list: () => api.get('/admin/missions'),
  create: (data) => api.post('/admin/missions', data),
  update: (missionId, data) => api.post(`/admin/missions/${missionId}`, data),
};

// Painel Administrativo — Módulo Jurídico e Compliance (docx "final jur.." Parte 11)
export const adminLegalApi = {
  listDocuments: () => api.get('/admin/legal/documents'),
  listVersions: (documentId) => api.get(`/admin/legal/documents/${documentId}/versions`),
  createVersion: (documentId, data) => api.post(`/admin/legal/documents/${documentId}/versions`, data),
  publishVersion: (documentId, versionId) =>
    api.post(`/admin/legal/documents/${documentId}/versions/${versionId}/publish`),
  getAcceptanceStats: (documentId) => api.get(`/admin/legal/documents/${documentId}/acceptance-stats`),
  listAcceptances: (documentId) => api.get(`/admin/legal/documents/${documentId}/acceptances`),

  listRequests: (status) => api.get(`/admin/legal/requests${status ? `?status=${status}` : ''}`),
  respondRequest: (requestId, data) => api.post(`/admin/legal/requests/${requestId}/respond`, data),

  listAppeals: (status) => api.get(`/admin/legal/appeals${status ? `?status=${status}` : ''}`),
  decideAppeal: (appealId, data) => api.post(`/admin/legal/appeals/${appealId}/decide`, data),
};
