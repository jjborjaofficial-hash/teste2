import { useEffect, useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { notificationsApi } from '../api/gameplayApi';
import {
  NotificationIcon, HomeIcon, WalletIcon, ProfileIcon, QuizIcon, ShopIcon, MissionsIcon, AchievementIcon,
  TrustShieldIcon, BoostIcon, SettingsIcon, CloseIcon,
} from '../icons';
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
    { title: 'Início', items: [{ to: '/admin', label: 'Visão geral', icon: HomeIcon }] },
    {
      title: 'Dinheiro',
      items: [
        ...(canSeeWithdrawals ? [{ to: '/admin/saques', label: 'Saques', icon: WalletIcon }] : []),
        ...(canSeeReports ? [{ to: '/admin/relatorios', label: 'Relatórios', icon: AchievementIcon }] : []),
      ],
    },
    { title: 'Pessoas', items: canSeeUsers ? [{ to: '/admin/usuarios', label: 'Utilizadores', icon: ProfileIcon }] : [] },
    {
      title: 'Conteúdo',
      items: canSeeUsers
        ? [
            { to: '/admin/conteudo/categorias', label: 'Perguntas', icon: QuizIcon },
            { to: '/admin/conteudo/missoes', label: 'Missões', icon: MissionsIcon },
          ]
        : [],
    },
    {
      title: 'Economia',
      items: [
        ...(canSeeReports ? [{ to: '/admin/loja', label: 'Loja', icon: ShopIcon }] : []),
        ...(user?.role === 'admin_master' ? [{ to: '/admin/anuncios', label: 'Anúncios', icon: BoostIcon }] : []),
      ],
    },
    { title: 'Comunicação', items: [{ to: '/admin/notificacoes', label: 'Notificações', icon: NotificationIcon }] },
    {
      title: 'Jurídico e sistema',
      items: [
        ...(canSeeLegal
          ? [
              { to: '/admin/legal/documentos', label: 'Documentos', icon: TrustShieldIcon },
              { to: '/admin/legal/reclamacoes', label: 'Reclamações', icon: NotificationIcon },
              { to: '/admin/legal/recursos', label: 'Recursos', icon: BoostIcon },
            ]
          : []),
        { to: '/admin/auditoria', label: 'Auditoria', icon: SettingsIcon },
      ],
    },
  ];

  // Barra de baixo (6 botões): só mostra o que o papel permite; o último abre o menu completo.
  const bottomItems = [
    { to: '/admin', label: 'Início', icon: HomeIcon, end: true },
    ...(canSeeWithdrawals ? [{ to: '/admin/saques', label: 'Saques', icon: WalletIcon }] : []),
    ...(canSeeUsers ? [{ to: '/admin/usuarios', label: 'Pessoas', icon: ProfileIcon }] : []),
    ...(canSeeUsers ? [{ to: '/admin/conteudo/categorias', label: 'Conteúdo', icon: QuizIcon }] : []),
    ...(canSeeReports ? [{ to: '/admin/loja', label: 'Loja', icon: ShopIcon }] : []),
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
        <div className="fixed inset-0 z-30 flex items-end" role="dialog" aria-modal="true" aria-label="Menu do painel">
          <button
            aria-label="Fechar menu"
            onClick={() => setMenuOpen(false)}
            className="absolute inset-0 bg-black/60 animate-fade-in"
          />
          <div className="relative animate-sheet-up w-full max-w-3xl mx-auto bg-surface border-t border-border rounded-t-2xl px-4 pt-3 pb-24 max-h-[85vh] overflow-y-auto">
            <div className="w-10 h-1 rounded-full bg-border mx-auto mb-3" />
            <div className="flex items-center justify-between mb-3">
              <p className="font-display text-h2 text-text">Menu</p>
              <button onClick={() => setMenuOpen(false)} aria-label="Fechar" className="w-9 h-9 flex items-center justify-center text-text-secondary">
                <CloseIcon className="w-5 h-5" />
              </button>
            </div>
            <div className="space-y-4">
              {groups.map((g) =>
                g.items.length === 0 ? null : (
                  <div key={g.title}>
                    <p className="text-caption text-text-secondary uppercase tracking-wide mb-2">{g.title}</p>
                    <div className="grid grid-cols-3 gap-2">
                      {g.items.map((it) => (
                        <NavLink
                          key={it.to}
                          to={it.to}
                          end={it.to === '/admin'}
                          onClick={() => setMenuOpen(false)}
                          className={({ isActive }) =>
                            `flex flex-col items-center gap-1.5 rounded-card border px-2 py-3 text-center transition-all duration-micro active:scale-[0.97] ${
                              isActive ? 'border-primary bg-primary/10 text-primary' : 'border-border bg-background text-text'
                            }`
                          }
                        >
                          <it.icon className="w-6 h-6" />
                          <span className="text-caption font-semibold leading-tight">{it.label}</span>
                        </NavLink>
                      ))}
                    </div>
                  </div>
                )
              )}
            </div>
          </div>
        </div>
      )}

      <main className="max-w-3xl mx-auto px-4 py-6 pb-28">
        <Outlet />
      </main>

      <nav className="fixed bottom-0 inset-x-0 z-20 bg-surface border-t border-border">
        <div className="max-w-3xl mx-auto flex">
          {bottomItems.map((it) => (
            <NavLink
              key={it.to}
              to={it.to}
              end={it.end}
              onClick={() => setMenuOpen(false)}
              className={({ isActive }) =>
                `flex-1 flex flex-col items-center gap-0.5 py-2 text-caption transition-colors duration-micro ${
                  isActive ? 'text-primary' : 'text-text-secondary'
                }`
              }
            >
              <it.icon className="w-6 h-6" />
              {it.label}
            </NavLink>
          ))}
          <button
            onClick={() => setMenuOpen((o) => !o)}
            className={`flex-1 flex flex-col items-center gap-0.5 py-2 text-caption ${menuOpen ? 'text-primary' : 'text-text-secondary'}`}
          >
            <span className="w-6 h-6 flex items-center justify-center text-h2 leading-none">☰</span>
            Menu
          </button>
        </div>
      </nav>
    </div>
  );
}
