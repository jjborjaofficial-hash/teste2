const quizService = require('../services/quizService');

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
    const { questionId, alternativeId } = req.validatedBody;
    const result = await quizService.submitAnswer({
      userId: req.user.id,
      questionId,
      alternativeId,
    });

    return res.status(200).json({
      status: 'success',
      message: result.isCorrect ? 'Correto!' : 'Resposta incorreta.',
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function getRoundSummary(req, res, next) {
  try {
    const summary = await quizService.getRoundSummary({ userId: req.user.id, roundId: req.params.roundId });
    return res.status(200).json({ status: 'success', message: null, data: summary });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listCategories, getNextQuestion, submitAnswer, getRoundSummary };
