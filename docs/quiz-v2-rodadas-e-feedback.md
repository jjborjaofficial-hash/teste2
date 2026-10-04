# Quiz v2 — rodadas de 10 perguntas, feedback pedagógico e qualidade das alternativas

Especificação do dono do projeto (versão consolidada, todos os requisitos mantidos).
Entry points: `backend/PENDENTE.md` (BE-002 a BE-004) e `frontend/PENDENTE.md` (FE-003).

## Regras de trabalho para esta entrega

- Trabalhar sobre o projeto existente: não recriar, não trocar a arquitetura sem necessidade,
  não remover funcionalidades, não mexer em autenticação, XP, Pontos, saldo MZN, missões, ranking
  ou notificações além do necessário. **Primeiro analisar, depois implementar** de forma
  compatível. Reutilizar componentes, serviços, endpoints e modelos existentes.
- Design atual do Aprenda e Ganhe, **sem emojis**, com `prefers-reduced-motion`, boa leitura,
  responsivo, botões claros, navegação por teclado quando aplicável.
- **Checkpoint de ~5 alterações significativas:** verificar código, rodar testes, ver erros,
  revisar o diff, commit, push, continuar. Se uma funcionalidade ou etapa estrutural importante
  fechar antes das 5: testar, commit e push na hora. Nunca commitar código quebrado só para
  chegar a 5; a qualidade tem prioridade. (As "5" são alterações de desenvolvimento, não
  perguntas do quiz.)
- Commits claros e descritivos (ex.: `feat(quiz): implement ten-question rounds`,
  `fix(quiz): prevent answer pattern leakage`). Evitar "update", "changes", "fix", "stuff".
- Antes de cada push: `git status`, branch correta, `git diff`, testes, sem alterações
  acidentais, **nenhum segredo** (passwords, API keys, tokens, `.env` reais, dados privados).
- Depois de cada checkpoint apresentar: CHECKPOINT (quantidade), IMPLEMENTADO, TESTADO,
  COMMIT (hash e mensagem), PUSH (sucesso/erro), PRÓXIMO BLOCO.
- No fim apresentar o RELATÓRIO FINAL: arquivos modificados, funcionalidades implementadas,
  fluxo final do quiz, testes executados, problemas encontrados e corrigidos, commits, push.

## Objetivo

Quiz = **aprendizagem + feedback + progresso + gamificação**. Cada resposta ensina algo.
Acerto = confirmar + explicar/complementar. Erro = corrigir + explicar + ensinar o conceito,
sem humilhar. Rápido, claro, natural e integrado ao design atual.

## Análise prévia obrigatória

Localizar e entender: tela do quiz, API de perguntas, endpoint de resposta, modelos de perguntas
e respostas, seleção/sorteio, categorias, dificuldades, explicações, XP, recompensas, missões,
progresso, estado da rodada, navegação, tela de resumo (se existir), dashboard, seleção de
categorias, tela de missões, persistência da sessão, importação/geração de perguntas, validação
das alternativas, e como hoje se evita repetir perguntas.

## Rodada

- **Não existe "quiz completo" fixo** (nada de 30 perguntas, 3 rodadas agrupadas ou resumo do
  dia). O banco é contínuo. Entrar numa categoria (ex.: Inteligência Artificial) inicia uma
  **nova rodada independente de 10 perguntas** recomendadas/selecionadas pelo sistema, com
  resultado próprio. Pode continuar indefinidamente (rodada 1, rodada 2, ...).
- Seleção respeita: categoria, dificuldade, perguntas já respondidas, perguntas recentes,
  progresso do utilizador, recomendações existentes, disponibilidade e regras de repetição.
  Sem repetir perguntas dentro da rodada, com diversidade de dificuldade. Não alterar o banco
  sem necessidade.
- Contador visível de **1/10 até 10/10**. Depois da 5.ª **não** mostrar resumo nem terminar.
  Só depois da 10.ª a rodada termina.

## Fluxo de cada pergunta

PERGUNTA → RESPOSTA → VALIDAÇÃO → FEEDBACK → EXPLICAÇÃO DIDÁTICA → PRÓXIMA PERGUNTA.
Feedback depois de **cada uma das 10**.

**Acerto:** "Correto!" + "Você identificou a resposta certa." + "Para complementar:" (informação
adicional relevante) + "Aprenda:" (conceito/detalhe). Curto o suficiente para não interromper.
**Erro:** "Resposta incorreta." + "Resposta correta:" + "Por quê?" + "O que aprender:" (conceito
principal) + quando útil "A sua resposta estava incorreta porque..." + opcionalmente "Dica:" de
memorização.

**Profundidade por dificuldade:** fácil = linguagem simples, curta, conceito fundamental; médio =
explica o raciocínio e contextualiza; difícil = raciocínio e relação entre conceitos;
especialista = técnica, com contexto, aplicações ou consequências. Qualidade > quantidade.

## Qualidade das alternativas (problema detectado)

Hoje a alternativa correta se denuncia por ser mais longa, detalhada, explicativa, técnica ou
estruturalmente diferente; as erradas são curtas e simples. Isso deve acabar.

- A correta **não pode** ser sistematicamente a mais longa, a mais curta, a mais detalhada, a
  mais técnica nem a única explicativa. As erradas devem ser **plausíveis** e relacionadas ao
  conceito (sem absurdos óbvios).
- **Validador** (não só por caracteres): comparar caracteres, palavras, tokens se houver,
  estrutura, nível de detalhe, termos técnicos, explicações embutidas, exemplos, pontuação e
  padrões linguísticos. Pequena diferença de tamanho é aceitável; o problema é o padrão que
  denuncia a resposta. Exemplo a rejeitar: correta = frase longa "É o processo pelo qual
  sistemas de IA aprendem padrões a partir de dados para realizar previsões"; erradas = "É um
  programa.", "É um banco de dados.", "É uma rede."
