const logger = require('../logger');

/**
 * SMS real, hoje via Twilio (mas isolado atrás desta função para trocar de
 * provedor sem tocar em quem chama — Manual Parte 3: "toda integração
 * externa deve permanecer isolada... criar uma camada específica").
 *
 * DEGRADAÇÃO GRACIOSA: sem TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN /
 * TWILIO_FROM_NUMBER, este serviço não lança erro — só registra em log que o
 * SMS foi pulado.
 *
 * NO DIA QUE HOUVER CREDENCIAL:
 * 1. `npm install twilio` (já está no package.json).
 * 2. Preencher as 3 variáveis de ambiente acima.
 * 3. Nada mais muda.
 *
 * Números moçambicanos (M-Pesa 84/85, e-Mola 86/87) precisam do prefixo
 * internacional +258 para o Twilio aceitar — `formatMozambiquePhone` cuida
 * disso, já que `users.phone` é armazenado sem o +258 (ver authValidators.js).
 */

function formatMozambiquePhone(phone) {
  const digits = phone.replace(/\D/g, '');
  if (digits.startsWith('258')) return `+${digits}`;
  return `+258${digits}`;
}

let twilioClient = null;
let initAttempted = false;

function getTwilioClient() {
  if (initAttempted) return twilioClient;
  initAttempted = true;

  const { TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER } = process.env;
  if (!TWILIO_ACCOUNT_SID || !TWILIO_AUTH_TOKEN || !TWILIO_FROM_NUMBER) {
    logger.info('smsService: credenciais do Twilio ausentes — SMS desativado (modo silencioso).');
    return null;
  }

  try {
    // eslint-disable-next-line global-require
    const twilio = require('twilio');
    twilioClient = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);
    logger.info('smsService: cliente Twilio inicializado com sucesso.');
  } catch (err) {
    logger.warn('smsService: falha ao inicializar Twilio (pacote instalado?)', { error: err.message });
    twilioClient = null;
  }

  return twilioClient;
}

async function sendSms(phone, message) {
  const client = getTwilioClient();
  if (!client) return { sent: false, skipped: true };

  try {
    await client.messages.create({
      to: formatMozambiquePhone(phone),
      from: process.env.TWILIO_FROM_NUMBER,
      body: message,
    });
    return { sent: true, skipped: false };
  } catch (err) {
    logger.error('smsService: falha ao enviar SMS', { error: err.message });
    return { sent: false, skipped: false, error: err.message };
  }
}

module.exports = { sendSms, formatMozambiquePhone };
