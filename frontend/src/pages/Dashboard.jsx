import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { gamificationApi } from '../api/profileApi';
import { missionsApi, notificationsApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { XpProgressBar } from '../components/XpProgressBar';
import { LivePlatformStats } from '../components/LivePlatformStats';
import { FireIcon, WalletIcon, XpIcon, ChevronRightIcon, NotificationIcon, MissionsIcon, PointsIcon } from '../icons';

/**
 * Painel Principal / "Centro de Comando" (Doc. Mestre Seção 19.2 e Seção 6).
 * Prioriza: Nível (XP), Ganhos Totais, Ofensiva atual, Missões Pendentes.
 */
export function Dashboard() {
  const { user } = useAuth();
  const [gamification, setGamification] = useState(null);
  const [missions, setMissions] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      try {
        const [gamResult, missionsResult, unreadResult] = await Promise.all([
          gamificationApi.me(),
          missionsApi.listMine(),
          notificationsApi.unreadCount(),
        ]);
        if (!mounted) return;
        setGamification(gamResult.data);
        setMissions(missionsResult.data.slice(0, 3));
        setUnreadCount(unreadResult.data.count);
      } finally {
        if (mounted) setLoading(false);
      }
    }
    load();
    return () => { mounted = false; };
  }, []);

  const firstName = user?.name?.split(' ')[0] || '';
  const xpPercent = gamification && gamification.xpStep
    ? Math.round((gamification.xpIntoCurrentLevel / gamification.xpStep) * 100)
    : 0;

  return (
    <div className="space-y-5 pb-4">
      <header className="flex items-center justify-between pt-2">
        <div>
          <p className="text-caption text-text-secondary">Olá,</p>
          <h1 className="font-display text-h1 text-text">{firstName || 'estudante'}!</h1>
        </div>
        <div className="flex items-center gap-2">
          <Link to="/notificacoes" className="relative w-11 h-11 flex items-center justify-center">
            <NotificationIcon className="w-6 h-6 text-text-secondary" hasUnread={unreadCount > 0} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-danger" />
            )}
          </Link>
          <div className="flex items-center gap-1 bg-warning/10 rounded-full px-3 py-2">
            <FireIcon className="w-5 h-5 text-warning" />
            <span className="font-display font-semibold text-warning">
              {gamification?.streak?.currentDays ?? 0}
            </span>
          </div>
        </div>
      </header>

      <div className="grid grid-cols-3 gap-2">
        <Card className="!p-3">
          <div className="flex items-center gap-1.5 mb-1">
            <WalletIcon className="w-4 h-4 text-gold shrink-0" />
            <span className="text-caption text-text-secondary">Saldo</span>
          </div>
          <p className="font-display text-h2 text-gold leading-tight">
            {(user?.walletBalanceMzn ?? 0).toFixed(2)}
          </p>
          <p className="text-caption text-text-secondary">MZN</p>
        </Card>

        <Card className="!p-3">
          <div className="flex items-center gap-1.5 mb-1">
            <XpIcon className="w-4 h-4 text-primary shrink-0" />
            <span className="text-caption text-text-secondary">Nível {gamification?.level ?? 1}</span>
          </div>
          <p className="font-display text-h2 text-primary leading-tight">{gamification?.xpTotal ?? 0}</p>
          <p className="text-caption text-text-secondary">XP</p>
        </Card>

        <Card className="!p-3">
          <div className="flex items-center gap-1.5 mb-1">
            <PointsIcon className="w-4 h-4 text-secondary shrink-0" />
            <span className="text-caption text-text-secondary">Pontos</span>
          </div>
          <p className="font-display text-h2 text-secondary leading-tight">
            {gamification?.pointsBalance ?? 0}
          </p>
          <p className="text-caption text-text-secondary">moeda soft</p>
        </Card>
      </div>

      {gamification && (
        <div>
          <div className="flex justify-between text-caption text-text-secondary mb-1">
            <span>Nível {gamification.level}</span>
            <span>{gamification.xpToNextLevel} XP para o próximo nível</span>
          </div>
          <XpProgressBar percent={xpPercent} />
        </div>
      )}

      <Card className="bg-gold/5 border-gold/20 text-center">
        <LivePlatformStats variant="compact" />
      </Card>

      {/* Anúncio Estratégico 1 — Banner Nativo (Seção 19.2). Placeholder até a
          integração real com AdSense/AdCash ser implementada. */}
      <div className="bg-border/40 rounded-card h-20 flex items-center justify-center text-caption text-text-secondary">
        Espaço de anúncio (Banner Nativo)
      </div>

      <div>
        <div className="flex items-center justify-between mb-2">
          <span className="flex items-center gap-1.5">
            <MissionsIcon
              className="w-5 h-5 text-primary"
              hasNew={missions.some((m) => m.status !== 'completed')}
            />
            <h2 className="font-display text-h2 text-text">Missões Diárias</h2>
          </span>
          <Link to="/missoes" className="text-caption text-primary font-semibold flex items-center">
            Ver todas <ChevronRightIcon className="w-4 h-4" />
          </Link>
        </div>

        {loading && <p className="text-caption text-text-secondary">Carregando missões...</p>}
        {!loading && missions.length === 0 && (
          <Card><p className="text-body text-text-secondary">Nenhuma missão disponível no momento.</p></Card>
        )}

        <div className="space-y-2">
          {missions.map((m) => (
            <Card key={m.userMissionId} status={m.status === 'completed' ? 'completed' : 'normal'}>
              <p className="text-body font-semibold text-text">{m.title}</p>
              <p className="text-caption text-text-secondary">
                {m.progress}/{m.target} concluído
              </p>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}
