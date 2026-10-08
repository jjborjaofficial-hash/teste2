/**
 * Missões "completar rodada" NÃO pagam dinheiro (decisão do dono, 2026-10-08): a rodada conta mesmo com 0
 * acertos, então pagar por ela premiaria responder ao acaso. Quizzes (quiz_count) só contam respostas certas
 * e continuam a poder pagar. Camadas: API (validação e edição), regra no banco (CHECK) e pagamento.
 * Integração: PostgreSQL com as migrations. Só cria e remove as missões desta suíte.
 */
const db = require('../src/config/database');
const adminMissionsService = require('../src/modules/missions/services/adminMissionsService');
const { createMissionSchema, ROUND_MONEY_MESSAGE } = require('../src/modules/missions/validators/adminMissionsValidators');

const base = { title: 'TESTE sem dinheiro', type: 'special', targetQuizCount: 1, xpReward: 5, pointsReward: 5 };
const created = [];

afterAll(async () => {
  if (created.length) await db.query('DELETE FROM missions WHERE id = ANY($1::uuid[])', [created]);
  await db.pool.end();
});

describe('API: validação ao criar', () => {
  it('recusa rodada com dinheiro, com mensagem clara no campo moneyRewardMzn', () => {
    const r = createMissionSchema.safeParse({ ...base, activityType: 'round_complete', moneyRewardMzn: 2 });
    expect(r.success).toBe(false);
    expect(r.error.issues[0].path).toEqual(['moneyRewardMzn']);
    expect(r.error.issues[0].message).toBe(ROUND_MONEY_MESSAGE);
  });

  it('aceita rodada sem dinheiro (XP e Pontos continuam permitidos)', () => {
    expect(createMissionSchema.safeParse({ ...base, activityType: 'round_complete', moneyRewardMzn: 0 }).success).toBe(true);
    expect(createMissionSchema.safeParse({ ...base, activityType: 'round_complete' }).success).toBe(true); // padrão 0
  });

  it('quizzes (respostas certas) continuam a poder pagar dinheiro', () => {
    expect(createMissionSchema.safeParse({ ...base, activityType: 'quiz_count', moneyRewardMzn: 2 }).success).toBe(true);
  });
});

describe('API: editar uma missão existente', () => {
  it('não deixa pôr dinheiro numa missão de rodada, mas deixa mudar o resto', async () => {
    const m = await adminMissionsService.createMission({ ...base, activityType: 'round_complete', moneyRewardMzn: 0 });
    created.push(m.id);
    await expect(adminMissionsService.updateMission(m.id, { moneyRewardMzn: 3 })).rejects.toThrow(/não podem pagar dinheiro/);
    const ok = await adminMissionsService.updateMission(m.id, { xpReward: 50, moneyRewardMzn: 0 });
    expect(ok.xpReward).toBe(50);
    expect(ok.moneyRewardMzn).toBe(0);
  });

  it('numa missão de quizzes continua a ser possível pôr dinheiro', async () => {
    const m = await adminMissionsService.createMission({ ...base, activityType: 'quiz_count', moneyRewardMzn: 0 });
    created.push(m.id);
    const ok = await adminMissionsService.updateMission(m.id, { moneyRewardMzn: 1.5 });
    expect(ok.moneyRewardMzn).toBe(1.5);
  });
});

describe('Banco: regra que não depende da API', () => {
  it('um INSERT direto de rodada com dinheiro é recusado', async () => {
    await expect(
      db.query(
        `INSERT INTO missions (title, type, activity_type, target_quiz_count, money_reward_mzn)
         VALUES ('TESTE direto', 'special', 'round_complete', 1, 2)`
      )
    ).rejects.toThrow(/missions_round_complete_sem_dinheiro_check/);
  });

  it('um UPDATE direto que põe dinheiro numa rodada é recusado', async () => {
    const m = await adminMissionsService.createMission({ ...base, activityType: 'round_complete', moneyRewardMzn: 0 });
    created.push(m.id);
    await expect(db.query('UPDATE missions SET money_reward_mzn = 4 WHERE id = $1', [m.id])).rejects.toThrow(
      /missions_round_complete_sem_dinheiro_check/
    );
  });

  it('a migration zera as missões de rodada que já tinham dinheiro e deixa as de quizzes', async () => {
    // Reproduz o estado "antigo": tira a regra, cria o problema, aplica o SQL da migration e confere.
    const fs = require('fs');
    const path = require('path');
    const sql = fs.readFileSync(path.join(__dirname, '../database/migrations/392_missoes_rodada_sem_dinheiro.sql'), 'utf8');
    await db.query('ALTER TABLE missions DROP CONSTRAINT missions_round_complete_sem_dinheiro_check');
    const r = (await db.query(
      `INSERT INTO missions (title, type, activity_type, target_quiz_count, money_reward_mzn, xp_reward)
       VALUES ('TESTE antiga rodada', 'special', 'round_complete', 1, 2.5, 7) RETURNING id`)).rows[0].id;
    const q = (await db.query(
      `INSERT INTO missions (title, type, activity_type, target_quiz_count, money_reward_mzn)
       VALUES ('TESTE antiga quiz', 'special', 'quiz_count', 1, 2.5) RETURNING id`)).rows[0].id;
    created.push(r, q);
    await db.query(sql);
    const rows = (await db.query('SELECT id, money_reward_mzn, xp_reward FROM missions WHERE id = ANY($1::uuid[])', [[r, q]])).rows;
    const byId = Object.fromEntries(rows.map((x) => [x.id, x]));
    expect(Number(byId[r].money_reward_mzn)).toBe(0); // dinheiro zerado
    expect(byId[r].xp_reward).toBe(7); // XP intacto
    expect(Number(byId[q].money_reward_mzn)).toBe(2.5); // quizzes intactos
    // e a regra voltou: já não dá para recriar o problema
    await expect(db.query('UPDATE missions SET money_reward_mzn = 1 WHERE id = $1', [r])).rejects.toThrow(/sem_dinheiro_check/);
  });
});
