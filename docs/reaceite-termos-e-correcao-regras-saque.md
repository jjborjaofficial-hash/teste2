# Reaceite de Termos + Correção das Regras de Saque

**Status:** ✅ Concluído
**Referências:** decisões do proprietário do projeto (esta conversa)

## 1. Mecanismo de reaceite de Termos de Uso

Antes: o checkbox de aceite só existia no cadastro (Seção 17 do Doc. Mestre). Se os
Termos mudassem depois, usuários antigos nunca eram forçados a reaceitar.

**Agora implementado:**
- `users.terms_version` guarda qual versão o usuário aceitou por último.
- `authService.TERMS_VERSION` é a versão vigente (constante no código — subir a
  versão aqui é o gatilho para forçar reaceite em massa).
- `GET /users/me` retorna `needsTermsReacceptance: true/false`, comparando as duas.
- Novo endpoint `POST /auth/accept-terms` (autenticado) grava o reaceite.
- Frontend: `ProtectedRoute` intercepta **qualquer** rota protegida e redireciona
  para `/reaceitar-termos` se `needsTermsReacceptance` for true — o app fica
  bloqueado até o usuário marcar o checkbox e confirmar (mesmo padrão visual do
  cadastro: checkbox desmarcado por padrão, links para Termos/Privacidade).

**Como testar:** mude `TERMS_VERSION` em `authService.js` (ex: de `'1.0'` para
`'1.1'`), reinicie o backend. Qualquer usuário já logado será redirecionado para
a tela de reaceite na próxima navegação.

## 2. Correção das regras econômicas de saque

O proprietário do projeto esclareceu que a implementação anterior estava com os
valores trocados:

| Regra | Antes (errado) | Agora (correto) |
|---|---|---|
| Saque mínimo | 7,20 MZN | **100 MZN** |
| Teto diário | 7,20 MZN de **saque** | 7,20 MZN de **ganho** (missões/streak) |
| Teto de saque | Existia | **Não existe** — saque livre acima do mínimo |

### O que mudou no código
- `system_config.withdrawal_min_mzn` → `100.00` (migration 015)
- `system_config.withdrawal_daily_cap_mzn` renomeado para `daily_earning_cap_mzn`
  (mesma migration) — deixa claro que é sobre ganho, não sobre saque
- `walletService.requestWithdrawal`: removida a checagem de teto diário de saque
  (`sumWithdrawalsToday` foi removida do repository)
- `walletService.creditReward`: agora aplica o teto de ganho diário automaticamente
  — se uma missão ou marco de streak tentar creditar mais do que resta do teto do
  dia, o valor é reduzido para caber (nunca creditamos além do teto). Isso é
  centralizado numa única função, então nenhum outro módulo precisa se preocupar
  com essa regra.

### Regra reforçada em todos os lugares visíveis ao usuário
> O usuário **nunca** deposita ou transfere dinheiro para a plataforma. A
> plataforma **nunca** cobra valor monetário de ninguém.

Isso agora aparece explicitamente em:
- Tela de Cadastro (subtítulo)
- Tela de Carteira (banner verde de destaque, acima do formulário de saque)
- Termos de Uso (Seção 4, em negrito)
- Como Funciona (passo 5)
- FAQ (primeira pergunta)

## Limitações que continuam

- O texto das políticas ainda não passou por revisão jurídica formal.
- Não há alerta automático se o teto de ganho diário for atingido (o usuário só
  percebe que ganhou menos do que o esperado olhando o histórico da Carteira).
  Poderia virar uma notificação futura: "Você atingiu seu teto de ganho hoje."
