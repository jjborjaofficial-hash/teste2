-- Explicações pedagógicas (BE-004) — Produtividade médio lote 6: Produtividade médio lote 6.
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 230. Só atualiza perguntas
-- que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não impedir o arranque
-- do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_medio_v6', 'O que é trabalho superficial (shallow work)?', 'Trabalho superficial são tarefas menos exigentes, como responder mensagens ou organizar papéis, que se fazem mesmo com a atenção dividida. Contrasta com o trabalho profundo, que pede concentração intensa.'),
    ('seed_produtividade_medio_v6', 'Qual estratégia ajuda a reduzir interrupções autoinduzidas?', 'Reservar momentos fixos para ver mensagens evita que a própria pessoa se interrompa a toda a hora. Verificar sempre que sente vontade fragmenta a atenção e tira rendimento ao trabalho.'),
    ('seed_produtividade_medio_v6', 'O que significa "custo de oportunidade" na gestão do tempo?', 'O custo de oportunidade é o que se perde ao escolher uma opção em vez de outra. No tempo, cada hora gasta numa atividade deixa de estar disponível para a melhor alternativa.'),
    ('seed_produtividade_medio_v6', 'O que é capacidade de trabalho?', 'A capacidade de trabalho é o que a pessoa consegue de facto fazer, tendo em conta o tempo, a energia e os recursos. Não é o total de horas do dia nem o tamanho da lista de tarefas.'),
    ('seed_produtividade_medio_v6', 'O que é planejamento baseado em capacidade?', 'Planejar com base na capacidade é distribuir as tarefas pelo tempo e pelos recursos realmente disponíveis. Assim os planos são realistas e atrasos por excesso de carga ficam menos prováveis.'),
    ('seed_produtividade_medio_v6', 'O que significa buffer de tempo?', 'O buffer é uma folga reservada no plano para absorver atrasos, imprevistos e a transição entre tarefas. Não é tempo perdido: protege o resto da agenda quando algo demora mais.'),
    ('seed_produtividade_medio_v6', 'Por que deixar espaços vazios na agenda pode ser produtivo?', 'Espaços vazios dão margem para imprevistos e evitam uma agenda rígida em que um atraso desarruma tudo. Isso é planejamento consciente, não falta de objetivos.'),
    ('seed_produtividade_medio_v6', 'O que é planejamento rígido?', 'Planejamento rígido é o que deixa pouca margem para alterações: cada hora está comprometida. Qualquer mudança obriga a refazer o resto.'),
    ('seed_produtividade_medio_v6', 'Qual é o risco de um planejamento excessivamente rígido?', 'Num planejamento muito rígido, um pequeno imprevisto desloca os compromissos seguintes e pode comprometer a programação inteira. Falta folga para absorver a mudança.'),
    ('seed_produtividade_medio_v6', 'Qual é a diferença entre urgência e importância?', 'Urgência diz respeito ao tempo de reação: pede ação rápida. Importância diz respeito ao impacto nos objetivos. Uma tarefa pode ser urgente sem ser importante, e vice-versa.'),
    ('seed_produtividade_medio_v6', 'Qual é a principal utilidade de uma Not-to-do list?', 'A not-to-do list reúne hábitos e tarefas que se decide deixar de fazer, por consumirem tempo sem contribuir para os objetivos. Liberta tempo e atenção para o que conta.'),
    ('seed_produtividade_medio_v6', 'O que significa aumentar o atrito de um comportamento indesejado?', 'Aumentar o atrito é pôr obstáculos entre a pessoa e o hábito, para exigir mais esforço para o praticar. Quanto menos fácil, menos provável é cair nele por impulso.'),
    ('seed_produtividade_medio_v6', 'Qual prática pode aumentar o atrito para evitar distrações digitais?', 'Remover atalhos ou silenciar notificações aumenta o esforço de chegar às distrações, e por isso a pessoa cede menos a elas. As outras opções tornam o acesso mais fácil.'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de resultado?', 'Uma meta de resultado define o que se quer alcançar no fim, como uma nota ou um valor. Não descreve as ações para lá chegar, e é isso que a distingue da meta de processo.'),
    ('seed_produtividade_medio_v6', 'O que é uma meta de processo?', 'Uma meta de processo descreve as ações ou comportamentos que levam ao resultado, como estudar uma hora por dia. É concreta e a pessoa pode cumpri-la mesmo antes de ver o resultado.'),
    ('seed_produtividade_medio_v6', 'Por que metas de processo podem ser úteis?', 'As metas de processo focam o que a pessoa controla diretamente, as suas ações. O resultado final depende também de fatores externos, que ela não domina.'),
    ('seed_produtividade_medio_v6', 'Por que feedback rápido pode ser útil?', 'Feedback rápido mostra cedo o que está errado, e por isso dá para corrigir antes de o erro se repetir ou crescer. Quanto mais tarde chega, mais caro é corrigir.'),
    ('seed_produtividade_medio_v6', 'Por que as prioridades devem ser revisadas periodicamente?', 'As circunstâncias mudam: prazos, informações, recursos e objetivos. Rever as prioridades de tempos a tempos mantém o plano alinhado com a realidade.'),
    ('seed_produtividade_medio_v6', 'Qual é uma estratégia eficiente para lidar com tarefas recorrentes?', 'Tarefas recorrentes pedem sistemas: rotina, checklist ou automação, que poupam decisões e reduzem erros. Reinventar o método a cada vez gasta energia sem ganho.'),
    ('seed_produtividade_medio_v6', 'Qual pergunta é adequada para uma retrospectiva de produtividade?', 'A retrospetiva serve para aprender com o que passou e ajustar o que vem. A pergunta certa olha para a próxima semana e procura melhorias, sem cortar descanso nem recusar mudanças.'),
    ('seed_produtividade_medio_v6', 'O que significa otimizar um sistema de produtividade?', 'Otimizar é ajustar métodos e processos para obter melhores resultados com mais eficiência e de forma sustentável. Trabalhar mais horas ou fazer mais tarefas sem avaliar não é otimizar.'),
    ('seed_produtividade_medio_v6', 'Qual princípio melhor representa uma produtividade de alto nível?', 'Alto nível não é fazer mais, é pôr os recursos nas atividades certas, executar bem e rever o sistema continuamente. Estar ocupado ou evitar mudanças não garante resultados.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 6: % pergunta(s) atualizada(s) (esperado: 22).', v_updated;
END $$;
