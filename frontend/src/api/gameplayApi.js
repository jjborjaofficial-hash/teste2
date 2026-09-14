import { api } from './client';

export const missionsApi = {
  listMine: () => api.get('/missions'),
  claim: (userMissionId) => api.post(`/missions/${userMissionId}/claim`),
};

export const walletApi = {
  getBalance: () => api.get('/wallet'),
  getHistory: () => api.get('/wallet/transactions'),
  requestWithdrawal: (data) => api.post('/wallet/withdrawals', data),
  getConversionRate: () => api.get('/wallet/convert-points/rate'),
  convertPoints: (data) => api.post('/wallet/convert-points', data),
};

export const rankingApi = {
  topWeekly: () => api.get('/ranking/weekly'),
  myPosition: () => api.get('/ranking/weekly/me'),
};

export const notificationsApi = {
  list: () => api.get('/notifications'),
  unreadCount: () => api.get('/notifications/unread-count'),
  markAsRead: (id) => api.post(`/notifications/${id}/read`),
  registerPushToken: (token, platform = 'web') => api.post('/notifications/push-tokens', { token, platform }),
  unregisterPushToken: (token) => api.delete('/notifications/push-tokens', { token }),
};
