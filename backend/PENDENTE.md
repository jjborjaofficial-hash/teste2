# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-005 — Sobras das rodadas do quiz v2

BE-002 (rodadas no servidor: migration 107, `quiz_rounds`, seleção das 10, retomar ao recarregar,
resumo só da rodada) já foi feito e testado. Sobram: (a) a rota antiga
`GET /quiz/categories/:id/next-question` + `POST /quiz/answers` sem `roundId` continua a servir
perguntas fora de rodada; o frontend já não os usa (usa só `/quiz/rounds`); decidir se o servidor passa a
exigir `roundId` (**`nextQuestion` já foi removido do frontend em 2026-10-07**; falta só decidir o servidor: o dono tem de dizer se pode cortar a rota antiga, por causa de versões antigas da app instaladas; o teste `quiz-wallet-ranking` teria de ser reescrito).

**(c) FEITO — conceitos errados por rodada** (`tests/quiz-round-review.test.js`, sem migration). Não foi preciso tabela nova:
cada resposta já fica em `quiz_attempts` com `round_id`, `question_id` e `is_correct`, ou seja, os conceitos errados de cada
rodada já estavam guardados; faltava expô-los. Agora: (1) o resumo da rodada traz `mistakes` (todos os errados, no máximo
10, com enunciado, "Por quê?" e dificuldade) e mantém `reviewStatements` por compatibilidade; (2) `GET /quiz/rounds/:roundId/summary`
reabre o resumo de uma rodada terminada (antes só saía uma vez e perdia-se ao recarregar); (3)
`GET /quiz/review/recommendations?categoryId=&limit=` (limite 1 a 20, padrão 10) lista o que rever: perguntas erradas em
rodadas cuja resposta mais recente continua errada, com `timesMissed`, mais recentes primeiro; ao acertar depois deixa de
aparecer, e perguntas desativadas não entram. Só dados do próprio utilizador e nunca devolve a alternativa certa nem a
escolhida. **Frontend FEITO (parcial):** a página `/revisao` (`Revisao.jsx`, entrada pelo Hub de Estudos e pelo link do resumo da
rodada) consome `GET /quiz/review/recommendations`, e o resumo da rodada mostra agora os erros com o "Por quê?" (`mistakes`).
`GET /quiz/rounds/:roundId/summary` continua sem uso no frontend: só serve para reabrir um resumo depois de recarregar, e
hoje o ecrã de resultado recebe o resumo pelo estado da navegação.

**(b) FEITO — missão "completar uma rodada"** (`activity_type = 'round_complete'`, migration 391,
`tests/missions-round-complete.test.js`). Conta +1 quando uma rodada termina por completo (a 10.ª resposta), dentro da
mesma transação; rodadas abandonadas não contam; se a missão tiver categoria só conta rodadas dessa categoria; o alvo é
`target_quiz_count` (nº de rodadas). O admin cria-a pela API com `activityType: "round_complete"` (só `quiz_count` e
`round_complete` são criáveis; os outros tipos continuam a vir das migrations). **Nenhuma missão foi criada**: o catálogo
paga dinheiro real (teto 7,20 MZN/dia) e é decisão do dono. Sobram, para o dono/frontend: (1) ~~o formulário de missões do
painel admin não tinha o seletor de tipo~~ **FEITO**: `AdminMissionsManage.jsx` tem agora "O que a missão pede" (Acertar perguntas /
Completar rodadas), mostra a unidade certa na lista e avisa quando uma missão de rodadas paga dinheiro; (2) **decisão de negócio:** uma rodada conta mesmo que o
jogador erre quase tudo, e, ao contrário de `quiz_count`, que só conta respostas certas, isto permite completar missões
pagas respondendo ao acaso; antes de criar uma missão com dinheiro decidir se exige um mínimo de acertos por rodada.

## BE-003 — REGULARIZAR o padrão "a correta é a mais longa" e criar o validador (quiz v2)

**Padrão obrigatório para reescrever alternativas (regras, passo a passo e modelos por tipo de pergunta):
`docs/quiz-v2-alternativas-padrao.md`.** Ler antes de tocar em qualquer alternativa.

**Problema — precisa ser regularizado (confirmado pelo dono em 2026-10-06).** A alternativa correta
denuncia-se pelo tamanho e pelo detalhe. Medido no banco (1.659 perguntas, migrations 001–119):
a correta é a **mais longa em 90,8%** das perguntas (ao acaso seriam ~25%) e a mais curta em só
3,7%; tem em média 60 caracteres contra 25 das erradas, e é pelo menos 50% maior que a média das
erradas em 82,8% das perguntas. Por categoria e dificuldade vai de 78% (fáceis de IA e de
Produtividade) a 99% (Finanças difícil); nas difíceis fica entre 84% e 99%. A posição já é
equilibrada (~25% em cada letra), por isso o problema é o tamanho, não a posição.
**Risco:** quem escolhe sempre a opção mais longa acerta cerca de 9 em cada 10. O quiz paga
dinheiro real, então isso permite farmar o jogo e esvazia o antifraude do cronómetro.

