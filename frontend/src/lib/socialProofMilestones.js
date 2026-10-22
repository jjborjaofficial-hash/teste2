/**
 * Marcos da prova social: devolve o MAIOR marco estritamente abaixo do valor real, para o texto "Mais de X" ser
 * sempre verdadeiro e só mudar quando a plataforma passa um marco (nunca "vibra"). Devolve null se o valor
 * não passa o primeiro marco.
 */
const BASE = [5, 10, 20, 50, 100, 200, 500];

function marcos() {
  const out = [...BASE];
  for (let m = 1000; m <= 100000000; m *= 10) out.push(m, m * 2, m * 5);
  return out;
}

export function maisDe(valor) {
  let best = null;
  for (const m of marcos()) {
    if (valor > m) best = m;
    else break;
  }
  return best;
}
