import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { ApiError } from '../api/client';

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
    loadQuestion();
    return () => clearInterval(timerRef.current);
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
      navigate(`/quiz/${categoryId}/resultado`, { state: { result: result.data, message: result.message } });
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
      <header className="flex items-center justify-between mb-8">
        <span className="text-caption text-text-secondary uppercase tracking-wide">
          Pergunta atual
        </span>
        <div
          className={`font-display font-semibold text-h2 tabular-nums ${
            timeIsRunningOut ? 'text-danger' : 'text-primary'
          }`}
        >
          00:{String(secondsLeft ?? 0).padStart(2, '0')}
        </div>
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
