# Changelog — Rodada 4 de consolidação (c__13_, ç__5_, ç__4_, ç__6_)

## O que foi incorporado

| Arquivo | Origem | O que faz |
|---|---|---|
| `031_remove_duplicate_questions.sql` | `ç__5_`/`ç__4_` (idênticas) | Migration que remove duplicatas de texto reais no banco, protegendo linhas já respondidas por usuários (FK RESTRICT) |
| `065_tecnologia_facil_3.sql` | `ç__5_`/`ç__4_` | Repõe as 3 perguntas removidas pela migration acima, com conteúdo novo (touchscreen, webcam, modo escuro) |

Confirmado antes de incorporar: minha árvore tinha exatamente as mesmas 3
duplicatas que a migration documenta (entre `003_tecnologia_facil.sql` e
`005_tecnologia_facil_2.sql`) — não era específico da outra árvore.
Auditoria completa rodada sobre os 65 arquivos de seed (simulando a lógica
exata da migration: agrupar por categoria+dificuldade+texto normalizado)
confirma que **essas são as únicas 3 duplicatas em todo o banco** — nenhum
lote adicionado depois (018+) introduziu duplicata nova.

## O que foi conferido e descartado (sem necessidade de decisão)

- **`c__13_.zip`**: snapshot antigo (para no seed ~024). Continha um
  arquivo exclusivo, `025_lote_110_perguntas_incompleto.sql`, com 5
  perguntas que pareciam novas — mas as 5 já existiam palavra-por-palavra
  em seeds já presentes nesta árvore (`007`, `021`, `022`, `023`, `024`).
  O conflito de nomenclatura (`source` colidindo com versões já usadas
  aqui, ex. `seed_produtividade_facil_v3`) se resolveu sozinho: mesmo
  material de origem, processado de forma independente nas duas árvores.
- **`ç__6_.zip`**: snapshot intermediário (para no seed ~050). Nada
  exclusivo encontrado — checado em código (`backend/src`, `frontend/src`)
  e em seeds, sem nenhuma diferença que não fosse "está atrás".

## Estado atual do banco de perguntas

Sem mudança no total — o par migration+seed tem efeito líquido zero
(remove 3, repõe 3). Segue em **1.566 perguntas**, agora comprovadamente
livre de duplicatas exatas em qualquer categoria+dificuldade (auditoria
completa, não amostral).

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | 100 | 100 | 101 | 301 |
| Produtividade | 100 | 100 | 99 | 299 |
| Inteligência Artificial | 100 | 100 | 136 | 336 |
| **TOTAL** | | | | **1.566** |
