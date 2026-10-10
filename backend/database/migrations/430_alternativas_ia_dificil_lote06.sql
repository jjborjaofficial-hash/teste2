-- Alternativas (BE-003, regularização) — IA difícil lote 6: 10 perguntas ativas de IA difícil (seed_ia_dificil_v2, as 10 últimas por ordem de inserção, fechando o difícil) ainda sem explicação.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda; só o texto das
-- alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis, sem absolutos só nas erradas).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_ia_dificil_v2', 'O que é auditoria de algoritmos?', 0, 'Instalação de computadores', 'Avaliação dos custos para identificar poupanças, prazos e rentabilidade'),
    ('seed_ia_dificil_v2', 'O que é auditoria de algoritmos?', 2, 'Venda de softwares', 'Atualização dos modelos para corrigir erros, falhas e lentidão'),
    ('seed_ia_dificil_v2', 'O que é auditoria de algoritmos?', 3, 'Criação de algoritmos', 'Documentação dos modelos para registar versões, autores e datas'),
    ('seed_ia_dificil_v2', 'Como reduzir alucinações em modelos de linguagem?', 0, 'Desligando o modelo', 'Usando menos dados, instruções curtas e sistemas de compressão'),
    ('seed_ia_dificil_v2', 'Como reduzir alucinações em modelos de linguagem?', 1, 'Impedindo qualquer pergunta', 'Usando temperaturas altas, instruções vagas e respostas mais longas'),
    ('seed_ia_dificil_v2', 'Como reduzir alucinações em modelos de linguagem?', 2, 'Removendo todos os dados', 'Usando modelos maiores, instruções iguais e sistemas de cache'),
    ('seed_ia_dificil_v2', 'O que é compressão de modelos?', 1, 'Aumento do tamanho do modelo', 'Técnicas para aumentar precisão e capacidade de memória de modelos de IA'),
    ('seed_ia_dificil_v2', 'O que é compressão de modelos?', 2, 'Exclusão de treinamento', 'Técnicas para reduzir dados e tempo de treinamento de modelos de IA'),
    ('seed_ia_dificil_v2', 'O que é compressão de modelos?', 3, 'Criação de dados', 'Técnicas para gerar dados e exemplos de teste para modelos de IA'),
    ('seed_ia_dificil_v2', 'O que representa o peso em uma rede neural?', 0, 'Quantidade de arquivos', 'Valor que indica a quantidade de neurônios artificiais existentes em cada camada da rede'),
    ('seed_ia_dificil_v2', 'O que representa o peso em uma rede neural?', 1, 'Tamanho físico do computador', 'Valor que mede o erro de uma conexão entre neurônios artificiais'),
    ('seed_ia_dificil_v2', 'O que representa o peso em uma rede neural?', 2, 'Número de usuários', 'Valor que limita a saída de cada camada entre neurônios artificiais'),
    ('seed_ia_dificil_v2', 'Qual é um dos maiores desafios atuais da Inteligência Artificial?', 0, 'Eliminar todos os computadores', 'Garantir velocidade, custo, escala e lucro'),
    ('seed_ia_dificil_v2', 'Qual é um dos maiores desafios atuais da Inteligência Artificial?', 1, 'Impedir qualquer inovação', 'Garantir precisão, desempenho, rapidez e substituição de empregos'),
    ('seed_ia_dificil_v2', 'Qual é um dos maiores desafios atuais da Inteligência Artificial?', 2, 'Remover todos os dados', 'Garantir autonomia, criatividade, memória e consciência própria'),
    ('seed_ia_dificil_v2', 'O que é aprendizado contínuo?', 0, 'Exclusão de informações', 'Capacidade de um sistema esquecer dados antigos ao longo do tempo'),
    ('seed_ia_dificil_v2', 'O que é aprendizado contínuo?', 1, 'Sistema sem atualização', 'Capacidade de um sistema funcionar sem interrupções ao longo do tempo'),
    ('seed_ia_dificil_v2', 'O que é aprendizado contínuo?', 3, 'Modelo sem treinamento', 'Capacidade de um sistema ser treinado uma única vez com todos os dados'),
    ('seed_ia_dificil_v2', 'O que é aprendizado por transferência (Transfer Learning)?', 0, 'Processo de copiar arquivos', 'Uso de um modelo recém-criado para resolver uma tarefa sem dados de treino'),
    ('seed_ia_dificil_v2', 'O que é aprendizado por transferência (Transfer Learning)?', 2, 'Criação de um computador novo', 'Uso de vários modelos em paralelo para resolver uma mesma tarefa de forma segura'),
    ('seed_ia_dificil_v2', 'O que é aprendizado por transferência (Transfer Learning)?', 3, 'Exclusão de conhecimento de um modelo', 'Cópia dos dados de um modelo para outro, sem treinar novamente a tarefa'),
    ('seed_ia_dificil_v2', 'O que é IA embarcada?', 0, 'Banco de dados', 'Inteligência artificial integrada diretamente em bancos de dados ou servidores'),
    ('seed_ia_dificil_v2', 'O que é IA embarcada?', 2, 'Programa sem hardware', 'Inteligência artificial executada diretamente em nuvens públicas ou privadas'),
    ('seed_ia_dificil_v2', 'O que é IA embarcada?', 3, 'IA apenas em servidores', 'Inteligência artificial integrada às aplicações web e a páginas de internet'),
    ('seed_ia_dificil_v2', 'O que é aprendizagem profunda (Deep Learning)?', 0, 'Método usado apenas para criar documentos', 'Área da IA que utiliza regras escritas por pessoas com múltiplas condições para decidir'),
    ('seed_ia_dificil_v2', 'O que é aprendizagem profunda (Deep Learning)?', 1, 'Programa sem capacidade de aprendizagem', 'Área da IA que utiliza bases de dados com múltiplas tabelas para guardar padrões complexos'),
    ('seed_ia_dificil_v2', 'O que é aprendizagem profunda (Deep Learning)?', 2, 'Sistema que apenas armazena informações manualmente', 'Área da IA que utiliza algoritmos de busca com múltiplas etapas para encontrar padrões complexos em tabelas'),
    ('seed_ia_dificil_v2', 'O que é learning rate?', 0, 'Capacidade de armazenamento', 'Taxa que controla o número de exemplos usados em cada passo do treinamento do modelo'),
    ('seed_ia_dificil_v2', 'O que é learning rate?', 1, 'Número de usuários', 'Taxa que controla a quantidade de camadas ocultas durante o treinamento'),
    ('seed_ia_dificil_v2', 'O que é learning rate?', 3, 'Velocidade da internet', 'Taxa que controla o tamanho dos dados lidos do disco durante o treinamento')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 6: % alternativa(s) errada(s) atualizada(s) (esperado: 30).', v_updated;
END $$;