**Como regularizar (plano recomendado):**
1. **Validador, só leitura** (script no backend, p. ex. `npm run quiz:validate`): por pergunta, mede
   caracteres e palavras de cada alternativa, a razão correta/erradas, se a correta é a mais
   longa ou a mais curta, estrutura (pontuação, explicação embutida, listas), alternativas
   duplicadas ou quase iguais, nº de alternativas, só uma correta e posição da correta. Gera um
   relatório por categoria e dificuldade e a lista das que reprovam. Critério sugerido (o dono
   pode ajustar): reprovar quando a correta é a mais longa e passa ~1,3× a média das erradas, ou
   quando traz explicação embutida; meta por categoria e dificuldade: correta mais longa em no
   máximo ~30–35% das perguntas.
2. **Corrigir por lotes de 25, com revisão humana do dono** (decisão já tomada), em migrations que
   **só alteram `question_alternatives.label`**: mantêm os ids, `is_correct`, a ordem e a pergunta,
   e nunca apagam perguntas. Reescrever para equilibrar tamanho e estrutura (distratores plausíveis,
   mais completos; correta mais enxuta quando preciso), sem absurdos óbvios e sem explicação
   embutida na correta.
3. **Ordem:** a mesma das explicações (Finanças fácil → médio → difícil, depois as outras
   categorias). Nas perguntas ainda sem explicação, escrever a explicação (BE-004) e corrigir as
   alternativas **no mesmo lote**, tocando em cada pergunta uma só vez. Finanças fácil (95 já com
   explicação) entra só na correção das alternativas.
4. **A cada lote:** rodar o validador e registar aqui o antes/depois (% de "correta mais longa") e
   o progresso, no mesmo commit do push.
5. **Perguntas reprovadas e ainda não corrigidas continuam a ser servidas** (cerca de 91% reprovam;
   parar de servi-las esvaziaria o jogo) e ficam marcadas para revisão; nada é apagado sem
   aprovação. As perguntas novas só entram se passarem no validador (**FEITO em código, P13**).
6. Reforço **FEITO (2026-10-06, pedido do dono):** a ordem das alternativas é aleatória a cada
   apresentação (`ORDER BY random()` em `quizRepository.getRandomQuestion` e `getQuestionById`); a
   validação usa o id da alternativa, não a posição. Teste: `tests/quiz-alternatives-shuffle.test.js`.
   Nota: ao recarregar a página a mesma pergunta volta com nova ordem (aceite).

**Decisão do dono (2026-10-06):** começar pelo validador (passo 1). Passos 2 em diante só depois do
validador feito e do dono rever o relatório.

**Progresso da regularização (atualizar a cada push):**
- Passo 1 (validador): **FEITO** (medição inicial abaixo). Código em
  `backend/src/modules/quiz/validation/alternativesValidator.js`, script `npm run quiz:validate`
  (`-- --list` lista as reprovadas, `-- --json` dá JSON) e teste `backend/tests/quiz-alternatives-validator.test.js`.
  Só leitura. O CI roda o relatório a cada push (passo "Relatório do validador" em Actions), então
  o antes/depois de cada lote fica no log do GitHub. Critérios ajustáveis em `CRITERIA` no mesmo ficheiro.
- **Validador estendido (P9 a P14): FEITO.** Só leitura, sem tocar nas migrations nem na medição histórica do validador acima.
  `biasDetector.js` (P9: pistas de linguagem e estrutura das regras 1, 3, 6 e 7), `duplicateQuestions.js` (P10: enunciados duplicados
  ou quase iguais), `positionAnalysis.js` (P11: posição previsível da correta — qui², sequências longas e padrão cíclico),
  `auditReport.js` + `npm run quiz:audit` (P12: relatório único; `--list`, `--json`, `--strict` que falha só com defeitos graves) e
  `newQuestionGate.js` (P13: ligado a `createQuestion`/`updateQuestion` do admin). Legenda dos alertas e como corrigir cada um:
  `docs/quiz-v2-alternativas-padrao.md` (secção "Validador estendido"). Testes: `quiz-bias-detector`, `quiz-duplicate-questions`,
  `quiz-position-analysis`, `quiz-audit-report` e `quiz-new-question-gate`.
  **Portão das perguntas novas (passo 5, agora em código):** pergunta nova, ou com enunciado/alternativas reescritos, só é gravada se
  não tiver correta bem mais longa, explicação embutida, "todas/nenhuma das anteriores", alternativas repetidas nem enunciado
  duplicado. Erro 400 com os motivos em `message`; viés leve volta em `qualityWarnings`. Mudar só `isActive`, tempo ou XP não passa pelo
  portão e as perguntas antigas continuam a ser servidas. Efeito prático: uma pergunta escrita ao jeito antigo é recusada até ser
  equilibrada. Só ~17% das perguntas atuais passariam hoje, o que bate com os ~91% que reprovam no validador. **Só vale em produção
  depois do deploy manual do backend.**
  **Auditoria do banco (2026-10-07, 1.659 ativas, após os lotes até a migration 201):** correta mais longa em **85,4%** (1.372 reprovam);
  posição equilibrada (A 25,7 / B 25,5 / C 24,9 / D 23,9%, qui² 1,24, nenhum grupo previsível); 0 enunciados idênticos; **18 pares
  quase iguais** (**REGULARIZADOS** pela migration 390: uma versão de cada par desativada, nada apagado; lista e regra em
  `docs/quiz-duplicadas-para-revisao.md`; hoje ficam 1.641 ativas e 0 duplicadas); 0 defeitos estruturais; 0
  "todas/nenhuma das anteriores". A pista mais comum fora o tamanho é `palavras_desequilibradas` (aviso, 1.199 perguntas).
  **Decisão do dono pendente:** pôr `npm run quiz:audit` também no CI
  (`.github/workflows/testes.yml`; não foi mexido: alterar workflows exige uma permissão a mais no token de push).
