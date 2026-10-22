import { api } from './client';

export const adminAccessApi = {
  status: () => api.get('/admin-access/status'),
  setPassword: (data) => api.post('/admin-access/set-password', data),
  unlock: (data) => api.post('/admin-access/unlock', data),
};
