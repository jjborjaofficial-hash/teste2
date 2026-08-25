import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { quizApi } from '../api/quizApi';
import { Card } from '../components/Card';
import { QuizIcon, ChevronRightIcon } from '../icons';

/**
 * Hub de Estudos (Doc. Mestre Seção 19.3). Lista de categorias clicáveis.
 * O Anúncio Estratégico 2 (Feed Ad) é inserido no meio da lista, conforme
 * especificado ("rolando naturalmente junto com a tela, sem ser intrusivo").
 */
export function HubEstudos() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    let mounted = true;
    quizApi.listCategories()
      .then((res) => { if (mounted) setCategories(res.data); })
      .catch(() => { if (mounted) setError('Não foi possível carregar as categorias.'); })
      .finally(() => { if (mounted) setLoading(false); });
    return () => { mounted = false; };
  }, []);

  const midpoint = Math.ceil(categories.length / 2);

  function renderCategory(cat) {
    return (
      <Card key={cat.id} onClick={() => navigate(`/quiz/${cat.id}`)} className="flex items-center gap-3">
        <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
          <QuizIcon className="w-6 h-6 text-primary" />
        </div>
        <div className="flex-1">
          <p className="text-body font-semibold text-text">{cat.name}</p>
          {cat.description && <p className="text-caption text-text-secondary">{cat.description}</p>}
        </div>
        <ChevronRightIcon className="w-5 h-5 text-text-secondary" />
      </Card>
    );
  }

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2">
        <h1 className="font-display text-h1 text-text">Hub de Estudos</h1>
        <p className="text-body text-text-secondary">O que você quer aprender hoje?</p>
      </header>

      {loading && <p className="text-caption text-text-secondary">Carregando categorias...</p>}
      {error && <p className="text-caption text-danger">{error}</p>}

      <div className="space-y-2">
        {categories.slice(0, midpoint).map(renderCategory)}

        {categories.length > 0 && (
          <div className="bg-border/40 rounded-card h-20 flex items-center justify-center text-caption text-text-secondary">
            Espaço de anúncio (Feed Ad)
          </div>
        )}

        {categories.slice(midpoint).map(renderCategory)}
      </div>
    </div>
  );
}
