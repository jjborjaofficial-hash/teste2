const db = require('../../../config/database');
const repository = require('../repositories/walletRepository');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const pointsLedgerRepository = require('../../gamification/repositories/pointsLedgerRepository');
const notificationsService = require('../../notifications/services/notificationsService');
const userCache = require('../../../common/cache/userCache');
const { BusinessRuleError, ForbiddenError, NotFoundError } = require('../../../common/errors/AppError');

/**
 * Service da Carteira (Doc. Mestre Seção 16.3 e 19.6 | Manual Parte 4/5).
 *
 * REGRAS ECONÔMICAS CONFIRMADAS PELO PROPRIETÁRIO DO PROJETO:
 * - O usuário NUNCA deposita ou transfere dinheiro para a plataforma.
 * - A plataforma NUNCA cobra valor monetário de ninguém.
 * - O usuário só pode GANHAR até `daily_earning_cap_mzn` (7,20 MZN) por dia com as
 *   MISSÕES (valor não garantido) — isso é um teto de GANHO, não de saque. Streak em
 *   dinheiro, conversão de Pontos e boas-vindas ficam fora do teto.
 * - O SAQUE não tem teto diário: o usuário pode solicitar a qualquer momento,
 *   qualquer valor, desde que tenha o mínimo de `withdrawal_min_mzn` (100 MZN)
 *   acumulado. Não existe "esperar até amanhã para sacar mais".
 */

// Fonte única do saque mínimo (system_config `withdrawal_min_mzn`). O frontend lê-o daqui,
// para que um ajuste feito pelo admin apareça na tela sem novo deploy.
async function getWithdrawalMin() {
  return Number((await configRepository.getConfigValue('withdrawal_min_mzn')) ?? 100);
}

async function getBalance(userId) {
  const balance = await repository.getWalletBalance(userId);
  if (balance === null) throw new NotFoundError('Usuário não encontrado.');
  return { walletBalanceMzn: balance, withdrawalMinMzn: await getWithdrawalMin() };
}

async function getHistory(userId, pagination) {
  const rows = await repository.getTransactionHistory(userId, pagination);
  return rows.map((r) => ({
    id: r.id,
    type: r.type,
    source: r.source,
    amountMzn: Number(r.amount_mzn),
    balanceAfter: Number(r.balance_after),
    status: r.status,
    createdAt: r.created_at,
  }));
}

/**
 * Credita uma recompensa na carteira do usuário.
 * O teto de GANHO diário (7,20 MZN) vale SÓ para as missões: por padrão, se o
 * valor solicitado exceder o quanto ainda resta hoje, o crédito é reduzido para
 * caber no teto (nunca excede); se o teto já foi atingido, nada é creditado.
 * Prémios fora do teto (marcos de streak em dinheiro, bónus de boas-vindas)
 * passam `ignoreDailyCap: true` e são creditados por inteiro.
 *
 * Chamado por outros módulos (Missões, Streak, Boas-vindas), sempre dentro de uma transação
 * existente quando possível — nunca aceita depósito do usuário, só credita
 * recompensas que a própria plataforma decidiu conceder.
 */
async function creditReward({ userId, amountMzn, source, referenceId, metadata, ignoreDailyCap = false }, executor = db) {
  if (amountMzn <= 0) return null;

  // Prémios fora do teto (bónus de boas-vindas, marcos de streak em dinheiro) creditam
  // o valor inteiro. O teto de 7,20 MZN é só das missões: sumEarningsToday soma apenas
  // `mission_reward`, então estas fontes não consomem o teto de ninguém.
  if (ignoreDailyCap) {
    const credited = await repository.creditWallet(executor, {
      userId,
      amountMzn,
      source,
      referenceId,
      metadata: { ...metadata, requestedAmountMzn: amountMzn, cappedByDailyLimit: false },
    });
    await userCache.invalidateProfile(userId);
    return { ...credited, amountCreditedMzn: amountMzn };
  }

  const dailyCap = Number(
    (await configRepository.getConfigValue('daily_earning_cap_mzn', executor)) ?? 7.2
  );
  const earnedToday = await repository.sumEarningsToday(userId, executor);
  // Arredonda a 2 casas para não acumular ruído de ponto flutuante (ex.: 7,2 - 6,0).
  const remainingAllowance = Math.max(0, Math.round((dailyCap - earnedToday) * 100) / 100);

  if (remainingAllowance <= 0) {
    // Teto de ganho diário já atingido — nada é creditado hoje. Isso é uma
    // decisão silenciosa por padrão (o valor de MZN da missão/streak é só uma
    // estimativa; o efetivamente pago respeita sempre o teto diário).
    // O usuário ainda assim é avisado (no máximo 1x/dia) — antes esse aviso
    // não existia (ver docs/reaceite-termos-e-correcao-regras-saque.md).
    await notificationsService.notifyDailyEarningCapReached(executor, userId, dailyCap);
    return null;
  }

  const amountToCredit = Math.round(Math.min(amountMzn, remainingAllowance) * 100) / 100;

  const result = await repository.creditWallet(executor, {
    userId,
    amountMzn: amountToCredit,
    source,
    referenceId,
    metadata: { ...metadata, requestedAmountMzn: amountMzn, cappedByDailyLimit: amountToCredit < amountMzn },
  });

  // Se este crédito consumiu o restante do teto de hoje, avisa agora — não
  // precisa esperar a próxima tentativa (que nem vai gerar crédito nenhum).
  if (amountToCredit === remainingAllowance) {
    await notificationsService.notifyDailyEarningCapReached(executor, userId, dailyCap);
  }

  // Invalidação ativa do cache de perfil (docx "REDIS CACHE E CRON JOBS",
  // Seção 2): o saldo em MZN faz parte do perfil cacheado.
  await userCache.invalidateProfile(userId);

  return { ...result, amountCreditedMzn: amountToCredit };
}

