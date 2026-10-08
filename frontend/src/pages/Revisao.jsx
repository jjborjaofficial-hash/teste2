import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';

const DIFFICULTY_LABEL = { easy: 'fácil', medium: 'médio', hard: 'difícil' };

/**
 * Revisão (BE-005 c): conceitos que o utilizador errou numa rodada e ainda não acertou depois.
 * Só mostra o enunciado e o "Por quê?"; nunca inventa texto quando a pergunta ainda não tem explicação.
 * Com ?categoryId=, filtra por categoria (é o link que sai do resumo da rodada).
 */
export function Revisao() {
  const [searchParams] = useSearchParams();
  const categoryId = searchParams.get('categoryId') || null;
  const navigate = useNavigate();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    setError(null);
    quizApi.reviewRecommendations({ categoryId, limit: 20 })
      .then((res) => { if (mounted) setItems(res.data); })
      .catch(() => { if (mounted) setError('Não foi possível carregar a revisão.'); })
      .finally(() => { if (mounted) setLoading(false); });
    return () => { mounted = false; };
  }, [categoryId]);

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2">
        <h1 className="font-display text-h1 text-text">Rever o que errei</h1>
        <p className="text-body text-text-secondary">
          Conceitos que você errou e ainda não acertou. Os mais recentes aparecem primeiro.
        </p>
      </header>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
      {error && <p className="text-caption text-danger">{error}</p>}

      {!loading && !error && items.length === 0 && (
        <Card className="space-y-1 text-center">
          <p className="text-body font-semibold text-text">Nada para rever por agora</p>
          <p className="text-caption text-text-secondary">
            Quando você errar uma pergunta numa rodada, ela aparece aqui até acertar.
          </p>
        </Card>
      )}

      <div className="space-y-2">
        {items.map((item) => (
          <Card key={item.questionId} className="space-y-2">
            <p className="text-body font-semibold text-text">{item.statement}</p>
            <p className="text-caption text-text-secondary">
              {item.categoryName} · {DIFFICULTY_LABEL[item.difficulty] || item.difficulty}
              {item.timesMissed > 1 ? ` · errou ${item.timesMissed} vezes` : ' · errou 1 vez'}
            </p>
            {item.explanation && (
              <div className="space-y-1 border-t border-border pt-2">
                <p className="text-caption font-semibold text-text">Por quê?</p>
                <p className="text-caption text-text-secondary">{item.explanation}</p>
              </div>
            )}
          </Card>
        ))}
      </div>

      <div className="flex flex-col gap-3 pt-2">
        {categoryId && (
          <PrimaryButton onClick={() => navigate(`/quiz/${categoryId}`)}>Praticar esta categoria</PrimaryButton>
        )}
        <SecondaryButton onClick={() => navigate('/hub-estudos')}>Escolher uma categoria</SecondaryButton>
      </div>
    </div>
  );
}
