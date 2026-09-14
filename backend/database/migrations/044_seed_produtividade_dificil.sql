-- Migration/seed: conteúdo Produtividade, nível Difícil (24 de 25 perguntas)
-- Fonte: lote de 80 perguntas de Produtividade fornecido pelo proprietário do
-- projeto (perguntas 56–79 do lote, marcadas como "Difícil"). Ver
-- 012_produtividade_facil.sql para o contexto completo do lote.
--
-- ⚠️ INCOMPLETO DE PROPÓSITO: a pergunta 80 (última do lote, também nível
-- Difícil) veio cortada no documento recebido — a alternativa B termina em
-- "Fazer o" e faltam C, D, Resposta e Dificuldade. Ela NÃO foi inserida aqui
-- para evitar conteúdo inventado ou incompleto no quiz. Quando o texto
-- completo da pergunta 80 for enviado, criar um seed adicional (015) só para
-- ela, seguindo este mesmo padrão.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores,
-- não é decisão de negócio): respostas corretas originalmente TODAS "A" —
-- posição redistribuída com seed fixa (53 — distinta das seeds 42 a 52 já
-- usadas) e distribuição controlada entre A/B/C/D, reprodutível — conteúdo
-- pedagógico inalterado, só a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'produtividade';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "produtividade" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_produtividade_dificil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_produtividade_dificil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_prod_dificil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_produtividade_dificil_v1'
    FROM (VALUES
      ('O que é a Lei de Parkinson?'),
      ('Como a Lei de Parkinson pode influenciar o planejamento?'),
      ('O que é custo de contexto?'),
      ('Qual estratégia pode reduzir o custo de contexto?'),
      ('O que é trabalho profundo?'),
      ('Qual é um obstáculo comum ao trabalho profundo?'),
      ('O que é carga cognitiva?'),
      ('Por que dividir informações complexas em partes pode ajudar?'),
      ('O que é intenção de implementação?'),
      ('Por que uma intenção de implementação pode ajudar na execução?'),
      ('O que é efeito Zeigarnik?'),
      ('Como o efeito Zeigarnik pode afetar a produtividade?'),
      ('O que é planejamento de capacidade?'),
      ('Por que sobrecarregar uma agenda pode reduzir a produtividade?'),
      ('O que é gargalo em um processo?'),
      ('Por que identificar gargalos é importante?'),
      ('O que é otimização prematura?'),
      ('Por que a otimização prematura pode ser prejudicial?'),
      ('O que é princípio 80/20, também conhecido como princípio de Pareto?'),
      ('Como o princípio 80/20 pode ser aplicado à produtividade?'),
      ('O que significa trabalhar de forma eficiente?'),
      ('Qual é a diferença entre eficiência e eficácia?'),
      ('Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?'),
      ('O que é melhoria contínua?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_prod_dificil q
    JOIN (VALUES
      ('O que é a Lei de Parkinson?', 'Método de investimento', FALSE, 0),
      ('O que é a Lei de Parkinson?', 'Ideia de que o trabalho tende a expandir-se para preencher o tempo disponível para sua realização', TRUE, 1),
      ('O que é a Lei de Parkinson?', 'Técnica de memorização', FALSE, 2),
      ('O que é a Lei de Parkinson?', 'Regra que determina o salário mínimo', FALSE, 3),
      ('Como a Lei de Parkinson pode influenciar o planejamento?', 'Prazos longos sempre aumentam a produtividade', FALSE, 0),
      ('Como a Lei de Parkinson pode influenciar o planejamento?', 'Quanto maior o prazo, menor será sempre o esforço', FALSE, 1),
      ('Como a Lei de Parkinson pode influenciar o planejamento?', 'Prazos excessivamente longos podem favorecer a expansão desnecessária do trabalho', TRUE, 2),
      ('Como a Lei de Parkinson pode influenciar o planejamento?', 'Prazos não influenciam comportamento', FALSE, 3),
      ('O que é custo de contexto?', 'Preço de um aplicativo', FALSE, 0),
      ('O que é custo de contexto?', 'Custo de internet', FALSE, 1),
      ('O que é custo de contexto?', 'Valor de uma reunião', FALSE, 2),
      ('O que é custo de contexto?', 'Perda de eficiência causada pela necessidade de mudar o contexto mental entre diferentes tipos de tarefa', TRUE, 3),
      ('Qual estratégia pode reduzir o custo de contexto?', 'Agrupar tarefas semelhantes em blocos', TRUE, 0),
      ('Qual estratégia pode reduzir o custo de contexto?', 'Trabalhar sem prioridades', FALSE, 1),
      ('Qual estratégia pode reduzir o custo de contexto?', 'Manter várias atividades abertas sem necessidade', FALSE, 2),
      ('Qual estratégia pode reduzir o custo de contexto?', 'Alternar tarefas a cada minuto', FALSE, 3),
      ('O que é trabalho profundo?', 'Período de concentração intensa em uma atividade cognitivamente exigente, com poucas distrações', TRUE, 0),
      ('O que é trabalho profundo?', 'Trabalho realizado sem planejamento', FALSE, 1),
      ('O que é trabalho profundo?', 'Trabalho realizado exclusivamente de madrugada', FALSE, 2),
      ('O que é trabalho profundo?', 'Trabalho físico pesado', FALSE, 3),
      ('Qual é um obstáculo comum ao trabalho profundo?', 'Períodos protegidos de concentração', FALSE, 0),
      ('Qual é um obstáculo comum ao trabalho profundo?', 'Interrupções frequentes', TRUE, 1),
      ('Qual é um obstáculo comum ao trabalho profundo?', 'Ambiente organizado', FALSE, 2),
      ('Qual é um obstáculo comum ao trabalho profundo?', 'Objetivos claros', FALSE, 3),
      ('O que é carga cognitiva?', 'Quantidade de dinheiro disponível', FALSE, 0),
      ('O que é carga cognitiva?', 'Quantidade de informação e esforço mental que a memória de trabalho precisa processar', TRUE, 1),
      ('O que é carga cognitiva?', 'Velocidade da internet', FALSE, 2),
      ('O que é carga cognitiva?', 'Número de funcionários', FALSE, 3),
      ('Por que dividir informações complexas em partes pode ajudar?', 'Porque torna qualquer assunto simples automaticamente', FALSE, 0),
      ('Por que dividir informações complexas em partes pode ajudar?', 'Pode reduzir a carga cognitiva e facilitar o processamento', TRUE, 1),
      ('Por que dividir informações complexas em partes pode ajudar?', 'Porque reduz o conteúdo disponível', FALSE, 2),
      ('Por que dividir informações complexas em partes pode ajudar?', 'Porque elimina a necessidade de aprendizagem', FALSE, 3),
      ('O que é intenção de implementação?', 'Técnica de vendas', FALSE, 0),
      ('O que é intenção de implementação?', 'Meta financeira', FALSE, 1),
      ('O que é intenção de implementação?', 'Lista de compras', FALSE, 2),
      ('O que é intenção de implementação?', 'Planejamento no formato "se acontecer X, então farei Y"', TRUE, 3),
      ('Por que uma intenção de implementação pode ajudar na execução?', 'Converte uma situação prevista em uma resposta previamente definida', TRUE, 0),
      ('Por que uma intenção de implementação pode ajudar na execução?', 'Elimina todos os imprevistos', FALSE, 1),
      ('Por que uma intenção de implementação pode ajudar na execução?', 'Garante sucesso absoluto', FALSE, 2),
      ('Por que uma intenção de implementação pode ajudar na execução?', 'Remove a necessidade de ação', FALSE, 3),
      ('O que é efeito Zeigarnik?', 'Sistema de arquivos', FALSE, 0),
      ('O que é efeito Zeigarnik?', 'Método financeiro', FALSE, 1),
      ('O que é efeito Zeigarnik?', 'Tendência de tarefas incompletas permanecerem mais acessíveis na memória do que algumas tarefas concluídas', TRUE, 2),
      ('O que é efeito Zeigarnik?', 'Técnica de vendas', FALSE, 3),
      ('Como o efeito Zeigarnik pode afetar a produtividade?', 'Pendências mal organizadas podem continuar ocupando atenção mental', TRUE, 0),
      ('Como o efeito Zeigarnik pode afetar a produtividade?', 'Tarefas pendentes desaparecem da memória', FALSE, 1),
      ('Como o efeito Zeigarnik pode afetar a produtividade?', 'Tarefas incompletas sempre aumentam a produtividade', FALSE, 2),
      ('Como o efeito Zeigarnik pode afetar a produtividade?', 'Tarefas incompletas não possuem qualquer impacto', FALSE, 3),
      ('O que é planejamento de capacidade?', 'Avaliação de quanto trabalho pode ser realisticamente realizado com os recursos e tempo disponíveis', TRUE, 0),
      ('O que é planejamento de capacidade?', 'Controle de salários', FALSE, 1),
      ('O que é planejamento de capacidade?', 'Definição de senhas', FALSE, 2),
      ('O que é planejamento de capacidade?', 'Planejamento de compras', FALSE, 3),
      ('Por que sobrecarregar uma agenda pode reduzir a produtividade?', 'Porque elimina interrupções', FALSE, 0),
      ('Por que sobrecarregar uma agenda pode reduzir a produtividade?', 'Porque reduz a quantidade de trabalho', FALSE, 1),
      ('Por que sobrecarregar uma agenda pode reduzir a produtividade?', 'Porque aumenta automaticamente a concentração', FALSE, 2),
      ('Por que sobrecarregar uma agenda pode reduzir a produtividade?', 'Porque diminui a margem para imprevistos, aumenta pressão e pode gerar atrasos', TRUE, 3),
      ('O que é gargalo em um processo?', 'Um objetivo pessoal', FALSE, 0),
      ('O que é gargalo em um processo?', 'Uma pausa planejada', FALSE, 1),
      ('O que é gargalo em um processo?', 'Etapa que limita ou reduz a capacidade de fluxo de todo o processo', TRUE, 2),
      ('O que é gargalo em um processo?', 'Etapa mais rápida', FALSE, 3),
      ('Por que identificar gargalos é importante?', 'Melhorar o gargalo pode aumentar o desempenho geral do processo', TRUE, 0),
      ('Por que identificar gargalos é importante?', 'Porque todos os processos dependem apenas da primeira etapa', FALSE, 1),
      ('Por que identificar gargalos é importante?', 'Porque torna qualquer tarefa automática', FALSE, 2),
      ('Por que identificar gargalos é importante?', 'Porque elimina todos os funcionários', FALSE, 3),
      ('O que é otimização prematura?', 'Criar uma rotina', FALSE, 0),
      ('O que é otimização prematura?', 'Planejar corretamente uma tarefa', FALSE, 1),
      ('O que é otimização prematura?', 'Definir prioridades', FALSE, 2),
      ('O que é otimização prematura?', 'Tentar otimizar detalhes antes de compreender ou resolver os problemas mais relevantes', TRUE, 3),
      ('Por que a otimização prematura pode ser prejudicial?', 'Porque produtividade não pode ser melhorada', FALSE, 0),
      ('Por que a otimização prematura pode ser prejudicial?', 'Pode consumir tempo em melhorias de baixo impacto enquanto problemas importantes permanecem', TRUE, 1),
      ('Por que a otimização prematura pode ser prejudicial?', 'Porque planejamento nunca funciona', FALSE, 2),
      ('Por que a otimização prematura pode ser prejudicial?', 'Porque toda otimização é inútil', FALSE, 3),
      ('O que é princípio 80/20, também conhecido como princípio de Pareto?', 'Método de controle financeiro obrigatório', FALSE, 0),
      ('O que é princípio 80/20, também conhecido como princípio de Pareto?', 'Regra matemática universal de que tudo será exatamente 80/20', FALSE, 1),
      ('O que é princípio 80/20, também conhecido como princípio de Pareto?', 'Técnica exclusiva de estudos', FALSE, 2),
      ('O que é princípio 80/20, também conhecido como princípio de Pareto?', 'Ideia de que uma parcela relativamente pequena de causas pode responder por uma parcela significativa dos resultados em determinados contextos', TRUE, 3),
      ('Como o princípio 80/20 pode ser aplicado à produtividade?', 'Eliminando 20% de todas as tarefas automaticamente', FALSE, 0),
      ('Como o princípio 80/20 pode ser aplicado à produtividade?', 'Fazendo somente quatro tarefas por dia', FALSE, 1),
      ('Como o princípio 80/20 pode ser aplicado à produtividade?', 'Identificando atividades que geram grande parte dos resultados desejados', TRUE, 2),
      ('Como o princípio 80/20 pode ser aplicado à produtividade?', 'Trabalhando exatamente 80% do dia', FALSE, 3),
      ('O que significa trabalhar de forma eficiente?', 'Trabalhar o maior número possível de horas', FALSE, 0),
      ('O que significa trabalhar de forma eficiente?', 'Fazer várias tarefas ao mesmo tempo', FALSE, 1),
      ('O que significa trabalhar de forma eficiente?', 'Utilizar recursos e tempo de maneira adequada para alcançar um resultado', TRUE, 2),
      ('O que significa trabalhar de forma eficiente?', 'Nunca descansar', FALSE, 3),
      ('Qual é a diferença entre eficiência e eficácia?', 'São exatamente iguais', FALSE, 0),
      ('Qual é a diferença entre eficiência e eficácia?', 'Eficiência significa trabalhar mais horas', FALSE, 1),
      ('Qual é a diferença entre eficiência e eficácia?', 'Eficiência está relacionada ao uso adequado dos recursos; eficácia está relacionada a alcançar o resultado pretendido', TRUE, 2),
      ('Qual é a diferença entre eficiência e eficácia?', 'Eficácia significa trabalhar sem planejamento', FALSE, 3),
      ('Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 'Todas as tarefas possuem o mesmo valor', FALSE, 0),
      ('Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 'Pode haver eficiência operacional sem eficácia em relação ao objetivo', TRUE, 1),
      ('Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 'A pessoa necessariamente é altamente produtiva', FALSE, 2),
      ('Uma pessoa conclui muitas tarefas, mas quase nenhuma contribui para seu objetivo principal. O que isso demonstra?', 'A quantidade de tarefas garante resultados', FALSE, 3),
      ('O que é melhoria contínua?', 'Trabalho sem avaliação', FALSE, 0),
      ('O que é melhoria contínua?', 'Mudança completa diária sem análise', FALSE, 1),
      ('O que é melhoria contínua?', 'Eliminação de todas as rotinas', FALSE, 2),
      ('O que é melhoria contínua?', 'Processo de avaliar e aperfeiçoar gradualmente métodos e resultados', TRUE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_prod_dificil;

    RAISE NOTICE '24 perguntas inseridas com sucesso (source=seed_produtividade_dificil_v1).';
  END IF;
END $$;

COMMIT;
