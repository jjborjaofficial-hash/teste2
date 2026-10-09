-- Ajuste de alternativas (BE-003, regularização) — Tecnologia difícil, resíduo: 7 perguntas do lote 4 (migration 324) que
-- ainda tinham pistas de linguagem apontadas pelo detetor de viés (absolutos só nas erradas, cautela só na correta, palavras
-- desequilibradas). Pedido do dono: deixar Tecnologia sem lacunas antes de passar ao Marketing Digital.
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é ajustado. As explicações destas
-- 7 perguntas são conceptuais e continuam coerentes com o novo texto, por isso não são tocadas.
-- CORREÇÃO POSTERIOR a um lote já aplicado (324): o nome `*_ajuste_alternativas_*` diz ao teste dos lotes
-- (tests/quiz-alternatives-lotes.test.js) que este texto substitui o do lote.
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
    ('seed_tecnologia_dificil_v2', 'O que é um conjunto de validação em Machine Learning?', 0, 'Dados utilizados para treinar os parâmetros internos do modelo antes de qualquer avaliação', 'Dados utilizados para treinar os parâmetros internos do modelo antes da fase de avaliação'),
    ('seed_tecnologia_dificil_v2', 'O que é um conjunto de validação em Machine Learning?', 1, 'Dados utilizados para medir o desempenho final do modelo somente depois de concluído', 'Dados utilizados para medir o desempenho final do modelo depois de concluído o desenvolvimento'),
    ('seed_tecnologia_dificil_v2', 'Em criptografia assimétrica, qual característica é correta?', 2, 'Utiliza uma chave pública para cifrar e a mesma chave pública para decifrar', 'Costuma utilizar uma chave pública para cifrar e a mesma chave pública para decifrar'),
    ('seed_tecnologia_dificil_v2', 'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 1, 'Treino mais longo', 'Treino prolongado'),
    ('seed_tecnologia_dificil_v2', 'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 2, 'Menos dados de treino', 'Poucos dados'),
    ('seed_tecnologia_dificil_v3', 'O que é computação em nuvem híbrida?', 0, 'Modelo que utiliza somente servidores de um único provedor de nuvem', 'Modelo que utiliza servidores de um único provedor de nuvem'),
    ('seed_tecnologia_dificil_v3', 'O que é computação em nuvem híbrida?', 2, 'Modelo que mantém todos os sistemas apenas em servidores da própria empresa', 'Modelo que mantém os sistemas em servidores da própria empresa'),
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 1, 'Modelo em que todas as réplicas são bloqueadas até que uma delas confirme a gravação', 'Modelo em que as réplicas são bloqueadas até que uma delas confirme a gravação'),
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 2, 'Modelo em que cada réplica guarda dados próprios e nunca troca informações com as demais', 'Modelo em que cada réplica pode guardar dados próprios e raramente troca informações com as demais'),
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 3, 'Modelo em que as réplicas ficam sempre diferentes, sem qualquer convergência', 'Modelo em que as réplicas ficam diferentes, sem convergência entre elas'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 0, 'A simétrica é usada somente em redes locais privadas, enquanto a assimétrica é usada somente em redes públicas abertas', 'A simétrica é usada em redes locais privadas, enquanto a assimétrica é usada em redes públicas abertas'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 3, 'A simétrica serve apenas para assinaturas digitais, enquanto a assimétrica serve apenas para compactar dados', 'A simétrica serve para assinaturas digitais, enquanto a assimétrica serve para compactar dados'),
    ('seed_tecnologia_dificil_v3', 'Qual é a principal finalidade de uma arquitetura de microsserviços?', 1, 'Reunir vários serviços independentes em uma única aplicação compacta executada como um só bloco', 'Reunir vários serviços independentes em uma única aplicação compacta executada como um bloco único'),
    ('seed_tecnologia_dificil_v3', 'Qual é a principal finalidade de uma arquitetura de microsserviços?', 3, 'Dividir uma aplicação em camadas visuais que se comunicam apenas por meio do navegador', 'Dividir uma aplicação em camadas visuais que se comunicam por meio do navegador')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Tecnologia (resíduo): % alternativa(s) errada(s) atualizada(s) (esperado: 14).', v_updated;
END $$;
