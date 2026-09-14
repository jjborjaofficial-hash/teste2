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
- **Pontos por acerto (migration 029 — antes uma lacuna crítica):** até a migration
  029, `quizService.submitAnswer` chamava `xpService.addXpAndPoints` com
  `pointsDelta: 0` fixo no código — o Quiz dava XP, mas **nunca** dava Pontos. Como o
  Quiz é a atividade mais frequente da plataforma e Missões/Streak/Indicação eram as
  únicas fontes de Pontos, isso deixava a Loja e a conversão Pontos→Dinheiro
  (migration 028) praticamente inacessíveis para quem só joga quiz. Corrigido usando
  exatamente a tabela de exemplo já documentada (Seção 5.9-B): fácil = 10 Pontos,
  médio = 25, difícil = 50 (configurável via `system_config.quiz_points_reward_*`,
  aplicado por cima da coluna `difficulty` que já existia em `questions`). Passa pelo
  mesmo teto diário de Pontos e mesmo Coin Boost 2x já usados por Missões/Streak
  (`xpService.addXpAndPoints`), sem nenhuma lógica nova de cap.
  ⚠️ **Não implementado** (sem valor de exemplo definido na documentação): o "bônus de
  pontos por sequência de acertos" citado na mesma Seção 5.9-B — fica registrado como
  pendência de decisão de negócio, não implementado por falta de fórmula/valor oficial.

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

### Conversão de Pontos em Dinheiro (migration 028)

Anteriormente, a taxa "1.000 Pontos = 10 MZN" existia **só como exemplo** nos documentos
de brainstorm (Seção 6.1 / Seção 5.9-B), explicitamente marcada como provisória
("os valores precisam ser calculados... ainda não são valores finais"). Não havia
rota, serviço nem tabela que de fato convertesse Pontos em MZN — só a Loja
(`shop_items`), que gasta Pontos em itens funcionais/cosméticos, nunca em dinheiro.

Esta migration ativa a conversão de verdade, usando exatamente a taxa do exemplo
como valor vigente (configurável, não fixo no código):

- `GET /api/v1/wallet/convert-points/rate` — retorna a taxa atual
  (`points_conversion_rate_points` / `points_conversion_rate_mzn`), para o frontend
  nunca precisar cravar o número.
- `POST /api/v1/wallet/convert-points` — converte Pontos em MZN. Valida, na ordem:
  1. Quantidade inteira e positiva.
  2. Conta ativa.
  3. Trust Score mínimo (`system_config.min_trust_score_for_conversion`, mesmo
     racional do saque — Manual Parte 7).
  4. Múltiplo exato da taxa vigente (mesma lógica do exemplo: só blocos "fechados",
     nunca uma fração esquisita de Pontos).
  5. **Conta para o mesmo teto de GANHO diário do saque** (`daily_earning_cap_mzn`,
     7,20 MZN) — decisão explícita para fechar a pergunta em aberto da Seção 6.2
     ("existe limite diário de conversão?"): sem isso, o teto de ganho vira
     decorativo, bastando acumular Pontos e converter tudo de uma vez.
- Debita `points_ledger` (source `points_conversion`) e credita `wallet_transactions`
  (source `points_conversion`) na mesma transação — mesmo padrão de
  `walletService.requestWithdrawal`/`shopService.purchase`.
- Gera notificação `points_converted` ao usuário.
- Correção incidental: ao recriar a constraint de tipos de notificação, restaurou-se
  `withdrawal_sla_risk`, removido por engano na migration 027.

**Continua em aberto (decisão de negócio, não técnica):** o valor exato da taxa
(hoje 100 Pontos = 1 MZN) segue sem uma planilha de sustentabilidade financeira
(receita de anúncios vs. custo de recompensas) formalizada — ver Recomendação do
Arquiteto nº 15 no documento "Aprenda-e-Ganhe-Documentao-Oficial". Recalibrar é só
atualizar `system_config`, sem deploy.

**Conflito entre documentos oficiais — RESOLVIDO por decisão explícita (não é bug):**
O documento "SISTEMA DE ECONOMIA E RECOMPENSAS" (recebido depois desta migration)
define três recursos separados — XP, Moedas Virtuais e MZN — e afirma que *"Moedas
virtuais NÃO podem ser sacadas. Moedas virtuais NÃO possuem valor financeiro
direto."* Isso contradiz diretamente a conversão Pontos → MZN acima, já que
"Pontos" nesta plataforma cumpre o mesmo papel que aquele documento chama de
"Moedas Virtuais" (moeda ganha em missões/quiz, gasta na Loja).

Apresentado o conflito ao proprietário do projeto: **decisão foi manter a
conversão como está e avaliar o resultado na prática**, em vez de removê-la para
seguir a restrição literal daquele documento. Isso não é uma inconsistência do
código — é uma divergência consciente entre dois documentos de referência, com a
decisão de negócio já tomada pelo dono do projeto. Não reabrir esta discussão sem
pedido explícito dele.

## Dados de exemplo para testar

Rode o seed (não é uma migration, é dado de exemplo apenas para dev/teste):

```bash
psql $DATABASE_URL -f database/seeds/001_sample_content.sql
```

## Conteúdo real de perguntas (não é dado de teste)

Diferente do `001_sample_content.sql` acima (2 perguntas, só para
desenvolvimento), `database/seeds/003_tecnologia_facil.sql` é **conteúdo
editorial de verdade**, fornecido pelo proprietário do projeto: 50 perguntas
de Tecnologia, nível Fácil. Pode (e deve) ser rodado em produção:

```bash
psql $DATABASE_URL -f database/seeds/003_tecnologia_facil.sql
```

Idempotente (usa `questions.source = 'seed_tecnologia_facil_v1'` como
marcador — rodar de novo não duplica nada).

**Correção de qualidade aplicada, registrada no próprio arquivo:** no lote
original, as 50 respostas corretas eram todas a alternativa "A". Isso foi
corrigido redistribuindo a posição da resposta certa (~13/13/12/12 entre
A/B/C/D, com seed fixa e reprodutível) — o conteúdo pedagógico em si não foi
alterado, só a ordem de exibição de cada alternativa.

**Ainda faltam**, deste mesmo lote de conteúdo: perguntas de Tecnologia nível
médio/difícil, e as 4 categorias restantes (Finanças, IA, Marketing Digital,
Produtividade) em todos os níveis — hoje só Tecnologia/Fácil tem volume real.

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
