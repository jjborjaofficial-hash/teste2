-- Explicações pedagógicas (BE-004) — IA fácil lote 1: as mesmas 25 perguntas da migration 400 (linguagem simples e curta,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_ia_facil_v1', 'O que significa IA?', 'IA é a sigla de Inteligência Artificial: a área que faz computadores e programas realizarem tarefas que normalmente pedem inteligência humana, como entender a fala, reconhecer imagens e responder perguntas.'),
    ('seed_ia_facil_v1', 'O que é um chatbot?', 'Chatbot é um programa feito para conversar com as pessoas, por texto ou por voz, e responder às perguntas delas. Você o vê em atendimentos de bancos, lojas e operadoras de telemóvel.'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 'A IA generativa cria conteúdo novo a partir do que você pede: textos, imagens, áudio e até código de programação. Ela não acelera a internet nem conserta aparelhos; o seu trabalho é gerar conteúdo.'),
    ('seed_ia_facil_v1', 'O que é um comando ou prompt para uma IA?', 'O prompt, ou comando, é a instrução ou pergunta que você escreve para a IA. Quanto mais clara for a instrução, melhor tende a ser a resposta. A resposta que a IA devolve é outra coisa.'),
    ('seed_ia_facil_v1', 'O que é reconhecimento de voz?', 'O reconhecimento de voz entende o que uma pessoa fala e transforma a fala em informação que o sistema consegue usar, como texto ou comandos. É assim que funcionam os assistentes virtuais e o ditado no telemóvel.'),
    ('seed_ia_facil_v1', 'Qual destas é uma aplicação comum de IA?', 'Os assistentes virtuais usam IA para entender o que você diz ou escreve e responder, como acontece nos assistentes dos telemóveis. Calculadoras simples, impressoras comuns e cabos de rede não aprendem nem entendem linguagem.'),
    ('seed_ia_facil_v1', 'O que é reconhecimento facial?', 'O reconhecimento facial analisa as características de um rosto numa imagem ou vídeo, como a distância entre os olhos, para identificar ou comparar pessoas. Serve, por exemplo, para desbloquear um telemóvel.'),
    ('seed_ia_facil_v1', 'O que é automação?', 'Automação é usar máquinas ou programas para executar tarefas sozinhos, quase sem ajuda humana. Ela é útil em tarefas repetitivas, como organizar dados, enviar avisos ou montar peças numa fábrica.'),
    ('seed_ia_facil_v1', 'Qual é uma vantagem potencial da automação?', 'Uma vantagem da automação é reduzir as tarefas repetitivas, deixando as pessoas livres para trabalhos que pedem criatividade e decisões. Bem usada, ela também pode poupar tempo.'),
    ('seed_ia_facil_v1', 'O que é um dado?', 'Dado é qualquer informação que pode ser guardada ou processada por um computador, como números, textos, imagens e sons. Os sistemas de IA usam muitos dados para aprender e funcionar.'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 'Os dados são o alimento da IA: com eles os modelos são treinados para aprender padrões, avaliados para ver se acertam e alimentados com informações para dar respostas. Sem dados, a maioria dos sistemas de IA não funciona.'),
    ('seed_ia_facil_v1', 'O que é uma imagem gerada por IA?', 'Uma imagem gerada por IA é criada por um sistema de inteligência artificial a partir de uma descrição escrita ou de exemplos, e não tirada por uma câmara. Por parecer real, convém conferir a origem antes de acreditar nela.'),
    ('seed_ia_facil_v1', 'O que é tradução automática?', 'A tradução automática usa programas, muitas vezes com IA, para passar um texto ou uma fala de uma língua para outra. É útil para entender o essencial, mas pode errar nuances, por isso textos importantes pedem revisão.'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 'Na recomendação baseada em IA, o sistema analisa o que você e outras pessoas já viram, ouviram ou compraram e sugere conteúdos, produtos ou ações parecidos. É assim que plataformas de vídeo e música escolhem o que mostrar.'),
    ('seed_ia_facil_v1', 'Onde podemos encontrar sistemas de recomendação?', 'Os sistemas de recomendação estão em plataformas de vídeo e música, em lojas online e em muitos outros serviços digitais, onde sugerem o que você pode gostar. Livros de papel e aparelhos simples sem internet não os usam.'),
    ('seed_ia_facil_v1', 'O que é aprendizado de máquina?', 'No aprendizado de máquina, o computador aprende a partir de muitos exemplos, descobrindo padrões nos dados em vez de seguir regras escritas uma a uma. É a base de muitos sistemas de IA atuais.'),
    ('seed_ia_facil_v1', 'O que é um modelo de IA?', 'Um modelo de IA é um sistema matemático ou de computador treinado com dados para realizar tarefas, como reconhecer imagens ou responder perguntas. É o que aprendeu os padrões durante o treino.'),
    ('seed_ia_facil_v1', 'A IA consegue sempre fornecer respostas corretas?', 'Não. A IA pode errar, inventar informações que parecem verdadeiras e repetir falhas dos dados com que foi treinada. Por isso é importante conferir as respostas, principalmente em assuntos importantes.'),
    ('seed_ia_facil_v1', 'Por que devemos verificar informações produzidas por IA?', 'Os sistemas de IA podem errar ou inventar informações que parecem verdadeiras. Por isso vale conferir em fontes confiáveis antes de usar ou compartilhar o que a IA produziu.'),
    ('seed_ia_facil_v1', 'O que é um assistente virtual?', 'Um assistente virtual é um programa que ajuda você a fazer tarefas quando você pede por voz ou texto, como marcar um alarme, procurar uma informação ou ligar para alguém. Ele não é uma pessoa, e sim um sistema digital.'),
    ('seed_ia_facil_v1', 'O que é geração de texto por IA?', 'Na geração de texto por IA, o sistema escreve textos novos, como respostas, resumos ou e-mails, a partir do que você pede ou dos dados que fornece. O texto sai pronto, mas deve ser revisado antes de usar.'),
    ('seed_ia_facil_v1', 'O que significa ética em IA?', 'Ética em IA é o conjunto de princípios que orientam o desenvolvimento e o uso responsável dessas tecnologias: respeitar as pessoas, proteger dados, evitar discriminação e ser transparente sobre o que o sistema faz.'),
    ('seed_ia_facil_v2', 'O que é um prompt?', 'Prompt é a instrução, pergunta ou texto que você entrega a um sistema de IA para ele responder. Quanto mais claro e detalhado, melhor costuma ser o resultado.'),
    ('seed_ia_facil_v2', 'Por que prompts específicos podem produzir respostas melhores?', 'Um prompt específico dá ao modelo mais contexto e orientações sobre o que você quer, como o assunto, o tom e o formato. Com mais informação, a IA tem menos que adivinhar e a resposta tende a servir melhor.'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 'Sim. A IA pode errar, inventar informações que parecem verdadeiras e repetir falhas dos dados com que foi treinada. Por isso, o melhor é conferir as respostas importantes.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA fácil lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
