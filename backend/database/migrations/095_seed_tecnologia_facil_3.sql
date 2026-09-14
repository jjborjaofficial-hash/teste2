-- Migration/seed: repõe 3 perguntas de Tecnologia/Fácil removidas pela
-- migration 031 (limpeza de duplicatas entre 003 e 005), trazendo a
-- categoria de volta a 100 perguntas neste nível.
--
-- Perguntas GERADAS por mim (Claude) a pedido do proprietário do projeto,
-- não transcritas de um documento. Temas escolhidos por NÃO aparecerem em
-- nenhuma das 97 perguntas já existentes (checado programaticamente, zero
-- duplicata): tela sensível ao toque, webcam, modo escuro.
--
-- Seed de embaralhamento: 103 (a mais alta já usada no projeto era 102).
-- Idempotente: usa a coluna `source` como marcador — rodar de novo não duplica.
--
-- REVISÃO RECOMENDADA: mesmo cuidado do lote seed_ia_dificil_v1 — conteúdo
-- redigido por IA, não fornecido/revisado pelo proprietário antes da gravação.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'tecnologia';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "tecnologia" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_facil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_tecnologia_facil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_facil3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_tecnologia_facil_v3'
    FROM (VALUES
      ('O que é uma tela sensível ao toque (touchscreen)?'),
      ('Para que serve uma webcam?'),
      ('O que é o "modo escuro" (dark mode) em aplicativos?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_facil3 q
    JOIN (VALUES
      ('O que é uma tela sensível ao toque (touchscreen)?', 'Tela que permite controlar o dispositivo tocando diretamente com os dedos', TRUE, 0),
      ('O que é uma tela sensível ao toque (touchscreen)?', 'Tipo de tela usada apenas em computadores antigos', FALSE, 1),
      ('O que é uma tela sensível ao toque (touchscreen)?', 'Tela que só funciona com um teclado externo conectado', FALSE, 2),
      ('O que é uma tela sensível ao toque (touchscreen)?', 'Acessório separado que precisa ser comprado à parte do celular', FALSE, 3),
      ('Para que serve uma webcam?', 'Guardar arquivos baixados da internet', FALSE, 0),
      ('Para que serve uma webcam?', 'Capturar imagens e vídeo, permitindo chamadas de vídeo e gravações', TRUE, 1),
      ('Para que serve uma webcam?', 'Aumentar a velocidade da internet', FALSE, 2),
      ('Para que serve uma webcam?', 'Proteger o computador contra vírus', FALSE, 3),
      ('O que é o "modo escuro" (dark mode) em aplicativos?', 'Modo que bloqueia o acesso à internet', FALSE, 0),
      ('O que é o "modo escuro" (dark mode) em aplicativos?', 'Função que desliga o aplicativo automaticamente à noite', FALSE, 1),
      ('O que é o "modo escuro" (dark mode) em aplicativos?', 'Opção de aparência com fundo escuro, usada para conforto visual e economia de bateria em algumas telas', TRUE, 2),
      ('O que é o "modo escuro" (dark mode) em aplicativos?', 'Recurso que apaga todos os dados do aplicativo', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_facil3;

    RAISE NOTICE '3 perguntas inseridas com sucesso (source=seed_tecnologia_facil_v3).';
  END IF;
END $$;

COMMIT;
