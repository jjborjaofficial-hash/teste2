import { useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { RewardBadge } from '../components/RewardBadge';
import { CheckIcon, CloseDrawIcon, FireIcon, XpIcon, WalletIcon, PointsIcon, AchievementIcon } from '../icons';

/**
 * Tela de Resultados (Doc. Mestre Seção 19.5). "Momento de maior pico de dopamina."
 * Inclui o Anúncio Estratégico 3 (Intersticial/Tela Cheia) — "ponto de maior
 * monetização" — exibido antes de liberar os botões de continuar, exatamente
 * como especificado: o usuário acabou de ganhar uma recompensa, então a
 * tolerância para o anúncio é alta.
 */
export function QuizResult() {
  const { categoryId } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const { result, message } = location.state || {};

  const [showAd, setShowAd] = useState(true);
  const [adSecondsLeft, setAdSecondsLeft] = useState(5);

  useEffect(() => {
    if (!result) return undefined;
    const interval = setInterval(() => {
      setAdSecondsLeft((s) => {
        if (s <= 1) {
          clearInterval(interval);
          setShowAd(false);
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [result]);

  useEffect(() => {
    if (!result) {
      navigate('/hub-estudos', { replace: true });
    }
  }, [result, navigate]);

  if (!result) {
    return null;
  }

  if (showAd) {
    return (
      <div className="min-h-screen bg-text flex flex-col items-center justify-center text-white px-6">
        <p className="text-caption text-white/60 mb-2">Publicidade</p>
        <div className="bg-white/10 rounded-card w-full max-w-sm h-64 flex items-center justify-center mb-4">
          <p className="text-body text-white/70">Espaço de anúncio (Intersticial)</p>
        </div>
        <p className="text-caption text-white/60">
          {adSecondsLeft > 0 ? `Continuar em ${adSecondsLeft}s` : 'Você já pode continuar'}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5 pt-6 pb-4">
      <div className="text-center">
        <div
          className={`w-16 h-16 rounded-full mx-auto mb-4 flex items-center justify-center ${
            result.isCorrect ? 'bg-success/10' : 'bg-danger/10'
          }`}
        >
          {result.isCorrect ? (
            <CheckIcon className="w-8 h-8 text-success" animated />
          ) : (
            <CloseDrawIcon className="w-8 h-8 text-danger" animated />
          )}
        </div>
        <h1 className="font-display text-h1 text-text mb-1">
          {result.isCorrect ? 'Incrível! Você dominou este assunto.' : message}
        </h1>
        {result.timeExpired && (
          <p className="text-caption text-text-secondary">O tempo esgotou desta vez.</p>
        )}
      </div>

      {result.isCorrect && (
        <div className="bg-surface border border-border rounded-card p-5 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-body text-text-secondary">XP ganho</span>
            <span className="flex items-center gap-1.5">
              <XpIcon className="w-4 h-4 text-gold" pulse={!result.leveledUp} levelUp={result.leveledUp} />
              <RewardBadge isNew>+{result.xpAwarded} XP</RewardBadge>
            </span>
          </div>

          {result.pointsAwarded > 0 && (
            <div className="flex items-center justify-between">
              <span className="text-body text-text-secondary">Pontos ganhos</span>
              <span className="flex items-center gap-1.5">
                <PointsIcon className="w-4 h-4 text-secondary" pulse />
                <RewardBadge isNew>+{result.pointsAwarded} Pontos</RewardBadge>
              </span>
            </div>
          )}

          {result.pointsCappedByDailyLimit && (
            <p className="text-caption text-warning">
              Você atingiu o teto diário de Pontos — volte amanhã para ganhar mais.
            </p>
          )}

          {result.newLevel && (
            <div className="flex items-center justify-between">
              <span className="text-body text-text-secondary">Nível atual</span>
              <span className="font-display font-semibold text-primary">
                {result.newLevel}
                {result.leveledUp && (
                  <span className="ml-1 text-caption text-success">Subiu de nível!</span>
                )}
              </span>
            </div>
          )}

          {result.streak && (
            <div className="flex items-center justify-between">
              <span className="text-body text-text-secondary">Ofensiva</span>
              <span className="flex items-center gap-1 font-display font-semibold text-warning">
                <FireIcon className="w-4 h-4" /> {result.streak.currentStreakDays} dias
              </span>
            </div>
          )}

          {result.missionsUpdated > 0 && (
            <p className="text-caption text-success">
              {result.missionsUpdated} missão(ões) atualizada(s) — confira no Painel.
            </p>
          )}
        </div>
      )}

      {result.streakMilestoneReached && (
        <div className="bg-gold/10 border border-gold/30 rounded-card p-4 text-center space-y-2">
          <div className="flex justify-center">
            <AchievementIcon className="w-12 h-12 text-gold" isNew />
          </div>
          <p className="text-body font-semibold text-gold">
            Marco de {result.streakMilestoneReached.days} dias alcançado!
          </p>
          <div className="flex justify-center gap-4">
            {result.streakMilestoneReached.pointsGranted > 0 && (
              <p className="flex items-center gap-1.5 text-caption text-secondary">
                <PointsIcon className="w-4 h-4" pulse />
                +{result.streakMilestoneReached.pointsGranted} Pontos
              </p>
            )}
            {result.streakMilestoneReached.moneyGrantedMzn > 0 && (
              <p className="flex items-center gap-1.5 text-caption text-gold">
                <WalletIcon className="w-4 h-4" impulse />
                +{result.streakMilestoneReached.moneyGrantedMzn} MZN
              </p>
            )}
          </div>
        </div>
      )}

      <div className="flex gap-3 pt-2">
        <SecondaryButton onClick={() => navigate('/dashboard')} className="flex-1">
          Painel
        </SecondaryButton>
        <PrimaryButton onClick={() => navigate(`/quiz/${categoryId}`, { replace: true })} className="flex-1">
          Tentar outra
        </PrimaryButton>
      </div>
    </div>
  );
}
