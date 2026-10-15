import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { GoogleCredentialButton } from '../components/GoogleCredentialButton';
import { ApiError } from '../api/client';

/**
 * Recuperar a conta sem SMS. A pessoa escolhe a senha nova e confirma que é ela
 * entrando com o Google que ligou antes à conta. Se nunca ligou, o servidor recusa.
 */
export function RecoverPassword() {
  const { recoverWithGoogle } = useAuth();
  const navigate = useNavigate();
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);

  const tooShort = password.length > 0 && password.length < 8;
  const mismatch = confirm.length > 0 && password !== confirm;
  const ready = password.length >= 8 && password === confirm;
  const inputClass =
    'w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none';

  async function handleCredential(idToken) {
    setError(null);
    setBusy(true);
    try {
      await recoverWithGoogle(idToken, password);
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível recuperar a conta. Tente novamente.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center px-6">
      <div className="max-w-md mx-auto w-full">
        <h1 className="font-display text-h1 text-text mb-1">Recuperar a conta</h1>
        <p className="text-body text-text-secondary mb-6">
          Escolha uma senha nova e confirme que é você entrando com o Google que ligou à sua conta.
        </p>

        <div className="space-y-4">
          <div>
            <label htmlFor="newPassword" className="text-caption text-text-secondary block mb-1">
              Nova senha (mínimo 8 caracteres)
            </label>
            <input
              id="newPassword"
              type="password"
              autoComplete="new-password"
              value={password}
              maxLength={72}
              onChange={(e) => setPassword(e.target.value)}
              className={inputClass}
            />
            {tooShort && <p className="text-danger text-caption mt-1">A senha deve ter pelo menos 8 caracteres.</p>}
          </div>
          <div>
            <label htmlFor="confirmPassword" className="text-caption text-text-secondary block mb-1">
              Repita a nova senha
            </label>
            <input
              id="confirmPassword"
              type="password"
              autoComplete="new-password"
              value={confirm}
              maxLength={72}
              onChange={(e) => setConfirm(e.target.value)}
              className={inputClass}
            />
            {mismatch && <p className="text-danger text-caption mt-1">As senhas não são iguais.</p>}
          </div>

          {ready ? (
            <div className="pt-2 space-y-2">
              <p className="text-caption text-text-secondary text-center">Agora confirme com o Google:</p>
              <GoogleCredentialButton onCredential={handleCredential} text="continue_with" />
              {busy && <p className="text-caption text-text-secondary text-center">A recuperar a conta...</p>}
            </div>
          ) : (
            <p className="text-caption text-text-secondary text-center pt-2">
              Preencha a senha nova nos dois campos para continuar.
            </p>
          )}

          {error && <p className="text-danger text-caption text-center">{error}</p>}
        </div>

        <p className="text-caption text-text-secondary text-center mt-6">
          Nunca ligou o Google à conta? Fale com o suporte.{' '}
          <Link to="/entrar" className="text-primary font-semibold">
            Voltar ao login
          </Link>
        </p>
      </div>
    </div>
  );
}
