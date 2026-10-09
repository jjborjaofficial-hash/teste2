-- Alternativas (BE-003, regularização) — Produtividade fácil lote 3: perguntas 1 a 25 do seed v4 (migration 087).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order, perguntas nem explicações. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_produtividade_facil_v4', 'O que é uma lista de tarefas?', 0, 'Um relatório financeiro', 'Um registro organizado das despesas e receitas de uma pessoa'),
    ('seed_produtividade_facil_v4', 'O que é uma lista de tarefas?', 1, 'Um calendário de feriados', 'Um conjunto de datas importantes marcadas em um calendário'),
    ('seed_produtividade_facil_v4', 'O que é uma lista de tarefas?', 2, 'Um arquivo de fotografias', 'Uma coleção de arquivos guardados em pastas no computador'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de definir prioridades?', 0, 'Fazer todas as tarefas ao mesmo tempo', 'Aumentar a quantidade de tarefas feitas por dia'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de definir prioridades?', 1, 'Evitar qualquer planejamento', 'Eliminar a necessidade de definir prazos'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de definir prioridades?', 2, 'Aumentar o número de tarefas', 'Reduzir o tempo reservado às pausas'),
    ('seed_produtividade_facil_v4', 'Por que dividir uma tarefa grande em etapas menores pode ajudar?', 1, 'Torna a tarefa necessariamente mais longa', 'Pode reduzir a necessidade de definir prazos e metas'),
    ('seed_produtividade_facil_v4', 'Por que dividir uma tarefa grande em etapas menores pode ajudar?', 2, 'Elimina a necessidade de realizar a tarefa', 'Pode tornar o trabalho mais cansativo e difícil de iniciar'),
    ('seed_produtividade_facil_v4', 'Por que dividir uma tarefa grande em etapas menores pode ajudar?', 3, 'Impede a conclusão do projeto', 'Pode impedir que se perceba o que já foi concluído'),
    ('seed_produtividade_facil_v4', 'Qual prática pode ajudar a reduzir a procrastinação?', 0, 'Adiar continuamente', 'Esperar sentir vontade para começar'),
    ('seed_produtividade_facil_v4', 'Qual prática pode ajudar a reduzir a procrastinação?', 2, 'Ignorar os prazos', 'Aumentar o número de tarefas ainda pendentes'),
    ('seed_produtividade_facil_v4', 'Qual prática pode ajudar a reduzir a procrastinação?', 3, 'Criar mais distrações', 'Deixar a tarefa para o último dia'),
    ('seed_produtividade_facil_v4', 'O que é um prazo?', 1, 'Uma pausa durante o trabalho', 'O momento de descanso previsto entre duas tarefas longas'),
    ('seed_produtividade_facil_v4', 'O que é um prazo?', 2, 'Uma ferramenta de comunicação', 'A pessoa responsável por acompanhar uma atividade'),
    ('seed_produtividade_facil_v4', 'O que é um prazo?', 3, 'Uma categoria de documentos', 'O resultado final esperado ao concluir o trabalho'),
    ('seed_produtividade_facil_v4', 'Qual ferramenta pode ser usada para organizar compromissos por datas?', 1, 'Editor de imagens', 'Cronômetro'),
    ('seed_produtividade_facil_v4', 'Qual ferramenta pode ser usada para organizar compromissos por datas?', 3, 'Reprodutor de música', 'Gravador de voz'),
    ('seed_produtividade_facil_v4', 'Qual é uma característica de uma meta clara?', 0, 'Não possui qualquer objetivo', 'Descreve de forma geral o que alguém talvez queira fazer'),
    ('seed_produtividade_facil_v4', 'Qual é uma característica de uma meta clara?', 2, 'Não pode ser acompanhada', 'Depende da opinião de outras pessoas para ser entendida'),
    ('seed_produtividade_facil_v4', 'Qual é uma característica de uma meta clara?', 3, 'É sempre impossível de alcançar', 'Muda de significado conforme o dia ou a situação'),
    ('seed_produtividade_facil_v4', 'O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 0, 'A qualidade aumenta sempre', 'Pode terminar cada tarefa com mais rapidez'),
    ('seed_produtividade_facil_v4', 'O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 1, 'Todas as tarefas ficam automaticamente concluídas', 'Pode melhorar o foco em cada atividade'),
    ('seed_produtividade_facil_v4', 'O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 2, 'O tempo deixa de ser relevante', 'Pode reduzir a necessidade de definir prioridades'),
    ('seed_produtividade_facil_v4', 'O que é concentração?', 1, 'Capacidade de fazer várias coisas sem atenção', 'Capacidade de mudar de tarefa várias vezes por hora'),
    ('seed_produtividade_facil_v4', 'O que é concentração?', 2, 'Ato de interromper constantemente uma tarefa', 'Hábito de verificar mensagens durante o trabalho'),
    ('seed_produtividade_facil_v4', 'O que é concentração?', 3, 'Forma de evitar objetivos', 'Rapidez para terminar tarefas sem revisar'),
    ('seed_produtividade_facil_v4', 'Qual destes pode ser uma distração durante o estudo?', 0, 'Um plano de estudo', 'Um ambiente de estudo silencioso'),
    ('seed_produtividade_facil_v4', 'Qual destes pode ser uma distração durante o estudo?', 1, 'Um objetivo definido', 'Um horário de estudo bem definido e respeitado'),
    ('seed_produtividade_facil_v4', 'Qual destes pode ser uma distração durante o estudo?', 2, 'Uma lista de tarefas', 'Uma pausa curta e planejada'),
    ('seed_produtividade_facil_v4', 'Por que organizar o espaço de trabalho pode ser útil?', 0, 'Elimina todas as tarefas', 'Pode aumentar o tempo gasto procurando materiais'),
    ('seed_produtividade_facil_v4', 'Por que organizar o espaço de trabalho pode ser útil?', 1, 'Impede a concentração', 'Pode reduzir a necessidade de planejar as tarefas'),
    ('seed_produtividade_facil_v4', 'Por que organizar o espaço de trabalho pode ser útil?', 2, 'Aumenta obrigatoriamente o tempo de trabalho', 'Pode dificultar a concentração durante o estudo'),
    ('seed_produtividade_facil_v4', 'Qual é o objetivo de uma agenda?', 1, 'Substituir todas as ferramentas digitais', 'Guardar documentos e arquivos importantes em um só lugar'),
    ('seed_produtividade_facil_v4', 'Qual é o objetivo de uma agenda?', 2, 'Armazenar apenas fotografias', 'Calcular o tempo gasto em cada tarefa realizada no dia'),
    ('seed_produtividade_facil_v4', 'Qual é o objetivo de uma agenda?', 3, 'Servir exclusivamente para entretenimento', 'Registrar contatos e informações de pessoas conhecidas'),
    ('seed_produtividade_facil_v4', 'Por que uma rotina pode contribuir para a produtividade?', 0, 'Elimina automaticamente todos os problemas', 'Pode aumentar a necessidade de escolher tudo a cada momento'),
    ('seed_produtividade_facil_v4', 'Por que uma rotina pode contribuir para a produtividade?', 1, 'Impede qualquer mudança', 'Pode impedir que se aprenda a organizar o próprio tempo'),
    ('seed_produtividade_facil_v4', 'Por que uma rotina pode contribuir para a produtividade?', 3, 'Garante que nenhuma tarefa será difícil', 'Pode dispensar a revisão dos resultados ao fim do dia'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma tarefa?', 0, 'Ignorá-la', 'Planejá-la com cuidado antes de iniciá-la'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma tarefa?', 1, 'Adiá-la sem motivo', 'Registrá-la na lista de tarefas do dia'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma tarefa?', 2, 'Transferi-la sempre para outra pessoa', 'Delegá-la a alguém da equipe com mais tempo'),
    ('seed_produtividade_facil_v4', 'Qual ação ajuda a acompanhar o progresso de um projeto?', 0, 'Apagar os objetivos', 'Ampliar a lista de tarefas'),
    ('seed_produtividade_facil_v4', 'Qual ação ajuda a acompanhar o progresso de um projeto?', 1, 'Evitar qualquer registo', 'Reduzir o prazo do projeto'),
    ('seed_produtividade_facil_v4', 'Qual ação ajuda a acompanhar o progresso de um projeto?', 2, 'Alterar constantemente o plano sem necessidade', 'Revisar apenas as etapas futuras'),
    ('seed_produtividade_facil_v4', 'Por que limitar interrupções durante uma tarefa importante pode ser útil?', 0, 'Reduz obrigatoriamente a qualidade', 'Pode dificultar a organização das tarefas'),
    ('seed_produtividade_facil_v4', 'Por que limitar interrupções durante uma tarefa importante pode ser útil?', 1, 'Impede qualquer comunicação necessária', 'Pode aumentar o número de pendências'),
    ('seed_produtividade_facil_v4', 'Por que limitar interrupções durante uma tarefa importante pode ser útil?', 3, 'Elimina os objetivos', 'Pode diminuir o interesse pelos objetivos'),
    ('seed_produtividade_facil_v4', 'Qual é uma boa prática antes de iniciar um projeto?', 0, 'Começar sem saber o resultado desejado', 'Iniciar as tarefas sem planejar o tempo'),
    ('seed_produtividade_facil_v4', 'Qual é uma boa prática antes de iniciar um projeto?', 2, 'Ignorar recursos necessários', 'Reunir recursos somente depois de começar'),
    ('seed_produtividade_facil_v4', 'Qual é uma boa prática antes de iniciar um projeto?', 3, 'Evitar qualquer prazo', 'Evitar combinar prazos com a equipe'),
    ('seed_produtividade_facil_v4', 'O que é produtividade?', 0, 'Quantidade de horas passadas sem produzir', 'Quantidade de horas de trabalho realizadas por semana sem considerar resultados'),
    ('seed_produtividade_facil_v4', 'O que é produtividade?', 1, 'Número de pausas realizadas', 'Número de tarefas iniciadas por dia independentemente de serem concluídas'),
    ('seed_produtividade_facil_v4', 'O que é produtividade?', 3, 'Quantidade de distrações durante o trabalho', 'Capacidade de responder rapidamente às mensagens e pedidos recebidos no dia'),
    ('seed_produtividade_facil_v4', 'O que é um lembrete?', 0, 'Uma tarefa eliminada', 'Um registro destinado a guardar o histórico de tarefas já concluídas'),
    ('seed_produtividade_facil_v4', 'O que é um lembrete?', 1, 'Um relatório financeiro', 'Uma lista destinada a reunir ideias para futuros projetos pessoais'),
    ('seed_produtividade_facil_v4', 'O que é um lembrete?', 3, 'Um tipo de descanso', 'Um relatório destinado a mostrar o tempo gasto em cada atividade'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de nomear corretamente arquivos?', 1, 'Aumenta automaticamente o espaço disponível', 'Aumenta o espaço livre no dispositivo de armazenamento'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de nomear corretamente arquivos?', 2, 'Elimina a necessidade de pastas', 'Reduz o tamanho dos arquivos guardados no computador'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de nomear corretamente arquivos?', 3, 'Impede o acesso aos documentos', 'Dispensa a cópia de segurança dos documentos'),
    ('seed_produtividade_facil_v4', 'O que é uma pausa?', 0, 'Uma tarefa obrigatória', 'Um período longo dedicado a concluir uma atividade importante'),
    ('seed_produtividade_facil_v4', 'O que é uma pausa?', 2, 'Uma meta', 'Um momento reservado para avaliar os resultados da semana'),
    ('seed_produtividade_facil_v4', 'O que é uma pausa?', 3, 'Um prazo', 'Um intervalo de tempo definido para cumprir uma entrega'),
    ('seed_produtividade_facil_v4', 'Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 1, 'Eliminam a necessidade de trabalhar', 'Podem aumentar o cansaço ao longo de um dia inteiro de trabalho'),
    ('seed_produtividade_facil_v4', 'Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 2, 'Garantem produtividade infinita', 'Podem dispensar o planejamento das tarefas seguintes'),
    ('seed_produtividade_facil_v4', 'Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 3, 'Tornam todas as tarefas mais difíceis', 'Podem tornar mais difícil retomar o ritmo depois')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade fácil lote 3: perguntas 1 a 25 do seed v4 (migration 087): % alternativa(s) errada(s) atualizada(s) (esperado: 65).', v_updated;
END $$;
