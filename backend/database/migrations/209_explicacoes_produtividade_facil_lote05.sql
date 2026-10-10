-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 5: perguntas 26 a 42 do seed v4 (migration 087, 17 perguntas).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 208. Só atualiza
-- perguntas que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera
-- perguntas nem alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não
-- impedir o arranque do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_facil_v4', 'O que significa revisar uma tarefa?', 'Revisar uma tarefa é verificar o trabalho realizado antes de considerá-lo concluído, procurando falhas e pontos a melhorar. Entregar sem conferir aumenta a chance de erros chegarem a quem recebe.'),
    ('seed_produtividade_facil_v4', 'Qual pode ser o benefício de revisar um documento antes de enviá-lo?', 'Revisar um documento antes de enviá-lo ajuda a identificar possíveis erros de escrita, de números ou de conteúdo, e corrigi-los a tempo. É uma etapa rápida que melhora a qualidade e a imagem do trabalho.'),
    ('seed_produtividade_facil_v4', 'O que é um objetivo de curto prazo?', 'Um objetivo de curto prazo é um resultado planejado para ser alcançado num período relativamente próximo, como alguns dias ou semanas. Costuma ser um passo intermédio rumo a objetivos maiores, de longo prazo.'),
    ('seed_produtividade_facil_v4', 'O que caracteriza uma tarefa urgente?', 'Uma tarefa urgente é a que necessita de atenção em pouco tempo, porque o prazo está próximo ou há uma consequência imediata. Urgente não é o mesmo que importante: uma tarefa pode ser urgente e ter pouco impacto.'),
    ('seed_produtividade_facil_v4', 'Qual é a diferença básica entre importante e urgente?', 'Importante e urgente são ideias diferentes: o que é importante tem impacto relevante nos objetivos; o que é urgente exige atenção rápida por causa do prazo. Algo pode ser importante sem ser urgente, e o contrário também.'),
    ('seed_produtividade_facil_v4', 'Por que estimar o tempo necessário para uma tarefa pode ser útil?', 'Estimar o tempo necessário para uma tarefa ajuda a organizar melhor o calendário, porque se reserva o espaço certo para cada atividade. Assim se evitam agendas sobrecarregadas e prazos cumpridos à pressa.'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma rotina de estudos?', 'Cumprir uma rotina de estudos é seguir regularmente horários ou práticas planejadas para estudar. A regularidade cria hábito, facilita a concentração e evita deixar tudo para a véspera da avaliação.'),
    ('seed_produtividade_facil_v4', 'Qual prática pode melhorar a organização dos estudos?', 'Definir horários e conteúdos a estudar organiza o estudo: sabe-se o que fazer e quando fazer. Estudar sem plano ou deixar tudo para a véspera costuma gerar pressa e conteúdos esquecidos.'),
    ('seed_produtividade_facil_v4', 'O que significa preparar materiais antes de iniciar uma tarefa?', 'Preparar os materiais antes de iniciar uma tarefa é organizar previamente os recursos necessários, como documentos, ferramentas e informações. Assim não se interrompe o trabalho a meio para procurar o que falta.'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de ter um espaço de trabalho organizado?', 'Um espaço de trabalho organizado pode reduzir o tempo gasto procurando objetos e documentos, e diminui as distrações visuais. Com tudo no lugar, a atenção fica na tarefa e o trabalho flui melhor.'),
    ('seed_produtividade_facil_v4', 'Qual exemplo representa uma tarefa recorrente?', 'Uma tarefa recorrente repete-se com regularidade, como verificar diariamente o e-mail profissional. As tarefas que acontecem uma só vez, como comprar um equipamento ou entregar um relatório final, não são recorrentes.'),
    ('seed_produtividade_facil_v4', 'O que significa acompanhar uma meta?', 'Acompanhar uma meta é verificar regularmente se o progresso está de acordo com o objetivo. Com essa verificação, percebe-se cedo se é preciso mudar o ritmo ou o plano para chegar ao resultado.'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de registar tarefas concluídas?', 'Registrar as tarefas concluídas permite visualizar o progresso realizado, o que motiva e mostra quanto já foi feito. Também ajuda a ver o que ainda falta e a planejar os passos seguintes.'),
    ('seed_produtividade_facil_v4', 'O que é uma tarefa pendente?', 'Uma tarefa pendente é aquela que ainda precisa ser concluída. Estar pendente não significa que foi eliminada ou que pertence a outra pessoa: o trabalho continua por fazer e deve entrar no planejamento.'),
    ('seed_produtividade_facil_v4', 'Por que é útil atualizar uma lista de tarefas?', 'Atualizar a lista de tarefas mantém o planeamento alinhado com a situação atual: tarefas concluídas saem, novas entram e as prioridades mudam quando é preciso. Uma lista desatualizada deixa de orientar o trabalho.'),
    ('seed_produtividade_facil_v4', 'O que significa trabalhar de forma organizada?', 'Trabalhar de forma organizada é seguir uma estrutura que facilita a realização das atividades, por exemplo com prioridades, horários e listas. Isso reduz o improviso e poupa tempo e energia.'),
    ('seed_produtividade_facil_v4', 'Qual atitude contribui para uma boa gestão do tempo?', 'Uma boa gestão do tempo exige definir prioridades e distribuir as atividades ao longo do tempo, em vez de acumulá-las. Adiar o importante, trabalhar sem objetivos ou ceder às distrações desperdiça o tempo disponível.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 5: perguntas 26 a 42 do seed v4 (migration 087, 17 perguntas): % pergunta(s) atualizada(s) (esperado: 17).', v_updated;
END $$;
