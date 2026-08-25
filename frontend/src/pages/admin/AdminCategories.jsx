import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { adminQuizApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

/**
 * Painel Administrativo — Gestão de Categorias (Doc. Mestre Seção 5).
 * Antes desta tela, categorias só existiam via seed de desenvolvimento — não
 * havia nenhuma forma de criar uma categoria nova em produção.
 */
export function AdminCategories() {
  const { showToast } = useToast();
  const [categories, setCategories] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  function load() {
    adminQuizApi.listCategories().then((res) => setCategories(res.data));
  }

  useEffect(load, []);

  async function handleCreate(e) {
    e.preventDefault();
    setError(null);
    if (name.trim().length < 2) {
      setError('Digite um nome com pelo menos 2 caracteres.');
      return;
    }
    setLoading(true);
    try {
      await adminQuizApi.createCategory({ name, description: description || undefined });
      showToast('Categoria criada.', 'success');
      setName('');
      setDescription('');
      setShowForm(false);
      load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível criar a categoria.');
    } finally {
      setLoading(false);
    }
  }

  async function handleToggleActive(category) {
    try {
      await adminQuizApi.updateCategory(category.id, { isActive: !category.isActive });
      showToast(category.isActive ? 'Categoria desativada.' : 'Categoria ativada.', 'success');
      load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar.', 'error');
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-h1 text-text">Categorias</h1>
        <SecondaryButton onClick={() => setShowForm((s) => !s)} className="!py-1.5 !px-3 text-caption">
          {showForm ? 'Cancelar' : 'Nova categoria'}
        </SecondaryButton>
      </div>

      {showForm && (
        <Card className="space-y-2">
          <form onSubmit={handleCreate} className="space-y-2">
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Nome (ex: Finanças)"
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
            />
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Descrição (opcional)"
              rows={2}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
            />
            {error && <p className="text-danger text-caption">{error}</p>}
            <PrimaryButton type="submit" loading={loading} className="w-full">Criar</PrimaryButton>
          </form>
        </Card>
      )}

      {!categories && <p className="text-caption text-text-secondary">Carregando...</p>}

      <div className="space-y-2">
        {categories?.map((c) => (
          <Card key={c.id} className="flex items-center justify-between">
            <div>
              <p className="text-body font-semibold text-text">
                {c.name} {!c.isActive && <span className="text-danger text-caption font-semibold">(inativa)</span>}
              </p>
              <p className="text-caption text-text-secondary">{c.activeQuestionsCount} pergunta(s) ativa(s)</p>
            </div>
            <div className="flex items-center gap-2">
              <Link to={`/admin/conteudo/categorias/${c.id}/perguntas`} className="text-caption text-primary font-semibold">
                Ver perguntas
              </Link>
              <SecondaryButton onClick={() => handleToggleActive(c)} className="!py-1 !px-2 text-caption">
                {c.isActive ? 'Desativar' : 'Ativar'}
              </SecondaryButton>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
