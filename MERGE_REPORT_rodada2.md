# Relatório de Fusão — Rodada 2 (ttt.zip + t.zip)

**Contexto:** o plano era receber 3 partes desta vez; chegaram 2
(`ttt.zip` e `t.zip`).

## Resultado da comparação

Diferente da Rodada 1 (3 versões genuinamente divergentes), aqui o
resultado foi simples: **`t.zip` é `ttt.zip` mais uma rodada adiante** —
319 dos 323 arquivos são idênticos byte a byte. As únicas diferenças:

- `backend/database/seeds/066_produtividade_facil_7.sql` — 48 perguntas
  novas de Produtividade/Fácil, só em `t.zip`
- `CHANGELOG_rodada5_consolidacao.md` — só em `t.zip`
- `README.md` e `docs/banco-de-perguntas-status.md` — atualizados em
  `t.zip` para refletir o seed novo (1.566 → 1.614 perguntas)

Nenhuma divergência de lógica. `t.zip` foi usado como base.

## Trazido da Rodada 1 (não existia em nenhum dos dois desta vez)

Este branch (`ttt.zip`/`t.zip`) evoluiu separadamente da fusão da Rodada 1
e não tinha as peças resgatadas de `c_5.zip` na ocasião. Para não perder
esse progresso, foram copiados da fusão anterior:

- `render.yaml` (já com o 5º recurso do worker, adicionado na Rodada 1)
- `.gitignore` (raiz, backend, frontend)
- `docs/deploy-render.md`

Confirmado que `backend/package.json` deste branch ainda tem os scripts
`worker`/`worker:dev` que o `render.yaml` espera — compatível sem ajuste.

## Duplicatas conhecidas (não é problema novo)

A varredura cruzada de todos os 66 seeds voltou a encontrar as mesmas 3
perguntas duplicadas de Tecnologia/Fácil já identificadas e corrigidas pela
migration `031_remove_duplicate_questions.sql` (que remove em tempo de
execução, sem precisar editar os arquivos de seed originais). Nada de novo
aqui — já esperado e já documentado em `docs/banco-de-perguntas-status.md`.

## Validação
- Sintaxe (`node --check`) de todo `.js`: sem erros
- Migrations: 001 a 031, sem lacuna
- `package.json` válido
