import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { legalApi } from '../api/legalApi';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { ApiError } from '../api/client';
import { FAQ_GROUPS, Section, FaqGroup, LegalShell } from './Legal';

/**
 * Central de Ajuda Jurídica (docx "final jur.." Parte 21 — Central de Ajuda,
 * Parte 11.4 — Reclamações, Parte 12 — Recursos e Contestação).
 * Reúne FAQ (já existente), formulário de reclamação e sistema de recurso com
 * protocolo — tudo em um único ponto de contato do usuário com a plataforma.
 */

const CATEGORY_LABELS = {
  saques: 'Saques',
  recompensas: 'Recompensas',
  conta_bloqueada: 'Conta bloqueada',
  privacidade: 'Privacidade',
  publicidade: 'Publicidade',
  problemas_tecnicos: 'Problemas técnicos',
  conteudo: 'Conteúdo',
};

const REQUEST_STATUS_LABELS = {
  aberta: 'Aberta',
  em_analise: 'Em análise',
  aguardando_usuario: 'Aguardando você',
  resolvida: 'Resolvida',
  encerrada: 'Encerrada',
};

const APPEAL_ACTION_LABELS = {
  conta_suspensa: 'Conta suspensa',
  conta_banida: 'Conta banida',
  recompensa_removida: 'Recompensa removida',
  saque_rejeitado: 'Saque rejeitado',
  trust_score_reduzido: 'Trust Score reduzido',
};

const APPEAL_STATUS_LABELS = {
  aberto: 'Aberto',
  em_analise: 'Em análise',
  deferido: 'Deferido',
  indeferido: 'Indeferido',
};

function RequestForm({ onCreated }) {
  const { showToast } = useToast();
  const [category, setCategory] = useState('saques');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    if (description.trim().length < 10) {
      setError('Descreva sua solicitação com mais detalhes (mínimo 10 caracteres).');
      return;
    }
    setLoading(true);
    try {
      await legalApi.createRequest({ category, description });
      showToast('Reclamação enviada. Você pode acompanhar o status abaixo.', 'success');
      setDescription('');
      onCreated?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível enviar sua reclamação.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3 bg-surface border border-border rounded-card p-4">
      <div>
        <label className="text-caption text-text-secondary block mb-1">Categoria</label>
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        >
          {Object.entries(CATEGORY_LABELS).map(([value, label]) => (
            <option key={value} value={value}>{label}</option>
          ))}
        </select>
      </div>
      <div>
        <label className="text-caption text-text-secondary block mb-1">Descrição</label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={4}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          placeholder="Explique o que aconteceu com o máximo de detalhes possível."
        />
      </div>
      {error && <p className="text-danger text-caption">{error}</p>}
      <PrimaryButton type="submit" loading={loading} className="w-full">
        Enviar reclamação
      </PrimaryButton>
    </form>
  );
}

function AppealForm({ onCreated }) {
  const { showToast } = useToast();
  const [relatedAction, setRelatedAction] = useState('conta_suspensa');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [protocol, setProtocol] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    if (description.trim().length < 10) {
      setError('Descreva o motivo do recurso com mais detalhes (mínimo 10 caracteres).');
      return;
    }
    setLoading(true);
    try {
      const res = await legalApi.createAppeal({ relatedAction, description });
      setProtocol(res.data.protocol);
      showToast('Recurso registrado com sucesso.', 'success');
      setDescription('');
      onCreated?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível registrar seu recurso.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3 bg-surface border border-border rounded-card p-4">
      <div>
        <label className="text-caption text-text-secondary block mb-1">Ação que você está contestando</label>
        <select
          value={relatedAction}
          onChange={(e) => setRelatedAction(e.target.value)}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        >
          {Object.entries(APPEAL_ACTION_LABELS).map(([value, label]) => (
            <option key={value} value={value}>{label}</option>
          ))}
        </select>
      </div>
      <div>
        <label className="text-caption text-text-secondary block mb-1">Motivo do recurso</label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={4}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          placeholder="Explique por que você acredita que esta decisão deveria ser revista."
        />
      </div>
      {error && <p className="text-danger text-caption">{error}</p>}
      {protocol && (
        <p className="text-caption text-success">
          Recurso registrado! Protocolo: <strong>{protocol}</strong> — guarde este número.
        </p>
      )}
      <SecondaryButton type="submit" loading={loading} className="w-full">
        Enviar recurso
      </SecondaryButton>
    </form>
  );
}