/**
 * Solicita um saque. Regras confirmadas:
 * - conta precisa estar ativa;
 * - Trust Score mínimo exigido;
 * - valor mínimo de 100 MZN acumulado (não é depósito — é o que já foi ganho);
 * - não pode haver outro pedido "vivo" ao mesmo tempo;
 * - SEM teto diário de saque — pode sacar quando quiser, qualquer valor acima
 *   do mínimo, respeitado o saldo disponível;
 * - processamento não é imediato — fica em 'pending_review' aguardando análise
 *   manual (ver módulo Admin).
 */
async function requestWithdrawal({ userId, amountMzn, method }) {
  const minAmount = await getWithdrawalMin();

  if (amountMzn < minAmount) {
    throw new BusinessRuleError(`O valor mínimo de saque é ${minAmount.toFixed(2)} MZN.`);
  }

  // Documento "Sistema de Saques v1.0": "Conta do usuário ativa e em conformidade
  // com as Políticas da Plataforma" e "Ausência de bloqueios, suspensões ou restrições".
  const accountInfo = await repository.getUserStatusAndTrustScore(userId);
  if (!accountInfo) throw new NotFoundError('Usuário não encontrado.');

  if (accountInfo.status !== 'active') {
    throw new ForbiddenError(
      'Sua conta não está ativa no momento, por isso não é possível solicitar saques. Contate o suporte.'
    );
  }

  const minTrustScore = Number(
    (await configRepository.getConfigValue('min_trust_score_for_withdrawal')) ?? 60
  );
  const trustScore = accountInfo.trust_score;
  if (trustScore < minTrustScore) {
    // Seção 16.2: saldo pode ser retido se o Trust Score indicar fraude.
    throw new ForbiddenError(
      'Sua conta está em análise de segurança. O saque não pode ser processado no momento.'
    );
  }

  // Documento "Sistema de Saques v1.0", Seção Segurança: "Impedir solicitações
  // duplicadas". O índice único parcial (migration 014) é a garantia final contra
  // condição de corrida; esta checagem prévia só existe para dar um erro amigável.
  const hasActive = await repository.hasActiveWithdrawal(userId);
  if (hasActive) {
    throw new BusinessRuleError(
      'Você já tem uma solicitação de saque em andamento. Aguarde a conclusão antes de pedir outra.'
    );
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const debit = await repository.debitWallet(client, {
      userId,
      amountMzn,
      source: 'withdrawal_request',
      metadata: { method },
    });

    const request = await repository.createWithdrawalRequest(client, {
      userId,
      amountMzn,
      method,
      trustScoreAtRequest: trustScore,
      walletTransactionId: debit.id,
    });

    // Confirmação imediata ao usuário, com o SLA de 24h (o pagamento em si é
    // processado manualmente por um admin — ver notifyAdminsNewWithdrawal abaixo).
    await notificationsService.notifyWithdrawalRequested(client, userId, { amountMzn, method });

    // Alerta para o(s) admin(s) financeiro(s) processarem a transferência manual
    // para o número de telefone já cadastrado na conta (Seção 16.1 do Doc. Mestre).
    const { rows: userRows } = await client.query(
      'SELECT name, phone FROM users WHERE id = $1',
      [userId]
    );
    await notificationsService.notifyAdminsNewWithdrawal(client, {
      withdrawalId: request.id,
      userName: userRows[0]?.name,
      userPhone: userRows[0]?.phone,
      amountMzn,
      method,
    });

    await client.query('COMMIT');

    // Saldo debitado ao solicitar o saque — invalida o perfil cacheado.
    await userCache.invalidateProfile(userId);

    return {
      requestId: request.id,
      status: request.status,
      amountMzn,
      method,
      requestedAt: request.requested_at,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    if (err.code === 'INSUFFICIENT_BALANCE') {
      throw new BusinessRuleError('Saldo insuficiente para este saque.');
    }
    if (err.code === '23505') {
      throw new BusinessRuleError(
        'Você já tem uma solicitação de saque em andamento. Aguarde a conclusão antes de pedir outra.'
      );
    }
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Retorna a taxa de conversão vigente (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS", Seção 6.1). Existe como endpoint próprio para o frontend
 * nunca precisar cravar o número no código — se um admin recalibrar a taxa
 * em `system_config`, a tela de conversão reflete o novo valor sem deploy.
 */
async function getConversionRate() {
  const ratePoints = Number(
    (await configRepository.getConfigValue('points_conversion_rate_points')) ?? 1000
  );
  const rateMzn = Number(
    (await configRepository.getConfigValue('points_conversion_rate_mzn')) ?? 10
  );
  return { ratePoints, rateMzn };
}

/**
 * Converte Pontos em dinheiro real (MZN). A taxa e as regras seguem
 * literalmente o exemplo já registrado na documentação (1.000 Pontos =
 * 10 MZN / 10.000 Pontos = 100 MZN — mesma proporção), que até agora nunca
 * tinha sido implementado, apenas descrito como possibilidade em conversa.
 *
 * Regras aplicadas:
 * - conta precisa estar ativa;
 * - Trust Score mínimo exigido (Manual Parte 7: "limites de conversão devem
 *   respeitar o Trust Score do usuário");
 * - a conversão só é aceita em múltiplos exatos da taxa (mesma lógica do
 *   exemplo: nunca um valor fracionário de Pontos "quebrado");
 * - NÃO conta para o teto de ganho diário de 7,20 MZN: esse teto vale só para as
 *   missões (ver walletRepository.sumEarningsToday). O volume de Pontos já é
 *   limitado pelo teto diário de Pontos.
 */
async function convertPointsToMoney({ userId, pointsAmount }) {
  if (!Number.isInteger(pointsAmount) || pointsAmount <= 0) {
    throw new BusinessRuleError('A quantidade de Pontos deve ser um número inteiro positivo.');
  }

  const { ratePoints, rateMzn } = await getConversionRate();

  if (pointsAmount % ratePoints !== 0) {
    throw new BusinessRuleError(
      `A conversão só pode ser feita em múltiplos de ${ratePoints} Pontos ` +
        `(ex.: ${ratePoints} Pontos = ${rateMzn.toFixed(2)} MZN).`
    );
  }

  const amountMzn = Number(((pointsAmount / ratePoints) * rateMzn).toFixed(2));

  const accountInfo = await repository.getUserStatusAndTrustScore(userId);
  if (!accountInfo) throw new NotFoundError('Usuário não encontrado.');

  if (accountInfo.status !== 'active') {
    throw new ForbiddenError(
      'Sua conta não está ativa no momento, por isso não é possível converter Pontos em dinheiro.'
    );
  }

  const minTrustScore = Number(
    (await configRepository.getConfigValue('min_trust_score_for_conversion')) ?? 60
  );
  if (accountInfo.trust_score < minTrustScore) {
    throw new ForbiddenError(
      'Sua conta está em análise de segurança. A conversão não pode ser processada no momento.'
    );
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    let pointsEntry;
    try {
      pointsEntry = await pointsLedgerRepository.debitPoints(client, {
        userId,
        amountPoints: pointsAmount,
        source: 'points_conversion',
        metadata: { ratePoints, rateMzn, amountMzn },
      });
    } catch (err) {
      if (err.code === 'INSUFFICIENT_BALANCE') {
        throw new BusinessRuleError(
          `Pontos insuficientes. Você precisa de ${pointsAmount} Pontos para esta conversão.`
        );
      }
      throw err;
    }

    const walletEntry = await repository.creditWallet(client, {
      userId,
      amountMzn,
      source: 'points_conversion',
      metadata: {
        pointsConverted: pointsAmount,
        ratePoints,
        rateMzn,
        pointsLedgerId: pointsEntry.id,
      },
    });

    await notificationsService.notifyPointsConverted(client, userId, {
      pointsAmount,
      amountMzn,
    });

    await client.query('COMMIT');

    // Saldo de Pontos E de MZN mudaram — invalida o perfil cacheado (mesmo
    // princípio já aplicado em creditReward/requestWithdrawal).
    await userCache.invalidateProfile(userId);

    return {
      pointsConverted: pointsAmount,
      amountMzn,
      newPointsBalance: pointsEntry.balanceAfter,
      newWalletBalanceMzn: Number(walletEntry.balance_after),
      convertedAt: walletEntry.created_at,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  getBalance,
  getHistory,
  creditReward,
  requestWithdrawal,
  getConversionRate,
  convertPointsToMoney,
};
