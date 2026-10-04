# Atualização do Quiz: Ensino + Aprendizagem (Instrução Mestre, versão 2)

Fonte única de verdade da atualização do quiz do Aprenda e Ganhe. Consolida os três
briefings do proprietário. **Onde houver conflito, vale o briefing mais recente (este)**:

- Não existe "quiz completo": **cada rodada de 10 perguntas é independente**.
- **Não há resumo final** que junte rodadas (nem do dia, nem da sessão).
- O resumo da rodada tem **exatamente 3 botões** (secção 8).

Estado do trabalho e lista de pedaços pequenos: [`PROGRESSO_QUIZ.md`](./PROGRESSO_QUIZ.md).
**Leia os dois ficheiros antes de editar.**

> Nota: o 3.º briefing recebido terminou no "TESTE 9" (cortado). Se existia mais texto
> (testes 9 e 10 e o fecho), pedir ao proprietário para reenviar.

---

## 0. Como retomar numa nova sessão

1. Clonar o repositório (público) e usar a branch `feat/quiz-aprendizagem`.
2. Ler este ficheiro e `PROGRESSO_QUIZ.md` (secção "Próximos pedaços").
3. Pegar o primeiro pedaço pendente da lista e fazer só esse.
4. Para o `git push` é preciso um token temporário (secção 17).

Mensagem sugerida para abrir a nova sessão:

> Leia `docs/quiz-aprendizagem/INSTRUCAO_QUIZ.md` e `PROGRESSO_QUIZ.md` no repositório
> `jjborjaofficial-hash/teste2` (branch `feat/quiz-aprendizagem`) e continue do próximo pedaço.

## 1. Objetivo e regras gerais

O quiz passa de "certo/errado" a **aprendizagem + feedback + progresso + gamificação**:
cada resposta ensina alguma coisa.

- ACERTO = confirmar + complementar + aprofundar.
- ERRO = corrigir + explicar + ensinar o conceito (nunca humilhante).

Regras:

- Trabalhar sobre o projeto existente; não recriar nem trocar a arquitetura sem necessidade.
- Não remover funcionalidades; não alterar autenticação, XP, Pontos, saldo MZN, missões,
  ranking, notificações ou outras áreas sem necessidade.
- Analisar antes de alterar; reutilizar componentes, serviços, endpoints e modelos.
- Não criar segunda implementação do que já existe.
- Não usar emojis. Manter o design atual.

## 2. Conceito oficial de rodada

- O banco de perguntas é contínuo. Ao entrar numa categoria (ex.: Inteligência Artificial)
  começa uma **nova rodada de 10 perguntas** selecionadas pelo sistema.
- Cada rodada é uma unidade independente, com o seu próprio resultado. Pode repetir-se
  indefinidamente (IA, depois IA outra vez, depois Tecnologia, etc.).
- **Não criar:** quiz fixo de 30 perguntas, 3 rodadas agrupadas, resumo das rodadas do dia,
  resumo de uma sessão, ou qualquer "quiz completo".

## 3. Seleção das 10 perguntas

Ao entrar na categoria, selecionar/recomendar 10 perguntas respeitando: categoria,
dificuldade (variedade), perguntas já respondidas, perguntas apresentadas recentemente,
progresso do utilizador, regras de repetição existentes e disponibilidade.

- Nunca repetir perguntas dentro da mesma rodada.
- Evitar repetir as vistas recentemente; respeitar o histórico do utilizador.
- Não alterar o banco de perguntas sem necessidade.
- Guardar as perguntas da rodada e a posição atual para a rodada poder ser retomada.

## 4. Contador e checkpoint dos 5

- Mostrar 1/10, 2/10 ... 10/10.
- Aos 5: **não** mostrar resumo, **não** terminar a rodada, **não** iniciar outra. Continua
  normalmente. (Internamente é só um checkpoint de persistência.)
- A rodada só termina depois da 10.ª pergunta.

## 5. Feedback depois de CADA pergunta

Fluxo: PERGUNTA -> RESPOSTA -> VALIDAÇÃO -> FEEDBACK -> EXPLICAÇÃO -> PRÓXIMA.

**Acerto:** "Correto!" + "Você identificou a resposta certa." + "Para complementar:"
(informação adicional) + "Aprenda:" (conceito ou detalhe importante). Curto, para não
interromper o fluxo. ACERTO = CONFIRMAÇÃO + COMPLEMENTO.