- **Posição da correta distribuída/aleatória** (sem A sempre correta etc.), com ordem visual
  aleatória, mas o **backend continua sabendo a correta** (não quebrar a validação).
- Se as perguntas forem geradas por IA: definir o conceito, gerar todas as alternativas em
  conjunto, definir a correta, gerar distratores plausíveis, validar equilíbrio e qualidade,
  aprovar/rejeitar (e não "gerar a correta e depois erradas simples").
- **Validador automático antes de aprovar:** nº de alternativas correto; só uma correta e ela
  existe; sem duplicadas nem quase iguais; tamanho e estrutura equilibrados; correta sem
  explicação extra; distratores plausíveis; posição não previsível; linguagem equilibrada; sem
  pistas óbvias; pergunta tem explicação coerente com a resposta; categoria e dificuldade
  corretas. Se falhar: **rejeitar ou enviar para revisão** (nunca publicar automaticamente).

## Segurança

Não enviar ao frontend antes da resposta nada que revele a correta (`correctAnswer`,
`correctOption`, `isCorrect`, id da alternativa certa ou equivalente). A validação é no backend.

## Fim da rodada e resumo

Na 10.ª: primeiro o feedback pedagógico dela, como nas anteriores; depois marcar a rodada
CONCLUÍDA, calcular o resultado, registrar desempenho, atualizar recompensas/métricas e o
progresso das missões aplicáveis, e abrir o **resumo**. Nunca mostrar nova pergunta nem iniciar
outra rodada automaticamente.

**Resumo = exclusivamente as 10 perguntas daquela rodada:** categoria, perguntas respondidas,
acertos, erros, % de aproveitamento, XP ganho, recompensas (quando aplicável), melhor
desempenho, conceitos a rever, progresso de aprendizagem e outras métricas já existentes.

**Exatamente 3 botões:** (1) "Painel inicial" -> Dashboard existente, sem iniciar rodada nem
selecionar perguntas; (2) "Escolher novamente uma categoria" -> tela existente de categorias, sem
iniciar rodada (só depois da escolha começa a nova rodada de 10); (3) "Ver missões em andamento"
-> tela de Missões existente, sem criar nem concluir missão, sem duplicar lógica (o progresso
atualizado pela rodada aparece lá).

## Missões, persistência, histórico e dados

- Missões: atualizar o progresso com a lógica existente (responder perguntas, completar rodada,
  login, 12 minutos); sem segunda implementação, sem duplicar progresso nem recompensa.
- Persistência: registrar rodada iniciada, categoria, as 10 perguntas, progresso, respostas,
  pergunta atual e conclusão. Ao recarregar, recuperar o estado quando a arquitetura permitir,
  sem perder nem duplicar respostas.
- Histórico por rodada (quando a arquitetura permitir): user_id, round_id, categoria, perguntas,
  respostas, acertos, erros, tempo, XP, recompensas, dificuldade, conceitos, data/hora,
  desempenho. Prepara estatísticas, perfil de aprendizagem, recomendações e revisão, sem criar
  "quiz completo" nem uma arquitetura gigante.

## Testes obrigatórios

1. Entrar numa categoria inicia rodada de 10. 2. Acerto: feedback + complemento. 3. Erro:
correção + explicação + aprendizagem. 4. Chegar à 5.ª continua normalmente, sem resumo. 5.
Responder a 10.ª: feedback, rodada concluída, resumo. 6. Resumo traz exatamente os dados da
rodada. 7. "Painel inicial" -> Dashboard. 8. "Escolher novamente uma categoria" -> seleção.
9. "Ver missões em andamento" -> tela de Missões com progresso atualizado, sem nova missão nem
nova rodada. 10. Depois de terminar, "Escolher novamente" abre as categorias e, após a escolha,
inicia nova rodada com 10 novas perguntas. 11. Correta muito maior que as restantes: validador
marca para revisão/rejeição, sem publicação automática. 12. Correta muito menor: analisar o
desequilíbrio e marcar para revisão quando o padrão for evidente. 13. Alternativas duplicadas ou
quase iguais: rejeitar/revisão. 14. Várias perguntas seguidas: posição da correta bem
distribuída, sem padrão, backend como fonte de verdade. 15. Recarregar durante a rodada:
estado recuperado, sem duplicar respondidas, progresso e contador corretos. 16. Rodada que
atualiza uma missão: progresso certo, sem duplicar recompensa nem progresso.

## Critério final de conclusão (não basta compilar)

1. Cada rodada tem 10 perguntas. 2. Selecionadas/recomendadas pelo sistema. 3. Cada resposta gera
feedback. 4. Erro gera explicação e aprendizagem. 5. Acerto gera confirmação e complemento. 6.
Contador de 1/10 a 10/10. 7. Sem resumo após 5. 8. Resumo só depois da 10.ª. 9. Resumo só daquela
rodada. 10. Os 3 botões. 11. Nenhum inicia rodada sozinho. 12. Nova rodada só depois de escolher
categoria. 13. Respostas e progresso registrados. 14. Missões recebem o progresso certo. 15.
Alternativas não denunciam a correta por tamanho ou estilo. 16. Posição da correta sem padrão.
17. Perguntas de baixa qualidade rejeitadas ou enviadas para revisão. 18. Estado da rodada
preservado. 19. Testes passam. 20. Alterações no Git. 21. Enviadas ao GitHub. 22. Relatório final.
