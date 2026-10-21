import { useEffect, useMemo, useRef, useState } from 'react';
import { ProfileIcon, XpIcon } from '../icons';
import { AVATAR_FRAME_CLASSES } from '../constants/shopCosmetics';

/**
 * Ecrã de celebração ao subir de nível (FE-007).
 *
 * Só apresentação: não dá dinheiro nem Pontos e não depende de rede (usa o que o
 * servidor já devolveu: `newLevel`). Mostra a identidade da plataforma (marca
 * "Aprenda e Ganhe", mesmas cores do site) e a do utilizador (foto ou ícone, a
 * moldura que tem equipada e o nome).
 *
 * Animação: raios a rodar, medalha com o número do nível a "bater", explosão de
 * confetes, brilhos a piscar. Com "reduzir movimento" ligado (ver index.css,
 * Doc. Mestre 13.7) tudo fica estático. Fecha com o botão, com Escape ou ao tocar
 * fora do cartão; nunca bloqueia o fluxo do quiz.
 */
// Classes completas (o Tailwind só gera o que lê escrito por extenso no código).
const CONFETTI_COLORS = ['bg-gold', 'bg-primary', 'bg-secondary', 'bg-success', 'bg-warning', 'bg-info'];
const CONFETTI_COUNT = 28;
const SPARKLE_COUNT = 8;

// Posições pseudo-aleatórias estáveis (sem Math.random no render, para não "saltarem" a cada re-render).
function buildConfetti() {
  return Array.from({ length: CONFETTI_COUNT }, (_, i) => {
    const angle = (i / CONFETTI_COUNT) * Math.PI * 2 + (i % 3) * 0.17;
    const distance = 90 + ((i * 37) % 70);
    return {
      id: i,
      color: CONFETTI_COLORS[i % CONFETTI_COLORS.length],
      dx: Math.round(Math.cos(angle) * distance),
      dy: Math.round(Math.sin(angle) * distance) - 30,
      rot: (i * 53) % 360,
      delay: 0.35 + (i % 7) * 0.04,
      size: 6 + (i % 3) * 3,
      round: i % 2 === 0,
    };
  });
}

function buildSparkles() {
  return Array.from({ length: SPARKLE_COUNT }, (_, i) => {
    const angle = (i / SPARKLE_COUNT) * Math.PI * 2;
    return {
      id: i,
      left: 50 + Math.cos(angle) * 46,
      top: 50 + Math.sin(angle) * 46,
      delay: (i % 4) * 0.35,
    };
  });
}

