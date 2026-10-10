-- Alternativas (BE-003, regularização) — IA difícil lote 4: 25 perguntas ativas de IA difícil (seed_ia_dificil_v2, as 25 seguintes por ordem de inserção) ainda sem explicação.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda; só o texto das
-- alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis, sem absolutos só nas erradas).
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
    ('seed_ia_dificil_v2', 'O que é automação robótica de processos (RPA)?', 0, 'Rede social', 'Tecnologia que automatiza o atendimento de clientes usando linguagem natural'),
    ('seed_ia_dificil_v2', 'O que é automação robótica de processos (RPA)?', 1, 'Sistema financeiro', 'Tecnologia que automatiza a produção em fábricas usando braços mecânicos'),
    ('seed_ia_dificil_v2', 'O que é automação robótica de processos (RPA)?', 2, 'Criação de robôs físicos apenas', 'Tecnologia que automatiza decisões complexas com redes neurais'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de saída?', 0, 'Receber dados externos', 'Receber os dados e passá-los ao modelo'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de saída?', 1, 'Treinar o computador físico', 'Guardar os pesos e os parâmetros aprendidos pelo modelo'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de saída?', 3, 'Criar banco de dados', 'Calcular o erro entre a previsão e o valor esperado'),
    ('seed_ia_dificil_v2', 'O que é engenharia de dados em IA?', 0, 'Criação de computadores', 'Processo de treinar, avaliar e comparar modelos usando dados já preparados'),
    ('seed_ia_dificil_v2', 'O que é engenharia de dados em IA?', 2, 'Desenvolvimento de jogos', 'Processo de desenhar, programar e publicar aplicações para utilizadores finais'),
    ('seed_ia_dificil_v2', 'O que é engenharia de dados em IA?', 3, 'Design gráfico', 'Processo de interpretar, explicar e apresentar resultados'),
    ('seed_ia_dificil_v2', 'O que é ética em Inteligência Artificial?', 0, 'Criação de computadores', 'Estudo do desempenho e da velocidade das tecnologias de IA'),
    ('seed_ia_dificil_v2', 'O que é ética em Inteligência Artificial?', 1, 'Armazenamento de arquivos', 'Estudo do custo e da rentabilidade das tecnologias de IA'),
    ('seed_ia_dificil_v2', 'O que é ética em Inteligência Artificial?', 3, 'Programação básica', 'Estudo da programação e da arquitetura das tecnologias de IA'),
    ('seed_ia_dificil_v2', 'O que são redes neurais convolucionais (CNNs)?', 0, 'Sistemas operacionais', 'Redes especializadas no processamento de textos e padrões de linguagem'),
    ('seed_ia_dificil_v2', 'O que são redes neurais convolucionais (CNNs)?', 2, 'Bancos de dados', 'Redes especializadas no processamento de sequências e dados temporais'),
    ('seed_ia_dificil_v2', 'O que são redes neurais convolucionais (CNNs)?', 3, 'Redes usadas apenas para pagamentos', 'Redes especializadas na análise de tabelas e dados financeiros'),
    ('seed_ia_dificil_v2', 'O que é segurança de modelos de IA?', 1, 'Exclusão dos usuários', 'Controlo de custos, prazos e recursos usados no treino dos modelos'),
    ('seed_ia_dificil_v2', 'O que é segurança de modelos de IA?', 2, 'Redução da inteligência', 'Redução do tamanho, da latência e do consumo dos modelos'),
    ('seed_ia_dificil_v2', 'O que é segurança de modelos de IA?', 3, 'Remoção do modelo', 'Verificação de acertos, erros e desempenho médio dos modelos'),
    ('seed_ia_dificil_v2', 'O que é privacidade de dados em IA?', 1, 'Aumento de publicidade', 'Aumento da precisão das previsões feitas por sistemas inteligentes'),
    ('seed_ia_dificil_v2', 'O que é privacidade de dados em IA?', 2, 'Exclusão da tecnologia', 'Armazenamento das informações utilizadas por sistemas inteligentes'),
    ('seed_ia_dificil_v2', 'O que é privacidade de dados em IA?', 3, 'Divulgação de todos os dados', 'Divulgação pública das informações dos sistemas inteligentes'),
    ('seed_ia_dificil_v2', 'O que é mecanismo de atenção em IA?', 1, 'Ferramenta de design', 'Técnica que permite ao modelo guardar partes importantes dos dados de treino'),
    ('seed_ia_dificil_v2', 'O que é mecanismo de atenção em IA?', 2, 'Sistema de armazenamento', 'Técnica que permite ao modelo repetir partes importantes dos dados de saída'),
    ('seed_ia_dificil_v2', 'O que é mecanismo de atenção em IA?', 3, 'Método de apagar informações', 'Técnica que permite ao modelo comprimir os dados de entrada'),
    ('seed_ia_dificil_v2', 'O que é transparência em IA?', 0, 'Impedir auditoria', 'Capacidade de automatizar as decisões do sistema sem intervenção humana'),
    ('seed_ia_dificil_v2', 'O que é transparência em IA?', 1, 'Remover dados', 'Capacidade de reduzir os dados usados nas decisões'),
    ('seed_ia_dificil_v2', 'O que é transparência em IA?', 2, 'Ocultar funcionamento do modelo', 'Capacidade de proteger o código e os parâmetros do sistema contra cópias'),
    ('seed_ia_dificil_v2', 'Qual é um desafio dos grandes modelos de IA?', 1, 'Ausência de algoritmos', 'Baixo custo de treinamento e necessidade de poucos dados de entrada'),
    ('seed_ia_dificil_v2', 'Qual é um desafio dos grandes modelos de IA?', 2, 'Não utilizar energia', 'Pouca capacidade de generalização e necessidade de dados rotulados'),
    ('seed_ia_dificil_v2', 'Qual é um desafio dos grandes modelos de IA?', 3, 'Falta completa de capacidade', 'Impossibilidade de aprender padrões e custo de energia reduzido'),
    ('seed_ia_dificil_v2', 'O que é um agente inteligente?', 0, 'Banco de dados', 'Sistema que registra o ambiente e guarda dados para consultas futuras'),
    ('seed_ia_dificil_v2', 'O que é um agente inteligente?', 1, 'Arquivo digital', 'Sistema que recebe ordens e executa passos fixos escritos por pessoas'),
    ('seed_ia_dificil_v2', 'O que é um agente inteligente?', 3, 'Programa sem ação', 'Sistema que observa o ambiente e apresenta relatórios sem tomar decisões'),
    ('seed_ia_dificil_v2', 'O que são redes neurais recorrentes (RNNs)?', 0, 'Sistemas de arquivos', 'Redes desenvolvidas para trabalhar com dados de imagem'),
    ('seed_ia_dificil_v2', 'O que são redes neurais recorrentes (RNNs)?', 2, 'Redes sem memória', 'Redes desenvolvidas para trabalhar com dados estáticos e tabelas'),
    ('seed_ia_dificil_v2', 'O que são redes neurais recorrentes (RNNs)?', 3, 'Programas de edição', 'Redes desenvolvidas para trabalhar com dados sem ordem definida'),
    ('seed_ia_dificil_v2', 'O que é AGI?', 0, 'Banco de dados', 'Inteligência Artificial Generativa capaz de criar diversos tipos de conteúdos novos e originais'),
    ('seed_ia_dificil_v2', 'O que é AGI?', 2, 'Sistema operacional', 'Inteligência Artificial Gráfica capaz de processar diversos tipos de imagens'),
    ('seed_ia_dificil_v2', 'O que é AGI?', 3, 'Aplicativo móvel', 'Inteligência Artificial Guiada capaz de seguir instruções passo a passo'),
    ('seed_ia_dificil_v2', 'O que é um algoritmo de Machine Learning?', 0, 'Uma rede social', 'Conjunto de regras usadas para permitir que máquinas executem tarefas fixas'),
    ('seed_ia_dificil_v2', 'O que é um algoritmo de Machine Learning?', 1, 'Um equipamento físico', 'Conjunto de peças usadas para permitir que máquinas processem grandes dados'),
    ('seed_ia_dificil_v2', 'O que é um algoritmo de Machine Learning?', 3, 'Um banco de dados', 'Conjunto de tabelas usadas para armazenar o que as máquinas aprendem'),
    ('seed_ia_dificil_v2', 'O que é embedding em IA?', 0, 'Arquivo de imagem', 'Representação gráfica de informações para que utilizadores possam visualizá-las'),
    ('seed_ia_dificil_v2', 'O que é embedding em IA?', 1, 'Sistema operacional', 'Compressão de informações para que modelos possam armazená-las'),
    ('seed_ia_dificil_v2', 'O que é embedding em IA?', 3, 'Código de segurança', 'Codificação de informações para que modelos possam protegê-las de acessos'),
    ('seed_ia_dificil_v2', 'O que é viés algorítmico?', 0, 'Aumento da velocidade da IA', 'Resultado lento causado por limitações de hardware nos servidores ou redes'),
    ('seed_ia_dificil_v2', 'O que é viés algorítmico?', 2, 'Redução de custos', 'Resultado impreciso causado por falhas de rede nos dados ou sistemas'),
    ('seed_ia_dificil_v2', 'O que é viés algorítmico?', 3, 'Melhoria automática do sistema', 'Resultado inesperado causado por atualizações automáticas dos dados ou modelos'),
    ('seed_ia_dificil_v2', 'O que é detecção de objetos?', 1, 'Tradução automática', 'Técnica de classificar o tipo de imagem sem localizar objetos dentro dela'),
    ('seed_ia_dificil_v2', 'O que é detecção de objetos?', 2, 'Exclusão de arquivos', 'Técnica de remover o fundo de imagens ou vídeos antes da edição'),
    ('seed_ia_dificil_v2', 'O que é detecção de objetos?', 3, 'Criação de textos', 'Técnica de descrever em texto o conteúdo geral de imagens ou vídeos'),
    ('seed_ia_dificil_v2', 'O que é uma rede neural profunda?', 0, 'Rede sem dados de treinamento', 'Rede neural composta por uma única camada de processamento'),
    ('seed_ia_dificil_v2', 'O que é uma rede neural profunda?', 1, 'Programa usado somente para cálculos simples', 'Rede neural composta por regras fixas de processamento'),
    ('seed_ia_dificil_v2', 'O que é uma rede neural profunda?', 2, 'Sistema sem parâmetros', 'Rede neural composta por várias camadas de armazenamento'),
    ('seed_ia_dificil_v2', 'Qual é o principal objetivo do desenvolvimento responsável de Inteligência Artificial?', 1, 'Eliminar qualquer tecnologia existente', 'Criar sistemas rápidos, baratos, rentáveis e competitivos para o mercado'),
    ('seed_ia_dificil_v2', 'Qual é o principal objetivo do desenvolvimento responsável de Inteligência Artificial?', 2, 'Substituir todas as pessoas imediatamente', 'Criar sistemas avançados, autónomos, flexíveis e independentes das pessoas'),
    ('seed_ia_dificil_v2', 'Qual é o principal objetivo do desenvolvimento responsável de Inteligência Artificial?', 3, 'Impedir evolução científica', 'Criar sistemas pequenos, simples, leves e fáceis de atualizar'),
    ('seed_ia_dificil_v2', 'O que é copiloto de IA?', 0, 'Sistema de segurança física', 'Sistema de piloto automático que conduz veículos em tarefas de transporte'),
    ('seed_ia_dificil_v2', 'O que é copiloto de IA?', 2, 'Banco de dados', 'Ferramenta de busca que encontra documentos internos'),
    ('seed_ia_dificil_v2', 'O que é copiloto de IA?', 3, 'Rede de computadores', 'Sistema de monitorização que avisa equipas sobre falhas em computadores'),
    ('seed_ia_dificil_v2', 'Por que dados de qualidade são importantes para IA?', 1, 'Porque substituem computadores', 'Porque modelos dependem do hardware para aprender padrões corretos'),
    ('seed_ia_dificil_v2', 'Por que dados de qualidade são importantes para IA?', 2, 'Porque eliminam toda programação', 'Porque modelos dependem dos algoritmos para aprender padrões corretos'),
    ('seed_ia_dificil_v2', 'Por que dados de qualidade são importantes para IA?', 3, 'Porque impedem treinamento', 'Porque modelos dependem do volume e não da qualidade'),
    ('seed_ia_dificil_v2', 'O que é MLOps?', 0, 'Linguagem de programação', 'Práticas para recolher, anotar e armazenar dados usados em Machine Learning'),
    ('seed_ia_dificil_v2', 'O que é MLOps?', 1, 'Sistema de pagamentos', 'Práticas para treinar, comparar e escolher algoritmos de Machine Learning no laboratório'),
    ('seed_ia_dificil_v2', 'O que é MLOps?', 3, 'Hardware específico', 'Práticas para configurar, instalar e atualizar servidores usados em Machine Learning'),
    ('seed_ia_dificil_v2', 'O que são GANs (Generative Adversarial Networks)?', 0, 'Sistemas sem treinamento', 'Redes formadas por codificador e decodificador que cooperam entre si para comprimir dados'),
    ('seed_ia_dificil_v2', 'O que são GANs (Generative Adversarial Networks)?', 2, 'Sistemas bancários', 'Redes formadas por agente e ambiente que interagem para maximizar recompensas'),
    ('seed_ia_dificil_v2', 'O que são GANs (Generative Adversarial Networks)?', 3, 'Redes sociais', 'Redes formadas por vários classificadores que votam para rotular dados reais'),
    ('seed_ia_dificil_v2', 'O que é backpropagation?', 0, 'Processo de apagar dados', 'Algoritmo usado para dividir os dados de uma rede neural'),
    ('seed_ia_dificil_v2', 'O que é backpropagation?', 1, 'Método de segurança', 'Algoritmo usado para escolher a arquitetura de uma rede neural antes do treinamento'),
    ('seed_ia_dificil_v2', 'O que é backpropagation?', 3, 'Tipo de hardware', 'Algoritmo usado para medir o desempenho de uma rede neural depois do treinamento'),
    ('seed_ia_dificil_v2', 'O que é inferência em tempo real?', 0, 'Exclusão de informações', 'Geração de dados de treino rapidamente após receber uma nova versão do modelo'),
    ('seed_ia_dificil_v2', 'O que é inferência em tempo real?', 1, 'Treinamento inicial', 'Ajuste de pesos do modelo rapidamente após receber um grande volume de dados'),
    ('seed_ia_dificil_v2', 'O que é inferência em tempo real?', 3, 'Criação de hardware', 'Cópia de segurança dos pesos feita após cada atualização')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
