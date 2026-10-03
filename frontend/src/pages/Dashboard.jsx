import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { gamificationApi } from '../api/profileApi';
import { missionsApi, notificationsApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { PrimaryButton } from '../components/Button';
import { XpProgressBar } from '../components/XpProgressBar';
import { SocialProofActivity } from '../components/SocialProofActivity';
import { DisplayAds } from '../ads';
import { StreakBrokenModal } from '../components/StreakBrokenModal';
import { WelcomeBonusCard } from '../components/WelcomeBonusCard';
import { FireIcon, WalletIcon, XpIcon, ChevronRightIcon, NotificationIcon, MissionsIcon, PointsIcon } from '../icons';

/**
 * Painel Principal / "Centro de Comando" (Doc. Mestre Seção 19.2 e Seção 6).
 * Prioriza: Nível (XP), Ganhos Totais, Ofensiva atual, Missões Pendentes.
 */
export function Dashboard() {
  const { user, refreshProfile } = useAuth();
  const navigate = useNavigate();
  const [gamification, setGamification] = useState(null);
  const [missions, setMissions] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [showStreakBroken, setShowStreakBroken] = useState(false);
  const [welcomeBonus, setWelcomeBonus] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    async function load() {
      try {
        const [gamResult, missionsResult, unreadResult, welcomeResult] = await Promise.all([
          gamificationApi.me(),
          missionsApi.listMine(),
          notificationsApi.unreadCount(),
          gamificationApi.welcomeBonus().catch(() => null),
        ]);
        if (!mounted) return;
        setGamification(gamResult.data);
        setWelcomeBonus(welcomeResult ? welcomeResult.data : null);
        // Missões já resgatadas hoje não aparecem no atalho do painel.
        setMissions(missionsResult.data.filter((m) => m.status !== 'reward_claimed').slice(0, 3));

        // Animação de ofensiva quebrada: uma única vez por quebra.
        const brokenAt = gamResult.data?.streak?.brokenAt;
        if (brokenAt) {
          let seen = null;
          try { seen = localStorage.getItem('streakBrokenSeen'); } catch { /* storage indisponível */ }
          if (seen !== String(brokenAt)) setShowStreakBroken(true);
        }
        setUnreadCount(unreadResult.data.count);
      } finally {
        if (mounted) setLoading(false);
      }
    }
    load();
    return () => { mounted = false; };
  }, []);

  async function reloadAfterWelcomeClaim() {
    const res = await gamificationApi.welcomeBonus();
    setWelcomeBonus(res.data);
    await refreshProfile();
  }

  function closeStreakBroken() {
    try { localStorage.setItem('streakBrokenSeen', String(gamification?.streak?.brokenAt)); } catch { /* storage indisponível */ }
    setShowStreakBroken(false);
  }

  const firstName = user?.name?.split(' ')[0] || '';
  const xpPercent = gamification && gamification.xpStep
    ? Math.round((gamification.xpIntoCurrentLevel / gamification.xpStep) * 100)
    : 0;

  return (
    <div className="space-y-5 pb-4">
      {showStreakBroken && (
        <StreakBrokenModal days={gamification?.streak?.brokenStreakDays ?? 0} onClose={closeStreakBroken} />
      )}
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

      <WelcomeBonusCard bonus={welcomeBonus} onClaimed={reloadAfterWelcomeClaim} />

      {gamification && (
        <div>
          <div className="flex justify-between text-caption text-text-secondary mb-1">
            <span>Nível {gamification.level}</span>
            <span>{gamification.xpToNextLevel} XP para o próximo nível</span>
          </div>
          <XpProgressBar percent={xpPercent} />
        </div>
      )}

      {/* FE-002: a ação principal do painel (estudar) precisa de um botão visível. */}
      <PrimaryButton onClick={() => navigate('/hub-estudos')} className="w-full">
        Estudar agora
      </PrimaryButton>

      <Card className="bg-gold/5 border-gold/20 text-center">
        <SocialProofActivity variant="compact" />
      </Card>

      {/* Anúncio Estratégico 1 — Banner Nativo (Seção 19.2). Zona real:
          300x100, Zone ID via VITE_ADCASH_ZONE_DASHBOARD. */}
      <DisplayAds location="dashboard" className="my-1" />

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
