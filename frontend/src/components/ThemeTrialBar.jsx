import { useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton, SecondaryButton } from './Button';

function useSecondsLeft(endsAtLocal, active) {
  const [secondsLeft, setSecondsLeft] = useState(() => (endsAtLocal ? Math.max(0, Math.ceil((endsAtLocal - Date.now()) / 1000)) : 0));
  useEffect(() => {
    if (!active || !endsAtLocal) return undefined;
    const tick = () => setSecondsLeft(Math.max(0, Math.ceil((endsAtLocal - Date.now()) / 1000)));
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, [endsAtLocal, active]);
  return secondsLeft;
}

export function formatTrialClock(seconds) {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${String(s).padStart(2, '0')}`;
}

/**
 * Tema Noite emprestado (GER-002): pílula discreta com a contagem e, quando acaba, um aviso não bloqueante com
 * atalho para a Loja. Não aparece durante o quiz (para não distrair nem interromper a pergunta e o cronómetro de
 * 50 s); o aviso de fim fica à espera e aparece quando o utilizador sai do quiz.
 */
export function ThemeTrialBar() {
  const { user, themeTrial, dismissTrialEnded } = useAuth();
  const location = useLocation();
  const secondsLeft = useSecondsLeft(themeTrial.endsAtLocal, themeTrial.active);
  const inQuiz = location.pathname.startsWith('/quiz');
  const ownsNight = user?.equippedTheme === 'theme_night';

  if (!user || inQuiz) return null;

  if (themeTrial.active && !ownsNight) {
    return (
      <Link
        to="/loja"
        aria-label={`Tema Noite emprestado, restam ${formatTrialClock(secondsLeft)}. Abrir a Loja.`}
        className="fixed top-2 left-1/2 -translate-x-1/2 z-40 flex items-center gap-2 rounded-full bg-surface border border-border px-3 py-1.5 text-caption text-text shadow-md"
      >
        <span aria-hidden="true">🌙</span>
        <span>Tema Noite emprestado</span>
        <span className="font-semibold text-primary tabular-nums">{formatTrialClock(secondsLeft)}</span>
      </Link>
    );
  }

  if (themeTrial.ended && !ownsNight) {
    return (
      <div role="status" aria-live="polite" className="fixed bottom-20 left-0 right-0 z-40 px-4">
        <div className="mx-auto max-w-md rounded-card bg-surface border border-border p-4 shadow-lg space-y-3">
          <p className="text-body text-text">
            O empréstimo do Tema Noite terminou e o site voltou ao tema claro. Pode ficar com o modo escuro na Loja.
          </p>
          <div className="flex gap-2">
            <Link to="/loja" onClick={dismissTrialEnded} className="flex-1">
              <PrimaryButton className="w-full !py-2">Ir à Loja</PrimaryButton>
            </Link>
            <SecondaryButton onClick={dismissTrialEnded} className="!py-2">Fechar</SecondaryButton>
          </div>
        </div>
      </div>
    );
  }

  return null;
}
