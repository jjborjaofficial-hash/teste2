/**
 * Bónus de convite (regra do dono, 2026-10-12): quem convida recebe, para sempre, 20% do MZN que cada convidado
 * ganha nas MISSÕES DIÁRIAS — extra da plataforma, nada sai da conta do convidado, e fora do teto diário de 7,20
 * de quem convida. Teste de integração (PostgreSQL com as migrations). Os utilizadores de teste NÃO são apagados
 * (audit_logs é append-only e bloqueia o DELETE em cascata); removemos só missões, atribuições e convites criados aqui.
 */
const db = require('../src/config/database');
const missionsService = require('../src/modules/missions/services/missionsService');
const referralsService = require('../src/modules/referrals/services/referralsService');
const walletService = require('../src/modules/wallet/services/walletService');
const walletRepository = require('../src/modules/wallet/repositories/walletRepository');

const missionIds = [];
const referralIds = [];
let dailyMissionId;
let weeklyMissionId;

async function makeUser(label) {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ($1, $2, 'x', 'mpesa', 'active') RETURNING id`,
    [`Teste Bonus ${label}`, phone]
  );
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [rows[0].id]);
  return rows[0].id;
}

async function makePair(status = 'rewarded') {
  const inviter = await makeUser('Convidador');
  const invitee = await makeUser('Convidado');
  const { rows } = await db.query(
    `INSERT INTO referrals (referrer_user_id, referred_user_id, status, reward_granted_at)
     VALUES ($1, $2, $3::varchar, CASE WHEN $3::varchar = 'rewarded' THEN now() END) RETURNING id`,
    [inviter, invitee, status]
  );
  referralIds.push(rows[0].id);
  return { inviter, invitee, referralId: rows[0].id };
}

async function completedMission(userId, missionId) {
  const { rows } = await db.query(
    `INSERT INTO user_missions (user_id, mission_id, status, progress_count, target_snapshot, completed_at)
     VALUES ($1, $2, 'completed', 1, 1, now()) RETURNING id`,
    [userId, missionId]
  );
  return rows[0].id;
}

async function totalBySource(userId, source) {
  const { rows } = await db.query(
    'SELECT COALESCE(SUM(amount_mzn), 0) AS total FROM wallet_transactions WHERE user_id = $1 AND source = $2',
    [userId, source]
  );
  return Number(rows[0].total);
}

async function createMission(title, type) {
  const { rows } = await db.query(
    `INSERT INTO missions (title, description, type, target_quiz_count, money_reward_mzn, is_active)
     VALUES ($1, 'teste', $2, 1, 1.20, false) RETURNING id`,
    [title, type]
  );
  missionIds.push(rows[0].id);
  return rows[0].id;
}

beforeAll(async () => {
  // is_active = false: não entram na atribuição automática das missões diárias dos outros testes.
  dailyMissionId = await createMission('TESTE bonus convite (diaria)', 'daily');
  weeklyMissionId = await createMission('TESTE bonus convite (semanal)', 'weekly');
});

afterAll(async () => {
  await db.query('DELETE FROM user_missions WHERE mission_id = ANY($1::uuid[])', [missionIds]);
  await db.query('DELETE FROM missions WHERE id = ANY($1::uuid[])', [missionIds]);
  await db.query('DELETE FROM referrals WHERE id = ANY($1::uuid[])', [referralIds]);
  await db.pool.end();
});

describe('bónus de convite de 20% nas missões diárias', () => {
  it('quem convida recebe 20% (0,24 de 1,20) e o convidado recebe o valor INTEIRO', async () => {
    const { inviter, invitee, referralId } = await makePair('rewarded');
    const um = await completedMission(invitee, dailyMissionId);

    await missionsService.claimReward(invitee, um);

    expect(await totalBySource(invitee, 'mission_reward')).toBeCloseTo(1.2, 2); // nada foi tirado ao convidado
    expect(await totalBySource(invitee, 'referral_bonus')).toBe(0);
    expect(await totalBySource(inviter, 'referral_bonus')).toBeCloseTo(0.24, 2);

    const { rows } = await db.query(
      "SELECT metadata FROM wallet_transactions WHERE user_id = $1 AND source = 'referral_bonus'",
      [inviter]
    );
    expect(rows).toHaveLength(1);
    expect(rows[0].metadata).toMatchObject({ referralId, referredUserId: invitee, percent: 20, baseAmountMzn: 1.2 });
  });

  it('não paga o bónus em duplicado se o resgate for repetido', async () => {
    const { inviter, invitee } = await makePair('rewarded');
    const um = await completedMission(invitee, dailyMissionId);

    await missionsService.claimReward(invitee, um);
    await expect(missionsService.claimReward(invitee, um)).rejects.toThrow(/já foi resgatada/i);

    expect(await totalBySource(inviter, 'referral_bonus')).toBeCloseTo(0.24, 2);
  });

  it('não há bónus enquanto o convite não estiver qualificado (convidado ainda não estudou o suficiente)', async () => {
    const { inviter, invitee } = await makePair('pending');
    const um = await completedMission(invitee, dailyMissionId);

    await missionsService.claimReward(invitee, um);

    expect(await totalBySource(invitee, 'mission_reward')).toBeCloseTo(1.2, 2);
    expect(await totalBySource(inviter, 'referral_bonus')).toBe(0);
  });

  it('só missões DIÁRIAS contam: uma missão semanal do convidado não gera bónus', async () => {
    const { inviter, invitee } = await makePair('rewarded');
    const um = await completedMission(invitee, weeklyMissionId);

    await missionsService.claimReward(invitee, um);

    expect(await totalBySource(invitee, 'mission_reward')).toBeCloseTo(1.2, 2);
    expect(await totalBySource(inviter, 'referral_bonus')).toBe(0);
  });

  it('um utilizador sem convite resgata normalmente, sem erro e sem bónus a ninguém', async () => {
    const solo = await makeUser('Sozinho');
    const um = await completedMission(solo, dailyMissionId);

    await expect(missionsService.claimReward(solo, um)).resolves.toBeDefined();

    expect(await totalBySource(solo, 'mission_reward')).toBeCloseTo(1.2, 2);
    expect(await totalBySource(solo, 'referral_bonus')).toBe(0);
  });

  it('o bónus é 20% do valor REALMENTE creditado: se o teto cortar o convidado, o bónus acompanha o corte', async () => {
    const { inviter, invitee } = await makePair('rewarded');
    // O convidado já ganhou 6,60 hoje em missões: sobram 0,60 do teto de 7,20, e a missão de 1,20 é cortada a 0,60.
    await walletService.creditReward({ userId: invitee, amountMzn: 6.6, source: 'mission_reward', referenceId: null }, db);
    const um = await completedMission(invitee, dailyMissionId);

    await missionsService.claimReward(invitee, um);

    expect(await totalBySource(invitee, 'mission_reward')).toBeCloseTo(7.2, 2);
    expect(await totalBySource(inviter, 'referral_bonus')).toBeCloseTo(0.12, 2); // 20% de 0,60
  });

  it('o bónus fica FORA do teto de quem convida: mesmo com 7,20 já ganhos hoje, recebe o bónus e o teto não sobe', async () => {
    const { inviter, invitee } = await makePair('rewarded');
    await walletService.creditReward({ userId: inviter, amountMzn: 7.2, source: 'mission_reward', referenceId: null }, db);
    const um = await completedMission(invitee, dailyMissionId);

    await missionsService.claimReward(invitee, um);

    expect(await totalBySource(inviter, 'referral_bonus')).toBeCloseTo(0.24, 2);
    expect(Number(await walletRepository.sumEarningsToday(inviter, db))).toBeCloseTo(7.2, 2); // o bónus não conta para o teto
  });

  it('a percentagem vem da configuração: 0 desliga o bónus', async () => {
    const { inviter, invitee } = await makePair('rewarded');
    await db.query("UPDATE system_config SET value = '0' WHERE key = 'referral_bonus_percent'");
    try {
      const um = await completedMission(invitee, dailyMissionId);
      await missionsService.claimReward(invitee, um);
      expect(await totalBySource(inviter, 'referral_bonus')).toBe(0);
    } finally {
      await db.query("UPDATE system_config SET value = '20' WHERE key = 'referral_bonus_percent'");
    }
  });

  it('a lista de convites mostra quanto cada convidado já rendeu em bónus', async () => {
    const { inviter, invitee, referralId } = await makePair('rewarded');
    await missionsService.claimReward(invitee, await completedMission(invitee, dailyMissionId));

    const lista = await referralsService.listMyReferrals(inviter);

    expect(lista).toHaveLength(1);
    expect(lista[0]).toMatchObject({ id: referralId, status: 'rewarded' });
    expect(lista[0].bonusMzn).toBeCloseTo(0.24, 2);
  });

  describe('notificação a quem convida (uma por missão)', () => {
    async function notificacoes(userId) {
      const { rows } = await db.query(
        "SELECT title, body, metadata FROM notifications WHERE user_id = $1 AND type = 'referral_bonus_received' ORDER BY created_at",
        [userId]
      );
      return rows;
    }

    it('quem convida recebe a notificação com o valor e o nome exato do convidado; o convidado não recebe nenhuma', async () => {
      const { inviter, invitee } = await makePair('rewarded');
      await missionsService.claimReward(invitee, await completedMission(invitee, dailyMissionId));

      const lista = await notificacoes(inviter);
      expect(lista).toHaveLength(1);
      expect(lista[0].title).toBe('Comissão de convite recebida');
      expect(lista[0].body).toBe('Recebeste 0,24 MZN pela comissão do convite, utilizador Teste Bonus Convidado.');
      expect(lista[0].metadata).toMatchObject({ bonusMzn: 0.24, referredName: 'Teste Bonus Convidado' });
      expect(await notificacoes(invitee)).toHaveLength(0);
    });

    it('uma notificação por missão: 3 missões do convidado dão 3 notificações', async () => {
      const { inviter, invitee } = await makePair('rewarded');
      // Um utilizador só tem uma atribuição por missão e período, por isso são 3 missões diárias diferentes.
      for (let i = 0; i < 3; i += 1) {
        // eslint-disable-next-line no-await-in-loop
        const missaoId = await createMission(`TESTE bonus convite (diaria extra ${i})`, 'daily');
        // eslint-disable-next-line no-await-in-loop
        await missionsService.claimReward(invitee, await completedMission(invitee, missaoId));
      }
      expect(await notificacoes(inviter)).toHaveLength(3);
    });

    it('sem bónus não há notificação (convite pendente, missão semanal, percentagem 0)', async () => {
      const pendente = await makePair('pending');
      await missionsService.claimReward(pendente.invitee, await completedMission(pendente.invitee, dailyMissionId));
      expect(await notificacoes(pendente.inviter)).toHaveLength(0);

      const semanal = await makePair('rewarded');
      await missionsService.claimReward(semanal.invitee, await completedMission(semanal.invitee, weeklyMissionId));
      expect(await notificacoes(semanal.inviter)).toHaveLength(0);

      const zero = await makePair('rewarded');
      await db.query("UPDATE system_config SET value = '0' WHERE key = 'referral_bonus_percent'");
      try {
        await missionsService.claimReward(zero.invitee, await completedMission(zero.invitee, dailyMissionId));
        expect(await notificacoes(zero.inviter)).toHaveLength(0);
      } finally {
        await db.query("UPDATE system_config SET value = '20' WHERE key = 'referral_bonus_percent'");
      }
    });

    it('o valor da notificação acompanha o valor realmente creditado (teto do convidado cortou)', async () => {
      const { inviter, invitee } = await makePair('rewarded');
      await walletService.creditReward({ userId: invitee, amountMzn: 7.0, source: 'mission_reward', referenceId: null });
      await missionsService.claimReward(invitee, await completedMission(invitee, dailyMissionId));

      const lista = await notificacoes(inviter);
      expect(lista).toHaveLength(1);
      expect(lista[0].body).toBe('Recebeste 0,04 MZN pela comissão do convite, utilizador Teste Bonus Convidado.');
    });

    it('um convidado sem nome mostra "um amigo", e uma falha na notificação não estraga o resgate nem o bónus', async () => {
      const semNome = await makePair('rewarded');
      await db.query("UPDATE users SET name = '   ' WHERE id = $1", [semNome.invitee]);
      await missionsService.claimReward(semNome.invitee, await completedMission(semNome.invitee, dailyMissionId));
      expect((await notificacoes(semNome.inviter))[0].body).toBe(
        'Recebeste 0,24 MZN pela comissão do convite, utilizador um amigo.'
      );

      const falha = await makePair('rewarded');
      const notificationsService = require('../src/modules/notifications/services/notificationsService');
      const spy = jest.spyOn(notificationsService, 'notifyReferralBonusReceived').mockRejectedValue(new Error('boom'));
      try {
        const r = await missionsService.claimReward(falha.invitee, await completedMission(falha.invitee, dailyMissionId));
        expect(r.rewardsGranted.moneyMzn).toBeCloseTo(1.2, 2);
        expect(await totalBySource(falha.inviter, 'referral_bonus')).toBeCloseTo(0.24, 2);
      } finally {
        spy.mockRestore();
      }
    });
  });
});