- **P15 (07/10): critério `correta_muito_mais_curta` FEITO** (teste 12 da especificação; simétrico ao da mais longa:
  a correta é a mais curta e fica abaixo de 0,75x a média das erradas; `CRITERIA.shortestRatio`). Evita trocar o padrão
  "a mais longa" por "a mais curta" ao enxugar as corretas nos lotes. Medido: só 23 de 1.659 perguntas (1,4%) o
  acusam (IA 11, Produtividade 6, Marketing Digital 3, Tecnologia 3; nenhuma em Finanças) e reprovam SÓ por isso;
  total que reprova passou de 1.332 para 1.355. Bloqueia perguntas novas no admin (portão) e é informativo nas antigas.
- **Validador: falso alarme "Porque" corrigido (auditoria de Finanças).** `hasEmbeddedExplanation` marcava "porque" em qualquer
  posição, então a resposta normal a uma pergunta "Por que…?" ("Porque pode ser necessária…") reprovava, e o portão de perguntas novas
  recusaria qualquer "Por que…?" bem escrita. Agora um "Porque" no INÍCIO da alternativa não conta; no meio ("X, porque Y"),
  parênteses, dois-pontos e "ou seja" continuam a contar. Efeito: Finanças passou de 16 para 7 assinaladas e o banco de 1.051 para
  1.040 a reprovar; **a medição histórica abaixo (1.457) usava a regra antiga.** Finanças: meta cumprida nos 3 níveis (18,6%, 16%,
  26,7%). **Ajuste residual de Finanças: FEITO** (aprovado pelo dono em 2026-10-07): migration 392 encurta 11 alternativas
  erradas de 4 perguntas (certa e explicação intactas) e as 3 alternativas "espelho" (necessidade/desejo, liquidez/solvência,
  financiamento/empréstimo) foram aceitas como estão. Detalhe em `docs/quiz-lotes-alternativas/financas-ajuste-residual.md`.
  **Correção posterior a um lote:** o teste `quiz-alternatives-lotes` exige que o banco tenha o texto exato de cada lote, então
  uma correção que mude uma alternativa já escrita por um lote deve ir numa migration chamada `NNN_ajuste_alternativas_*.sql`
  (mesmas linhas `(fonte, pergunta, posição, antigo, novo)` e `esperado: N`); o teste de lotes passa a esperar o texto da correção
  e `tests/quiz-ajuste-alternativas.test.js` confere certa, explicação e validador. Finanças fica com 0 assinaladas (as 3
  espelho deixaram de ser assinaladas pela regra de espelho, abaixo).
- **Validador: mais 2 falsos alarmes corrigidos, medidos com as 659 perguntas já aprovadas pelo dono em lotes** (o portão das
  perguntas novas recusava 4 delas, 0,6%; agora recusa 0). (1) Uma **sigla entre parênteses** (só maiúsculas/números, ex.:
  "Processador (CPU)") não é explicação embutida; "(taxa cobrada)" continua a ser. (2) Uma alternativa **espelho** (os dois lados
  da ideia trocados, ex.: "Necessidade é essencial; desejo é opcional" × "Necessidade é opcional; desejo é essencial") não é "quase
  igual": é uma troca pura de lugares, com exatamente as mesmas palavras em ordem diferente e 5+ palavras. Uma palavra a mais ou a
  menos, ou o mesmo texto com outra pontuação, continuam a ser apanhados. **Como repetir esta verificação** quando mexerem nas
  regras: avaliar com `evaluateNewQuestion` as perguntas que aparecem nas migrations `*_alternativas_*`/`*_ajuste_alternativas_*`
  (as aprovadas); qualquer bloqueio sobre elas é suspeito de falso alarme.
