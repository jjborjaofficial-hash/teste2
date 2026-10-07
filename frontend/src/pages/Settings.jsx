import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Card } from '../components/Card';
import { SecondaryButton } from '../components/Button';
import { ChevronRightIcon } from '../icons';
import { walletApi } from '../api/gameplayApi';
import { DEFAULT_WITHDRAWAL_MIN_MZN } from './Wallet';

function mzn(v) {
  return `${Number(v).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

/**
 * Configurações da conta: dados da conta, estado do saque e terminar sessão.
 * (Edição de nome/foto/provedor de pagamento precisa de um endpoint novo no backend.)
 */
export function Settings() {
  const { user, logout } = useAuth();
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

  return (
    <div className="space-y-5 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <button onClick={() => navigate(-1)} aria-label="Voltar" className="w-10 h-10 flex items-center justify-center text-text-secondary">
          <ChevronRightIcon className="w-5 h-5 rotate-180" />
        </button>
        <h1 className="font-display text-h1 text-text">Configurações</h1>
      </header>

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

      <SecondaryButton onClick={handleLogout} className="w-full">Terminar sessão</SecondaryButton>
    </div>
  );
}
