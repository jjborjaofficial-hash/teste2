-- Migration/seed: conteúdo Inteligência Artificial, nível Fácil — lote 4 (9 de 13 perguntas)
-- Fonte: "ARQUIVO 049" fornecido pelo proprietário do projeto (13 perguntas).
--
-- DEDUPLICAÇÃO APLICADA: comparei texto a texto contra as 1267 perguntas já
-- existentes no banco e encontrei 4 repetidas, removidas deste arquivo:
--   - "O que é inteligência artificial?"
--   - "O que é visão computacional?"
--   - "O que caracteriza uma IA generativa?"
--   - "O que é um chatbot?"
-- Sobraram 9 perguntas novas e únicas.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores): este lote já vem com respostas parcialmente variadas (10 A,
-- 3 B). Para manter consistência com o resto do banco, a posição da
-- alternativa correta (preservando o texto correto do documento original)
-- foi redistribuída por pergunta com seed fixa (87 — distinta das seeds 42
-- a 86 já usadas) e distribuição controlada entre A/B/C/D. Conteúdo
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_facil_v4') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_facil_v4) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_facil_v4 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_ia_facil_v4'
    FROM (VALUES
      ('Qual destes é um exemplo comum de inteligência artificial no dia a dia?'),
      ('Para que serve o reconhecimento de voz?'),
      ('Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?'),
      ('O que pode fazer um sistema de recomendação?'),
      ('Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:'),
      ('Qual destas tarefas pode ser realizada por uma IA generativa?'),
      ('Por que os dados são importantes para muitos sistemas de inteligência artificial?'),
      ('Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?'),
      ('Qual é uma limitação importante dos sistemas de IA?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_facil_v4 q
    JOIN (VALUES
      ('Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 'Um cabo USB', FALSE, 0),
      ('Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 'Uma tomada elétrica', FALSE, 1),
      ('Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 'Um assistente virtual que interpreta comandos de voz', TRUE, 2),
      ('Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 'Uma calculadora simples', FALSE, 3),
      ('Para que serve o reconhecimento de voz?', 'Criar automaticamente componentes físicos', FALSE, 0),
      ('Para que serve o reconhecimento de voz?', 'Aumentar a capacidade da bateria', FALSE, 1),
      ('Para que serve o reconhecimento de voz?', 'Melhorar a velocidade da internet', FALSE, 2),
      ('Para que serve o reconhecimento de voz?', 'Transformar comandos falados em informação que um sistema pode processar', TRUE, 3),
      ('Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?', 'Visão computacional', TRUE, 0),
      ('Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?', 'Processamento de texto', FALSE, 1),
      ('Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?', 'Sistema de arquivos', FALSE, 2),
      ('Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?', 'Compactação de arquivos', FALSE, 3),
      ('O que pode fazer um sistema de recomendação?', 'Substituir uma ligação à internet', FALSE, 0),
      ('O que pode fazer um sistema de recomendação?', 'Aumentar a memória RAM', FALSE, 1),
      ('O que pode fazer um sistema de recomendação?', 'Reparar fisicamente um computador', FALSE, 2),
      ('O que pode fazer um sistema de recomendação?', 'Sugerir conteúdos ou produtos com base em informações e comportamentos disponíveis', TRUE, 3),
      ('Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 'Sistema de recomendação', TRUE, 0),
      ('Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 'Editor de código', FALSE, 1),
      ('Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 'Sistema de impressão', FALSE, 2),
      ('Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 'Firewall', FALSE, 3),
      ('Qual destas tarefas pode ser realizada por uma IA generativa?', 'Reparar uma tela quebrada', FALSE, 0),
      ('Qual destas tarefas pode ser realizada por uma IA generativa?', 'Criar um texto a partir de uma instrução', TRUE, 1),
      ('Qual destas tarefas pode ser realizada por uma IA generativa?', 'Trocar fisicamente uma bateria', FALSE, 2),
      ('Qual destas tarefas pode ser realizada por uma IA generativa?', 'Instalar uma placa de vídeo manualmente', FALSE, 3),
      ('Por que os dados são importantes para muitos sistemas de inteligência artificial?', 'Substituem automaticamente o hardware', FALSE, 0),
      ('Por que os dados são importantes para muitos sistemas de inteligência artificial?', 'Servem apenas para ocupar espaço no armazenamento', FALSE, 1),
      ('Por que os dados são importantes para muitos sistemas de inteligência artificial?', 'Podem fornecer exemplos e informações usados para identificar padrões e melhorar modelos', TRUE, 2),
      ('Por que os dados são importantes para muitos sistemas de inteligência artificial?', 'Impedem qualquer tipo de aprendizagem', FALSE, 3),
      ('Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 'Compartilhar todas as informações pessoais', FALSE, 0),
      ('Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 'Verificar informações relevantes antes de utilizá-las', TRUE, 1),
      ('Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 'Aceitar todas as respostas sem questionar', FALSE, 2),
      ('Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 'Ignorar possíveis erros', FALSE, 3),
      ('Qual é uma limitação importante dos sistemas de IA?', 'Podem produzir resultados incorretos ou inadequados', TRUE, 0),
      ('Qual é uma limitação importante dos sistemas de IA?', 'Funcionam apenas em computadores antigos', FALSE, 1),
      ('Qual é uma limitação importante dos sistemas de IA?', 'Nunca conseguem processar textos', FALSE, 2),
      ('Qual é uma limitação importante dos sistemas de IA?', 'Não podem utilizar dados', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_facil_v4;

    RAISE NOTICE '9 perguntas inseridas com sucesso (source=seed_ia_facil_v4).';
  END IF;
END $$;

COMMIT;
