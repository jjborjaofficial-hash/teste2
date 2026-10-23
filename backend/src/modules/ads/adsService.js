const db = require('../../config/database');
const { NotFoundError, BusinessRuleError } = require('../../common/errors/AppError');
const { SLOTS, FORMAT_FN, FORMAT_LABEL } = require('./adsCatalog');

/**
 * Gestão dos anúncios pelo painel. Só aceita código do Adcash (aclib.run...({ zoneId: '123' })): extraímos o Zone ID e o
 * frontend chama a função certa do aclib com ele. NÃO se guarda nem se executa script arbitrário (um script colado
 * correria em todos os ecrãs dos utilizadores).
 */

const MASTER = '_master';

function slotOrThrow(key) {
  const slot = SLOTS.find((s) => s.key === key);
  if (!slot) throw new NotFoundError('Local de anúncio desconhecido.');
  return slot;
}

function parseAdcashSnippet(slot, code) {
  const text = String(code || '').trim();
  if (!text) throw new BusinessRuleError('Cole o código do anúncio.');
  if (text.length > 4000) throw new BusinessRuleError('Código demasiado grande.');
  const fn = text.match(/aclib\s*\.\s*(run\w+)\s*\(/);
  if (!fn) {
    throw new BusinessRuleError('Código não reconhecido. Cole o código do Adcash (o que tem aclib.run...).');
  }
  const expected = FORMAT_FN[slot.format];
  if (fn[1] !== expected) {
    throw new BusinessRuleError(
      `Este local aceita ${FORMAT_LABEL[slot.format]} (${expected}), mas o código colado é ${fn[1]}. Use o código certo para este local.`
    );
  }
  const zone = text.match(/zoneId\s*:\s*['"]?(\d{3,12})['"]?/);
  if (!zone) throw new BusinessRuleError('Não encontrei o Zone ID no código colado.');
  return zone[1];
}

async function rows() {
  const { rows: r } = await db.query('SELECT slot_key, zone_id, enabled, script_raw, updated_at FROM ad_slots');
  return new Map(r.map((x) => [x.slot_key, x]));
}

async function listSlots() {
  const map = await rows();
  return {
    masterEnabled: map.get(MASTER)?.enabled === true,
    slots: SLOTS.map((s) => {
      const row = map.get(s.key);
      return {
        key: s.key,
        label: s.label,
        where: s.where,
        format: s.format,
        formatLabel: FORMAT_LABEL[s.format],
        size: s.size,
        zoneId: row?.zone_id || null,
        enabled: row ? row.enabled : true,
        integrated: Boolean(row?.zone_id),
        updatedAt: row?.updated_at || null,
      };
    }),
  };
}

async function saveSlot(key, code, adminId) {
  const slot = slotOrThrow(key);
  const zoneId = parseAdcashSnippet(slot, code);
  await db.query(
    `INSERT INTO ad_slots (slot_key, zone_id, enabled, script_raw, updated_at, updated_by)
     VALUES ($1, $2, TRUE, $3, now(), $4)
     ON CONFLICT (slot_key) DO UPDATE SET zone_id = EXCLUDED.zone_id, script_raw = EXCLUDED.script_raw,
       enabled = TRUE, updated_at = now(), updated_by = EXCLUDED.updated_by`,
    [key, zoneId, String(code).trim(), adminId]
  );
  return listSlots();
}

async function clearSlot(key, adminId) {
  slotOrThrow(key);
  await db.query(
    `UPDATE ad_slots SET zone_id = NULL, script_raw = NULL, updated_at = now(), updated_by = $2 WHERE slot_key = $1`,
    [key, adminId]
  );
  return listSlots();
}

async function setSlotEnabled(key, enabled, adminId) {
  slotOrThrow(key);
  await db.query(
    `INSERT INTO ad_slots (slot_key, enabled, updated_by) VALUES ($1, $2, $3)
     ON CONFLICT (slot_key) DO UPDATE SET enabled = EXCLUDED.enabled, updated_at = now(), updated_by = EXCLUDED.updated_by`,
    [key, Boolean(enabled), adminId]
  );
  return listSlots();
}

async function setMaster(enabled, adminId) {
  await db.query(
    `INSERT INTO ad_slots (slot_key, enabled, updated_by) VALUES ($1, $2, $3)
     ON CONFLICT (slot_key) DO UPDATE SET enabled = EXCLUDED.enabled, updated_at = now(), updated_by = EXCLUDED.updated_by`,
    [MASTER, Boolean(enabled), adminId]
  );
  return listSlots();
}

/** Configuração pública (sem login): só locais ligados e com Zone ID. */
async function publicConfig() {
  const map = await rows();
  const zones = {};
  for (const s of SLOTS) {
    const row = map.get(s.key);
    if (row && row.zone_id && row.enabled) zones[s.key] = row.zone_id;
  }
  return { masterEnabled: map.get(MASTER)?.enabled === true, zones };
}

module.exports = { listSlots, saveSlot, clearSlot, setSlotEnabled, setMaster, publicConfig };
