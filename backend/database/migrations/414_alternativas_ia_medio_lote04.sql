-- Alternativas (BE-003, regularização) — IA médio lote 4: as 24 últimas perguntas de IA médio sem explicação (22 do seed_ia_medio_v3, de "seleção de características" até "explicabilidade", mais 1 do v4 e 1 do v5)
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta
-- CERTA NÃO muda; só o texto das alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis,
-- sem absolutos só nas erradas).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_ia_medio_v3', 'Um modelo apresenta resultados ruins porque recebe informações irrelevantes e redundantes. Qual etapa pode ajudar?', 0, 'Compressão do monitor', 'Aumento do conjunto de teste'),
    ('seed_ia_medio_v3', 'Um modelo apresenta resultados ruins porque recebe informações irrelevantes e redundantes. Qual etapa pode ajudar?', 1, 'Criação de mais senhas', 'Aumento do número de camadas'),
    ('seed_ia_medio_v3', 'Um modelo apresenta resultados ruins porque recebe informações irrelevantes e redundantes. Qual etapa pode ajudar?', 3, 'Aumento das notificações', 'Duplicação dos exemplos de treino'),
    ('seed_ia_medio_v3', 'O que é redução de dimensionalidade?', 0, 'Aumentar o número de variáveis indefinidamente', 'Aumentar o número de características combinando as existentes para obter mais detalhe'),
    ('seed_ia_medio_v3', 'O que é redução de dimensionalidade?', 1, 'Transformar texto em áudio', 'Reduzir o número de exemplos do conjunto de dados mantendo a mesma variedade'),
    ('seed_ia_medio_v3', 'O que é redução de dimensionalidade?', 2, 'Eliminar todos os dados', 'Reduzir o tamanho do modelo apagando as camadas menos utilizadas no treinamento'),
    ('seed_ia_medio_v3', 'Qual pode ser uma vantagem da redução de dimensionalidade?', 0, 'Garantir 100% de precisão', 'Aumentar o número de exemplos e facilitar a recolha de dados novos'),
    ('seed_ia_medio_v3', 'Qual pode ser uma vantagem da redução de dimensionalidade?', 1, 'Aumentar obrigatoriamente os dados disponíveis', 'Tornar os dados mais fáceis de recolher e de guardar em ficheiros'),
    ('seed_ia_medio_v3', 'Qual pode ser uma vantagem da redução de dimensionalidade?', 2, 'Eliminar qualquer risco', 'Corrigir os rótulos errados e facilitar a avaliação dos resultados'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 0, 'Processo de coletar exclusivamente dados de treino', 'Processo de ajustar os pesos de um modelo com dados já conhecidos e rotulados'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 1, 'Criação física do computador', 'Processo de avaliar o modelo comparando previsões com respostas conhecidas de teste'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 2, 'Exclusão do modelo', 'Processo de recolher e limpar os dados que serão usados mais tarde no treinamento'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre treinamento e inferência?', 0, 'Treinamento nunca utiliza dados', 'Treinamento utiliza o modelo para gerar resultados; inferência ajusta o modelo com dados'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre treinamento e inferência?', 1, 'São exatamente a mesma etapa', 'Treinamento acontece no telemóvel do utilizador; inferência acontece no servidor da empresa'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre treinamento e inferência?', 3, 'Inferência sempre modifica os pesos', 'Treinamento serve para avaliar o modelo; inferência serve para escolher os dados'),
    ('seed_ia_medio_v3', 'O que significa latência em uma aplicação de IA?', 0, 'Número de parâmetros', 'Número de pedidos que o sistema consegue processar durante um minuto'),
    ('seed_ia_medio_v3', 'O que significa latência em uma aplicação de IA?', 1, 'Taxa de acerto', 'Percentagem de respostas corretas que o sistema dá nos testes feitos'),
    ('seed_ia_medio_v3', 'O que significa latência em uma aplicação de IA?', 3, 'Quantidade de dados de treinamento', 'Quantidade de memória que o sistema utiliza para guardar cada resposta'),
    ('seed_ia_medio_v3', 'Por que a latência é importante num chatbot?', 0, 'Latência elimina erros factuais', 'Respostas muito curtas podem prejudicar a precisão das informações dadas'),
    ('seed_ia_medio_v3', 'Por que a latência é importante num chatbot?', 2, 'Latência determina a cor da interface', 'Respostas muito rápidas podem aumentar o número de erros factuais produzidos'),
    ('seed_ia_medio_v3', 'Por que a latência é importante num chatbot?', 3, 'Latência substitui o treinamento', 'Respostas muito longas podem obrigar o modelo a repetir o treinamento inicial'),
    ('seed_ia_medio_v3', 'O que são parâmetros de um modelo?', 0, 'Dados obrigatoriamente pessoais', 'Valores escolhidos pelo programador antes do início do treinamento'),
    ('seed_ia_medio_v3', 'O que são parâmetros de um modelo?', 1, 'Perguntas feitas pelos utilizadores', 'Respostas produzidas pelo modelo depois de terminado o treinamento'),
    ('seed_ia_medio_v3', 'O que são parâmetros de um modelo?', 3, 'Apenas arquivos externos', 'Ficheiros externos que o modelo consulta durante o treinamento'),
    ('seed_ia_medio_v3', 'Qual é uma diferença entre parâmetros e hiperparâmetros?', 0, 'Hiperparâmetros são sempre dados de entrada', 'Hiperparâmetros são aprendidos durante o treinamento; parâmetros são definidos para controlar o processo'),
    ('seed_ia_medio_v3', 'Qual é uma diferença entre parâmetros e hiperparâmetros?', 1, 'Parâmetros são exclusivamente configurações de hardware', 'Parâmetros são os dados de entrada do modelo; hiperparâmetros são os resultados que ele produz'),
    ('seed_ia_medio_v3', 'Qual é uma diferença entre parâmetros e hiperparâmetros?', 2, 'Ambos são sempre aprendidos automaticamente', 'Os dois são escolhidos pelo programador, mas os parâmetros só mudam depois do treinamento'),
    ('seed_ia_medio_v3', 'Qual dos seguintes é um exemplo de hiperparâmetro?', 0, 'Texto produzido pelo modelo', 'Resposta do modelo'),
    ('seed_ia_medio_v3', 'Qual dos seguintes é um exemplo de hiperparâmetro?', 3, 'Peso aprendido por um neurônio', 'Peso de um neurónio'),
    ('seed_ia_medio_v3', 'O que é um modelo pré-treinado?', 0, 'Modelo sem parâmetros', 'Modelo que foi treinado do zero com os dados privados de uma única empresa e não pode ser adaptado'),
    ('seed_ia_medio_v3', 'O que é um modelo pré-treinado?', 2, 'Modelo que só funciona offline', 'Modelo que ainda não foi treinado e vai aprender enquanto responde aos pedidos dos utilizadores'),
    ('seed_ia_medio_v3', 'O que é um modelo pré-treinado?', 3, 'Modelo que nunca recebeu dados', 'Modelo que foi testado por pessoas antes de ser publicado, mas que não passou por treinamento'),
    ('seed_ia_medio_v3', 'Qual é uma vantagem potencial de utilizar um modelo pré-treinado?', 0, 'Impede adaptação', 'Pode dispensar a recolha de dados em fases posteriores do desenvolvimento da solução'),
    ('seed_ia_medio_v3', 'Qual é uma vantagem potencial de utilizar um modelo pré-treinado?', 1, 'Elimina toda necessidade de avaliação', 'Pode tornar desnecessária a verificação dos resultados antes da utilização real'),
    ('seed_ia_medio_v3', 'Qual é uma vantagem potencial de utilizar um modelo pré-treinado?', 2, 'Garante que o modelo será correto', 'Pode aumentar a precisão do modelo sem necessidade de o testar com casos reais'),
    ('seed_ia_medio_v3', 'O que é fine-tuning?', 0, 'Exclusão dos parâmetros', 'Treinamento de um modelo novo, de raiz, com dados escolhidos para um domínio específico'),
    ('seed_ia_medio_v3', 'O que é fine-tuning?', 1, 'Limpeza física do computador', 'Avaliação final de um modelo pré-treinado com dados novos, que não foram vistos antes'),
    ('seed_ia_medio_v3', 'O que é fine-tuning?', 2, 'Compressão dos dados', 'Redução do tamanho de um modelo pré-treinado para funcionar em equipamentos mais simples'),
    ('seed_ia_medio_v3', 'Uma empresa adapta um modelo de linguagem geral com exemplos específicos do seu setor. Isso pode ser considerado:', 0, 'Clustering', 'Inferência'),
    ('seed_ia_medio_v3', 'Uma empresa adapta um modelo de linguagem geral com exemplos específicos do seu setor. Isso pode ser considerado:', 2, 'Criptografia', 'Tokenização'),
    ('seed_ia_medio_v3', 'Uma empresa adapta um modelo de linguagem geral com exemplos específicos do seu setor. Isso pode ser considerado:', 3, 'Renderização', 'Normalização'),
    ('seed_ia_medio_v3', 'O que é um token em modelos de linguagem?', 1, 'Um tipo de cabo', 'Uma frase completa que o modelo guarda no seu dicionário de respostas'),
    ('seed_ia_medio_v3', 'O que é um token em modelos de linguagem?', 2, 'Um componente físico do servidor', 'Uma chave de acesso que identifica o utilizador perante o servidor'),
    ('seed_ia_medio_v3', 'O que é um token em modelos de linguagem?', 3, 'Uma moeda obrigatoriamente financeira', 'Uma medida do tempo que o modelo demora a gerar cada resposta'),
    ('seed_ia_medio_v3', 'Por que a tokenização é importante em modelos de linguagem?', 0, 'Impede o processamento de texto', 'Corrige erros de ortografia antes de o modelo processar o texto'),
    ('seed_ia_medio_v3', 'Por que a tokenização é importante em modelos de linguagem?', 1, 'Substitui o treinamento', 'Traduz o texto para outro idioma antes de o modelo o processar'),
    ('seed_ia_medio_v3', 'Por que a tokenização é importante em modelos de linguagem?', 2, 'Elimina o significado das palavras', 'Aumenta o tamanho dos dados para o modelo ter mais exemplos'),
    ('seed_ia_medio_v3', 'O que significa contexto em uma interação com um modelo de linguagem?', 0, 'O tamanho do teclado', 'Quantidade de dados usados para treinar o modelo antes da publicação'),
    ('seed_ia_medio_v3', 'O que significa contexto em uma interação com um modelo de linguagem?', 2, 'Memória física do computador', 'Memória física do equipamento onde o modelo foi instalado e configurado'),
    ('seed_ia_medio_v3', 'O que significa contexto em uma interação com um modelo de linguagem?', 3, 'Apenas a velocidade da internet', 'Velocidade da ligação que o utilizador usa para falar com o modelo'),
    ('seed_ia_medio_v3', 'Um utilizador fornece objetivo, público-alvo, formato e restrições numa instrução para IA. Qual é o principal benefício?', 1, 'Eliminar qualquer possibilidade de erro', 'Acelerar o treinamento do modelo de IA'),
    ('seed_ia_medio_v3', 'Um utilizador fornece objetivo, público-alvo, formato e restrições numa instrução para IA. Qual é o principal benefício?', 2, 'Desativar o processamento', 'Evitar a necessidade de rever a resposta'),
    ('seed_ia_medio_v3', 'Um utilizador fornece objetivo, público-alvo, formato e restrições numa instrução para IA. Qual é o principal benefício?', 3, 'Reduzir obrigatoriamente o modelo', 'Aumentar o tamanho do modelo utilizado'),
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 0, 'Falta de energia elétrica', 'Produção de conteúdo lento porque o servidor tem muitos pedidos para processar em simultâneo'),
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 1, 'Falha física do computador', 'Recusa de responder a um pedido porque o conteúdo é considerado inadequado ou perigoso'),
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 2, 'Exclusão automática do modelo', 'Repetição da mesma frase muitas vezes porque o modelo ficou preso num ciclo de geração'),
    ('seed_ia_medio_v3', 'Qual estratégia pode reduzir o risco de utilizar uma informação incorreta produzida por IA?', 0, 'Aumentar o tamanho do prompt sem verificar fontes', 'Pedir ao modelo uma resposta mais longa e com mais detalhes'),
    ('seed_ia_medio_v3', 'Qual estratégia pode reduzir o risco de utilizar uma informação incorreta produzida por IA?', 1, 'Evitar qualquer revisão', 'Confiar na resposta quando o modelo apresenta muita certeza'),
    ('seed_ia_medio_v3', 'Qual estratégia pode reduzir o risco de utilizar uma informação incorreta produzida por IA?', 3, 'Aceitar sempre a primeira resposta', 'Usar a resposta se estiver bem escrita e organizada'),
    ('seed_ia_medio_v3', 'O que é explicabilidade em IA?', 0, 'Capacidade de gerar senhas', 'Capacidade de um sistema chegar a resultados corretos mesmo quando recebe dados incompletos ou errados'),
    ('seed_ia_medio_v3', 'O que é explicabilidade em IA?', 1, 'Capacidade de aumentar a velocidade da internet', 'Capacidade de um sistema responder rapidamente quando recebe muitos pedidos ao mesmo tempo de vários utilizadores'),
    ('seed_ia_medio_v3', 'O que é explicabilidade em IA?', 3, 'Capacidade de armazenar mais arquivos', 'Capacidade de um sistema guardar os dados dos utilizadores de forma segura e protegida contra acessos'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 1, 'Elimina a necessidade de supervisão', 'Pode acelerar as decisões do sistema e reduzir os dados de que ele precisa para funcionar'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 2, 'Garante que o modelo nunca erre', 'Pode reduzir o tempo de treinamento e o custo de guardar os dados usados nele'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 3, 'Substitui completamente os dados', 'Pode dispensar a revisão humana nas decisões tomadas pelo sistema em casos delicados'),
    ('seed_ia_medio_v4', 'O que é aprendizado de máquina (Machine Learning)?', 0, 'Um método para montar computadores manualmente', 'Uma técnica em que programadores escrevem as regras de cada decisão'),
    ('seed_ia_medio_v4', 'O que é aprendizado de máquina (Machine Learning)?', 2, 'Um programa usado apenas para editar vídeos', 'Uma técnica usada para guardar e organizar grandes volumes de dados'),
    ('seed_ia_medio_v4', 'O que é aprendizado de máquina (Machine Learning)?', 3, 'Uma tecnologia que não utiliza dados', 'Uma técnica usada para ligar computadores entre si numa rede segura'),
    ('seed_ia_medio_v5', 'Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 0, 'Porque qualquer modelo de IA produz necessariamente resultados aleatórios', 'Porque o modelo pode ser lento e demorar a analisar os currículos recebidos'),
    ('seed_ia_medio_v5', 'Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 2, 'Porque os dados não influenciam as decisões do modelo', 'Porque os currículos têm de ser analisados primeiro por pessoas antes do modelo'),
    ('seed_ia_medio_v5', 'Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 3, 'Porque eliminar os dados torna o sistema mais preciso', 'Porque o modelo pode guardar os currículos e partilhá-los com outras empresas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA médio lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 71).', v_updated;
END $$;
