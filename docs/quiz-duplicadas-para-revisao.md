# Perguntas duplicadas — regularizadas (migration 390)

`npm run quiz:audit` (BE-003, P10) encontrou 18 pares de enunciados quase iguais. O dono aprovou regularizar e a migration
`390_desativar_perguntas_duplicadas.sql` **desativou uma versão de cada par**. Nada foi apagado e as respostas já dadas ficam ligadas.

**Regra (igual para todos):** mantém-se a versão cujas alternativas denunciam menos a correta (menor razão correta/média das erradas
no validador), calculada com os lotes de correção até à migration 311 já aplicados, por isso as versões já corrigidas ganham;
em empate, a redação com artigo ("um/uma"). Em 5 pares as duas versões estão em lotes revistos; ficou a de menor razão.

**Reverter um par:** `UPDATE questions SET is_active = true WHERE statement = '<enunciado desativado>' AND difficulty = '<dificuldade>';`
Mas atenção: reativar volta a criar a duplicada, e `tests/quiz-duplicadas-regularizadas.test.js` falha enquanto isso acontecer.
As perguntas desativadas que também estão em lotes de explicações são toleradas por `tests/quiz-explanations-lotes.test.js`,
que lê a lista da migration 390 (qualquer outra pergunta desses lotes tem de continuar ativa).

| # | Categoria | Desativada (dif., razão) | Mantida (dif., razão) |
|---|---|---|---|
| 1 | Finanças | O que é despesa? (easy, 0.96) | O que é uma despesa? (easy, 0.86) |
| 2 | Finanças | O que é dívida? (easy, 1) | O que é uma dívida? (easy, 0.98) |
| 3 | Finanças | O que é uma conta de poupança? (easy, 1.04) | O que é uma conta poupança? (easy, 0.97) |
| 4 | Inteligência Artificial | O que é dataset? (hard, 5.35) | O que é um dataset? (medium, 4.13) |
| 5 | Inteligência Artificial / Tecnologia | O que é um algoritmo? (easy, 4.84) | O que é algoritmo? (medium, 3.13) |
| 6 | Inteligência Artificial | O que é viés em um sistema de IA? (medium, 3.03) | O que é um viés em um sistema de IA? (easy, 2.5) |
| 7 | Marketing Digital | O que é hashtag? (easy, 3.9) | O que é uma hashtag? (easy, 3.79) |
| 8 | Marketing Digital | O que é lead? (medium, 5.09) | O que é um lead? (easy, 3.73) |
| 9 | Marketing Digital | O que é persona? (medium, 4.74) | O que é uma persona? (easy, 3) |
| 10 | Marketing Digital | O que é seguidor? (easy, 2.75) | O que é um seguidor? (easy, 2.07) |
| 11 | Marketing Digital | Por que atribuição pode ser complexa? (hard, 1.83) | Por que a atribuição pode ser complexa? (hard, 1.8) |
| 12 | Produtividade | O que é margem de tempo no planejamento? (medium, 2.52) | O que é margem de tempo em um planejamento? (medium, 1.73) |
| 13 | Produtividade | Por que dividir uma tarefa grande em etapas menores pode ajudar? (easy, 1.61) | Por que dividir uma tarefa grande em etapas pode ajudar? (easy, 1.24) |
| 14 | Tecnologia | O que é QR Code? (easy, 1.02) | O que é um QR Code? (easy, 0.98) |
| 15 | Tecnologia | O que é a internet? (easy, 1.11) | O que é internet? (medium, 1.02) |
| 16 | Tecnologia | O que é atualização de software? (medium, 2.14) | O que é uma atualização de software? (medium, 1.01) |
| 17 | Tecnologia | O que é um aplicativo móvel? (medium, 3.73) | O que é aplicativo móvel? (medium, 1.03) |
| 18 | Tecnologia | O que é uma API? (medium, 3.43) | O que é API? (medium, 0.94) |
