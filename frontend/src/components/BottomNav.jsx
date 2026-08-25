import { useEffect, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { HomeIcon, QuizIcon, MissionsIcon, WalletIcon, RankingIcon, ProfileIcon } from '../icons';
import { missionsApi } from '../api/gameplayApi';

const items = [
  { to: '/dashboard', label: 'Início', Icon: HomeIcon },
  { to: '/hub-estudos', label: 'Estudar', Icon: QuizIcon },
  { to: '/missoes', label: 'Missões', Icon: MissionsIcon, badgeAware: true },
  { to: '/carteira', label: 'Carteira', Icon: WalletIcon },
  { to: '/ranking', label: 'Ranking', Icon: RankingIcon },
  { to: '/perfil', label: 'Perfil', Icon: ProfileIcon },
];

/**
 * Bottom Navigation (Doc. Mestre Seção 19: "navegação principal será feita por uma
 * barra fixa na parte inferior da tela"). Este componente é omitido explicitamente
 * na Tela de Quiz Ativo (Seção 19.4: "foco absoluto, o usuário não pode se distrair").
 *
 * A aba "Missões" acende o indicador de "nova missão" (Seção 13.5: "Pulso leve
 * quando há missão nova") sempre que existir recompensa pronta para resgatar —
 * é a forma de o usuário descobrir que tem dinheiro/XP esperando, mesmo sem
 * abrir o Dashboard primeiro.
 */
export function BottomNav() {
  const [hasClaimable, setHasClaimable] = useState(false);

  useEffect(() => {
    missionsApi.listMine()
      .then((res) => setHasClaimable(res.data.some((m) => m.status === 'completed')))
      .catch(() => setHasClaimable(false));
  }, []);

  return (
    <nav
      className="fixed bottom-0 left-0 right-0 z-40 bg-surface border-t border-border
                 flex justify-around items-center h-16 px-1 pb-[env(safe-area-inset-bottom)]"
      aria-label="Navegação principal"
    >
      {items.map(({ to, label, Icon, badgeAware }) => (
        <NavLink
          key={to}
          to={to}
          className={({ isActive }) =>
            `flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors duration-micro ${
              isActive ? 'text-primary' : 'text-text-secondary'
            }`
          }
        >
          <Icon className="w-6 h-6" {...(badgeAware ? { hasNew: hasClaimable } : {})} />
          <span className="text-caption">{label}</span>
        </NavLink>
      ))}
    </nav>
  );
}
