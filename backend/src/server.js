require('dotenv').config();
const app = require('./app');
const logger = require('./common/logger');
const { pool, verifyConnection } = require('./config/database');

const PORT = process.env.PORT || 3000;

// Segurança de Credenciais (docs/seguranca-credenciais-banco-de-dados.md, Seção 9):
// confirma a conexão com o banco ANTES de aceitar tráfego. Se as credenciais
// foram rotacionadas incorretamente (ex: .env não atualizado após a Etapa 2 do
// processo de rotação), o processo falha alto e cedo, em vez de aceitar
// requisições que vão falhar silenciosamente depois.
async function start() {
  const connected = await verifyConnection();
  if (!connected) {
    logger.error(
      'Não foi possível conectar ao banco de dados no boot. Verifique DATABASE_URL ' +
        '(ver docs/seguranca-credenciais-banco-de-dados.md). Encerrando processo.'
    );
    process.exit(1);
  }

  const server = app.listen(PORT, () => {
    logger.info(`Aprenda e Ganhe backend rodando na porta ${PORT}`, {
      env: process.env.NODE_ENV,
    });
  });

  // Encerramento gracioso: essencial para deploys sem downtime (Render/Docker)
  async function shutdown(signal) {
    logger.info(`Recebido ${signal}. Encerrando servidor graciosamente...`);
    server.close(async () => {
      await pool.end();
      logger.info('Conexões encerradas. Até logo.');
      process.exit(0);
    });

    // Failsafe: força encerramento se algo travar
    setTimeout(() => process.exit(1), 10000).unref();
  }

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

start();

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Rejection', { reason: reason?.message || reason });
});
