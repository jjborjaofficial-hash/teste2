import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { ApiError } from '../api/client';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { RewardBadge } from '../components/RewardBadge';
import { XpIcon, PointsIcon } from '../icons';

const DIFFICULTY_LABEL = { easy: 'Fácil', medium: 'Média', hard: 'Difícil' };

function motivationalMessage(percent) {
  if (percent >= 80) return 'Excelente rodada. Você domina bem este assunto.';
  if (percent >= 50) return 'Bom progresso. Rever os pontos abaixo ajuda a consolidar o que aprendeu.';
  return 'Cada rodada ensina algo novo. Reveja os pontos abaixo e tente de novo quando quiser.';
}

/**
 * Resumo da rodada (aparece só depois da 10.ª pergunta; aos 5 há apenas um checkpoint
 * técnico sem resumo). Os dados vêm do servidor, então recarregar a página não perde o
 * resumo.
 */
export function QuizRoundSummary() {
  const { roundId } = useParams();
  const navigate = useNavigate();
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;
    quizApi.roundSummary(roundId)
      .then((res) => { if (!cancelled) setSummary(res.data); })
      .catch((err) => {
        if (!cancelled) setError(err instanceof ApiError ? err.message : 'Não foi possível carregar o resumo.');
      });
    return () => { cancelled = true; };
  }, [roundId]);

  if (error) {
    return (
      <div className="text-center mt-10 space-y-4">
        <p className="text-body text-danger">{error}</p>
        <button onClick={() => navigate('/hub-estudos')} className="text-primary text-body font-semibold">
          Voltar ao Hub de Estudos
        </button>
      </div>
    );
  }

  if (!summary) {
    return <p className="text-center text-body text-text-secondary mt-10">Carregando resumo...</p>;
  }

  return (
    <div className="space-y-5 pt-6 pb-4">
      <div className="text-center space-y-1">
        <h1 className="font-display text-h1 text-text">Rodada concluída</h1>
        <p className="text-body text-text-secondary">
          {summary.answered} perguntas respondidas em {summary.categoryName}
        </p>
      </div>

      <div className="bg-surface border border-border rounded-card p-5">
        <div className="grid grid-cols-3 gap-3 text-center">
          <div>
            <p className="font-display text-h1 text-success">{summary.correct}</p>
            <p className="text-caption text-text-secondary">acertos</p>
          </div>
          <div>
            <p className="font-display text-h1 text-danger">{summary.wrong}</p>
            <p className="text-caption text-text-secondary">erros</p>
          </div>
          <div>
            <p className="font-display text-h1 text-primary">{summary.accuracyPercent}%</p>
            <p className="text-caption text-text-secondary">aproveitamento</p>
          </div>
        </div>
      </div>

      <div className="bg-surface border border-border rounded-card p-5 space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-body text-text-secondary">XP obtido</span>
          <span className="flex items-center gap-1.5">
            <XpIcon className="w-4 h-4 text-gold" />
            <RewardBadge isNew={summary.xpEarned > 0}>+{summary.xpEarned} XP</RewardBadge>
          </span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-body text-text-secondary">Pontos obtidos</span>
          <span className="flex items-center gap-1.5">
            <PointsIcon className="w-4 h-4 text-secondary" />
            <RewardBadge isNew={summary.pointsEarned > 0}>+{summary.pointsEarned} Pontos</RewardBadge>
          </span>
        </div>
        {summary.bestDifficulty && (
          <div className="flex items-center justify-between">
            <span className="text-body text-text-secondary">Melhor desempenho</span>
            <span className="font-display font-semibold text-text">
              Perguntas {DIFFICULTY_LABEL[summary.bestDifficulty].toLowerCase()}s
            </span>
          </div>
        )}
        {summary.reviewDifficulty && summary.reviewDifficulty !== summary.bestDifficulty && (
          <div className="flex items-center justify-between">
            <span className="text-body text-text-secondary">Vale a pena rever</span>
            <span className="font-display font-semibold text-text">
              Perguntas {DIFFICULTY_LABEL[summary.reviewDifficulty].toLowerCase()}s
            </span>
          </div>
        )}
      </div>

      {summary.toReview.length > 0 && (
        <div className="bg-surface border border-border rounded-card p-5 space-y-4">
          <p className="font-display font-semibold text-text">Para rever</p>
          {summary.toReview.map((item) => (
            <div key={item.questionId} className="space-y-1">
              <p className="text-body text-text">{item.statement}</p>
              {item.correctLabel && (
                <p className="text-caption text-success">Resposta correta: {item.correctLabel}</p>
              )}
            </div>
          ))}
        </div>
      )}

      <p className="text-body text-text-secondary text-center">{motivationalMessage(summary.accuracyPercent)}</p>

      <div className="flex gap-3 pt-2">
        <SecondaryButton onClick={() => navigate('/dashboard')} className="flex-1">
          Painel
        </SecondaryButton>
        <PrimaryButton onClick={() => navigate('/hub-estudos', { replace: true })} className="flex-1">
          Escolher categoria
        </PrimaryButton>
      </div>
    </div>
  );
}
