/**
 * Fuso horário oficial da plataforma (Doc. Mestre Seção 1: Moçambique).
 *
 * CORREÇÃO: várias contagens de "hoje" (teto de ganho diário na Carteira,
 * tentativas de quiz por dia, cálculo de streak) usavam `now()::date` no
 * Postgres ou `new Date()` no Node, que ambos resolvem a data no fuso horário
 * DA SESSÃO/SERVIDOR — não necessariamente Moçambique (UTC+2). Se o banco ou
 * o processo Node rodar em UTC (comum em produção), a "virada do dia" para o
 * usuário acontecia 2 horas ANTES da meia-noite local, o que:
 *  - encerrava o teto de ganho diário cedo demais;
 *  - podia contar erroneamente uma atividade das 22h-23h59 (hora de MZ do dia
 *    seguinte, já que MZ está à frente de UTC) como pertencente ao dia errado
 *    no streak.
 *
 * Este módulo centraliza a resolução de "hoje" no fuso oficial da
 * plataforma, tanto para uso em SQL (fragmento reutilizável) quanto em JS.
 */

// África/Maputo é UTC+2 o ano inteiro (Moçambique não observa horário de
// verão), mas usamos o nome IANA da zona (via Intl) em vez de somar 2h à mão,
// para o código continuar correto se a plataforma expandir para outro país
// com regras de fuso diferentes (Seção 3 do Doc. Mestre: "moeda, país e
// idioma configuráveis desde a base").
const PLATFORM_TIMEZONE = process.env.PLATFORM_TIMEZONE || 'Africa/Maputo';

/**
 * Fragmento SQL para converter uma coluna timestamptz (ou now()) para a data
 * corrida no fuso da plataforma, independente do timezone configurado na
 * sessão do Postgres. Uso: `${dateInPlatformTz('created_at')} = ${dateInPlatformTz('now()')}`.
 */
function dateInPlatformTz(expression) {
  return `((${expression}) AT TIME ZONE '${PLATFORM_TIMEZONE}')::date`;
}

/**
 * Retorna a data corrida (calendário) de agora, no fuso da plataforma, como
 * string 'YYYY-MM-DD' — comparável diretamente com colunas DATE do Postgres
 * (que não carregam timezone).
 */
function todayInPlatformTz() {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: PLATFORM_TIMEZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date()); // en-CA formata como YYYY-MM-DD nativamente
}

/**
 * Diferença em dias inteiros entre duas datas 'YYYY-MM-DD' (strings de
 * calendário, sem horário/timezone embutido — seguro para aritmética direta).
 */
function diffInCalendarDays(dateStrA, dateStrB) {
  const a = Date.UTC(...dateStrA.split('-').map(Number).map((v, i) => (i === 1 ? v - 1 : v)));
  const b = Date.UTC(...dateStrB.split('-').map(Number).map((v, i) => (i === 1 ? v - 1 : v)));
  return Math.round((a - b) / 86400000);
}

module.exports = { PLATFORM_TIMEZONE, dateInPlatformTz, todayInPlatformTz, diffInCalendarDays };
