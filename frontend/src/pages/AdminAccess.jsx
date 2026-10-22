import { useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';
import { cleanPhone } from '../lib/phone';
import { isAdminRole, unlockAdmin } from '../lib/adminUnlock';

/** Acesso de administrador: só quem já tem o papel de admin chega aqui (o ícone só aparece a eles). */
export function AdminAccess() {
  const { user, login } = useAuth();
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  if (!isAdminRole(user)) return <Navigate to="/dashboard" replace />;

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const entered = await login({ phone, password });
      if (!isAdminRole(entered)) {
        setError('Estas credenciais não são de administrador.');
        return;
      }
      unlockAdmin();
      navigate('/admin', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível entrar. Tente novamente.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="max-w-md mx-auto w-full pt-6 pb-4">
      <h1 className="font-display text-h1 text-text mb-1">Acesso de administrador</h1>
      <p className="text-body text-text-secondary mb-6">Confirme o número e a senha para abrir o painel.</p>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="admin-phone" className="text-caption text-text-secondary block mb-1">Número de telefone</label>
          <input
            id="admin-phone"
            type="tel"
            inputMode="numeric"
            placeholder="84XXXXXXX"
            value={phone}
            maxLength={9}
            onChange={(e) => setPhone(cleanPhone(e.target.value))}
            required
            className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
          />
        </div>
        <div>
          <label htmlFor="admin-password" className="text-caption text-text-secondary block mb-1">Senha</label>
          <input
            id="admin-password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
          />
        </div>
        {error && <p className="text-danger text-caption">{error}</p>}
        <PrimaryButton type="submit" loading={loading} className="w-full">Entrar no painel</PrimaryButton>
      </form>
    </div>
  );
}
