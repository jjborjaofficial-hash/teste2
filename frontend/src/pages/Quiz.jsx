import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { ApiError } from '../api/client';
import { QUIZ_ROUND_SIZE } from '../lib/quizRound';

/**
 * Tela de Quiz Ativo (Doc. Mestre Seção 19.4 — "O Coração do Sistema").
 * Cabeçalho minimalista, cronômetro visual de contagem regressiva, 4 alternativas,
 * SEM anúncios (para não travar o carregamento nem o cronômetro) e SEM BottomNav/Rodapé
 * (usa FocusLayout — ver src/layouts/FocusLayout.jsx).
 *
 * O cronômetro no cliente é só visual/UX: o tempo real é medido inteiramente
 * pelo servidor, a partir do instante em que ele entrega a pergunta (Manual
 * Parte 5: o backend é sempre a autoridade final) — o cliente não envia mais
 * nenhum valor de tempo, então não há como burlar o antifraude manipulando
 * o relógio do navegador.
 */
export function Quiz() {
  const { categoryId } = useParams();
  const navigate = useNavigate();

  const [question, setQuestion] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selecting, setSelecting] = useState(false);
  const [secondsLeft, setSecondsLeft] = useState(null);

  const timerRef = useRef(null);

  const loadQuestion = useCallback(() => {
    setLoading(true);
    setError(null);
    setQuestion(null);
    quizApi.nextQuestion(categoryId)
      .then((res) => {
        setQuestion(res.data);
        setSecondsLeft(res.data.time_limit_seconds);
      })
      .catch((err) => {
        setError(err instanceof ApiError ? err.message : 'Não foi possível carregar a pergunta.');
      })
      .finally(() => setLoading(false));
  }, [categoryId]);

  useEffect(() => {
    // O progresso da rodada vem do servidor junto com a pergunta (question.round):
    // recarregar a página retoma a rodada onde ficou.
    loadQuestion();
    return () => clearInterval(timerRef.current);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [loadQuestion]);

  useEffect(() => {
    if (secondsLeft === null) return undefined;
    clearInterval(timerRef.current);

    if (secondsLeft <= 0) return undefined;

    timerRef.current = setInterval(() => {
      setSecondsLeft((s) => {
        if (s <= 1) {
          clearInterval(timerRef.current);
          return 0;
        }
        return s - 1;
      });
    }, 1000);

    return () => clearInterval(timerRef.current);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [question]);

  async function handleAnswer(alternativeId) {
    if (selecting || !question) return;
    setSelecting(true);
    clearInterval(timerRef.current);

    try {
      const result = await quizApi.submitAnswer({
        questionId: question.id,
        alternativeId,
      });
      // replace: o botão voltar não reabre uma pergunta já respondida.
      navigate(`/quiz/${categoryId}/resultado`, {
        replace: true,
        state: {
          result: result.data,
          message: result.message,
          // Texto da pergunta e das alternativas (o cliente já os tinha): o ecrã de resultado
          // mostra a resposta escolhida e a correta sem pedir nada de novo ao servidor.
          question: {
            statement: question.statement,
            alternatives: question.alternatives.map((a) => ({ id: a.id, label: a.label })),
          },
        },
      });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível enviar sua resposta.');
      setSelecting(false);
    }
  }

  useEffect(() => {
    if (secondsLeft === 0 && question && !selecting) {
      // Tempo esgotado (Seção 19.4): submete automaticamente como errada.
      // O backend mede o tempo de forma totalmente independente, então enviar
      // qualquer alternativa aqui é seguro — o resultado será "errado" de
      // qualquer forma, pois timeExpired será true no servidor.
      handleAnswer(question.alternatives[0]?.id);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [secondsLeft]);

  const timeIsRunningOut = secondsLeft !== null && question && secondsLeft <= Math.ceil(question.time_limit_seconds * 0.3);

  if (loading) {
    return <p className="text-center text-body text-text-secondary mt-10">Carregando pergunta...</p>;
  }

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

  if (!question) return null;

  return (
    <div className="flex-1 flex flex-col">
      <div
        className="h-1 w-full bg-border rounded-full overflow-hidden mb-4"
        role="progressbar"
        aria-valuemin={0}
        aria-valuemax={question.time_limit_seconds}
        aria-valuenow={secondsLeft ?? 0}
      >
        <div
          className={`h-full rounded-full transition-[width] duration-1000 ease-linear ${
            timeIsRunningOut ? 'bg-danger' : 'bg-primary'
          }`}
          style={{ width: `${Math.max(0, ((secondsLeft ?? 0) / question.time_limit_seconds) * 100)}%` }}
        />
      </div>

      <header className="flex items-center justify-between mb-8">
        <span className="text-caption text-text-secondary uppercase tracking-wide">
          Pergunta {(question.round?.answered ?? 0) + 1} de {question.round?.target ?? QUIZ_ROUND_SIZE}
        </span>
        {/* Segundos visíveis a decrescer (a barra fina continua acima). aria-hidden para o
            leitor de ecrã não anunciar a cada segundo; o texto sr-only abaixo cobre isso. */}
        <span
          aria-hidden="true"
          className={`font-display font-semibold tabular-nums text-body ${
            timeIsRunningOut ? 'text-danger' : 'text-text-secondary'
          }`}
        >
          {secondsLeft ?? 0}s
        </span>
        <span className="sr-only" aria-live="polite">{secondsLeft ?? 0} segundos restantes</span>
      </header>

      <h1 className="font-display text-h1 text-text mb-8">{question.statement}</h1>

      <div className="flex-1 space-y-3">
        {question.alternatives.map((alt) => (
          <button
            key={alt.id}
            onClick={() => handleAnswer(alt.id)}
            disabled={selecting || secondsLeft === 0}
            className="w-full text-left bg-surface border border-border rounded-card px-4 py-4
                       text-body text-text transition-all duration-micro
                       hover:border-primary/40 active:scale-[0.98]
                       disabled:opacity-45"
          >
            {alt.label}
          </button>
        ))}
      </div>

      {secondsLeft === 0 && (
        <p className="text-center text-caption text-danger mt-4">Tempo esgotado!</p>
      )}
    </div>
  );
}
