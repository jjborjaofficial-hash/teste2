const quizService = require('../services/quizService');
const { ValidationError } = require('../../../common/errors/AppError');
const { roundIdParamSchema, recommendationsQuerySchema } = require('../validators/quizValidators');

async function listCategories(req, res, next) {
  try {
    const categories = await quizService.listCategories();
    return res.status(200).json({ status: 'success', message: null, data: categories });
  } catch (err) {
    return next(err);
  }
}

async function getNextQuestion(req, res, next) {
  try {
    const question = await quizService.getNextQuestion(req.params.categoryId, req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: question });
  } catch (err) {
    return next(err);
  }
}

async function submitAnswer(req, res, next) {
  try {
    const { questionId, alternativeId, roundId } = req.validatedBody;
    const result = await quizService.submitAnswer({
      userId: req.user.id,
      questionId,
      alternativeId,
      roundId,
    });

    return res.status(200).json({
      status: 'success',
      message: result.isCorrect
        ? 'Resposta certa! Muito bem.'
        : 'Não foi desta vez. Veja a explicação e tente a próxima.',
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function startRound(req, res, next) {
  try {
    const round = await quizService.startRound({
      userId: req.user.id,
      categoryId: req.validatedBody.categoryId,
    });
    return res.status(200).json({ status: 'success', message: null, data: round });
  } catch (err) {
    return next(err);
  }
}

async function getActiveRound(req, res, next) {
  try {
    const round = await quizService.getActiveRoundState(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: round });
  } catch (err) {
    return next(err);
  }
}

async function getRoundQuestion(req, res, next) {
  try {
    const question = await quizService.getRoundQuestion({
      userId: req.user.id,
      roundId: req.params.roundId,
    });
    return res.status(200).json({ status: 'success', message: null, data: question });
  } catch (err) {
    return next(err);
  }
}

function parseOrFail(schema, input) {
  const result = schema.safeParse(input);
  if (!result.success) {
    throw new ValidationError(
      'Dados inválidos',
      result.error.issues.map((i) => ({ field: i.path.join('.'), message: i.message }))
    );
  }
  return result.data;
}

async function getRoundSummary(req, res, next) {
  try {
    const { roundId } = parseOrFail(roundIdParamSchema, req.params);
    const summary = await quizService.getRoundSummary({ userId: req.user.id, roundId });
    return res.status(200).json({ status: 'success', message: null, data: summary });
  } catch (err) {
    return next(err);
  }
}

async function getReviewRecommendations(req, res, next) {
  try {
    const { categoryId, limit } = parseOrFail(recommendationsQuerySchema, req.query);
    const items = await quizService.getReviewRecommendations({ userId: req.user.id, categoryId: categoryId || null, limit });
    return res.status(200).json({ status: 'success', message: null, data: items });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listCategories,
  getNextQuestion,
  submitAnswer,
  startRound,
  getActiveRound,
  getRoundQuestion,
  getRoundSummary,
  getReviewRecommendations,
};
