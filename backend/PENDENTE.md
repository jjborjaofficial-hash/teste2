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
   aprovação. As perguntas novas só entram se passarem no validador.
6. Reforço **FEITO (2026-10-06, pedido do dono):** a ordem das alternativas é aleatória a cada
   apresentação (`ORDER BY random()` em `quizRepository.getRandomQuestion` e `getQuestionById`); a
   validação usa o id da alternativa, não a posição. Teste: `tests/quiz-alternatives-shuffle.test.js`.
   Nota: ao recarregar a página a mesma pergunta volta com nova ordem (aceite).

**Decisão do dono (2026-10-06):** começar pelo validador (passo 1). Passos 2 em diante só depois do
validador feito e do dono rever o relatório.

**Progresso da regularização (atualizar a cada push):**
- Passo 1 (validador): **FEITO, falta rever o relatório**. Código em
  `backend/src/modules/quiz/validation/alternativesValidator.js`, script `npm run quiz:validate`
  (`-- --list` lista as reprovadas, `-- --json` dá JSON) e teste `backend/tests/quiz-alternatives-validator.test.js`.
  Só leitura. O CI roda o relatório a cada push (passo "Relatório do validador" em Actions), então
  o antes/depois de cada lote fica no log do GitHub. Critérios ajustáveis em `CRITERIA` no mesmo ficheiro.
- Passo 2 (corrigir alternativas em lotes de 25, só `question_alternatives.label`): **não começou**.
  **Próximo:** abrir o relatório do CI, registar aqui a medição inicial por grupo e propor ao dono as
  25 primeiras de Finanças fácil para ele rever antes da migration.
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
- **PRÓXIMA CATEGORIA (decidido pelo dono em 2026-10-07): IA.** Começar por IA fácil, depois médio e difícil, em lotes de 10 (próxima migration: 141), seguindo a ordem dos seeds e das perguntas no ficheiro. Depois de IA: Marketing Digital, Produtividade e Tecnologia (ordem a decidir pelo dono).

Parte técnica **feita**: `submitAnswer` já devolve `feedback` ({ correctAlternativeId,
correctAlternativeLabel, explanation }) depois de responder, só se a pergunta foi entregue ao
utilizador (senão `null`, para ninguém colher respostas por id), e a tela de resultado mostra-o.
`explanation` é `null` nas perguntas ainda sem texto: aí a tela mostra só a resposta correta.
Decisão do dono: um único texto de explicação serve para acerto ("Para complementar") e erro
("Por quê?"). Falta, só se o dono quiser: "O que aprender" e "Dica" como campos próprios (exigiria
colunas novas e reescrever as explicações já feitas).
