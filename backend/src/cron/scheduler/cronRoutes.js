/**
 * Rotas internas para um agendador EXTERNO gratuito (cron-job.org, GitHub Actions, UptimeRobot...) "tocar"
 * o backend a cada poucos minutos: isso acorda o servidor gratuito do Render e corre as tarefas devidas.
 * Protegidas por segredo (header `x-cron-secret` = variável CRON_SECRET). Sem CRON_SECRET (ou curto demais),
 * as rotas ficam desligadas (404).
 */
const crypto = require('crypto');
const express = require('express');
const logger = require('../../common/logger');
const { runDueJobs, getStatus } = require('./runDueJobs');

const router = express.Router();

function requireSecret(req, res, next) {
  const secret = process.env.CRON_SECRET;
  if (!secret || secret.length < 24) return res.status(404).json({ error: 'Não encontrado.' });
  const given = Buffer.from(req.get('x-cron-secret') || '');
  const expected = Buffer.from(secret);
  if (given.length !== expected.length || !crypto.timingSafeEqual(given, expected)) {
    return res.status(401).json({ error: 'Não autorizado.' });
  }
  return next();
}

// POST /internal/cron/tick  -> responde logo (202) e corre as tarefas em segundo plano.
// Com ?wait=1 espera o fim e devolve o resultado (útil para testar à mão).
router.post('/tick', requireSecret, async (req, res) => {
  if (req.query.wait === '1') {
    try {
      return res.json(await runDueJobs());
    } catch (err) {
      logger.error('CRON-TICK: falha', { error: err.message });
      return res.status(500).json({ error: 'Falha ao correr as tarefas.' });
    }
  }
  runDueJobs().catch((err) => logger.error('CRON-TICK: falha', { error: err.message }));
  return res.status(202).json({ accepted: true });
});

// GET /internal/cron/status -> última execução, próxima e último erro de cada tarefa.
router.get('/status', requireSecret, async (req, res) => {
  try {
    return res.json(await getStatus());
  } catch (err) {
    logger.error('CRON-TICK: falha ao ler o estado', { error: err.message });
    return res.status(500).json({ error: 'Falha ao ler o estado.' });
  }
});

module.exports = router;
