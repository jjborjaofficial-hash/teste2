const { Router } = require('express');
const controller = require('../controllers/adminQuizController');
const authenticate = require('../../../middleware/authenticate');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const {
  createCategorySchema,
  updateCategorySchema,
  createQuestionSchema,
  updateQuestionSchema,
} = require('../validators/adminQuizValidators');

const router = Router();

// Gestão de Categorias e Perguntas — antes desta rota não existia NENHUMA
// forma de adicionar conteúdo além de editar o banco na mão (seed de dev).
router.use(authenticate);
router.use(requireRole('admin_suporte'));

router.get('/categories', controller.listCategories);
router.post('/categories', validate(createCategorySchema), controller.createCategory);
router.post('/categories/:categoryId', validate(updateCategorySchema), controller.updateCategory);

router.get('/categories/:categoryId/questions', controller.listQuestions);
router.get('/questions/:questionId', controller.getQuestion);
router.post('/questions', validate(createQuestionSchema), controller.createQuestion);
router.post('/questions/:questionId', validate(updateQuestionSchema), controller.updateQuestion);

module.exports = router;