export function LevelUpCelebration({ level, previousLevel, xpAwarded, user, onClose }) {
  const closeRef = useRef(null);
  const confetti = useMemo(buildConfetti, []);
  const sparkles = useMemo(buildSparkles, []);
  const [photoFailed, setPhotoFailed] = useState(false);
  const firstName = (user?.name || '').trim().split(/\s+/)[0] || '';
  const frameClass = AVATAR_FRAME_CLASSES[user?.equippedAvatarFrame] || '';
  const showPhoto = Boolean(user?.avatarUrl) && !photoFailed;

  useEffect(() => {
    closeRef.current?.focus({ preventScroll: true });
    const onKey = (e) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 px-5 overflow-hidden"
      role="dialog"
      aria-modal="true"
      aria-label={`Subiu para o nível ${level}`}
      onClick={onClose}
    >
      <style>{`
        @keyframes lu-card-in { 0% { transform: translateY(24px) scale(.88); opacity: 0 } 60% { transform: translateY(-4px) scale(1.02); opacity: 1 } 100% { transform: translateY(0) scale(1); opacity: 1 } }
        @keyframes lu-rays { from { transform: translate(-50%, -50%) rotate(0deg) } to { transform: translate(-50%, -50%) rotate(360deg) } }
        @keyframes lu-glow { 0%, 100% { opacity: .55; transform: translate(-50%, -50%) scale(1) } 50% { opacity: .9; transform: translate(-50%, -50%) scale(1.12) } }
        @keyframes lu-badge { 0% { transform: scale(.2) rotate(-25deg); opacity: 0 } 55% { transform: scale(1.22) rotate(6deg); opacity: 1 } 75% { transform: scale(.94) rotate(-2deg) } 100% { transform: scale(1) rotate(0) } }
        @keyframes lu-num { 0% { transform: scale(.4); opacity: 0 } 60% { transform: scale(1.25) } 100% { transform: scale(1); opacity: 1 } }
        @keyframes lu-float { 0%, 100% { transform: translateY(0) } 50% { transform: translateY(-5px) } }
        @keyframes lu-confetti { 0% { transform: translate(0, 0) rotate(0deg) scale(.4); opacity: 0 } 15% { opacity: 1 } 100% { transform: translate(var(--dx), calc(var(--dy) + 120px)) rotate(var(--rot)) scale(1); opacity: 0 } }
        @keyframes lu-sparkle { 0%, 100% { transform: scale(0) rotate(0deg); opacity: 0 } 50% { transform: scale(1) rotate(90deg); opacity: 1 } }
        @keyframes lu-fade-up { from { transform: translateY(10px); opacity: 0 } to { transform: translateY(0); opacity: 1 } }
        .lu-card { animation: lu-card-in .6s cubic-bezier(.2,.8,.2,1) both; }
        .lu-rays { position: absolute; left: 50%; top: 50%; width: 900px; height: 900px; margin: 0;
          background: repeating-conic-gradient(from 0deg, rgb(var(--color-gold) / .28) 0deg 8deg, transparent 8deg 24deg);
          -webkit-mask-image: radial-gradient(circle, #000 25%, transparent 70%); mask-image: radial-gradient(circle, #000 25%, transparent 70%);
          border-radius: 9999px; animation: lu-rays 22s linear infinite; pointer-events: none; }
        .lu-glow { position: absolute; left: 50%; top: 50%; width: 300px; height: 300px; border-radius: 9999px;
          background: radial-gradient(circle, rgb(var(--color-gold) / .45), transparent 65%); animation: lu-glow 2.6s ease-in-out infinite; pointer-events: none; }
        .lu-badge { animation: lu-badge .9s cubic-bezier(.2,.9,.3,1.2) .2s both; }
        .lu-badge-inner { animation: lu-float 3s ease-in-out 1.2s infinite; }
        .lu-num { animation: lu-num .6s ease-out .75s both; }
        .lu-confetti { position: absolute; left: 50%; top: 40%; animation: lu-confetti 1.9s cubic-bezier(.15,.7,.3,1) var(--delay) both; pointer-events: none; }
        .lu-sparkle { position: absolute; width: 14px; height: 14px; animation: lu-sparkle 1.8s ease-in-out var(--delay) infinite; pointer-events: none; }
        .lu-sparkle::before, .lu-sparkle::after { content: ''; position: absolute; background: rgb(var(--color-gold)); border-radius: 2px; }
        .lu-sparkle::before { left: 6px; top: 0; width: 2px; height: 14px; }
        .lu-sparkle::after { left: 0; top: 6px; width: 14px; height: 2px; }
        .lu-up1 { animation: lu-fade-up .5s ease-out .9s both; }
        .lu-up2 { animation: lu-fade-up .5s ease-out 1.1s both; }
        .lu-up3 { animation: lu-fade-up .5s ease-out 1.3s both; }
        @media (prefers-reduced-motion: reduce) {
          .lu-card, .lu-rays, .lu-glow, .lu-badge, .lu-badge-inner, .lu-num, .lu-confetti, .lu-sparkle, .lu-up1, .lu-up2, .lu-up3 { animation: none !important; }
          .lu-confetti { display: none; }
          .lu-sparkle { opacity: 1; transform: scale(1); }
        }
      `}</style>

      {/* Fundo: raios e brilho atrás do cartão. */}
      <div className="lu-rays" aria-hidden="true" />
      <div className="lu-glow" aria-hidden="true" />

      <div
        className="lu-card relative w-full max-w-sm bg-surface border border-gold/40 rounded-card px-6 pt-8 pb-6 text-center shadow-[0_0_40px_rgb(var(--color-gold)/0.25)]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Identidade da plataforma. */}
        <p className="font-display text-caption font-semibold tracking-[0.2em] uppercase text-gold">Aprenda e Ganhe</p>

        {/* Medalha com o nível. */}
        <div className="relative mx-auto mt-5 mb-5 w-36 h-36 flex items-center justify-center">
          {sparkles.map((s) => (
            <span key={s.id} className="lu-sparkle" style={{ left: `${s.left}%`, top: `${s.top}%`, '--delay': `${s.delay}s`, marginLeft: -7, marginTop: -7 }} aria-hidden="true" />
          ))}
          <div className="lu-badge w-full h-full">
            <div className="lu-badge-inner w-full h-full rounded-full flex flex-col items-center justify-center bg-gradient-to-b from-gold/30 to-primary/30 border-4 border-gold shadow-[0_0_28px_rgb(var(--color-gold)/0.55)]">
              <XpIcon className="w-6 h-6 text-gold" />
              <span className="lu-num font-display text-highlight text-text leading-none mt-1">{level}</span>
              <span className="text-caption text-text-secondary uppercase tracking-wider mt-1">Nível</span>
            </div>
          </div>
        </div>

        <h2 className="lu-up1 font-display text-h1 text-text">Subiu de nível!</h2>
        <p className="lu-up1 text-body text-text-secondary mt-1">
          {previousLevel && previousLevel < level ? `Do nível ${previousLevel} para o nível ${level}` : `Agora está no nível ${level}`}
          {xpAwarded > 0 ? ` · +${xpAwarded} XP` : ''}
        </p>

        {/* Identidade do utilizador: foto ou ícone, com a moldura equipada. */}
        <div className="lu-up2 mt-5 flex items-center justify-center gap-3">
          <div className={`w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center overflow-hidden shrink-0 ${frameClass}`}>
            {showPhoto ? (
              <img src={user.avatarUrl} alt="" className="w-full h-full object-cover" onError={() => setPhotoFailed(true)} referrerPolicy="no-referrer" />
            ) : (
              <ProfileIcon className="w-7 h-7 text-primary" />
            )}
          </div>
          <div className="text-left min-w-0">
            <p className="font-display font-semibold text-text truncate">{firstName || 'Estudante'}</p>
            <p className="text-caption text-text-secondary">Continue a aprender e a ganhar</p>
          </div>
        </div>

        <button
          ref={closeRef}
          type="button"
          onClick={onClose}
          className="lu-up3 mt-6 w-full min-h-[44px] rounded-button bg-primary text-white font-semibold text-button"
        >
          Continuar
        </button>
      </div>

      {/* Confetes que explodem a partir da medalha. */}
      <div className="absolute inset-0 z-10 pointer-events-none" aria-hidden="true">
        {confetti.map((c) => (
          <span
            key={c.id}
            className={`lu-confetti ${c.color}`}
            style={{
              '--dx': `${c.dx}px`,
              '--dy': `${c.dy}px`,
              '--rot': `${c.rot}deg`,
              '--delay': `${c.delay}s`,
              width: c.size,
              height: c.round ? c.size : c.size * 1.7,
              borderRadius: c.round ? '9999px' : '2px',
            }}
          />
        ))}
      </div>
    </div>
  );
}
