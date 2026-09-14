# Módulo: Painel Administrativo + Lacunas da Seção 20

**Status:** ✅ Concluído — API + interface visual (React) + papéis granulares +
filas/scheduler automático (ver nota de atualização abaixo)
**Referências:** Doc. Mestre Seção 20, 23.1 | Manual Parte 3 (módulo oficial), Parte 5

## Módulo Admin

Todas as rotas abaixo exigem **autenticação + papel `admin`** (`role = 'admin'` na tabela
`users`, migration 011). Nenhum usuário é promovido a admin automaticamente — isso é uma
ação operacional deliberada (ver `database/seeds/002_promote_admin.sql`).

⚠️ **Importante**: o papel do usuário é gravado no JWT no momento do login. Se você
promover alguém a admin via banco enquanto a sessão já existe, a pessoa precisa
fazer login novamente para que o novo papel tenha efeito.

### Saques
| Rota | Descrição |
|---|---|
| `GET /api/v1/admin/withdrawals` | Lista saques com status `pending_review` |
| `POST /api/v1/admin/withdrawals/:id/approve` | Aprova, confirma o lançamento no ledger, notifica o usuário |
| `POST /api/v1/admin/withdrawals/:id/reject` | Rejeita, **estorna o valor** (novo lançamento de crédito, nunca edita o lançamento original — Manual Parte 4: ledger imutável), notifica o usuário |

### Usuários
| Rota | Descrição |
|---|---|
| `GET /api/v1/admin/users?search=` | Lista/busca usuários por nome ou telefone |
| `POST /api/v1/admin/users/:id/trust-score/adjust` | Ajuste manual de Trust Score, com motivo obrigatório |
| `POST /api/v1/admin/users/:id/status` | Muda status (`active`/`suspended`/`banned`) |

### Auditoria
| Rota | Descrição |
|---|---|
| `GET /api/v1/admin/audit-logs?userId=` | Consulta os logs append-only já gravados desde o módulo de Autenticação |

**Toda ação administrativa acima gera seu próprio registro em `audit_logs`**, incluindo
quem fez (`adminUserId`), o quê, e com qual motivo — nenhuma ação de admin é silenciosa.

## Lacunas da Seção 20 fechadas nesta entrega

| Lacuna original (Seção 20) | O que foi feito |
|---|---|
| CRON Jobs pendentes | `assignDailyMissions.js` e `expireMissions.js` adicionados a `src/cron/jobs/` |
| Rate limiting (listado em "Segurança") | Migrado de memória local para **Redis compartilhado** (`rate-limit-redis`), com fallback automático para memória se o Redis cair |
| Auditoria em ações sensíveis | Toda ação do módulo Admin grava em `audit_logs` via `common/repositories/auditLogRepository.js` (novo repositório compartilhado, evita duplicação) |

## Lacunas da Seção 20 que continuam pendentes (fora do escopo desta entrega)

- **Filas (Queues) e Scheduler automático**: ✅ **fechado numa entrega posterior** —
  ver `src/queue/` (BullMQ + Redis). `npm run worker` agenda e executa todos os
  jobs de `src/cron/jobs/` internamente, sem depender de um agendador externo.
  Os scripts continuam podendo ser rodados manualmente (`node src/cron/jobs/x.js`)
  para depuração local.
- **Rotação de credenciais expostas** (Seção 23.2.1): ação operacional, não é código.

> ⚠️ **Nota de atualização (documentação estava desatualizada):** as duas linhas
> abaixo, presentes numa versão anterior deste documento, não refletem mais o
> estado real do código — mantidas aqui riscadas por rastreabilidade, não como
> pendência:
> - ~~Autenticação/autorização entre módulos internos: hoje a autorização é só
>   usuário-vs-admin~~ → **resolvido**: migration 012 introduziu papéis
>   granulares (`admin_master`, `admin_financeiro`, `admin_suporte`, e depois
>   `admin_juridico` na migration 016), aplicados rota a rota via
>   `middleware/requireRole.js`.
> - ~~Painel Administrativo — interface visual: esta entrega é só a API~~ →
>   **resolvido**: existe uma UI completa em React (`frontend/src/pages/admin/`,
>   14 páginas, ~1.700 linhas), com guarda de papel também no frontend
>   (`router/RequireAdminRole.jsx`), espelhando as mesmas regras do backend.

## Nota técnica: `assignDailyMissions.js`

A primeira versão deste job iterava usuário × missão fazendo uma query por combinação,
o que não escalaria (500.000 queries para 100.000 usuários × 5 missões). Antes de
finalizar esta entrega, isso foi revisado e reescrito como um único
`INSERT ... SELECT` (produto cartesiano usuários ativos × missões ativas, com
`ON CONFLICT DO NOTHING`) — uma única operação de banco, independente do número de
usuários. Isso segue o princípio do Manual Parte 1: revisar a solução *antes* da
entrega, não depois, quando a resposta para "isso aguenta centenas de milhares de
usuários?" é não.
