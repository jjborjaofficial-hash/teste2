import { useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { RewardBadge } from '../components/RewardBadge';
import { CheckIcon, CloseDrawIcon, FireIcon, XpIcon, WalletIcon, PointsIcon, AchievementIcon } from '../icons';
import { InterstitialAds } from '../ads';

/**
 * Tela de Resultados (Doc. Mestre Seção 19.5). "Momento de maior pico de dopamina."
 *
 * Primeiro vem o FEEDBACK PEDAGÓGICO (resultado, resposta correta e explicação): o quiz
 * ensina, não só corrige. O Anúncio Estratégico 3 (Intersticial/Tela Cheia) continua
 * a existir, mas passou a aparecer ao AVANÇAR (depois de o utilizador ter lido a
 * explicação), em vez de tapar o ecrã de resultado.
 */
export function QuizResult() {
  const { categoryId } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const { result, message, question } = location.state || {};
  // Progresso da rodada calculado e guardado pelo servidor (não pelo navegador).
  const round = result?.round || null;
  const roundFinished = Boolean(round?.completed);

  // Destino pendente: ao tocar num botão, o intersticial aparece e só depois navega.
  const [pendingNav, setPendingNav] = useState(null);
  const [adSecondsLeft, setAdSecondsLeft] = useState(5);

  useEffect(() => {
    if (!pendingNav) return undefined;
    setAdSecondsLeft(5);
    const interval = setInterval(() => {
      setAdSecondsLeft((s) => {
        if (s <= 1) {
          clearInterval(interval);
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [pendingNav]);

  useEffect(() => {
    if (!result) {
      navigate('/hub-estudos', { replace: true });
    }
  }, [result, navigate]);

  if (!result) {
    return null;
  }

  function goWithAd(to, options) {
    setPendingNav({ to, options });
  }

  if (pendingNav) {
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
        {adSecondsLeft > 0 ? (
          <p className="text-caption text-white/60">Continuar em {adSecondsLeft}s</p>
        ) : (
          <PrimaryButton onClick={() => navigate(pendingNav.to, pendingNav.options)}>Continuar</PrimaryButton>
        )}
      </div>
    );
  }

  const chosenLabel = question?.alternatives?.find((a) => a.id === result.chosenAlternativeId)?.label;
  const correctLabel = result.correctAlternative?.label;

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
          {result.isCorrect ? 'Correto!' : message || 'Resposta incorreta.'}
        </h1>
        {result.isCorrect && (
          <p className="text-caption text-text-secondary">Você identificou a resposta certa.</p>
        )}
        {result.timeExpired && (
          <p className="text-caption text-text-secondary">O tempo esgotou desta vez.</p>
        )}
        {!result.isCorrect && (
          <p className="text-caption text-text-secondary">
            Errar faz parte de aprender. Veja a resposta e a explicação abaixo.
          </p>
        )}
      </div>

      {/* Feedback pedagógico: só aparece quando o servidor devolveu a resposta correta. */}
      {correctLabel && (
        <div className="bg-surface border border-border rounded-card p-5 space-y-4">
          {question?.statement && (
            <p className="text-caption text-text-secondary">{question.statement}</p>
          )}

          {!result.isCorrect && !result.timeExpired && chosenLabel && (
            <div>
              <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">Você escolheu</p>
              <p className="text-body text-text">{chosenLabel}</p>
            </div>
          )}

          <div>
            <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">Resposta correta:</p>
            <p className="text-body font-semibold text-success">{correctLabel}</p>
          </div>

          {result.explanation && (
            <div>
              <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">
                {result.isCorrect ? 'Para complementar:' : 'Por quê?'}
              </p>
              <p className="text-body text-text">{result.explanation}</p>
            </div>
          )}

          {result.learnPoint && (
            <div>
              <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">
                {result.isCorrect ? 'Aprenda:' : 'O que aprender:'}
              </p>
              <p className="text-body text-text">{result.learnPoint}</p>
            </div>
          )}

          {!result.isCorrect && result.memoryTip && (
            <div>
              <p className="text-caption text-text-secondary uppercase tracking-wide mb-1">Dica:</p>
              <p className="text-body text-text">{result.memoryTip}</p>
            </div>
          )}
        </div>
      )}

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

      {/* Checkpoint técnico (5.ª pergunta): só confirma que o progresso foi guardado. Sem resumo. */}
      {round && !roundFinished && (
        <p className="text-caption text-text-secondary text-center">
          {round.checkpoint ? `Progresso guardado: ${round.answered} de ${round.target}. ` : ''}
          Pergunta {round.answered} de {round.target} respondida
        </p>
      )}

      <div className="flex gap-3 pt-2">
        {/* Na 10.ª pergunta o único caminho é o resumo da rodada (instrução mestre, secção 6):
            o atalho para o Painel passa a existir dentro do próprio resumo. */}
        {!roundFinished && (
          <SecondaryButton onClick={() => goWithAd('/dashboard')} className="flex-1">
            Painel
          </SecondaryButton>
        )}
        {roundFinished ? (
          <PrimaryButton
            onClick={() => goWithAd(`/quiz/${categoryId}/rodada/${round.id}`, { replace: true })}
            className="flex-1"
          >
            Ver resumo da rodada
          </PrimaryButton>
        ) : (
          <PrimaryButton
            onClick={() => goWithAd(`/quiz/${categoryId}`, { replace: true })}
            className="flex-1"
          >
            Próxima pergunta
          </PrimaryButton>
        )}
      </div>
    </div>
  );
}
