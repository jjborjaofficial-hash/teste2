# Módulos: Gamificação, Quiz, Missões, Carteira e Trust Score

**Status:** ✅ Concluído (v1.0 — funcionalidade central end-to-end)
**Referências:** Doc. Mestre Seções 4, 5, 7, 9, 11, 12, 16.3, 19.4, 19.5, 19.6 | Manual Partes 3, 4, 5

## Visão geral do fluxo integrado

Esta entrega implementa o "Mapa de Relação entre Módulos" da Seção 4 do Documento Mestre
de ponta a ponta: **Quiz → XP → Streak → Missões → Trust Score → Carteira → Banco de Dados**,
tudo dentro de transações atômicas (uma resposta de quiz nunca deixa o sistema em estado
inconsistente, mesmo em caso de falha no meio do processo).

```
POST /api/v1/quiz/answers
  └─ 1. Valida a alternativa e o tempo de resposta (cronômetro antifraude)
  └─ 2. Registra a tentativa (quiz_attempts)
  └─ 3. Se correta:
        ├─ credita XP (gamification.xpService)
        ├─ atualiza streak diário (gamification.streakService) — pode conceder marco
        └─ atualiza progresso de missões da categoria (missions.incrementProgressForCategory)
  └─ 4. Se resposta suspeita (muito rápida): reduz Trust Score
  └─ COMMIT (tudo ou nada)
```

## Módulo Gamificação (XP, Nível, Streak)

- `GET /api/v1/gamification/me` — retorna XP total, nível atual, pontos e estado do streak.
- **Nível**: fórmula placeholder `nível = piso(xp_total / 500) + 1`, configurável via
  `system_config.level_xp_step`. **Pendente de aprovação oficial** (Seção 23.1.5 do Doc. Mestre
  registra a economia da plataforma como não formalizada).
- **Streak**: implementa a Tabela de Marcos de Ofensiva da Seção 5 (7/15/30/60/100 dias).
  Aos 15 dias concede automaticamente o "item de proteção" que evita a quebra do streak
  uma única vez, conforme especificado.
- ⚠️ Os valores de recompensa de cada marco (pontos e MZN) são **placeholders técnicos**
  armazenados em `system_config` (migration 008), claramente marcados como pendentes de
  aprovação do negócio — não são uma decisão de produto tomada pela IA.

## Módulo Quiz ("O Coração do Sistema" — Seção 19.4)

- `GET /api/v1/quiz/categories` — lista categorias ativas.
- `GET /api/v1/quiz/categories/:categoryId/next-question` — pergunta aleatória, **sem**
  revelar a alternativa correta ao cliente.
- `POST /api/v1/quiz/answers` — submete resposta. O backend é a única autoridade sobre
  correção (Manual Parte 5); o cronômetro é validado no servidor, não confiando no cliente.
- **Antifraude implementado**: se `responseTimeMs` exceder o `time_limit_seconds` da
  pergunta, a resposta é automaticamente considerada errada. Respostas corretas
  submetidas em menos de 400ms reduzem o Trust Score em 5 pontos (heurística simples,
  ajustável — a Seção 20 registra que estratégias antifraude mais avançadas ainda
  precisam ser detalhadas).

## Módulo Missões

- `GET /api/v1/missions` — lista missões do usuário (auto-atribui missões ativas na
  primeira consulta; **nota**: a atribuição via CRON job diário mencionada na Seção 8
  do Doc. Mestre ainda não foi implementada — ver Parte 3 do Manual, "CRON Jobs").
- `POST /api/v1/missions/:userMissionId/claim` — resgata a recompensa de uma missão
  concluída (credita XP/Pontos/MZN). Idempotente: não permite resgate duplo.

## Módulo Trust Score

- `GET /api/v1/trust-score/me` — retorna apenas um **selo qualitativo**
  (`verified_trusted` / `in_good_standing` / `under_review` / `restricted`), nunca o
  valor numérico exato, conforme a regra explícita da ficha técnica do ícone na
  Seção 13.5 ("Não expor valor exato publicamente").
- Todo ajuste é auditado em `trust_score_history` com motivo obrigatório.
- Motivos atualmente implementados: `suspiciously_fast_answer`. Os motivos
  `failed_login_pattern`, `withdrawal_approved` e `manual_admin_adjustment` já estão
  definidos no service, prontos para uso por outros módulos.

## Módulo Carteira

- `GET /api/v1/wallet` — saldo atual em MZN.
- `GET /api/v1/wallet/transactions` — histórico paginado (livro-razão).
- `POST /api/v1/wallet/withdrawals` — solicita saque. Valida, na ordem:
  1. Conta ativa (`status = 'active'`).
  2. Trust Score mínimo (`system_config.min_trust_score_for_withdrawal`, placeholder 60).
  3. Valor mínimo de saque (`system_config.withdrawal_min_mzn` = **100 MZN**, confirmado
     pelo proprietário do projeto — não é mais placeholder).
  4. Ausência de outro pedido "vivo" (anti-duplicidade).
  5. Saldo suficiente.

  ⚠️ **Não existe teto diário de saque.** O usuário pode solicitar quando quiser,
  qualquer valor acima do mínimo. O que existe é um **teto de GANHO diário**
  (`system_config.daily_earning_cap_mzn` = 7,20 MZN), aplicado em `walletService.creditReward`
  sempre que uma missão ou marco de streak credita dinheiro real — isso limita
  quanto o usuário pode *ganhar* por dia, não quanto pode *sacar* de uma vez.
- O saque fica em status `pending_review` — **o processamento real via M-Pesa/e-Mola
  (gateway de pagamento) ainda não está implementado** (Seção 16.3: "o processamento do
  pagamento não é imediato; passa por auditoria antes de ser liberado via integração de
  pagamento" — essa integração externa é um próximo passo, não coberto nesta entrega).

## Dados de exemplo para testar

Rode o seed (não é uma migration, é dado de exemplo apenas para dev/teste):

```bash
psql $DATABASE_URL -f database/seeds/001_sample_content.sql
```

Isso cria 3 categorias, 2 perguntas com alternativas, e 1 missão diária de exemplo.

## Limitações conhecidas / próximos passos

- Cache Redis ainda não é usado nestes módulos (ex: ranking e perfil deveriam ser
  cacheados — Manual Parte 3). A conexão já está pronta em `src/config/redis.js`.
- Ranking Semanal: tabela `weekly_rankings` já existe (migration 007), mas o job que
  a popula (CRON semanal) ainda não foi implementado.
- Integração real com gateway de pagamento M-Pesa/e-Mola para liberar saques: pendente.
- Login social via Google e validação OTP: pendentes (já registrados no módulo de
  Autenticação).
- Painel Administrativo para aprovar/rejeitar saques manualmente: pendente.
