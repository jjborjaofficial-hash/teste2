/**
 * Slots de cosméticos equipáveis. O slot é inferido pelo prefixo da chave do
 * item em `shop_items` (`theme_` -> tema, `avatar_` -> imagem de avatar,
 * qualquer outro cosmético -> moldura) e cada slot vive numa coluna de `users`.
 */
const SLOT_COLUMNS = {
  frame: 'equipped_avatar_frame',
  theme: 'equipped_theme',
  avatar: 'equipped_avatar_image',
};

function slotForKey(key) {
  if (key.startsWith('theme_')) return 'theme';
  if (key.startsWith('avatar_')) return 'avatar';
  return 'frame';
}

function columnForSlot(slot) {
  return Object.prototype.hasOwnProperty.call(SLOT_COLUMNS, slot) ? SLOT_COLUMNS[slot] : null;
}

module.exports = { SLOT_COLUMNS, slotForKey, columnForSlot };
