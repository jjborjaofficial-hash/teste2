import { api } from './client';

export const quizApi = {
  listCategories: () => api.get('/quiz/categories'),
  // Rodadas (quiz v2): o servidor escolhe as 10 perguntas e guarda o progresso.
  startRound: (categoryId) => api.post('/quiz/rounds', { categoryId }),
  roundQuestion: (roundId) => api.get(`/quiz/rounds/${roundId}/question`),
  submitAnswer: (data) => api.post('/quiz/answers', data),
};
