# Atualização do Quiz: Ensino + Aprendizagem (Instrução Mestre)

Este documento é a **fonte única de verdade** da atualização do quiz da plataforma
Aprenda e Ganhe. Foi consolidado a partir dos dois briefings do proprietário. Onde
os dois diferiam, vale a **regra definitiva** (rodada de 10 perguntas, ver secção 3).

O estado do trabalho (o que já foi feito e o que falta) está em
[`PROGRESSO_QUIZ.md`](./PROGRESSO_QUIZ.md). **Leia os dois ficheiros antes de editar.**

---

## 0. Como retomar numa nova sessão

1. Clonar o repositório (público) e mudar para a branch `feat/quiz-aprendizagem`.
2. Ler este ficheiro e `PROGRESSO_QUIZ.md` (secção "Próximo bloco").
3. Continuar do ponto em que parou. Não é preciso reenviar a instrução.
4. Para o `git push` é preciso um token GitHub temporário (ver secção 14).

Mensagem sugerida para abrir a nova sessão:

> Leia `docs/quiz-aprendizagem/INSTRUCAO_QUIZ.md` e `PROGRESSO_QUIZ.md` no repositório
> `jjborjaofficial-hash/teste2` (branch `feat/quiz-aprendizagem`) e continue do próximo bloco.

---

## 1. Objetivo

O quiz deixa de ser só "certo/errado" e passa a ser uma experiência real de
**ensino + aprendizagem**: o utilizador não está apenas a responder, está a aprender.

Regras gerais:

- Não recriar o projeto nem trocar a arquitetura sem necessidade.
- Não remover funcionalidades existentes.
- Não alterar autenticação, saldo MZN, XP, Pontos, missões, ranking ou outras
  funcionalidades sem necessidade.
- Primeiro analisar o código, depois implementar de forma compatível.
- Testar tudo, registar no Git, fazer push (secção 11).
- Se encontrar trabalho feito antes por outra pessoa ou IA, preservá-lo e analisar antes de mexer.
- Não usar emojis. Manter o design atual e reutilizar componentes existentes.

## 2. Fluxo por pergunta

```
PERGUNTA -> UTILIZADOR RESPONDE -> SERVIDOR VALIDA -> RESULTADO
         -> EXPLICAÇÃO DIDÁTICA -> UTILIZADOR APRENDE/REVÊ -> PRÓXIMA PERGUNTA
```

Rápido e natural. Não transformar cada pergunta numa aula.

## 3. Estrutura definitiva do quiz (REGRA DEFINITIVA)

- **Rodada = EXATAMENTE 10 perguntas.** É a unidade normal de jogo.
- **Resumo da rodada** só aparece **depois da 10.ª pergunta**.
- **5 perguntas = checkpoint técnico/de persistência**: o servidor grava/verifica o
  progresso e o utilizador continua. **Não** mostra resumo e **não** finaliza nada.
- Contador sempre "Pergunta N de 10". Após a 5.ª mostra "5 de 10" e continua. Nunca
  mostrar "5 de 5".
- Quiz com mais de 10 perguntas divide-se em rodadas de 10 (ex.: 30 = 1–10, 11–20, 21–30).
  Se o total não for múltiplo de 10, a última rodada pode ter o restante, desde que a
  arquitetura suporte.
- Ao concluir todas as rodadas, mostrar o **resumo final consolidado** (não só da última rodada).

Não confundir: 5 alterações de código = checkpoint do Git (secção 11). 5 perguntas =
checkpoint técnico do quiz. 10 perguntas = fim da rodada + resumo.

## 4. Feedback pedagógico após CADA resposta

O resumo da rodada **não substitui** a explicação individual.

**Se acertar** (acerto = confirmação + aprofundamento):

```
CORRETO -> por que está certa -> complemento -> conceito a reter -> próxima pergunta
```

**Se errar** (erro = correção + aprendizagem; nunca humilhante):

```
RESPOSTA INCORRETA -> resposta correta -> por que é correta
 -> por que a escolhida estava errada (quando útil)
 -> o que aprender (conceito principal) -> dica para memorizar -> próxima pergunta
```

