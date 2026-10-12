import { api } from './client';

export const usersApi = {
  me: () => api.get('/users/me'),
  update: (data) => api.patch('/users/me', data),
  changePaymentPhone: (data) => api.put('/users/me/payment-phone', data),
  exportData: () => api.get('/users/me/export'),
  deleteAccount: (data) => api.delete('/users/me', data),
};

export const gamificationApi = {
  me: () => api.get('/gamification/me'),
  welcomeBonus: () => api.get('/gamification/welcome-bonus'),
  claimWelcomeBonus: () => api.post('/gamification/welcome-bonus/claim'),
};

export const trustScoreApi = {
  me: () => api.get('/trust-score/me'),
};
