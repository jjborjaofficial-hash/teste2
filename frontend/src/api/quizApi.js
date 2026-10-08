import { api } from './client';

export const quizApi = {
  listCategories: () => api.get('/quiz/categories'),
  // Rodadas (quiz v2): o servidor escolhe as 10 perguntas e guarda o progresso.
  startRound: (categoryId) => api.post('/quiz/rounds', { categoryId }),
  roundQuestion: (roundId) => api.get(`/quiz/rounds/${roundId}/question`),
  // O que rever: perguntas erradas em rodadas e ainda não acertadas (limite 1 a 20).
  reviewRecommendations: (limit = 10) => api.get(`/quiz/review/recommendations?limit=${limit}`),
  submitAnswer: (data) => api.post('/quiz/answers', data),
};
