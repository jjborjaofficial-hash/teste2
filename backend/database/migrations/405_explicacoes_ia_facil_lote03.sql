-- Explicações pedagógicas (BE-004) — IA fácil lote 3: as mesmas 25 perguntas da migration 404 (linguagem simples e curta,
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
    ('seed_ia_facil_v3', 'O que é um erro ou informação incorreta produzida por uma IA?', 'Uma IA pode produzir respostas com informação falsa ou inadequada, mesmo escritas com muita confiança. Por isso é importante conferir o que ela diz, sobretudo em assuntos importantes.'),
    ('seed_ia_facil_v3', 'Por que uma resposta de IA pode precisar de verificação?', 'Os modelos de IA podem errar ou inventar informações que parecem verdadeiras. Por isso, uma resposta importante merece ser conferida em fontes confiáveis antes de ser usada.'),
    ('seed_ia_facil_v3', 'Qual área utiliza IA para recomendar produtos aos clientes?', 'O comércio eletrónico usa IA para sugerir produtos que combinam com o que cada cliente já viu ou comprou. É assim que as lojas online mostram artigos que provavelmente interessam a você.'),
    ('seed_ia_facil_v3', 'Como a IA pode ajudar no atendimento ao cliente?', 'A IA pode atender clientes respondendo automaticamente às perguntas mais frequentes, a qualquer hora. Assim, a equipa tem mais tempo para tratar dos casos que realmente precisam de uma pessoa.'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de processamento de linguagem natural?', 'Tradução automática é processamento de linguagem natural: a IA entende um texto num idioma e escreve o seu sentido noutro. Essa é a área da IA que lida com a língua humana.'),
    ('seed_ia_facil_v3', 'O que pode uma IA fazer com grandes volumes de texto?', 'Com grandes volumes de texto, a IA consegue analisar o conteúdo e identificar padrões ou informações, como temas repetidos ou opiniões, muito mais depressa do que uma pessoa. Ela não elimina os erros humanos.'),
    ('seed_ia_facil_v3', 'Qual é uma utilização da IA em tradução?', 'Na tradução, a IA converte textos de um idioma para outro, como quando você traduz uma mensagem no telemóvel. Ela ajuda a entender, mas pode errar em expressões e sentidos mais difíceis.'),
    ('seed_ia_facil_v3', 'O que é uma recomendação personalizada?', 'Uma recomendação personalizada é uma sugestão feita a partir do que você viu, comprou ou escolheu antes. Por isso duas pessoas podem receber sugestões diferentes na mesma plataforma.'),
    ('seed_ia_facil_v3', 'Qual plataforma pode utilizar algoritmos de recomendação?', 'Serviços de vídeos usam algoritmos de recomendação para sugerir o que assistir a seguir, com base no que você já viu. Aparelhos simples, como calculadoras, não aprendem com o seu comportamento.'),
    ('seed_ia_facil_v3', 'O que é um robô?', 'Um robô é uma máquina capaz de executar ações programadas ou controladas, como montar peças ou aspirar o chão. Um robô pode ou não usar inteligência artificial.'),
    ('seed_ia_facil_v3', 'Todos os robôs utilizam inteligência artificial?', 'Nem todos os robôs usam IA. Muitos só seguem instruções pré-programadas, como os braços de uma linha de montagem. A IA entra quando o robô precisa de perceber o ambiente ou de decidir.'),
    ('seed_ia_facil_v3', 'Qual é a relação entre robótica e IA?', 'A robótica constrói as máquinas e a IA pode dar-lhes capacidades como perceber o ambiente, decidir e adaptar-se. São áreas ligadas, mas diferentes, e muitos robôs funcionam sem IA.'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de automação inteligente numa empresa?', 'Classificar documentos automaticamente é automação inteligente: o sistema lê cada documento e decide onde ele deve ficar, sem ajuda de uma pessoa. Tarefas manuais não usam IA.'),
    ('seed_ia_facil_v3', 'O que é um dado de entrada para uma IA?', 'O dado de entrada é a informação que você fornece ao sistema para ele processar, como uma pergunta, uma foto ou um áudio. O resultado que o sistema devolve é a saída.'),
    ('seed_ia_facil_v3', 'O que é uma saída de um sistema de IA?', 'A saída é o resultado que o sistema de IA produz depois de processar a entrada, como a resposta de um chatbot ou a tradução de um texto. O que você fornece ao sistema é a entrada.'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de entrada para um chatbot?', 'A entrada de um chatbot é o que você lhe envia, como uma pergunta escrita. A resposta que o chatbot devolve é a saída.'),
    ('seed_ia_facil_v3', 'Qual pode ser a saída de um chatbot?', 'A saída de um chatbot é a resposta que ele devolve, normalmente em texto. O que você escreve para ele é a entrada.'),
    ('seed_ia_facil_v3', 'O que significa personalização por IA?', 'Personalização por IA é adaptar resultados e experiências ao que o sistema aprende sobre você, como os seus gostos e o seu comportamento. Por isso o seu feed pode ser diferente do de outra pessoa.'),
    ('seed_ia_facil_v3', 'Qual é um benefício potencial da personalização?', 'A personalização pode mostrar a cada pessoa conteúdos mais relevantes, o que poupa tempo na procura. O cuidado é não fechar a pessoa só no que ela já conhece.'),
    ('seed_ia_facil_v3', 'O que é um sistema de detecção de fraude baseado em IA?', 'Um sistema de detecção de fraude baseado em IA procura padrões associados a possíveis comportamentos fraudulentos, como compras estranhas num cartão. Ele aponta suspeitas, mas não garante que não exista fraude.'),
    ('seed_ia_facil_v3', 'Por que a IA pode ser útil na detecção de fraude?', 'A IA consegue analisar enormes quantidades de transações em pouco tempo e identificar padrões suspeitos que uma pessoa não veria. Ela também pode errar, por isso uma pessoa confirma os casos mais sérios.'),
    ('seed_ia_facil_v3', 'O que é um viés em um sistema de IA?', 'Viés é uma tendência sistemática que pode influenciar os resultados de um sistema de IA, favorecendo ou prejudicando certos grupos. Muitas vezes vem dos dados com que o sistema aprendeu.'),
    ('seed_ia_facil_v3', 'De onde pode surgir viés em IA?', 'O viés pode surgir dos dados utilizados, se forem incompletos ou injustos, ou da forma como o sistema foi desenvolvido. Por isso é importante testar a IA com pessoas e situações diferentes.'),
    ('seed_ia_facil_v3', 'Qual atitude ajuda a utilizar IA de maneira ética?', 'Usar IA com ética é pensar nos possíveis impactos e verificar os resultados importantes antes de agir. Também é respeitar a privacidade e não enganar quem usa o serviço.'),
    ('seed_ia_facil_v3', 'O que é privacidade de dados?', 'Privacidade de dados é proteger as informações pessoais, como nome, telefone e fotos, contra uso ou acesso inadequado. Por isso convém partilhar o mínimo possível e conferir quem recebe os seus dados.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA fácil lote 3: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
