import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';

export function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await login({ phone, password });
      const redirectTo = location.state?.from?.pathname || '/dashboard';
      navigate(redirectTo, { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível entrar. Tente novamente.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center px-6">
      <div className="max-w-md mx-auto w-full">
        <h1 className="font-display text-h1 text-text mb-1">Bem-vindo de volta</h1>
        <p className="text-body text-text-secondary mb-8">
          Entre para continuar sua ofensiva de estudos.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="phone" className="text-caption text-text-secondary block mb-1">
              Número de telefone
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

          <div>
            <label htmlFor="password" className="text-caption text-text-secondary block mb-1">
              Senha
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
          </div>

          {error && <p className="text-danger text-caption">{error}</p>}

          <PrimaryButton type="submit" loading={loading} className="w-full">
            Entrar
          </PrimaryButton>
        </form>

        <p className="text-caption text-text-secondary text-center mt-6">
          Ainda não tem conta?{' '}
          <Link to="/cadastro" className="text-primary font-semibold">
            Criar Nova Conta
          </Link>
        </p>
      </div>
    </div>
  );
}
