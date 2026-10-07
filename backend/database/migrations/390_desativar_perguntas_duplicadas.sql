-- BE-003 (P10) — Regularização das perguntas duplicadas: desativa UMA de cada par (esperado: 18).
-- Origem: `npm run quiz:audit` encontrou 18 pares de enunciados quase iguais (docs/quiz-duplicadas-para-revisao.md);
-- o dono aprovou regularizar. Nada é apagado: só `is_active = false`, reversível, e as respostas já dadas ficam ligadas.
-- Regra de escolha (a mesma para todos): mantém-se a versão cujas alternativas denunciam menos a correta (menor razão
-- correta/média das erradas no validador), calculada com os lotes de correção até à migration 311 já aplicados, por isso
-- as versões já corrigidas ganham; em empate, a redação com artigo ("um/uma"). A lista completa (desativa → mantém) está
-- na tabela abaixo.
-- Segurança: casa por categoria + dificuldade + ENUNCIADO (os ids mudam entre bancos) e só desativa se a versão a manter
-- existir e estiver ativa, para nunca desativar as duas. Se algo não casar, é ignorado (nunca falha, para não impedir o
-- arranque do backend: as migrations correm no deploy). Idempotente. O runner já envolve o ficheiro numa transação.
-- Para reverter um par: UPDATE questions SET is_active = true WHERE statement = '<enunciado desativado>' AND difficulty = '<dificuldade>';

DO $$
DECLARE
  r RECORD;
  v_n INTEGER;
  v_total INTEGER := 0;
BEGIN
  FOR r IN
    SELECT * FROM (VALUES
    ('Finanças', 'easy', 'O que é despesa?', 'Finanças', 'easy', 'O que é uma despesa?'),
    ('Finanças', 'easy', 'O que é dívida?', 'Finanças', 'easy', 'O que é uma dívida?'),
    ('Finanças', 'easy', 'O que é uma conta de poupança?', 'Finanças', 'easy', 'O que é uma conta poupança?'),
    ('Inteligência Artificial', 'hard', 'O que é dataset?', 'Inteligência Artificial', 'medium', 'O que é um dataset?'),
    ('Inteligência Artificial', 'easy', 'O que é um algoritmo?', 'Tecnologia', 'medium', 'O que é algoritmo?'),
    ('Inteligência Artificial', 'medium', 'O que é viés em um sistema de IA?', 'Inteligência Artificial', 'easy', 'O que é um viés em um sistema de IA?'),
    ('Marketing Digital', 'easy', 'O que é hashtag?', 'Marketing Digital', 'easy', 'O que é uma hashtag?'),
    ('Marketing Digital', 'medium', 'O que é lead?', 'Marketing Digital', 'easy', 'O que é um lead?'),
    ('Marketing Digital', 'medium', 'O que é persona?', 'Marketing Digital', 'easy', 'O que é uma persona?'),
    ('Marketing Digital', 'easy', 'O que é seguidor?', 'Marketing Digital', 'easy', 'O que é um seguidor?'),
    ('Marketing Digital', 'hard', 'Por que atribuição pode ser complexa?', 'Marketing Digital', 'hard', 'Por que a atribuição pode ser complexa?'),
    ('Produtividade', 'medium', 'O que é margem de tempo no planejamento?', 'Produtividade', 'medium', 'O que é margem de tempo em um planejamento?'),
    ('Produtividade', 'easy', 'Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Produtividade', 'easy', 'Por que dividir uma tarefa grande em etapas pode ajudar?'),
    ('Tecnologia', 'easy', 'O que é QR Code?', 'Tecnologia', 'easy', 'O que é um QR Code?'),
    ('Tecnologia', 'easy', 'O que é a internet?', 'Tecnologia', 'medium', 'O que é internet?'),
    ('Tecnologia', 'medium', 'O que é atualização de software?', 'Tecnologia', 'medium', 'O que é uma atualização de software?'),
    ('Tecnologia', 'medium', 'O que é um aplicativo móvel?', 'Tecnologia', 'medium', 'O que é aplicativo móvel?'),
    ('Tecnologia', 'medium', 'O que é uma API?', 'Tecnologia', 'medium', 'O que é API?')
    ) AS t(drop_cat, drop_diff, drop_stmt, keep_cat, keep_diff, keep_stmt)
  LOOP
    UPDATE questions q
       SET is_active = false
      FROM categories c
     WHERE c.id = q.category_id
       AND c.name = r.drop_cat
       AND q.difficulty = r.drop_diff
       AND q.statement = r.drop_stmt
       AND q.is_active
       AND EXISTS (
         SELECT 1 FROM questions k
           JOIN categories kc ON kc.id = k.category_id
          WHERE kc.name = r.keep_cat AND k.difficulty = r.keep_diff
            AND k.statement = r.keep_stmt AND k.is_active
       );
    GET DIAGNOSTICS v_n = ROW_COUNT;
    v_total := v_total + v_n;
  END LOOP;
  RAISE NOTICE 'BE-003 P10: % perguntas duplicadas desativadas (esperado: 18)', v_total;
END $$;
