-- Alternativas (BE-003, regularização) — IA médio lote 1: as 25 primeiras perguntas ativas de IA médio sem explicação (seed_ia_medio_v1, ordem do ficheiro 041)
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
    ('seed_ia_medio_v1', 'O que é treinamento de um modelo de aprendizado de máquina?', 0, 'Atualização manual de uma página', 'Processo em que o utilizador corrige manualmente cada resposta dada pelo sistema'),
    ('seed_ia_medio_v1', 'O que é treinamento de um modelo de aprendizado de máquina?', 1, 'Criação de uma conta de email', 'Etapa em que o modelo é instalado em vários servidores para atender os utilizadores'),
    ('seed_ia_medio_v1', 'O que é treinamento de um modelo de aprendizado de máquina?', 3, 'Instalação de um teclado', 'Processo em que o programador reescreve o código do modelo para corrigir erros'),
    ('seed_ia_medio_v1', 'O que são dados de treinamento?', 1, 'Dados que nunca são utilizados', 'Dados guardados depois do treinamento para avaliar o desempenho final'),
    ('seed_ia_medio_v1', 'O que são dados de treinamento?', 2, 'Apenas senhas', 'Dados usados para proteger o acesso ao sistema e às contas'),
    ('seed_ia_medio_v1', 'O que são dados de treinamento?', 3, 'Apenas arquivos de áudio', 'Dados criados pelo modelo depois de ser colocado em utilização'),
    ('seed_ia_medio_v1', 'O que são dados de teste?', 0, 'Dados exclusivamente financeiros', 'Dados usados para ajustar os parâmetros do modelo durante a fase de aprendizagem com exemplos'),
    ('seed_ia_medio_v1', 'O que são dados de teste?', 1, 'Dados apagados antes do treinamento', 'Dados descartados antes do treinamento por conterem erros, repetições ou valores em falta'),
    ('seed_ia_medio_v1', 'O que são dados de teste?', 3, 'Dados usados apenas para criar contas', 'Dados usados para treinar o modelo com exemplos já conhecidos e respostas indicadas'),
    ('seed_ia_medio_v1', 'O que é overfitting?', 0, 'Quando um computador fica sem bateria', 'Quando um modelo é treinado com poucos dados e não consegue aprender padrões úteis nem nos próprios exemplos'),
    ('seed_ia_medio_v1', 'O que é overfitting?', 1, 'Quando um programa é desinstalado', 'Quando um modelo fica desatualizado porque os dados reais mudaram e já não correspondem aos usados'),
    ('seed_ia_medio_v1', 'O que é overfitting?', 2, 'Quando um modelo não recebe dados', 'Quando um modelo é treinado com demasiados dados e por isso demora muito tempo a responder'),
    ('seed_ia_medio_v1', 'O que é generalização em aprendizado de máquina?', 0, 'Capacidade de criar contas', 'Capacidade de um modelo memorizar com exatidão cada um dos exemplos usados durante o seu treinamento'),
    ('seed_ia_medio_v1', 'O que é generalização em aprendizado de máquina?', 1, 'Capacidade de armazenar mais arquivos', 'Capacidade de um modelo dar a mesma resposta a pedidos diferentes, sem distinguir os casos recebidos'),
    ('seed_ia_medio_v1', 'O que é generalização em aprendizado de máquina?', 2, 'Capacidade de aumentar a memória física', 'Capacidade de um modelo ser executado em vários equipamentos diferentes, de forma automática'),
    ('seed_ia_medio_v1', 'O que é classificação em aprendizado de máquina?', 0, 'Conversão de moedas', 'Tarefa de prever um valor numérico a partir das entradas'),
    ('seed_ia_medio_v1', 'O que é classificação em aprendizado de máquina?', 1, 'Criação de documentos', 'Tarefa de gerar novos textos a partir de uma instrução'),
    ('seed_ia_medio_v1', 'O que é classificação em aprendizado de máquina?', 3, 'Organização de arquivos por tamanho', 'Tarefa de reduzir o tamanho dos dados de entrada'),
    ('seed_ia_medio_v1', 'Qual é um exemplo de classificação?', 1, 'Aumentar o volume de um áudio', 'Estimar o preço de venda de uma casa a partir da área'),
    ('seed_ia_medio_v1', 'Qual é um exemplo de classificação?', 2, 'Alterar o brilho do monitor', 'Prever a temperatura de amanhã a partir dos dados de hoje'),
    ('seed_ia_medio_v1', 'Qual é um exemplo de classificação?', 3, 'Copiar um arquivo', 'Gerar um resumo de um texto longo para leitura rápida'),
    ('seed_ia_medio_v1', 'O que é regressão em aprendizado de máquina?', 0, 'Criação de senhas', 'Tarefa de separar exemplos em categorias fixas'),
    ('seed_ia_medio_v1', 'O que é regressão em aprendizado de máquina?', 2, 'Classificação de imagens exclusivamente', 'Tarefa de agrupar dados parecidos sem rótulos'),
    ('seed_ia_medio_v1', 'O que é regressão em aprendizado de máquina?', 3, 'Organização de documentos', 'Tarefa de gerar texto novo a partir de exemplos'),
    ('seed_ia_medio_v1', 'Qual pode ser um exemplo de regressão?', 0, 'Identificar se uma imagem contém um gato', 'Identificar se uma imagem contém um gato ou um cão'),
    ('seed_ia_medio_v1', 'Qual pode ser um exemplo de regressão?', 2, 'Classificar emails como spam', 'Classificar mensagens como urgentes ou não urgentes'),
    ('seed_ia_medio_v1', 'Qual pode ser um exemplo de regressão?', 3, 'Separar arquivos por extensão', 'Separar fotografias por álbum conforme o conteúdo'),
    ('seed_ia_medio_v1', 'O que é processamento de linguagem natural?', 1, 'Tecnologia de carregamento', 'Área da IA dedicada ao reconhecimento de objetos e pessoas em imagens captadas por câmaras'),
    ('seed_ia_medio_v1', 'O que é processamento de linguagem natural?', 2, 'Sistema para controlar impressoras', 'Área da computação dedicada à gestão e ao controlo de equipamentos ligados a uma rede'),
    ('seed_ia_medio_v1', 'O que é processamento de linguagem natural?', 3, 'Sistema bancário', 'Área da IA dedicada à criação de programas capazes de jogar e vencer jogos de tabuleiro'),
    ('seed_ia_medio_v1', 'O que é análise de sentimento?', 0, 'Cálculo de salários', 'Técnica usada para contar quantas palavras diferentes existem num conjunto de textos'),
    ('seed_ia_medio_v1', 'O que é análise de sentimento?', 1, 'Medição da temperatura', 'Técnica usada para traduzir automaticamente opiniões escritas de um idioma para outro'),
    ('seed_ia_medio_v1', 'O que é análise de sentimento?', 2, 'Análise de velocidade da internet', 'Técnica usada para corrigir erros de ortografia e de pontuação em textos escritos'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 0, 'Um aplicativo de mensagens', 'Programa que executa os cálculos usados para treinar e avaliar um modelo'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 2, 'Um dispositivo físico', 'Equipamento físico onde os dados são armazenados e processados durante o treinamento'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 3, 'Uma senha', 'Regra que define como o modelo deve combinar os dados para chegar a um resultado'),
    ('seed_ia_medio_v1', 'O que é um rótulo em aprendizado supervisionado?', 1, 'Número de série do monitor', 'Informação que identifica o equipamento onde o exemplo de treinamento foi recolhido'),
    ('seed_ia_medio_v1', 'O que é um rótulo em aprendizado supervisionado?', 2, 'Nome do computador', 'Texto que descreve o programa usado para recolher e guardar cada exemplo de treinamento'),
    ('seed_ia_medio_v1', 'O que é um rótulo em aprendizado supervisionado?', 3, 'Senha do usuário', 'Código que protege o acesso aos exemplos de treinamento guardados no servidor central'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado supervisionado?', 0, 'O modelo nunca recebe dados', 'O modelo aprende sozinho a procurar grupos nos dados, sem nenhuma resposta indicada'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado supervisionado?', 2, 'O modelo depende exclusivamente de intervenção humana em cada previsão', 'O modelo recebe uma ordem humana para cada previsão que produz depois de treinado'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado supervisionado?', 3, 'O sistema funciona apenas sem algoritmos', 'O modelo aprende por tentativa e erro, recebendo recompensas pelas ações que realiza'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado não supervisionado?', 1, 'O modelo apenas copia textos', 'O sistema aprende com exemplos em que cada resposta correta foi indicada previamente por pessoas'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado não supervisionado?', 2, 'Não existem dados', 'O sistema aprende por tentativa e erro, recebendo uma recompensa quando acerta na ação escolhida'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado não supervisionado?', 3, 'Todos os dados possuem respostas previamente indicadas', 'O sistema repete exatamente as respostas que viu durante o treinamento, sem analisar os dados'),
    ('seed_ia_medio_v1', 'O que é agrupamento, ou clustering?', 1, 'Sistema de pagamentos', 'Técnica que atribui dados a categorias já definidas por pessoas'),
    ('seed_ia_medio_v1', 'O que é agrupamento, ou clustering?', 2, 'Técnica de criptografia', 'Técnica que prevê valores futuros com base em dados anteriores'),
    ('seed_ia_medio_v1', 'O que é agrupamento, ou clustering?', 3, 'Método de edição de vídeo', 'Técnica que reduz o tamanho dos dados sem perder informação'),
    ('seed_ia_medio_v1', 'Por que a qualidade dos dados é importante?', 0, 'Porque elimina a necessidade de testes', 'Dados em maior quantidade tornam o modelo mais rápido a responder aos pedidos'),
    ('seed_ia_medio_v1', 'Por que a qualidade dos dados é importante?', 1, 'Porque qualquer dado produz o mesmo resultado', 'Dados organizados em tabelas permitem reduzir o custo de armazenamento do modelo'),
    ('seed_ia_medio_v1', 'Por que a qualidade dos dados é importante?', 2, 'Porque dados nunca influenciam modelos', 'Dados mais antigos tornam o modelo mais estável e menos sujeito a mudanças'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 0, 'Criação de imagens', 'Processo de recolher dados de várias fontes e reuni-los numa única tabela organizada para análise'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 1, 'Exclusão de todos os dados', 'Processo de apagar os dados mais antigos do sistema para libertar espaço de armazenamento'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 3, 'Formatação de um computador', 'Processo de converter os dados para outro formato para serem lidos por outro programa'),
    ('seed_ia_medio_v1', 'O que é engenharia de prompt?', 0, 'Reparação de servidores', 'Processo de treinar de raiz um novo modelo de IA com milhões de exemplos de texto recolhidos'),
    ('seed_ia_medio_v1', 'O que é engenharia de prompt?', 1, 'Criação de redes elétricas', 'Processo de programar a interface gráfica usada pelas pessoas para conversar com um modelo de IA'),
    ('seed_ia_medio_v1', 'O que é engenharia de prompt?', 3, 'Construção física de computadores', 'Processo de configurar o hardware necessário para um modelo de IA responder mais depressa'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 1, 'Pedido extremamente ambíguo', 'Pedido curto, com poucas palavras e sem indicar o formato esperado'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 2, 'Ausência total de contexto', 'Pedido genérico, que deixa o modelo escolher livremente o objetivo'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 3, 'Informações contraditórias', 'Pedido longo, com muitas instruções que se repetem de formas diferentes'),
    ('seed_ia_medio_v1', 'O que significa alucinação em IA generativa?', 0, 'Desligamento do computador', 'Geração de uma resposta lenta porque o modelo está a processar muitos pedidos ao mesmo tempo'),
    ('seed_ia_medio_v1', 'O que significa alucinação em IA generativa?', 2, 'Falha elétrica', 'Recusa do modelo em responder a pedidos que considera inadequados ou perigosos para o utilizador'),
    ('seed_ia_medio_v1', 'O que significa alucinação em IA generativa?', 3, 'Falha da internet', 'Repetição da mesma resposta várias vezes, mesmo quando o utilizador muda a pergunta feita'),
    ('seed_ia_medio_v1', 'Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 0, 'Pedir sempre uma resposta mais longa', 'Pedir ao próprio modelo que confirme que a resposta anterior está certa'),
    ('seed_ia_medio_v1', 'Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 1, 'Aceitar automaticamente toda resposta', 'Usar a resposta se estiver bem escrita e apresentada de forma organizada'),
    ('seed_ia_medio_v1', 'Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 2, 'Ignorar qualquer fonte externa', 'Preferir as respostas mais longas, porque costumam trazer mais detalhes'),
    ('seed_ia_medio_v1', 'O que é multimodalidade em IA?', 0, 'Capacidade de funcionar sem dados', 'Capacidade de funcionar em vários dispositivos diferentes, como telemóvel, computador e televisão'),
    ('seed_ia_medio_v1', 'O que é multimodalidade em IA?', 1, 'Capacidade de usar apenas texto', 'Capacidade de responder em vários idiomas diferentes, como português, inglês, francês ou espanhol'),
    ('seed_ia_medio_v1', 'O que é multimodalidade em IA?', 3, 'Capacidade de desligar o computador', 'Capacidade de executar várias tarefas ao mesmo tempo, como responder, traduzir e resumir'),
    ('seed_ia_medio_v1', 'O que é geração de código por IA?', 1, 'Impressão de circuitos', 'Uso de modelos de IA para testar e reparar fisicamente os circuitos de um computador'),
    ('seed_ia_medio_v1', 'O que é geração de código por IA?', 2, 'Instalação de internet', 'Uso de modelos de IA para instalar e configurar redes de internet em grandes edifícios'),
    ('seed_ia_medio_v1', 'O que é geração de código por IA?', 3, 'Criação de hardware automaticamente', 'Uso de modelos de IA para desenhar e fabricar automaticamente novos componentes de hardware'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 0, 'Porque código gerado por IA nunca funciona', 'Pode deixar de funcionar quando o computador é reiniciado'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 1, 'Porque nenhum código pode ser testado', 'Pode ser escrito numa linguagem que o computador não entende'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 3, 'Porque IA não conhece programação', 'Pode ocupar demasiado espaço de armazenamento no sistema')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA médio lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
