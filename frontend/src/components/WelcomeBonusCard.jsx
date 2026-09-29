import { Card } from './Card';
import { CheckIcon } from '../icons';

function mzn(v) {
  return `${Number(v).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

/**
 * Bónus de boas-vindas (primeiros 7 dias). Mostra os 7 dias, o que já foi ganho e o
 * que falta para o bónus de conclusão. Só aparece enquanto a janela está aberta.
 * Todos os valores vêm do servidor (system_config), nada é fixo aqui.
 */
export function WelcomeBonusCard({ bonus }) {
  if (!bonus || !bonus.visible) return null;

  const remaining = Math.max(0, bonus.requiredDays - bonus.studiedDays);

  return (
    <Card className="border-gold/30 bg-gold/5">
      <div className="flex justify-between items-baseline">
        <span className="font-display font-semibold text-text">Bónus de boas-vindas</span>
        <span className="text-caption text-text-secondary">Dia {bonus.dayNumber} de {bonus.totalDays}</span>
      </div>

      <div className="flex gap-1.5 mt-3" aria-label={`${bonus.studiedDays} de ${bonus.totalDays} dias estudados`}>
        {bonus.days.map((done, i) => {
          const isToday = i + 1 === bonus.dayNumber;
          return (
            <div
              key={i}
              className={`flex-1 h-7 rounded-md flex items-center justify-center text-caption border ${
                done
                  ? 'bg-gold text-background border-gold'
                  : isToday
                    ? 'border-gold text-gold'
                    : 'border-border text-text-secondary'
              }`}
            >
              {done ? <CheckIcon className="w-4 h-4" /> : i + 1}
            </div>
          );
        })}
      </div>

      <p className="text-caption text-text-secondary mt-3">
        {bonus.completed
          ? `Semana concluída! Já ganhou ${mzn(bonus.earnedMzn)} de bónus.`
          : bonus.studiedToday
            ? `Hoje já garantiu +${mzn(bonus.dailyMzn)}. Faltam ${remaining} dia${remaining === 1 ? '' : 's'} de estudo para o extra de +${mzn(bonus.completionMzn)}.`
            : `Acerte uma pergunta hoje e ganhe +${mzn(bonus.dailyMzn)}. Estudando em ${bonus.requiredDays} dos ${bonus.totalDays} dias, ganha +${mzn(bonus.completionMzn)} extra.`}
      </p>
    </Card>
  );
}
