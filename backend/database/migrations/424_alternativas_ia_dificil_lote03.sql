-- Alternativas (BE-003, regularização) — IA difícil lote 3: 25 perguntas ativas de IA difícil (seed_ia_dificil_v2, as 25 seguintes por ordem de inserção) ainda sem explicação.
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
    ('seed_ia_dificil_v2', 'O que é alinhamento de IA?', 0, 'Criação de hardware', 'Processo de ajustar o hardware dos servidores para a IA funcionar melhor'),
    ('seed_ia_dificil_v2', 'O que é alinhamento de IA?', 1, 'Aumento de velocidade', 'Processo de acelerar o treinamento dos sistemas de IA para responderem aos pedidos mais depressa'),
    ('seed_ia_dificil_v2', 'O que é alinhamento de IA?', 2, 'Redução de dados', 'Processo de reduzir os dados dos sistemas de IA para que atuem com menos erros de cálculo'),
    ('seed_ia_dificil_v2', 'O que é um Transformer em Inteligência Artificial?', 1, 'Um antivírus', 'Arquitetura neural baseada em filtros convolucionais para processar imagens'),
    ('seed_ia_dificil_v2', 'O que é um Transformer em Inteligência Artificial?', 2, 'Um computador físico', 'Arquitetura neural baseada em ligações recorrentes para processar sequências'),
    ('seed_ia_dificil_v2', 'O que é um Transformer em Inteligência Artificial?', 3, 'Um banco de dados', 'Arquitetura de software baseada em tabelas para armazenar e consultar sequências'),
    ('seed_ia_dificil_v2', 'O que é computação quântica aplicada à IA?', 0, 'Substituição de todos os dados', 'Uso de computadores quânticos para potencialmente substituir os dados de treino'),
    ('seed_ia_dificil_v2', 'O que é computação quântica aplicada à IA?', 1, 'Criação de redes sociais', 'Uso de computadores comuns para potencialmente simular cálculos quânticos de modelos de IA'),
    ('seed_ia_dificil_v2', 'O que é computação quântica aplicada à IA?', 3, 'Método de pagamento', 'Uso de sensores quânticos para potencialmente medir a energia consumida pelos modelos de IA'),
    ('seed_ia_dificil_v2', 'O que é um modelo de difusão?', 1, 'Banco de dados', 'Modelo discriminativo usado principalmente para classificar imagens através de camadas convolucionais'),
    ('seed_ia_dificil_v2', 'O que é um modelo de difusão?', 2, 'Sistema financeiro', 'Modelo generativo usado principalmente para criar texto através da previsão do token seguinte'),
    ('seed_ia_dificil_v2', 'O que é um modelo de difusão?', 3, 'Antivírus', 'Modelo de aprendizado por reforço usado principalmente para controlar agentes através de recompensas'),
    ('seed_ia_dificil_v2', 'O que é overfitting em Machine Learning?', 0, 'Quando o algoritmo é removido', 'Quando o modelo aprende de forma insuficiente os dados de treinamento e perde capacidade de generalização'),
    ('seed_ia_dificil_v2', 'O que é overfitting em Machine Learning?', 1, 'Quando o computador desliga', 'Quando o modelo é treinado com poucos dados e perde capacidade de armazenar os pesos'),
    ('seed_ia_dificil_v2', 'O que é overfitting em Machine Learning?', 3, 'Quando o modelo não recebe dados', 'Quando o modelo recebe dados repetidos e perde capacidade de atualizar os parâmetros'),
    ('seed_ia_dificil_v2', 'O que é recall em Machine Learning?', 0, 'Tempo de processamento', 'Capacidade do modelo de responder rapidamente aos casos recebidos'),
    ('seed_ia_dificil_v2', 'O que é recall em Machine Learning?', 1, 'Número de arquivos recuperados', 'Capacidade do modelo de evitar classificar como positivos casos que são negativos'),
    ('seed_ia_dificil_v2', 'O que é recall em Machine Learning?', 2, 'Capacidade de armazenamento', 'Capacidade do modelo de guardar corretamente os dados usados durante o treinamento'),
    ('seed_ia_dificil_v2', 'O que é IA generativa multimodal?', 0, 'IA apenas textual', 'IA capaz de trabalhar e criar conteúdos usando um só tipo de dados'),
    ('seed_ia_dificil_v2', 'O que é IA generativa multimodal?', 2, 'Sistema sem entrada', 'IA capaz de trabalhar e criar conteúdos usando vários idiomas ao mesmo tempo'),
    ('seed_ia_dificil_v2', 'O que é IA generativa multimodal?', 3, 'Programa básico', 'IA capaz de trabalhar e criar conteúdos usando diferentes servidores em simultâneo'),
    ('seed_ia_dificil_v2', 'O que é conjunto de teste em Machine Learning?', 0, 'Arquivos temporários', 'Dados usados para ajustar os pesos do modelo durante o treinamento'),
    ('seed_ia_dificil_v2', 'O que é conjunto de teste em Machine Learning?', 1, 'Dados usados apenas para criar o modelo', 'Dados usados para escolher os melhores hiperparâmetros antes do treinamento final'),
    ('seed_ia_dificil_v2', 'O que é conjunto de teste em Machine Learning?', 2, 'Dados sem importância', 'Dados usados para aumentar o conjunto de treino com exemplos artificiais'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial forte?', 0, 'Sistema sem aprendizagem', 'Conceito de IA com capacidade limitada a uma única tarefa bem definida'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial forte?', 2, 'Calculadora automática', 'Conceito de IA com capacidade de superar as pessoas em jogos de estratégia'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial forte?', 3, 'Programa simples', 'Conceito de IA com capacidade de funcionar sem ligação à internet'),
    ('seed_ia_dificil_v2', 'O que é singularidade tecnológica?', 0, 'Atualização de software comum', 'Hipótese de um futuro onde a IA deixa de evoluir por falta de dados'),
    ('seed_ia_dificil_v2', 'O que é singularidade tecnológica?', 1, 'Instalação de aplicativo', 'Hipótese de um futuro onde a IA substitui os computadores por dispositivos quânticos'),
    ('seed_ia_dificil_v2', 'O que é singularidade tecnológica?', 2, 'Criação de banco de dados', 'Hipótese de um futuro onde a IA fica limitada por leis iguais nos vários países'),
    ('seed_ia_dificil_v2', 'Qual é uma aplicação avançada da IA na medicina?', 0, 'Controle de pagamentos', 'Auxílio na gestão de pagamentos através da análise de faturas'),
    ('seed_ia_dificil_v2', 'Qual é uma aplicação avançada da IA na medicina?', 1, 'Criação de jogos', 'Auxílio na criação de jogos educativos através da análise de dados de pacientes'),
    ('seed_ia_dificil_v2', 'Qual é uma aplicação avançada da IA na medicina?', 2, 'Apenas impressão de documentos', 'Auxílio na impressão de receitas através da leitura de ficheiros e dados médicos'),
    ('seed_ia_dificil_v2', 'O que é Dropout em redes neurais?', 0, 'Processo de tradução', 'Técnica que aumenta aleatoriamente o número de neurônios durante o treinamento para evitar underfitting'),
    ('seed_ia_dificil_v2', 'O que é Dropout em redes neurais?', 2, 'Método de apagar todo o modelo', 'Técnica que remove aleatoriamente alguns exemplos durante o treinamento para evitar overfitting'),
    ('seed_ia_dificil_v2', 'O que é Dropout em redes neurais?', 3, 'Sistema de armazenamento', 'Técnica que congela alguns neurônios durante o treinamento para acelerar a convergência'),
    ('seed_ia_dificil_v2', 'O que é aprendizado não supervisionado?', 0, 'Sistema sem dados', 'Método onde o modelo aprende com dados que trazem rótulos definidos por pessoas'),
    ('seed_ia_dificil_v2', 'O que é aprendizado não supervisionado?', 1, 'Modelo treinado apenas com respostas prontas', 'Método onde o modelo aprende por tentativa e erro com recompensas'),
    ('seed_ia_dificil_v2', 'O que é aprendizado não supervisionado?', 3, 'Algoritmo sem objetivos', 'Método onde o modelo compara resultados com respostas corretas já definidas'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial estreita (ANI)?', 0, 'Sistema sem programação', 'IA capaz de aprender qualquer tarefa'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial estreita (ANI)?', 1, 'Robô totalmente independente', 'IA capaz de sentir emoções humanas'),
    ('seed_ia_dificil_v2', 'O que é inteligência artificial estreita (ANI)?', 3, 'IA com consciência humana', 'IA que supera a inteligência humana'),
    ('seed_ia_dificil_v2', 'O que é underfitting?', 0, 'Quando aumenta a memória do computador', 'Quando o modelo aprende demasiado os detalhes e o ruído dos dados de treino'),
    ('seed_ia_dificil_v2', 'O que é underfitting?', 1, 'Quando o modelo aprende perfeitamente', 'Quando o modelo aprende bem os padrões, mas falha ao receber dados novos'),
    ('seed_ia_dificil_v2', 'O que é underfitting?', 2, 'Quando há excesso de dados', 'Quando o modelo recebe dados em excesso e deixa de conseguir guardá-los'),
    ('seed_ia_dificil_v2', 'O que é alucinação em modelos de IA?', 0, 'Quando o computador desliga', 'Quando um modelo deixa de responder por falta de memória disponível durante a geração'),
    ('seed_ia_dificil_v2', 'O que é alucinação em modelos de IA?', 2, 'Quando dados são apagados', 'Quando um modelo apaga informações do treino e apresenta o resultado como definitivo'),
    ('seed_ia_dificil_v2', 'O que é alucinação em modelos de IA?', 3, 'Quando o modelo fica mais rápido', 'Quando um modelo gera respostas muito rápidas e apresenta o tempo como indicador de qualidade'),
    ('seed_ia_dificil_v2', 'O que é democratização da IA?', 0, 'Impedir inovação', 'Reservar o desenvolvimento de IA a grandes empresas e centros de investigação'),
    ('seed_ia_dificil_v2', 'O que é democratização da IA?', 2, 'Eliminar tecnologia', 'Substituir as ferramentas de IA por processos manuais'),
    ('seed_ia_dificil_v2', 'O que é democratização da IA?', 3, 'Restringir totalmente o uso', 'Limitar o uso de ferramentas de IA a especialistas com formação técnica'),
    ('seed_ia_dificil_v2', 'O que é inferência em IA?', 0, 'Criação de dados', 'Processo em que um modelo é treinado para gerar dados sintéticos novos'),
    ('seed_ia_dificil_v2', 'O que é inferência em IA?', 1, 'Processo de treinamento inicial', 'Processo em que um modelo ajusta os pesos com base nos erros cometidos'),
    ('seed_ia_dificil_v2', 'O que é inferência em IA?', 2, 'Exclusão do modelo', 'Processo em que um modelo é reduzido para usar menos memória'),
    ('seed_ia_dificil_v2', 'O que é otimização de modelos de IA?', 1, 'Reduzir dados sempre', 'Processo de reduzir dados de treino, aumentando o tamanho do modelo'),
    ('seed_ia_dificil_v2', 'O que é otimização de modelos de IA?', 2, 'Bloquear usuários', 'Processo de restringir o acesso ao modelo, reduzindo o número de utilizadores'),
    ('seed_ia_dificil_v2', 'O que é otimização de modelos de IA?', 3, 'Apagar o modelo', 'Processo de substituir o modelo por outro, sem comparar o desempenho dos dois'),
    ('seed_ia_dificil_v2', 'O que é IA explicável (Explainable AI)?', 0, 'IA sem treinamento', 'Técnicas que tornam os modelos de IA mais rápidos a responder'),
    ('seed_ia_dificil_v2', 'O que é IA explicável (Explainable AI)?', 1, 'Banco de imagens', 'Técnicas que guardam as decisões dos modelos de IA em bases de dados para auditoria'),
    ('seed_ia_dificil_v2', 'O que é IA explicável (Explainable AI)?', 2, 'Sistema de jogos', 'Técnicas que tornam os modelos de IA mais pequenos para serem usados em telemóveis'),
    ('seed_ia_dificil_v2', 'O que é modelo discriminativo?', 0, 'Modelo usado apenas para criar imagens', 'Modelo que aprende a gerar novos dados parecidos com os de treino'),
    ('seed_ia_dificil_v2', 'O que é modelo discriminativo?', 1, 'Sistema sem treinamento', 'Modelo que aprende a comprimir dados para ocupar menos espaço'),
    ('seed_ia_dificil_v2', 'O que é modelo discriminativo?', 2, 'Banco de dados', 'Modelo que aprende a reduzir o ruído dos dados'),
    ('seed_ia_dificil_v2', 'O que é batch size?', 0, 'Quantidade de aplicativos instalados', 'Quantidade de camadas processadas antes de atualizar os parâmetros do modelo'),
    ('seed_ia_dificil_v2', 'O que é batch size?', 2, 'Número de computadores conectados', 'Quantidade de épocas processadas antes de atualizar os parâmetros do modelo'),
    ('seed_ia_dificil_v2', 'O que é batch size?', 3, 'Tamanho do arquivo final', 'Quantidade de parâmetros atualizados em cada camada do modelo treinado'),
    ('seed_ia_dificil_v2', 'O que é IA responsável?', 1, 'IA sem regras', 'Desenvolvimento e uso de IA considerando velocidade, custo e mercado'),
    ('seed_ia_dificil_v2', 'O que é IA responsável?', 2, 'Sistema sem dados', 'Desenvolvimento e uso de IA considerando a precisão, o desempenho e a escala técnica'),
    ('seed_ia_dificil_v2', 'O que é IA responsável?', 3, 'Automação sem controle', 'Automação de decisões por IA considerando eficiência, rapidez e redução de pessoal'),
    ('seed_ia_dificil_v2', 'O que é agente autônomo de IA?', 0, 'Programa sem decisões', 'Sistema capaz de responder a perguntas e gerar texto para atingir objetivos'),
    ('seed_ia_dificil_v2', 'O que é agente autônomo de IA?', 1, 'Editor de imagens', 'Sistema capaz de editar imagens para atingir objetivos'),
    ('seed_ia_dificil_v2', 'O que é agente autônomo de IA?', 3, 'Arquivo digital', 'Sistema capaz de armazenar dados e consultar registos para atingir objetivos'),
    ('seed_ia_dificil_v2', 'O que é processamento de linguagem natural (NLP)?', 1, 'Sistema de armazenamento físico', 'Área da IA que permite computadores reconhecerem rostos e objetos em imagens'),
    ('seed_ia_dificil_v2', 'O que é processamento de linguagem natural (NLP)?', 2, 'Método de segurança bancária', 'Área da IA que permite computadores aprenderem por tentativa e erro com recompensas'),
    ('seed_ia_dificil_v2', 'O que é processamento de linguagem natural (NLP)?', 3, 'Tecnologia de impressão', 'Área da IA que permite computadores preverem valores numéricos a partir de tabelas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
