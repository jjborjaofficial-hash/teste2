-- Migration 031: remove perguntas duplicadas no banco de conteúdo.
--
-- Contexto: auditoria cruzada entre os 62 arquivos de seed encontrou 3
-- perguntas de Tecnologia/Fácil duplicadas (texto idêntico) entre
-- `003_tecnologia_facil.sql` e `005_tecnologia_facil_2.sql` — o segundo
-- lote não foi comparado contra o primeiro antes de ser gravado:
--   "O que é um aplicativo?"
--   "O que é uma pasta no computador?"
--   "O que é uma chamada de vídeo?"
--
-- Em vez de uma migration que remove só essas 3 linhas nominalmente, esta
-- migration faz uma varredura real no banco (fonte da verdade, não nos
-- arquivos .sql) por QUALQUER duplicata de texto dentro da mesma
-- categoria+dificuldade — cobre essas 3 e qualquer outra que a auditoria
-- baseada em arquivo não tenha capturado (ex.: por diferença de espaço ou
-- maiúscula/minúscula).
--
-- Segurança: mantém sempre a cópia mais antiga (created_at) de cada
-- duplicata. Se algum usuário já tiver respondido a cópia mais nova
-- (existe linha em quiz_attempts referenciando aquele id), a remoção
-- daquela linha específica é PULADA — quiz_attempts.question_id é
-- ON DELETE RESTRICT de propósito (Seção 11 do Doc. Mestre: livro-razão/
-- histórico não pode perder integridade referencial). As alternativas
-- (question_alternatives) são removidas automaticamente via CASCADE.

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

  RAISE NOTICE 'Limpeza de duplicatas concluída: % removida(s), % pulada(s) por já ter resposta de usuário.', removed_count, skipped_count;
END $$;

COMMIT;
