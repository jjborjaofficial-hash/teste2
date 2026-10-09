-- Explicações pedagógicas (BE-004) — IA fácil lote 2: as mesmas 25 perguntas da migration 402 (linguagem simples e curta,
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
    ('seed_ia_facil_v2', 'Qual é uma aplicação comum de IA?', 'Assistentes virtuais, como os que respondem por voz no telemóvel, usam IA para entender o que você pede e responder. Aparelhos simples só executam funções fixas e não entendem linguagem.'),
    ('seed_ia_facil_v2', 'O que caracteriza uma IA generativa?', 'Uma IA generativa cria conteúdo novo a partir do que você pede: textos, imagens, áudio e até código de programação. Guardar, ligar ou calcular são tarefas de outros sistemas.'),
    ('seed_ia_facil_v2', 'Por que informações geradas por IA devem ser verificadas em situações importantes?', 'Os modelos de IA podem errar ou inventar informações com muita confiança. Por isso, em assuntos importantes como saúde, dinheiro ou estudos, vale conferir em fontes confiáveis.'),
    ('seed_ia_facil_v3', 'O que significa a sigla IA?', 'IA é a sigla de Inteligência Artificial: a área que faz sistemas realizarem tarefas que normalmente pedem inteligência humana, como entender a fala ou reconhecer imagens.'),
    ('seed_ia_facil_v3', 'Qual é um exemplo comum de inteligência artificial?', 'Os sistemas de recomendação de vídeos usam IA para aprender o que você gosta de ver e sugerir novos vídeos. Os objetos comuns do dia a dia não aprendem com o seu comportamento.'),
    ('seed_ia_facil_v3', 'Qual tecnologia permite que sistemas reconheçam rostos em imagens?', 'Reconhecimento facial é a tecnologia que identifica rostos em imagens, comparando características como a distância entre os olhos e o formato do rosto. Usa-se, por exemplo, para desbloquear telemóveis.'),
    ('seed_ia_facil_v3', 'Qual destes pode ser utilizado para conversar com uma IA?', 'Você conversa com uma IA por uma interface de conversação, como um chat onde escreve ou fala os seus pedidos e recebe as respostas.'),
    ('seed_ia_facil_v3', 'Qual é uma utilização comum da IA na educação?', 'A IA pode adaptar exercícios, ritmo e explicações ao nível de cada aluno, personalizando a aprendizagem. Ela apoia o ensino e não substitui professores nem avaliações.'),
    ('seed_ia_facil_v3', 'O que são dados?', 'Dados são informações que podem ser guardadas e analisadas, como números, textos, imagens e sons. Os sistemas de IA aprendem justamente a partir de grandes quantidades de dados.'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de reconhecimento de voz?', 'Reconhecimento de voz transforma a fala em texto ou em comandos que o sistema entende. É o que acontece quando você dita uma mensagem ao telemóvel.'),
    ('seed_ia_facil_v3', 'Qual é uma aplicação da IA em bancos?', 'Os bancos usam IA para analisar padrões de compra e detetar transações suspeitas, como pagamentos fora do seu comportamento normal. Assim podem bloquear possíveis fraudes mais cedo.'),
    ('seed_ia_facil_v3', 'Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 'Na medicina, a IA ajuda a analisar exames e imagens, como radiografias, para apoiar o diagnóstico de doenças. A decisão final continua a ser do profissional de saúde.'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de IA em smartphones?', 'O reconhecimento de voz do assistente virtual usa IA para entender o que você diz e transformar em ação, como ligar para alguém ou procurar algo. Acessórios e botões físicos não usam IA.'),
    ('seed_ia_facil_v3', 'Qual é a função de um conjunto de treinamento?', 'O conjunto de treinamento reúne os exemplos com que o modelo aprende. Quanto melhores e mais variados forem os exemplos, melhor o modelo tende a funcionar.'),
    ('seed_ia_facil_v3', 'O que pode acontecer se uma IA receber dados de baixa qualidade?', 'Se os dados forem errados, incompletos ou de má qualidade, o modelo aprende padrões errados e o desempenho cai. Dados bons são tão importantes quanto o algoritmo.'),
    ('seed_ia_facil_v3', 'Qual destas tecnologias pode usar IA para sugerir músicas?', 'As plataformas de streaming usam IA para aprender os seus gostos e sugerir músicas parecidas com as que você já ouve.'),
    ('seed_ia_facil_v3', 'Qual é um possível benefício da IA nas empresas?', 'Uma das vantagens da IA nas empresas é automatizar tarefas repetitivas, como classificar documentos ou responder perguntas comuns, deixando as pessoas livres para trabalho mais importante. Ela não dispensa a supervisão humana nem garante lucro.'),
    ('seed_ia_facil_v3', 'O que significa dizer que uma IA foi treinada?', 'Treinar uma IA é ajustar o modelo com muitos dados para que ele aprenda padrões, como reconhecer rostos ou prever palavras. Sem treino, o modelo não sabe fazer a tarefa.'),
    ('seed_ia_facil_v3', 'Qual é uma preocupação relacionada ao uso de IA?', 'A IA usa muitos dados, e isso levanta preocupações com a privacidade e com o uso indevido de informações pessoais. Por isso é importante proteger os seus dados e saber a quem os entrega.'),
    ('seed_ia_facil_v3', 'Qual destas tarefas uma IA generativa pode realizar?', 'Uma IA generativa pode gerar texto, como mensagens, resumos e explicações. Tarefas físicas, como reparar ecrãs ou trocar peças, não fazem parte do que ela faz.'),
    ('seed_ia_facil_v3', 'O que significa IA generativa?', 'IA generativa é a que produz conteúdo novo, como texto, imagens, áudio ou código, a partir do pedido que você faz. É diferente de outras IAs que apenas classificam ou analisam dados.'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 'A IA generativa cria conteúdos digitais, como texto, imagens, áudio e código. Materiais físicos, como papel ou metal, não são criados por ela.'),
    ('seed_ia_facil_v3', 'Qual é a principal função de um prompt?', 'O prompt é o pedido que você escreve para a IA. Ele orienta o modelo sobre o que você deseja, e quanto mais claro for, melhor tende a ser a resposta.'),
    ('seed_ia_facil_v3', 'Um prompt detalhado pode ajudar porque:', 'Um prompt detalhado fornece mais contexto: o assunto, o tipo de resposta e o tamanho desejado. Com isso, o modelo entende melhor o pedido e responde de forma mais útil.'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de uso responsável da IA?', 'Usar a IA com responsabilidade é conferir as informações importantes antes de usá-las. Ela pode errar, e proteger os dados pessoais e não enganar ninguém também fazem parte do uso responsável.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA fácil lote 2: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
