# Módulo: Autenticação

**Status:** ✅ Concluído (v1.0)
**Referências:** Documento Mestre Seção 12 (`/auth`), 16.1, 16.2, 17 | Manual Partes 3, 4, 5

## Objetivo

Permitir cadastro e login seguros de usuários moçambicanos, vinculados a um número
M-Pesa ou e-Mola, com emissão de tokens JWT e proteção contra fraude e força bruta.

## Regras de negócio implementadas

- Um telefone = uma conta ativa (constraint de unicidade parcial no banco).
- Telefone deve seguir o padrão M-Pesa (84/85) ou e-Mola (86/87) — Seção 16.1.
- Cadastro exige declaração explícita de maioridade e aceite dos Termos de Uso — Seção 17.
- Senhas nunca são armazenadas em texto puro (bcrypt, custo configurável via env).
- Após 5 tentativas de login falhas em 15 minutos, o telefone é temporariamente bloqueado.
- Refresh tokens são armazenados como hash (SHA-256), nunca em texto puro, e rotacionados
  a cada uso (mitiga replay de token roubado).
- Toda ação sensível (registro, login) gera um registro em `audit_logs` (append-only).

## Arquitetura

```
Rota (authRoutes.js)
  -> Middleware: rate limit + validação (Zod)
  -> Controller (authController.js) — sem regra de negócio
  -> Service (authService.js) — toda a lógica de negócio
  -> Repository (authRepository.js) — única camada que toca o banco
```

## Endpoints

### POST /api/v1/auth/register
**Entrada:**
```json
{
  "name": "Maria Chissano",
  "phone": "841234567",
  "password": "senhaForte123",
  "isAdultDeclared": true,
  "termsAccepted": true
}
```
**Saída (201):** `{ status, message, data: { user, accessToken, refreshToken } }`

**Erros possíveis:** 400 (validação), 409 (telefone já cadastrado)

### POST /api/v1/auth/login
**Entrada:** `{ "phone": "841234567", "password": "senhaForte123" }`
**Saída (200):** `{ status, message, data: { user, accessToken, refreshToken } }`
**Erros possíveis:** 400, 401 (credenciais inválidas), 403 (conta banida/suspensa ou
muitas tentativas falhas)

### POST /api/v1/auth/refresh
**Entrada:** `{ "refreshToken": "..." }`
**Saída (200):** novo par de tokens. O token antigo é revogado.
**Erros possíveis:** 401 (token inválido/expirado)

### POST /api/v1/auth/logout
**Entrada:** `{ "refreshToken": "..." }`
**Saída (200):** confirma revogação.

## Dependências

- Banco de dados: tabelas `users`, `refresh_tokens`, `login_attempts`, `audit_logs`, `streaks`.
- Nenhuma dependência de outros módulos de negócio ainda não implementados.

## Limitações conhecidas / próximos passos

- Login social via Google (mencionado na Seção 19.1 do Doc. Mestre) ainda não implementado.
- Validação OTP por SMS (Seção 17, item 3) ainda não implementada — atualmente o cadastro
  cria a conta com status `pending_verification`, mas nada força a verificação ainda.
- Trust Score inicial fixo em 100 para todo novo usuário; regras de variação pertencem
  ao módulo de Trust Score (ainda não implementado).
- Rate limiting é em memória (por processo). Ao escalar para múltiplas instâncias, migrar
  para rate limiting distribuído usando o Redis já configurado em `src/config/redis.js`.