**Erro:** "Resposta incorreta." + "Resposta correta:" + "Por quê?" (explicação) +
"O que aprender:" (conceito principal) + quando útil "A sua resposta estava incorreta
porque..." + opcionalmente "Dica:" (memorização). ERRO = CORREÇÃO + EXPLICAÇÃO + APRENDIZAGEM.

**Profundidade por dificuldade** (qualidade acima de quantidade):

| Dificuldade | Explicação |
|---|---|
| Fácil | linguagem simples, curta, conceito fundamental |
| Média | explica o raciocínio e contextualiza |
| Difícil | raciocínio e relações entre conceitos quando necessário |
| Especialista | técnica, com contexto, aplicações ou consequências (o banco hoje só tem fácil/média/difícil) |

## 6. Fim da 10.ª pergunta

Primeiro mostrar o feedback pedagógico dessa pergunta, igual às anteriores. Depois:
marcar a rodada como CONCLUÍDA, calcular o resultado, registar o desempenho, atualizar
métricas/recompensas, atualizar as missões aplicáveis e abrir o RESUMO DA RODADA.
**Não** mostrar nova pergunta e **não** iniciar outra rodada automaticamente.

## 7. Resumo da rodada

Representa **exclusivamente** as 10 perguntas daquela rodada: categoria, 10 respondidas,
acertos, erros, % de aproveitamento, XP ganho, recompensas (quando aplicável), melhor
desempenho, conceitos a rever, progresso de aprendizagem e outras métricas já existentes.

## 8. Botões do resumo (EXATAMENTE 3)

1. **Painel inicial** -> Dashboard existente (`/dashboard`). Não inicia rodada nem reabre a categoria.
2. **Escolher novamente uma categoria** -> tela existente de categorias (`/hub-estudos`).
   Não inicia rodada sozinho; só depois de o utilizador escolher a categoria começa a nova
   rodada com 10 perguntas.
3. **Ver missões em andamento** -> tela existente de missões (`/missoes`). Não cria nem
   conclui missões; só leva o utilizador à área de missões, já com o progresso atualizado.

## 9. Histórico das rodadas

Registar cada rodada (sem inventar "quiz completo"): user_id, round_id, categoria,
perguntas apresentadas, respostas, acertos, erros, tempo, XP, recompensas, dificuldade,
conceitos, data/hora, desempenho. Serve para estatísticas, perfil de aprendizagem,
recomendações, evolução e histórico futuros. Sem arquitetura gigante.

## 10. Integração com missões

Usar a lógica existente de missões (responder perguntas, completar uma rodada, login,
permanecer 12 minutos). Não duplicar nem criar segunda implementação. Depois da rodada,
"Ver missões em andamento" mostra a tela atualizada.

## 11. Qualidade das alternativas (problema crítico)

Problema: a correta é identificável por ser mais longa, detalhada, técnica, explicativa ou
estruturalmente diferente. **Auditado: a correta é a mais longa em 89,4% das 1.659 perguntas.**

Regras: a correta não pode ser sistematicamente a mais longa, curta, detalhada, técnica ou
a única explicativa; as erradas devem ser plausíveis e do mesmo conceito, sem absurdos;
todas com nível de elaboração semelhante. Uma pequena diferença de tamanho é aceitável; o
problema é um padrão claro que denuncia a resposta.

Medir mais do que caracteres: palavras, tokens (se disponível), estrutura da frase, nível
de detalhe, quantidade de informação, termos técnicos, explicações embutidas, exemplos,
pontuação, palavras absolutas e outros padrões linguísticos.

