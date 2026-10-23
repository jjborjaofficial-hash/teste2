import { useEffect, useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { notificationsApi } from '../api/gameplayApi';
import { NotificationIcon } from '../icons';
import { lockAdmin } from '../lib/adminUnlock';

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
  const { user } = useAuth();
  const navigate = useNavigate();
  const [unreadCount, setUnreadCount] = useState(0);
  const [menuOpen, setMenuOpen] = useState(false);

  const canSeeWithdrawals = user?.role === 'admin_master' || user?.role === 'admin_financeiro';
  const canSeeUsers = user?.role === 'admin_master' || user?.role === 'admin_suporte';
  const canSeeLegal = user?.role === 'admin_master' || user?.role === 'admin_juridico';
  const canSeeReports = user?.role === 'admin_master' || user?.role === 'admin_financeiro';

  const groups = [
    { title: 'Início', items: [{ to: '/admin', label: 'Visão geral' }] },
    {
      title: 'Dinheiro',
      items: [
        ...(canSeeWithdrawals ? [{ to: '/admin/saques', label: 'Saques' }] : []),
        ...(canSeeReports ? [{ to: '/admin/relatorios', label: 'Relatórios diários' }] : []),
      ],
    },
    { title: 'Pessoas', items: canSeeUsers ? [{ to: '/admin/usuarios', label: 'Utilizadores' }] : [] },
    {
      title: 'Conteúdo',
      items: canSeeUsers
        ? [
            { to: '/admin/conteudo/categorias', label: 'Categorias e perguntas' },
            { to: '/admin/conteudo/missoes', label: 'Missões' },
          ]
        : [],
    },
    { title: 'Economia', items: canSeeReports ? [{ to: '/admin/loja', label: 'Loja' }] : [] },
    { title: 'Comunicação', items: [{ to: '/admin/notificacoes', label: 'Notificações' }] },
    {
      title: 'Jurídico e sistema',
      items: [
        ...(canSeeLegal
          ? [
              { to: '/admin/legal/documentos', label: 'Documentos' },
              { to: '/admin/legal/reclamacoes', label: 'Reclamações' },
              { to: '/admin/legal/recursos', label: 'Recursos' },
            ]
          : []),
        { to: '/admin/auditoria', label: 'Auditoria' },
      ],
    },
  ];

  useEffect(() => {
    let mounted = true;
    notificationsApi.unreadCount().then((res) => {
      if (mounted) setUnreadCount(res.data.count);
    });
    return () => { mounted = false; };
  }, []);

  // Fecha só o painel (volta ao Perfil, na conta normal); sair da conta faz-se no Perfil.
  function handleExitAdmin() {
    lockAdmin();
    navigate('/perfil', { replace: true });
  }

  const linkClass = ({ isActive }) =>
    `px-3 py-2 rounded-button text-button transition-colors duration-micro ${
      isActive ? 'bg-primary/10 text-primary' : 'text-text-secondary hover:text-text'
    }`;

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-surface border-b border-border px-4 py-3 flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <button
            onClick={() => setMenuOpen((o) => !o)}
            aria-label="Abrir menu"
            aria-expanded={menuOpen}
            className="w-10 h-10 flex items-center justify-center rounded-button border border-border text-text text-h2"
          >
            {menuOpen ? '✕' : '☰'}
          </button>
          <div>
            <p className="font-display font-semibold text-text">Aprenda e Ganhe · Admin</p>
            <p className="text-caption text-text-secondary">{ROLE_LABELS[user?.role] || user?.role}</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <NavLink to="/admin/notificacoes" className="relative w-10 h-10 flex items-center justify-center">
            <NotificationIcon className="w-6 h-6 text-text-secondary" hasUnread={unreadCount > 0} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-danger" />
            )}
          </NavLink>
          <button onClick={handleExitAdmin} className="text-caption text-primary font-semibold">
            Sair do painel
          </button>
        </div>
      </header>

      {menuOpen && (
        <nav className="bg-surface border-b border-border px-4 py-3 space-y-3">
          {groups.map((g) =>
            g.items.length === 0 ? null : (
              <div key={g.title}>
                <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">{g.title}</p>
                <div className="flex flex-wrap gap-1">
                  {g.items.map((it) => (
                    <NavLink key={it.to} to={it.to} end={it.to === '/admin'} className={linkClass} onClick={() => setMenuOpen(false)}>
                      {it.label}
                    </NavLink>
                  ))}
                </div>
              </div>
            )
          )}
        </nav>
      )}

      <main className="max-w-3xl mx-auto px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
