const logger = require('../logger');

/**
 * Push real via Firebase Cloud Messaging (FCM).
 *
 * DEGRADAÇÃO GRACIOSA (mesmo princípio de common/cache/cacheService.js):
 * enquanto as variáveis FIREBASE_PROJECT_ID / FIREBASE_CLIENT_EMAIL /
 * FIREBASE_PRIVATE_KEY não estiverem definidas, este serviço não lança erro
 * nenhum — apenas registra em log que o push foi "pulado", e a plataforma
 * continua funcionando 100% normalmente (a notificação já foi gravada em
 * `notifications` por quem chamou; push é só um canal extra).
 *
 * NO DIA QUE HOUVER CREDENCIAL (ver docs/notificacoes-push-sms.md):
 * 1. `npm install firebase-admin` (já está no package.json, só falta instalar).
 * 2. Preencher as 3 variáveis de ambiente citadas acima.
 * 3. Nada mais muda — este arquivo já está pronto para funcionar.
 */

let firebaseApp = null;
let initAttempted = false;

function getFirebaseApp() {
  if (initAttempted) return firebaseApp;
  initAttempted = true;

  const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } = process.env;
  if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
    logger.info('pushService: credenciais do Firebase ausentes — push desativado (modo silencioso).');
    return null;
  }

  try {
    // require() só acontece aqui dentro, de propósito: se `firebase-admin`
    // ainda não tiver sido instalado (`npm install`), o resto do backend
    // continua funcionando normalmente — só o push fica inativo.
    // eslint-disable-next-line global-require
    const admin = require('firebase-admin');
    firebaseApp = admin.apps.length
      ? admin.app()
      : admin.initializeApp({
          credential: admin.credential.cert({
            projectId: FIREBASE_PROJECT_ID,
            clientEmail: FIREBASE_CLIENT_EMAIL,
            // No .env, quebras de linha da chave privada vêm como "\\n" literal;
            // aqui convertemos de volta para quebras de linha reais.
            privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
          }),
        });
    logger.info('pushService: Firebase Admin inicializado com sucesso.');
  } catch (err) {
    logger.warn('pushService: falha ao inicializar Firebase Admin (pacote instalado?)', { error: err.message });
    firebaseApp = null;
  }

  return firebaseApp;
}

/**
 * Envia uma notificação push para TODOS os tokens registrados de um usuário
 * (pode ter mais de um dispositivo/navegador). Tokens que o FCM reportar como
 * inválidos/expirados são removidos automaticamente do banco — sem isso, a
 * tabela `push_tokens` acumularia lixo para sempre.
 */
async function sendToUser(userId, { title, body, data = {} }, tokensRepository) {
  const app = getFirebaseApp();
  if (!app) return { sent: 0, skipped: true };

  const tokens = await tokensRepository.listTokensByUser(userId);
  if (tokens.length === 0) return { sent: 0, skipped: false };

  // eslint-disable-next-line global-require
  const admin = require('firebase-admin');
  const message = {
    notification: { title, body },
    data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
    tokens: tokens.map((t) => t.token),
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);

    const invalidTokens = [];
    response.responses.forEach((r, i) => {
      if (!r.success && ['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(r.error?.code)) {
        invalidTokens.push(tokens[i].token);
      }
    });
    if (invalidTokens.length > 0) {
      await tokensRepository.deleteTokens(invalidTokens);
    }

    return { sent: response.successCount, skipped: false };
  } catch (err) {
    logger.error('pushService: falha ao enviar push', { userId, error: err.message });
    return { sent: 0, skipped: false, error: err.message };
  }
}

module.exports = { sendToUser };
