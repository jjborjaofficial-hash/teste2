import { api } from './client';

export const authApi = {
  register: (data) => api.post('/auth/register', data, { auth: false }),
  login: (data) => api.post('/auth/login', data, { auth: false }),
  // idToken vem do Google Identity Services (ver components/GoogleLoginButton).
  loginWithGoogle: (idToken, referralCode) =>
    api.post('/auth/google', { idToken, ...(referralCode ? { referralCode } : {}) }, { auth: false }),
  // Recuperação sem SMS: liga o Google à conta (com sessão) e redefine a senha entrando com ele (sem sessão).
  linkGoogle: (idToken) => api.post('/auth/link-google', { idToken }),
  recoverWithGoogle: (idToken, newPassword) =>
    api.post('/auth/recover-with-google', { idToken, newPassword }, { auth: false }),
  // Pedida logo após o primeiro login via Google (conta nasce sem telefone).
  completeProfile: (data) => api.post('/auth/complete-profile', data),
  // O refresh token não passa mais por aqui — vai no cookie httpOnly que o
  // navegador já anexa sozinho à requisição.
  logout: () => api.post('/auth/logout', undefined, { auth: false }),
  acceptTerms: () => api.post('/auth/accept-terms'),
};
