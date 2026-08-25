# Fluxo de Saque Manual, Permissões Granulares e Painel Admin Visual

**Status:** ✅ Concluído
**Referências:** Doc. Mestre Seção 16.3, 19.6 | Manual Parte 3 (Painel Administrativo) | decisão do proprietário do projeto sobre pagamento manual

## Fluxo de saque (decisão de negócio confirmada)

Não há integração automática com gateway de pagamento M-Pesa/e-Mola. O pagamento é
**manual**, feito pelo proprietário do projeto. O sistema reflete isso em 3 estados:

```
1. Usuário solicita saque
   -> valida política (valor mínimo, teto diário, Trust Score)
   -> debita o valor do saldo (ledger)
   -> status: pending_review
   -> usuário recebe notificação IMEDIATA: "o valor estará na conta em até 24h"
   -> admin_financeiro recebe notificação: "novo pedido de X"

2. Admin financeiro revisa e aprova (ou rejeita)
   -> aprovar: confirma o lançamento no ledger, status: approved
   -> rejeitar: estorna o valor automaticamente, exige motivo, status: rejected

3. Admin financeiro transfere o dinheiro MANUALMENTE (fora do sistema) via
   M-Pesa/e-Mola para o número já cadastrado na conta do usuário (Seção 16.1)
   -> depois de transferir de fato, clica "Marcar como pago"
   -> status: paid
   -> usuário recebe notificação: "saque pago com sucesso"
```

### Por que a notificação de 24h é disparada ANTES da aprovação?

