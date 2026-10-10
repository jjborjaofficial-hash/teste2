-- Explicações pedagógicas (BE-004) — Produtividade difícil lote 4: as 23 perguntas ativas que faltam do seed v2 (v2#52 a v2#73, migration 078) e a do seed v3 (migration 101), que fecha o difícil.
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 266. Só atualiza perguntas
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
    ('seed_produtividade_dificil_v2', 'O que é uma premissa de planejamento?', 'Uma premissa é uma condição que se assume como verdadeira ao construir o plano, por exemplo "a equipa terá três pessoas". Se a premissa deixar de ser verdadeira, o plano precisa de ser revisto.'),
    ('seed_produtividade_dificil_v2', 'Por que rever premissas pode ser importante?', 'Os planos assentam em premissas, e as condições mudam. Rever as premissas mostra quando o plano deixou de ser adequado e precisa de ajuste. Não é abandonar o plano nem ignorar os dados.'),
    ('seed_produtividade_dificil_v2', 'Uma equipa estabelece um prazo sem considerar a duração das dependências anteriores. Qual falha ocorreu?', 'Definir um prazo sem ver quanto demoram as dependências anteriores é ignorar o caminho necessário até a entrega, e o prazo acaba por ser irreal. O prazo tem de partir da sequência real do trabalho.'),
    ('seed_produtividade_dificil_v2', 'O que significa identificar o caminho crítico de um projeto?', 'O caminho crítico é a sequência de atividades que determina a duração mínima do projeto: um atraso em qualquer uma delas atrasa a entrega. Saber qual é permite concentrar atenção onde mais pesa.'),
    ('seed_produtividade_dificil_v2', 'Se uma atividade do caminho crítico atrasar e não houver margem, o que pode acontecer?', 'Uma atividade do caminho crítico sem margem empurra tudo o que vem depois, por isso o prazo final do projeto pode atrasar. O atraso não desaparece sozinho.'),
    ('seed_produtividade_dificil_v2', 'Qual é a finalidade de uma retrospectiva de projeto?', 'A retrospetiva serve para aprender com o processo e identificar melhorias para os próximos projetos: o que correu bem, o que correu mal e o que mudar. Não serve para repetir decisões nem para eliminar registos.'),
    ('seed_produtividade_dificil_v2', 'Uma retrospectiva identifica que reuniões longas foram responsáveis por atrasos recorrentes. Qual seria uma resposta baseada em evidências?', 'Uma resposta baseada em evidências é testar a mudança, como reuniões mais curtas, e medir o impacto. Assim vê-se com dados se resolve os atrasos, em vez de adivinhar.'),
    ('seed_produtividade_dificil_v2', 'Por que testar uma melhoria antes de aplicá-la em toda a organização pode ser útil?', 'Testar numa escala pequena e controlada permite avaliar resultados e riscos antes de alargar a mudança. Se correr mal, o prejuízo é limitado. Não garante o sucesso, mas reduz o custo de errar.'),
    ('seed_produtividade_dificil_v2', 'Uma equipa implementa uma nova rotina e, após um mês, verifica que o desempenho piorou. Qual atitude é mais adequada?', 'Se o desempenho piorou, o mais adequado é analisar os dados e ajustar ou abandonar a abordagem conforme os resultados. Manter a rotina por teimosia ou ignorar os números repete o erro.'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma cultura de melhoria contínua?', 'Numa cultura de melhoria contínua procura-se com regularidade melhorar os processos com base em evidências, ou seja, em dados. Mudar muito sem medir, ou trocar de ferramentas por moda, não é melhorar.'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa trabalha melhor quando possui um objetivo claramente definido, mas recebe tarefas inesperadas constantemente. Qual solução pode equilibrar flexibilidade e foco?', 'Reservar uma margem de tempo para imprevistos mantém o foco no objetivo e deixa espaço para o que surge. Um calendário cheio ou ignorar o imprevisto tiram flexibilidade ou foco.'),
    ('seed_produtividade_dificil_v2', 'Qual é a principal função de uma margem de capacidade no planejamento?', 'A margem de capacidade permite absorver variações, como imprevistos e atrasos, sem comprometer logo o plano. Um calendário sem folga deixa qualquer atraso virar atraso do plano inteiro.'),
    ('seed_produtividade_dificil_v2', 'Uma equipa está sempre ocupada, mas os resultados estratégicos não melhoram. Qual diagnóstico deve ser considerado primeiro?', 'Uma equipa sempre ocupada sem melhorar os resultados estratégicos pode estar a fazer atividades que não levam aos objetivos: desalinhamento entre o que faz e o que importa. Convém verificar isso primeiro.'),
    ('seed_produtividade_dificil_v2', 'Qual pergunta melhor ajuda a identificar atividades de baixo valor?', 'Para encontrar atividades de baixo valor, a pergunta útil é se contribuem significativamente para algum objetivo. Contar aplicações, mensagens ou tempo ocupado mostra atividade, não valor.'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa continua executando manualmente uma tarefa porque "sempre foi assim". Qual princípio de produtividade deve ser aplicado?', '"Sempre foi assim" não é razão para manter um processo. O princípio a aplicar é questionar os processos existentes e procurar oportunidades de melhoria, como automatizar o que é repetitivo.'),
    ('seed_produtividade_dificil_v2', 'Qual situação representa desperdício de capacidade?', 'Há desperdício de capacidade quando se gastam tempo e recursos em atividades sem contribuição relevante para os objetivos. Descanso, revisão e planeamento são usos válidos da capacidade.'),
    ('seed_produtividade_dificil_v2', 'Uma organização possui excelentes planos, mas baixa execução. Qual fator pode explicar essa diferença?', 'Planos bons e pouca execução costumam indicar que falta definir quem é responsável por quê e acompanhar o andamento. Sem isso, ninguém assume as tarefas e os atrasos não são notados.'),
    ('seed_produtividade_dificil_v2', 'O que transforma um plano em um sistema de execução mais robusto?', 'Um plano passa a ser um sistema de execução mais robusto quando tem responsáveis, prazos, prioridades e acompanhamento: assim sabe-se quem faz o quê, até quando e como vai o andamento.'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa termina uma tarefa e imediatamente começa outra sem verificar se o resultado atende aos critérios definidos. Qual risco aumenta?', 'Começar outra tarefa sem verificar se a anterior cumpre os critérios aumenta o risco de entregas incompletas ou de baixa qualidade, que depois voltam como retrabalho.'),
    ('seed_produtividade_dificil_v2', 'Qual etapa deve ocorrer antes de considerar uma entrega concluída em um processo que exige qualidade?', 'Antes de dar uma entrega por concluída, deve-se verificá-la contra os critérios definidos. Só assim se sabe que cumpre o que foi combinado.'),
    ('seed_produtividade_dificil_v2', 'Um projeto apresenta muitas revisões porque os requisitos mudam constantemente. Qual medida pode reduzir retrabalho?', 'Os requisitos mudam e geram revisões quando não são claros desde o início. Clarificá-los e fixar critérios de aceitação antes da execução reduz o retrabalho.'),
    ('seed_produtividade_dificil_v2', 'Qual é uma consequência direta de requisitos pouco claros?', 'Requisitos pouco claros levam a entender coisas diferentes e a refazer o trabalho, por isso aumenta a probabilidade de retrabalho. Não dão mais previsibilidade nem reduzem custos.'),
    ('seed_produtividade_dificil_v3', 'O que é a técnica de time blocking?', 'Time blocking é reservar blocos específicos de tempo na agenda para tarefas ou tipos de atividade definidos, assim o tempo importante fica protegido. Não é bloquear interrupções nem trabalhar sem horário.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade difícil lote 4: % pergunta(s) atualizada(s) (esperado: 23).', v_updated;
END $$;
