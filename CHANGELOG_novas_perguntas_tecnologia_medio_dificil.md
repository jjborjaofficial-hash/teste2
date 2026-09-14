# Changelog — Novo lote de perguntas (Tecnologia Médio + Difícil)

## O que mudou

2 novos arquivos de seed em `backend/database/seeds/` (025 e 026), a partir
de dois lotes fornecidos pelo proprietário do projeto:

- Lote "TECNOLOGIA — MÉDIO (50 questões)"
- Lote "TECNOLOGIA — DIFÍCIL (50 questões)"

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 025_tecnologia_medio_2.sql | Tecnologia · Médio | 33 |
| 026_tecnologia_dificil_2.sql | Tecnologia · Difícil | 48 |

**Total: 81 perguntas novas inseridas.**

## Deduplicação aplicada

Os dois lotes somavam 100 perguntas. Cada uma foi comparada (texto
normalizado) contra os 614 enunciados já existentes nos seeds 003–024.
Resultado: **19 descartadas** por já existirem (17 de Tecnologia Médio já
estavam no seed 004, e 2 de Tecnologia Difícil já estavam no seed 006).
Nenhuma duplicata interna entre os dois lotes. As 81 restantes entraram nos
arquivos 025 e 026.

## Correção de qualidade (mesma dos lotes anteriores)

Nos dois lotes originais, a resposta correta era quase sempre a alternativa
"A" (48 de 48 no lote Difícil, 31 de 33 no lote Médio já filtrado) —
decorável sem conhecimento real. A posição da alternativa correta foi
redistribuída por pergunta com seed fixa própria (64 para Médio, 65 para
Difícil — sequência distinta das seeds 42 a 63 já usadas), com distribuição
praticamente igual entre A/B/C/D. O conteúdo pedagógico permanece
exatamente como enviado — só a ordem de exibição das alternativas mudou.

## Estado atual do banco de perguntas (após 025–026)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 83 | 98 | 281 |
| Marketing Digital | 51 | 58 | 50 | 159 |
| Finanças | 33 | 38 | 31 | 102 |
| Produtividade | 37 | 35 | 24 | 96 |
| Inteligência Artificial | 31 | 35 | 0 | 66 |
| **TOTAL** | | | | **704** |

Inteligência Artificial Difícil continua sem nenhuma pergunta.
