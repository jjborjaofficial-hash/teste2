/**
 * Consentimento de publicidade — ponte para o sistema de cookies já
 * existente (CookieBanner.jsx). Nenhum componente de anúncio deste
 * módulo deve carregar ou chamar o script do Adcash sem primeiro
 * confirmar aqui que o usuário aceitou "cookies de publicidade" —
 * exigência da Seção 8 do documento jurídico da plataforma
 * ("As escolhas deverão ser armazenadas").
 *
 * IMPORTANTE: a chave abaixo precisa ser IDÊNTICA à LOCAL_KEY definida
 * em components/CookieBanner.jsx. Se um dia mudar lá, mudar aqui também.
 */
const COOKIE_CHOICE_KEY = 'aeg_cookie_choice';

export function hasAdvertisingConsent() {
  try {
    const raw = localStorage.getItem(COOKIE_CHOICE_KEY);
    if (!raw) return false; // ainda não decidiu = sem consentimento, por padrão
    const choices = JSON.parse(raw);
    return choices.advertising === true;
  } catch {
    return false; // qualquer falha ao ler/parsear = tratar como sem consentimento
  }
}
