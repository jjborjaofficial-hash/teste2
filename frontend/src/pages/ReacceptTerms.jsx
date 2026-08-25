import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { legalApi } from '../api/legalApi';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';

const DOC_ROUTES = {
  termos: '/termos',
  privacidade: '/privacidade',
};

/**
 * Tela de reaceite de documentos jurídicos obrigatórios (docx Parte 7:
 * "Alterações Jurídicas" — quando uma nova versão de Termos e/ou Privacidade
 * é publicada, o usuário precisa revisar e aceitar antes de continuar usando
 * o app). Lista dinamicamente QUALQUER documento obrigatório pendente, não
 * apenas os Termos — cobre o caso de mais de um ter mudado ao mesmo tempo.
 */
export function ReacceptTerms() {
  const { refreshProfile } = useAuth();
  const [pending, setPending] = useState(null);
  const [accepted, setAccepted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    legalApi.getPending().then((res) => setPending(res.data)).catch(() => setPending([]));
  }, []);

  async function handleConfirm() {
    if (!accepted) {
      setError('Você precisa marcar a caixa para continuar.');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      await legalApi.acceptMandatory();
      await refreshProfile();
      // Depois do refreshProfile, needsTermsReacceptance vira false e o guard
      // de rota (ver App.jsx) libera o resto do app automaticamente.
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível confirmar. Tente novamente.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center px-6">
      <div className="max-w-md mx-auto w-full space-y-4">
        <h1 className="font-display text-h1 text-text">Atualizamos nossos documentos</h1>
        <p className="text-body text-text-secondary">
          Para continuar usando o Aprenda e Ganhe, você precisa revisar e aceitar a
          versão mais recente {pending?.length === 1 ? 'do documento abaixo' : 'dos documentos abaixo'}.
        </p>

        {pending && pending.length > 0 && (
          <ul className="text-caption text-text-secondary space-y-1">
            {pending.map((doc) => (
              <li key={doc.type}>
                •{' '}
                <Link
                  to={DOC_ROUTES[doc.type] || `/legal/${doc.type}`}
                  target="_blank"
                  className="text-primary font-semibold"
                >
                  {doc.title}
                </Link>{' '}
                (versão {doc.version})
              </li>
            ))}
          </ul>
        )}

        <label className="flex items-start gap-3 text-caption text-text-secondary bg-surface border border-border rounded-card p-4">
          <input
            type="checkbox"
            checked={accepted}
            onChange={(e) => setAccepted(e.target.checked)}
            className="mt-0.5 w-5 h-5 accent-primary shrink-0"
          />
          Li e concordo com a versão atualizada dos documentos listados acima.
        </label>

        {error && <p className="text-danger text-caption">{error}</p>}

        <PrimaryButton onClick={handleConfirm} loading={loading} className="w-full">
          Confirmar e continuar
        </PrimaryButton>
      </div>
    </div>
  );
}
