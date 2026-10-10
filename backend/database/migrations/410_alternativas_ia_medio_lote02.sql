-- Alternativas (BE-003, regularização) — IA médio lote 2: as 25 perguntas seguintes de IA médio sem explicação (as 4 últimas do seed_ia_medio_v1, as 5 do v2 e as 16 primeiras do v3, na ordem dos ficheiros)
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
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 0, 'Automação sem qualquer software', 'Uso de máquinas para repetir os mesmos passos de uma tarefa, sem analisar os dados nem decidir'),
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 2, 'Trabalho exclusivamente manual', 'Uso de programas que executam tarefas de acordo com regras fixas e sem aprender com os dados'),
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 3, 'Uso de computadores apenas para jogos', 'Uso de assistentes virtuais para conversar com os utilizadores, mesmo sem executar nenhuma tarefa'),
    ('seed_ia_medio_v1', 'O que é um modelo de linguagem?', 0, 'Dicionário impresso', 'Programa que guarda uma lista de palavras e das suas definições para consulta'),
    ('seed_ia_medio_v1', 'O que é um modelo de linguagem?', 2, 'Sistema operacional', 'Sistema que traduz o código escrito pelo programador para linguagem de máquina'),
    ('seed_ia_medio_v1', 'O que é um modelo de linguagem?', 3, 'Tradutor humano', 'Modelo treinado para reconhecer rostos e objetos com base em imagens aprendidas'),
    ('seed_ia_medio_v1', 'O que é contexto em uma conversa com IA?', 0, 'Apenas o nome do usuário', 'Conjunto de comandos técnicos usados para configurar o servidor onde o modelo está instalado'),
    ('seed_ia_medio_v1', 'O que é contexto em uma conversa com IA?', 1, 'O tamanho do monitor', 'Resposta produzida pelo modelo depois de analisar as instruções recebidas do utilizador'),
    ('seed_ia_medio_v1', 'O que é contexto em uma conversa com IA?', 2, 'A velocidade da internet', 'Quantidade de dados usados para treinar o modelo antes de ser disponibilizado ao público'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 0, 'Porque substitui a verificação humana', 'Reduz o tamanho do modelo e acelera o processamento de cada resposta'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 2, 'Porque elimina todos os erros', 'Permite ao modelo guardar a conversa para outras utilizações futuras'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 3, 'Porque aumenta automaticamente a velocidade da internet', 'Garante que o modelo usa fontes oficiais nas respostas que produz'),
    ('seed_ia_medio_v2', 'O que é reconhecimento de padrões?', 1, 'Formatação de computadores', 'Eliminação de erros e repetições nos dados'),
    ('seed_ia_medio_v2', 'O que é reconhecimento de padrões?', 2, 'Criação manual de documentos', 'Previsão exata de um valor numérico'),
    ('seed_ia_medio_v2', 'O que é reconhecimento de padrões?', 3, 'Exclusão de informações', 'Organização dos dados em tabelas ordenadas'),
    ('seed_ia_medio_v2', 'O que é viés em IA?', 0, 'Tipo de teclado', 'Erro isolado que aparece uma só vez num resultado'),
    ('seed_ia_medio_v2', 'O que é viés em IA?', 1, 'Aumento da memória RAM', 'Falha técnica causada por falta de memória no sistema'),
    ('seed_ia_medio_v2', 'O que é viés em IA?', 3, 'Velocidade de internet', 'Atraso no tempo de resposta quando há muitos pedidos'),
    ('seed_ia_medio_v2', 'O que é automação com IA?', 0, 'Remover dados', 'Uso de IA para apagar dados antigos e libertar armazenamento'),
    ('seed_ia_medio_v2', 'O que é automação com IA?', 2, 'Criar cabos', 'Uso de IA para fabricar peças de equipamentos informáticos'),
    ('seed_ia_medio_v2', 'O que é automação com IA?', 3, 'Desligar computadores', 'Uso de IA para monitorizar computadores e desligá-los à noite'),
    ('seed_ia_medio_v2', 'O que significa treinamento de um modelo?', 1, 'Criação de uma conta bancária', 'Processo de instalar o modelo em vários servidores'),
    ('seed_ia_medio_v2', 'O que significa treinamento de um modelo?', 2, 'Limpeza física do computador', 'Processo de apagar os dados que o modelo já aprendeu'),
    ('seed_ia_medio_v2', 'O que significa treinamento de um modelo?', 3, 'Instalação de um teclado', 'Processo de avaliar o modelo com perguntas de pessoas'),
    ('seed_ia_medio_v2', 'Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 0, 'Cor do computador', 'Velocidade da ligação à internet'),
    ('seed_ia_medio_v2', 'Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 1, 'Tamanho da tela', 'Quantidade de memória do aparelho'),
    ('seed_ia_medio_v2', 'Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 2, 'Marca do teclado', 'Preço do software usado no sistema'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 0, 'Sistemas baseados em regras funcionam apenas sem computadores', 'O sistema baseado em regras aprende sozinho com os dados, enquanto o de aprendizado de máquina segue regras escritas pelo programador'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 1, 'O aprendizado de máquina não utiliza dados', 'O sistema baseado em regras exige muitos dados de treinamento, enquanto o aprendizado de máquina funciona com regras fixas'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 2, 'Os dois sistemas são obrigatoriamente idênticos', 'Os dois sistemas aprendem a partir de dados, mas o baseado em regras precisa de mais tempo de treinamento e de mais memória'),
    ('seed_ia_medio_v3', 'Durante o treinamento de um modelo, para que serve o conjunto de validação?', 1, 'Armazenar exclusivamente dados pessoais', 'Guardar uma cópia de segurança do modelo depois do treinamento'),
    ('seed_ia_medio_v3', 'Durante o treinamento de um modelo, para que serve o conjunto de validação?', 2, 'Executar o modelo apenas depois da publicação', 'Medir o desempenho final do modelo com dados totalmente novos'),
    ('seed_ia_medio_v3', 'Durante o treinamento de um modelo, para que serve o conjunto de validação?', 3, 'Substituir completamente os dados de treinamento', 'Aumentar o número de exemplos usados no treinamento'),
    ('seed_ia_medio_v3', 'O que caracteriza o overfitting?', 1, 'O modelo não possui parâmetros', 'O modelo apresenta resultados medianos nos dados de treinamento, mas melhora bastante quando recebe dados novos'),
    ('seed_ia_medio_v3', 'O que caracteriza o overfitting?', 2, 'O modelo não consegue processar nenhuma informação', 'O modelo é demasiado simples para os dados e por isso não consegue aprender os padrões, nem no treino'),
    ('seed_ia_medio_v3', 'O que caracteriza o overfitting?', 3, 'O modelo apresenta resultados ruins tanto no treino quanto em novos dados', 'O modelo apresenta resultados semelhantes no treino e em dados novos porque aprendeu padrões gerais'),
    ('seed_ia_medio_v3', 'Qual situação representa melhor underfitting?', 0, 'O modelo apresenta excelente desempenho em qualquer conjunto', 'O modelo tem ótimo desempenho no treino, mas fraco com dados novos'),
    ('seed_ia_medio_v3', 'Qual situação representa melhor underfitting?', 2, 'O modelo memoriza perfeitamente os exemplos de treino', 'O modelo memoriza os exemplos de treino e acerta neles com facilidade'),
    ('seed_ia_medio_v3', 'Qual situação representa melhor underfitting?', 3, 'O modelo é complexo demais para os dados', 'O modelo é muito complexo e ajusta-se até ao ruído existente nos dados'),
    ('seed_ia_medio_v3', 'Por que separar dados de treinamento e teste é importante?', 1, 'Para aumentar artificialmente a quantidade de dados', 'Para reduzir o tempo de treinamento ao usar menos exemplos no modelo'),
    ('seed_ia_medio_v3', 'Por que separar dados de treinamento e teste é importante?', 2, 'Para impedir qualquer aprendizagem', 'Para garantir que o modelo aprende os mesmos exemplos duas vezes seguidas'),
    ('seed_ia_medio_v3', 'Por que separar dados de treinamento e teste é importante?', 3, 'Para eliminar a necessidade de validação', 'Para evitar que o modelo veja dados pessoais durante o treinamento'),
    ('seed_ia_medio_v3', 'O que significa generalização em aprendizado de máquina?', 0, 'Capacidade de aumentar o tamanho dos arquivos', 'Capacidade de um modelo funcionar em equipamentos diferentes'),
    ('seed_ia_medio_v3', 'O que significa generalização em aprendizado de máquina?', 1, 'Capacidade de executar somente uma tarefa específica', 'Capacidade de um modelo executar muitas tarefas ao mesmo tempo'),
    ('seed_ia_medio_v3', 'O que significa generalização em aprendizado de máquina?', 3, 'Capacidade de memorizar os dados de treino', 'Capacidade de um modelo memorizar os exemplos de treino'),
    ('seed_ia_medio_v3', 'Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?', 1, 'Excesso de memória RAM', 'Possível underfitting'),
    ('seed_ia_medio_v3', 'Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?', 2, 'Ausência de algoritmo', 'Excesso de dados de teste'),
    ('seed_ia_medio_v3', 'O que é uma variável ou característica utilizada por um modelo para fazer uma previsão?', 0, 'Prompt final', 'Prompt'),
    ('seed_ia_medio_v3', 'O que é uma variável ou característica utilizada por um modelo para fazer uma previsão?', 2, 'Tokenizador', 'Token'),
    ('seed_ia_medio_v3', 'Num sistema que prevê o preço de uma casa usando área, localização e número de quartos, esses elementos são exemplos de:', 0, 'Saídas', 'Previsões'),
    ('seed_ia_medio_v3', 'Num sistema que prevê o preço de uma casa usando área, localização e número de quartos, esses elementos são exemplos de:', 1, 'Erros', 'Parâmetros'),
    ('seed_ia_medio_v3', 'Em um problema de classificação, o que normalmente se pretende prever?', 1, 'Apenas um número decimal contínuo', 'Um valor numérico contínuo'),
    ('seed_ia_medio_v3', 'Em um problema de classificação, o que normalmente se pretende prever?', 2, 'O tamanho do modelo', 'Uma sequência de texto novo'),
    ('seed_ia_medio_v3', 'Em um problema de classificação, o que normalmente se pretende prever?', 3, 'A quantidade de memória disponível', 'Um valor de erro do modelo'),
    ('seed_ia_medio_v3', 'Qual exemplo representa um problema de regressão?', 0, 'Identificar se uma imagem contém um gato', 'Detetar se uma foto tem gatos'),
    ('seed_ia_medio_v3', 'Qual exemplo representa classificação binária?', 0, 'Estimar o salário de uma pessoa', 'Estimar o salário de uma pessoa com base na experiência'),
    ('seed_ia_medio_v3', 'Qual exemplo representa classificação binária?', 2, 'Prever o consumo mensal de energia', 'Prever o consumo mensal de energia de uma empresa'),
    ('seed_ia_medio_v3', 'Qual exemplo representa classificação binária?', 3, 'Prever a temperatura amanhã', 'Prever a temperatura máxima de amanhã numa cidade'),
    ('seed_ia_medio_v3', 'O que é aprendizado supervisionado?', 0, 'Aprendizado baseado apenas em regras manuais', 'Treinamento em que o modelo procura grupos nos dados sem usar respostas conhecidas'),
    ('seed_ia_medio_v3', 'O que é aprendizado supervisionado?', 2, 'Treinamento exclusivamente por tentativa física', 'Treinamento em que o modelo aprende por recompensas e penalizações ao agir'),
    ('seed_ia_medio_v3', 'O que é aprendizado supervisionado?', 3, 'Aprendizado realizado sem qualquer dado', 'Treinamento em que as regras são escritas pelo programador antes de ver os dados'),
    ('seed_ia_medio_v3', 'Qual tarefa é típica do aprendizado não supervisionado?', 0, 'Previsão de uma nota conhecida', 'Previsão da nota de um aluno com base em notas passadas'),
    ('seed_ia_medio_v3', 'Qual tarefa é típica do aprendizado não supervisionado?', 1, 'Identificação de spam com exemplos marcados', 'Identificação de spam com exemplos já marcados por pessoas'),
    ('seed_ia_medio_v3', 'Qual tarefa é típica do aprendizado não supervisionado?', 2, 'Classificação de imagens previamente rotuladas', 'Classificação de imagens com legendas previamente indicadas'),
    ('seed_ia_medio_v3', 'O que é clustering?', 0, 'Técnica para aumentar a resolução de imagens', 'Técnica que classifica elementos em categorias definidas com base em rótulos prévios'),
    ('seed_ia_medio_v3', 'O que é clustering?', 2, 'Processo de tradução automática', 'Técnica que prevê valores numéricos com base em exemplos e resultados anteriores'),
    ('seed_ia_medio_v3', 'O que é clustering?', 3, 'Método de criptografia', 'Técnica que reduz o número de características dos dados mantendo o essencial'),
    ('seed_ia_medio_v3', 'Uma empresa divide seus clientes em grupos com comportamentos semelhantes sem definir previamente os grupos. Qual técnica pode ser adequada?', 0, 'Compilação', 'Regressão'),
    ('seed_ia_medio_v3', 'Uma empresa divide seus clientes em grupos com comportamentos semelhantes sem definir previamente os grupos. Qual técnica pode ser adequada?', 1, 'Criptografia', 'Classificação')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA médio lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