Exemplo a rejeitar: correta longa e específica ("É o processo pelo qual sistemas de IA
aprendem padrões a partir de dados para realizar previsões.") contra erradas curtas
("É um programa." / "É um banco de dados." / "É uma rede.").

**Geração por IA:** não gerar a correta e depois distratores simples. Definir o conceito,
gerar todas as alternativas em conjunto, definir a correta, gerar distratores plausíveis,
validar equilíbrio e qualidade, aprovar ou rejeitar.

## 12. Validador automático (16 controlos)

1. Número correto de alternativas. 2. Apenas uma correta. 3. A correta existe.
4. Sem alternativas duplicadas. 5. Sem alternativas quase iguais. 6. Tamanho equilibrado.
7. Estrutura equilibrada. 8. A correta sem explicação extra. 9. Distratores plausíveis.
10. Posição da correta não previsível. 11. Linguagem equilibrada. 12. Sem pistas óbvias.
13. A pergunta tem explicação. 14. A explicação é coerente com a resposta.
15. Categoria correta. 16. Dificuldade coerente.

Se falhar: **rejeitar ou enviar para revisão**; nunca publicar automaticamente.

## 13. Posição da correta e segurança

- A ordem visual das alternativas é aleatória e a posição da correta bem distribuída
  (hoje já ~25% por posição; manter e impedir padrões nas novas).
- O backend continua a saber a correta e a validar por `alternative_id`; nunca confiar na
  posição visual nem no frontend.
- Antes de responder, o frontend não recebe `correctAnswer`, `isCorrect`, `answer_id` correto
  ou equivalente (a API atual já cumpre; manter). Correta e explicação só depois de registada
  a resposta, e só se a pergunta foi entregue ao utilizador (anti-colheita).

## 14. Persistência

A rodada tem estado confiável: iniciada, categoria, 10 perguntas selecionadas, progresso,
respostas, pergunta atual, conclusão. Recarregar a página recupera o estado. Sem perder
nem duplicar respostas por falhas simples de frontend.

## 15. Visual, acessibilidade e UX

Manter o design atual e reutilizar componentes, botões, cards, tipografia, cores, ícones,
animações e navegação. Botões claros, estados de resposta claros, boa leitura, responsivo,
navegação por teclado quando aplicável, feedback visual suficiente, respeitar
`prefers-reduced-motion`. Sem animações excessivas.

## 16. Dados de aprendizagem

Se couber sem complexidade: acertos, erros, categoria, dificuldade, tempo de resposta,
conceitos errados, desempenho por rodada. Preparar o sistema, sem arquitetura gigante.

## 17. Git: PEDAÇOS PEQUENOS, PUSH A CADA UM (regra principal)

Para que, se a sessão atingir o limite, o que já foi feito esteja sempre no GitHub:

```
ESCOLHER 1 pedaço pequeno -> IMPLEMENTAR -> TESTAR -> COMMIT -> PUSH -> REGISTAR no PROGRESSO
```

- Cada pedaço é pequeno (uma ideia, poucos ficheiros). **Commit e push logo que o pedaço
  estiver testado**, sem juntar muitos.
- O limite máximo é ~5 alterações por commit; o normal é menos.
- Depois de cada push, atualizar `PROGRESSO_QUIZ.md` (o que foi feito, o que falta, próximo pedaço).
- Nunca commitar código quebrado. Antes do commit: `git status`, rever diferenças, testes, build.
- Não commitar ficheiros gerados (ex.: dumps do Redis, `dist`, `.env`).
- Commits claros, por exemplo `feat(quiz): ...`, `test(quiz): ...`, `docs(quiz): ...`.

Relatório curto após cada push: IMPLEMENTADO, TESTADO, COMMIT, PUSH, PRÓXIMO PEDAÇO.

## 18. Testes obrigatórios

1. Entrar numa categoria inicia rodada de 10 perguntas.
2. Acertar: feedback correto + complemento/aprendizagem.
3. Errar: correção + explicação + aprendizagem.
4. Chegar à 5.ª: continua normalmente, sem resumo.
5. Responder a 10.ª: feedback, rodada concluída, resumo.
6. Resumo com exatamente os dados daquela rodada.
7. Botão "Painel inicial" abre o Dashboard.
8. Botão "Escolher novamente uma categoria" abre a seleção de categorias.
9. Botão "Ver missões em andamento" abre as missões (com progresso atualizado).
10. Validador: correta muito maior, posição previsível, alternativas duplicadas.
11. Recarregar a página a meio recupera o estado.

Dizer claramente quando um teste não puder correr no ambiente. Nunca afirmar que passou sem ter corrido.

## 19. Token do GitHub (segurança)

O repositório é público (clone sem token); o **push** precisa de token. O proprietário cria
um fine-grained token de 7 dias, só para este repositório, com **Contents: Read and write**,
e apaga-o depois. O token nunca é gravado em ficheiros, `.git/config`, memória ou repositório;
usa-se só por comando (header HTTP temporário).

## 20. Critérios de conclusão

Concluído quando: erros ensinam e acertos complementam; contador 1/10 a 10/10 sem resumo aos
5; resumo só depois da 10.ª com os 3 botões corretos; cada rodada independente e registada;
missões atualizadas; alternativas sem pistas; validador ativo; testes a passar; tudo no
GitHub; relatório final apresentado.
