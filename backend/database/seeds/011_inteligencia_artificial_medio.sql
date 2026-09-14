-- Migration/seed: conteúdo Inteligência Artificial, nível Médio (30 perguntas)
-- Fonte: lote de 80 perguntas de Inteligência Artificial fornecido pelo
-- proprietário do projeto (perguntas 26–55 do lote, marcadas como "Médio").
-- Ver 010_inteligencia_artificial_facil.sql para o contexto completo do lote,
-- incluindo a observação sobre o nível Difícil (56–80) ainda pendente por
-- documento incompleto.
--
-- ⚠️ ATENÇÃO — SOBREPOSIÇÃO DE CONTEÚDO ENCONTRADA (não corrigida
-- automaticamente): a pergunta "O que é visão computacional?" já existe em
-- 006_tecnologia_dificil.sql (categoria Tecnologia/Difícil), com a mesma
-- pergunta mas alternativas reescritas com palavras diferentes. Isso NÃO é um
-- erro técnico — são categorias diferentes (Tecnologia vs. Inteligência
-- Artificial) e nenhuma constraint impede — mas um usuário pode ver duas
-- perguntas quase idênticas em categorias distintas. Optei por inserir como
-- enviado, sinalizando aqui para revisão editorial se desejado.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): respostas corretas originalmente TODAS "A" —
-- posição redistribuída com seed fixa (50 — distinta das seeds 42 a 49 já
-- usadas) e distribuição controlada entre A/B/C/D, reprodutível — conteúdo
-- pedagógico inalterado, só a ORDEM de exibição mudou.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_medio_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_medio_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_medio AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_ia_medio_v1'
    FROM (VALUES
      ('O que é treinamento de um modelo de aprendizado de máquina?'),
      ('O que são dados de treinamento?'),
      ('O que são dados de teste?'),
      ('O que é overfitting?'),
      ('O que é generalização em aprendizado de máquina?'),
      ('O que é classificação em aprendizado de máquina?'),
      ('Qual é um exemplo de classificação?'),
      ('O que é regressão em aprendizado de máquina?'),
      ('Qual pode ser um exemplo de regressão?'),
      ('O que é processamento de linguagem natural?'),
      ('O que é análise de sentimento?'),
      ('O que é um dataset?'),
      ('O que é um rótulo em aprendizado supervisionado?'),
      ('O que caracteriza o aprendizado supervisionado?'),
      ('O que caracteriza o aprendizado não supervisionado?'),
      ('O que é agrupamento, ou clustering?'),
      ('O que é viés em um sistema de IA?'),
      ('Por que a qualidade dos dados é importante?'),
      ('O que é limpeza de dados?'),
      ('O que é engenharia de prompt?'),
      ('Qual característica tende a melhorar um prompt?'),
      ('O que significa alucinação em IA generativa?'),
      ('Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?'),
      ('O que é multimodalidade em IA?'),
      ('O que é geração de código por IA?'),
      ('Por que código gerado por IA deve ser revisado?'),
      ('O que é automação inteligente?'),
      ('O que é um modelo de linguagem?'),
      ('O que é contexto em uma conversa com IA?'),
      ('Por que fornecer contexto adequado a uma IA pode melhorar a resposta?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_medio q
    JOIN (VALUES
      ('O que é treinamento de um modelo de aprendizado de máquina?', 'Atualização manual de uma página', FALSE, 0),
      ('O que é treinamento de um modelo de aprendizado de máquina?', 'Criação de uma conta de email', FALSE, 1),
      ('O que é treinamento de um modelo de aprendizado de máquina?', 'Processo em que o modelo ajusta seus parâmetros com base em dados para aprender padrões', TRUE, 2),
      ('O que é treinamento de um modelo de aprendizado de máquina?', 'Instalação de um teclado', FALSE, 3),
      ('O que são dados de treinamento?', 'Dados utilizados para ajudar um modelo a aprender padrões ou relações', TRUE, 0),
      ('O que são dados de treinamento?', 'Dados que nunca são utilizados', FALSE, 1),
      ('O que são dados de treinamento?', 'Apenas senhas', FALSE, 2),
      ('O que são dados de treinamento?', 'Apenas arquivos de áudio', FALSE, 3),
      ('O que são dados de teste?', 'Dados exclusivamente financeiros', FALSE, 0),
      ('O que são dados de teste?', 'Dados apagados antes do treinamento', FALSE, 1),
      ('O que são dados de teste?', 'Dados usados para avaliar o desempenho de um modelo em exemplos que não foram usados para seu treinamento', TRUE, 2),
      ('O que são dados de teste?', 'Dados usados apenas para criar contas', FALSE, 3),
      ('O que é overfitting?', 'Quando um computador fica sem bateria', FALSE, 0),
      ('O que é overfitting?', 'Quando um programa é desinstalado', FALSE, 1),
      ('O que é overfitting?', 'Quando um modelo não recebe dados', FALSE, 2),
      ('O que é overfitting?', 'Quando um modelo se adapta excessivamente aos dados de treinamento e pode ter desempenho pior em dados novos', TRUE, 3),
      ('O que é generalização em aprendizado de máquina?', 'Capacidade de criar contas', FALSE, 0),
      ('O que é generalização em aprendizado de máquina?', 'Capacidade de armazenar mais arquivos', FALSE, 1),
      ('O que é generalização em aprendizado de máquina?', 'Capacidade de aumentar a memória física', FALSE, 2),
      ('O que é generalização em aprendizado de máquina?', 'Capacidade de um modelo apresentar bom desempenho em dados novos e não apenas nos exemplos de treinamento', TRUE, 3),
      ('O que é classificação em aprendizado de máquina?', 'Conversão de moedas', FALSE, 0),
      ('O que é classificação em aprendizado de máquina?', 'Criação de documentos', FALSE, 1),
      ('O que é classificação em aprendizado de máquina?', 'Tarefa de atribuir entradas a categorias ou classes', TRUE, 2),
      ('O que é classificação em aprendizado de máquina?', 'Organização de arquivos por tamanho', FALSE, 3),
      ('Qual é um exemplo de classificação?', 'Determinar se uma mensagem é spam ou não spam', TRUE, 0),
      ('Qual é um exemplo de classificação?', 'Aumentar o volume de um áudio', FALSE, 1),
      ('Qual é um exemplo de classificação?', 'Alterar o brilho do monitor', FALSE, 2),
      ('Qual é um exemplo de classificação?', 'Copiar um arquivo', FALSE, 3),
      ('O que é regressão em aprendizado de máquina?', 'Criação de senhas', FALSE, 0),
      ('O que é regressão em aprendizado de máquina?', 'Tarefa de prever um valor numérico contínuo', TRUE, 1),
      ('O que é regressão em aprendizado de máquina?', 'Classificação de imagens exclusivamente', FALSE, 2),
      ('O que é regressão em aprendizado de máquina?', 'Organização de documentos', FALSE, 3),
      ('Qual pode ser um exemplo de regressão?', 'Identificar se uma imagem contém um gato', FALSE, 0),
      ('Qual pode ser um exemplo de regressão?', 'Prever o preço de um imóvel com base em características', TRUE, 1),
      ('Qual pode ser um exemplo de regressão?', 'Classificar emails como spam', FALSE, 2),
      ('Qual pode ser um exemplo de regressão?', 'Separar arquivos por extensão', FALSE, 3),
      ('O que é processamento de linguagem natural?', 'Área da IA dedicada ao processamento e compreensão de linguagem humana por computadores', TRUE, 0),
      ('O que é processamento de linguagem natural?', 'Tecnologia de carregamento', FALSE, 1),
      ('O que é processamento de linguagem natural?', 'Sistema para controlar impressoras', FALSE, 2),
      ('O que é processamento de linguagem natural?', 'Sistema bancário', FALSE, 3),
      ('O que é análise de sentimento?', 'Cálculo de salários', FALSE, 0),
      ('O que é análise de sentimento?', 'Medição da temperatura', FALSE, 1),
      ('O que é análise de sentimento?', 'Análise de velocidade da internet', FALSE, 2),
      ('O que é análise de sentimento?', 'Técnica usada para identificar ou estimar sentimentos ou opiniões expressos em textos', TRUE, 3),
      ('O que é um dataset?', 'Um aplicativo de mensagens', FALSE, 0),
      ('O que é um dataset?', 'Conjunto organizado de dados utilizado para análise, treinamento ou avaliação', TRUE, 1),
      ('O que é um dataset?', 'Um dispositivo físico', FALSE, 2),
      ('O que é um dataset?', 'Uma senha', FALSE, 3),
      ('O que é um rótulo em aprendizado supervisionado?', 'Informação que indica a resposta ou categoria associada a um exemplo de treinamento', TRUE, 0),
      ('O que é um rótulo em aprendizado supervisionado?', 'Número de série do monitor', FALSE, 1),
      ('O que é um rótulo em aprendizado supervisionado?', 'Nome do computador', FALSE, 2),
      ('O que é um rótulo em aprendizado supervisionado?', 'Senha do usuário', FALSE, 3),
      ('O que caracteriza o aprendizado supervisionado?', 'O modelo nunca recebe dados', FALSE, 0),
      ('O que caracteriza o aprendizado supervisionado?', 'O modelo aprende utilizando exemplos que possuem respostas ou rótulos conhecidos', TRUE, 1),
      ('O que caracteriza o aprendizado supervisionado?', 'O modelo depende exclusivamente de intervenção humana em cada previsão', FALSE, 2),
      ('O que caracteriza o aprendizado supervisionado?', 'O sistema funciona apenas sem algoritmos', FALSE, 3),
      ('O que caracteriza o aprendizado não supervisionado?', 'O sistema procura padrões ou estruturas em dados sem depender de rótulos fornecidos para cada exemplo', TRUE, 0),
      ('O que caracteriza o aprendizado não supervisionado?', 'O modelo apenas copia textos', FALSE, 1),
      ('O que caracteriza o aprendizado não supervisionado?', 'Não existem dados', FALSE, 2),
      ('O que caracteriza o aprendizado não supervisionado?', 'Todos os dados possuem respostas previamente indicadas', FALSE, 3),
      ('O que é agrupamento, ou clustering?', 'Técnica que organiza dados em grupos com base em semelhanças', TRUE, 0),
      ('O que é agrupamento, ou clustering?', 'Sistema de pagamentos', FALSE, 1),
      ('O que é agrupamento, ou clustering?', 'Técnica de criptografia', FALSE, 2),
      ('O que é agrupamento, ou clustering?', 'Método de edição de vídeo', FALSE, 3),
      ('O que é viés em um sistema de IA?', 'Criação automática de senhas', FALSE, 0),
      ('O que é viés em um sistema de IA?', 'Redução do tamanho do arquivo', FALSE, 1),
      ('O que é viés em um sistema de IA?', 'Aumento da velocidade do computador', FALSE, 2),
      ('O que é viés em um sistema de IA?', 'Tendência sistemática que pode levar o sistema a produzir resultados inadequados ou desiguais', TRUE, 3),
      ('Por que a qualidade dos dados é importante?', 'Porque elimina a necessidade de testes', FALSE, 0),
      ('Por que a qualidade dos dados é importante?', 'Porque qualquer dado produz o mesmo resultado', FALSE, 1),
      ('Por que a qualidade dos dados é importante?', 'Porque dados nunca influenciam modelos', FALSE, 2),
      ('Por que a qualidade dos dados é importante?', 'Dados inadequados podem prejudicar o treinamento e o desempenho do modelo', TRUE, 3),
      ('O que é limpeza de dados?', 'Criação de imagens', FALSE, 0),
      ('O que é limpeza de dados?', 'Exclusão de todos os dados', FALSE, 1),
      ('O que é limpeza de dados?', 'Processo de identificar e corrigir ou tratar problemas como erros, duplicações ou valores ausentes', TRUE, 2),
      ('O que é limpeza de dados?', 'Formatação de um computador', FALSE, 3),
      ('O que é engenharia de prompt?', 'Reparação de servidores', FALSE, 0),
      ('O que é engenharia de prompt?', 'Criação de redes elétricas', FALSE, 1),
      ('O que é engenharia de prompt?', 'Processo de estruturar instruções para orientar um modelo de IA a produzir uma resposta mais adequada', TRUE, 2),
      ('O que é engenharia de prompt?', 'Construção física de computadores', FALSE, 3),
      ('Qual característica tende a melhorar um prompt?', 'Instruções claras, contexto relevante e objetivo bem definido', TRUE, 0),
      ('Qual característica tende a melhorar um prompt?', 'Pedido extremamente ambíguo', FALSE, 1),
      ('Qual característica tende a melhorar um prompt?', 'Ausência total de contexto', FALSE, 2),
      ('Qual característica tende a melhorar um prompt?', 'Informações contraditórias', FALSE, 3),
      ('O que significa alucinação em IA generativa?', 'Desligamento do computador', FALSE, 0),
      ('O que significa alucinação em IA generativa?', 'Geração de informação que parece plausível, mas é incorreta, inventada ou não fundamentada', TRUE, 1),
      ('O que significa alucinação em IA generativa?', 'Falha elétrica', FALSE, 2),
      ('O que significa alucinação em IA generativa?', 'Falha da internet', FALSE, 3),
      ('Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 'Pedir sempre uma resposta mais longa', FALSE, 0),
      ('Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 'Aceitar automaticamente toda resposta', FALSE, 1),
      ('Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 'Ignorar qualquer fonte externa', FALSE, 2),
      ('Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 'Verificar a informação em fontes confiáveis quando a precisão for importante', TRUE, 3),
      ('O que é multimodalidade em IA?', 'Capacidade de funcionar sem dados', FALSE, 0),
      ('O que é multimodalidade em IA?', 'Capacidade de usar apenas texto', FALSE, 1),
      ('O que é multimodalidade em IA?', 'Capacidade de trabalhar com diferentes tipos de informação, como texto, imagem, áudio ou vídeo', TRUE, 2),
      ('O que é multimodalidade em IA?', 'Capacidade de desligar o computador', FALSE, 3),
      ('O que é geração de código por IA?', 'Uso de modelos de IA para produzir ou auxiliar na produção de código de programação', TRUE, 0),
      ('O que é geração de código por IA?', 'Impressão de circuitos', FALSE, 1),
      ('O que é geração de código por IA?', 'Instalação de internet', FALSE, 2),
      ('O que é geração de código por IA?', 'Criação de hardware automaticamente', FALSE, 3),
      ('Por que código gerado por IA deve ser revisado?', 'Porque código gerado por IA nunca funciona', FALSE, 0),
      ('Por que código gerado por IA deve ser revisado?', 'Porque nenhum código pode ser testado', FALSE, 1),
      ('Por que código gerado por IA deve ser revisado?', 'Pode conter erros, vulnerabilidades ou lógica inadequada', TRUE, 2),
      ('Por que código gerado por IA deve ser revisado?', 'Porque IA não conhece programação', FALSE, 3),
      ('O que é automação inteligente?', 'Automação sem qualquer software', FALSE, 0),
      ('O que é automação inteligente?', 'Combinação de automação com técnicas de IA para lidar com determinadas tarefas ou decisões', TRUE, 1),
      ('O que é automação inteligente?', 'Trabalho exclusivamente manual', FALSE, 2),
      ('O que é automação inteligente?', 'Uso de computadores apenas para jogos', FALSE, 3),
      ('O que é um modelo de linguagem?', 'Dicionário impresso', FALSE, 0),
      ('O que é um modelo de linguagem?', 'Modelo treinado para processar ou gerar linguagem com base em padrões aprendidos', TRUE, 1),
      ('O que é um modelo de linguagem?', 'Sistema operacional', FALSE, 2),
      ('O que é um modelo de linguagem?', 'Tradutor humano', FALSE, 3),
      ('O que é contexto em uma conversa com IA?', 'Apenas o nome do usuário', FALSE, 0),
      ('O que é contexto em uma conversa com IA?', 'O tamanho do monitor', FALSE, 1),
      ('O que é contexto em uma conversa com IA?', 'A velocidade da internet', FALSE, 2),
      ('O que é contexto em uma conversa com IA?', 'Informações relevantes fornecidas para ajudar o modelo a interpretar corretamente uma solicitação', TRUE, 3),
      ('Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 'Porque substitui a verificação humana', FALSE, 0),
      ('Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 'Ajuda o modelo a compreender melhor o objetivo, as restrições e a situação', TRUE, 1),
      ('Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 'Porque elimina todos os erros', FALSE, 2),
      ('Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 'Porque aumenta automaticamente a velocidade da internet', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_medio;

    RAISE NOTICE '30 perguntas inseridas com sucesso (source=seed_ia_medio_v1).';
  END IF;
END $$;

COMMIT;
