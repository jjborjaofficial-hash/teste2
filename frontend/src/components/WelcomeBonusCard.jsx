import { useState } from 'react';
import { Card } from './Card';
import { PrimaryButton } from './Button';
import { CheckIcon, GiftIcon } from '../icons';
import { gamificationApi } from '../api/profileApi';
import { ApiError } from '../api/client';
import { useToast } from './Toast';

function mzn(v) {
  return `${Number(v).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

const TILE_STYLE = {
  claimed: 'bg-gold text-background border-gold',
  available: 'border-gold text-gold bg-gold/10',
  missed: 'border-border text-text-secondary/50 line-through',
  locked: 'border-border text-text-secondary',
};

/**
 * Calendário de boas-vindas (7 primeiros dias da conta).
 * - Cada dia só pode ser coletado no próprio dia.
 * - Dia perdido fica BLOQUEADO e o calendário segue para o dia seguinte.
 * Valores e estados vêm do servidor; aqui só se mostra e se envia o pedido de coleta.
 */
export function WelcomeBonusCard({ bonus, onClaimed }) {
  const { showToast } = useToast();
  const [claiming, setClaiming] = useState(false);

  if (!bonus || !bonus.visible) return null;

  const today = bonus.days.find((d) => d.status === 'available');
  const missedCount = bonus.days.filter((d) => d.status === 'missed').length;

  async function handleClaim() {
    setClaiming(true);
    try {
      const res = await gamificationApi.claimWelcomeBonus();
      showToast(`Bónus de boas-vindas: +${mzn(res.data.amountMzn)}`, 'success');
      await onClaimed?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível coletar agora.', 'error');
    } finally {
      setClaiming(false);
    }
  }

  return (
    <Card className="border-gold/30 bg-gold/5">
      <div className="flex justify-between items-center">
        <span className="flex items-center gap-2 font-display font-semibold text-text">
          <GiftIcon className="w-5 h-5 text-gold" />
          Bónus de boas-vindas
        </span>
        <span className="text-caption text-text-secondary">Dia {bonus.dayNumber} de {bonus.days.length}</span>
      </div>

      <div className="grid grid-cols-7 gap-1.5 mt-3">
        {bonus.days.map((d) => (
          <div
            key={d.day}
            className={`rounded-md border py-1.5 flex flex-col items-center justify-center text-[11px] leading-tight ${TILE_STYLE[d.status]}`}
            aria-label={`Dia ${d.day}: ${mzn(d.amountMzn)} (${d.status})`}
          >
            <span className="font-semibold">{d.status === 'claimed' ? <CheckIcon className="w-4 h-4" /> : `D${d.day}`}</span>
            <span>{d.amountMzn.toFixed(2).replace('.', ',')}</span>
            <span className="text-[9px] opacity-80">MZN</span>
          </div>
        ))}
      </div>

      {today ? (
        <PrimaryButton onClick={handleClaim} loading={claiming} className="w-full mt-3 !py-2 text-caption">
          Coletar +{mzn(today.amountMzn)}
        </PrimaryButton>
      ) : (
        <p className="text-caption text-text-secondary mt-3">
          Hoje já coletou. Volte amanhã para a próxima recompensa.
        </p>
      )}

      <p className="text-caption text-text-secondary mt-2">
        Cada dia só pode ser coletado no próprio dia
        {missedCount > 0 ? ` — ${missedCount} dia${missedCount > 1 ? 's' : ''} perdido${missedCount > 1 ? 's' : ''} e bloqueado${missedCount > 1 ? 's' : ''}.` : '.'}
      </p>
    </Card>
  );
}
