const service = require('../services/adminQuizService');

async function listCategories(req, res, next) {
  try {
    const categories = await service.listCategories();
    return res.status(200).json({ status: 'success', message: null, data: categories });
  } catch (err) {
    return next(err);
  }
}

async function createCategory(req, res, next) {
  try {
    const created = await service.createCategory(req.validatedBody);
    return res.status(201).json({ status: 'success', message: 'Categoria criada.', data: created });
  } catch (err) {
    return next(err);
  }
}

async function updateCategory(req, res, next) {
  try {
    const updated = await service.updateCategory(req.params.categoryId, req.validatedBody);
    return res.status(200).json({ status: 'success', message: 'Categoria atualizada.', data: updated });
  } catch (err) {
    return next(err);
  }
}

async function listQuestions(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;
    const questions = await service.listQuestions(req.params.categoryId, { limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: questions });
  } catch (err) {
    return next(err);
  }
}

async function getQuestion(req, res, next) {
  try {
    const question = await service.getQuestion(req.params.questionId);
    return res.status(200).json({ status: 'success', message: null, data: question });
  } catch (err) {
    return next(err);
  }
}

async function createQuestion(req, res, next) {
  try {
    const created = await service.createQuestion(req.validatedBody);
    return res.status(201).json({ status: 'success', message: 'Pergunta criada.', data: created });
  } catch (err) {
    return next(err);
  }
}

async function updateQuestion(req, res, next) {
  try {
    const updated = await service.updateQuestion(req.params.questionId, req.validatedBody);
    return res.status(200).json({ status: 'success', message: 'Pergunta atualizada.', data: updated });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listCategories, createCategory, updateCategory, listQuestions, getQuestion, createQuestion, updateQuestion };
