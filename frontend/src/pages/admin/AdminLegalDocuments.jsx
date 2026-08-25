import { useEffect, useState } from 'react';
import { adminLegalApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const STATUS_LABELS = { active: 'Ativo', archived: 'Arquivado' };

/**
 * Painel Administrativo — Gestão de Documentos Jurídicos (docx Parte 11.1).
 * Permite criar novas versões (rascunho) e publicá-las como vigentes. Nunca
 * substitui o conteúdo de uma versão já publicada — sempre cria uma nova.
 */
function DocumentVersions({ document, onChanged }) {
  const { showToast } = useToast();
  const [versions, setVersions] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [version, setVersion] = useState('');
  const [content, setContent] = useState('');
  const [effectiveDate, setEffectiveDate] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState(null);

  function loadVersions() {
    adminLegalApi.listVersions(document.id).then((res) => setVersions(res.data));
    adminLegalApi.getAcceptanceStats(document.id).then((res) => setStats(res.data));
  }

  useEffect(loadVersions, [document.id]);

  async function handleCreate(e) {
    e.preventDefault();
    setError(null);
    if (!version.trim() || content.trim().length < 10) {
      setError('Preencha a versão e um conteúdo com pelo menos 10 caracteres.');
      return;
    }
    setLoading(true);
    try {
      await adminLegalApi.createVersion(document.id, { version, content, effectiveDate: effectiveDate || undefined });
      showToast('Nova versão criada como rascunho.', 'success');
      setVersion('');
      setContent('');
      setEffectiveDate('');
      setShowForm(false);
      loadVersions();
      onChanged?.();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível criar a versão.');
    } finally {
      setLoading(false);
    }
  }

  async function handlePublish(versionId) {
    try {
      await adminLegalApi.publishVersion(document.id, versionId);
      showToast('Versão publicada como vigente. Usuários que já aceitaram a versão anterior precisarão reaceitar.', 'success');
      loadVersions();
      onChanged?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível publicar a versão.', 'error');
    }
  }

  return (
    <Card className="space-y-3">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-body font-semibold text-text">{document.title}</p>
          <p className="text-caption text-text-secondary">
            Versão vigente: {document.version || '—'} · {STATUS_LABELS[document.status]}
            {stats && ` · ${stats.totalAccepted} aceite(s) registrado(s)`}
          </p>
        </div>
        <SecondaryButton onClick={() => setShowForm((s) => !s)} className="!py-1.5 !px-3 text-caption">
          {showForm ? 'Cancelar' : 'Nova versão'}
        </SecondaryButton>
      </div>

      {showForm && (
        <form onSubmit={handleCreate} className="space-y-2 border-t border-border pt-3">
          <input
            value={version}
            onChange={(e) => setVersion(e.target.value)}
            placeholder="Versão (ex: 1.1)"
            className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
          <input
            type="date"
            value={effectiveDate}
            onChange={(e) => setEffectiveDate(e.target.value)}
            className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={6}
            placeholder="Conteúdo completo do documento"
            className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
          {error && <p className="text-danger text-caption">{error}</p>}
          <PrimaryButton type="submit" loading={loading} className="w-full">Salvar rascunho</PrimaryButton>
        </form>
      )}

      {versions && (
        <div className="space-y-1 border-t border-border pt-3">
          {versions.map((v) => (
            <div key={v.id} className="flex items-center justify-between text-caption">
              <span className="text-text">
                v{v.version} {v.isCurrent && <span className="text-success font-semibold">(vigente)</span>}
                {!v.publishedAt && !v.isCurrent && <span className="text-warning"> (rascunho)</span>}
              </span>
              {!v.isCurrent && (
                <button onClick={() => handlePublish(v.id)} className="text-primary font-semibold">
                  Publicar
                </button>
              )}
            </div>
          ))}
        </div>
      )}
    </Card>
  );
}

export function AdminLegalDocuments() {
  const [documents, setDocuments] = useState(null);

  function load() {
    adminLegalApi.listDocuments().then((res) => setDocuments(res.data));
  }

  useEffect(load, []);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Documentos Jurídicos</h1>
      <p className="text-caption text-text-secondary">
        Central Jurídica — criação, versionamento e publicação (docx Parte 11.1).
        Documentos nunca são substituídos, apenas versionados.
      </p>

      {!documents && <p className="text-caption text-text-secondary">Carregando...</p>}

      <div className="space-y-3">
        {documents?.map((doc) => (
          <DocumentVersions key={doc.id} document={doc} onChanged={load} />
        ))}
      </div>
    </div>
  );
}
