/**
 * Badge de Recompensa (Doc. Mestre Seção 13.4).
 * Normal: fundo --gold a 12%, texto --gold, radius pill.
 * Nova conquista (Seção 13.6 — Conquistas/Medalhas): pop-in (scale 0->1.1->1)
 * + confete leve + brilho pulsante em loop (não apenas um flash único).
 */
export function RewardBadge({ children, isNew = false, className = '' }) {
  return (
    <span className="relative inline-flex">
      {isNew && (
        <>
          {/* Confete leve: 4 pontinhos que caem e desaparecem, atrasados em
              cascata para não parecerem um bloco só. */}
          <span className="pointer-events-none absolute -top-1 left-1/4 w-1 h-1 rounded-full bg-gold animate-confetti" style={{ animationDelay: '0ms' }} />
          <span className="pointer-events-none absolute -top-1 left-1/2 w-1 h-1 rounded-full bg-warning animate-confetti" style={{ animationDelay: '120ms' }} />
          <span className="pointer-events-none absolute -top-1 left-2/3 w-1 h-1 rounded-full bg-gold animate-confetti" style={{ animationDelay: '220ms' }} />
          <span className="pointer-events-none absolute -top-1 left-1/3 w-1 h-1 rounded-full bg-warning animate-confetti" style={{ animationDelay: '80ms' }} />
        </>
      )}
      <span
        className={`
          inline-flex items-center gap-1 rounded-full px-3 py-1 text-caption font-semibold
          bg-gold/10 text-gold
          ${isNew ? 'animate-pop-in animate-glow-pulse' : ''}
          ${className}
        `}
      >
        {children}
      </span>
    </span>
  );
}
