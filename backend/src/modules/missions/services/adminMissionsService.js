const repository = require('../repositories/adminMissionsRepository');
const { NotFoundError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Regras de negócio da Gestão de Missões (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS": "Painel Administrativo — Controle XP/Moedas: criar
 * recompensa"). O gate de elegibilidade por Pontos acumulados para missões
 * de dinheiro (discutido, mas ainda sem valores aprovados) fica como próximo
 * passo — hoje toda missão com money_reward_mzn > 0 é elegível para qualquer
 * usuário que cumprir o target_quiz_count, sem trava adicional.
 */

function mapMission(m) {
  return {
    id: m.id,
    title: m.title,
    description: m.description,
    type: m.type,
    categoryId: m.category_id,
    categoryName: m.category_name,
    targetQuizCount: m.target_quiz_count,
    xpReward: m.xp_reward,
    pointsReward: m.points_reward,
    moneyRewardMzn: Number(m.money_reward_mzn),
    isActive: m.is_active,
    startsAt: m.starts_at,
    endsAt: m.ends_at,
    assignmentsCount: m.assignments_count,
  };
}

async function listMissions() {
  const rows = await repository.listAllMissions();
  return rows.map(mapMission);
}

async function createMission(data) {
  if (data.startsAt && data.endsAt && new Date(data.startsAt) >= new Date(data.endsAt)) {
    throw new BusinessRuleError('A data de início precisa ser anterior à data de término.');
  }
  const created = await repository.createMission(data);
  return mapMission(created);
}

async function updateMission(id, data) {
  const existing = await repository.findMissionById(id);
  if (!existing) throw new NotFoundError('Missão não encontrada.');
  const updated = await repository.updateMission(id, data);
  return mapMission(updated);
}

module.exports = { listMissions, createMission, updateMission };
