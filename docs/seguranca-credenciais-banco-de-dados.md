# Gestão de Credenciais do Banco de Dados e Rotação de Segurança

## Categoria
Segurança da Plataforma

## Status
✅ Implementado nesta entrega (código) · ⚠️ Ações operacionais marcadas abaixo
ainda dependem de execução manual em cada ambiente (não são automatizáveis
dentro do repositório).

Este documento traduz a especificação oficial de gestão de credenciais para a
realidade concreta desta stack (Node/Express + PostgreSQL + Redis, Docker
local, deploy no Render). Sempre que a especificação original pedia algo
puramente processual (ex: "gerar nova senha no provedor"), este documento diz
exatamente onde e como fazer isso nesta stack.

---

## 1. Objetivo

Proteger a comunicação entre o backend do Aprenda e Ganhe e o banco de dados
contra acesso não autorizado — a mesma conexão que carrega dados pessoais,
saldos em MZN, histórico de recompensas, saques, respostas de quiz e dados
administrativos (ver `docs/politicas-plataforma-organizadas.md` para o que
cada um desses dados representa em termos de LGPD/privacidade).

## 2. Princípio Fundamental — já implementado

Nenhuma credencial vive no código-fonte. `backend/src/config/database.js` lê
exclusivamente de `process.env.DATABASE_URL`, e agora **falha alto e cedo** se
essa variável não existir, em vez de deixar o pool tentar conectar a
`undefined` silenciosamente:

```js
if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL não definida...');
}
```

`.gitignore` já exclui `.env` na raiz do backend — confirme que isso vale
também para qualquer `.env.local`, `.env.production` etc. que você criar.

## 3. Armazenamento Seguro — já implementado

✅ Nenhuma senha/chave hardcoded em nenhum módulo (`grep -r "password.*=.*['\"]"`
no código não deve retornar nada fora de testes/exemplos).
✅ `.env.example` documenta todas as variáveis necessárias sem conter valores
reais.

⚠️ **Ação operacional (fora do código):** em produção, as credenciais devem
viver exclusivamente nas variáveis de ambiente do provedor (painel do Render,
ou o gerenciador de segredos que você escolher — ex: Render Environment
Groups, Doppler, AWS Secrets Manager). Nunca em um arquivo `.env` dentro do
servidor de produção que possa vazar por backup ou acesso indevido ao disco.

## 4. Separação de Ambientes

| Ambiente | Banco | Onde configurar nesta stack |
|---|---|---|
| Desenvolvimento | `docker-compose.yml` local (`aprenda-e-ganhe-db`) | `.env` local, nunca commitado |
| Staging | Banco Postgres separado no Render (ou outro provedor) | Variáveis de ambiente do serviço "staging" no Render |
| Produção | Banco Postgres separado, credenciais exclusivas | Variáveis de ambiente do serviço "produção" no Render |

⚠️ **Ação operacional:** hoje o repositório só define `docker-compose.yml`
para desenvolvimento local. Staging e Produção precisam ser criados como
serviços PostgreSQL distintos no provedor escolhido — nunca reaproveite o
mesmo banco entre ambientes, mesmo temporariamente.

## 5. Processo de Rotação de Credenciais

**Quando rotacionar:** suspeita de exposição, troca de equipe técnica,
incidente de segurança, ou por política interna (recomenda-se, no mínimo, a
cada 90 dias em produção).

Passo a passo nesta stack (exemplo usando Render, adapte para o seu provedor):

1. **Criar novas credenciais** — no painel do banco Postgres do provedor,
   gere uma nova senha para o usuário `database_api` (ver Seção 7). Não
   reutilize senhas antigas.
   - Se ainda não existirem os papéis `database_api`/`database_readonly`,
     rode primeiro `backend/database/security/create_db_roles.sql` (uma
     única vez, com o usuário administrador do banco).
2. **Atualizar o Backend** — no painel de variáveis de ambiente do serviço
   Web no Render, atualize `DATABASE_URL` com a nova senha. Não edite o
   `.env` de produção manualmente por SSH quando existir um painel de
   variáveis de ambiente gerenciado — use sempre o painel, que mantém
   histórico e evita edição manual desalinhada.
3. **Reiniciar os serviços** — o Render reinicia automaticamente o serviço ao
   salvar novas variáveis de ambiente. Confirme isso no log de deploy.
4. **Testar funcionamento** — depois do restart, o próprio `server.js` já
   valida a conexão no boot (`verifyConnection()`) e recusa subir se falhar.
   Além disso, rode manualmente:
   - `GET /health` — confirma que o processo subiu.
   - Fluxo de cadastro → login → responder 1 quiz → ver Carteira → Ranking →
     Painel Admin (`/admin`) — cobre os módulos citados na especificação
     original (Cadastro, Login, Quizzes, Missões, Carteira, Recompensas,
     Saques, Painel administrativo).
5. **Revogar credenciais antigas** — só depois de confirmar que o passo 4
   funcionou. No Postgres:
   ```sql
   ALTER ROLE database_api WITH PASSWORD 'nova_senha_ja_em_uso';
   -- a senha antiga já deixou de funcionar assim que trocada; não há
   -- "revogação" adicional necessária para senha, diferente de tokens JWT.
   ```

## 6 e 7. Controle de Acesso e Separação de Usuários do Banco

Script pronto: **`backend/database/security/create_db_roles.sql`**.

| Papel | Uso | Privilégios |
|---|---|---|
| `database_admin` | Rodar migrations, manutenção | Superusuário do provedor (não criado por este script — já existe) |
| `database_api` | Backend em produção (`DATABASE_URL` da API) | SELECT/INSERT/UPDATE/DELETE em todas as tabelas; **sem** CREATE/ALTER/DROP |
| `database_readonly` | Relatórios/BI futuros | Apenas SELECT |

