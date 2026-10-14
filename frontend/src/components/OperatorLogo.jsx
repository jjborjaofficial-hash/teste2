import vodacom1x from '../assets/operators/vodacom.png';
import vodacom2x from '../assets/operators/vodacom@2x.png';
import movitel1x from '../assets/operators/movitel.png';
import movitel2x from '../assets/operators/movitel@2x.png';

/**
 * Operadora de um número de Moçambique, pelo prefixo: 84/85 = Vodacom (M-Pesa), 86/87 = Movitel (e-Mola).
 * Devolve null enquanto a pessoa ainda não escreveu os dois primeiros dígitos ou se o prefixo não é um destes.
 */
export function operatorOf(phone) {
  const prefix = String(phone || '').replace(/\D/g, '').slice(0, 2);
  if (prefix === '84' || prefix === '85') return 'vodacom';
  if (prefix === '86' || prefix === '87') return 'movitel';
  return null;
}

const LOGOS = {
  vodacom: { src: vodacom1x, srcSet: `${vodacom1x} 1x, ${vodacom2x} 2x`, alt: 'Vodacom (M-Pesa)', className: 'h-5 w-auto' },
  movitel: { src: movitel1x, srcSet: `${movitel1x} 1x, ${movitel2x} 2x`, alt: 'Movitel (e-Mola)', className: 'h-7 w-7 rounded-md' },
};

/**
 * Logo da operadora, dentro do campo do número (canto direito). Tem de ficar dentro de um contentor `relative`, e o
 * <input> precisa de `pr-24` para o texto não ficar por baixo do logo. Não captura toques (o campo continua a receber o foco).
 */
export function OperatorLogo({ phone }) {
  const operator = operatorOf(phone);
  if (!operator) return null;
  const logo = LOGOS[operator];
  return (
    <img
      src={logo.src}
      srcSet={logo.srcSet}
      alt={logo.alt}
      className={`absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none select-none ${logo.className}`}
      draggable={false}
    />
  );
}
