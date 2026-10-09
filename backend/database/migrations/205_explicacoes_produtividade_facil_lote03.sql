-- Explicações pedagógicas (BE-004) — Produtividade fácil lote 3: perguntas 1 a 25 do seed v4 (migration 087).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 204. Só atualiza
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
    ('seed_produtividade_facil_v4', 'O que é uma lista de tarefas?', 'Uma lista de tarefas é uma relação organizada das atividades que precisam ser realizadas. Escrever tudo num só lugar ajuda a lembrar, a escolher por onde começar e a marcar o que já foi feito.'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de definir prioridades?', 'Definir prioridades é identificar o que merece atenção primeiro, para dedicar o tempo e a energia ao que é mais importante ou urgente. Assim, o essencial não fica para depois por causa do que é menos relevante.'),
    ('seed_produtividade_facil_v4', 'Por que dividir uma tarefa grande em etapas menores pode ajudar?', 'Dividir uma tarefa grande em etapas menores pode facilitar a organização e o acompanhamento do progresso: cada etapa é mais fácil de começar, e ver as partes concluídas dá motivação para continuar.'),
    ('seed_produtividade_facil_v4', 'Qual prática pode ajudar a reduzir a procrastinação?', 'Para reduzir a procrastinação, ajuda começar por uma pequena parte da tarefa. O primeiro passo costuma ser o mais difícil, e depois de iniciar fica mais fácil continuar.'),
    ('seed_produtividade_facil_v4', 'O que é um prazo?', 'Prazo é o tempo máximo ou a data definida para concluir algo. Ter um prazo ajuda a planejar o trabalho e a saber quando uma tarefa precisa estar pronta.'),
    ('seed_produtividade_facil_v4', 'Qual ferramenta pode ser usada para organizar compromissos por datas?', 'O calendário é a ferramenta usada para organizar compromissos por datas, mostrando os dias e os meses. Calculadoras e outros programas têm funções diferentes, como fazer contas ou medir tempo.'),
    ('seed_produtividade_facil_v4', 'Qual é uma característica de uma meta clara?', 'Uma meta clara indica de forma compreensível o que se pretende alcançar. Quando todos entendem o objetivo, é mais fácil agir na direção certa e verificar se ele foi atingido.'),
    ('seed_produtividade_facil_v4', 'O que pode acontecer quando uma pessoa tenta realizar muitas tarefas simultaneamente?', 'Tentar fazer muitas tarefas ao mesmo tempo divide a atenção, por isso a pessoa pode perder concentração e cometer mais erros. Em geral, rende mais fazer uma coisa de cada vez.'),
    ('seed_produtividade_facil_v4', 'O que é concentração?', 'Concentração é a capacidade de manter a atenção numa atividade. Quanto mais focada a pessoa está, menos erros comete e mais depressa termina o que começou.'),
    ('seed_produtividade_facil_v4', 'Qual destes pode ser uma distração durante o estudo?', 'Uma notificação constante do telefone interrompe o estudo e obriga a atenção a voltar ao início de cada vez. Um plano, um objetivo definido ou uma lista de tarefas, pelo contrário, ajudam a manter o foco.'),
    ('seed_produtividade_facil_v4', 'Por que organizar o espaço de trabalho pode ser útil?', 'Organizar o espaço de trabalho pode facilitar o acesso aos materiais necessários. Quando tudo tem o seu lugar, perde-se menos tempo a procurar e a atenção fica na tarefa.'),
    ('seed_produtividade_facil_v4', 'Qual é o objetivo de uma agenda?', 'A agenda serve para ajudar a organizar compromissos e atividades ao longo do tempo, registrando datas e horários. Assim se evitam esquecimentos e conflitos entre atividades.'),
    ('seed_produtividade_facil_v4', 'Por que uma rotina pode contribuir para a produtividade?', 'Uma rotina pode reduzir a necessidade de decidir constantemente o que fazer, porque as atividades já têm hora e ordem. Isso poupa energia mental para o que realmente exige atenção.'),
    ('seed_produtividade_facil_v4', 'O que significa cumprir uma tarefa?', 'Cumprir uma tarefa é realizá-la conforme o objetivo estabelecido, ou seja, fazê-la até ao fim e com o resultado combinado. Planejar ou registrar a tarefa é parte do caminho, mas não basta para a cumprir.'),
    ('seed_produtividade_facil_v4', 'Qual ação ajuda a acompanhar o progresso de um projeto?', 'Marcar as etapas concluídas é uma forma simples de acompanhar o progresso de um projeto, porque mostra o que já foi feito e o que ainda falta. Isso permite ajustar o ritmo a tempo.'),
    ('seed_produtividade_facil_v4', 'Por que limitar interrupções durante uma tarefa importante pode ser útil?', 'Limitar as interrupções durante uma tarefa importante pode ajudar a manter a concentração. Cada interrupção obriga a atenção a recomeçar e aumenta a chance de erros e de atrasos.'),
    ('seed_produtividade_facil_v4', 'O que significa organizar tarefas por ordem de importância?', 'Organizar tarefas por ordem de importância é priorizar: decidir o que fazer primeiro, segundo o valor ou a urgência de cada tarefa. Ignorar, cancelar ou sortear tarefas não é organizar.'),
    ('seed_produtividade_facil_v4', 'Qual é uma boa prática antes de iniciar um projeto?', 'Antes de iniciar um projeto, é boa prática definir os objetivos e as etapas principais. Assim a equipe sabe aonde quer chegar e por onde começar, e evita retrabalho mais tarde.'),
    ('seed_produtividade_facil_v4', 'O que é produtividade?', 'Produtividade é a capacidade de utilizar recursos e tempo de forma eficaz para alcançar resultados. Não mede apenas as horas trabalhadas, mas o que realmente se consegue concluir com o que se tem.'),
    ('seed_produtividade_facil_v4', 'Uma pessoa termina uma tarefa importante antes de começar outra. Qual princípio está aplicando?', 'Quem termina uma tarefa importante antes de começar outra está aplicando a priorização: escolher o que é mais importante e concentrar-se nisso. Distração, procrastinação e improvisação vão no sentido contrário.'),
    ('seed_produtividade_facil_v4', 'O que é um lembrete?', 'Um lembrete é um aviso destinado a ajudar alguém a recordar uma atividade ou compromisso. Pode ser um alarme, uma notificação ou uma nota, e evita que se esqueça o que foi combinado.'),
    ('seed_produtividade_facil_v4', 'Qual ferramenta pode ajudar a lembrar uma reunião marcada para determinada hora?', 'O alarme ou lembrete avisa na hora certa e ajuda a não esquecer uma reunião marcada. Editores de fotografias, calculadoras e leitores de música não têm essa função.'),
    ('seed_produtividade_facil_v4', 'Qual é uma vantagem de nomear corretamente arquivos?', 'Nomear corretamente os arquivos facilita a identificação e a localização posterior. Com nomes claros, encontra-se o documento certo em segundos, sem abrir um por um.'),
    ('seed_produtividade_facil_v4', 'O que é uma pausa?', 'Pausa é um período curto de interrupção planejada de uma atividade, para descansar a mente e o corpo. Não é uma tarefa, nem uma meta ou um prazo.'),
    ('seed_produtividade_facil_v4', 'Por que pausas adequadas podem ser úteis durante períodos prolongados de trabalho?', 'Pausas adequadas podem ajudar a recuperar a atenção e a reduzir a fadiga em períodos prolongados de trabalho. Depois de descansar um pouco, a concentração costuma voltar e o trabalho rende mais.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Produtividade fácil lote 3: perguntas 1 a 25 do seed v4 (migration 087): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
