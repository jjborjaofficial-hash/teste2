import { useEffect, useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import { adminApi } from '../../api/adminApi';
import { useAuth } from '../../context/AuthContext';
import {
  WalletIcon, ProfileIcon, QuizIcon, MissionsIcon, ShopIcon, NotificationIcon, TrustShieldIcon, AchievementIcon,
  ChevronRightIcon,
} from '../../icons';

const mzn = (n) =>
  `${Number(n || 0).toLocaleString('pt-MZ', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;

/** Cartão de número: tocável, leva à área onde se age sobre aquele número. */
function Kpi({ to, label, value, hint, tone = 'text-text' }) {
  return (
    <Link
      to={to}
      className="block bg-surface border border-border rounded-card p-3 transition-colors duration-micro hover:border-primary/40 active:scale-[0.99]"
    >
      <p className="text-caption text-text-secondary flex items-center justify-between">
        {label}
        <ChevronRightIcon className="w-3 h-3 text-text-secondary" />
      </p>
      <p className={`font-display text-h2 leading-tight ${tone}`}>{value}</p>
      {hint && <p className="text-caption text-text-secondary mt-0.5">{hint}</p>}
    </Link>
  );
}

/** Botão de atalho compacto: ícone e nome. */
function Shortcut({ to, icon: Icon, label }) {
  return (
    <Link
      to={to}
      className="flex flex-col items-center gap-1.5 bg-surface border border-border rounded-card px-2 py-3 text-center transition-all duration-micro hover:border-primary/40 active:scale-[0.97]"
    >
      <span className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center">
        <Icon className="w-4 h-4" />
      </span>
      <span className="text-caption font-semibold text-text leading-tight">{label}</span>
    </Link>
  );
}

function Section({ title, children }) {
  return (
    <section>
      <h2 className="text-caption text-text-secondary uppercase tracking-wide mb-2">{title}</h2>
      {children}
    </section>
  );
}

/** Visão geral do painel: o que precisa de atenção hoje, os números principais e atalhos para cada área. */
export function AdminOverview() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    adminApi
      .getOverview()
      .then((res) => setData(res.data))
      .catch((err) => setError(err?.status === 403 ? 'forbidden' : 'Não foi possível carregar a visão geral.'));
  }, []);

  // Papéis sem acesso à visão geral (ex.: jurídico) vão direto à sua área.
  if (error === 'forbidden') return <Navigate to="/admin/legal/documentos" replace />;
  if (error) return <p className="text-danger text-body">{error}</p>;
  if (!data) return <p className="text-text-secondary text-body">Carregando...</p>;

  const role = user?.role;
  const canMoney = role === 'admin_master' || role === 'admin_financeiro';
  const canPeople = role === 'admin_master' || role === 'admin_suporte';
  const firstName = user?.name?.split(' ')[0] || 'administrador';
  const today = new Date().toLocaleDateString('pt-MZ', { weekday: 'long', day: 'numeric', month: 'long' });
  const pend = data.pendingWithdrawals;

  return (
    <div className="space-y-6">
      <header>
        <p className="text-caption text-text-secondary capitalize">{today}</p>
        <h1 className="font-display text-h1 text-text">Olá, {firstName}</h1>
        <p className="text-body text-text-secondary">Aqui está o resumo da plataforma.</p>
      </header>

      {pend.count > 0 ? (
        <Link
          to="/admin/saques"
          className="flex items-center justify-between gap-3 bg-warning/10 border border-warning/40 rounded-card p-4 active:scale-[0.99]"
        >
          <span>
            <span className="block text-body font-semibold text-warning">
              {pend.count} {pend.count === 1 ? 'saque à espera' : 'saques à espera'}
            </span>
            <span className="block text-caption text-text-secondary">{mzn(pend.amountMzn)} por rever</span>
          </span>
          <span className="shrink-0 bg-warning text-background text-button font-semibold rounded-button px-3 py-2">
            Rever agora
          </span>
        </Link>
      ) : (
        <div className="flex items-center gap-3 bg-success/10 border border-success/30 rounded-card p-4">
          <span className="w-9 h-9 rounded-full bg-success/20 text-success flex items-center justify-center">
            <TrustShieldIcon className="w-5 h-5" />
          </span>
          <span>
            <span className="block text-body font-semibold text-success">Tudo em dia</span>
            <span className="block text-caption text-text-secondary">Nenhum saque à espera de revisão.</span>
          </span>
        </div>
      )}

      <Section title="Pessoas">
        <div className="grid grid-cols-2 gap-2">
          <Kpi to="/admin/usuarios" label="Utilizadores" value={data.users.total} tone="text-primary" />
          <Kpi to="/admin/usuarios" label="Novos (24 h)" value={data.users.new24h} hint={`${data.users.new7d} nos últimos 7 dias`} />
          <Kpi to="/admin/relatorios" label="Ativos (24 h)" value={data.activity.active24h} hint="responderam a quizzes" />
          <Kpi to="/admin/relatorios" label="Respostas (24 h)" value={data.activity.answers24h} />
        </div>
      </Section>

      <Section title="Dinheiro">
        <div className="grid grid-cols-2 gap-2">
          <Kpi to="/admin/relatorios" label="Ganho pelos utilizadores" value={mzn(data.money.creditedMzn)} tone="text-gold" hint="total creditado" />
          <Kpi to="/admin/saques" label="Já pago em saques" value={mzn(data.money.paidMzn)} tone="text-success" />
          <Kpi to="/admin/saques" label="Em saldos (a pagar)" value={mzn(data.money.owedToUsersMzn)} tone="text-warning" hint="o que a plataforma deve" />
        </div>
      </Section>

      <Section title="Atalhos">
        <div className="grid grid-cols-3 gap-2">
          {canMoney && <Shortcut to="/admin/saques" icon={WalletIcon} label="Saques" />}
          {canPeople && <Shortcut to="/admin/usuarios" icon={ProfileIcon} label="Utilizadores" />}
          {canPeople && <Shortcut to="/admin/conteudo/categorias" icon={QuizIcon} label="Perguntas" />}
          {canPeople && <Shortcut to="/admin/conteudo/missoes" icon={MissionsIcon} label="Missões" />}
          {canMoney && <Shortcut to="/admin/loja" icon={ShopIcon} label="Loja" />}
          <Shortcut to="/admin/notificacoes" icon={NotificationIcon} label="Notificações" />
          {canMoney && <Shortcut to="/admin/relatorios" icon={AchievementIcon} label="Relatórios" />}
          <Shortcut to="/admin/auditoria" icon={TrustShieldIcon} label="Auditoria" />
        </div>
      </Section>
    </div>
  );
}
