-- Explicações pedagógicas (BE-004) — Produtividade médio lote 5: as mesmas 25 perguntas da migration 228 (explicação curta e clara,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_medio_v1', 'Segundo a lógica da matriz de Eisenhower, uma tarefa urgente e importante deve ser:', 'O que é urgente e importante tem prazo curto e peso real nos objetivos, por isso passa à frente de tudo o resto. Adiar, ignorar ou delegar sem critério pode transformar um problema em crise.'),
    ('seed_produtividade_medio_v6', 'O que é uma interrupção autoinduzida?', 'Interrupção autoinduzida é a que vem de nós mesmos: abrir o telemóvel ou mudar de aba sem necessidade. Como a origem é interna, ela pode ser reduzida com hábitos, por exemplo definir horas para ver mensagens.'),
    ('seed_produtividade_medio_v6', 'Uma tarefa pode ser urgente, mas pouco importante?', 'Urgência e importância são coisas diferentes: urgente pede resposta rápida, importante contribui para os objetivos. Um pedido de última hora de pouco valor é urgente mas pouco importante, e é por isso que a matriz de Eisenhower separa as duas.'),
    ('seed_produtividade_medio_v6', 'O que é uma prioridade estratégica?', 'Uma prioridade estratégica é a que ajuda diretamente a alcançar os objetivos maiores. O critério é o impacto no que importa a longo prazo, e não a rapidez nem o facto de a tarefa ser urgente.'),
    ('seed_produtividade_medio_v6', 'O que é revisão de prioridades?', 'Com o tempo, prazos, pedidos e objetivos mudam. Revisar prioridades é voltar a conferir se o que está na lista ainda faz sentido, para ajustar a ordem e deixar de gastar tempo no que perdeu importância.'),
    ('seed_produtividade_medio_v6', 'O que significa "tempo de trabalho profundo" (deep work)?', 'Deep work é trabalhar com atenção total numa tarefa que exige raciocínio, sem se deixar interromper. Não depende da hora do dia: o que conta é a concentração intensa e o pouco ruído à volta.'),
    ('seed_produtividade_medio_v6', 'O que significa reduzir o atrito de uma tarefa?', 'Atrito é tudo o que dificulta começar, como procurar material ou abrir programas. Reduzi-lo, por exemplo deixando tudo pronto de véspera, torna o arranque mais fácil e diminui a tentação de adiar.'),
    ('seed_produtividade_medio_v6', 'Por que checklists são úteis em tarefas repetitivas?', 'Em tarefas que se repetem, a memória falha por rotina e uma etapa fica para trás. O checklist funciona como lembrete externo e reduz a chance de esquecimentos, embora não garanta que nunca haverá erros.'),
    ('seed_produtividade_medio_v6', 'O que é um indicador-chave de desempenho (KPI)?', 'KPI é uma métrica escolhida de propósito para mostrar se se está a avançar rumo a um objetivo. Não é qualquer número: só serve se estiver ligado ao que se quer alcançar e ajudar a decidir o que ajustar.'),
    ('seed_produtividade_medio_v6', 'Qual exemplo representa uma intenção de implementação?', 'Uma intenção de implementação liga uma situação concreta a uma ação concreta, no formato "se acontecer X, então faço Y". Ao definir o gatilho e a duração, deixa de depender da vontade do momento e fica mais fácil cumprir.'),
    ('seed_produtividade_medio_v6', 'Qual é a utilidade de registrar o tempo gasto em determinadas tarefas?', 'Anotar quanto tempo cada tarefa realmente levou mostra onde as estimativas falham. Com esses dados, os próximos planejamentos ficam mais realistas e é mais fácil prometer prazos que se consegue cumprir.'),
    ('seed_produtividade_medio_v6', 'O que é uma tarefa de baixa prioridade?', 'Baixa prioridade é uma questão de comparação: a tarefa tem menos impacto ou urgência do que as outras. Não significa que seja inútil, apenas que pode esperar ou ser feita depois do que pesa mais.'),
    ('seed_produtividade_medio_v6', 'O que é uma lista "Não Fazer" (Not-to-do list)?', 'A lista "Não Fazer" reúne hábitos e atividades a evitar, como abrir redes sociais a meio do trabalho. Ao decidir antes o que não fazer, protege-se a atenção para o que realmente importa.'),
    ('seed_produtividade_medio_v6', 'Qual comportamento é mais compatível com uma sessão de deep work?', 'Deep work pede foco numa só tarefa importante, por isso as notificações têm de ser reduzidas. Responder a mensagens ou alternar entre conversas quebra a concentração, e cada quebra custa tempo para retomar o fio.'),
    ('seed_produtividade_medio_v6', 'Qual é a vantagem de possuir um plano alternativo?', 'Imprevistos acontecem e nenhum plano os evita. Ter uma alternativa pronta permite mudar de rumo sem perder tempo a improvisar, mantendo o trabalho a andar quando o plano principal falha.'),
    ('seed_produtividade_medio_v6', 'O que ocorre quando o planejamento ultrapassa constantemente a capacidade disponível?', 'Planejar mais do que cabe no tempo e na energia disponíveis faz com que algo fique por fazer. O resultado habitual é atraso, cansaço e trabalho de pior qualidade, e não um aumento mágico de produtividade.'),
    ('seed_produtividade_medio_v6', 'O que é uma estimativa de tempo?', 'Estimar o tempo é fazer uma previsão aproximada, baseada na experiência, de quanto uma atividade vai demorar. É aproximada porque o futuro tem incertezas, mas ajuda a planear prazos e a organizar o dia.'),
    ('seed_produtividade_medio_v6', 'O que é uma retrospectiva pessoal?', 'A retrospectiva pessoal olha para trás para aprender: o que correu bem, o que correu mal e o que pode mudar. É uma forma de melhorar o método de trabalho com base na experiência real e não em suposições.'),
    ('seed_produtividade_medio_v6', 'O que é um checklist?', 'Um checklist é uma lista organizada de itens ou passos a conferir, um a um. Serve para não saltar nada importante, sobretudo em tarefas com muitas etapas ou que se repetem.'),
    ('seed_produtividade_medio_v6', 'Qual é a principal finalidade de definir uma prioridade máxima para o dia?', 'Escolher uma prioridade máxima diz-lhe o que tem de ficar feito mesmo que o dia corra mal. Assim a energia vai primeiro para o que mais importa, antes de se gastar em tarefas menores.'),
    ('seed_produtividade_medio_v6', 'Por que distinguir trabalho profundo de trabalho superficial pode melhorar a organização?', 'Tarefas exigentes pedem blocos de concentração, enquanto as superficiais cabem em intervalos curtos. Separar os dois tipos permite reservar as melhores horas para o trabalho difícil e deixar o resto para momentos de menor energia.'),
    ('seed_produtividade_medio_v6', 'Por que as estimativas de tempo podem apresentar erros?', 'Uma estimativa é uma previsão, e na prática aparecem interrupções, dificuldades e detalhes que ninguém previu. Por isso os erros são normais e convém deixar folga e comparar sempre com o tempo real.'),
    ('seed_produtividade_medio_v6', 'O que é planejamento por cenários?', 'No planejamento por cenários imaginam-se várias situações possíveis, como o melhor e o pior caso, e prepara-se uma resposta para cada uma. Assim, quando algo muda, já existe um caminho pensado.'),
    ('seed_produtividade_medio_v6', 'O que é feedback no contexto da produtividade?', 'Feedback é a informação de volta sobre como se está a ir. Serve para corrigir o que não funciona e manter o que funciona, ajustando as próximas ações com base em dados e não em palpites.'),
    ('seed_produtividade_medio_v6', 'Qual exemplo reduz o atrito para estudar?', 'Ter caderno, livros e caneta já preparados elimina o esforço de começar e tira desculpas para adiar. Quanto menos passos entre si e o estudo, mais fácil é arrancar.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade médio lote 5: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
