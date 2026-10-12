import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Card } from './Card';
import { PrimaryButton } from './Button';
import { useToast } from './Toast';
import { ApiError } from '../api/client';

/**
 * Cartão "Experimentar o Tema Noite por 10 minutos" (GER-002): só aparece para quem tem a oferta disponível
 * (contas novas que escolheram "Modo claro" no início e ainda não usaram o empréstimo).
 */
export function ThemeTrialCard() {
  const { user, startThemeTrial } = useAuth();
  const { showToast } = useToast();
  const [loading, setLoading] = useState(false);

  if (user?.themeTrial?.status !== 'available') return null;

  async function handleStart() {
    setLoading(true);
    try {
      await startThemeTrial();
      showToast('Tema Noite emprestado por 10 minutos.', 'success');
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível começar agora.', 'error');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card className="space-y-2">
      <p className="text-body font-semibold text-text">Experimente o Tema Noite</p>
      <p className="text-caption text-text-secondary">
        Pode usar o modo escuro durante 10 minutos, uma única vez, para ver se gosta. Depois volta ao tema claro.
      </p>
      <PrimaryButton onClick={handleStart} loading={loading} className="!py-1.5 !px-4 text-caption">
        Experimentar 10 minutos
      </PrimaryButton>
    </Card>
  );
}
