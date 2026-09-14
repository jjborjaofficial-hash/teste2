-- Migration/seed: conteúdo Inteligência Artificial, nível Fácil — lote 3 (56 de 69 perguntas)
-- Fonte: novo lote de 69 perguntas de Inteligência Artificial/Fácil fornecido
-- pelo proprietário do projeto.
--
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra as 1073 perguntas já
-- existentes no banco e encontrei 13 repetidas, removidas deste arquivo:
--   - "O que é um algoritmo?"
--   - "O que é aprendizado de máquina?"
--   - "O que é um chatbot?"
--   - "Por que os dados são importantes para muitos sistemas de IA?"
--   - "O que é uma imagem gerada por IA?"
--   - "O que significa automatizar uma tarefa?"
--   - "O que é visão computacional?"
--   - "O que é um modelo de IA?"
--   - "O que é reconhecimento de padrões?"
--   - "O que é um assistente virtual?"
--   - "O que é um prompt?"
--   - "O que é processamento de linguagem natural?"
--   - "O que é automação inteligente?"
-- Sobraram 56 perguntas novas e únicas.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores): neste lote a resposta correta já vinha variada em algumas
-- perguntas (não sempre "A"), mas ainda predominantemente "A". Para manter
-- consistência com o resto do banco e evitar viés residual, a posição da
-- alternativa correta (usando o texto correto conforme indicado no
-- documento original) foi redistribuída por pergunta com seed fixa (84 —
-- distinta das seeds 42 a 83 já usadas) e distribuição controlada entre
-- A/B/C/D. O conteúdo pedagógico (pergunta e as 4 alternativas) permanece
-- exatamente como enviado; apenas a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_facil_v3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v3'
    FROM (VALUES
      ('O que significa a sigla IA?'),
      ('Qual é um exemplo comum de inteligência artificial?'),
      ('Qual tecnologia permite que sistemas reconheçam rostos em imagens?'),
      ('Qual destes pode ser utilizado para conversar com uma IA?'),
      ('Qual é uma utilização comum da IA na educação?'),
      ('O que são dados?'),
      ('Qual destes é um exemplo de reconhecimento de voz?'),
      ('Qual é uma aplicação da IA em bancos?'),
      ('Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?'),
      ('Qual é um exemplo de IA em smartphones?'),
      ('Qual é a função de um conjunto de treinamento?'),
      ('O que pode acontecer se uma IA receber dados de baixa qualidade?'),
      ('Qual destas tecnologias pode usar IA para sugerir músicas?'),
      ('Qual é um possível benefício da IA nas empresas?'),
      ('O que significa dizer que uma IA foi treinada?'),
      ('Qual é uma preocupação relacionada ao uso de IA?'),
      ('Qual destas tarefas uma IA generativa pode realizar?'),
      ('O que significa IA generativa?'),
      ('Qual é um exemplo de conteúdo que uma IA generativa pode criar?'),
      ('Qual é a principal função de um prompt?'),
      ('Um prompt detalhado pode ajudar porque:'),
      ('Qual destes é um exemplo de uso responsável da IA?'),
      ('O que é um erro ou informação incorreta produzida por uma IA?'),
      ('Por que uma resposta de IA pode precisar de verificação?'),
      ('Qual área utiliza IA para recomendar produtos aos clientes?'),
      ('Como a IA pode ajudar no atendimento ao cliente?'),
      ('Qual destes é um exemplo de processamento de linguagem natural?'),
      ('O que pode uma IA fazer com grandes volumes de texto?'),
      ('Qual é uma utilização da IA em tradução?'),
      ('O que é uma recomendação personalizada?'),
      ('Qual plataforma pode utilizar algoritmos de recomendação?'),
      ('O que é um robô?'),
      ('Todos os robôs utilizam inteligência artificial?'),
      ('Qual é a relação entre robótica e IA?'),
      ('Qual é um exemplo de automação inteligente numa empresa?'),
      ('O que é um dado de entrada para uma IA?'),
      ('O que é uma saída de um sistema de IA?'),
      ('Qual é um exemplo de entrada para um chatbot?'),
      ('Qual pode ser a saída de um chatbot?'),
      ('O que significa personalização por IA?'),
      ('Qual é um benefício potencial da personalização?'),
      ('O que é um sistema de detecção de fraude baseado em IA?'),
      ('Por que a IA pode ser útil na detecção de fraude?'),
      ('O que é um viés em um sistema de IA?'),
      ('De onde pode surgir viés em IA?'),
      ('Qual atitude ajuda a utilizar IA de maneira ética?'),
      ('O que é privacidade de dados?'),
      ('Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?'),
      ('Qual destas informações pode ser considerada pessoal?'),
      ('O que significa supervisionar uma IA?'),
      ('Por que a supervisão humana pode ser importante?'),
      ('Qual é uma limitação comum dos sistemas de IA?'),
      ('Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?'),
      ('Qual é uma vantagem de utilizar IA como ferramenta de apoio?'),
      ('Qual afirmação sobre IA é mais adequada?'),
      ('Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_facil_v3 q
    JOIN (VALUES
      ('O que significa a sigla IA?', 'Inteligência Artificial', TRUE, 0),
      ('O que significa a sigla IA?', 'Informação Automática', FALSE, 1),
      ('O que significa a sigla IA?', 'Integração Algorítmica', FALSE, 2),
      ('O que significa a sigla IA?', 'Internet Avançada', FALSE, 3),
      ('Qual é um exemplo comum de inteligência artificial?', 'Um lápis', FALSE, 0),
      ('Qual é um exemplo comum de inteligência artificial?', 'Uma calculadora simples', FALSE, 1),
      ('Qual é um exemplo comum de inteligência artificial?', 'Uma folha de papel', FALSE, 2),
      ('Qual é um exemplo comum de inteligência artificial?', 'Um sistema de recomendação de vídeos', TRUE, 3),
      ('Qual tecnologia permite que sistemas reconheçam rostos em imagens?', 'Armazenamento em nuvem', FALSE, 0),
      ('Qual tecnologia permite que sistemas reconheçam rostos em imagens?', 'Compactação de arquivos', FALSE, 1),
      ('Qual tecnologia permite que sistemas reconheçam rostos em imagens?', 'Reconhecimento facial', TRUE, 2),
      ('Qual tecnologia permite que sistemas reconheçam rostos em imagens?', 'Processamento de texto', FALSE, 3),
      ('Qual destes pode ser utilizado para conversar com uma IA?', 'Pen drive', FALSE, 0),
      ('Qual destes pode ser utilizado para conversar com uma IA?', 'Cabo de energia', FALSE, 1),
      ('Qual destes pode ser utilizado para conversar com uma IA?', 'Impressora', FALSE, 2),
      ('Qual destes pode ser utilizado para conversar com uma IA?', 'Interface de conversação', TRUE, 3),
      ('Qual é uma utilização comum da IA na educação?', 'Eliminar todos os professores', FALSE, 0),
      ('Qual é uma utilização comum da IA na educação?', 'Impedir avaliações', FALSE, 1),
      ('Qual é uma utilização comum da IA na educação?', 'Substituir livros físicos obrigatoriamente', FALSE, 2),
      ('Qual é uma utilização comum da IA na educação?', 'Personalizar experiências de aprendizagem', TRUE, 3),
      ('O que são dados?', 'Informações que podem ser armazenadas e analisadas', TRUE, 0),
      ('O que são dados?', 'Somente textos', FALSE, 1),
      ('O que são dados?', 'Apenas números bancários', FALSE, 2),
      ('O que são dados?', 'Apenas fotografias', FALSE, 3),
      ('Qual destes é um exemplo de reconhecimento de voz?', 'Criar uma pasta', FALSE, 0),
      ('Qual destes é um exemplo de reconhecimento de voz?', 'Transformar fala em texto', TRUE, 1),
      ('Qual destes é um exemplo de reconhecimento de voz?', 'Aumentar o brilho da tela', FALSE, 2),
      ('Qual destes é um exemplo de reconhecimento de voz?', 'Formatar um computador', FALSE, 3),
      ('Qual é uma aplicação da IA em bancos?', 'Impressão de cartões sem sistema', FALSE, 0),
      ('Qual é uma aplicação da IA em bancos?', 'Fabricação de notas manualmente', FALSE, 1),
      ('Qual é uma aplicação da IA em bancos?', 'Detecção de transações suspeitas', TRUE, 2),
      ('Qual é uma aplicação da IA em bancos?', 'Eliminação dos registros financeiros', FALSE, 3),
      ('Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 'Música exclusivamente', FALSE, 0),
      ('Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 'Medicina', TRUE, 1),
      ('Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 'Transporte exclusivamente', FALSE, 2),
      ('Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 'Construção', FALSE, 3),
      ('Qual é um exemplo de IA em smartphones?', 'Capa protetora', FALSE, 0),
      ('Qual é um exemplo de IA em smartphones?', 'Botão de volume', FALSE, 1),
      ('Qual é um exemplo de IA em smartphones?', 'Carregador', FALSE, 2),
      ('Qual é um exemplo de IA em smartphones?', 'Reconhecimento de voz do assistente virtual', TRUE, 3),
      ('Qual é a função de um conjunto de treinamento?', 'Desligar o computador', FALSE, 0),
      ('Qual é a função de um conjunto de treinamento?', 'Fornecer exemplos utilizados para ensinar um modelo', TRUE, 1),
      ('Qual é a função de um conjunto de treinamento?', 'Armazenar apenas músicas', FALSE, 2),
      ('Qual é a função de um conjunto de treinamento?', 'Substituir o algoritmo', FALSE, 3),
      ('O que pode acontecer se uma IA receber dados de baixa qualidade?', 'Os dados deixam de ser necessários', FALSE, 0),
      ('O que pode acontecer se uma IA receber dados de baixa qualidade?', 'O sistema sempre fica mais rápido', FALSE, 1),
      ('O que pode acontecer se uma IA receber dados de baixa qualidade?', 'O desempenho do sistema pode ser prejudicado', TRUE, 2),
      ('O que pode acontecer se uma IA receber dados de baixa qualidade?', 'A IA torna-se automaticamente mais precisa', FALSE, 3),
      ('Qual destas tecnologias pode usar IA para sugerir músicas?', 'Plataformas de streaming', TRUE, 0),
      ('Qual destas tecnologias pode usar IA para sugerir músicas?', 'Teclados mecânicos', FALSE, 1),
      ('Qual destas tecnologias pode usar IA para sugerir músicas?', 'Impressoras', FALSE, 2),
      ('Qual destas tecnologias pode usar IA para sugerir músicas?', 'Cabos USB', FALSE, 3),
      ('Qual é um possível benefício da IA nas empresas?', 'Eliminar toda supervisão humana', FALSE, 0),
      ('Qual é um possível benefício da IA nas empresas?', 'Automatizar determinadas tarefas repetitivas', TRUE, 1),
      ('Qual é um possível benefício da IA nas empresas?', 'Impedir qualquer erro', FALSE, 2),
      ('Qual é um possível benefício da IA nas empresas?', 'Garantir lucro', FALSE, 3),
      ('O que significa dizer que uma IA foi treinada?', 'O computador recebeu uma limpeza física', FALSE, 0),
      ('O que significa dizer que uma IA foi treinada?', 'O dispositivo foi desligado', FALSE, 1),
      ('O que significa dizer que uma IA foi treinada?', 'O programa foi instalado sem dados', FALSE, 2),
      ('O que significa dizer que uma IA foi treinada?', 'O modelo foi ajustado utilizando dados para aprender determinados padrões', TRUE, 3),
      ('Qual é uma preocupação relacionada ao uso de IA?', 'Privacidade e utilização inadequada de dados', TRUE, 0),
      ('Qual é uma preocupação relacionada ao uso de IA?', 'Ausência de qualquer algoritmo', FALSE, 1),
      ('Qual é uma preocupação relacionada ao uso de IA?', 'Falta de eletricidade em todos os casos', FALSE, 2),
      ('Qual é uma preocupação relacionada ao uso de IA?', 'Impossibilidade de armazenar textos', FALSE, 3),
      ('Qual destas tarefas uma IA generativa pode realizar?', 'Gerar texto', TRUE, 0),
      ('Qual destas tarefas uma IA generativa pode realizar?', 'Substituir um processador', FALSE, 1),
      ('Qual destas tarefas uma IA generativa pode realizar?', 'Carregar uma bateria', FALSE, 2),
      ('Qual destas tarefas uma IA generativa pode realizar?', 'Aumentar fisicamente a memória RAM', FALSE, 3),
      ('O que significa IA generativa?', 'IA capaz de produzir conteúdos como texto, imagens, áudio ou código', TRUE, 0),
      ('O que significa IA generativa?', 'IA usada exclusivamente para calcular impostos', FALSE, 1),
      ('O que significa IA generativa?', 'IA usada apenas em robôs físicos', FALSE, 2),
      ('O que significa IA generativa?', 'IA que funciona sem algoritmos', FALSE, 3),
      ('Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 'Energia elétrica', FALSE, 0),
      ('Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 'Hardware físico', FALSE, 1),
      ('Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 'Cabos de rede', FALSE, 2),
      ('Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 'Texto', TRUE, 3),
      ('Qual é a principal função de um prompt?', 'Orientar o modelo sobre o que o utilizador deseja', TRUE, 0),
      ('Qual é a principal função de um prompt?', 'Substituir a internet', FALSE, 1),
      ('Qual é a principal função de um prompt?', 'Aumentar a memória do computador', FALSE, 2),
      ('Qual é a principal função de um prompt?', 'Formatar o dispositivo', FALSE, 3),
      ('Um prompt detalhado pode ajudar porque:', 'Remove todos os dados', FALSE, 0),
      ('Um prompt detalhado pode ajudar porque:', 'Fornece mais contexto ao modelo', TRUE, 1),
      ('Um prompt detalhado pode ajudar porque:', 'Desliga o modelo', FALSE, 2),
      ('Um prompt detalhado pode ajudar porque:', 'Impede qualquer resposta', FALSE, 3),
      ('Qual destes é um exemplo de uso responsável da IA?', 'Aceitar todas as respostas automaticamente', FALSE, 0),
      ('Qual destes é um exemplo de uso responsável da IA?', 'Compartilhar dados privados sem necessidade', FALSE, 1),
      ('Qual destes é um exemplo de uso responsável da IA?', 'Verificar informações importantes antes de utilizá-las', TRUE, 2),
      ('Qual destes é um exemplo de uso responsável da IA?', 'Utilizar IA para enganar pessoas', FALSE, 3),
      ('O que é um erro ou informação incorreta produzida por uma IA?', 'Uma atualização do sistema', FALSE, 0),
      ('O que é um erro ou informação incorreta produzida por uma IA?', 'Uma melhoria automática', FALSE, 1),
      ('O que é um erro ou informação incorreta produzida por uma IA?', 'Uma resposta que contém informação falsa ou inadequada', TRUE, 2),
      ('O que é um erro ou informação incorreta produzida por uma IA?', 'Um tipo de hardware', FALSE, 3),
      ('Por que uma resposta de IA pode precisar de verificação?', 'Porque IA nunca consegue produzir texto', FALSE, 0),
      ('Por que uma resposta de IA pode precisar de verificação?', 'Porque modelos não utilizam dados', FALSE, 1),
      ('Por que uma resposta de IA pode precisar de verificação?', 'Porque modelos podem produzir informações incorretas', TRUE, 2),
      ('Por que uma resposta de IA pode precisar de verificação?', 'Porque toda resposta é necessariamente falsa', FALSE, 3),
      ('Qual área utiliza IA para recomendar produtos aos clientes?', 'Agricultura manual exclusivamente', FALSE, 0),
      ('Qual área utiliza IA para recomendar produtos aos clientes?', 'Comércio eletrónico', TRUE, 1),
      ('Qual área utiliza IA para recomendar produtos aos clientes?', 'Construção civil exclusivamente', FALSE, 2),
      ('Qual área utiliza IA para recomendar produtos aos clientes?', 'Impressão tradicional', FALSE, 3),
      ('Como a IA pode ajudar no atendimento ao cliente?', 'Impedindo perguntas', FALSE, 0),
      ('Como a IA pode ajudar no atendimento ao cliente?', 'Respondendo automaticamente a perguntas frequentes', TRUE, 1),
      ('Como a IA pode ajudar no atendimento ao cliente?', 'Eliminando todos os clientes', FALSE, 2),
      ('Como a IA pode ajudar no atendimento ao cliente?', 'Desligando os canais de comunicação', FALSE, 3),
      ('Qual destes é um exemplo de processamento de linguagem natural?', 'Tradução automática de idiomas', TRUE, 0),
      ('Qual destes é um exemplo de processamento de linguagem natural?', 'Aumento da resolução física de um monitor', FALSE, 1),
      ('Qual destes é um exemplo de processamento de linguagem natural?', 'Carregamento de bateria', FALSE, 2),
      ('Qual destes é um exemplo de processamento de linguagem natural?', 'Impressão de fotografias', FALSE, 3),
      ('O que pode uma IA fazer com grandes volumes de texto?', 'Eliminar automaticamente todos os erros humanos', FALSE, 0),
      ('O que pode uma IA fazer com grandes volumes de texto?', 'Transformar texto em eletricidade', FALSE, 1),
      ('O que pode uma IA fazer com grandes volumes de texto?', 'Aumentar a capacidade física do disco', FALSE, 2),
      ('O que pode uma IA fazer com grandes volumes de texto?', 'Analisar e identificar padrões ou informações', TRUE, 3),
      ('Qual é uma utilização da IA em tradução?', 'Aumentar a velocidade da internet', FALSE, 0),
      ('Qual é uma utilização da IA em tradução?', 'Criar energia', FALSE, 1),
      ('Qual é uma utilização da IA em tradução?', 'Reparar cabos', FALSE, 2),
      ('Qual é uma utilização da IA em tradução?', 'Traduzir textos entre diferentes idiomas', TRUE, 3),
      ('O que é uma recomendação personalizada?', 'Uma sugestão completamente aleatória', FALSE, 0),
      ('O que é uma recomendação personalizada?', 'Um tipo de arquivo', FALSE, 1),
      ('O que é uma recomendação personalizada?', 'Uma sugestão baseada em informações ou comportamento do utilizador', TRUE, 2),
      ('O que é uma recomendação personalizada?', 'Um comando de hardware', FALSE, 3),
      ('Qual plataforma pode utilizar algoritmos de recomendação?', 'Serviços de vídeos', TRUE, 0),
      ('Qual plataforma pode utilizar algoritmos de recomendação?', 'Teclados', FALSE, 1),
      ('Qual plataforma pode utilizar algoritmos de recomendação?', 'Cabos USB', FALSE, 2),
      ('Qual plataforma pode utilizar algoritmos de recomendação?', 'Calculadoras simples', FALSE, 3),
      ('O que é um robô?', 'Um navegador', FALSE, 0),
      ('O que é um robô?', 'Um documento digital', FALSE, 1),
      ('O que é um robô?', 'Uma máquina capaz de executar ações programadas ou controladas', TRUE, 2),
      ('O que é um robô?', 'Um tipo de banco de dados', FALSE, 3),
      ('Todos os robôs utilizam inteligência artificial?', 'Não, alguns podem funcionar apenas com instruções pré-programadas', TRUE, 0),
      ('Todos os robôs utilizam inteligência artificial?', 'Sim, obrigatoriamente', FALSE, 1),
      ('Todos os robôs utilizam inteligência artificial?', 'Apenas robôs industriais', FALSE, 2),
      ('Todos os robôs utilizam inteligência artificial?', 'Apenas robôs domésticos', FALSE, 3),
      ('Qual é a relação entre robótica e IA?', 'Robótica não utiliza computadores', FALSE, 0),
      ('Qual é a relação entre robótica e IA?', 'A IA pode fornecer capacidades de percepção, decisão ou adaptação a determinados robôs', TRUE, 1),
      ('Qual é a relação entre robótica e IA?', 'IA só funciona em máquinas físicas', FALSE, 2),
      ('Qual é a relação entre robótica e IA?', 'São exatamente a mesma coisa', FALSE, 3),
      ('Qual é um exemplo de automação inteligente numa empresa?', 'Organização física de cadeiras', FALSE, 0),
      ('Qual é um exemplo de automação inteligente numa empresa?', 'Classificação automática de documentos', TRUE, 1),
      ('Qual é um exemplo de automação inteligente numa empresa?', 'Limpeza manual do escritório', FALSE, 2),
      ('Qual é um exemplo de automação inteligente numa empresa?', 'Impressão manual de cada documento', FALSE, 3),
      ('O que é um dado de entrada para uma IA?', 'Cabo de energia', FALSE, 0),
      ('O que é um dado de entrada para uma IA?', 'Informação fornecida ao sistema para processamento', TRUE, 1),
      ('O que é um dado de entrada para uma IA?', 'Monitor', FALSE, 2),
      ('O que é um dado de entrada para uma IA?', 'Resultado produzido pelo sistema', FALSE, 3),
      ('O que é uma saída de um sistema de IA?', 'Energia elétrica', FALSE, 0),
      ('O que é uma saída de um sistema de IA?', 'Cabo de rede', FALSE, 1),
      ('O que é uma saída de um sistema de IA?', 'Teclado', FALSE, 2),
      ('O que é uma saída de um sistema de IA?', 'Resultado produzido após o processamento da entrada', TRUE, 3),
      ('Qual é um exemplo de entrada para um chatbot?', 'Uma impressora', FALSE, 0),
      ('Qual é um exemplo de entrada para um chatbot?', 'Um cabo USB', FALSE, 1),
      ('Qual é um exemplo de entrada para um chatbot?', 'Uma bateria', FALSE, 2),
      ('Qual é um exemplo de entrada para um chatbot?', 'Uma pergunta escrita pelo utilizador', TRUE, 3),
      ('Qual pode ser a saída de um chatbot?', 'Um processador físico', FALSE, 0),
      ('Qual pode ser a saída de um chatbot?', 'Uma resposta textual', TRUE, 1),
      ('Qual pode ser a saída de um chatbot?', 'Uma tomada elétrica', FALSE, 2),
      ('Qual pode ser a saída de um chatbot?', 'Uma bateria', FALSE, 3),
      ('O que significa personalização por IA?', 'Aumentar a velocidade do computador', FALSE, 0),
      ('O que significa personalização por IA?', 'Criar uma conta automaticamente', FALSE, 1),
      ('O que significa personalização por IA?', 'Adaptar resultados ou experiências às características ou comportamento do utilizador', TRUE, 2),
      ('O que significa personalização por IA?', 'Eliminar dados pessoais', FALSE, 3),
      ('Qual é um benefício potencial da personalização?', 'Apresentar conteúdos mais relevantes para cada utilizador', TRUE, 0),
      ('Qual é um benefício potencial da personalização?', 'Garantir que todos recebem exatamente o mesmo conteúdo', FALSE, 1),
      ('Qual é um benefício potencial da personalização?', 'Eliminar recomendações', FALSE, 2),
      ('Qual é um benefício potencial da personalização?', 'Impedir escolhas', FALSE, 3),
      ('O que é um sistema de detecção de fraude baseado em IA?', 'Sistema de impressão', FALSE, 0),
      ('O que é um sistema de detecção de fraude baseado em IA?', 'Programa para criar documentos', FALSE, 1),
      ('O que é um sistema de detecção de fraude baseado em IA?', 'Sistema que procura padrões associados a possíveis comportamentos fraudulentos', TRUE, 2),
      ('O que é um sistema de detecção de fraude baseado em IA?', 'Sistema que garante que nenhuma fraude existe', FALSE, 3),
      ('Por que a IA pode ser útil na detecção de fraude?', 'Porque nunca produz falsos positivos', FALSE, 0),
      ('Por que a IA pode ser útil na detecção de fraude?', 'Pode analisar grandes quantidades de transações e identificar padrões suspeitos', TRUE, 1),
      ('Por que a IA pode ser útil na detecção de fraude?', 'Porque elimina a necessidade de dados', FALSE, 2),
      ('Por que a IA pode ser útil na detecção de fraude?', 'Porque sabe automaticamente a intenção de todas as pessoas', FALSE, 3),
      ('O que é um viés em um sistema de IA?', 'Uma peça do computador', FALSE, 0),
      ('O que é um viés em um sistema de IA?', 'Uma atualização de software', FALSE, 1),
      ('O que é um viés em um sistema de IA?', 'Uma tendência sistemática que pode influenciar os resultados', TRUE, 2),
      ('O que é um viés em um sistema de IA?', 'Uma conexão de internet', FALSE, 3),
      ('De onde pode surgir viés em IA?', 'Apenas da bateria', FALSE, 0),
      ('De onde pode surgir viés em IA?', 'Apenas da velocidade da internet', FALSE, 1),
      ('De onde pode surgir viés em IA?', 'Apenas do monitor', FALSE, 2),
      ('De onde pode surgir viés em IA?', 'Dos dados utilizados ou da forma como o sistema foi desenvolvido', TRUE, 3),
      ('Qual atitude ajuda a utilizar IA de maneira ética?', 'Ignorar completamente os riscos', FALSE, 0),
      ('Qual atitude ajuda a utilizar IA de maneira ética?', 'Enganar utilizadores', FALSE, 1),
      ('Qual atitude ajuda a utilizar IA de maneira ética?', 'Considerar possíveis impactos e verificar resultados importantes', TRUE, 2),
      ('Qual atitude ajuda a utilizar IA de maneira ética?', 'Utilizar qualquer informação privada sem autorização', FALSE, 3),
      ('O que é privacidade de dados?', 'Proteção das informações pessoais contra uso ou acesso inadequado', TRUE, 0),
      ('O que é privacidade de dados?', 'Criação de imagens', FALSE, 1),
      ('O que é privacidade de dados?', 'Aumento da velocidade da internet', FALSE, 2),
      ('O que é privacidade de dados?', 'Instalação de programas', FALSE, 3),
      ('Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 'São sempre públicos', FALSE, 0),
      ('Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 'Podem conter informações sensíveis ou identificáveis', TRUE, 1),
      ('Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 'Não possuem qualquer valor', FALSE, 2),
      ('Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 'Nunca podem ser armazenados', FALSE, 3),
      ('Qual destas informações pode ser considerada pessoal?', 'Data de um feriado público', FALSE, 0),
      ('Qual destas informações pode ser considerada pessoal?', 'Temperatura média de uma cidade', FALSE, 1),
      ('Qual destas informações pode ser considerada pessoal?', 'Nome de um país', FALSE, 2),
      ('Qual destas informações pode ser considerada pessoal?', 'Número de telefone', TRUE, 3),
      ('O que significa supervisionar uma IA?', 'Remover todos os dados', FALSE, 0),
      ('O que significa supervisionar uma IA?', 'Impedir qualquer atualização', FALSE, 1),
      ('O que significa supervisionar uma IA?', 'Acompanhar seu funcionamento e avaliar seus resultados', TRUE, 2),
      ('O que significa supervisionar uma IA?', 'Desligar o sistema permanentemente', FALSE, 3),
      ('Por que a supervisão humana pode ser importante?', 'Para identificar erros, riscos ou decisões inadequadas', TRUE, 0),
      ('Por que a supervisão humana pode ser importante?', 'Porque IA nunca pode executar tarefas', FALSE, 1),
      ('Por que a supervisão humana pode ser importante?', 'Para impedir toda automação', FALSE, 2),
      ('Por que a supervisão humana pode ser importante?', 'Para substituir todos os algoritmos', FALSE, 3),
      ('Qual é uma limitação comum dos sistemas de IA?', 'Não utilizam modelos', FALSE, 0),
      ('Qual é uma limitação comum dos sistemas de IA?', 'Nunca conseguem processar dados', FALSE, 1),
      ('Qual é uma limitação comum dos sistemas de IA?', 'Podem produzir resultados incorretos', TRUE, 2),
      ('Qual é uma limitação comum dos sistemas de IA?', 'Não conseguem receber entradas', FALSE, 3),
      ('Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 'Rever, compreender e verificar o conteúdo produzido', TRUE, 0),
      ('Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 'Considerar todas as respostas automaticamente verdadeiras', FALSE, 1),
      ('Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 'Entregar sem ler', FALSE, 2),
      ('Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 'Esconder qualquer utilização da ferramenta sempre', FALSE, 3),
      ('Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 'Garante que todas as decisões serão perfeitas', FALSE, 0),
      ('Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 'Impede aprendizagem', FALSE, 1),
      ('Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 'Elimina a necessidade de conhecimento humano', FALSE, 2),
      ('Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 'Pode acelerar determinadas tarefas', TRUE, 3),
      ('Qual afirmação sobre IA é mais adequada?', 'IA é sempre correta', FALSE, 0),
      ('Qual afirmação sobre IA é mais adequada?', 'IA pode ser poderosa, mas seus resultados precisam ser utilizados de forma crítica', TRUE, 1),
      ('Qual afirmação sobre IA é mais adequada?', 'IA não precisa de dados', FALSE, 2),
      ('Qual afirmação sobre IA é mais adequada?', 'IA nunca comete erros', FALSE, 3),
      ('Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 'Fornecer imediatamente todas as informações pessoais', FALSE, 0),
      ('Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 'Aceitar qualquer resultado sem verificar', FALSE, 1),
      ('Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 'Utilizá-la para qualquer finalidade sem considerar riscos', FALSE, 2),
      ('Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 'Compreender sua finalidade, limitações e regras de utilização', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_facil_v3;

    RAISE NOTICE '56 perguntas inseridas com sucesso (source=seed_ia_facil_v3).';
  END IF;
END $$;

COMMIT;
