import { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { PrimaryButton } from '../components/Button';
import { ApiError } from '../api/client';

/**
 * Tela de Cadastro (Doc. Mestre Seção 17 — Fluxo de Criação de Conta / Check-in
 * Jurídico). O checkbox de concordância é desmarcado por padrão e é obrigatório
 * antes de habilitar "Criar Conta", exatamente como especificado.
 */
export function Register() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [form, setForm] = useState({ name: '', phone: '', password: '', referralCode: '' });
  const [isAdultDeclared, setIsAdultDeclared] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [referralFromLink, setReferralFromLink] = useState(false);

  // Preenche sozinho quando a pessoa abre um link de convite (ex: .../cadastro?ref=A1B2C3D4),
  // que é exatamente o link gerado pela seção "Convites" do Perfil de quem indicou.
  useEffect(() => {
    const ref = searchParams.get('ref');
    if (ref) {
      setForm((f) => ({ ...f, referralCode: ref.toUpperCase() }));
      setReferralFromLink(true);
    }
  }, [searchParams]);

  function update(field, value) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    if (!isAdultDeclared || !termsAccepted) {
      setError('É necessário declarar maioridade e aceitar os Termos de Uso para continuar.');
      return;
    }

    setLoading(true);
    try {
      await register({
        name: form.name,
        phone: form.phone,
        password: form.password,
        isAdultDeclared: true,
        termsAccepted: true,
        referralCode: form.referralCode || undefined,
      });
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Não foi possível criar sua conta.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col justify-center px-6 py-10">
      <div className="max-w-md mx-auto w-full">
        <h1 className="font-display text-h1 text-text mb-1">Criar sua conta</h1>
        <p className="text-body text-text-secondary mb-8">
          Leva menos de um minuto. Você precisa de um número M-Pesa ou e-Mola.
          Nenhum depósito ou cartão é necessário — você só recebe dinheiro, nunca envia.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="name" className="text-caption text-text-secondary block mb-1">Nome</label>
            <input
              id="name"
              type="text"
              value={form.name}
              onChange={(e) => update('name', e.target.value)}
              required
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
          </div>

          <div>
            <label htmlFor="phone" className="text-caption text-text-secondary block mb-1">
              Número de telefone (M-Pesa 84/85 ou e-Mola 86/87)
            </label>
            <input
              id="phone"
              type="tel"
              inputMode="numeric"
              placeholder="84XXXXXXX"
              value={form.phone}
              onChange={(e) => update('phone', e.target.value)}
              required
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
          </div>

          <div>
            <label htmlFor="password" className="text-caption text-text-secondary block mb-1">
              Senha (mínimo 8 caracteres)
            </label>
            <input
              id="password"
              type="password"
              minLength={8}
              value={form.password}
              onChange={(e) => update('password', e.target.value)}
              required
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
          </div>

          <div>
            <label htmlFor="referralCode" className="text-caption text-text-secondary block mb-1">
              Código de indicação (opcional)
            </label>
            <input
              id="referralCode"
              type="text"
              value={form.referralCode}
              onChange={(e) => update('referralCode', e.target.value.toUpperCase())}
              className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
            />
            {referralFromLink && (
              <p className="text-caption text-success mt-1">Código aplicado automaticamente pelo link de convite.</p>
            )}
          </div>

          <label className="flex items-start gap-3 text-caption text-text-secondary">
            <input
              type="checkbox"
              checked={isAdultDeclared}
              onChange={(e) => setIsAdultDeclared(e.target.checked)}
              className="mt-0.5 w-5 h-5 accent-primary shrink-0"
            />
            Declaro que sou maior de idade.
          </label>

          <label className="flex items-start gap-3 text-caption text-text-secondary">
            <input
              type="checkbox"
              checked={termsAccepted}
              onChange={(e) => setTermsAccepted(e.target.checked)}
              className="mt-0.5 w-5 h-5 accent-primary shrink-0"
            />
            Li e concordo com os{' '}
            <Link to="/termos" className="text-primary font-semibold">Termos de Uso</Link> e a{' '}
            <Link to="/privacidade" className="text-primary font-semibold">Política de Privacidade</Link>{' '}
            do Aprenda e Ganhe.
          </label>

          {error && <p className="text-danger text-caption">{error}</p>}

          <PrimaryButton type="submit" loading={loading} className="w-full">
            Criar Nova Conta
          </PrimaryButton>
        </form>

        <p className="text-caption text-text-secondary text-center mt-6">
          Já tem conta? <Link to="/entrar" className="text-primary font-semibold">Entrar</Link>
        </p>
      </div>
    </div>
  );
}
