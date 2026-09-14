-- Migration/seed: conteúdo Inteligência Artificial, nível Fácil (25 perguntas)
-- Fonte: lote de 80 perguntas de Inteligência Artificial fornecido pelo
-- proprietário do projeto (perguntas 1–25 do lote, marcadas como "Fácil").
-- O documento recebido está incompleto: a pergunta 77 (nível Difícil) foi
-- cortada a meio e as perguntas 78–80 não foram recebidas. Por isso, apenas os
-- níveis Fácil e Médio deste lote foram inseridos aqui e em
-- 011_inteligencia_artificial_medio.sql; o nível Difícil (perguntas 56–80)
-- fica pendente até o restante do documento ser enviado.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): no lote original, as respostas corretas eram
-- TODAS a alternativa "A" — decorável sem conhecimento real. A posição da
-- alternativa correta foi redistribuída por pergunta com seed fixa (49 —
-- distinta das seeds 42 a 48 já usadas) e distribuição controlada entre
-- A/B/C/D, reprodutível — o conteúdo pedagógico permanece exatamente como
-- enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Inteligência Artificial" (slug: inteligencia-artificial) já
-- existe desde a migration 021 — esta é a primeira leva de perguntas para ela.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.
--
-- CORREÇÃO DE DUPLICATA CRUZADA (rodada de consolidação): 2 perguntas
-- deste arquivo tinham o MESMO enunciado de perguntas já existentes em
-- outras categorias — "O que é Inteligência Artificial?" (já em
-- 003_tecnologia_facil.sql) e "O que é visão computacional?" (já em
-- 006_tecnologia_dificil.sql). Removidas daqui.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_facil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v1'
    FROM (VALUES
      ('O que significa IA?'),
      ('O que é um chatbot?'),
      ('Para que pode ser usada uma IA generativa?'),
      ('O que é um comando ou prompt para uma IA?'),
      ('O que é reconhecimento de voz?'),
      ('Qual destas é uma aplicação comum de IA?'),
      ('O que é reconhecimento facial?'),
      ('O que é automação?'),
      ('Qual é uma vantagem potencial da automação?'),
      ('O que é um algoritmo?'),
      ('O que é um dado?'),
      ('Por que os dados são importantes para muitos sistemas de IA?'),
      ('O que é uma imagem gerada por IA?'),
      ('O que é tradução automática?'),
      ('O que é recomendação baseada em IA?'),
      ('Onde podemos encontrar sistemas de recomendação?'),
      ('O que é aprendizado de máquina?'),
      ('O que é um modelo de IA?'),
      ('A IA consegue sempre fornecer respostas corretas?'),
      ('Por que devemos verificar informações produzidas por IA?'),
      ('O que é um assistente virtual?'),
      ('O que é geração de texto por IA?'),
      ('O que significa ética em IA?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_facil q
    JOIN (VALUES
      ('O que significa IA?', 'Informação Avançada', FALSE, 0),
      ('O que significa IA?', 'Integração Artificial', FALSE, 1),
      ('O que significa IA?', 'Internet Automática', FALSE, 2),
      ('O que significa IA?', 'Inteligência Artificial', TRUE, 3),
      ('O que é um chatbot?', 'Um dispositivo para carregar telemóveis', FALSE, 0),
      ('O que é um chatbot?', 'Um tipo de banco', FALSE, 1),
      ('O que é um chatbot?', 'Sistema capaz de conversar com usuários por meio de texto ou voz', TRUE, 2),
      ('O que é um chatbot?', 'Um antivírus físico', FALSE, 3),
      ('Para que pode ser usada uma IA generativa?', 'Para criar conteúdos como textos, imagens, áudio ou código', TRUE, 0),
      ('Para que pode ser usada uma IA generativa?', 'Apenas para fazer chamadas telefónicas', FALSE, 1),
      ('Para que pode ser usada uma IA generativa?', 'Apenas para calcular impostos', FALSE, 2),
      ('Para que pode ser usada uma IA generativa?', 'Somente para armazenar arquivos', FALSE, 3),
      ('O que é um comando ou prompt para uma IA?', 'Uma senha bancária', FALSE, 0),
      ('O que é um comando ou prompt para uma IA?', 'Um cabo USB', FALSE, 1),
      ('O que é um comando ou prompt para uma IA?', 'Instrução ou solicitação fornecida ao sistema', TRUE, 2),
      ('O que é um comando ou prompt para uma IA?', 'Um tipo de vírus', FALSE, 3),
      ('O que é reconhecimento de voz?', 'Tecnologia capaz de transformar ou interpretar fala humana em informação processável', TRUE, 0),
      ('O que é reconhecimento de voz?', 'Um sistema de pagamento', FALSE, 1),
      ('O que é reconhecimento de voz?', 'Tecnologia para aumentar o volume de um aparelho', FALSE, 2),
      ('O que é reconhecimento de voz?', 'Um editor de fotografias', FALSE, 3),
      ('Qual destas é uma aplicação comum de IA?', 'Assistentes virtuais', TRUE, 0),
      ('Qual destas é uma aplicação comum de IA?', 'Cadernos de papel', FALSE, 1),
      ('Qual destas é uma aplicação comum de IA?', 'Mesas de madeira', FALSE, 2),
      ('Qual destas é uma aplicação comum de IA?', 'Canetas', FALSE, 3),
      ('O que é reconhecimento facial?', 'Ferramenta para aumentar o brilho do ecrã', FALSE, 0),
      ('O que é reconhecimento facial?', 'Sistema para reconhecer documentos financeiros', FALSE, 1),
      ('O que é reconhecimento facial?', 'Programa para editar planilhas', FALSE, 2),
      ('O que é reconhecimento facial?', 'Tecnologia que analisa características de rostos em imagens ou vídeos', TRUE, 3),
      ('O que é automação?', 'Desligar computadores', FALSE, 0),
      ('O que é automação?', 'Uso de sistemas para executar tarefas com pouca ou nenhuma intervenção humana direta', TRUE, 1),
      ('O que é automação?', 'Fazer todas as tarefas manualmente', FALSE, 2),
      ('O que é automação?', 'Apagar dados', FALSE, 3),
      ('Qual é uma vantagem potencial da automação?', 'Eliminar todos os empregos automaticamente', FALSE, 0),
      ('Qual é uma vantagem potencial da automação?', 'Garantir que nunca haverá erros', FALSE, 1),
      ('Qual é uma vantagem potencial da automação?', 'Reduzir tarefas repetitivas', TRUE, 2),
      ('Qual é uma vantagem potencial da automação?', 'Impedir o uso de computadores', FALSE, 3),
      ('O que é um algoritmo?', 'Um tipo de monitor', FALSE, 0),
      ('O que é um algoritmo?', 'Uma rede social', FALSE, 1),
      ('O que é um algoritmo?', 'Um banco de dados físico', FALSE, 2),
      ('O que é um algoritmo?', 'Conjunto de instruções ou etapas utilizadas para resolver um problema ou realizar uma tarefa', TRUE, 3),
      ('O que é um dado?', 'Informação que pode ser armazenada ou processada', TRUE, 0),
      ('O que é um dado?', 'Apenas uma senha', FALSE, 1),
      ('O que é um dado?', 'Apenas um número', FALSE, 2),
      ('O que é um dado?', 'Apenas uma imagem', FALSE, 3),
      ('Por que os dados são importantes para muitos sistemas de IA?', 'Porque tornam qualquer sistema infalível', FALSE, 0),
      ('Por que os dados são importantes para muitos sistemas de IA?', 'Porque eliminam algoritmos', FALSE, 1),
      ('Por que os dados são importantes para muitos sistemas de IA?', 'Porque substituem eletricidade', FALSE, 2),
      ('Por que os dados são importantes para muitos sistemas de IA?', 'Podem ser usados para treinar, avaliar ou alimentar modelos', TRUE, 3),
      ('O que é uma imagem gerada por IA?', 'Fotografia obrigatoriamente tirada por uma câmara', FALSE, 0),
      ('O que é uma imagem gerada por IA?', 'Imagem criada ou sintetizada por um sistema de inteligência artificial', TRUE, 1),
      ('O que é uma imagem gerada por IA?', 'Captura de ecrã sem alterações', FALSE, 2),
      ('O que é uma imagem gerada por IA?', 'Documento bancário', FALSE, 3),
      ('O que é tradução automática?', 'Conversão de moedas', FALSE, 0),
      ('O que é tradução automática?', 'Compressão de arquivos', FALSE, 1),
      ('O que é tradução automática?', 'Criação de senhas', FALSE, 2),
      ('O que é tradução automática?', 'Uso de sistemas computacionais para converter conteúdo de uma língua para outra', TRUE, 3),
      ('O que é recomendação baseada em IA?', 'Uma ordem obrigatória', FALSE, 0),
      ('O que é recomendação baseada em IA?', 'Sugestão de conteúdos, produtos ou ações com base em dados e padrões', TRUE, 1),
      ('O que é recomendação baseada em IA?', 'Um pagamento automático', FALSE, 2),
      ('O que é recomendação baseada em IA?', 'Um tipo de vírus', FALSE, 3),
      ('Onde podemos encontrar sistemas de recomendação?', 'Apenas em calculadoras', FALSE, 0),
      ('Onde podemos encontrar sistemas de recomendação?', 'Apenas em impressoras', FALSE, 1),
      ('Onde podemos encontrar sistemas de recomendação?', 'Apenas em relógios', FALSE, 2),
      ('Onde podemos encontrar sistemas de recomendação?', 'Plataformas de vídeos, música, compras e outros serviços digitais', TRUE, 3),
      ('O que é aprendizado de máquina?', 'Um curso de programação', FALSE, 0),
      ('O que é aprendizado de máquina?', 'Aprendizagem exclusivamente feita por livros', FALSE, 1),
      ('O que é aprendizado de máquina?', 'Método em que sistemas aprendem padrões a partir de dados para realizar determinadas tarefas', TRUE, 2),
      ('O que é aprendizado de máquina?', 'Um sistema operacional', FALSE, 3),
      ('O que é um modelo de IA?', 'Uma fotografia', FALSE, 0),
      ('O que é um modelo de IA?', 'Um documento fiscal', FALSE, 1),
      ('O que é um modelo de IA?', 'Sistema matemático ou computacional treinado ou configurado para realizar determinadas tarefas', TRUE, 2),
      ('O que é um modelo de IA?', 'Um modelo de roupa', FALSE, 3),
      ('A IA consegue sempre fornecer respostas corretas?', 'Apenas durante o dia', FALSE, 0),
      ('A IA consegue sempre fornecer respostas corretas?', 'Não', TRUE, 1),
      ('A IA consegue sempre fornecer respostas corretas?', 'Apenas quando está conectada à internet', FALSE, 2),
      ('A IA consegue sempre fornecer respostas corretas?', 'Sim, sem exceção', FALSE, 3),
      ('Por que devemos verificar informações produzidas por IA?', 'Porque sistemas de IA podem cometer erros ou gerar informações incorretas', TRUE, 0),
      ('Por que devemos verificar informações produzidas por IA?', 'Porque IA nunca processa dados', FALSE, 1),
      ('Por que devemos verificar informações produzidas por IA?', 'Porque a verificação é impossível', FALSE, 2),
      ('Por que devemos verificar informações produzidas por IA?', 'Porque toda IA é sempre falsa', FALSE, 3),
      ('O que é um assistente virtual?', 'Um trabalhador contratado fisicamente', FALSE, 0),
      ('O que é um assistente virtual?', 'Um computador sem software', FALSE, 1),
      ('O que é um assistente virtual?', 'Sistema digital que pode ajudar o usuário a realizar determinadas tarefas por meio de comandos', TRUE, 2),
      ('O que é um assistente virtual?', 'Um dispositivo exclusivamente de armazenamento', FALSE, 3),
      ('O que é geração de texto por IA?', 'Digitalização de papel', FALSE, 0),
      ('O que é geração de texto por IA?', 'Produção automática de texto a partir de instruções ou dados fornecidos ao sistema', TRUE, 1),
      ('O que é geração de texto por IA?', 'Impressão de documentos', FALSE, 2),
      ('O que é geração de texto por IA?', 'Conversão de texto em moeda', FALSE, 3),
      ('O que significa ética em IA?', 'Princípios usados para orientar o desenvolvimento e uso responsável de sistemas de IA', TRUE, 0),
      ('O que significa ética em IA?', 'Apenas programação', FALSE, 1),
      ('O que significa ética em IA?', 'Apenas segurança física', FALSE, 2),
      ('O que significa ética em IA?', 'Apenas marketing', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_facil;

    RAISE NOTICE '23 perguntas inseridas com sucesso (source=seed_ia_facil_v1).';
  END IF;
END $$;

COMMIT;