Tom: o erro é parte do processo de aprendizagem. Sem mensagens negativas ou humilhantes.

**Profundidade conforme a dificuldade** (qualidade acima de tamanho):

| Dificuldade | Explicação |
|---|---|
| Fácil | curta, linguagem simples, conceito fundamental |
| Média | um pouco mais desenvolvida, explica o raciocínio |
| Difícil | raciocínio e relações entre conceitos quando necessário |
| Especialista | técnica, contextualizada, com consequência ou aplicação (hoje o banco só tem fácil/médio/difícil) |

## 5. Resumos

**Resumo da rodada (após 10 perguntas):** perguntas respondidas, acertos, erros, % de
aproveitamento, XP obtido, recompensas (quando aplicável), categorias/conceitos com
melhor desempenho, conceitos com mais erros, recomendação de revisão, progresso da
rodada, botão para continuar para a próxima rodada quando existir.

**Resumo final do quiz:** total de perguntas, acertos, erros, % de aproveitamento,
percentagem por rodada, XP total, recompensas, missões/progresso relacionado (se
aplicável), melhor categoria, o que rever, evolução (se houver dados), mensagem final.

Exemplo de estrutura (texto, sem emojis):

```
Rodada concluída
10 perguntas respondidas | 8 acertos | 2 erros | 80%
Melhor desempenho: Tecnologia
Vale a pena rever: Segurança digital
+XP        [Continuar]
```

## 6. Qualidade das alternativas (problema crítico)

Problema detetado: a alternativa correta tende a ser bem mais longa e detalhada que
as erradas, permitindo acertar sem saber a matéria. **Auditado: a correta é a mais
longa em 89,4% das perguntas** (ver `PROGRESSO_QUIZ.md`).

Regras de construção:

- A correta não pode ser sistematicamente a mais longa, nem a mais curta, nem a que tem mais detalhes.
- Mesma estrutura linguística em todas; sem palavras que denunciem a resposta.
- As erradas devem ser plausíveis e do mesmo conceito.
- Nível semelhante de elaboração em todas.
- Não basta contar caracteres: analisar também nº de palavras, estrutura da frase,
  nível de detalhe, quantidade de informação, termos técnicos, explicações extra,
  exemplos, palavras absolutas ou óbvias e outros padrões reveladores.

**Geração de perguntas:** não gerar primeiro a correta e depois erradas simples.
Definir o conceito avaliado, gerar todas as alternativas em conjunto com nível
semelhante, definir a correta, validar o conjunto.

## 7. Validador automático

Antes de uma pergunta entrar no banco, verificar:

1. Número de alternativas correto.
2. Exatamente uma correta.
3. A correta está entre as alternativas.
4. Sem alternativas duplicadas.
5. Sem alternativas praticamente iguais.
6. A correta não é bem maior que todas.
7. A correta não é bem menor que todas.
8. A correta não tem explicação adicional que as outras não têm.
9. As erradas são plausíveis.
10. A posição da correta não segue padrão previsível.
11. Linguagem de nível semelhante.
12. Nenhum padrão óbvio que permita acertar sem conhecimento.

Se falhar: **rejeitar ou enviar para revisão**. Perguntas claramente enviesadas não
podem ser publicadas automaticamente.

## 8. Posição da resposta correta e segurança

- A posição da correta deve ser aleatória e bem distribuída (hoje a distribuição já é
  ~25% por posição; manter e impedir padrões nas novas perguntas).
- A aleatorização não pode quebrar a validação por `alternative_id`.
- **Nunca confiar na posição visual.** O backend é a fonte de verdade.
- Não enviar ao frontend `correctAnswer`, `correctOption`, `isCorrect` ou equivalente
  antes de o utilizador responder (a API atual já cumpre isto; manter). A resposta
  correta e a explicação só são devolvidas **depois** de a resposta ser registada.

## 9. Controlo de progresso (persistente)

O sistema deve saber de forma confiável: quantas perguntas foram respondidas, onde
começa a rodada atual, quantas faltam para o checkpoint, se a rodada/quiz terminou e
se o resumo já foi mostrado. **Não depender só de variáveis visuais do frontend**:
usar estado persistente/dados do backend, para que recarregar a página recupere o estado.

