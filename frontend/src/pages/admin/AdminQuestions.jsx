import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { adminQuizApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const DIFFICULTY_LABELS = { easy: 'Fácil', medium: 'Médio', hard: 'Difícil' };

function emptyAlternatives() {
  return [
    { label: '', isCorrect: true },
    { label: '', isCorrect: false },
    { label: '', isCorrect: false },
    { label: '', isCorrect: false },
  ];
}

function QuestionForm({ categoryId, onCreated, onCancel }) {
  const { showToast } = useToast();
  const [statement, setStatement] = useState('');
  const [difficulty, setDifficulty] = useState('easy');
  const [timeLimitSeconds, setTimeLimitSeconds] = useState(15);
  const [xpReward, setXpReward] = useState(10);
  const [alternatives, setAlternatives] = useState(emptyAlternatives());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  function updateAlternative(index, field, value) {
    setAlternatives((prev) =>
      prev.map((alt, i) => {
        if (field === 'isCorrect') {
          // Só uma alternativa correta por vez (Manual Parte 5: regra de negócio no backend,
          // mas já evitamos o erro aqui mesmo, na UI).
          return { ...alt, isCorrect: i === index };
        }
        return i === index ? { ...alt, [field]: value } : alt;
      })
    );
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    if (statement.trim().length < 5) {
      setError('Escreva o enunciado da pergunta.');
      return;
    }
    const filled = alternatives.filter((a) => a.label.trim().length > 0);
    if (filled.length < 2) {
      setError('Preencha pelo menos 2 alternativas.');
      return;
    }

    setLoading(true);
    try {
      await adminQuizApi.createQuestion({
        categoryId,
        statement,
        difficulty,
        timeLimitSeconds: Number(timeLimitSeconds),
        xpReward: Number(xpReward),
        alternatives: filled,
      });
      showToast('Pergunta criada.', 'success');
      onCreated?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível criar a pergunta.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card className="space-y-3">
      <form onSubmit={handleSubmit} className="space-y-3">
        <textarea
          value={statement}
          onChange={(e) => setStatement(e.target.value)}
          placeholder="Enunciado da pergunta"
          rows={2}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        />

        <div className="flex gap-2">
          <select
            value={difficulty}
            onChange={(e) => setDifficulty(e.target.value)}
            className="flex-1 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          >
            {Object.entries(DIFFICULTY_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
          <input
            type="number"
            value={timeLimitSeconds}
            onChange={(e) => setTimeLimitSeconds(e.target.value)}
            title="Tempo limite (segundos)"
            className="w-24 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
          <input
            type="number"
            value={xpReward}
            onChange={(e) => setXpReward(e.target.value)}
            title="XP ao acertar"
            className="w-24 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
        </div>

        <div className="space-y-2">
          <p className="text-caption text-text-secondary">Alternativas (marque a correta)</p>
          {alternatives.map((alt, i) => (
            <div key={i} className="flex items-center gap-2">
              <input
                type="radio"
                name="correct-alt"
                checked={alt.isCorrect}
                onChange={() => updateAlternative(i, 'isCorrect', true)}
                className="w-5 h-5 accent-success shrink-0"
              />
              <input
                value={alt.label}
                onChange={(e) => updateAlternative(i, 'label', e.target.value)}
                placeholder={`Alternativa ${i + 1}`}
                className="flex-1 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
              />
            </div>
          ))}
        </div>

        {error && <p className="text-danger text-caption">{error}</p>}

        <div className="flex gap-2">
          <SecondaryButton onClick={onCancel} className="flex-1">Cancelar</SecondaryButton>
          <PrimaryButton type="submit" loading={loading} className="flex-1">Criar pergunta</PrimaryButton>
        </div>
      </form>
    </Card>
  );
}

export function AdminQuestions() {
  const { categoryId } = useParams();
  const [questions, setQuestions] = useState(null);
  const [showForm, setShowForm] = useState(false);

  function load() {
    adminQuizApi.listQuestions(categoryId).then((res) => setQuestions(res.data));
  }

  useEffect(load, [categoryId]);

  async function handleToggleActive(question) {
    try {
      await adminQuizApi.updateQuestion(question.id, { isActive: !question.isActive });
      load();
    } catch {
      // erro já é reportado via toast pelo padrão do client; silencioso aqui.
    }
  }

  return (
    <div className="space-y-4">
      <Link to="/admin/conteudo/categorias" className="text-caption text-primary font-semibold">← Categorias</Link>
      <div className="flex items-center justify-between">
        <h1 className="font-display text-h1 text-text">Perguntas</h1>
        <SecondaryButton onClick={() => setShowForm((s) => !s)} className="!py-1.5 !px-3 text-caption">
          {showForm ? 'Cancelar' : 'Nova pergunta'}
        </SecondaryButton>
      </div>

      {showForm && (
        <QuestionForm
          categoryId={categoryId}
          onCreated={() => { setShowForm(false); load(); }}
          onCancel={() => setShowForm(false)}
        />
      )}

      {!questions && <p className="text-caption text-text-secondary">Carregando...</p>}
      {questions?.length === 0 && <Card><p className="text-body text-text-secondary">Nenhuma pergunta nesta categoria ainda.</p></Card>}

      <div className="space-y-2">
        {questions?.map((q) => (
          <Card key={q.id} className="space-y-1">
            <div className="flex items-start justify-between gap-2">
              <p className="text-body text-text flex-1">{q.statement}</p>
              <SecondaryButton onClick={() => handleToggleActive(q)} className="!py-1 !px-2 text-caption shrink-0">
                {q.isActive ? 'Desativar' : 'Ativar'}
              </SecondaryButton>
            </div>
            <p className="text-caption text-text-secondary">
              {DIFFICULTY_LABELS[q.difficulty]} · {q.timeLimitSeconds}s · {q.xpReward} XP
              {!q.isActive && <span className="text-danger font-semibold"> · Inativa</span>}
            </p>
          </Card>
        ))}
      </div>
    </div>
  );
}
