const cacheService = require('./cacheService');

/**
 * Cache de dados do usuário lidos com muita frequência (docx "REDIS CACHE E
 * CRON JOBS", Seções 2 e 3: Perfil básico e Streak).
 *
 * IMPORTANTE — por que TTL curto + invalidação ativa, e não só TTL:
 * XP, Pontos, saldo e streak mudam a cada resposta de quiz. Se dependêssemos
 * só do TTL de 5-15 min pedido na especificação, o usuário responderia um
 * quiz e veria o próprio saldo "desatualizado" por até 15 minutos — uma
 * regressão de UX real. Por isso todo módulo que muda um desses campos chama
 * `invalidateProfile`/`invalidateStreak` no mesmo instante da escrita; o TTL
 * fica como rede de segurança (ex: se alguma chamada de invalidação for
 * esquecida em um módulo futuro), não como mecanismo principal de frescor.
 */

const PROFILE_TTL_SECONDS = 600; // 10 min — dentro da janela de 5-15 min pedida
const STREAK_TTL_SECONDS = 600;

function profileKey(userId) {
  return `user:profile:${userId}`;
}

function streakKey(userId) {
  return `user:streak:${userId}`;
}

async function getOrSetProfile(userId, fetchFn) {
  return cacheService.getOrSet(profileKey(userId), PROFILE_TTL_SECONDS, fetchFn);
}

async function invalidateProfile(userId) {
  return cacheService.invalidate(profileKey(userId));
}

async function getOrSetStreak(userId, fetchFn) {
  return cacheService.getOrSet(streakKey(userId), STREAK_TTL_SECONDS, fetchFn);
}

async function invalidateStreak(userId) {
  return cacheService.invalidate(streakKey(userId));
}

module.exports = {
  getOrSetProfile,
  invalidateProfile,
  getOrSetStreak,
  invalidateStreak,
};