⚠️ **Importante:** as migrations (`npm run migrate:up`) continuam exigindo o
usuário administrador, porque `CREATE TABLE`/`ALTER TABLE` são DDL. O
`database_api` é deliberadamente proibido de rodar DDL — mesmo que a
aplicação seja comprometida por uma falha de código, um invasor não
conseguiria dropar tabelas ou alterar o schema usando essa credencial.

## 8. Proteção Contra Exposição — já implementado

✅ `.gitignore` exclui `.env`.
✅ `backend/src/config/database.js` nunca loga a connection string completa —
apenas host/porta/nome do banco (via `maskConnectionString()`), justamente
para que logs de erro nunca vazem a senha.

⚠️ **Checklist de revisão humana** (não automatizável): antes de qualquer
print de tela, commit ou documentação ser compartilhado, confirme que nenhuma
credencial real aparece. Isso inclui histórico de commits antigos — se uma
credencial real já foi commitada, ela deve ser considerada exposta
permanentemente e rotacionada, mesmo que o commit seja removido depois
(histórico do Git pode ser recuperado).

## 9. Auditoria de Segurança — já implementado

`backend/src/config/database.js` agora registra, via logger estruturado
(Winston/JSON, pronto para qualquer agregador de logs):

- `DATABASE_CONNECTION_SUCCESS` — no boot do servidor (`server.js` chama
  `verifyConnection()` antes de aceitar tráfego).
- `DATABASE_CONNECTION_FAILED` — em qualquer falha de conexão do pool, com
  contador de falhas consecutivas.

`CREDENTIAL_UPDATED` e `ACCESS_PERMISSION_CHANGED` são eventos
**operacionais** (acontecem no provedor de banco, não dentro do código da
aplicação) — registre-os manualmente na sua ferramenta de gestão de mudanças
(ex: um card no board da equipe, ou um log em `docs/` mesmo) toda vez que
rotacionar uma credencial ou alterar permissão de um papel do banco. O evento
de mudança de **papel de usuário da aplicação** (`admin_master`,
`admin_juridico` etc. — diferente de papel do banco) já é auditado
automaticamente como `admin.user.role_changed` na tabela `audit_logs`
(`backend/src/modules/admin/services/adminService.js`).

## 10. Monitoramento de Acessos — já implementado (nível básico)

`backend/src/config/database.js` conta falhas de conexão consecutivas e emite
um log de alerta (`logger.error` com mensagem "ALERTA DE SEGURANÇA...") ao
ultrapassar 5 falhas seguidas — sinal típico de credencial rotacionada
incorretamente ou banco fora do ar.

⚠️ **Próximo passo recomendado (fora do escopo desta entrega):** conectar
esse alerta a um canal externo (e-mail, Slack, PagerDuty) via webhook, em vez
de apenas gravar no log local. Hoje o alerta existe, mas só é visível para
quem está olhando os logs no momento.

## 11. Backup e Recuperação

⚠️ **Ação operacional:** ative backups diários automáticos no painel do
provedor de Postgres (no Render, isso normalmente exige o plano pago — ver
`docs/` sobre infraestrutura no Documento Mestre, Seção 14). Depois de
ativado, teste a restauração pelo menos uma vez em um banco de staging para
confirmar que o backup é realmente restaurável, não apenas gerado.

## 12. Checklist Antes da Produção

- [x] Nenhuma senha dentro do código (`config/database.js` usa só `process.env`)
- [x] `.env` protegido via `.gitignore`
- [ ] Ambientes separados (staging/produção como bancos distintos) — **ação operacional**
- [ ] Produção possui credenciais próprias, diferentes de dev/staging — **ação operacional**
- [ ] `database_api`/`database_readonly` provisionados via `create_db_roles.sql` — **ação operacional, script pronto**
- [x] Permissões revisadas (least privilege documentado e scriptado)
- [x] Logs de conexão funcionando (`DATABASE_CONNECTION_SUCCESS`/`FAILED`)
- [ ] Backups automáticos configurados no provedor — **ação operacional**
- [x] Monitoramento básico de falhas consecutivas ativo

## 13. Arquitetura Segura de Comunicação

```
Usuário
  ↓
Frontend (React) — nunca conhece a connection string do banco
  ↓
Backend (Express) — único componente com DATABASE_URL
  ↓
Variáveis de Ambiente (.env local / painel do provedor em produção)
  ↓
Banco de Dados PostgreSQL — usuário database_api, privilégio mínimo
  ↓
Dados protegidos
```

O frontend nunca se comunica diretamente com o banco — toda leitura/escrita
passa pela API REST do backend, que já aplica autenticação, autorização e
validação antes de qualquer query (ver Manual do Desenvolvedor, Parte 5).

## 14. Critério de Conclusão

| Item | Status |
|---|---|
| Credenciais protegidas (código) | ✅ Concluído |
| Rotação segura possível | ✅ Processo documentado, script de papéis pronto |
| Controle de acesso (least privilege) | ✅ Scriptado, falta executar em cada ambiente |
| Auditoria | ✅ Concluído |
| Backups | ⚠️ Depende de ativação manual no provedor |
| Preparado para crescimento | ✅ Pool configurável, papéis separados, sem acoplamento a um único ambiente |

**Resumo:** todo item que dependia de código foi implementado nesta entrega.
Os itens restantes (separação física de ambientes, ativação de backups no
provedor, provisionamento real dos papéis do banco) são ações operacionais de
quem administra a infraestrutura — não há mais nada a programar para eles,
apenas executar os passos acima uma vez por ambiente.
