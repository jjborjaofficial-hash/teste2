import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { legalApi } from '../api/legalApi';
import { PrimaryButton, SecondaryButton } from '../components/Button';

const LOCAL_KEY = 'aeg_cookie_choice';

/**
 * Gerenciador de preferências de cookies (docx "final jur.." Parte 8).
 * Antes do login, a escolha fica só no dispositivo (localStorage). Ao logar,
 * é sincronizada com o backend (cookie_preferences), conforme "As escolhas
 * deverão ser armazenadas".
 */
export function CookieBanner() {
  const { user } = useAuth();
  const [visible, setVisible] = useState(false);
  const [expanded, setExpanded] = useState(false);
  const [choices, setChoices] = useState({ preferences: false, analytics: false, advertising: false });

  useEffect(() => {
    async function init() {
      if (user) {
        try {
          const res = await legalApi.getCookiePreferences();
          if (!res.data.configured) {
            setVisible(true);
          }
        } catch {
          setVisible(false);
        }
      } else {
        const stored = localStorage.getItem(LOCAL_KEY);
        setVisible(!stored);
      }
    }
    init();
  }, [user]);

  async function persist(finalChoices) {
    localStorage.setItem(LOCAL_KEY, JSON.stringify(finalChoices));
    if (user) {
      try {
        await legalApi.setCookiePreferences(finalChoices);
      } catch {
        // Falha ao sincronizar não deve travar a navegação do usuário.
      }
    }
    setVisible(false);
  }

  function handleAcceptAll() {
    persist({ preferences: true, analytics: true, advertising: true });
  }

  function handleRejectAll() {
    persist({ preferences: false, analytics: false, advertising: false });
  }

  function handleSaveCustom() {
    persist(choices);
  }

  if (!visible) return null;

  return (
    <div className="fixed inset-x-0 bottom-0 z-50 bg-surface border-t border-border px-4 py-4 shadow-lg">
      <div className="max-w-md mx-auto space-y-3">
        <p className="text-body font-semibold text-text">Sua privacidade importa.</p>
        <p className="text-caption text-text-secondary">
          Utilizamos tecnologias necessárias para o funcionamento da plataforma e
          tecnologias adicionais para análise e publicidade. Veja a{' '}
          <Link to="/legal/cookies" className="text-primary font-semibold">Política de Cookies</Link>.
        </p>

        {expanded && (
          <div className="space-y-2 border-t border-border pt-3">
            <label className="flex items-center justify-between text-caption text-text-secondary">
              Cookies essenciais (sempre ativos)
              <input type="checkbox" checked disabled className="w-5 h-5 accent-border" />
            </label>
            <label className="flex items-center justify-between text-caption text-text-secondary">
              Cookies de preferência
              <input
                type="checkbox"
                checked={choices.preferences}
                onChange={(e) => setChoices((c) => ({ ...c, preferences: e.target.checked }))}
                className="w-5 h-5 accent-primary"
              />
            </label>
            <label className="flex items-center justify-between text-caption text-text-secondary">
              Cookies analíticos
              <input
                type="checkbox"
                checked={choices.analytics}
                onChange={(e) => setChoices((c) => ({ ...c, analytics: e.target.checked }))}
                className="w-5 h-5 accent-primary"
              />
            </label>
            <label className="flex items-center justify-between text-caption text-text-secondary">
              Cookies de publicidade
              <input
                type="checkbox"
                checked={choices.advertising}
                onChange={(e) => setChoices((c) => ({ ...c, advertising: e.target.checked }))}
                className="w-5 h-5 accent-primary"
              />
            </label>
          </div>
        )}

        <div className="flex gap-2">
          {!expanded && (
            <>
              <SecondaryButton onClick={handleRejectAll} className="flex-1">Recusar</SecondaryButton>
              <PrimaryButton onClick={handleAcceptAll} className="flex-1">Aceitar</PrimaryButton>
            </>
          )}
          {expanded && (
            <PrimaryButton onClick={handleSaveCustom} className="flex-1">Salvar preferências</PrimaryButton>
          )}
        </div>
        <button
          onClick={() => setExpanded((e) => !e)}
          className="text-caption text-text-secondary underline w-full text-center"
        >
          {expanded ? 'Ocultar opções' : 'Configurar preferências'}
        </button>
      </div>
    </div>
  );
}
