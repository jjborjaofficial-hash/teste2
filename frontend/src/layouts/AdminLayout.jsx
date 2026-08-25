import { useEffect, useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { notificationsApi } from '../api/gameplayApi';
import { WalletIcon, ProfileIcon, NotificationIcon } from '../icons';

const ROLE_LABELS = {
  admin_master: 'Admin Master',
  admin_financeiro: 'Admin Financeiro',
  admin_suporte: 'Admin Suporte',
  admin_juridico: 'Admin Jurídico',
};

/**
 * Layout do Painel Admin. Deliberadamente diferente do AppLayout do usuário final
 * (sem BottomNav, sem Rodapé da Seção 18 — este painel não faz parte do Sitemap
 * da Seção 19, que é 100% voltado ao usuário final). Navegação simples em topo,
 * cada item só aparece se o papel do admin tiver acesso à área.
 */
export function AdminLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [unreadCount, setUnreadCount] = useState(0);

  const canSeeWithdrawals = user?.role === 'admin_master' || user?.role === 'admin_financeiro';
  const canSeeUsers = user?.role === 'admin_master' || user?.role === 'admin_suporte';
  const canSeeLegal = user?.role === 'admin_master' || user?.role === 'admin_juridico';
  const canSeeReports = user?.role === 'admin_master' || user?.role === 'admin_financeiro';

  useEffect(() => {
    let mounted = true;
    notificationsApi.unreadCount().then((res) => {
      if (mounted) setUnreadCount(res.data.count);
    });
    return () => { mounted = false; };
  }, []);

  async function handleLogout() {
    await logout();
    navigate('/entrar', { replace: true });
  }

  const linkClass = ({ isActive }) =>
    `px-3 py-2 rounded-button text-button transition-colors duration-micro ${
      isActive ? 'bg-primary/10 text-primary' : 'text-text-secondary hover:text-text'
    }`;

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-surface border-b border-border px-4 py-3 flex items-center justify-between sticky top-0 z-10">
        <div>
          <p className="font-display font-semibold text-text">Aprenda e Ganhe · Admin</p>
          <p className="text-caption text-text-secondary">{ROLE_LABELS[user?.role] || user?.role}</p>
        </div>
        <div className="flex items-center gap-3">
          <NavLink to="/admin/notificacoes" className="relative w-10 h-10 flex items-center justify-center">
            <NotificationIcon className="w-6 h-6 text-text-secondary" hasUnread={unreadCount > 0} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-danger" />
            )}
          </NavLink>
          <button onClick={handleLogout} className="text-caption text-danger font-semibold">
            Sair
          </button>
        </div>
      </header>

      <nav className="bg-surface border-b border-border px-4 flex gap-1 overflow-x-auto">
        {canSeeWithdrawals && (
          <NavLink to="/admin/saques" className={linkClass}>
            <span className="flex items-center gap-1"><WalletIcon className="w-4 h-4" /> Saques</span>
          </NavLink>
        )}
        {canSeeUsers && (
          <NavLink to="/admin/usuarios" className={linkClass}>
            <span className="flex items-center gap-1"><ProfileIcon className="w-4 h-4" /> Usuários</span>
          </NavLink>
        )}
        {canSeeUsers && (
          <NavLink to="/admin/conteudo/categorias" className={linkClass}>
            Categorias
          </NavLink>
        )}
        {canSeeUsers && (
          <NavLink to="/admin/conteudo/missoes" className={linkClass}>
            Missões
          </NavLink>
        )}
        <NavLink to="/admin/auditoria" className={linkClass}>
          Auditoria
        </NavLink>
        {canSeeReports && (
          <NavLink to="/admin/relatorios" className={linkClass}>
            Relatórios
          </NavLink>
        )}
        {canSeeReports && (
          <NavLink to="/admin/loja" className={linkClass}>
            Loja
          </NavLink>
        )}
        {canSeeLegal && (
          <>
            <NavLink to="/admin/legal/documentos" className={linkClass}>
              Documentos
            </NavLink>
            <NavLink to="/admin/legal/reclamacoes" className={linkClass}>
              Reclamações
            </NavLink>
            <NavLink to="/admin/legal/recursos" className={linkClass}>
              Recursos
            </NavLink>
          </>
        )}
      </nav>

      <main className="max-w-3xl mx-auto px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
