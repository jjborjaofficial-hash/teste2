import { api } from './client';

export const usersApi = {
  me: () => api.get('/users/me'),
};

export const gamificationApi = {
  me: () => api.get('/gamification/me'),
};

export const trustScoreApi = {
  me: () => api.get('/trust-score/me'),
};
