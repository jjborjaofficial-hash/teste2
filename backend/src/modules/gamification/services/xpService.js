const db = require('../../../config/database');
const repository = require('../repositories/gamificationRepository');
const pointsLedgerRepository = require('../repositories/pointsLedgerRepository');
const inventoryRepository = require('../../shop/repositories/inventoryRepository');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const levelService = require('./levelService');
const userCache = require('../../../common/cache/userCache');

/**
 * Adiciona XP e/ou Pontos ao usuário. Deve ser chamado dentro de uma transação
 * quando fizer parte de uma operação maior (ex: submissão de resposta de quiz).
 *
 * Pontos aplicam o teto diário de ganho (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS", Seção 8) e geram uma linha no livro-razão (Seção 9) — mesmo
 * padrão já usado no teto de MZN (`walletService.creditReward`). XP não tem
 * teto nem livro-razão: é controlado por antifraude (Trust Score), não por
 * limite numérico, conforme o mesmo documento confirma ("XP: sem limite
 * rígido, mas com controle antifraude").
 *
 * `pointsSource` é obrigatório sempre que `pointsDelta > 0`, para que o
 * livro-razão nunca tenha uma linha sem origem identificável.
 */
async function addXpAndPoints(executor = db, { userId, xpDelta = 0, pointsDelta = 0, pointsSource, pointsReferenceId, pointsMetadata }) {
  let cappedPointsDelta = pointsDelta;
  let pointsCappedByDailyLimit = false;
  let boostApplied = false;

  if (pointsDelta > 0) {
    if (!pointsSource) {
      throw new Error('pointsSource é obrigatório ao creditar Pontos (necessário para o livro-razão).');
    }

    // Coin Boost (migration 026): multiplica só Pontos, NUNCA XP — nunca dá
    // vantagem de ranking/nível, só acelera acesso à Loja. Revalidado no
    // servidor a cada crédito (expires_at > now() checado dentro da própria
    // query — nunca confiamos em nada vindo do cliente sobre o boost).
    const activeBoost = await inventoryRepository.getActiveEffect(userId, 'points_multiplier_2x', executor);
    let effectivePointsDelta = pointsDelta;
    if (activeBoost) {
      effectivePointsDelta = pointsDelta * 2;
      boostApplied = true;
    }

    const dailyCap = Number((await configRepository.getConfigValue('daily_points_cap', executor)) ?? 5000);
    const earnedToday = await pointsLedgerRepository.sumCreditsToday(userId, executor);
    const remainingAllowance = Math.max(0, dailyCap - earnedToday);
    cappedPointsDelta = Math.min(effectivePointsDelta, remainingAllowance);
    pointsCappedByDailyLimit = cappedPointsDelta < effectivePointsDelta;
  }

  const totals = await repository.addXpAndPoints(executor, { userId, xpDelta, pointsDelta: cappedPointsDelta });
  const levelInfo = await levelService.calculateLevel(totals.xpTotal);

  if (cappedPointsDelta > 0) {
    await pointsLedgerRepository.insertLedgerEntry(executor, {
      userId,
      type: 'credit',
      amountPoints: cappedPointsDelta,
      balanceAfter: totals.pointsBalance,
      source: pointsSource,
      referenceId: pointsReferenceId,
      metadata: { ...pointsMetadata, requestedPoints: pointsDelta, cappedByDailyLimit: pointsCappedByDailyLimit, boostApplied },
    });
  }

  // Compara o nível antes e depois deste crédito para saber se houve level-up
  // agora mesmo (usado pelo frontend para a animação de rotação — Seção 13.6:
  // "XP: rotação ao completar nível").
  const previousXpTotal = Math.max(0, totals.xpTotal - xpDelta);
  const previousLevelInfo = await levelService.calculateLevel(previousXpTotal);
  const leveledUp = xpDelta > 0 && levelInfo.level > previousLevelInfo.level;

  // Invalidação ativa do cache de perfil (docx "REDIS CACHE E CRON JOBS",
  // Seção 2): XP/Pontos/Nível fazem parte do perfil cacheado, e o usuário
  // precisa ver o resultado imediatamente após responder o quiz, não só
  // depois do TTL expirar.
  await userCache.invalidateProfile(userId);

  return { ...totals, ...levelInfo, leveledUp, pointsCappedByDailyLimit, pointsBoostApplied: boostApplied, pointsCredited: cappedPointsDelta, xpCredited: xpDelta };
}

module.exports = { addXpAndPoints };
