import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Card } from '../components/Card';
import { OperatorLogo } from '../components/OperatorLogo';
import { isValidPhone } from '../lib/phone';
import { ThemeTrialCard } from '../components/ThemeTrialCard';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { usersApi } from '../api/profileApi';
import { ChevronRightIcon } from '../icons';
import { walletApi } from '../api/gameplayApi';
import { DEFAULT_WITHDRAWAL_MIN_MZN } from './Wallet';

function mzn(v) {
  return `${Number(v).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

/**
 * Configurações da conta: dados da conta, estado do saque e terminar sessão.
 * Também: editar nome/foto, mudar o número M-Pesa/e-Mola, baixar os seus dados e eliminar a conta.
 */
export function Settings() {
  const { user, logout, refreshProfile } = useAuth();
  const { showToast } = useToast();
  const navigate = useNavigate();

  // Saque mínimo vindo do servidor (valor de reserva até a resposta chegar).
  const [withdrawalMin, setWithdrawalMin] = useState(DEFAULT_WITHDRAWAL_MIN_MZN);
  useEffect(() => {
    walletApi.getBalance()
      .then((res) => {
        const min = Number(res.data.withdrawalMinMzn);
        if (Number.isFinite(min) && min > 0) setWithdrawalMin(min);
      })
      .catch(() => {});
  }, []);

  const balance = Number(user?.walletBalanceMzn ?? 0);
  const missing = Math.max(0, withdrawalMin - balance);
  const percent = Math.min(100, Math.round((balance / withdrawalMin) * 100));

  async function handleLogout() {
    await logout();
    navigate('/onboarding', { replace: true });
  }

  const [name, setName] = useState(user?.name || '');
  const [avatarUrl, setAvatarUrl] = useState(user?.avatarUrl || '');
  const [phone, setPhone] = useState('');
  const [phonePassword, setPhonePassword] = useState('');
  const [curPass, setCurPass] = useState('');
  const [newPass, setNewPass] = useState('');
  const [newPass2, setNewPass2] = useState('');
  const [delPassword, setDelPassword] = useState('');
  const [delConfirm, setDelConfirm] = useState('');
  const [acceptLose, setAcceptLose] = useState(false);
  const [busy, setBusy] = useState('');

  const inputClass = 'w-full rounded-button border border-border bg-transparent px-3 py-2 text-body text-text';
  const providerLabel = user?.phoneProvider === 'emola' ? 'e-Mola' : user?.phoneProvider === 'mpesa' ? 'M-Pesa' : '';

  async function run(key, fn, okMsg) {
    setBusy(key);
    try {
      await fn();
      if (okMsg) showToast(okMsg, 'success');
    } catch (err) {
      showToast(err.message || 'Não foi possível concluir.', 'error');
    } finally {
      setBusy('');
    }
  }

  const saveProfile = () => run('profile', async () => {
    await usersApi.update({ name: name.trim(), avatarUrl: avatarUrl.trim() ? avatarUrl.trim() : null });
    await refreshProfile();
  }, 'Perfil atualizado.');

  const savePhone = () => run('phone', async () => {
    await usersApi.changePaymentPhone({ phone: phone.trim(), password: phonePassword || undefined });
    setPhone('');
    setPhonePassword('');
    await refreshProfile();
  }, 'Número de pagamento atualizado.');

  const savePassword = () => run('password', async () => {
    if (newPass !== newPass2) throw new Error('As duas senhas novas não são iguais.');
    await usersApi.changePassword({ currentPassword: curPass || undefined, newPassword: newPass });
    setCurPass('');
    setNewPass('');
    setNewPass2('');
    await refreshProfile();
  }, 'Senha atualizada. Os outros aparelhos foram desligados.');

  const downloadData = () => run('export', async () => {
    const res = await usersApi.exportData();
    const blob = new Blob([JSON.stringify(res.data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'meus-dados.json';
    a.click();
    URL.revokeObjectURL(url);
  }, 'Ficheiro com os seus dados descarregado.');

  const deleteAccount = () => run('delete', async () => {
    await usersApi.deleteAccount({
      password: delPassword || undefined,
      confirmation: delConfirm,
      acceptLoseBalance: acceptLose,
    });
    await logout();
    navigate('/onboarding', { replace: true });
  });

  return (
    <div className="space-y-5 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <button onClick={() => navigate(-1)} aria-label="Voltar" className="w-10 h-10 flex items-center justify-center text-text-secondary">
          <ChevronRightIcon className="w-5 h-5 rotate-180" />
        </button>
        <h1 className="font-display text-h1 text-text">Configurações</h1>
      </header>

      <ThemeTrialCard />

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">Conta</h2>
        <Card className="space-y-2">
          <div className="flex justify-between text-body">
            <span className="text-text-secondary">Nome</span>
            <span className="text-text">{user?.name}</span>
          </div>
          <div className="flex justify-between text-body">
            <span className="text-text-secondary">Telefone</span>
            <span className="text-text">{user?.phone}</span>
          </div>
          {user?.email && (
            <div className="flex justify-between text-body">
              <span className="text-text-secondary">E-mail (Google)</span>
              <span className="text-text">{user.email}</span>
            </div>
          )}
          {user?.memberSince && (
            <div className="flex justify-between text-body">
              <span className="text-text-secondary">Membro desde</span>
              <span className="text-text">{new Date(user.memberSince).toLocaleDateString('pt-PT')}</span>
            </div>
          )}
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">Saque</h2>
        <Card className="space-y-2">
          <div className="flex justify-between text-body">
            <span className="text-text-secondary">Saldo</span>
            <span className="text-gold font-semibold">{mzn(balance)}</span>
          </div>
          <div className="h-1 bg-border rounded-full overflow-hidden">
            <div className="h-full bg-gold transition-all duration-500" style={{ width: `${percent}%` }} />
          </div>
          <p className="text-caption text-text-secondary">
            {missing > 0
              ? `Faltam ${mzn(missing)} para o saque mínimo de ${mzn(withdrawalMin)}.`
              : 'Você já pode solicitar saque na Carteira.'}
          </p>
          <Link to="/carteira" className="text-primary text-caption font-semibold">Ir para a Carteira</Link>
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">Editar perfil</h2>
        <Card className="space-y-3">
          <label className="block text-caption text-text-secondary">Nome
            <input className={inputClass} value={name} maxLength={120} onChange={(e) => setName(e.target.value)} />
          </label>
          <label className="block text-caption text-text-secondary">Foto (link https, opcional)
            <input className={inputClass} value={avatarUrl} placeholder="https://..." onChange={(e) => setAvatarUrl(e.target.value)} />
          </label>
          <PrimaryButton onClick={saveProfile} loading={busy === 'profile'} disabled={name.trim().length < 2}>Guardar</PrimaryButton>
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">{user?.hasPassword ? 'Mudar senha' : 'Criar senha'}</h2>
        <Card className="space-y-3">
          {!user?.hasPassword && (
            <p className="text-caption text-text-secondary">
              A sua conta foi criada com o Google{user?.email ? ` (${user.email})` : ''}. O e-mail não muda, mas pode criar uma senha
              para também entrar com telefone e senha.
            </p>
          )}
          {user?.hasPassword && (
            <label className="block text-caption text-text-secondary">Senha atual
              <input className={inputClass} type="password" value={curPass} onChange={(e) => setCurPass(e.target.value)} />
            </label>
          )}
          <label className="block text-caption text-text-secondary">Nova senha (mínimo 8 caracteres)
            <input className={inputClass} type="password" value={newPass} onChange={(e) => setNewPass(e.target.value)} />
          </label>
          <label className="block text-caption text-text-secondary">Repita a nova senha
            <input className={inputClass} type="password" value={newPass2} onChange={(e) => setNewPass2(e.target.value)} />
          </label>
          <PrimaryButton onClick={savePassword} loading={busy === 'password'} disabled={newPass.length < 8 || (user?.hasPassword && !curPass)}>
            {user?.hasPassword ? 'Mudar senha' : 'Criar senha'}
          </PrimaryButton>
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">Número de pagamento</h2>
        <Card className="space-y-3">
          <p className="text-caption text-text-secondary">
            Atual: {user?.phone || '—'} {providerLabel && `(${providerLabel})`}. É para este número que o dinheiro dos saques é enviado.
            O operador (M-Pesa ou e-Mola) é detetado pelo número. Só pode mudar uma vez a cada 30 dias e não durante um saque em andamento.
          </p>
          <label className="block text-caption text-text-secondary">Novo número
            <div className="relative mt-1">
              <input className={`${inputClass} pr-24`} value={phone} inputMode="numeric" maxLength={9} placeholder="84xxxxxxx" onChange={(e) => setPhone(e.target.value.replace(/\D/g, ''))} />
              <OperatorLogo phone={phone} />
            </div>
          </label>
          {user?.hasPassword && (
            <label className="block text-caption text-text-secondary">Sua senha (para confirmar)
              <input className={inputClass} type="password" value={phonePassword} onChange={(e) => setPhonePassword(e.target.value)} />
            </label>
          )}
          <PrimaryButton onClick={savePhone} loading={busy === 'phone'} disabled={!isValidPhone(phone)}>Mudar número</PrimaryButton>
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-text">Os seus dados</h2>
        <Card className="space-y-3">
          <p className="text-caption text-text-secondary">Descarregue uma cópia de tudo o que a plataforma guarda sobre si (ficheiro JSON).</p>
          <SecondaryButton onClick={downloadData} loading={busy === 'export'}>Descarregar os meus dados</SecondaryButton>
        </Card>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-h2 text-danger">Eliminar conta</h2>
        <Card className="space-y-3">
          <p className="text-caption text-text-secondary">
            Remove o seu nome, número, e-mail e foto, e fecha a sessão. Isto não pode ser desfeito.
            Não é possível eliminar com um saque em andamento. O registo de transações fica guardado sem ligação à sua identidade.
          </p>
          {balance > 0 && (
            <label className="flex items-start gap-2 text-caption text-text">
              <input type="checkbox" checked={acceptLose} onChange={(e) => setAcceptLose(e.target.checked)} className="mt-1" />
              <span>Tenho {mzn(balance)} na carteira e aceito perder este saldo (ou levante-o antes).</span>
            </label>
          )}
          {user?.hasPassword && (
            <label className="block text-caption text-text-secondary">Sua senha
              <input className={inputClass} type="password" value={delPassword} onChange={(e) => setDelPassword(e.target.value)} />
            </label>
          )}
          <label className="block text-caption text-text-secondary">Escreva ELIMINAR para confirmar
            <input className={inputClass} value={delConfirm} onChange={(e) => setDelConfirm(e.target.value)} />
          </label>
          <SecondaryButton
            onClick={deleteAccount}
            loading={busy === 'delete'}
            disabled={delConfirm !== 'ELIMINAR' || (balance > 0 && !acceptLose)}
            className="w-full"
          >
            Eliminar a minha conta
          </SecondaryButton>
        </Card>
      </section>

      <SecondaryButton onClick={handleLogout} className="w-full">Terminar sessão</SecondaryButton>
    </div>
  );
}
