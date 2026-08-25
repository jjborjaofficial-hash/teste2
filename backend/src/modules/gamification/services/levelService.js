const configRepository = require('../../../common/repositories/systemConfigRepository');

/**
 * Cálculo de nível a partir do XP total (Doc. Mestre Seção 6: Dashboard prioriza "Nível (XP)").
 *
 * NOTA: a fórmula de conversão XP -> Nível ainda não foi formalizada oficialmente
 * (ver Seção 23.1.5 do Doc. Mestre: "Economia da Plataforma — Status: Pendente").
 * Usamos uma fórmula placeholder simples e configurável (`level_xp_step` em system_config),
 * para que o produto funcione fim-a-fim enquanto a formalização oficial não ocorre.
 */
async function calculateLevel(xpTotal) {
  const step = Number((await configRepository.getConfigValue('level_xp_step')) ?? 500);
  const level = Math.floor(xpTotal / step) + 1;
  const xpIntoCurrentLevel = xpTotal % step;
  const xpToNextLevel = step - xpIntoCurrentLevel;
  return { level, xpIntoCurrentLevel, xpToNextLevel, xpStep: step };
}

module.exports = { calculateLevel };
