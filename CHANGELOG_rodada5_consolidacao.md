# Changelog — Rodada 5 de consolidação (ç__1_, ç__2_, ç__3_)

## O que foi incorporado

| Arquivo | Origem | Conteúdo |
|---|---|---|
| `066_produtividade_facil_7.sql` | `ç__3_` | 48 perguntas novas de Produtividade Fácil |

## Como se chegou nas 48

O arquivo de origem (`046_produtividade_facil_3.sql` na árvore `ç__3_`)
trazia 54 perguntas, já deduplicadas pela própria ramificação de origem
contra os seeds 012/021 (9 descartadas de um lote de 63 recebido). Ao
conferir essas 54 contra o banco completo desta árvore (que inclui lotes
que a outra ramificação nunca viu — 054, 057, 059, 061, todos de
Produtividade Fácil), mais 6 já existiam aqui. Restaram 48 genuinamente
novas.

O `source` original do arquivo (`seed_produtividade_facil_v3`) colidia com
a v3 já usada nesta árvore (arquivo 054, conteúdo diferente) — renomeado
para `v7` (próxima versão livre) para não colidir.

Nenhuma nova redistribuição de posição foi necessária: a ramificação de
origem já havia corrigido o viés original ("sempre A" em 40 das 54) com a
seed de embaralhamento própria dela. A ordem das alternativas foi herdada
como recebida.

## O que foi conferido e não trouxe nada novo

- **`ç__1_.zip`**: subconjunto das outras duas, sem nenhum arquivo exclusivo.
- **`ç__2_.zip`**: tinha os arquivos 046-052 (ia_facil_3, ia_medio_3,
  produtividade_dificil_2, ia_facil_4, ia_dificil, ia_dificil_2,
  produtividade_medio_3) — todos conferidos **byte a byte idênticos** aos
  já presentes nesta árvore. Nenhuma mudança de código (`backend/src`,
  `frontend/src`) em nenhuma das 3 partes.

## Nota de metodologia — contagem estática vs. real

A migration 031 (rodada anterior) remove 3 duplicatas de Tecnologia Fácil
em tempo de execução. Uma contagem estática pura dos `INSERT`s nos
arquivos de seed mostraria Tecnologia Fácil = 103 (103 inseridos - 0
considerados removidos, já que a remoção só acontece ao rodar a
migration). O número real após rodar tudo em ordem é **100**. Todos os
totais abaixo já refletem esse ajuste.

## Estado atual do banco de perguntas

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | 100 | 100 | 101 | 301 |
| Produtividade | **148** | 100 | 99 | 347 |
| Inteligência Artificial | 100 | 100 | 136 | 336 |
| **TOTAL** | | | | **1.614** |

Produtividade Fácil ultrapassou bastante a meta implícita de ~100 (148) —
mantido assim, seguindo o mesmo critério já usado para outras categorias
que passaram do alvo (Tecnologia Médio=124, Marketing Digital
Difícil=106): conteúdo novo e válido nunca é descartado só para bater
num número redondo.
