import { api } from './client';

export const authApi = {
  register: (data) => api.post('/auth/register', data, { auth: false }),
  login: (data) => api.post('/auth/login', data, { auth: false }),
  // O refresh token não passa mais por aqui — vai no cookie httpOnly que o
  // navegador já anexa sozinho à requisição.
  logout: () => api.post('/auth/logout', undefined, { auth: false }),
  acceptTerms: () => api.post('/auth/accept-terms'),
};
