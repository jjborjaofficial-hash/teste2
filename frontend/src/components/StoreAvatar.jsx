import { AVATAR_IMAGES, AVATAR_FRAME_CLASSES } from '../constants/shopCosmetics';

/**
 * Avatar comprado na Loja e equipado pelo utilizador, com a moldura que ele também tenha equipado.
 * Não desenha nada se não houver avatar equipado (quem não comprou nenhum não vê diferença nenhuma).
 */
export function StoreAvatar({ user, className = 'w-12 h-12' }) {
  const src = AVATAR_IMAGES[user?.equippedAvatarImage];
  if (!src) return null;
  const frame = AVATAR_FRAME_CLASSES[user?.equippedAvatarFrame] || '';
  return <img src={src} alt="O seu avatar" className={`${className} rounded-full object-cover shrink-0 ${frame}`} />;
}
