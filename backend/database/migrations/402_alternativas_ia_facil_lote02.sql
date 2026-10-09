-- Alternativas (BE-003, regularização) — IA fácil lote 2: 3 perguntas do seed v2 (migration 053; as restantes 3 do v2 foram no lote 1) e as 22 primeiras do seed v3 (migration 076).
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
    ('seed_ia_facil_v2', 'Qual é uma aplicação comum de IA?', 0, 'Apenas televisores antigos', 'Televisores antigos'),
    ('seed_ia_facil_v2', 'Qual é uma aplicação comum de IA?', 2, 'Somente relógios analógicos', 'Relógios analógicos'),
    ('seed_ia_facil_v2', 'Qual é uma aplicação comum de IA?', 3, 'Apenas calculadoras mecânicas', 'Calculadoras simples'),
    ('seed_ia_facil_v2', 'O que caracteriza uma IA generativa?', 1, 'Apenas armazenar arquivos', 'Capacidade de guardar arquivos como fotos, vídeos, textos ou planilhas'),
    ('seed_ia_facil_v2', 'O que caracteriza uma IA generativa?', 2, 'Apenas conectar dispositivos', 'Capacidade de ligar aparelhos como telemóveis, câmaras, rádios ou antenas'),
    ('seed_ia_facil_v2', 'O que caracteriza uma IA generativa?', 3, 'Somente calcular números', 'Capacidade de calcular valores como somas, médias, taxas ou percentagens'),
    ('seed_ia_facil_v2', 'Por que informações geradas por IA devem ser verificadas em situações importantes?', 1, 'Porque a internet deixa de funcionar', 'Porque a conexão pode falhar durante a consulta'),
    ('seed_ia_facil_v2', 'Por que informações geradas por IA devem ser verificadas em situações importantes?', 2, 'Porque IA nunca produz texto', 'Porque o sistema guarda respostas em arquivos antigos'),
    ('seed_ia_facil_v2', 'Por que informações geradas por IA devem ser verificadas em situações importantes?', 3, 'Porque toda informação é necessariamente falsa', 'Porque os resultados vêm de fontes já confirmadas'),
    ('seed_ia_facil_v3', 'Qual é um exemplo comum de inteligência artificial?', 0, 'Um lápis', 'Um carregador de bateria portátil'),
    ('seed_ia_facil_v3', 'Qual é um exemplo comum de inteligência artificial?', 1, 'Uma calculadora simples', 'Uma calculadora científica comum'),
    ('seed_ia_facil_v3', 'Qual é um exemplo comum de inteligência artificial?', 2, 'Uma folha de papel', 'Um relógio de parede analógico'),
    ('seed_ia_facil_v3', 'Qual destes pode ser utilizado para conversar com uma IA?', 0, 'Pen drive', 'Unidade de armazenamento'),
    ('seed_ia_facil_v3', 'Qual destes pode ser utilizado para conversar com uma IA?', 1, 'Cabo de energia', 'Adaptador de energia'),
    ('seed_ia_facil_v3', 'Qual destes pode ser utilizado para conversar com uma IA?', 2, 'Impressora', 'Dispositivo de impressão'),
    ('seed_ia_facil_v3', 'O que são dados?', 1, 'Somente textos', 'Programas que podem ser instalados e atualizados'),
    ('seed_ia_facil_v3', 'O que são dados?', 2, 'Apenas números bancários', 'Equipamentos que podem ser ligados ou desligados'),
    ('seed_ia_facil_v3', 'O que são dados?', 3, 'Apenas fotografias', 'Instruções que orientam o funcionamento de aparelhos'),
    ('seed_ia_facil_v3', 'Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 0, 'Música exclusivamente', 'Música'),
    ('seed_ia_facil_v3', 'Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 2, 'Transporte exclusivamente', 'Transporte'),
    ('seed_ia_facil_v3', 'Qual destas áreas utiliza IA para identificar doenças ou auxiliar diagnósticos?', 3, 'Construção', 'Construção'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de IA em smartphones?', 0, 'Capa protetora', 'Capa protetora com espaço para cartões e notas'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de IA em smartphones?', 1, 'Botão de volume', 'Botão lateral para ajustar o volume do aparelho'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de IA em smartphones?', 2, 'Carregador', 'Carregador rápido com cabo de energia incluído'),
    ('seed_ia_facil_v3', 'Qual é a função de um conjunto de treinamento?', 0, 'Desligar o computador', 'Guardar cópias dos resultados produzidos pelo modelo'),
    ('seed_ia_facil_v3', 'Qual é a função de um conjunto de treinamento?', 2, 'Armazenar apenas músicas', 'Medir a velocidade de resposta do sistema'),
    ('seed_ia_facil_v3', 'Qual é a função de um conjunto de treinamento?', 3, 'Substituir o algoritmo', 'Proteger o sistema contra acessos indevidos'),
    ('seed_ia_facil_v3', 'O que pode acontecer se uma IA receber dados de baixa qualidade?', 0, 'Os dados deixam de ser necessários', 'Os dados deixam de ser necessários ao modelo'),
    ('seed_ia_facil_v3', 'O que pode acontecer se uma IA receber dados de baixa qualidade?', 1, 'O sistema sempre fica mais rápido', 'O sistema pode ficar mais rápido nas respostas'),
    ('seed_ia_facil_v3', 'O que pode acontecer se uma IA receber dados de baixa qualidade?', 3, 'A IA torna-se automaticamente mais precisa', 'A IA passa a ficar automaticamente mais precisa'),
    ('seed_ia_facil_v3', 'Qual destas tecnologias pode usar IA para sugerir músicas?', 1, 'Teclados mecânicos', 'Aplicações de calculadora'),
    ('seed_ia_facil_v3', 'Qual destas tecnologias pode usar IA para sugerir músicas?', 2, 'Impressoras', 'Editores de texto simples'),
    ('seed_ia_facil_v3', 'Qual destas tecnologias pode usar IA para sugerir músicas?', 3, 'Cabos USB', 'Gestores de ficheiros'),
    ('seed_ia_facil_v3', 'Qual é um possível benefício da IA nas empresas?', 0, 'Eliminar toda supervisão humana', 'Dispensar a supervisão humana nos processos'),
    ('seed_ia_facil_v3', 'Qual é um possível benefício da IA nas empresas?', 2, 'Impedir qualquer erro', 'Impedir falhas humanas nos processos internos'),
    ('seed_ia_facil_v3', 'Qual é um possível benefício da IA nas empresas?', 3, 'Garantir lucro', 'Assegurar lucro nas vendas do ano inteiro'),
    ('seed_ia_facil_v3', 'O que significa dizer que uma IA foi treinada?', 0, 'O computador recebeu uma limpeza física', 'O modelo foi copiado para vários computadores de uma empresa'),
    ('seed_ia_facil_v3', 'O que significa dizer que uma IA foi treinada?', 1, 'O dispositivo foi desligado', 'O programa foi atualizado com novos ícones e menus visuais'),
    ('seed_ia_facil_v3', 'O que significa dizer que uma IA foi treinada?', 2, 'O programa foi instalado sem dados', 'O sistema foi configurado com novas senhas para os usuários'),
    ('seed_ia_facil_v3', 'Qual é uma preocupação relacionada ao uso de IA?', 1, 'Ausência de qualquer algoritmo', 'Desgaste físico dos ecrãs e dos teclados'),
    ('seed_ia_facil_v3', 'Qual é uma preocupação relacionada ao uso de IA?', 2, 'Falta de eletricidade em todos os casos', 'Custo elevado de cabos e conectores de rede'),
    ('seed_ia_facil_v3', 'Qual é uma preocupação relacionada ao uso de IA?', 3, 'Impossibilidade de armazenar textos', 'Perda de sinal em zonas sem cobertura móvel'),
    ('seed_ia_facil_v3', 'Qual destas tarefas uma IA generativa pode realizar?', 1, 'Substituir um processador', 'Reparar ecrãs'),
    ('seed_ia_facil_v3', 'Qual destas tarefas uma IA generativa pode realizar?', 2, 'Carregar uma bateria', 'Medir tensão'),
    ('seed_ia_facil_v3', 'Qual destas tarefas uma IA generativa pode realizar?', 3, 'Aumentar fisicamente a memória RAM', 'Trocar peças'),
    ('seed_ia_facil_v3', 'O que significa IA generativa?', 1, 'IA usada exclusivamente para calcular impostos', 'IA capaz de arquivar documentos como contratos, faturas, recibos ou cartas'),
    ('seed_ia_facil_v3', 'O que significa IA generativa?', 2, 'IA usada apenas em robôs físicos', 'IA capaz de controlar aparelhos como câmaras, portões, rádios ou antenas'),
    ('seed_ia_facil_v3', 'O que significa IA generativa?', 3, 'IA que funciona sem algoritmos', 'IA capaz de converter moedas como meticais, dólares, euros ou rands'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 0, 'Energia elétrica', 'Papel'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 1, 'Hardware físico', 'Metal'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de conteúdo que uma IA generativa pode criar?', 2, 'Cabos de rede', 'Tinta'),
    ('seed_ia_facil_v3', 'Qual é a principal função de um prompt?', 1, 'Substituir a internet', 'Registar o histórico das conversas do utilizador'),
    ('seed_ia_facil_v3', 'Qual é a principal função de um prompt?', 2, 'Aumentar a memória do computador', 'Corrigir falhas de ligação durante a conversa'),
    ('seed_ia_facil_v3', 'Qual é a principal função de um prompt?', 3, 'Formatar o dispositivo', 'Proteger o modelo contra pedidos repetidos'),
    ('seed_ia_facil_v3', 'Um prompt detalhado pode ajudar porque:', 0, 'Remove todos os dados', 'Aumenta a velocidade da internet'),
    ('seed_ia_facil_v3', 'Um prompt detalhado pode ajudar porque:', 2, 'Desliga o modelo', 'Reduz o espaço ocupado pelo modelo'),
    ('seed_ia_facil_v3', 'Um prompt detalhado pode ajudar porque:', 3, 'Impede qualquer resposta', 'Troca o modelo por outro mais novo'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de uso responsável da IA?', 0, 'Aceitar todas as respostas automaticamente', 'Copiar respostas diretamente para trabalhos escolares'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de uso responsável da IA?', 1, 'Compartilhar dados privados sem necessidade', 'Partilhar dados pessoais para obter respostas melhores'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de uso responsável da IA?', 3, 'Utilizar IA para enganar pessoas', 'Utilizar a IA para criar mensagens falsas sobre pessoas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA fácil lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 60).', v_updated;
END $$;
