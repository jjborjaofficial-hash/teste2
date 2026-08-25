const redis = require('../../../config/redis');
const logger = require('../../../common/logger');

/**
 * Cronômetro antifraude do Quiz — SERVIDOR é a única fonte de verdade sobre o
 * tempo de resposta (Doc. Mestre Seção 19.4: "ferramenta antifraude vital que
 * impede o usuário de pesquisar as respostas no Google").
 *
 * ANTES: o cliente informava `responseTimeMs` no corpo da requisição e o
 * backend confiava nesse valor cegamente — um script podia sempre enviar um
 * valor conveniente (ex.: 401ms) e vencer tanto a checagem de tempo esgotado
 * quanto a de "resposta suspeitosamente rápida", não importa quanto tempo
 * realmente levou.
 *
 * AGORA: quando a pergunta é entregue (getNextQuestion), o backend grava seu
 * próprio timestamp no Redis. Quando a resposta chega (submitAnswer), o
 * backend calcula o tempo decorrido sozinho, sem depender de nada que o
 * cliente informe. Se o registro não existir (expirado ou nunca solicitado
 * por este endpoint), a resposta é tratada como tempo esgotado por padrão —
 * fail-safe a favor da integridade, nunca a favor do usuário.
 *
 * TTL da chave = time_limit_seconds da pergunta + margem de rede, para não
 * expirar antes da hora em conexões lentas, mas também não ficar vivo
 * indefinidamente ocupando memória do Redis.
 */

const NETWORK_GRACE_SECONDS = 10;

function buildKey(userId, questionId) {
  return `quiz:issued:${userId}:${questionId}`;
}

/**
 * Registra o instante exato (server-side) em que a pergunta foi entregue ao
 * usuário. Chamado sempre que getNextQuestion devolve uma pergunta.
 */
async function markQuestionIssued(userId, questionId, timeLimitSeconds) {
  const key = buildKey(userId, questionId);
  const issuedAtMs = Date.now();
  const ttlSeconds = Math.max(timeLimitSeconds + NETWORK_GRACE_SECONDS, 5);

  try {
    await redis.set(key, String(issuedAtMs), 'EX', ttlSeconds);
  } catch (err) {
    // Se o Redis cair, não travamos a entrega da pergunta (mesmo princípio de
    // degradação graciosa usado no resto do projeto) — mas registramos o
    // ocorrido, porque isso enfraquece o antifraude enquanto durar.
    logger.warn('Não foi possível gravar o timestamp antifraude do quiz no Redis', {
      userId,
      questionId,
      error: err.message,
    });
  }

  return issuedAtMs;
}

/**
 * Calcula o tempo de resposta real, medido inteiramente pelo servidor, e
 * consome o registro (uma pergunta só pode ser respondida uma vez com este
 * timestamp — evita reuso do mesmo "issued_at" para múltiplas tentativas).
 *
 * Retorna `null` se não houver registro válido (expirado, nunca emitido, ou
 * Redis indisponível) — quem chama deve tratar isso como tempo esgotado.
 */
async function consumeElapsedMs(userId, questionId) {
  const key = buildKey(userId, questionId);

  try {
    const issuedAtRaw = await redis.get(key);
    if (!issuedAtRaw) return null;

    await redis.del(key);

    const issuedAtMs = Number(issuedAtRaw);
    const elapsedMs = Date.now() - issuedAtMs;
    return Math.max(elapsedMs, 0);
  } catch (err) {
    logger.warn('Não foi possível ler o timestamp antifraude do quiz no Redis', {
      userId,
      questionId,
      error: err.message,
    });
    return null;
  }
}

module.exports = { markQuestionIssued, consumeElapsedMs };
