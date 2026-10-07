const { Router } = require('express');
const controller = require('../controllers/quizController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { submitAnswerSchema, startRoundSchema } = require('../validators/quizValidators');

const router = Router();

router.get('/categories', authenticate, controller.listCategories);
router.get('/categories/:categoryId/next-question', authenticate, controller.getNextQuestion);
// Rodadas (quiz v2): o servidor escolhe as 10 perguntas e guarda o progresso.
router.post('/rounds', authenticate, validate(startRoundSchema), controller.startRound);
router.get('/rounds/active', authenticate, controller.getActiveRound);
router.get('/rounds/:roundId/question', authenticate, controller.getRoundQuestion);
// BE-005 c: reabrir o resumo de uma rodada terminada e listar os conceitos a rever (só do próprio utilizador).
router.get('/rounds/:roundId/summary', authenticate, controller.getRoundSummary);
router.get('/review/recommendations', authenticate, controller.getReviewRecommendations);
router.post('/answers', authenticate, validate(submitAnswerSchema), controller.submitAnswer);

module.exports = router;
