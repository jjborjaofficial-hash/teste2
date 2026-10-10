-- Alternativas (BE-003, regularização) — Produtividade difícil lote 1: perguntas 1 a 24 do seed v1 (migration 044) e a 1 do seed v2 (migration 078).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Produtividade usa a faixa de migrations 200+
-- (difícil: 260 a 267) para não colidir com as outras categorias (Finanças 144+, Tecnologia 300+, IA 400+, Marketing Digital 500+).
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
    ('seed_produtividade_dificil_v1', 'O que é a Lei de Parkinson?', 0, 'Método de investimento', 'Teoria que explica como o investimento em ferramentas acelera a conclusão das tarefas'),
    ('seed_produtividade_dificil_v1', 'O que é a Lei de Parkinson?', 2, 'Técnica de memorização', 'Técnica que ajuda a memorizar listas de tarefas por meio de associações visuais'),
    ('seed_produtividade_dificil_v1', 'O que é a Lei de Parkinson?', 3, 'Regra que determina o salário mínimo', 'Regra de gestão que define a duração ideal das reuniões de uma equipe de trabalho'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 0, 'Prazos longos sempre aumentam a produtividade', 'Prazos mais longos aumentam a produtividade porque dão mais tempo para revisar o trabalho'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 1, 'Quanto maior o prazo, menor será sempre o esforço', 'Quanto maior for o prazo, menor é a necessidade de planejar as etapas do projeto'),
    ('seed_produtividade_dificil_v1', 'Como a Lei de Parkinson pode influenciar o planejamento?', 3, 'Prazos não influenciam comportamento', 'Os prazos não influenciam o ritmo nem a forma como as pessoas organizam o trabalho'),
    ('seed_produtividade_dificil_v1', 'O que é custo de contexto?', 0, 'Preço de um aplicativo', 'Valor cobrado pelos aplicativos de gestão para organizar o contexto das tarefas de uma equipe'),
    ('seed_produtividade_dificil_v1', 'O que é custo de contexto?', 1, 'Custo de internet', 'Gasto adicional de internet causado pelo uso simultâneo de vários aplicativos e plataformas de trabalho ao longo do dia'),
    ('seed_produtividade_dificil_v1', 'O que é custo de contexto?', 2, 'Valor de uma reunião', 'Valor gasto com reuniões de alinhamento em que se discute o contexto de cada projeto da empresa'),
    ('seed_produtividade_dificil_v1', 'Qual estratégia pode reduzir o custo de contexto?', 1, 'Trabalhar sem prioridades', 'Resolver as tarefas conforme aparecem, sem as agrupar'),
    ('seed_produtividade_dificil_v1', 'Qual estratégia pode reduzir o custo de contexto?', 2, 'Manter várias atividades abertas sem necessidade', 'Manter várias atividades abertas ao mesmo tempo'),
    ('seed_produtividade_dificil_v1', 'Qual estratégia pode reduzir o custo de contexto?', 3, 'Alternar tarefas a cada minuto', 'Alternar tarefas com frequência'),
    ('seed_produtividade_dificil_v1', 'O que é trabalho profundo?', 1, 'Trabalho realizado sem planejamento', 'Trabalho de rotina feito em ritmo constante, com tarefas simples e repetitivas, que exigem pouca decisão'),
    ('seed_produtividade_dificil_v1', 'O que é trabalho profundo?', 2, 'Trabalho realizado exclusivamente de madrugada', 'Trabalho feito em grupo, com reuniões curtas e frequentes ao longo do dia para alinhar as tarefas'),
    ('seed_produtividade_dificil_v1', 'O que é trabalho profundo?', 3, 'Trabalho físico pesado', 'Trabalho que exige muito esforço físico e pouca concentração mental, feito em turnos longos'),
    ('seed_produtividade_dificil_v1', 'O que é carga cognitiva?', 0, 'Quantidade de dinheiro disponível', 'Quantidade de recursos financeiros que a empresa precisa investir em cada tarefa'),
    ('seed_produtividade_dificil_v1', 'O que é carga cognitiva?', 2, 'Velocidade da internet', 'Velocidade com que a internet transmite as informações usadas na realização do trabalho'),
    ('seed_produtividade_dificil_v1', 'O que é carga cognitiva?', 3, 'Número de funcionários', 'Número de pessoas necessárias para executar as tarefas de um projeto no prazo'),
    ('seed_produtividade_dificil_v1', 'Por que dividir informações complexas em partes pode ajudar?', 0, 'Porque torna qualquer assunto simples automaticamente', 'Pode tornar o assunto mais curto e reduzir o tempo gasto com leitura'),
    ('seed_produtividade_dificil_v1', 'Por que dividir informações complexas em partes pode ajudar?', 2, 'Porque reduz o conteúdo disponível', 'Pode reduzir o conteúdo disponível e diminuir o que precisa ser estudado'),
    ('seed_produtividade_dificil_v1', 'Por que dividir informações complexas em partes pode ajudar?', 3, 'Porque elimina a necessidade de aprendizagem', 'Pode dispensar a necessidade de revisão e de prática posterior'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 0, 'Técnica de vendas', 'Técnica de vendas usada para fechar negócios com clientes'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 1, 'Meta financeira', 'Meta financeira definida para o fim de cada período do ano'),
    ('seed_produtividade_dificil_v1', 'O que é intenção de implementação?', 2, 'Lista de compras', 'Lista de compras mensal'),
    ('seed_produtividade_dificil_v1', 'Por que uma intenção de implementação pode ajudar na execução?', 1, 'Elimina todos os imprevistos', 'Evita que imprevistos surjam durante a execução das tarefas planejadas'),
    ('seed_produtividade_dificil_v1', 'Por que uma intenção de implementação pode ajudar na execução?', 2, 'Garante sucesso absoluto', 'Aumenta o número de tarefas que podem ser feitas em um mesmo dia'),
    ('seed_produtividade_dificil_v1', 'Por que uma intenção de implementação pode ajudar na execução?', 3, 'Remove a necessidade de ação', 'Dispensa o esforço de decidir qual tarefa fazer em cada momento'),
    ('seed_produtividade_dificil_v1', 'O que é efeito Zeigarnik?', 0, 'Sistema de arquivos', 'Sistema usado para organizar arquivos e lembretes de tarefas já concluídas pela equipe do projeto'),
    ('seed_produtividade_dificil_v1', 'O que é efeito Zeigarnik?', 1, 'Método financeiro', 'Método financeiro que consiste em registrar as despesas pendentes de cada mês e comparar com o orçamento'),
    ('seed_produtividade_dificil_v1', 'O que é efeito Zeigarnik?', 3, 'Técnica de vendas', 'Técnica de vendas baseada em lembrar o cliente de pedidos que ficaram incompletos no carrinho de compras'),
    ('seed_produtividade_dificil_v1', 'Como o efeito Zeigarnik pode afetar a produtividade?', 1, 'Tarefas pendentes desaparecem da memória', 'Tarefas pendentes deixam de ser lembradas depois de algumas horas'),
    ('seed_produtividade_dificil_v1', 'Como o efeito Zeigarnik pode afetar a produtividade?', 2, 'Tarefas incompletas sempre aumentam a produtividade', 'Tarefas incompletas podem aumentar a produtividade quando estão em maior número'),
    ('seed_produtividade_dificil_v1', 'Como o efeito Zeigarnik pode afetar a produtividade?', 3, 'Tarefas incompletas não possuem qualquer impacto', 'Tarefas incompletas afetam a memória de longo prazo, mas não a atenção'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 1, 'Controle de salários', 'Controle dos salários e dos benefícios pagos à equipe de trabalho em cada período do ano'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 2, 'Definição de senhas', 'Definição das senhas e dos acessos de cada membro da equipe aos sistemas e às ferramentas da empresa'),
    ('seed_produtividade_dificil_v1', 'O que é planejamento de capacidade?', 3, 'Planejamento de compras', 'Planejamento das compras de materiais e equipamentos necessários à execução do projeto no prazo'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 0, 'Porque elimina interrupções', 'Porque reduz o tempo de planejamento, mas aumenta o número de tarefas concluídas'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 1, 'Porque reduz a quantidade de trabalho', 'Porque reduz a quantidade de reuniões, mas aumenta o tempo gasto com e-mails'),
    ('seed_produtividade_dificil_v1', 'Por que sobrecarregar uma agenda pode reduzir a produtividade?', 2, 'Porque aumenta automaticamente a concentração', 'Porque aumenta o foco nas tarefas urgentes e deixa as tarefas importantes sem prazo'),
    ('seed_produtividade_dificil_v1', 'O que é gargalo em um processo?', 0, 'Um objetivo pessoal', 'Um objetivo definido para a equipe no início de cada etapa do processo'),
    ('seed_produtividade_dificil_v1', 'O que é gargalo em um processo?', 1, 'Uma pausa planejada', 'Uma pausa planejada entre duas etapas para evitar o cansaço da equipe'),
    ('seed_produtividade_dificil_v1', 'O que é gargalo em um processo?', 3, 'Etapa mais rápida', 'Etapa mais rápida do processo, que costuma ficar parada à espera das demais'),
    ('seed_produtividade_dificil_v1', 'Por que identificar gargalos é importante?', 1, 'Porque todos os processos dependem apenas da primeira etapa', 'Melhorar as etapas mais rápidas pode aumentar o desempenho geral do processo'),
    ('seed_produtividade_dificil_v1', 'Por que identificar gargalos é importante?', 2, 'Porque torna qualquer tarefa automática', 'Aumentar o número de etapas pode reduzir o tempo total do processo'),
    ('seed_produtividade_dificil_v1', 'Por que identificar gargalos é importante?', 3, 'Porque elimina todos os funcionários', 'Reduzir a equipe das etapas mais lentas pode aumentar a velocidade geral'),
    ('seed_produtividade_dificil_v1', 'O que é otimização prematura?', 0, 'Criar uma rotina', 'Criar uma rotina de trabalho antes de conhecer as necessidades da equipe'),
    ('seed_produtividade_dificil_v1', 'O que é otimização prematura?', 1, 'Planejar corretamente uma tarefa', 'Planejar uma tarefa com antecedência, antes de começar a executá-la'),
    ('seed_produtividade_dificil_v1', 'O que é otimização prematura?', 2, 'Definir prioridades', 'Definir as prioridades do dia antes de analisar o que é mais urgente'),
    ('seed_produtividade_dificil_v1', 'Por que a otimização prematura pode ser prejudicial?', 0, 'Porque produtividade não pode ser melhorada', 'Pode gerar custos com ferramentas novas que a equipe ainda não sabe usar bem'),
    ('seed_produtividade_dificil_v1', 'Por que a otimização prematura pode ser prejudicial?', 2, 'Porque planejamento nunca funciona', 'Pode obrigar a equipe a trabalhar em ordem diferente da que foi planejada'),
    ('seed_produtividade_dificil_v1', 'Por que a otimização prematura pode ser prejudicial?', 3, 'Porque toda otimização é inútil', 'Pode melhorar demais um processo e, com isso, tornar as demais etapas desnecessárias para a empresa'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 0, 'Método de controle financeiro obrigatório', 'Método de controle financeiro em que 80% do orçamento deve ser destinado às despesas fixas e 20% às despesas variáveis de cada mês'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 1, 'Regra matemática universal de que tudo será exatamente 80/20', 'Regra de que 80% do tempo de trabalho deve ser dedicado a reuniões e 20% à execução das tarefas planejadas pela equipe'),
    ('seed_produtividade_dificil_v1', 'O que é princípio 80/20, também conhecido como princípio de Pareto?', 2, 'Técnica exclusiva de estudos', 'Técnica de estudo que recomenda dedicar 80% do tempo à leitura de novos conteúdos e 20% à revisão do que já foi aprendido'),
    ('seed_produtividade_dificil_v1', 'Como o princípio 80/20 pode ser aplicado à produtividade?', 0, 'Eliminando 20% de todas as tarefas automaticamente', 'Eliminando 20% das tarefas de cada dia, sem analisar o resultado de cada uma'),
    ('seed_produtividade_dificil_v1', 'Como o princípio 80/20 pode ser aplicado à produtividade?', 1, 'Fazendo somente quatro tarefas por dia', 'Limitando o dia a quatro tarefas, escolhidas ao acaso entre as pendentes'),
    ('seed_produtividade_dificil_v1', 'Como o princípio 80/20 pode ser aplicado à produtividade?', 3, 'Trabalhando exatamente 80% do dia', 'Reservando 80% do dia para reuniões e 20% para as tarefas de maior prioridade'),
    ('seed_produtividade_dificil_v1', 'O que significa trabalhar de forma eficiente?', 0, 'Trabalhar o maior número possível de horas', 'Dedicar o maior número de horas possível ao trabalho para concluir mais tarefas'),
    ('seed_produtividade_dificil_v1', 'O que significa trabalhar de forma eficiente?', 1, 'Fazer várias tarefas ao mesmo tempo', 'Realizar várias tarefas ao mesmo tempo para reduzir o tempo total de trabalho'),
    ('seed_produtividade_dificil_v1', 'O que significa trabalhar de forma eficiente?', 3, 'Nunca descansar', 'Evitar pausas durante o dia para manter o ritmo de trabalho constante'),
    ('seed_produtividade_dificil_v1', 'Qual é a diferença entre eficiência e eficácia?', 0, 'São exatamente iguais', 'São termos equivalentes, que descrevem a mesma capacidade de concluir tarefas rapidamente'),
    ('seed_produtividade_dificil_v1', 'Qual é a diferença entre eficiência e eficácia?', 1, 'Eficiência significa trabalhar mais horas', 'Eficiência está relacionada à quantidade de horas trabalhadas; eficácia está relacionada ao número de tarefas concluídas'),
    ('seed_produtividade_dificil_v1', 'Qual é a diferença entre eficiência e eficácia?', 3, 'Eficácia significa trabalhar sem planejamento', 'Eficácia está relacionada à rapidez na execução; eficiência, à escolha dos objetivos a alcançar'),
    ('seed_produtividade_dificil_v1', 'Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 0, 'Todas as tarefas possuem o mesmo valor', 'Pode demonstrar que as tarefas concluídas têm valor semelhante para o objetivo principal'),
    ('seed_produtividade_dificil_v1', 'Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 2, 'A pessoa necessariamente é altamente produtiva', 'Pode indicar que a pessoa está alcançando bons resultados com o objetivo principal'),
    ('seed_produtividade_dificil_v1', 'Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 3, 'A quantidade de tarefas garante resultados', 'Pode mostrar que a quantidade de tarefas concluídas é o melhor indicador de progresso'),
    ('seed_produtividade_dificil_v1', 'O que é melhoria contínua?', 0, 'Trabalho sem avaliação', 'Trabalho feito sem avaliação periódica dos resultados obtidos pela equipe'),
    ('seed_produtividade_dificil_v1', 'O que é melhoria contínua?', 1, 'Mudança completa diária sem análise', 'Mudança completa dos métodos de trabalho a cada dia, sem análise prévia'),
    ('seed_produtividade_dificil_v1', 'O que é melhoria contínua?', 2, 'Eliminação de todas as rotinas', 'Eliminação das rotinas de trabalho que a equipe já tem consolidadas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui 20 tarefas, mas apenas cinco contribuem diretamente para o objetivo principal do projeto. Qual abordagem é mais adequada?', 0, 'Delegar todas as tarefas simultaneamente', 'Delegar as 20 tarefas a pessoas diferentes ao mesmo tempo'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui 20 tarefas, mas apenas cinco contribuem diretamente para o objetivo principal do projeto. Qual abordagem é mais adequada?', 1, 'Distribuir o tempo igualmente pelas 20 tarefas', 'Distribuir o tempo de forma igual entre as 20 tarefas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa possui 20 tarefas, mas apenas cinco contribuem diretamente para o objetivo principal do projeto. Qual abordagem é mais adequada?', 3, 'Começar pelas tarefas mais rápidas', 'Começar pelas tarefas mais rápidas de concluir')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade difícil lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
