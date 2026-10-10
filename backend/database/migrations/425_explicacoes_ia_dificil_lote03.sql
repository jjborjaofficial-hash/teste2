-- Explicações pedagógicas (BE-004) — IA difícil lote 3: as mesmas 25 perguntas da migration 424 (explicação curta e clara,
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
    ('seed_ia_dificil_v2', 'O que é alinhamento de IA?', 'Alinhar a IA é garantir que ela atue de acordo com os objetivos e valores das pessoas. Um sistema pode ser muito capaz e, mesmo assim, fazer o que ninguém queria se não estiver alinhado.'),
    ('seed_ia_dificil_v2', 'O que é um Transformer em Inteligência Artificial?', 'O Transformer é uma arquitetura de rede neural que usa atenção para relacionar todas as partes de uma sequência, como as palavras de uma frase. É a base dos modelos de linguagem atuais.'),
    ('seed_ia_dificil_v2', 'O que é computação quântica aplicada à IA?', 'A computação quântica usa efeitos da física quântica para tentar resolver certos cálculos mais depressa do que os computadores comuns. Na IA, a ideia é acelerar alguns desses cálculos, mas ainda está em investigação.'),
    ('seed_ia_dificil_v2', 'O que é um modelo de difusão?', 'Um modelo de difusão aprende a desfazer ruído passo a passo: parte de ruído aleatório e vai-o transformando numa imagem. É a ideia por trás de vários geradores de imagens.'),
    ('seed_ia_dificil_v2', 'O que é overfitting em Machine Learning?', 'Overfitting é o modelo decorar os dados de treino em vez de aprender o padrão geral. Vai bem no treino mas mal em dados novos, ou seja, perde a capacidade de generalizar.'),
    ('seed_ia_dificil_v2', 'O que é recall em Machine Learning?', 'Recall mede, de todos os casos realmente positivos, quantos o modelo conseguiu encontrar. É importante quando deixar passar um caso positivo é grave, como numa doença.'),
    ('seed_ia_dificil_v2', 'O que é IA generativa multimodal?', 'A IA generativa multimodal entende e cria mais de um tipo de conteúdo, como texto, imagens e áudio. Por exemplo, descreve uma fotografia ou cria uma imagem a partir de uma frase.'),
    ('seed_ia_dificil_v2', 'O que é conjunto de teste em Machine Learning?', 'O conjunto de teste são dados que o modelo nunca viu durante o treino. Serve para medir, no fim, o desempenho real do modelo treinado.'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial forte?', 'A IA forte, ou geral, seria uma IA capaz de compreender e aprender qualquer coisa como uma pessoa. Ainda é um conceito: as IAs atuais são especializadas em tarefas concretas.'),
    ('seed_ia_dificil_v2', 'O que é singularidade tecnológica?', 'Singularidade tecnológica é a hipótese de um momento futuro em que a IA ultrapassa de longe a inteligência humana e passa a evoluir a um ritmo que não conseguimos acompanhar. É uma ideia debatida, não um facto.'),
    ('seed_ia_dificil_v2', 'Qual é uma aplicação avançada da IA na medicina?', 'A IA consegue analisar radiografias, exames e outros dados médicos e ajudar o médico a detetar sinais de doença mais cedo. Apoia o diagnóstico, mas a decisão continua a ser do profissional.'),
    ('seed_ia_dificil_v2', 'O que é Dropout em redes neurais?', 'No dropout, a cada passo do treino alguns neurônios são desligados ao acaso. A rede não pode depender de poucos caminhos e generaliza melhor, o que ajuda a evitar overfitting.'),
    ('seed_ia_dificil_v2', 'O que é aprendizado não supervisionado?', 'No aprendizado não supervisionado os dados não têm rótulos. O modelo procura sozinho estruturas nos dados, como grupos de elementos parecidos.'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial estreita (ANI)?', 'A IA estreita (ANI) é a IA de hoje: faz bem uma tarefa ou um conjunto limitado de tarefas, como reconhecer voz ou recomendar filmes, mas não consegue generalizar como uma pessoa.'),
    ('seed_ia_dificil_v2', 'O que é underfitting?', 'Underfitting é o modelo ser simples demais ou treinado de menos, e por isso nem no treino aprende bem os padrões. Os resultados são fracos tanto nos dados de treino como nos de teste.'),
    ('seed_ia_dificil_v2', 'O que é alucinação em modelos de IA?', 'Alucinação é o modelo inventar informações falsas e apresentá-las com segurança, como se fossem verdadeiras. Por isso as respostas importantes devem ser conferidas.'),
    ('seed_ia_dificil_v2', 'O que é democratização da IA?', 'Democratizar a IA é fazer com que mais pessoas e organizações, e não só as grandes empresas, possam aceder e usar ferramentas de IA, por exemplo através de aplicações gratuitas ou simples de usar.'),
    ('seed_ia_dificil_v2', 'O que é inferência em IA?', 'Inferência é a fase de uso: o modelo já treinado recebe uma entrada e produz uma previsão ou resposta. É diferente do treinamento, em que ele aprende.'),
    ('seed_ia_dificil_v2', 'O que é otimização de modelos de IA?', 'Otimizar um modelo é torná-lo melhor em eficiência, velocidade ou desempenho, por exemplo reduzindo o seu tamanho ou o tempo de resposta sem perder muita qualidade.'),
    ('seed_ia_dificil_v2', 'O que é IA explicável (Explainable AI)?', 'IA explicável reúne técnicas que mostram por que um modelo tomou certa decisão, em termos que as pessoas conseguem entender. Ajuda a confiar nos resultados e a detetar erros.'),
    ('seed_ia_dificil_v2', 'O que é modelo discriminativo?', 'Um modelo discriminativo aprende a separar ou classificar dados, por exemplo dizer se um e-mail é spam ou não. Contrasta com os generativos, que criam dados novos.'),
    ('seed_ia_dificil_v2', 'O que é batch size?', 'Batch size é o número de exemplos que o modelo processa de cada vez antes de atualizar os seus parâmetros. Lotes maiores usam mais memória; lotes menores dão atualizações mais ruidosas.'),
    ('seed_ia_dificil_v2', 'O que é IA responsável?', 'IA responsável é criar e usar IA pensando na ética, na segurança e no impacto nas pessoas e na sociedade, por exemplo evitando discriminação e protegendo dados.'),
    ('seed_ia_dificil_v2', 'O que é agente autônomo de IA?', 'Um agente autônomo de IA recebe um objetivo, planeia os passos e executa ações, como pesquisar, usar ferramentas ou enviar mensagens, até o alcançar, com pouca intervenção humana.'),
    ('seed_ia_dificil_v2', 'O que é processamento de linguagem natural (NLP)?', 'NLP é a área da IA que ensina os computadores a compreender e a produzir linguagem humana, escrita ou falada. Está por trás da tradução automática, dos chatbots e dos assistentes de voz.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 3: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
