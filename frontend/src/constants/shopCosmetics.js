/**
 * Molduras de perfil compráveis na Loja (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS" — catálogo de personalização). Cada chave corresponde
 * exatamente ao `key` do item em `shop_items` (migration 020). Compartilhado
 * entre Profile.jsx e Ranking.jsx para que a moldura apareça de forma
 * consistente em qualquer lugar onde o usuário é exibido — sem isso, o item
 * de status só aparecia para o próprio dono, esvaziando o propósito da compra.
 */
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
