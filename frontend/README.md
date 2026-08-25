# Aprenda e Ganhe — Frontend Web

Interface web mobile-first, construída em conformidade com o Design System (Seção 13)
e o Sitemap (Seção 19) do `Documento Mestre Consolidado v1.0`.

## Stack

- **React 18 + Vite** — build rápido, componentização
- **React Router 6** — navegação
- **Tailwind CSS** — mapeado 1:1 aos tokens da Seção 13 (`tailwind.config.js`)
- Fontes **Inter** (corpo/UI) e **Poppins** (display), carregadas via Google Fonts

## Como rodar localmente

```bash
cd frontend
npm install
cp .env.example .env
# edite .env se o backend não estiver em http://localhost:3000
npm run dev
```

Abre em `http://localhost:5173`. **Pré-requisito**: o backend (`../backend`) precisa
estar rodando e com as migrations aplicadas (ver README do backend).

## Telas implementadas (Seção 19 do Doc. Mestre)

| Seção | Tela | Rota |
|---|---|---|
| 19.1 | Onboarding Persuasivo (3 slides + bifurcação + prova social) | `/onboarding` |
| 19.1 | Login | `/entrar` |
| 19.1 / 17 | Cadastro (com Check-in Jurídico obrigatório) | `/cadastro` |
| 19.2 | Painel Principal (Dashboard) | `/dashboard` |
| 19.3 | Hub de Estudos (categorias) | `/hub-estudos` |
| 19.4 | Quiz Ativo (cronômetro, foco absoluto, sem nav/rodapé) | `/quiz/:categoryId` |
| 19.5 | Tela de Resultados (com intersticial de anúncio) | `/quiz/:categoryId/resultado` |
| 19.6 | Carteira (saldo, saque, histórico) | `/carteira` |
| 19.7 | Perfil e Configurações (selo de Trust Score, logout) | `/perfil` |
| 9 | Ranking Semanal | `/ranking` |
| 16 / 18 | Termos, Privacidade, Recompensas, Como Funciona, Suporte | `/termos`, `/privacidade`, `/recompensas`, `/como-funciona`, `/suporte` |

Design System aplicado: cores, tipografia, espaçamento, componentes oficiais
(Botão Primário, Card, Badge de Recompensa, Barra de Progresso XP, Toast),
sistema de ícones (SVG inline, stroke-based) e acessibilidade (Seção 13.7:
`prefers-reduced-motion`, foco visível, área de toque mínima 44×44px).

## Limitações conhecidas / próximos passos

- **"Continuar com o Google"** (login social, mencionado na Seção 19.1): não
  implementado. O botão de cadastro atual é só telefone + senha.
- **Validação OTP por SMS** (Seção 17, item 3): não implementada no frontend
  (o backend também ainda não força isso — ver docs do backend).
- **Anúncios**: todos os 4 espaços de anúncio (Banner Nativo, Feed Ad, Intersticial,
  Banner Rodapé) são **placeholders visuais**. Nenhuma integração real com
  AdSense/AdCash/efficientcpmnetwork foi feita — isso depende de contrato e
  credenciais reais com essas redes.
- **Teto de saque fixo no frontend** (`WITHDRAWAL_CAP_MZN` em `Wallet.jsx`): hoje é
  um valor espelhado manualmente do placeholder do backend
  (`system_config.withdrawal_daily_cap_mzn`). Se um admin mudar esse valor no banco,
  o frontend não vai refletir automaticamente — falta um endpoint público de
  configuração para isso ser dinâmico.
- **Painel Administrativo**: sem interface — só a API existe (ver backend).
- **PWA / instalável**: não configurado (sem manifest.json nem service worker).
- **Testes automatizados de frontend**: não incluídos nesta entrega (o backend
  tem testes de integração; o frontend ainda não).

## Estrutura de pastas

```
frontend/
  src/
    api/            -- cliente HTTP + funções por domínio (auth, quiz, wallet...)
    context/         -- AuthContext (sessão do usuário)
    components/      -- Button, Card, RewardBadge, XpProgressBar, Toast, BottomNav, Footer
    icons/            -- sistema de ícones SVG inline (Seção 13.5)
    layouts/           -- AppLayout (com nav/rodapé) e FocusLayout (quiz, sem distrações)
    pages/              -- uma tela do Sitemap por arquivo
    router/              -- ProtectedRoute
  tailwind.config.js      -- tokens de design (cores, tipografia, espaçamento)
  index.html
```