function MyRequestsAndAppeals({ refreshKey }) {
  const [requests, setRequests] = useState(null);
  const [appeals, setAppeals] = useState(null);

  useEffect(() => {
    legalApi.listMyRequests().then((res) => setRequests(res.data)).catch(() => setRequests([]));
    legalApi.listMyAppeals().then((res) => setAppeals(res.data)).catch(() => setAppeals([]));
  }, [refreshKey]);

  return (
    <div className="space-y-4">
      <div>
        <h3 className="text-caption font-semibold text-text-secondary uppercase tracking-wide mb-2">
          Minhas Reclamações
        </h3>
        {requests?.length === 0 && <p className="text-caption text-text-secondary">Nenhuma reclamação enviada ainda.</p>}
        <div className="space-y-2">
          {requests?.map((r) => (
            <div key={r.id} className="bg-surface border border-border rounded-card px-4 py-3">
              <div className="flex items-center justify-between">
                <span className="text-body font-semibold text-text">{CATEGORY_LABELS[r.category]}</span>
                <span className="text-caption text-primary font-semibold">{REQUEST_STATUS_LABELS[r.status]}</span>
              </div>
              <p className="text-caption text-text-secondary mt-1">{r.description}</p>
              {r.response && (
                <p className="text-caption text-text mt-2 pt-2 border-t border-border">
                  <strong>Resposta:</strong> {r.response}
                </p>
              )}
            </div>
          ))}
        </div>
      </div>

      <div>
        <h3 className="text-caption font-semibold text-text-secondary uppercase tracking-wide mb-2">
          Meus Recursos
        </h3>
        {appeals?.length === 0 && <p className="text-caption text-text-secondary">Nenhum recurso registrado ainda.</p>}
        <div className="space-y-2">
          {appeals?.map((a) => (
            <div key={a.id} className="bg-surface border border-border rounded-card px-4 py-3">
              <div className="flex items-center justify-between">
                <span className="text-body font-semibold text-text">{APPEAL_ACTION_LABELS[a.relatedAction]}</span>
                <span className="text-caption text-primary font-semibold">{APPEAL_STATUS_LABELS[a.status]}</span>
              </div>
              <p className="text-caption text-text-secondary mt-1">Protocolo: {a.protocol}</p>
              {a.decision && (
                <p className="text-caption text-text mt-2 pt-2 border-t border-border">
                  <strong>Decisão:</strong> {a.decision}
                </p>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export function SupportPage() {
  const { user } = useAuth();
  const [tab, setTab] = useState('faq');
  const [refreshKey, setRefreshKey] = useState(0);

  return (
    <LegalShell title="Suporte e FAQ">
      <Section number={1} title="Canais de Contato">
        <p>Canal oficial de suporte ainda em definição. Por enquanto, use a Central
        de Reclamações e o Sistema de Recursos abaixo — ambos ficam registrados e
        são analisados pela nossa equipe.</p>
      </Section>

      {user && (
        <div className="flex gap-2 pt-1">
          {[
            { key: 'faq', label: 'FAQ' },
            { key: 'reclamar', label: 'Reclamação' },
            { key: 'recurso', label: 'Recurso' },
            { key: 'minhas', label: 'Minhas solicitações' },
          ].map((t) => (
            <button
              key={t.key}
              onClick={() => setTab(t.key)}
              className={`px-3 py-1.5 rounded-full text-caption font-semibold transition-colors duration-micro ${
                tab === t.key ? 'bg-primary text-white' : 'bg-surface border border-border text-text-secondary'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>
      )}

      {(!user || tab === 'faq') && (
        <div className="space-y-5 pt-2">
          {FAQ_GROUPS.map((group) => (
            <FaqGroup key={group.title} title={group.title} items={group.items} />
          ))}
        </div>
      )}

      {user && tab === 'reclamar' && (
        <div className="pt-2">
          <RequestForm onCreated={() => setRefreshKey((k) => k + 1)} />
        </div>
      )}

      {user && tab === 'recurso' && (
        <div className="pt-2">
          <AppealForm onCreated={() => setRefreshKey((k) => k + 1)} />
        </div>
      )}

      {user && tab === 'minhas' && (
        <div className="pt-2">
          <MyRequestsAndAppeals refreshKey={refreshKey} />
        </div>
      )}

      {!user && (
        <p className="text-caption text-text-secondary pt-2">
          <Link to="/entrar" className="text-primary font-semibold">Entre na sua conta</Link> para abrir uma
          reclamação ou registrar um recurso.
        </p>
      )}
    </LegalShell>
  );
}
