import { Link } from 'react-router-dom';
import { FireIcon } from '../icons';

/**
 * Animação de "ofensiva quebrada": a chama aparece no ecrã, racha ao meio e as
 * duas metades caem. Mostrada uma única vez por quebra (o Dashboard guarda em
 * localStorage o `brokenAt` já visto).
 */
export function StreakBrokenModal({ days, onClose }) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 px-6"
      role="dialog"
      aria-modal="true"
      aria-label="Ofensiva quebrada"
    >
      <style>{`
        @keyframes streak-appear { from { transform: scale(.6); opacity: 0 } to { transform: scale(1); opacity: 1 } }
        @keyframes streak-left  { 0%, 35% { transform: translate(0,0) rotate(0) } 100% { transform: translate(-34px, 78px) rotate(-24deg); opacity: 0 } }
        @keyframes streak-right { 0%, 35% { transform: translate(0,0) rotate(0) } 100% { transform: translate(34px, 90px) rotate(24deg); opacity: 0 } }
        @keyframes streak-crack { 0%, 30% { opacity: 0 } 40%, 100% { opacity: 1 } }
        .streak-flame { position: relative; width: 96px; height: 96px; animation: streak-appear .5s ease-out both; }
        .streak-half  { position: absolute; inset: 0; }
        .streak-half.left  { clip-path: polygon(0 0, 52% 0, 44% 35%, 56% 60%, 46% 100%, 0 100%); animation: streak-left 1.6s ease-in .5s forwards; }
        .streak-half.right { clip-path: polygon(52% 0, 100% 0, 100% 100%, 46% 100%, 56% 60%, 44% 35%); animation: streak-right 1.6s ease-in .5s forwards; }
        .streak-crack { position: absolute; left: 47%; top: 0; width: 3px; height: 100%; background: #fff; opacity: 0; animation: streak-crack .6s ease-out .3s forwards; }
        @media (prefers-reduced-motion: reduce) {
          .streak-flame, .streak-half.left, .streak-half.right, .streak-crack { animation: none; }
          .streak-half { opacity: .4; }
        }
      `}</style>

      <div className="bg-surface border border-border rounded-card p-6 w-full max-w-sm text-center space-y-4">
        <div className="flex justify-center h-28 items-center">
          <div className="streak-flame">
            <div className="streak-half left"><FireIcon className="w-24 h-24 text-warning" /></div>
            <div className="streak-half right"><FireIcon className="w-24 h-24 text-warning" /></div>
            <div className="streak-crack" />
          </div>
        </div>
        <h2 className="font-display text-h2 text-text">A sua ofensiva quebrou</h2>
        <p className="text-body text-text-secondary">
          {days > 0
            ? `Perdeu a sequência de ${days} dia${days > 1 ? 's' : ''}. Estude hoje para começar uma nova.`
            : 'Estude hoje para começar uma nova sequência.'}
        </p>
        <div className="flex flex-col gap-2">
          <Link to="/loja" onClick={onClose} className="text-primary text-body font-semibold">
            Recuperar ofensiva na Loja
          </Link>
          <button onClick={onClose} className="text-text-secondary text-caption">
            Recomeçar
          </button>
        </div>
      </div>
    </div>
  );
}
