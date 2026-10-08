import { api } from './client';

export const quizApi = {
  listCategories: () => api.get('/quiz/categories'),
  // Rodadas (quiz v2): o servidor escolhe as 10 perguntas e guarda o progresso.
  startRound: (categoryId) => api.post('/quiz/rounds', { categoryId }),
  roundQuestion: (roundId) => api.get(`/quiz/rounds/${roundId}/question`),
  submitAnswer: (data) => api.post('/quiz/answers', data),
  // Conceitos que o utilizador errou e ainda não acertou (BE-005 c). categoryId é opcional.
  reviewRecommendations: ({ categoryId, limit } = {}) => {
    const params = new URLSearchParams();
    if (categoryId) params.set('categoryId', categoryId);
    if (limit) params.set('limit', String(limit));
    const qs = params.toString();
    return api.get(`/quiz/review/recommendations${qs ? `?${qs}` : ''}`);
  },
};