Decisão deliberada: o usuário precisa de uma resposta imediata e tranquilizadora
assim que solicita (evita ansiedade / mensagens de suporte perguntando "cadê meu
dinheiro"), mesmo sabendo que o processamento real é manual e pode variar. Por isso
o SLA de 24h é comunicado no ato do pedido, não depois da aprovação.

⚠️ **Importante**: 24h é um compromisso operacional, não uma garantia técnica do
sistema — se o processo manual demorar mais que isso na prática, ajuste o texto em
`notificationsService.notifyWithdrawalRequested` para refletir a realidade.

## Endpoints novos/alterados

| Rota | Papel exigido | Descrição |
|---|---|---|
| `GET /api/v1/admin/withdrawals?status=pending_review\|approved` | `admin_financeiro` | Lista por status (antes só listava pendentes) |
| `POST /api/v1/admin/withdrawals/:id/mark-paid` | `admin_financeiro` | Novo — fecha o ciclo depois da transferência manual |

## Permissões granulares de admin (migration 012)

Papel binário `user`/`admin` foi substituído por 4 valores:

| Papel | Acesso |
|---|---|
| `user` | Nenhum acesso admin (padrão) |
| `admin_master` | Acesso total — inclusive gestão de papéis de outros admins |
| `admin_financeiro` | Só saques (`/admin/withdrawals/*`) |
| `admin_suporte` | Só usuários e Trust Score (`/admin/users/*`) |

Auditoria (`/admin/audit-logs`) é acessível a `admin_financeiro` e `admin_suporte`
(é só leitura, útil para investigação cruzada).

Novo endpoint `POST /admin/users/:id/role` — **exclusivo `admin_master`** — promove
ou rebaixa o papel de qualquer usuário. Tem uma proteção: um `admin_master` não
consegue remover o próprio acesso master (evita ficar trancado para fora sem ninguém
para reverter).

⚠️ **Lembrete operacional**: o papel é gravado no JWT no login. Trocar o papel de
alguém exige que a pessoa faça login novamente para o novo papel valer.

## Painel Admin — interface visual (nova)

Antes só existia a API. Agora existe uma interface web em `/admin`, com layout e
navegação próprios (deliberadamente fora do Sitemap da Seção 19, que é 100% do
usuário final):

- `/admin/saques` — duas abas: "Pendentes de revisão" (aprovar/rejeitar) e
  "Aguardando transferência" (marcar como pago depois da transferência manual)
- `/admin/usuarios` — busca, ajuste de Trust Score, mudança de status; troca de
  papel administrativo só aparece para quem é `admin_master`
- `/admin/auditoria` — consulta de logs
- `/admin/notificacoes` — alertas de novos saques (sino com contador no header)

Cada item de navegação só aparece se o papel do admin logado tiver acesso àquela
área — `admin_financeiro` não vê "Usuários", `admin_suporte` não vê "Saques".

## Como testar o fluxo completo

```bash
# 1. Promover um usuário a admin_financeiro (edite o telefone antes)
psql $DATABASE_URL -f backend/database/seeds/002_promote_admin.sql

# 2. Como usuário comum: solicitar um saque pelo app (/carteira)
#    -> confira a notificação recebida em /notificacoes

# 3. Login com o usuário admin_financeiro -> /admin
#    -> confira o alerta em /admin/notificacoes
#    -> aprove em /admin/saques (aba "Pendentes de revisão")
#    -> vá para a aba "Aguardando transferência", transfira de verdade via
#       M-Pesa/e-Mola, depois clique "Marcar como pago"

# 4. Volte como o usuário comum -> confira a notificação de saque pago
```

## Lacunas fechadas contra o documento "Sistema de Saques v1.0" (revisão adicional)

Depois de comparar a implementação com o documento oficial ponto a ponto, foram
identificadas e fechadas 6 lacunas:

1. **Conta ativa**: `requestWithdrawal` agora verifica `status = 'active'` antes de
   aceitar o pedido (documento: "Conta do usuário ativa e em conformidade").
2. **Anti-duplicidade**: um usuário não pode ter mais de um pedido "vivo"
   (`pending_review`/`approved`/`suspended_for_review`) ao mesmo tempo — garantido
   por checagem prévia (mensagem amigável) **e** por índice único parcial no banco
   (`uq_withdrawal_one_active_per_user`, migration 014) como rede de segurança
   contra condição de corrida.
3. **Status faltantes**: adicionados `cancelled` e `suspended_for_review`
   (documento: "Cancelado" e "Suspenso para verificação"), com as ações de admin
   correspondentes ("Suspender para revisão" e "Cancelar").
4. **Dossiê completo do administrador** (`GET /admin/withdrawals/:id`): e-mail,
   saldo atual, Trust Score atual, situação da conta, data de criação, **último
   acesso** (novo campo `users.last_login_at`, atualizado a cada login), histórico
   completo de saques do usuário, e uma contagem de "alertas" (proxy: número de
   reduções de Trust Score já registradas — não existe um sistema de denúncias
   separado ainda, então isso é uma aproximação documentada).
5. **Administrador responsável no próprio registro**: `withdrawal_requests.resolved_by_admin_id`
   agora é gravado em toda transição de status (aprovar/rejeitar/suspender/cancelar/pagar).
6. **Mensagens alinhadas ao texto oficial**: as notificações de solicitação, alerta
   ao admin e confirmação de pagamento foram reescritas para seguir o texto do
   documento quase literalmente (pequenas adaptações de formatação).

### Decisão sobre o timing do débito (item 7 da análise)

O documento, na Seção 8, sugere que o saldo só seria atualizado depois do pagamento
confirmado. **Mantivemos o comportamento já implementado: o saldo é debitado no
momento do PEDIDO** (não do pagamento), com estorno automático em caso de rejeição
ou cancelamento. Motivo: isso resolve a duplicidade de forma nativa (o dinheiro já
não está mais "disponível" para um segundo pedido enquanto o primeiro está em
análise) e é a prática padrão em sistemas financeiros com livro-razão. Se essa
decisão for revista no futuro, ela precisa vir acompanhada de uma trava adicional
contra pedidos duplicados gastando o mesmo saldo simultaneamente.

## Limitações que continuam

- Nenhuma integração automática de pagamento — tudo depende do admin financeiro
  agir manualmente nos passos 2 e 3.
- O SLA de 24h é só uma mensagem — não há alerta automático se o admin demorar
  mais que isso para processar (poderia virar um CRON job futuro: "saques
  aprovados há mais de 20h sem pagamento").
