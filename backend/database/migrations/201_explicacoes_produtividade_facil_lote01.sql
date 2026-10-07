-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 1: perguntas 1 a 25 do seed v1 (migration 042).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md). Só atualiza perguntas que ainda NÃO têm explicação, então é idempotente e
-- nunca sobrescreve texto já escrito. Não altera perguntas nem alternativas. Se alguma pergunta já não existir,
-- é simplesmente ignorada (nunca falha, para não impedir o arranque do backend: as migrations correm no deploy).
-- O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_produtividade_facil_v1', 'O que significa ser produtivo?', 'Ser produtivo não é trabalhar mais horas nem fazer muitas coisas ao mesmo tempo: é conseguir fazer o que realmente importa de forma eficiente. Quem escolhe bem o que fazer e como fazer gasta menos tempo e energia para chegar ao resultado.'),
    ('seed_produtividade_facil_v1', 'O que é uma tarefa?', 'Tarefa é uma atividade concreta que precisa ser feita, como estudar um capítulo ou lavar a roupa. Dividir o trabalho em tarefas torna mais fácil saber o que fazer primeiro e acompanhar o que já ficou pronto.'),
    ('seed_produtividade_facil_v1', 'Para que serve uma lista de tarefas?', 'A lista de tarefas reúne num só lugar tudo o que precisa de ser feito. Assim a pessoa não depende só da memória, vê o que falta e pode riscar o que já terminou, o que dá clareza e motivação.'),
    ('seed_produtividade_facil_v1', 'O que significa priorizar?', 'Priorizar é decidir o que merece atenção primeiro, normalmente o que é mais importante ou mais urgente. Quando tudo parece igual, o tempo acaba nas tarefas fáceis e as importantes ficam para trás.'),
    ('seed_produtividade_facil_v1', 'Qual destas é uma ferramenta que pode ajudar na organização?', 'A agenda serve para anotar compromissos, datas e tarefas, por isso ajuda a organizar o tempo. Ferramentas feitas para diversão ou comunicação não têm essa função e podem até distrair.'),
    ('seed_produtividade_facil_v1', 'O que é uma meta?', 'Meta é o resultado que se quer alcançar, como terminar um curso ou poupar uma quantia. Ter uma meta dá direção: permite saber para onde ir e perceber se já se está a chegar lá.'),
    ('seed_produtividade_facil_v1', 'Por que estabelecer metas pode ser útil?', 'As metas funcionam como um mapa: ajudam a escolher onde gastar tempo e esforço para chegar ao que se deseja. Não garantem sucesso, mas tornam mais fácil decidir o que fazer a cada dia.'),
    ('seed_produtividade_facil_v1', 'O que é organização pessoal?', 'Organização pessoal é cuidar do próprio tempo, das tarefas, das informações e das responsabilidades. Quem se organiza perde menos tempo a procurar coisas e esquece menos os compromissos.'),
    ('seed_produtividade_facil_v1', 'O que é uma rotina?', 'Rotina é um conjunto de atividades que se repetem com regularidade, como acordar, estudar e dormir mais ou menos às mesmas horas. Por se repetir, a rotina cria hábito e facilita o dia a dia.'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de ter uma rotina?', 'Quando uma atividade já faz parte da rotina, não é preciso decidir de novo todos os dias se se vai fazer ou quando. Isso poupa energia mental e deixa mais atenção para o que realmente exige pensar.'),
    ('seed_produtividade_facil_v1', 'O que significa cumprir um prazo?', 'Cumprir um prazo é terminar a atividade dentro do tempo combinado. Não basta começar a tempo: o que conta é entregar o trabalho pronto até à data marcada.'),
    ('seed_produtividade_facil_v1', 'O que é uma distração?', 'Distração é tudo o que tira a atenção do que se está a fazer, como uma notificação ou uma conversa. Mesmo curtas, as distrações fazem perder o fio do raciocínio e o trabalho demora mais.'),
    ('seed_produtividade_facil_v1', 'Qual destas pode ser uma distração durante os estudos?', 'As notificações constantes do telemóvel chamam a atenção a toda a hora e interrompem o estudo. Já o que apoia o estudo, como resumos, um horário definido ou um local silencioso, ajuda a manter o foco.'),
    ('seed_produtividade_facil_v1', 'O que significa concentrar-se?', 'Concentrar-se é dirigir a atenção para uma atividade de cada vez. Dividir a atenção entre várias coisas faz errar mais e demorar mais.'),
    ('seed_produtividade_facil_v1', 'Por que pequenas pausas podem ser úteis?', 'Pausas curtas dão descanso à mente e ao corpo, ajudando a recuperar a atenção e a reduzir o cansaço. Depois da pausa, é mais fácil voltar ao trabalho com energia.'),
    ('seed_produtividade_facil_v1', 'O que é procrastinação?', 'Procrastinar é adiar uma tarefa que deveria ser feita sem uma razão que o justifique. O resultado costuma ser pressa e stress mais tarde, quando o prazo se aproxima. Parar para atender uma urgência real não é procrastinar.'),
    ('seed_produtividade_facil_v1', 'Qual atitude pode ajudar a combater a procrastinação?', 'Uma tarefa grande pode parecer pesada e dar vontade de adiar. Dividi-la em etapas pequenas torna o começo mais fácil e mostra progresso a cada etapa concluída. Esperar pela vontade costuma só atrasar mais.'),
    ('seed_produtividade_facil_v1', 'O que significa planejar o dia?', 'Planejar o dia é decidir antes quais são as principais atividades e o que vem primeiro. Com o plano pronto, gasta-se menos tempo a pensar no que fazer e há menos risco de esquecer o que é importante.'),
    ('seed_produtividade_facil_v1', 'O que é um calendário?', 'O calendário mostra dias, semanas e meses e serve para marcar datas e compromissos, como provas, reuniões e prazos. Assim é mais fácil não esquecer nada e distribuir bem o tempo.'),
    ('seed_produtividade_facil_v1', 'O que é um compromisso?', 'Compromisso é uma atividade ou obrigação combinada ou marcada antes, como uma consulta ou uma reunião. Por ter sido combinado, merece ser cumprido e anotado na agenda.'),
    ('seed_produtividade_facil_v1', 'Qual é uma vantagem de organizar o espaço de trabalho?', 'Um espaço arrumado deixa os materiais à mão e tem menos coisas a chamar a atenção. Assim perde-se menos tempo a procurar e é mais fácil manter o foco.'),
    ('seed_produtividade_facil_v1', 'O que significa terminar uma tarefa?', 'Terminar uma tarefa é concluir o que precisava ser feito, e não apenas começá-la. Só quando está concluída é que se pode riscá-la da lista e passar para a seguinte.'),
    ('seed_produtividade_facil_v1', 'O que é foco?', 'Foco é a capacidade de manter a atenção numa atividade ou objetivo, sem se deixar levar por outras coisas. Quanto maior o foco, mais rápido e melhor se trabalha.'),
    ('seed_produtividade_facil_v1', 'Qual é uma boa prática antes de começar um trabalho importante?', 'Antes de começar um trabalho importante, convém definir claramente o que precisa ser feito. Com o objetivo claro, é mais fácil escolher os passos e evitar perder tempo em coisas que não ajudam.'),
    ('seed_produtividade_facil_v1', 'O que significa organizar informações?', 'Organizar informações é arrumá-las por temas, nomes ou datas, de modo que seja fácil encontrá-las e usá-las depois. Informação bem organizada poupa tempo e evita perder dados importantes.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
