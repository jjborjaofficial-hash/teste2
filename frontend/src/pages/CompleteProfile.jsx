import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';

/**
 * Tela "Completar Perfil" — passo obrigatório logo após o primeiro login via
 * Google (Doc. Mestre Seção 17, variante Google). A conta já existe e já
 * está autenticada nesse ponto; falta só o telefone M-Pesa/e-Mola (exigido
 * para a carteira, Seção 16.1) e o check-in jurídico (maioridade + Termos),
 * que o Google não fornece.
 *
 * Espelha o ProtectedRoute/needsTermsReacceptance: enquanto user.needsPhone
 * for true, o app inteiro fica bloqueado nesta tela.
 */
export function CompleteProfile() {
  const { user, completeProfile } = useAuth();
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [isAdultDeclared, setIsAdultDeclared] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    if (!isAdultDeclared || !termsAccepted) {
      setError('É necessário declarar maioridade e aceitar os Termos de Uso para continuar.');
      return;
    }

    setLoading(true);
    try {
      await completeProfile({ phone, isAdultDeclared: true, termsAccepted: true });
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível completar seu perfil.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center px-6 py-10">
      <div className="max-w-md mx-auto w-full">
        <h1 className="font-display text-h1 text-text mb-1">
          Quase lá{user?.name ? `, ${user.name.split(' ')[0]}` : ''}!
        </h1>
        <p className="text-body text-text-secondary mb-8">
          Só falta o seu número M-Pesa ou e-Mola, para onde vai o dinheiro das suas
          recompensas. Nenhum depósito ou cartão é necessário — você só recebe, nunca envia.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="phone" className="text-caption text-text-secondary block mb-1">
              Número de telefone (M-Pesa 84/85 ou e-Mola 86/87)
            </label>
            <input
              id="phone"
              type="tel"
              inputMode="numeric"
              placeholder="84XXXXXXX"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
          </div>

          <label className="flex items-start gap-3 text-caption text-text-secondary">
            <input
              type="checkbox"
              checked={isAdultDeclared}
              onChange={(e) => setIsAdultDeclared(e.target.checked)}
              className="mt-0.5 w-5 h-5 accent-primary shrink-0"
            />
            Declaro que sou maior de idade.
          </label>

          <label className="flex items-start gap-3 text-caption text-text-secondary">
            <input
              type="checkbox"
              checked={termsAccepted}
              onChange={(e) => setTermsAccepted(e.target.checked)}
              className="mt-0.5 w-5 h-5 accent-primary shrink-0"
            />
            Li e concordo com os{' '}
            <a href="/termos" target="_blank" rel="noreferrer" className="text-primary font-semibold">
              Termos de Uso
            </a>{' '}
            e a{' '}
            <a href="/privacidade" target="_blank" rel="noreferrer" className="text-primary font-semibold">
              Política de Privacidade
            </a>{' '}
            do Aprenda e Ganhe.
          </label>

          {error && <p className="text-danger text-caption">{error}</p>}

          <PrimaryButton type="submit" loading={loading} className="w-full">
            Continuar
          </PrimaryButton>
        </form>
      </div>
    </div>
  );
}
