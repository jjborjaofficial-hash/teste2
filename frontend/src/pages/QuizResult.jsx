import { useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { RewardBadge } from '../components/RewardBadge';
import { CheckIcon, CloseDrawIcon, FireIcon, XpIcon, WalletIcon, PointsIcon, AchievementIcon } from '../icons';
import { InterstitialAds } from '../ads';

/**
 * Tela de Resultados (Doc. Mestre Seção 19.5). "Momento de maior pico de dopamina."
 * Inclui o Anúncio Estratégico 3 (Intersticial/Tela Cheia) — "ponto de maior
 * monetização" — exibido antes de liberar os botões de continuar, exatamente
 * como especificado: o usuário acabou de ganhar uma recompensa, então a
 * tolerância para o anúncio é alta.
 */
const DIFFICULTY_LABEL = { easy: 'fácil', medium: 'médio', hard: 'difícil' };

export function QuizResult() {
  const { categoryId } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const { result, message } = location.state || {};
  // O progresso da rodada e o resumo final vêm do servidor (resposta de /quiz/answers).
  const round = result?.round;
  const summary = result?.roundSummary;
  const roundFinished = Boolean(round?.finished && summary);

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
        {/* InterstitialAds controla a própria UI de tela cheia do Adcash por
            cima disto quando um anúncio real está configurado e disponível.
            A tela abaixo (com o próprio cronômetro de segurança) é a rede de
            proteção: garante que o usuário NUNCA fica preso esperando,
            mesmo se o anúncio falhar, demorar, ou não houver Zone ID
            configurado ainda — a lógica de dismissal aqui é independente do
            que o Adcash faz. */}
        <InterstitialAds onDone={() => {}} />
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

          {/* Só aparece quando a ofensiva realmente aumentou (1ª resposta correta do dia);
              nas respostas seguintes do mesmo dia não se repete. */}
          {result.streak && result.streakIncreasedToday && (
            <div className="flex items-center justify-between">
              <span className="text-body text-text-secondary">Ofensiva</span>
              <span className="flex items-center gap-1 font-display font-semibold text-warning">
                <FireIcon className="w-4 h-4" /> {result.streak.currentStreakDays} dias
                <span className="ml-1 text-caption text-success">+1</span>
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

      {roundFinished && (
        <div className="bg-surface border border-border rounded-card p-5 space-y-3">
          <p className="font-display font-semibold text-text text-center">Rodada concluída</p>
          <div className="grid grid-cols-3 gap-2 text-center">
            <div>
              <p className="font-display font-semibold text-text">{summary.total}</p>
              <p className="text-caption text-text-secondary">perguntas</p>
            </div>
            <div>
              <p className="font-display font-semibold text-success">{summary.correct}</p>
              <p className="text-caption text-text-secondary">acertos</p>
            </div>
            <div>
              <p className="font-display font-semibold text-danger">{summary.wrong}</p>
              <p className="text-caption text-text-secondary">erros</p>
            </div>
          </div>
          <p className="text-body text-text-secondary text-center">
            {summary.accuracyPercent}% de aproveitamento
            {summary.xpTotal > 0 ? ` · +${summary.xpTotal} XP` : ''}
          </p>
          {summary.bestDifficulty && (
            <p className="text-caption text-text-secondary text-center">
              Melhor desempenho: perguntas de nível {DIFFICULTY_LABEL[summary.bestDifficulty]}.
            </p>
          )}
          {summary.reviewStatements.length > 0 && (
            <div className="border-t border-border pt-3 space-y-1">
              <p className="text-caption font-semibold text-text">Vale a pena rever</p>
              <ul className="list-disc pl-5 space-y-1">
                {summary.reviewStatements.slice(0, 3).map((statement) => (
                  <li key={statement} className="text-caption text-text-secondary">{statement}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {!roundFinished && round && (
        <p className="text-caption text-text-secondary text-center">
          {round.answered}/{round.total} respondidas
        </p>
      )}

      {roundFinished ? (
        // Exatamente 3 caminhos; nenhum inicia uma nova rodada sozinho. A nova rodada só
        // começa depois de o utilizador escolher uma categoria.
        <div className="flex flex-col gap-3 pt-2">
          <PrimaryButton onClick={() => navigate('/dashboard')}>Painel inicial</PrimaryButton>
          <SecondaryButton onClick={() => navigate('/hub-estudos', { replace: true })}>
            Escolher novamente uma categoria
          </SecondaryButton>
          <SecondaryButton onClick={() => navigate('/missoes')}>Ver missões em andamento</SecondaryButton>
        </div>
      ) : (
        <div className="flex gap-3 pt-2">
          <SecondaryButton onClick={() => navigate('/dashboard')} className="flex-1">
            Painel
          </SecondaryButton>
          <PrimaryButton
            onClick={() => navigate(`/quiz/${categoryId}`, { replace: true })}
            className="flex-1"
          >
            Próxima pergunta
          </PrimaryButton>
        </div>
      )}
    </div>
  );
}
