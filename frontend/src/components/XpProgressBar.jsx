/**
 * Barra de Progresso XP (Doc. Mestre Seção 13.4).
 * Normal: trilho --border, preenchimento gradiente --gold->--warning, altura 8px.
 * Ao ganhar XP: anima em 0.6s ease-out, nunca instantâneo (duration-xp = 600ms).
 */
export function XpProgressBar({ percent, className = '' }) {
  const clamped = Math.max(0, Math.min(100, percent));

  return (
    <div className={`h-2 w-full rounded-full bg-border overflow-hidden ${className}`}>
      <div
        className="h-full rounded-full bg-gradient-to-r from-gold to-warning transition-all duration-xp ease-out"
        style={{ width: `${clamped}%` }}
        role="progressbar"
        aria-valuenow={clamped}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label="Progresso de XP para o próximo nível"
      />
    </div>
  );
}
