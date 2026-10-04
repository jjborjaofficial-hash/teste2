# Fluxo de trabalho (como o Claude atualiza e sobe cada pedaço)

Receita para qualquer sessão retomar o trabalho do quiz sem reaprender nada.
Instrução: [`INSTRUCAO_QUIZ.md`](./INSTRUCAO_QUIZ.md). Estado e lista de pedaços: [`PROGRESSO_QUIZ.md`](./PROGRESSO_QUIZ.md).

## 1. O ciclo de cada pedaço

```
LER o primeiro "[ ]" de PROGRESSO -> IMPLEMENTAR (pequeno) -> TESTAR -> git commit -> git push
-> marcar "[x]" em PROGRESSO (no mesmo commit) -> relatório curto
```

Regras: um pedaço = uma ideia e poucos ficheiros. Commit e push logo que estiver testado, para
que, se a sessão acabar, o que foi feito já esteja no GitHub. Marcar o `[x]` no PROGRESSO
**no mesmo commit** do pedaço, assim o registo nunca fica atrás do código.

## 2. Preparar o ambiente (início de sessão)

```bash
git clone https://github.com/jjborjaofficial-hash/teste2.git && cd teste2
git checkout feat/quiz-aprendizagem
git config user.name "Claude" && git config user.email "noreply@anthropic.com"
```

Banco e Redis reais para testes (opcional, mas valida SQL de verdade):

```bash
apt-get update -qq && apt-get install -y -qq postgresql redis-server
redis-server --daemonize yes --dir /tmp        # --dir evita criar dump.rdb dentro do repositório
service postgresql start
su postgres -c "psql -c \"CREATE USER app WITH PASSWORD 'app' SUPERUSER;\""
su postgres -c "psql -c \"CREATE DATABASE aeg OWNER app;\""
```

Variáveis de teste (ficheiro FORA do repositório, ex.: `/tmp/test.env`; valores descartáveis):

```
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000
DATABASE_URL=postgres://app:app@localhost:5432/aeg
DATABASE_SSL=false
REDIS_URL=redis://localhost:6379
JWT_ACCESS_SECRET=local_test_access_secret_value_123456
JWT_REFRESH_SECRET=local_test_refresh_secret_value_654321
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d
BCRYPT_SALT_ROUNDS=4
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=600
CORS_ALLOWED_ORIGINS=http://localhost:5173
DEFAULT_COUNTRY=MZ
DEFAULT_CURRENCY=MZN
DEFAULT_LOCALE=pt-MZ
COOKIE_SAMESITE=strict
```

Instalar dependências e aplicar migrations:

```bash
cd backend && npm install && set -a && . /tmp/test.env && set +a && node src/database/migrate.js up
cd ../frontend && npm install
```

## 3. Testar

```bash
cd backend && set -a && . /tmp/test.env && set +a
timeout 120 npx jest --runInBand --forceExit tests/quiz-feedback.test.js tests/quiz-rounds.test.js   # unitários
RUN_DB_TESTS=1 timeout 150 npx jest --runInBand --forceExit tests/quiz-rounds.integration.test.js   # banco real
timeout 240 npx jest --runInBand --forceExit                                                         # suíte completa
cd ../frontend && npm run build                                                                      # compilação
```

`tests/auth.test.js` tem 3 falhas que já existiam antes deste trabalho (fora do escopo).
O frontend não tem executor de testes: verificar por build e leitura; ver no navegador é o pedaço P18.

## 4. Subir para o GitHub (token só por comando)

O token (fine-grained, 7 dias, só este repositório, Contents: Read and write) é fornecido pelo
proprietário na conversa. **Nunca** gravar em ficheiro, `.git/config`, memória ou commit.

```bash
git add -A && git status --short            # conferir: nada de .env, dump.rdb, dist, node_modules
git commit -m "feat(quiz): ..."
H="Authorization: Basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
git -c http.extraheader="$H" push origin feat/quiz-aprendizagem
```

## 5. Checklist antes de cada push

- [ ] O pedaço está testado (diga o que NÃO pôde testar).
- [ ] `git status` limpo de ficheiros gerados e segredos.
- [ ] `PROGRESSO_QUIZ.md` atualizado (item marcado, notas, próximo pedaço).
- [ ] Mensagem de commit clara.

## 6. Armadilhas conhecidas

- `node -e "require(...)"` de módulos que ligam ao Redis **não termina**; usar `node --check` ou `timeout`.
- Jest com Redis/Postgres: usar `--forceExit` e `timeout`.
- Redis sem `--dir /tmp` cria `dump.rdb` no repositório (já está no `.gitignore`).
- `audit_logs` é append-only: não dá para apagar utilizadores de teste; limpar só rodadas e tentativas.
- `users.phone_provider` só aceita `mpesa` ou `emola`; o cadastro real também cria a linha em `streaks`.
- O antifraude trata respostas em menos de ~400 ms como suspeitas; nos testes esperar ~450 ms antes de responder.
- `apt-get install` pode falhar com 404 se o índice estiver velho: rodar `apt-get update` antes.
- Os números da auditoria (1.659 perguntas, 0 explicações, 1.483 com a correta mais longa) saem de
  `select` no banco depois das migrations; servem para conferir o ambiente.

## 7. Relatório curto depois de cada push

```
IMPLEMENTADO: ...
TESTADO: ... (e o que não foi possível testar)
COMMIT: <hash>   PUSH: sucesso/erro
PRÓXIMO PEDAÇO: P?
```
