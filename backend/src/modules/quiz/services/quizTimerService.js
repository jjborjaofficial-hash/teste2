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
 *
 * CORREÇÃO (F5 reinicia o relógio): antes, dar F5 ou reabrir a tela de quiz
 * sorteava uma pergunta nova com o relógio visual cheio de novo — o tempo real
 * continuava correto no servidor, mas o usuário "ganhava" tempo visualmente ao
 * forçar uma nova pergunta sempre que o cronômetro visual apertava. Agora o
 * registro guarda também a questionId e o time_limit_seconds emitidos, e
 * getActiveIssuedQuestion() permite ao service checar, ANTES de sortear uma
 * pergunta nova, se o usuário já tem uma pergunta ativa em andamento — e se
 * tiver, devolver a mesma pergunta com o tempo restante real, em vez de uma
 * pergunta nova com o tempo zerado.
 */

const NETWORK_GRACE_SECONDS = 10;

function buildKey(userId) {
  return `quiz:issued:${userId}`;
}

/**
 * Registra o instante exato (server-side) em que a pergunta foi entregue ao
 * usuário, além da própria pergunta e do seu limite de tempo. Chamado sempre
 * que getNextQuestion devolve uma pergunta (nova ou repetida).
 */
async function markQuestionIssued(userId, questionId, timeLimitSeconds) {
  const key = buildKey(userId);
  const issuedAtMs = Date.now();
  const ttlSeconds = Math.max(timeLimitSeconds + NETWORK_GRACE_SECONDS, 5);
  const payload = JSON.stringify({ questionId, issuedAtMs, timeLimitSeconds });

  try {
    await redis.set(key, payload, 'EX', ttlSeconds);
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
 * Busca, sem consumir, a pergunta que o servidor já tinha entregue a este
 * usuário e que ainda está dentro do prazo (não expirada). Usada por
 * getNextQuestion para decidir se repete a pergunta ativa (com o tempo
 * restante real) em vez de sortear uma pergunta nova.
 *
 * Retorna `null` se não houver registro, se já tiver expirado ou se o Redis
 * estiver indisponível — nesses casos quem chama deve seguir o caminho normal
 * de sortear uma pergunta nova.
 */
async function getActiveIssuedQuestion(userId) {
  const key = buildKey(userId);

  try {
    const raw = await redis.get(key);
    if (!raw) return null;

    const { questionId, issuedAtMs, timeLimitSeconds } = JSON.parse(raw);
    const elapsedSeconds = Math.floor((Date.now() - issuedAtMs) / 1000);
    const remainingSeconds = timeLimitSeconds - elapsedSeconds;

    if (remainingSeconds <= 0) return null;

    return { questionId, remainingSeconds };
  } catch (err) {
    logger.warn('Não foi possível ler a pergunta ativa do quiz no Redis', {
      userId,
      error: err.message,
    });
    return null;
  }
}

/**
 * Calcula o tempo de resposta real, medido inteiramente pelo servidor, e
 * consome o registro (uma pergunta só pode ser respondida uma vez com este
 * timestamp — evita reuso do mesmo "issued_at" para múltiplas tentativas).
 *
 * Retorna `null` se não houver registro válido (expirado, nunca emitido, de
 * outra pergunta, ou Redis indisponível) — quem chama deve tratar isso como
 * tempo esgotado.
 */
async function consumeElapsedMs(userId, questionId) {
  const key = buildKey(userId);

  try {
    const raw = await redis.get(key);
    if (!raw) return null;

    const { questionId: issuedQuestionId, issuedAtMs } = JSON.parse(raw);
    if (issuedQuestionId !== questionId) return null;

    await redis.del(key);

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

module.exports = { markQuestionIssued, getActiveIssuedQuestion, consumeElapsedMs };
