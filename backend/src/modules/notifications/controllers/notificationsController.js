const notificationsService = require('../services/notificationsService');

async function listMine(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const unreadOnly = req.query.unreadOnly === 'true';
    const notifications = await notificationsService.listMyNotifications(req.user.id, {
      limit,
      offset,
      unreadOnly,
    });
    return res.status(200).json({ status: 'success', message: null, data: notifications });
  } catch (err) {
    return next(err);
  }
}

async function unreadCount(req, res, next) {
  try {
    const count = await notificationsService.getUnreadCount(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: { count } });
  } catch (err) {
    return next(err);
  }
}

async function markAsRead(req, res, next) {
  try {
    const result = await notificationsService.markAsRead(req.user.id, req.params.notificationId);
    if (!result) {
      return res.status(200).json({
        status: 'success',
        message: 'Notificação já estava marcada como lida ou não existe.',
        data: null,
      });
    }
    return res.status(200).json({ status: 'success', message: 'Notificação marcada como lida.', data: null });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listMine, unreadCount, markAsRead };
