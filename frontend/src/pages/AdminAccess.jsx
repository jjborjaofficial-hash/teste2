import { useEffect, useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';
import { adminAccessApi } from '../api/adminAccessApi';
import { isAdminRole, unlockAdmin } from '../lib/adminUnlock';

const inputClass =
  'w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none';

function Field({ id, label, children }) {
  return (
    <div>
      <label htmlFor={id} className="text-caption text-text-secondary block mb-1">{label}</label>
      {children}
    </div>
  );
}

/**
 * Acesso de administrador. 1.ª vez: cria a SENHA DE ADMINISTRADOR (confirmando a senha normal da conta).
 * Depois: confirma número ou Gmail da conta + senha de administrador (diferente da senha de login).
 * Só chega aqui quem tem papel admin_* (o ícone no Perfil só aparece a eles).
 */
export function AdminAccess() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [passwordSet, setPasswordSet] = useState(null); // null = a carregar
  const [identifier, setIdentifier] = useState('');
  const [adminPassword, setAdminPassword] = useState('');
  const [currentPassword, setCurrentPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const isAdmin = isAdminRole(user);

  useEffect(() => {
    if (!isAdmin) return;
    adminAccessApi
      .status()
      .then((res) => setPasswordSet(res.data.adminPasswordSet))
      .catch(() => setError('Não foi possível carregar. Tente novamente.'));
  }, [isAdmin]);

  if (!isAdmin) return <Navigate to="/dashboard" replace />;

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    if (!passwordSet && adminPassword !== confirmPassword) {
      setError('As duas senhas de administrador não são iguais.');
      return;
    }
    setLoading(true);
    try {
      const res = passwordSet
        ? await adminAccessApi.unlock({ identifier, adminPassword })
        : await adminAccessApi.setPassword({ identifier, currentPassword, adminPassword });
      unlockAdmin(res.data);
      navigate('/admin', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível entrar. Tente novamente.');
    } finally {
      setLoading(false);
    }
  }

  if (passwordSet === null && !error) {
    return <p className="text-text-secondary text-body pt-6">Carregando...</p>;
  }

  return (
    <div className="max-w-md mx-auto w-full pt-6 pb-4">
      <h1 className="font-display text-h1 text-text mb-1">
        {passwordSet ? 'Acesso de administrador' : 'Criar senha de administrador'}
      </h1>
      <p className="text-body text-text-secondary mb-6">
        {passwordSet
          ? 'Confirme o seu número ou Gmail e a senha de administrador.'
          : 'É a senha só do painel, diferente da senha com que entra na plataforma. Mínimo 10 caracteres.'}
      </p>
      <form onSubmit={handleSubmit} className="space-y-4">
        <Field id="admin-id" label="Número de telefone ou Gmail da conta">
          <input
            id="admin-id"
            type="text"
            autoComplete="username"
            placeholder="84XXXXXXX ou nome@gmail.com"
            value={identifier}
            onChange={(e) => setIdentifier(e.target.value)}
            required
            className={inputClass}
          />
        </Field>
        {!passwordSet && (
          <Field id="admin-current" label="Senha normal da sua conta (a de login)">
            <input
              id="admin-current"
              type="password"
              autoComplete="current-password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              required
              className={inputClass}
            />
          </Field>
        )}
        <Field id="admin-password" label={passwordSet ? 'Senha de administrador' : 'Nova senha de administrador'}>
          <input
            id="admin-password"
            type="password"
            autoComplete="new-password"
            value={adminPassword}
            onChange={(e) => setAdminPassword(e.target.value)}
            required
            minLength={passwordSet ? undefined : 10}
            className={inputClass}
          />
        </Field>
        {!passwordSet && (
          <Field id="admin-confirm" label="Repita a senha de administrador">
            <input
              id="admin-confirm"
              type="password"
              autoComplete="new-password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              className={inputClass}
            />
          </Field>
        )}
        {error && <p className="text-danger text-caption">{error}</p>}
        <PrimaryButton type="submit" loading={loading} className="w-full">
          {passwordSet ? 'Entrar no painel' : 'Criar senha e entrar'}
        </PrimaryButton>
      </form>
    </div>
  );
}
