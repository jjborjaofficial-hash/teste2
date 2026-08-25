const db = require('../../../config/database');
const repository = require('../repositories/walletRepository');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const notificationsService = require('../../notifications/services/notificationsService');
const userCache = require('../../../common/cache/userCache');
const { BusinessRuleError, ForbiddenError, NotFoundError } = require('../../../common/errors/AppError');

/**
 * Service da Carteira (Doc. Mestre Seção 16.3 e 19.6 | Manual Parte 4/5).
 *
 * REGRAS ECONÔMICAS CONFIRMADAS PELO PROPRIETÁRIO DO PROJETO:
 * - O usuário NUNCA deposita ou transfere dinheiro para a plataforma.
 * - A plataforma NUNCA cobra valor monetário de ninguém.
 * - O usuário só pode GANHAR até `daily_earning_cap_mzn` (7,20 MZN) em dinheiro
 *   real por dia, via missões/streak — isso é um teto de GANHO, não de saque.
 * - O SAQUE não tem teto diário: o usuário pode solicitar a qualquer momento,
 *   qualquer valor, desde que tenha o mínimo de `withdrawal_min_mzn` (100 MZN)
 *   acumulado. Não existe "esperar até amanhã para sacar mais".
 */

async function getBalance(userId) {
  const balance = await repository.getWalletBalance(userId);
  if (balance === null) throw new NotFoundError('Usuário não encontrado.');
  return { walletBalanceMzn: balance };
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
 * Credita uma recompensa (missão ou marco de streak) na carteira do usuário.
 * Aplica automaticamente o teto de GANHO diário: se o valor solicitado exceder
 * o quanto ainda resta hoje, o crédito é reduzido para caber no teto (nunca
 * excede). Se o teto já foi atingido, nada é creditado.
 *
 * Chamado por outros módulos (Missões, Streak), sempre dentro de uma transação
 * existente quando possível — nunca aceita depósito do usuário, só credita
 * recompensas que a própria plataforma decidiu conceder.
 */
async function creditReward({ userId, amountMzn, source, referenceId, metadata }, executor = db) {
  if (amountMzn <= 0) return null;

  const dailyCap = Number(
    (await configRepository.getConfigValue('daily_earning_cap_mzn', executor)) ?? 7.2
  );
  const earnedToday = await repository.sumEarningsToday(userId, executor);
  const remainingAllowance = Math.max(0, dailyCap - earnedToday);

  if (remainingAllowance <= 0) {
    // Teto de ganho diário já atingido — nada é creditado hoje. Isso é uma
    // decisão silenciosa por padrão (o valor de MZN da missão/streak é só uma
    // estimativa; o efetivamente pago respeita sempre o teto diário).
    return null;
  }

  const amountToCredit = Math.min(amountMzn, remainingAllowance);

  const result = await repository.creditWallet(executor, {
    userId,
    amountMzn: amountToCredit,
    source,
    referenceId,
    metadata: { ...metadata, requestedAmountMzn: amountMzn, cappedByDailyLimit: amountToCredit < amountMzn },
  });

  // Invalidação ativa do cache de perfil (docx "REDIS CACHE E CRON JOBS",
  // Seção 2): o saldo em MZN faz parte do perfil cacheado.
  await userCache.invalidateProfile(userId);

  return result;
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
  const minAmount = Number(
    (await configRepository.getConfigValue('withdrawal_min_mzn')) ?? 100
  );

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

module.exports = { getBalance, getHistory, creditReward, requestWithdrawal };
