# Animações de Ícones (Seção 13.6 do Doc. Mestre)

**Status:** ✅ Concluído — as 10 animações da tabela oficial, ligadas a lugares reais do app.
**Referências:** Doc. Mestre Seção 13.5 (construção dos ícones) e 13.6 (tabela de animações)

## O que existia antes desta entrega

15 ícones SVG inline (stroke-based, seguindo a regra de construção da Seção
13.5), mas **sem nenhuma das animações específicas** da tabela 13.6 realmente
ligadas a eles — só 2 efeitos CSS genéricos (`pop-in`, `gentle-swing`) usados
em 3 lugares soltos.

## O que foi implementado

Cada ícone agora aceita props que ligam a animação exata da tabela oficial,
sempre desativada por padrão onde faz sentido ser condicional (só anima quando
algo aconteceu de verdade), e sempre ativa onde a tabela pede loop contínuo.

| Elemento (Seção 13.6) | Animação oficial | Prop no componente | Onde está ligada |
|---|---|---|---|
| XP | Preenchimento sobe ao ganhar; rotação ao completar nível | `<XpIcon pulse levelUp />` | `QuizResult.jsx` — `levelUp` vem do backend (`result.leveledUp`, novo campo) |
| Resposta correta | Check desenha-se | `<CheckIcon animated />` | `QuizResult.jsx` — usa `pathLength=1` no SVG para o traço sempre desenhar 0→100% |
| Resposta incorreta | X desenha-se em vermelho suave | `<CloseDrawIcon animated />` | `QuizResult.jsx` (novo ícone, separado do `CloseIcon` estático usado no Toast) |
| Troféu/Conquista | Brilho pulsante | `.animate-glow-pulse` (loop) | `RewardBadge` (prop `isNew`) e card de marco de streak |
| Conquista | Confete suave | `.animate-confetti` ×4, cascata | `RewardBadge` (prop `isNew`) |
| Streak (chama) | Chama oscila, loop suave | `<FireIcon animate>` (padrão `true`) | Dashboard e Tela de Resultados |
| Loading | Rotação contínua | *(não aplicável ainda — não há spinner de loading dedicado)* | — |
| Notificação | Leve balanço | `<NotificationIcon hasUnread />` | Dashboard e `AdminLayout` (sino no header) |
| Carteira | Impulso (scale) ao receber valor | `<WalletIcon impulse />` | `QuizResult.jsx`, quando um marco de streak credita MZN |
| Missão | Pulso leve quando há nova | `<MissionsIcon hasNew />` | Dashboard, ao lado do título "Missões Diárias" |
| Barra de XP | Preenchimento atualiza suavemente | já existia (`XpProgressBar`, `duration-xp` = 600ms) | Dashboard |
| Ranking | Barras crescem em stagger | `<RankingIcon animateIn>` (padrão `true`) | Tela de Ranking |
| Trust Score | Preenchimento sobe conforme score; transição suave | `<TrustShieldIcon badge={badge} />` | `Profile.jsx` |
| Configurações | Rotação suave só no toque, sem loop | `<SettingsIcon spinKey={n} />` | `Profile.jsx`, botão de engrenagem no topo do perfil |

## Decisões técnicas que valem explicar

### "Rotação ao completar nível" precisou de um dado novo do backend
O frontend não tinha como saber se um usuário "acabou de subir de nível" — só
recebia o nível atual. Adicionei `leveledUp` em `xpService.addXpAndPoints`
(compara o nível antes e depois do crédito de XP) e propaguei até a resposta
de `POST /quiz/answers`. Sem isso, a animação de rotação só poderia ser
"chutada" no frontend, o que violaria a regra de o backend ser a autoridade
sobre o estado do jogo.

### Traço de "check"/"X" via `pathLength="1"`
Em vez de calcular `stroke-dasharray` manualmente para cada ícone (o que exige
saber o comprimento exato do traço SVG, calculado em pixels), usei o atributo
`pathLength="1"` do SVG — ele normaliza o comprimento do traço para sempre
valer 1, então a animação `stroke-dashoffset: 1 -> 0` funciona identicamente
não importa a geometria real do ícone. Solução mais robusta e fácil de manter
do que valores mágicos por ícone.

### Trust Score: preenchimento por faixa, não por valor exato
A Seção 13.5 proíbe expor o valor exato do Trust Score publicamente. Por isso
o preenchimento visual do `TrustShieldIcon` usa a mesma faixa qualitativa que
já existia no backend (`restricted` / `under_review` / `in_good_standing` /
`verified_trusted`), mapeada para um percentual aproximado de preenchimento —
nunca o número real.

### Item da tabela que ficou sem lugar: "Loading — rotação contínua"
Não implementado porque **não existe um componente de spinner/loading
dedicado no app ainda** — os estados de carregamento hoje são só texto
("Carregando..."). Fica registrado como pendência: se um spinner visual for
adicionado no futuro, a classe `animate-spin` do próprio Tailwind já resolve
isso (não precisa de nova animação customizada).

## Correção adicional: visibilidade dos Pontos (bug funcional, não estético)

Durante uma revisão de identidade visual, foi identificado que a moeda
**Pontos** (Doc. Mestre Seção 5 — "Economia de Duas Moedas": Pontos é diferente
de XP) existia desde o início no banco de dados e na API
(`gamification.pointsBalance`), mas **nunca aparecia em nenhuma tela do app**.
Um usuário podia acumular Pontos via missões, marcos de streak e indicações,
sem nunca conseguir ver esse saldo em lugar nenhum.

**Corrigido:**
- Novo ícone `PointsIcon` (moeda com aro interno, deliberadamente diferente do
  raio/estrela do `XpIcon`, para não serem confundidos).
- Dashboard agora mostra 3 cartões (Saldo MZN / Nível+XP / Pontos), em vez de 2.
- Tela de Resultados agora mostra Pontos ganhos em marcos de streak (o backend
  já calculava `pointsGranted`, só não estava sendo exibido).

## Ícone que faltava na ficha técnica: Conquistas/Medalhas

A Seção 13.5 lista 12 famílias oficiais de ícone; 11 já existiam, faltava
"Conquistas/Medalhas" (medalha com fita). Criado como `AchievementIcon`, com a
animação da Seção 13.6 ("Confete leve + brilho pulsante") embutida via prop
`isNew`. Usado agora no card de marco de streak na Tela de Resultados.

## Limitações conhecidas


- As animações de ícone dependem de `prefers-reduced-motion` (já tratado
  globalmente em `index.css` desde a entrega do Design System) — usuários que
  pedem menos movimento no sistema operacional recebem versões estáticas
  automaticamente, sem precisar de nenhuma lógica extra por ícone.
- A "identidade visual única" (traço/estilo distintivo de marca, além da regra
  técnica de construção) **continua não implementada** — isso ficou
  deliberadamente fora desta entrega, que tratou só das animações (Parte 2 da
  pergunta original). Fica disponível para uma próxima rodada se for do
  interesse do proprietário do projeto.
