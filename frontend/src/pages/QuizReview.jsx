import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { ApiError } from '../api/client';
import { Card } from '../components/Card';
import { SecondaryButton } from '../components/Button';

const DIFFICULTY_LABELS = { easy: 'Fácil', medium: 'Médio', hard: 'Difícil' };

/**
 * Rever o que errei (BE-005 c). Lista as perguntas que o utilizador errou em rodadas e cuja
 * resposta mais recente continua errada; ao acertar depois, deixam de aparecer. O servidor só
 * devolve o enunciado e o "Por quê?" (nunca a alternativa certa nem a escolhida), e só dados do
 * próprio utilizador. Não inicia rodada: treinar é sempre uma escolha explícita da categoria.
 */
export function QuizReview() {
  const navigate = useNavigate();
  const [items, setItems] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    quizApi.reviewRecommendations(10)
      .then((res) => { if (mounted) setItems(res.data); })
      .catch((err) => {
        if (mounted) setError(err instanceof ApiError ? err.message : 'Não foi possível carregar a revisão.');
      });
    return () => { mounted = false; };
  }, []);

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2">
        <h1 className="font-display text-h1 text-text">Rever o que errei</h1>
        <p className="text-body text-text-secondary">
          Conceitos que ainda não acertou nas suas rodadas. Ao acertar, saem da lista.
        </p>
      </header>

      {!items && !error && <p className="text-caption text-text-secondary">Carregando...</p>}
      {error && <p className="text-caption text-danger">{error}</p>}

      {items && items.length === 0 && (
        <Card>
          <p className="text-body text-text">Nada para rever por agora.</p>
          <p className="text-caption text-text-secondary mt-1">
            Quando errar uma pergunta numa rodada, ela aparece aqui para estudar.
          </p>
        </Card>
      )}

      {items && items.length > 0 && (
        <ul className="space-y-2">
          {items.map((item) => (
            <li key={item.questionId}>
              <Card className="space-y-2">
                <p className="text-caption text-text-secondary">
                  {item.categoryName} · {DIFFICULTY_LABELS[item.difficulty] || item.difficulty}
                  {item.timesMissed > 1 && ` · errou ${item.timesMissed} vezes`}
                </p>
                <p className="text-body font-semibold text-text">{item.statement}</p>
                {item.explanation && (
                  <div>
                    <p className="text-caption font-semibold text-text-secondary">Por quê?</p>
                    <p className="text-body text-text">{item.explanation}</p>
                  </div>
                )}
                <SecondaryButton onClick={() => navigate(`/quiz/${item.categoryId}`)} className="!py-1.5 !px-3 text-caption">
                  Treinar {item.categoryName}
                </SecondaryButton>
              </Card>
            </li>
          ))}
        </ul>
      )}

      <SecondaryButton onClick={() => navigate('/hub-estudos')} className="w-full">
        Voltar ao Hub de Estudos
      </SecondaryButton>
    </div>
  );
}
