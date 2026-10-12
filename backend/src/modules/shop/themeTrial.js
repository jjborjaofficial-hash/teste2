/**
 * Tema Noite emprestado por 10 minutos (GER-002) — regra de tempo, sem banco.
 *
 * Quem manda no tempo é o servidor: fim = início + 10 minutos, e o estado é sempre calculado na hora
 * ("expirado" é apenas `agora >= fim`; não há tarefa agendada). O cliente só desenha a contagem a
 * partir de `endsAt` e `serverNow` devolvidos aqui, nunca decide sozinho.
 */
const TRIAL_MINUTES = 10;
const TRIAL_MS = TRIAL_MINUTES * 60 * 1000;

/**
 * @param {{eligible?: boolean, startedAt?: Date|string|null, introSeenAt?: Date|string|null, equippedTheme?: string|null}} row
 * @param {Date} now
 * @returns {{status: 'available'|'active'|'expired'|'unavailable', endsAt: string|null, secondsLeft: number,
 *            serverNow: string, introSeen: boolean, durationSeconds: number}}
 */
function computeTrial({ eligible, startedAt, introSeenAt, equippedTheme } = {}, now = new Date()) {
  const nowMs = now.getTime();
  let status;
  let endsMs = null;

  if (startedAt) {
    endsMs = new Date(startedAt).getTime() + TRIAL_MS;
    status = nowMs < endsMs ? 'active' : 'expired';
  } else if (eligible && equippedTheme !== 'theme_night') {
    status = 'available';
  } else {
    status = 'unavailable';
  }

  return {
    status,
    endsAt: endsMs === null ? null : new Date(endsMs).toISOString(),
    secondsLeft: status === 'active' ? Math.max(0, Math.ceil((endsMs - nowMs) / 1000)) : 0,
    serverNow: now.toISOString(),
    introSeen: Boolean(introSeenAt),
    durationSeconds: TRIAL_MINUTES * 60,
  };
}

module.exports = { TRIAL_MINUTES, TRIAL_MS, computeTrial };
