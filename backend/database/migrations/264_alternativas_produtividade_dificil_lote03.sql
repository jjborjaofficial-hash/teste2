-- Alternativas (BE-003, regularização) — Produtividade difícil lote 3: 25 perguntas seguintes do seed v2 (v2#27 a v2#51, migration 078).
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
    ('seed_produtividade_dificil_v2', 'Uma reunião termina sem decisões, responsáveis ou prazos. Qual é uma das principais falhas?', 0, 'Excesso de prioridades', 'Excesso de prioridades definidas'),
    ('seed_produtividade_dificil_v2', 'Uma reunião termina sem decisões, responsáveis ou prazos. Qual é uma das principais falhas?', 1, 'Excesso de documentação', 'Excesso de documentação gerada'),
    ('seed_produtividade_dificil_v2', 'Uma reunião termina sem decisões, responsáveis ou prazos. Qual é uma das principais falhas?', 2, 'Automação inadequada', 'Automação inadequada dos processos'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa recebe uma tarefa vaga: "Melhorar o relatório". Qual pergunta ajudaria a transformar a tarefa em algo executável?', 0, '"Quando teremos outra reunião?"', '"Quando será a próxima reunião de equipa?"'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa recebe uma tarefa vaga: "Melhorar o relatório". Qual pergunta ajudaria a transformar a tarefa em algo executável?', 1, '"Quantas mensagens recebeste?"', '"Quantas mensagens recebeste sobre o relatório?"'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa recebe uma tarefa vaga: "Melhorar o relatório". Qual pergunta ajudaria a transformar a tarefa em algo executável?', 2, '"Qual aplicação utilizas?"', '"Qual aplicação utilizas para escrever relatórios?"'),
    ('seed_produtividade_dificil_v2', 'O que é ambiguidade de tarefa?', 0, 'Quando uma tarefa é automatizada', 'Quando uma tarefa é automatizada sem que a equipa saiba como funciona o processo'),
    ('seed_produtividade_dificil_v2', 'O que é ambiguidade de tarefa?', 1, 'Quando a tarefa possui prazo', 'Quando a tarefa possui um prazo que depende da decisão de outra pessoa'),
    ('seed_produtividade_dificil_v2', 'O que é ambiguidade de tarefa?', 2, 'Quando existem recursos disponíveis', 'Quando existem recursos disponíveis, mas ninguém sabe quem os deve utilizar'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa continua sendo refeita porque o responsável recebe instruções diferentes de várias pessoas. Qual problema existe?', 0, 'Baixa quantidade de tarefas', 'Quantidade de tarefas inferior à capacidade do responsável'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa continua sendo refeita porque o responsável recebe instruções diferentes de várias pessoas. Qual problema existe?', 1, 'Excesso de descanso', 'Excesso de pausas e de descanso durante o horário de trabalho'),
    ('seed_produtividade_dificil_v2', 'Uma tarefa continua sendo refeita porque o responsável recebe instruções diferentes de várias pessoas. Qual problema existe?', 3, 'Excesso de clareza', 'Excesso de clareza nas instruções recebidas por cada pessoa'),
    ('seed_produtividade_dificil_v2', 'Qual é uma vantagem de definir um "responsável final" por uma atividade?', 0, 'Elimina a necessidade de colaboração', 'Elimina a necessidade de colaboração entre os membros da equipa'),
    ('seed_produtividade_dificil_v2', 'Qual é uma vantagem de definir um "responsável final" por uma atividade?', 2, 'Impede revisões', 'Impede revisões do trabalho por outras pessoas da equipa'),
    ('seed_produtividade_dificil_v2', 'Qual é uma vantagem de definir um "responsável final" por uma atividade?', 3, 'Garante que nenhum erro ocorrerá', 'Reduz a necessidade de comunicação entre a equipa e o gestor'),
    ('seed_produtividade_dificil_v2', 'Uma equipa começa novos projetos continuamente sem terminar os anteriores. Qual problema de gestão pode estar presente?', 2, 'Excesso de descanso', 'Excesso de pausas durante o dia'),
    ('seed_produtividade_dificil_v2', 'Uma equipa começa novos projetos continuamente sem terminar os anteriores. Qual problema de gestão pode estar presente?', 3, 'Falta de tarefas', 'Falta de tarefas para a equipa'),
    ('seed_produtividade_dificil_v2', 'O que significa limitar o trabalho em andamento?', 0, 'Aumentar todas as prioridades', 'Aumentar o número de prioridades definidas para a equipa'),
    ('seed_produtividade_dificil_v2', 'O que significa limitar o trabalho em andamento?', 1, 'Trabalhar somente numa tarefa durante toda a vida', 'Trabalhar numa só tarefa até ao fim do dia de trabalho'),
    ('seed_produtividade_dificil_v2', 'O que significa limitar o trabalho em andamento?', 3, 'Impedir qualquer atividade', 'Impedir que a equipa inicie atividades fora do plano anual'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mantém dez tarefas abertas porque "talvez sejam necessárias", embora apenas três sejam relevantes. Qual ação é mais produtiva?', 0, 'Evitar decisões', 'Evitar decidir quais tarefas manter'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mantém dez tarefas abertas porque "talvez sejam necessárias", embora apenas três sejam relevantes. Qual ação é mais produtiva?', 1, 'Aumentar os prazos', 'Aumentar os prazos das dez tarefas abertas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa mantém dez tarefas abertas porque "talvez sejam necessárias", embora apenas três sejam relevantes. Qual ação é mais produtiva?', 2, 'Adicionar mais sete', 'Adicionar mais sete tarefas ao quadro'),
    ('seed_produtividade_dificil_v2', 'Um profissional planeia uma tarefa para duas horas, mas ela geralmente leva quatro. O que deve fazer antes de alterar todo o calendário?', 0, 'Ignorar os dados', 'Ignorar os dados e manter as estimativas'),
    ('seed_produtividade_dificil_v2', 'Um profissional planeia uma tarefa para duas horas, mas ela geralmente leva quatro. O que deve fazer antes de alterar todo o calendário?', 2, 'Reduzir a qualidade', 'Reduzir a qualidade para caber nas duas horas'),
    ('seed_produtividade_dificil_v2', 'Um profissional planeia uma tarefa para duas horas, mas ela geralmente leva quatro. O que deve fazer antes de alterar todo o calendário?', 3, 'Duplicar todas as tarefas', 'Duplicar o tempo previsto para as tarefas seguintes'),
    ('seed_produtividade_dificil_v2', 'Por que registar o tempo real de execução pode melhorar o planejamento futuro?', 0, 'Elimina todos os imprevistos', 'Elimina os imprevistos durante a execução das tarefas'),
    ('seed_produtividade_dificil_v2', 'Por que registar o tempo real de execução pode melhorar o planejamento futuro?', 1, 'Garante velocidade constante', 'Aumenta a velocidade de execução das tarefas seguintes'),
    ('seed_produtividade_dificil_v2', 'Por que registar o tempo real de execução pode melhorar o planejamento futuro?', 2, 'Torna os prazos desnecessários', 'Torna os prazos desnecessários nas tarefas seguintes'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa sempre subestima pequenas tarefas que, somadas, ocupam várias horas. Qual conceito explica melhor o problema?', 0, 'Pausa programada', 'Pausa programada entre as tarefas pequenas'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa sempre subestima pequenas tarefas que, somadas, ocupam várias horas. Qual conceito explica melhor o problema?', 2, 'Delegação perfeita', 'Delegação das tarefas pequenas à equipa'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa sempre subestima pequenas tarefas que, somadas, ocupam várias horas. Qual conceito explica melhor o problema?', 3, 'Automação completa', 'Automação das tarefas de menor duração'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa passa duas horas por dia em atividades administrativas que poderiam ser automatizadas. Qual análise deve ser feita primeiro?', 0, 'Eliminar a atividade sem substituição', 'Eliminar a atividade administrativa sem analisar o impacto'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa passa duas horas por dia em atividades administrativas que poderiam ser automatizadas. Qual análise deve ser feita primeiro?', 2, 'Automatizar tudo imediatamente', 'Automatizar as atividades logo, sem medir o tempo gasto'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa passa duas horas por dia em atividades administrativas que poderiam ser automatizadas. Qual análise deve ser feita primeiro?', 3, 'Aumentar o tempo administrativo', 'Aumentar o tempo reservado para as atividades administrativas'),
    ('seed_produtividade_dificil_v2', 'Qual é o risco de otimizar uma tarefa isoladamente sem analisar o processo completo?', 0, 'Elimina gargalos automaticamente', 'Pode eliminar os gargalos do processo completo'),
    ('seed_produtividade_dificil_v2', 'Qual é o risco de otimizar uma tarefa isoladamente sem analisar o processo completo?', 1, 'Sempre aumenta a qualidade', 'Pode aumentar a qualidade do produto final'),
    ('seed_produtividade_dificil_v2', 'Qual é o risco de otimizar uma tarefa isoladamente sem analisar o processo completo?', 2, 'Sempre reduz o tempo total', 'Pode reduzir o tempo total de todas as etapas'),
    ('seed_produtividade_dificil_v2', 'Uma equipa reduz o tempo de produção de um produto, mas aumenta o tempo de espera antes da entrega. Qual conclusão é mais adequada?', 0, 'A etapa de produção deixou de ser importante', 'A etapa de produção deixou de ter relevância para o processo'),
    ('seed_produtividade_dificil_v2', 'Uma equipa reduz o tempo de produção de um produto, mas aumenta o tempo de espera antes da entrega. Qual conclusão é mais adequada?', 1, 'A produtividade global necessariamente melhorou', 'A produtividade global melhorou, porque a produção ficou mais rápida'),
    ('seed_produtividade_dificil_v2', 'Uma equipa reduz o tempo de produção de um produto, mas aumenta o tempo de espera antes da entrega. Qual conclusão é mais adequada?', 2, 'O tempo de espera não possui relevância', 'O tempo de espera tem pouca relevância para o resultado final'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma otimização local?', 0, 'Automatizar toda a organização', 'Automatizar o processo completo para reduzir o tempo total de execução'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma otimização local?', 1, 'Eliminar todas as etapas', 'Eliminar as etapas mais lentas sem analisar o resultado final'),
    ('seed_produtividade_dificil_v2', 'O que caracteriza uma otimização local?', 3, 'Melhorar todo o sistema simultaneamente', 'Melhorar o sistema inteiro ao mesmo tempo, com foco no resultado global'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza uma ferramenta sofisticada, mas ninguém sabe claramente quais são as prioridades. Qual conclusão é mais razoável?', 0, 'Mais ferramentas resolverão necessariamente o problema', 'Mais ferramentas devem resolver o problema da equipa'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza uma ferramenta sofisticada, mas ninguém sabe claramente quais são as prioridades. Qual conclusão é mais razoável?', 1, 'A ferramenta substitui a necessidade de planejamento', 'A ferramenta dispensa a definição de prioridades pela equipa'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza uma ferramenta sofisticada, mas ninguém sabe claramente quais são as prioridades. Qual conclusão é mais razoável?', 2, 'O problema é exclusivamente técnico', 'O problema é técnico e depende da qualidade da ferramenta'),
    ('seed_produtividade_dificil_v2', 'Qual princípio deve orientar a escolha de uma ferramenta de produtividade?', 0, 'Trocar de ferramenta semanalmente', 'Trocar de ferramenta quando surgir uma novidade no mercado'),
    ('seed_produtividade_dificil_v2', 'Qual princípio deve orientar a escolha de uma ferramenta de produtividade?', 1, 'Utilizar o maior número possível de ferramentas', 'Utilizar o maior número possível de ferramentas ao mesmo tempo'),
    ('seed_produtividade_dificil_v2', 'Qual princípio deve orientar a escolha de uma ferramenta de produtividade?', 3, 'Escolher a ferramenta mais complexa', 'Escolher a ferramenta com mais funcionalidades disponíveis'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza três aplicações diferentes para armazenar a mesma informação. Qual risco aumenta?', 0, 'Clareza automática', 'Clareza na informação'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza três aplicações diferentes para armazenar a mesma informação. Qual risco aumenta?', 2, 'Redução de duplicação', 'Redução da duplicação de dados'),
    ('seed_produtividade_dificil_v2', 'Uma equipa utiliza três aplicações diferentes para armazenar a mesma informação. Qual risco aumenta?', 3, 'Centralização', 'Centralização da informação'),
    ('seed_produtividade_dificil_v2', 'O que significa centralizar informações relevantes?', 1, 'Eliminar qualquer documentação', 'Eliminar a documentação interna para evitar ficheiros desatualizados'),
    ('seed_produtividade_dificil_v2', 'O que significa centralizar informações relevantes?', 2, 'Copiar tudo para vários locais', 'Copiar as informações importantes para vários locais diferentes'),
    ('seed_produtividade_dificil_v2', 'O que significa centralizar informações relevantes?', 3, 'Usar apenas mensagens instantâneas', 'Usar mensagens instantâneas para guardar e partilhar as informações'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa tem um objetivo para seis meses, mas nunca verifica seu progresso. Qual problema existe?', 1, 'Excesso de medição', 'Medição excessiva dos resultados'),
    ('seed_produtividade_dificil_v2', 'Uma pessoa tem um objetivo para seis meses, mas nunca verifica seu progresso. Qual problema existe?', 2, 'Excesso de revisão', 'Revisão excessiva do plano'),
    ('seed_produtividade_dificil_v2', 'Qual frequência de revisão é mais adequada para uma meta de longo prazo?', 0, 'A cada minuto', 'Diariamente, mesmo quando a meta é de longo prazo'),
    ('seed_produtividade_dificil_v2', 'Qual frequência de revisão é mais adequada para uma meta de longo prazo?', 2, 'Apenas no último dia', 'Só no último dia, para comparar com o resultado final'),
    ('seed_produtividade_dificil_v2', 'Qual frequência de revisão é mais adequada para uma meta de longo prazo?', 3, 'Nunca', 'Em intervalos aleatórios, sem relação com a meta'),
    ('seed_produtividade_dificil_v2', 'Uma meta está atrasada porque as condições externas mudaram significativamente. Qual comportamento demonstra boa gestão?', 1, 'Abandonar todos os objetivos', 'Abandonar a meta e definir outra do zero'),
    ('seed_produtividade_dificil_v2', 'Uma meta está atrasada porque as condições externas mudaram significativamente. Qual comportamento demonstra boa gestão?', 2, 'Ignorar os dados', 'Ignorar as mudanças e manter o esforço'),
    ('seed_produtividade_dificil_v2', 'Uma meta está atrasada porque as condições externas mudaram significativamente. Qual comportamento demonstra boa gestão?', 3, 'Manter o plano original independentemente das novas condições', 'Manter o plano original apesar das novas condições')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Produtividade difícil lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 64).', v_updated;
END $$;