## 10. Métricas de aprendizagem (leve e extensível)

Se a arquitetura permitir sem grande complexidade, registar: perguntas respondidas,
acertos, erros, categoria, dificuldade, tempo de resposta, conceitos que geraram erro,
evolução. Servem para futura personalização e dificuldade adaptativa. Não construir
uma arquitetura gigante só para isto.

## 11. Regra de Git e registo

Ciclos de trabalho:

```
ANALISAR -> IMPLEMENTAR -> TESTAR -> COMMIT -> PUSH -> REGISTAR EM PROGRESSO_QUIZ.md
```

- **Checkpoint normal:** a cada ~5 alterações/itens concluídos e testados.
- **Checkpoint estrutural:** ao concluir uma secção importante, mesmo com menos de 5.
- **Checkpoint final:** ao concluir o quiz/feature (commit final, push, resumo completo).
- Nunca fazer commit de código quebrado só para atingir 5. Qualidade primeiro.
- Antes de cada commit: `git status`, rever diferenças, testes e build.
- Commits claros, por exemplo `feat(quiz): improve learning feedback`,
  `feat(quiz): add answer quality validation`.
- **Depois de cada checkpoint, atualizar `PROGRESSO_QUIZ.md`** (feito, testado, commit,
  push, próximo bloco) e incluir essa atualização no mesmo push ou num commit logo a seguir.

Relatório após cada checkpoint:

```
CHECKPOINT: ...
IMPLEMENTADO: ...
TESTADO: ...
COMMIT: ...
PUSH: sucesso/erro
PRÓXIMO BLOCO: ...
```

Relatório final: arquivos alterados, funcionalidades, testes, problemas encontrados e
corrigidos, commit final, push.

## 12. Testes obrigatórios

1. Utilizador acerta: resposta correta, explicação complementar, avanço correto.
2. Utilizador erra: incorreta, resposta correta, explicação, aprendizagem, avanço.
3. Completar 5 perguntas: checkpoint técnico, contador "5 de 10", sem resumo, progresso correto.
4. Completar 10 perguntas: resumo da rodada com contagem correta.
5. Continuar depois do resumo: próxima rodada, contador reiniciado.
6. Finalizar todas as rodadas: resumo final consolidado.
7. Alternativa correta muito maior: o validador deteta o viés.
8. Posição previsível da correta: o sistema corrige/aleatoriza.
9. Alternativas duplicadas: rejeição ou revisão.
10. Recarregar a página durante o quiz: o estado é recuperado.

Dizer claramente quando um teste não puder correr no ambiente (ex.: sem Postgres/Redis).
Nunca afirmar que passou sem ter corrido.

## 13. Fases de execução

1. Analisar o projeto existente.
2. Identificar os ficheiros a modificar.
3. Feedback pedagógico (certo/errado).
4. Checkpoint técnico de 5 perguntas.
5. Rodada de 10 e resumo da rodada.
6. Persistência/recuperação do estado.
7. Resumo final do quiz.
8. Auditar a lógica das alternativas.
9. Validador contra pistas de comprimento/estilo/posição.
10. Conteúdo: corrigir alternativas enviesadas e preencher explicações, por lotes.
11. Testes.
12. Commits por checkpoint e push.

## 14. Token do GitHub (segurança)

- O repositório é público: o clone não precisa de token; o **push** precisa.
- O proprietário cria um fine-grained token de 7 dias, limitado ao repositório, com
  **Contents: Read and write**, e apaga-o depois do uso.
- O token **nunca** é gravado em ficheiros, no `.git/config`, na memória ou neste
  repositório. Usa-se só por comando (header HTTP temporário).
- Se o token tiver sido colado numa conversa, apagá-lo no GitHub quando terminar.

## 15. Critérios de conclusão

A tarefa só está concluída quando: o fluxo pedagógico funciona; erros ensinam; acertos
complementam; o checkpoint de 5 e a rodada de 10 funcionam; os resumos de rodada e
final funcionam; as alternativas não denunciam a correta; os testes passam; tudo está
no Git e enviado ao GitHub; e o relatório final foi apresentado.