- Passo 2 (corrigir alternativas em lotes de 25, só `question_alternatives.label`): **EM ANDAMENTO**. Finanças fácil lote 1 (perguntas 1 a 25 do seed 045; 56 alternativas erradas ajustadas) aprovado pelo dono em 2026-10-07 e gravado na migration 141 (`tests/quiz-alternatives-financas-facil-lote01.test.js`). Rascunhos dos lotes: `docs/quiz-lotes-alternativas/`.
  **Lotes feitos:** Finanças fácil lote 1 (migration 141), lote 2 (142), lote 3 (143, perguntas 18 a 42 do seed 064) e lote 4 (144, as 25 últimas: seed 064#43 a 59, seed 068, 094 e 099), que **FECHA Finanças fácil**: a certa estava mais longa em 39% das fáceis e passou a 18%, e as reprovadas de 26 para 1 (a que sobra é "alternativas duplicadas ou quase iguais", da lista de duplicadas para o dono decidir). No lote 4, 22 explicações que citavam as erradas antigas foram reescritas na mesma migration (regra 9; teste genérico `tests/quiz-explanations-lotes.test.js`, que cobre todos os lotes que reescrevem explicações). **Finanças médio lote 1 FEITO** (migration 145, as 25 primeiras do seed 046): 69 alternativas erradas ajustadas (as das contas que já vinham de erros reais ficaram) e 14 explicações reescritas; Finanças médio: correta mais longa de 90% para 72% e reprovadas de 91 para 76 (no grupo inteiro, de 100 perguntas). **6 perguntas do lote continuam reprovando por `explicacao_embutida_na_correta`** (a correta começa por "Porque…", resposta natural a "Por que…?", e as 4 opções já começam por "Porque"): são as perguntas 4, 7, 10, 12, 20 e 25 do seed 046. Mexer na correta exige aviso ao dono (regra de ouro). **Decisão do dono pendente:** aceitar "Porque" quando as 4 opções o usam (ajustar o validador) ou reescrever essas 6 certas sem "Porque". **AUTORIZAÇÃO DO DONO (2026-10-07):
  gravar cada lote direto, sem esperar aprovação** (ele já validou a regra); avisá-lo depois e deixar o rascunho em
  `docs/quiz-lotes-alternativas/` para ele conferir. **Finanças médio lote 2 FEITO** (migration 146: 046#26 a 38 e 065#1 a 12; 74 alternativas e 25 explicações; correta mais longa em 4 de 25). **Finanças médio lote 3 FEITO** (migration 147: 065#13 a 37; 75 alternativas e 24 explicações; correta mais longa em 6 de 25). **Finanças médio lote 4 FEITO** (migration 148: 065#38 a 54, 069#1 a 3 e 100#1 a 5; 72 alternativas e 20 explicações; correta mais longa em 4 de 25), que **FECHA Finanças médio (100 perguntas)**. **Finanças difícil lote 1 FEITO** (migration 149: 047#1 a 25) e **lote 2 FEITO** (migration 150: 047#26 a 31 e 073#1 a 19; 75 alternativas, 21 explicações). **Finanças difícil lote 3 FEITO** (migration 151: 073#20 a 35 e 074#1 a 9; 75 alternativas, 10 explicações). **Finanças difícil lote 4 FEITO** (migration 152: 074#10 a 33 e 075#1; 75 alternativas, 3 explicações; correta mais longa em 7 de 25), que **FECHA Finanças difícil**. A única pergunta do `seed_financas_dificil_v5` (083, conta de juros compostos com 4 valores) ficou como está: as 4 respostas são números do mesmo tamanho, sem problema de comprimento. **FINANÇAS COMPLETA (fácil, médio e difícil: alternativas e explicações).** **Finanças não precisa de mais nada** (CI de 08/10: 0 reprovadas nos 3 níveis). **IA já está em andamento noutra sessão (faixa 400+, ver bloco da IA abaixo); Marketing Digital: RESERVADO a esta sessão (08/10, a pedido do dono) na faixa de migrations 500+ (alternativas e explicações juntas, lotes de 25, como Tecnologia/IA; começa pelo fácil, seeds 007, 018, 027, 031, 040, 041, 068; ordem dos seeds). Outras sessões: não pegar Marketing sem avisar aqui.** Medição do CI em 08/10: correta mais longa em 59,8% das 1.641 ativas (era 89,4%); reprovam 836, todas em IA, Marketing e Produtividade. Atenção (regra 9): no médio muitas explicações citam as erradas antigas e as dos lotes 13 a 22 do BE-004 seguem o estilo curto das fáceis; reescrever no mesmo lote as que citarem opções que deixaram de existir.
  Cada lote: rascunho em `docs/quiz-lotes-alternativas/` (tabela com a coluna "Seed" no formato 064#18) → migration gerada
  a partir da tabela (a certa nunca muda) → `tests/quiz-alternatives-lotes.test.js` (cobre todos os lotes) → push → CI verde →
  deploy do backend → atualizar este bloco.
- **Produtividade (penúltima categoria) — feita em paralelo, por outra sessão, a pedido do dono (2026-10-07).** Explicações **e** alternativas juntas, em lotes de 25, com a regra do dono (a certa não muda). Usa a **faixa de migrations 200+** (Finanças segue em 144+), para as duas sessões não colidirem. Cada lote = 2 migrations (`NNN_alternativas_produtividade_...` e `NNN+1_explicacoes_produtividade_...`) + rascunho em `docs/quiz-lotes-alternativas/produtividade-...` + testes (`quiz-alternatives-lotes` e `quiz-explanations-produtividade`, genéricos). **Feito:** fácil lote 1 (seed v1, 25 perguntas; migrations 200 e 201): a certa passou de 75% para 62,8% de "mais longa" no grupo Produtividade fácil e as reprovadas de 105 para 81. **ASSUMIDO (08/10 03:58, a pedido do dono, por outra sessão; a anterior não enviava nada desde 07/10 02:14): esta sessão continua Produtividade lote a lote, em ordem, com push a cada lote; NÃO duplicar.** **Fácil lote 2 FEITO (08/10; seeds v2 (12) + v3 (13); migrations 202 e 203; rascunho `produtividade-facil-lote02.md`):** a certa passou de 80% (20 de 25) para 16% (4 de 25) de "mais longa", as reprovadas de 17 para 0; 72 alternativas e 25 explicações (a #14 já estava equilibrada e ficou igual). **Fácil lote 3 FEITO (09/10; seed v4 perguntas 1 a 25; migrations 204 e 205; rascunho `produtividade-facil-lote03.md`):** a certa passou de 64% (16 de 25) para 24% (6 de 25) de "mais longa", as reprovadas de 17 para 0 e os avisos de viés de 16 para 0; 65 alternativas e 25 explicações. **Ajuste residual do fácil lote 2 FEITO (migration 290, 09/10):** o detetor de viés (que só passou a existir depois do lote 2) apontava 5 perguntas (absolutos só nas erradas, "pode" só na correta, palavras desequilibradas); corrigidas (12 alternativas erradas; certa e explicação intactas) e o lote 2 fica com 0 reprovadas e 0 avisos. **LIÇÃO para os próximos lotes: antes de gravar medir sempre (1) reprovadas, (2) pistas de viés (`detectBias`) e (3) % de "mais longa" (meta <= 35%); se a correta começa por "Pode…", pôr "Pode…" nas erradas também; no fácil as erradas ficam com no máximo ~50% mais palavras que a menor opção.** **Fácil lote 4 FEITO (10/10; mini-lote: seed v5 completo (7) + v6 completo (1); migrations 206 e 207; rascunho `produtividade-facil-lote04.md`):** a certa passou de 88% (7 de 8) para 25% (2 de 8) de "mais longa", as reprovadas de 7 para 0 e os avisos de viés de 5 para 0; 22 alternativas e 8 explicações. **Fácil lote 5 FEITO (10/10; seed v4 perguntas 26 a 42, 17 perguntas, fecha o seed v4; migrations 208 e 209; rascunho `produtividade-facil-lote05.md`):** a certa passou de 71% (12 de 17) para 24% (4 de 17) de "mais longa", as reprovadas de 11 para 0 e os avisos de viés de 12 para 0; 51 alternativas e 17 explicações. **PRÓXIMO: fácil lote 6** = seed v7 perguntas 1 a 25 (migrations 210 e 211); lote 7 = v7 26 a 48 (212 e 213); depois médio e difícil. Medir em CARACTERES (é o que o validador faz), não em palavras: a certa tem de ser a mais longa em no máximo ~30% das perguntas do lote.
- **Produtividade DIFÍCIL — RESERVADO a outra sessão (Claude, chat do dono, 09/10), migrations 260 a 267; a sessão de Produtividade fácil/médio NÃO deve fazer o difícil.** 100 perguntas (seeds 044 = v1 com 24, 078 = v2 com 75, 101 = v3 com 1), em 4 lotes de 25, mesma regra (a certa e o resto não mudam além do padrão), cada lote = 2 migrations (`NNN_alternativas_produtividade_...` e `NNN+1_explicacoes_produtividade_...`) + rascunho em `docs/quiz-lotes-alternativas/produtividade-dificil-loteNN.md`. Lote 1 = migrations 260 e 261, lote 2 = 262 e 263, lote 3 = 264 e 265, lote 4 = 266 e 267. **Feito:** nada ainda.
- **Marketing Digital (faixa de migrations 500+; explicações + alternativas juntas, lotes de 25) — em sessão própria (2026-10-08).** Cada lote = 2 migrations (`NNN_alternativas_marketing_...` e `NNN+1_explicacoes_marketing_...`) + rascunho em `docs/quiz-lotes-alternativas/marketing-...` + testes (`quiz-alternatives-lotes` e `quiz-explanations-marketing`). **Feito:** fácil lote 1 (25 perguntas ativas: seed v1, que tem 23 ativas, e v2#1 e #2; migrations 500 e 501; v1#8 está desativada e foi saltada): 72 alternativas e 25 explicações; Marketing fácil passou de 90,8% para 71,4% de "correta mais longa" e as reprovadas de 89 para 65; no lote, correta mais longa em 5 de 25 e mais curta em 4 de 25 (equilíbrio de propósito). **Fácil lote 2 FEITO** (v2#3 a v2#26 e v3#1; migrations 502 e 503): 69 alternativas e 25 explicações; Marketing fácil passou para 53,1% de "correta mais longa" e as reprovadas de 65 para 42; no lote, correta mais longa em 5 de 25 e mais curta em 1 de 25. **Fácil lote 3 FEITO (10/10; v3#2 a v3#27, saltando a v3#20 desativada; migrations 504 e 505; rascunho `marketing-facil-lote03.md`):** 63 alternativas e 25 explicações; no grupo Marketing fácil a certa mais longa passou de 53,1% para 35,7% e as reprovadas de 42 para 22; no lote, correta mais longa em 3 de 25 e mais curta em 5 de 25, com 0 reprovadas. Total geral de reprovadas 566 → 546 (já com os lotes de outras sessões). **Fácil lote 4 FEITO (10/10; as 23 ativas que faltavam: v3#28 a v3#34, v4 (8), v5 (5), v6 (2), v7 (1); migrations 506 e 507; rascunho `marketing-facil-lote04.md`) — FECHA o fácil de Marketing:** 66 alternativas e 23 explicações; Marketing fácil passou de 35,7% para 19,4% de "correta mais longa" e de 22 reprovadas para 0 (o grupo inteiro cumpre a meta); no lote, correta mais longa em 6 de 23 e mais curta em 1 de 23 (a primeira versão tinha 12 de 23 e foi alongada uma errada em 6 perguntas). Total geral de reprovadas 546 → 524. **Marketing fácil está concluído nesta sessão. O médio (510 a 519) e o difícil (520 a 527) de Marketing são de outras sessões: não pegar sem avisar aqui.** Medir em CARACTERES e contar só as perguntas ATIVAS (algumas foram desativadas na migration 390).
- **Marketing Digital MÉDIO — RESERVADO à sessão de Marketing fácil/médio que fez os lotes 1 e 2 do fácil (10/10 02:10, a pedido do dono): não pegar.** 98 perguntas ativas (seeds `seed_marketing_digital_medio_v*`), todas sem explicação, em lotes de ~25, **migrations 510 a 519** (lote 1 = 510/511; lote 2 = 512/513; lote 3 = 514/515; lote 4 = 516/517, que fecha o médio). Mesma regra de sempre: a certa não muda; explicação com raciocínio (nível médio, mais profunda que a do fácil); medir em CARACTERES e só as ATIVAS; rascunhos em `docs/quiz-lotes-alternativas/marketing-medio-loteNN.md`. A sessão que está no **fácil lote 3 (504/505)** segue só o fácil e **não faz o médio sem avisar aqui**. **Médio lote 1 FEITO (10/10; v1#2 a v1#26, 25 ativas; migrations 510 e 511; rascunho `marketing-medio-lote01.md`):** 72 alternativas e 25 explicações (com raciocínio, nível médio); Marketing médio passou de 89,8% para 73,5% de "correta mais longa" e as reprovadas de 90 para 68; no lote, correta mais longa em 5 de 25 e mais curta em 1 de 25. **PRÓXIMO: médio lote 2** = v1#27 e v1#28 (as 3 ativas que sobram do v1, se houver) + as primeiras do v2 até completar 25 (migrations 512 e 513); depois v3 (31), v4 (9), v5 (1), v6 (1). Contar só perguntas ATIVAS ainda sem explicação.
- **Marketing Digital DIFÍCIL — RESERVADO a este chat (10/10 01:32, a pedido do dono; divisão por nível, como na IA): não pegar.** Perguntas: todas as ATIVAS dos seeds `seed_marketing_digital_dificil_v1` a `v4` (105 ativas; 1 foi desativada na migration 390), em lotes de ~25, **migrations 520 a 527** (lote 1 = 520/521: v1 ativas + v2#1; lote 2 = 522/523; lote 3 = 524/525; lote 4 = 526/527, que fecha o difícil). A outra sessão de Marketing segue com fácil e médio (faixa 500 a 519) e **não faz o difícil**; se chegar lá, avisar aqui primeiro. Regras: a certa não muda; explicação com raciocínio e relação entre conceitos (nível difícil); medir em caracteres e só as ATIVAS; rascunhos em `docs/quiz-lotes-alternativas/marketing-dificil_loteNN.md`. **Feito:** difícil lote 1 FEITO (as 24 ativas do seed dificil_v1 e a v2#1; migrations 520 e 521): 75 alternativas e 25 explicações; no lote, correta mais longa em 6 de 25 (era 25 de 25). **Próximo:** lote 2 = v2#2 a v2#25 e v3#1 (migrations 522 e 523); depois lote 3 (v3#2 a 26, 524/525) e lote 4 (v3#27 a 44 e v4, 526/527), que fecha o difícil.
- **Medição inicial do validador (CI, 2026-10-07, 1.659 perguntas ativas):** correta mais longa em **89,4%**;
  **1.457 perguntas reprovam** nos critérios. Por grupo (% correta mais longa): Finanças fácil 88, médio 90, difícil 98;
  IA fácil 76, médio 90, difícil 97,1; Marketing fácil 91, médio 90, difícil 97,2; Produtividade fácil 75, médio 93,2,
  difícil 83; Tecnologia fácil 86, médio 94,2, difícil 93. Nenhum grupo cumpre a meta (<= 35%). Pior: Finanças difícil (98%).

## BE-004 — Feedback pedagógico: explicação em cada pergunta (quiz v2)

A coluna `questions.explanation` existe (migration 022) mas está vazia nas 1.659 perguntas, e a
resposta do quiz não a devolve. Devolver, só depois de responder: resposta correta, "Por quê?",
"O que aprender" e dica opcional, adaptados à dificuldade. Conteúdo: escrever as explicações
por categoria, começando por uma (decisão do dono pendente: qual primeiro). Sem explicação, usar
um feedback genérico seguro enquanto o conteúdo não existir.

**Progresso das explicações (atualizar a cada push).** Decisão do dono: começar por Finanças; ordem
fácil → médio → difícil; lotes de 10 perguntas (o dono pediu 10 em 2026-10-06), e cada lote = migration + testes + commit + push +
esta atualização. Dentro de cada dificuldade segue-se a ordem dos seeds e, em cada seed, a ordem das
perguntas no ficheiro. A explicação é o "Por quê?" (coluna `questions.explanation`), curta e em
linguagem simples nas fáceis.
- Finanças fácil (seeds 045 → 064 → 068 → 094 → 099; 100 perguntas no banco): **CONCLUÍDO** — as 100
  explicações escritas (migrations 109 a 120).
- Finanças médio (seeds 046 → 065 → 069 → 100; 100 perguntas no banco): **CONCLUÍDO** — as 100
  explicações escritas (migrations 120 a 130). Nota de qualidade: os lotes 13 a 22 (migrations 120 a
  129) seguiram o estilo curto das fáceis (definição + "não é X"); a especificação pede, para médio,
  raciocínio e contexto. Só o seed 100 (lote 23) já segue isso. Reescrever as 95 anteriores, se o dono
  quiser, exige um UPDATE que sobrescreva (as migrations atuais nunca sobrescrevem).
- Finanças difícil (seeds 047 → 073 → 074 → 075 → 083): **CONCLUÍDO** — todas as perguntas dos seeds 047, 073, 074, 075 e 083 têm explicação (migrations 130 a 140; o lote 33, migration 140, fechou com 6 perguntas). **Finanças (fácil, médio e difícil) está terminada** em explicações. Falta só conferir, no banco de produção, se sobra alguma pergunta ativa de Finanças sem explicação (perguntas fora desses seeds).
- **ORDEM DECIDIDA PELO DONO (2026-10-07), a seguir sem perguntar de novo:**
  1. **Finanças, só correção das alternativas** (301 perguntas, que já têm explicação): fácil → médio → difícil,
     lotes de 25 com revisão do dono ANTES da migration, seguindo `docs/quiz-v2-alternativas-padrao.md`; **regra do dono: a certa e a explicação NÃO mudam, só se ajustam as erradas**
     (fácil 88%, médio 90%, difícil 98% com a correta mais longa). Ordem das perguntas: a dos seeds (fácil: 045 → 064 → 068 → 094 → 099).
  2. **IA** (fácil → médio → difícil): em cada lote, explicações **e** alternativas juntas (a pergunta é tocada uma só vez).
  3. Depois: Marketing Digital, Produtividade e Tecnologia, também com as duas coisas juntas (ordem entre elas a decidir pelo dono).
  Cada lote = migration + teste + relatório do validador (antes/depois) + commit + push + deploy do backend + esta atualização. Próxima migration: 146.
- **Tecnologia (faixa de migrations 300+; explicações + alternativas juntas, lotes de 25):** integrado no `main` (rascunhos para revisão visual em `docs/quiz-lotes-alternativas/tecnologia-*.md`; migrations de alternativas e de explicações em pares; testes passam). **Tecnologia fácil (100) e médio (120) CONCLUÍDOS** (migrations 300 a 317). Difícil: lotes 1 a 4 feitos (seeds `dificil_v1`, `dificil_v2` e `dificil_v3` inteiros; migrations 318 a 325) — **TECNOLOGIA CONCLUÍDA**. **Lote 4 FEITO (08/10, a pedido do dono, por outra sessão que pegou a reserva):** `dificil_v2` perguntas 26 a 48 + `dificil_v3` 1 e 2, migrations **324 e 325**, rascunho `docs/quiz-lotes-alternativas/tecnologia-dificil_lote04.md`. A correta passou de 92% (23 de 25) para 32% (8 de 25) de "mais longa", 0 reprovadas, 75 alternativas e 25 explicações. O lote 3 (322 e 323) já estava no `main`. Com os dois, Tecnologia fica 100% (explicações e alternativas); não há mais nenhum lote de Tecnologia por fazer. A migration 390 do outro fluxo desativou 5 duplicadas de Tecnologia (2 fáceis, 3 médias); as minhas migrations convivem com ela. **Ajuste residual (migration 326, 09/10):** 7 perguntas do lote 4 ainda tinham pistas leves de linguagem; corrigidas (14 alternativas erradas; a certa e a explicação não mudaram), e Tecnologia ativa fica com **0 reprovadas, 0 pistas de viés e a correta mais longa em 21%**. Resumo de todos os lotes em `docs/quiz-lotes-alternativas/tecnologia-resumo.md`; todos os rascunhos de Tecnologia estão GRAVADOS no `main` (não há revisão pendente).
- **IA (faixa de migrations 400+; explicações + alternativas juntas, lotes de 25) — em sessão própria (2026-10-07); Finanças (144+), Produtividade (200+) e Tecnologia (300+) já tinham sessões.** Cada lote = 2 migrations (`NNN_alternativas_ia_...` e `NNN+1_explicacoes_ia_...`) + rascunho em `docs/quiz-lotes-alternativas/ia-...` + testes (`quiz-alternatives-lotes` e `quiz-explanations-ia`, genéricos). **Feito:** fácil lote 1 (22 perguntas ativas do seed v1 — a 040#10 está desativada, migration 390 — e as 3 primeiras do v2; migrations 400 e 401): a certa passou de 75,8% para 60,6% de "mais longa" no grupo IA fácil e as reprovadas de 74 para 53; no lote, correta mais longa em 6 de 25 e mais curta em 5 de 25. Do lote só 1 ainda reprova, por `explicacao_embutida_na_correta` ("Por que devemos verificar informações produzidas por IA?": a certa começa por "Porque"; mesmo caso da decisão pendente do dono em Finanças médio). **Fácil lote 2 FEITO (migrations 402 e 403; rascunho `docs/quiz-lotes-alternativas/ia-facil-lote02.md`):** as 3 que sobravam do seed v2 + as 22 primeiras do v3; 60 alternativas e 25 explicações; no lote, as reprovadas passaram de 18 para 0 (pistas de viés de 15 para 0) e a correta é a mais longa em 5 de 25. No grupo IA fácil as reprovadas passaram de 52 para 34 e a correta mais longa de 60,6% para 48,5%; total geral de 836 para 818. **Fácil lote 3 FEITO (migrations 404 e 405; rascunho `docs/quiz-lotes-alternativas/ia-facil-lote03.md`):** `seed_ia_facil_v3` perguntas 23 a 47; 63 alternativas e 25 explicações; no lote, reprovadas de 20 para 0 (pistas de viés de 21 para 0), correta mais longa em 7 de 25. Primeira versão deixava a correta mais longa em 13 de 25 apesar de passar no validador; alonguei uma errada em 7 perguntas até ficar em 7 (**medir sempre a % de "mais longa", não só as reprovadas**). No grupo IA fácil: reprovadas de 34 para 14 e correta mais longa de 48,5% para 35,4%. **Fácil lote 4 FEITO (09/10; migrations 406 e 407; rascunho `docs/quiz-lotes-alternativas/ia-facil-lote04.md`):** as 24 últimas perguntas ativas de IA fácil (v3 48 a 56, v4, v5, v6, v7); 65 alternativas erradas e 24 explicações; a certa e as explicações já feitas não mudaram. **IA FÁCIL CONCLUÍDO** (medir % no CI do push). **Médio lote 1 FEITO (10/10; seed_ia_medio_v1, as 25 primeiras sem explicação, na ordem do ficheiro 041; migrations 408 e 409; rascunho `ia-medio-lote01.md`):** 75 alternativas e 25 explicações. **Médio lote 2 FEITO (10/10; v1 as 4 últimas, v2 as 5, v3 as 16 primeiras; migrations 410 e 411; rascunho `ia-medio-lote02.md`).** **Médio lote 3 FEITO (10/10; v3 de "aprendizado por reforço" a "engenharia de características"; migrations 412 e 413; rascunho `ia-medio-lote03.md`).** **Médio lote 4 FEITO (10/10; as 24 últimas: v3 de "seleção de características" a "explicabilidade", 1 do v4 e 1 do v5; migrations 414 e 415; rascunho `ia-medio-lote04.md`) — IA MÉDIO CONCLUÍDO (99 explicações, falta só medir no CI).** **IA difícil, de CIMA para baixo (esta sessão, migrations 416 a 419; o outro chat vai de BAIXO para cima na faixa 420 a 431):** lote 1 = as 25 primeiras de IA difícil sem explicação (seeds 080, 081 e seguintes, na ordem dos ficheiros; migrations 416 e 417), lote 2 = as 25 seguintes (418 e 419). Antes de cada lote ler este ficheiro: se o outro chat já tiver feito as perguntas do meio, parar e deixar o resto para ele (o `explanation IS NULL` torna a migration segura, mas não duplicar trabalho). A sessão de IA anterior parou; esta continua IA lote a lote (pedido do dono, 09/10 18:51), NÃO duplicar. Reserva de IA feita por outro chat do dono em 10/10 RETIRADA: a sessão de IA que já fez os lotes 1 e 2 do médio continua com IA fácil/médio, de cima para baixo; por pedido posterior do dono (10/10, "vai de baixo pra cima") o IA DIFÍCIL está reservado a outro chat, ver a linha seguinte.)**
- **IA DIFÍCIL — RESERVADO a outro chat do dono (10/10, pedido: "vai de baixo pra cima, as de IA"), migrations 420 a 431; a sessão de IA fácil/médio NÃO deve fazer o difícil.** Perguntas ativas de IA difícil ainda sem explicação (135) em lotes de 25 (6 lotes), mesma regra (a certa nunca muda; explicações e alternativas juntas; cada lote = 2 migrations `NNN_alternativas_ia_dificil_...` e `NNN+1_explicacoes_ia_dificil_...` + rascunho `docs/quiz-lotes-alternativas/ia-dificil-loteNN.md` + testes genéricos; medir também a % de "correta mais longa"). A sessão do médio segue de cima para baixo (fácil, médio); este chat vai de baixo para cima (difícil e, se chegarmos lá, o fim do médio, que será reservado aqui antes de começar). **Feito:** nenhum lote ainda.

Parte técnica **feita**: `submitAnswer` já devolve `feedback` ({ correctAlternativeId,
correctAlternativeLabel, explanation }) depois de responder, só se a pergunta foi entregue ao
utilizador (senão `null`, para ninguém colher respostas por id), e a tela de resultado mostra-o.
`explanation` é `null` nas perguntas ainda sem texto: aí a tela mostra só a resposta correta.
Decisão do dono: um único texto de explicação serve para acerto ("Para complementar") e erro
("Por quê?"). Falta, só se o dono quiser: "O que aprender" e "Dica" como campos próprios (exigiria
colunas novas e reescrever as explicações já feitas).
