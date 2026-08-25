import { api } from './client';

export const quizApi = {
  listCategories: () => api.get('/quiz/categories'),
  nextQuestion: (categoryId) => api.get(`/quiz/categories/${categoryId}/next-question`),
  submitAnswer: (data) => api.post('/quiz/answers', data),
};
