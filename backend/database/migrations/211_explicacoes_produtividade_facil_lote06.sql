-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 6: perguntas 1 a 25 do seed v7 (migration 096).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples, com o raciocínio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 210. Só atualiza perguntas
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
    ('seed_produtividade_facil_v7', 'Qual é uma boa prática para organizar as tarefas do dia?', 'Definir prioridades ajuda a organizar o dia, porque mostra o que é mais importante e deve ser feito primeiro. Fazer tudo junto ou não planejar deixa o dia confuso.'),
    ('seed_produtividade_facil_v7', 'O que significa estabelecer uma prioridade?', 'Estabelecer uma prioridade é determinar o que deve ser feito primeiro, de acordo com a importância ou a urgência. Escolher à sorte ou adiar não é priorizar.'),
    ('seed_produtividade_facil_v7', 'Qual ferramenta pode ajudar a controlar as tarefas?', 'A lista de tarefas ajuda a controlar o que precisa ser feito, porque tudo fica registrado num só lugar. Calculadora, câmera e leitor de música servem para outras coisas.'),
    ('seed_produtividade_facil_v7', 'Por que é útil definir objetivos?', 'Definir objetivos orienta os esforços: a pessoa sabe para onde está a ir e o que priorizar. Sem objetivos, o trabalho fica solto e é difícil saber se está a dar resultado.'),
    ('seed_produtividade_facil_v7', 'Qual destas atividades geralmente prejudica a concentração?', 'Verificar as redes sociais a toda a hora quebra a concentração, porque a atenção sai da tarefa. Definir metas, organizar o ambiente e fazer pausas planejadas ajudam a manter o foco.'),
    ('seed_produtividade_facil_v7', 'Para que serve uma agenda?', 'A agenda serve para registrar e organizar compromissos, para a pessoa não esquecer datas e horários. Não substitui as outras ferramentas nem elimina horários.'),
    ('seed_produtividade_facil_v7', 'O que pode ajudar a manter o foco?', 'Definir um período específico para uma tarefa ajuda a manter o foco, porque a atenção fica numa coisa só durante aquele tempo. Trocar de tarefa a toda a hora ou ter distrações abertas faz perder o foco.'),
    ('seed_produtividade_facil_v7', 'Qual é a função de um calendário?', 'O calendário serve para organizar datas e compromissos, mostrando o que está marcado e quando. Ajuda a memória, mas não a substitui.'),
    ('seed_produtividade_facil_v7', 'Qual comportamento contribui para uma boa organização?', 'Manter os materiais organizados ajuda a encontrar o que se precisa e poupa tempo. Ignorar documentos, guardar sem ordem ou evitar listas desorganiza o trabalho.'),
    ('seed_produtividade_facil_v7', 'Por que dividir uma tarefa grande em partes menores pode ser útil?', 'Dividir uma tarefa grande em partes menores facilita o acompanhamento do progresso, porque cada parte concluída mostra o avanço. Também torna o começo menos pesado.'),
    ('seed_produtividade_facil_v7', 'O que significa administrar o tempo?', 'Administrar o tempo é usá-lo de maneira planejada, decidindo o que fazer e quando. Fazer várias coisas juntas ou trabalhar sem pausas não é administrar o tempo.'),
    ('seed_produtividade_facil_v7', 'Qual destas opções é uma distração digital comum?', 'Uma notificação desnecessária é uma distração digital comum: chama a atenção e tira o foco da tarefa. Lista de tarefas, cronómetro e calendário ajudam a organizar o tempo.'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de preparar as atividades do dia seguinte?', 'Preparar as atividades do dia seguinte permite começar o dia com maior clareza, porque a pessoa já sabe o que fazer. Não impede mudanças nem elimina problemas.'),
    ('seed_produtividade_facil_v7', 'Qual hábito pode melhorar a produtividade?', 'Definir horários para as atividades importantes ajuda a produtividade, porque reserva tempo para o que conta. Adiar ou ignorar compromissos faz o contrário.'),
    ('seed_produtividade_facil_v7', 'O que significa estar concentrado?', 'Estar concentrado é prestar atenção ao que está a ser realizado. Pensar em várias coisas ou verificar mensagens a toda a hora divide a atenção.'),
    ('seed_produtividade_facil_v7', 'Qual recurso pode ser usado para lembrar compromissos?', 'O alarme pode ser usado para lembrar compromissos, porque toca na hora marcada. Galeria, câmara e lanterna não servem para avisar de compromissos.'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de manter o espaço de trabalho organizado?', 'Um espaço de trabalho organizado facilita encontrar materiais, e assim poupa tempo. Não elimina erros, não dispensa o planejamento e não aumenta o salário.'),
    ('seed_produtividade_facil_v7', 'Qual é uma boa forma de lidar com várias tarefas?', 'Com várias tarefas, a boa forma é organizá-las por prioridade, começando pelo que é mais importante ou urgente. Ignorar ou fazer várias ao mesmo tempo prejudica o resultado.'),
    ('seed_produtividade_facil_v7', 'O que pode acontecer quando uma pessoa tenta fazer muitas coisas ao mesmo tempo?', 'Fazer muitas coisas ao mesmo tempo divide a atenção, por isso a concentração pode diminuir e os erros aumentar. É melhor fazer uma de cada vez.'),
    ('seed_produtividade_facil_v7', 'Para que serve um lembrete?', 'O lembrete serve para ajudar a recordar uma atividade ou compromisso, para que não seja esquecido. Não substitui tarefas nem elimina obrigações.'),
    ('seed_produtividade_facil_v7', 'Qual atitude ajuda a começar uma tarefa difícil?', 'Dividir a tarefa difícil em pequenos passos torna-a menos pesada e mais fácil de começar. Evitar, adiar ou esperar pelo último momento só aumenta a pressão.'),
    ('seed_produtividade_facil_v7', 'Qual destas ferramentas é útil para controlar horários?', 'O relógio é útil para controlar horários, porque mostra as horas. Galeria, microfone e câmara servem para fotos e som.'),
    ('seed_produtividade_facil_v7', 'Qual é uma vantagem de estabelecer horários?', 'Estabelecer horários ajuda a estruturar o dia, e assim cada atividade tem o seu momento. Horários não eliminam o descanso nem fazem as tarefas desaparecer.'),
    ('seed_produtividade_facil_v7', 'O que é um objetivo?', 'Um objetivo é um resultado que se pretende alcançar e que orienta o que se faz. Não é uma distração, um atraso nem uma pausa.'),
    ('seed_produtividade_facil_v7', 'Qual destas ações ajuda a reduzir distrações?', 'Desativar as notificações desnecessárias reduz as distrações, porque o telemóvel deixa de chamar a atenção durante o trabalho. Manter notificações, verificar o telefone ou abrir redes sociais aumenta as distrações.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 6: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
