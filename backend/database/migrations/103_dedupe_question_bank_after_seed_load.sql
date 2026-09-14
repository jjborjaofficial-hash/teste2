-- Migration 103: reaplica a limpeza de duplicatas (mesma lógica da
-- migration 031) depois de carregado todo o banco de perguntas real
-- (migrations 033-102, convertidas de backend/database/seeds/, que a
-- migration 031 original não podia ter visto — ela rodou antes desse
-- conteúdo existir na base de dados de produção).
--
-- Sem isto, qualquer duplicata de texto entre os 70 arquivos de seed
-- (introduzida ao longo de várias rodadas de consolidação de conteúdo —
-- ver CHANGELOG_rodada*.md na raiz do projeto) ficaria sem limpeza em
-- produção, mesmo já existindo uma migration pronta para essa limpeza.
--
-- Idêntica à 031_remove_duplicate_questions.sql — não altera o
-- comportamento (mesma regra: mantém a cópia mais antiga; nunca remove
-- pergunta já respondida por algum usuário em quiz_attempts).

BEGIN;

DO $$
DECLARE
  r RECORD;
  dup_id UUID;
  keep_id UUID;
  removed_count INT := 0;
  skipped_count INT := 0;
BEGIN
  FOR r IN
    SELECT
      category_id,
      difficulty,
      lower(trim(regexp_replace(statement, '\s+', ' ', 'g'))) AS norm_statement,
      array_agg(id ORDER BY created_at ASC) AS ids
    FROM questions
    GROUP BY category_id, difficulty, lower(trim(regexp_replace(statement, '\s+', ' ', 'g')))
    HAVING count(*) > 1
  LOOP
    keep_id := r.ids[1]; -- cópia mais antiga sempre fica

    FOR i IN 2 .. array_length(r.ids, 1) LOOP
      dup_id := r.ids[i];

      IF EXISTS (SELECT 1 FROM quiz_attempts WHERE question_id = dup_id) THEN
        RAISE NOTICE 'Pulando remoção da pergunta % — já possui resposta registrada em quiz_attempts.', dup_id;
        skipped_count := skipped_count + 1;
      ELSE
        DELETE FROM questions WHERE id = dup_id;
        removed_count := removed_count + 1;
      END IF;
    END LOOP;
  END LOOP;

  RAISE NOTICE 'Limpeza de duplicatas (pós-carga do banco de perguntas) concluída: % removida(s), % pulada(s) por já ter resposta de usuário.', removed_count, skipped_count;
END $$;

COMMIT;
