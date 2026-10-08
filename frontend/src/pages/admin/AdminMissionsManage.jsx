import { useEffect, useState } from 'react';
import { adminQuizApi, adminMissionsApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const TYPE_LABELS = { daily: 'Diária', weekly: 'Semanal', special: 'Especial', sponsored: 'Patrocinada' };

// Só estes dois tipos podem ser criados pelo painel (o servidor recusa os outros);
// os restantes (entrar, tempo ativo, explorar categorias) vêm das migrations.
const CREATABLE_ACTIVITY_TYPES = {
  quiz_count: { label: 'Quizzes (respostas certas)', targetLabel: 'Quizzes necessários' },
  round_complete: { label: 'Rodadas completas (10 perguntas)', targetLabel: 'Rodadas necessárias' },
};

// Como a meta de cada tipo de missão é contada, para mostrar na lista.
const ACTIVITY_UNITS = {
  quiz_count: 'quiz(zes)',
  round_complete: 'rodada(s)',
  login: 'entrada(s)',
  time_active_minutes: 'minuto(s) ativo(s)',
  category_exploration: 'categoria(s)',
};

function MissionForm({ categories, onCreated, onCancel }) {
  const { showToast } = useToast();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [type, setType] = useState('daily');
  const [categoryId, setCategoryId] = useState('');
  const [activityType, setActivityType] = useState('quiz_count');
  const [targetQuizCount, setTargetQuizCount] = useState(1);
  const [xpReward, setXpReward] = useState(20);
  const [pointsReward, setPointsReward] = useState(10);
  const [moneyRewardMzn, setMoneyRewardMzn] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Só missões de quizzes (que contam respostas certas) podem pagar dinheiro.
  const pays = activityType === 'quiz_count';

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    if (title.trim().length < 3) {
      setError('Digite um título para a missão.');
      return;
    }
    setLoading(true);
    try {
      await adminMissionsApi.create({
        title,
        description: description || undefined,
        type,
        categoryId: categoryId || undefined,
        activityType,
        targetQuizCount: Number(targetQuizCount),
        xpReward: Number(xpReward),
        pointsReward: Number(pointsReward),
        // Rodada conta mesmo sem acertos: nunca paga dinheiro (o servidor também recusa).
        moneyRewardMzn: pays ? Number(moneyRewardMzn) : 0,
      });
      showToast('Missão criada.', 'success');
      onCreated?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível criar a missão.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card className="space-y-3">
      <form onSubmit={handleSubmit} className="space-y-3">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Título (ex: Quiz Diário de Finanças)"
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        />
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Descrição (ex: Complete 1 quiz de Finanças hoje)"
          rows={2}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        />
        <div className="flex gap-2">
          <select
            value={type}
            onChange={(e) => setType(e.target.value)}
            className="flex-1 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          >
            {Object.entries(TYPE_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
          <select
            value={categoryId}
            onChange={(e) => setCategoryId(e.target.value)}
            className="flex-1 rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          >
            <option value="">Qualquer categoria</option>
            {categories?.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
        <label className="block text-caption text-text-secondary">
          O que a missão conta
          <select
            value={activityType}
            onChange={(e) => {
              setActivityType(e.target.value);
              if (e.target.value !== 'quiz_count') setMoneyRewardMzn(0);
            }}
            className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text mt-1"
          >
            {Object.entries(CREATABLE_ACTIVITY_TYPES).map(([v, a]) => <option key={v} value={v}>{a.label}</option>)}
          </select>
        </label>
        <div className="grid grid-cols-2 gap-2">
          <label className="text-caption text-text-secondary">
            {CREATABLE_ACTIVITY_TYPES[activityType].targetLabel}
            <input type="number" value={targetQuizCount} onChange={(e) => setTargetQuizCount(e.target.value)}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text mt-1" />
          </label>
          <label className="text-caption text-text-secondary">
            XP de recompensa
            <input type="number" value={xpReward} onChange={(e) => setXpReward(e.target.value)}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text mt-1" />
          </label>
          <label className="text-caption text-text-secondary">
            Pontos de recompensa
            <input type="number" value={pointsReward} onChange={(e) => setPointsReward(e.target.value)}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text mt-1" />
          </label>
          <label className="text-caption text-text-secondary">
            MZN de recompensa
            <input type="number" step="0.01" value={pays ? moneyRewardMzn : 0} disabled={!pays}
              onChange={(e) => setMoneyRewardMzn(e.target.value)}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text mt-1 disabled:opacity-50" />
          </label>
        </div>

        {!pays && (
          <p className="text-caption text-text-secondary">
            Missões de rodadas não pagam dinheiro: a rodada conta mesmo sem acertos. Dão só XP e Pontos.
            Para pagar dinheiro, use uma missão de quizzes (que só conta respostas certas).
          </p>
        )}

        {Number(moneyRewardMzn) > 0 && (
          <p className="text-caption text-warning">
            ⚠️ Esta missão paga dinheiro real. Ela é limitada pelo teto de ganho diário (7,20 MZN) automaticamente.
          </p>
        )}

        {error && <p className="text-danger text-caption">{error}</p>}

        <div className="flex gap-2">
          <SecondaryButton onClick={onCancel} className="flex-1">Cancelar</SecondaryButton>
          <PrimaryButton type="submit" loading={loading} className="flex-1">Criar missão</PrimaryButton>
        </div>
      </form>
    </Card>
  );
}

/**
 * Painel Administrativo — Gestão de Missões. Antes desta tela, `missions` só
 * tinha 1 linha de seed de desenvolvimento e nenhuma rota para criar novas —
 * sem isso, a plataforma em produção nunca teria missões reais para os
 * usuários completarem.
 */
export function AdminMissionsManage() {
  const { showToast } = useToast();
  const [missions, setMissions] = useState(null);
  const [categories, setCategories] = useState(null);
  const [showForm, setShowForm] = useState(false);

  function load() {
    adminMissionsApi.list().then((res) => setMissions(res.data));
  }

  useEffect(() => {
    load();
    adminQuizApi.listCategories().then((res) => setCategories(res.data));
  }, []);

  async function handleToggleActive(mission) {
    try {
      await adminMissionsApi.update(mission.id, { isActive: !mission.isActive });
      showToast(mission.isActive ? 'Missão desativada.' : 'Missão ativada.', 'success');
      load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar.', 'error');
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-h1 text-text">Missões</h1>
        <SecondaryButton onClick={() => setShowForm((s) => !s)} className="!py-1.5 !px-3 text-caption">
          {showForm ? 'Cancelar' : 'Nova missão'}
        </SecondaryButton>
      </div>

      {showForm && (
        <MissionForm categories={categories} onCreated={() => { setShowForm(false); load(); }} onCancel={() => setShowForm(false)} />
      )}

      {!missions && <p className="text-caption text-text-secondary">Carregando...</p>}

      <div className="space-y-2">
        {missions?.map((m) => (
          <Card key={m.id} className="space-y-1">
            <div className="flex items-start justify-between gap-2">
              <div>
                <p className="text-body font-semibold text-text">
                  {m.title} {!m.isActive && <span className="text-danger text-caption font-semibold">(inativa)</span>}
                </p>
                <p className="text-caption text-text-secondary">
                  {TYPE_LABELS[m.type]} · {m.categoryName || 'Qualquer categoria'} · {m.targetQuizCount} {ACTIVITY_UNITS[m.activityType] || 'meta'}
                </p>
                <p className="text-caption text-gold font-semibold">
                  {m.xpReward} XP · {m.pointsReward} Pontos {m.moneyRewardMzn > 0 && `· ${m.moneyRewardMzn.toFixed(2)} MZN`}
                </p>
                <p className="text-caption text-text-secondary">{m.assignmentsCount} usuário(s) receberam esta missão</p>
              </div>
              <SecondaryButton onClick={() => handleToggleActive(m)} className="!py-1 !px-2 text-caption shrink-0">
                {m.isActive ? 'Desativar' : 'Ativar'}
              </SecondaryButton>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
