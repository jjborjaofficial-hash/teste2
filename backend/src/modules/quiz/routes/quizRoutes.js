const { Router } = require('express');
const controller = require('../controllers/quizController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { submitAnswerSchema } = require('../validators/quizValidators');

const router = Router();

router.get('/categories', authenticate, controller.listCategories);
router.get('/categories/:categoryId/next-question', authenticate, controller.getNextQuestion);
router.post('/answers', authenticate, validate(submitAnswerSchema), controller.submitAnswer);

module.exports = router;
