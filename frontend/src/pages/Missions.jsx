import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { missionsApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { PrimaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { ApiError } from '../api/client';
import { MissionsIcon, XpIcon, PointsIcon, WalletIcon, CheckIcon } from '../icons';

/**
 * Tela de Missões (Doc. Mestre Seção 5 e 8 | FAQ: "resgate sua recompensa na
 * aba de Missões"). Antes desta tela, `POST /missions/:id/claim` existia no
 * backend mas nunca era chamado pelo frontend — o usuário completava uma
 * missão e não tinha como coletar a recompensa. Esta tela fecha esse ciclo.
 */

const STATUS_ORDER = { completed: 0, in_progress: 1, reward_claimed: 2, expired: 3 };

const UNIT_BY_ACTIVITY = {
  quiz_count: 'quizzes',
  time_active_minutes: 'min',
  category_exploration: 'categorias',
  login: '',
};

export function formatMzn(value) {
  return `${Number(value).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

function RewardChips({ rewards }) {
  const chips = [];
  if (rewards.xp > 0) chips.push({ key: 'xp', icon: XpIcon, label: `${rewards.xp} XP` });
  if (rewards.points > 0) chips.push({ key: 'points', icon: PointsIcon, label: `${rewards.points} Pontos` });
  if (rewards.moneyMzn > 0) chips.push({ key: 'money', icon: WalletIcon, label: formatMzn(rewards.moneyMzn) });

  if (chips.length === 0) return null;

  return (
    <div className="flex flex-wrap gap-2 mt-2">
      {chips.map(({ key, icon: Icon, label }) => (
        <span
          key={key}
          className="flex items-center gap-1 bg-gold/10 text-gold text-caption font-semibold px-2.5 py-1 rounded-full"
        >
          <Icon className="w-3.5 h-3.5" />
          {label}
        </span>
      ))}
    </div>
  );
}

/**
 * Botão de ação das missões EM ANDAMENTO (FE-001). Só apresentação: não muda regra
 * nem valores. Missão de login é automática (sem botão). Missão de tempo é medida
 * pelo servidor (heartbeat), então o botão só leva ao Hub de Estudos.
 */
function actionFor(mission) {
  if (mission.activityType === 'login') return null;
  if (mission.activityType === 'time_active_minutes') return { label: 'Estudar agora' };
  return { label: mission.progress > 0 ? 'Continuar' : 'Começar missão' };
}

function MissionCard({ mission, onClaimed }) {
  const { showToast } = useToast();
  const navigate = useNavigate();
  const [claiming, setClaiming] = useState(false);

  const isCompleted = mission.status === 'completed';
  const isClaimed = mission.status === 'reward_claimed';
  const isExpired = mission.status === 'expired';
  const progressPercent = Math.min(100, Math.round((mission.progress / mission.target) * 100));
  const inProgress = mission.status === 'in_progress';
  const action = inProgress ? actionFor(mission) : null;
  const remaining = Math.max(0, mission.target - mission.progress);
  const unit = UNIT_BY_ACTIVITY[mission.activityType] ?? '';

  async function handleClaim() {
    setClaiming(true);
    try {
      const res = await missionsApi.claim(mission.userMissionId);
      const credited = res.data.rewardsGranted?.moneyMzn ?? 0;
      showToast(
        credited > 0
          ? `Recompensa resgatada: +${formatMzn(credited)}`
          : `Recompensa resgatada: ${res.data.title}!`,
        'success'
      );
      onClaimed?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível resgatar a recompensa.', 'error');
    } finally {
      setClaiming(false);
    }
  }

  return (
    <Card status={isCompleted || isClaimed ? 'completed' : 'normal'} className={isExpired ? 'opacity-60' : ''}>
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1">
          <p className="text-body font-semibold text-text">{mission.title}</p>
          {mission.description && (
            <p className="text-caption text-text-secondary mt-0.5">{mission.description}</p>
          )}
        </div>
        {isClaimed && <CheckIcon className="w-5 h-5 text-success shrink-0" animated />}
      </div>

      {!isClaimed && !isExpired && (
        <div className="mt-3">
          <div className="flex justify-between text-caption text-text-secondary mb-1">
            <span>{mission.progress}/{mission.target} {UNIT_BY_ACTIVITY[mission.activityType] ?? ''}</span>
            <span>{progressPercent}%</span>
          </div>
          <div className="h-2 bg-border rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-gold to-warning transition-all duration-500 ease-out"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
        </div>
      )}

      <RewardChips rewards={mission.rewards} />

      {inProgress && remaining > 0 && unit && (
        <p className="text-caption text-text-secondary mt-2">Faltam {remaining} {unit}</p>
      )}

      {inProgress && action && (
        <PrimaryButton onClick={() => navigate('/hub-estudos')} className="w-full mt-3">
          {action.label}
        </PrimaryButton>
      )}

      {isCompleted && (
        <PrimaryButton onClick={handleClaim} loading={claiming} className="w-full mt-3 shadow-md">
          Resgatar recompensa
        </PrimaryButton>
      )}

      {isClaimed && (
        <p className="text-caption text-success font-semibold mt-2">Concluída · recompensa já resgatada</p>
      )}

      {isExpired && (
        <p className="text-caption text-text-secondary mt-2">Esta missão expirou.</p>
      )}
    </Card>
  );
}

export function Missions() {
  const [missions, setMissions] = useState(null);
  const [error, setError] = useState(false);

  function load() {
    missionsApi.listMine()
      .then((res) => {
        const sorted = [...res.data].sort(
          (a, b) => (STATUS_ORDER[a.status] ?? 9) - (STATUS_ORDER[b.status] ?? 9)
        );
        setMissions(sorted);
      })
      .catch(() => setError(true));
  }

  useEffect(load, []);

  const claimableCount = missions?.filter((m) => m.status === 'completed').length ?? 0;

  // Resumo do dia: valores somados a partir do que o servidor devolve (nada inventado no cliente).
  const daily = (missions ?? []).filter((m) => m.type === 'daily');
  const dailyPotential = daily.reduce((sum, m) => sum + m.rewards.moneyMzn, 0);
  const dailyClaimed = daily
    .filter((m) => m.status === 'reward_claimed')
    .reduce((sum, m) => sum + m.rewards.moneyMzn, 0);
  const dailyPercent = dailyPotential > 0 ? Math.min(100, Math.round((dailyClaimed / dailyPotential) * 100)) : 0;

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <MissionsIcon className="w-6 h-6 text-primary" hasNew={claimableCount > 0} />
        <h1 className="font-display text-h1 text-text">Missões</h1>
      </header>

      {dailyPotential > 0 && (
        <Card>
          <div className="flex justify-between items-baseline">
            <span className="text-caption text-text-secondary">Ganhos de hoje</span>
            <span className="font-display text-gold font-semibold">
              {formatMzn(dailyClaimed)} <span className="text-caption text-text-secondary">/ {formatMzn(dailyPotential)}</span>
            </span>
          </div>
          <div className="h-1 bg-border rounded-full overflow-hidden mt-2">
            <div className="h-full bg-gradient-to-r from-gold to-warning transition-all duration-500" style={{ width: `${dailyPercent}%` }} />
          </div>
        </Card>
      )}

      {claimableCount > 0 && (
        <Card className="bg-gold/5 border-gold/20">
          <p className="text-body text-gold font-semibold">
            Você tem {claimableCount} recompensa{claimableCount > 1 ? 's' : ''} esperando para ser resgatada{claimableCount > 1 ? 's' : ''}!
          </p>
        </Card>
      )}

      {error && <p className="text-danger text-body">Não foi possível carregar suas missões agora.</p>}
      {!error && missions === null && <p className="text-caption text-text-secondary">Carregando missões...</p>}
      {missions?.length === 0 && (
        <Card><p className="text-body text-text-secondary">Nenhuma missão disponível no momento.</p></Card>
      )}

      <div className="space-y-3">
        {missions?.map((m) => (
          <MissionCard key={m.userMissionId} mission={m} onClaimed={load} />
        ))}
      </div>

      <Link to="/hub-estudos" className="block text-center text-caption text-primary font-semibold pt-2">
        Ir para o Hub de Estudos →
      </Link>
    </div>
  );
}
