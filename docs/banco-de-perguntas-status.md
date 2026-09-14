# Status do Banco de Perguntas

**Gerado em:** 2026-09-12, calculado programaticamente a partir de todos os
72 arquivos de conteúdo em `database/seeds/` (não conta `001`/`002`, que são
dev/admin).

## Totais reais por categoria e dificuldade

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 120 | 100 | 320 |
| Finanças | 100 | 100 | 101 | 301 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Produtividade | **148** | **148** | 100 | 396 |
| Inteligência Artificial | 100 | 100 | 136 | 336 |

**Total geral: 1.659 perguntas, zero duplicatas.**

## Observação: Produtividade está desproporcionalmente maior

16 arquivos de seed contribuem pra essa categoria (a maioria das outras tem
5-7), resultado de várias rodadas reforçando o que antes era a categoria
mais fraca do banco. Não é erro — confirmado que as 148+148 são todas
únicas (ver seção de duplicata abaixo) — só um desequilíbrio de volume que
pode valer a pena nivelar depois, se o objetivo for ~100 por nível em todas
as categorias.

## Duplicatas: zero, verificado em 3 níveis de rigor

Esta é a checagem mais importante deste documento. Uma rodada anterior
desta auditoria só comparava duplicata **dentro da mesma categoria E mesma
dificuldade** — isso tinha um ponto cego real: não pegava a mesma pergunta
aparecendo em dificuldades diferentes da mesma categoria (ex.: "O que é
inteligência artificial?" em Tecnologia/Fácil E Tecnologia/Médio ao mesmo
tempo), nem entre categorias diferentes (ex.: "O que é uma rede social?"
em Tecnologia E em Marketing Digital).

Uma correção de conteúdo resolveu isso diretamente nos arquivos de seed
(`004`, `005`, `007`, `010`, `034`, `035`) — removendo a ocorrência
duplicada e mantendo a original. Confirmado com 3 varreduras progressivamente
mais rigorosas sobre o banco inteiro:
1. Duplicata por categoria+dificuldade: **0**
2. Duplicata por categoria (ignorando dificuldade): **0**
3. Duplicata global (ignorando categoria e dificuldade): **0**

## Achado importante sobre a migration 031 (não é mais crítico, mas registrar por quê)

A migration `031_remove_duplicate_questions.sql` foi escrita para varrer o
banco em busca de duplicatas e removê-las — mas ela roda durante
`npm run migrate:up`, que executa **antes** de qualquer seed ser carregado
(seeds são arquivos separados, rodados manualmente via `psql -f
database/seeds/X.sql`). Isso significa que, num banco **novo**, a migration
031 nunca encontra nada para remover — a tabela `questions` ainda está
vazia no momento em que ela roda.

**Isso não é mais um problema na prática**, porque a correção de conteúdo
acima elimina a duplicata na origem (nos próprios arquivos de seed), então
não há mais nada para a 031 precisar limpar em uma instalação nova. A
migration continua no projeto como rede de segurança para bancos **já
existentes** que rodaram os seeds antigos (com duplicata) antes desta
correção — nesse caso, rodar a 031 de novo (ela é idempotente/segura de
re-executar) ainda limpa retroativamente.

## Convenções seguidas por todos os seeds de conteúdo

- `questions.source` como marcador único, idempotente
- Toda correção de "resposta sempre A" usa seed de embaralhamento numérica
  fixa, nunca repetida
- Todo lote novo deve ser comparado por texto normalizado contra **todo o
  banco** (não só a mesma categoria/dificuldade) antes de gravar — a lição
  desta rodada é que o escopo da comparação importa tanto quanto o fato de
  comparar
