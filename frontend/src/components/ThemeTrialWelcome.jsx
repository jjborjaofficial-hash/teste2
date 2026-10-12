import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton, SecondaryButton } from './Button';
import { useToast } from './Toast';
import { ApiError } from '../api/client';

function MoonIcon({ className = '' }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="M21 12.8A8.5 8.5 0 1 1 11.2 3a6.6 6.6 0 0 0 9.8 9.8Z" />
    </svg>
  );
}

/**
 * Tema Noite emprestado por 10 minutos (GER-002) — mostrado uma única vez, logo depois de criar a conta.
 * Ecrã 1: informa que o tema escuro foi emprestado por 10 minutos (o relógio ainda NÃO começa).
 * Ecrã 2: escolha entre "Modo escuro" (o servidor regista o início e a contagem começa) e "Modo claro"
 * (nada é gasto; a oferta continua disponível uma vez na Loja e nas Configurações).
 */
export function ThemeTrialWelcome() {
  const { startThemeTrial, dismissThemeTrialIntro } = useAuth();
  const { showToast } = useToast();
  const [step, setStep] = useState(0);
  const [busy, setBusy] = useState('');

  async function choose(kind) {
    setBusy(kind);
    try {
      if (kind === 'dark') await startThemeTrial();
      else await dismissThemeTrialIntro();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível guardar a sua escolha agora. Tente de novo.', 'error');
      setBusy('');
    }
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background px-6 text-center">
      <div className="w-full max-w-sm space-y-6">
        <MoonIcon className="w-14 h-14 text-primary mx-auto" />

        {step === 0 ? (
          <>
            <div className="space-y-3">
              <h1 className="font-display text-h1 text-text">Emprestámos-lhe o Tema Noite</h1>
              <p className="text-body text-text-secondary">
                Para experimentar o modo escuro, o Tema Noite foi emprestado por <strong className="text-text">10 minutos</strong>.
                Passado esse tempo, volta ao tema claro. Se gostar, pode ficar com ele na Loja.
              </p>
            </div>
            <PrimaryButton onClick={() => setStep(1)} className="w-full">Continuar</PrimaryButton>
          </>
        ) : (
          <>
            <div className="space-y-3">
              <h1 className="font-display text-h1 text-text">Que modo prefere agora?</h1>
              <p className="text-body text-text-secondary">
                Ao escolher o modo escuro, os 10 minutos começam a contar já. Se escolher o modo claro, a experiência continua
                disponível uma vez na Loja.
              </p>
            </div>
            <div className="space-y-3">
              <PrimaryButton onClick={() => choose('dark')} loading={busy === 'dark'} disabled={Boolean(busy)} className="w-full">
                Modo escuro
              </PrimaryButton>
              <SecondaryButton onClick={() => choose('light')} loading={busy === 'light'} disabled={Boolean(busy)} className="w-full">
                Modo claro
              </SecondaryButton>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
