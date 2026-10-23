/**
 * Molduras de perfil compráveis na Loja (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS" — catálogo de personalização). Cada chave corresponde
 * exatamente ao `key` do item em `shop_items` (migration 020). Compartilhado
 * entre Profile.jsx e Ranking.jsx para que a moldura apareça de forma
 * consistente em qualquer lugar onde o usuário é exibido — sem isso, o item
 * de status só aparecia para o próprio dono, esvaziando o propósito da compra.
 */
/**
 * Imagens de avatar compráveis na Loja (migrations 730/732). O nome do ficheiro em src/assets/avatars é a
 * chave do item em `shop_items` (prefixo `avatar_`): `avatar_naruto.webp` -> `avatar_naruto`. A imagem equipada
 * substitui a foto/ícone do utilizador no Perfil, no Painel, no Ranking e na celebração de nível.
 * Para vender outro avatar: pôr o .webp em src/assets/avatars e semear o item numa migration (nada mais).
 */
const avatarFiles = import.meta.glob('../assets/avatars/*.webp', { eager: true, import: 'default' });
export const AVATAR_IMAGES = Object.fromEntries(
  Object.entries(avatarFiles).map(([path, url]) => [path.split('/').pop().replace(/\.webp$/, ''), url])
);

/** Slot de um item pelo prefixo da chave — igual ao do backend (backend/src/modules/shop/slots.js). */
export function slotForKey(key) {
  if (key.startsWith('theme_')) return 'theme';
  if (key.startsWith('avatar_')) return 'avatar';
  return 'frame';
}

export const AVATAR_FRAME_CLASSES = {
  frame_streak: 'ring-4 ring-warning ring-offset-2 ring-offset-background',
  frame_champion: 'ring-4 ring-gold ring-offset-2 ring-offset-background shadow-[0_0_16px_rgb(var(--color-gold)/0.5)]',
  // Molduras por categoria (migration 023) — recompensa de identidade para
  // quem se especializa numa área específica das 5 categorias oficiais.
  frame_financas: 'ring-4 ring-success ring-offset-2 ring-offset-background',
  frame_tecnologia: 'ring-4 ring-info ring-offset-2 ring-offset-background',
  frame_ia: 'ring-4 ring-primary ring-offset-2 ring-offset-background',
  frame_marketing: 'ring-4 ring-danger ring-offset-2 ring-offset-background',
  frame_produtividade: 'ring-4 ring-warning ring-offset-2 ring-offset-background',
};
