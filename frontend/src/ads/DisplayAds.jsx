import { useEffect, useRef } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * DisplayAds — banner/display do Adcash.
 *
 * Fiel ao código exato fornecido pelo Adcash para cada zona:
 *
 *   <div class="ad-container ad-300x100">
 *     <script type="text/javascript">
 *       aclib.runBanner({ zoneId: '12182518' });
 *     </script>
 *   </div>
 *
 * React não executa tags <script> inseridas via innerHTML/JSX (é uma
 * particularidade da plataforma web) — por isso este componente cria o
 * elemento <script> via DOM API e o insere manualmente dentro do
 * container, depois do aclib.js global já ter carregado. Isso garante
 * que o script de cada zona roda exatamente no mesmo lugar do DOM que
 * o código original do Adcash espera, sem alterar o comportamento.
 *
 * Localizações e dimensões reais (Zone ID configurado via env var —
 * ver .env.example):
 *   - dashboard: 300x100
 *   - content (Hub de Estudos): 250x250
 *   - wallet: 300x100 (zona ainda não criada — fica inerte até ter Zone ID)
 */
export function DisplayAds({ location, className = '' }) {
  const containerRef = useRef(null);
  const dimensions = adConfig.displayDimensions[location];
  const zoneId = adConfig.zones[location];

  useEffect(() => {
    if (!isFormatActive('display')) return undefined;
    if (!hasAdvertisingConsent()) return undefined;
    if (!zoneId || !containerRef.current) return undefined;

    let cancelled = false;

    loadAclib()
      .then(() => {
        if (cancelled || !containerRef.current) return;

        const script = document.createElement('script');
        script.type = 'text/javascript';
        script.text = `aclib.runBanner({ zoneId: '${zoneId}' });`;
        containerRef.current.appendChild(script);
      })
      .catch(() => {
        // Falha ao carregar o anúncio nunca deve quebrar a página —
        // o usuário só não vê o banner, e a plataforma segue normal.
      });

    return () => {
      cancelled = true;
    };
  }, [location, zoneId]);

  if (!isFormatActive('display') || !zoneId) return null;

  return (
    <div className={`flex justify-center ${className}`}>
      <div
        ref={containerRef}
        className={`ad-container ad-${dimensions ? `${dimensions.width}x${dimensions.height}` : location}`}
        style={{
          width: dimensions ? `${dimensions.width}px` : undefined,
          height: dimensions ? `${dimensions.height}px` : undefined,
          maxWidth: '100%',
        }}
      />
    </div>
  );
}
