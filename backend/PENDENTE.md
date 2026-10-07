# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-005 — Sobras das rodadas do quiz v2

BE-002 (rodadas no servidor: migration 107, `quiz_rounds`, seleção das 10, retomar ao recarregar,
resumo só da rodada) já foi feito e testado. Sobram: (a) a rota antiga
`GET /quiz/categories/:id/next-question` + `POST /quiz/answers` sem `roundId` continua a servir
perguntas fora de rodada; o frontend já não os usa (usa só `/quiz/rounds`); decidir se o servidor passa a
exigir `roundId` e remover `nextQuestion` de `frontend/src/api/quizApi.js`; (b) não existe tipo de missão "completar uma rodada" (hoje o progresso das
missões conta por resposta certa); (c) guardar os conceitos errados por rodada para
recomendações (hoje só há `reviewStatements` no resumo).

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
  quase iguais** (lista para o dono decidir em `docs/quiz-duplicadas-para-revisao.md`; nada foi apagado); 0 defeitos estruturais; 0
  "todas/nenhuma das anteriores". A pista mais comum fora o tamanho é `palavras_desequilibradas` (aviso, 1.199 perguntas).
  **Decisões do dono pendentes:** (a) o que fazer com os 18 pares quase iguais; (b) pôr `npm run quiz:audit` também no CI
  (`.github/workflows/testes.yml`; não foi mexido: alterar workflows exige uma permissão a mais no token de push).
- Passo 2 (corrigir alternativas em lotes de 25, só `question_alternatives.label`): **EM ANDAMENTO**. Finanças fácil lote 1 (perguntas 1 a 25 do seed 045; 56 alternativas erradas ajustadas) aprovado pelo dono em 2026-10-07 e gravado na migration 141 (`tests/quiz-alternatives-financas-facil-lote01.test.js`). Rascunhos dos lotes: `docs/quiz-lotes-alternativas/`.
  **Lotes feitos:** Finanças fácil lote 1 (migration 141), lote 2 (142) e lote 3 (143, perguntas 18 a 42 do seed 064). **AUTORIZAÇÃO DO DONO (2026-10-07):
  gravar cada lote direto, sem esperar aprovação** (ele já validou a regra); avisá-lo depois e deixar o rascunho em
  `docs/quiz-lotes-alternativas/` para ele conferir. **PRÓXIMO: Finanças fácil lote 4** (seguintes 25 perguntas: as 17 que sobram do seed 064
  (da 43.ª à 59.ª), as 3 do seed 068 e as 5 primeiras do seed 094; depois 094 → 099), migration 144, e assim até acabar Finanças fácil, médio e difícil.
  Cada lote: rascunho em `docs/quiz-lotes-alternativas/` (tabela com a coluna "Seed" no formato 064#18) → migration gerada
  a partir da tabela (a certa nunca muda) → `tests/quiz-alternatives-lotes.test.js` (cobre todos os lotes) → push → CI verde →
  deploy do backend → atualizar este bloco.
- **Produtividade (penúltima categoria) — feita em paralelo, por outra sessão, a pedido do dono (2026-10-07).** Explicações **e** alternativas juntas, em lotes de 25, com a regra do dono (a certa não muda). Usa a **faixa de migrations 200+** (Finanças segue em 144+), para as duas sessões não colidirem. Cada lote = 2 migrations (`NNN_alternativas_produtividade_...` e `NNN+1_explicacoes_produtividade_...`) + rascunho em `docs/quiz-lotes-alternativas/produtividade-...` + testes (`quiz-alternatives-lotes` e `quiz-explanations-produtividade`, genéricos). **Feito:** fácil lote 1 (seed v1, 25 perguntas; migrations 200 e 201): a certa passou de 75% para 62,8% de "mais longa" no grupo Produtividade fácil e as reprovadas de 105 para 81. **PRÓXIMO: fácil lote 2** = seeds v2 (12) + v3 (13), migrations 202 e 203; depois v4 (42), v5 (7), v6 (1), v7 (48); depois médio e difícil. Medir em CARACTERES (é o que o validador faz), não em palavras: a certa tem de ser a mais longa em no máximo ~30% das perguntas do lote.
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
  Cada lote = migration + teste + relatório do validador (antes/depois) + commit + push + deploy do backend + esta atualização. Próxima migration: 144.

Parte técnica **feita**: `submitAnswer` já devolve `feedback` ({ correctAlternativeId,
correctAlternativeLabel, explanation }) depois de responder, só se a pergunta foi entregue ao
utilizador (senão `null`, para ninguém colher respostas por id), e a tela de resultado mostra-o.
`explanation` é `null` nas perguntas ainda sem texto: aí a tela mostra só a resposta correta.
Decisão do dono: um único texto de explicação serve para acerto ("Para complementar") e erro
("Por quê?"). Falta, só se o dono quiser: "O que aprender" e "Dica" como campos próprios (exigiria
colunas novas e reescrever as explicações já feitas).
