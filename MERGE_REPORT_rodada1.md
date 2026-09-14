# Relatório de Fusão — 3 versões do projeto (c_4, c_5, c_6)

**Contexto:** o proprietário do projeto enviou 3 zips do mesmo projeto,
alegando que cada um tinha funcionalidades que os outros não tinham. Este
documento registra como a fusão foi feita e o que foi encontrado, para
rastreabilidade.

## Método

Em vez de assumir qual versão era "melhor" por data ou por achismo, cada uma
das ~180 combinações de arquivo (backend/src, frontend/src, migrations,
seeds, docs, tests, arquivos de raiz) foi comparada por **hash de conteúdo**
entre as 3 versões. Onde havia divergência, o diff completo foi inspecionado
manualmente — não só a existência do arquivo, mas se o conteúdo de uma
versão era um superconjunto estrito da outra (só adições) ou se havia lógica
genuinamente conflitante que exigiria decisão do proprietário.

## Resultado da auditoria

**Migrations 001-026 e a maioria dos arquivos de `backend/src`/`frontend/src`
eram byte-idênticas nas 3 versões.** Onde havia diferença, em **100% dos
casos verificados, sem exceção**, uma versão era um superconjunto estrito de
outra — nunca uma divergência de lógica de negócio. Em ordem de
completude: **v3 (`c_6.zip`) ⊇ v1 (`c_4.zip`) ⊇ v2 (`c_5.zip`)**.

Isso significa que não havia, na prática, "3 implementações diferentes" da
mesma coisa — eram 3 fotografias em pontos diferentes de uma mesma linha do
tempo de desenvolvimento (v2 é a mais antiga, sem o sistema de fila/BullMQ
nem a conversão de Pontos; v1 tem essas duas coisas mas não tem a página
"Meus Recursos" unificada nem o sistema de raridade; v3 tem tudo).

**Nenhum caso exigiu decisão do proprietário** — não houve regra de negócio
implementada de forma diferente e incompatível entre as versões.

## Base escolhida

**v3 (`c_6.zip`) foi usado como base** para tudo — migrations, seeds,
`backend/src`, `frontend/src`, testes, docs, `README.md`, `package.json` —
por ser o superconjunto de tudo.

## Peças genuinamente exclusivas, resgatadas de outras versões

Só a v2 (`c_5.zip`) tinha arquivos que não existiam em nenhuma outra versão
— resgatados e incorporados:

- `render.yaml` — Blueprint de deploy no Render (4 recursos: banco, Redis,
  backend, frontend)
- `.gitignore` (raiz), `backend/.gitignore`, `frontend/.gitignore`
- `docs/deploy-render.md` — guia passo a passo de deploy

## Correção aplicada durante a fusão (não é bug de nenhuma das 3 versões)

O `render.yaml` da v2 foi escrito **antes** do sistema de fila (BullMQ)
existir — por isso só provisionava 4 recursos (banco, Redis, backend,
frontend), sem um serviço rodando `npm run worker`. Copiado sozinho para
cima da base v3 (que já tem o sistema de fila), isso deixaria os CRON Jobs
sem nenhum processo para executá-los em produção — mesmo com o código
funcionando perfeitamente.

**Corrigido:** adicionado um 5º recurso (`aprenda-e-ganhe-worker`, tipo
Background Worker) ao `render.yaml`, e atualizado `docs/deploy-render.md`
para refletir isso (5 recursos, não 4, mais um passo de verificação nos
logs do worker).

## Validação final

- Sintaxe (`node --check`) de todo `.js` do backend: sem erros
- Sequência de migrations: 001 a 030, sem lacuna
- Nenhum diretório/arquivo "lixo" (nomes com chaves literais de shell)
