-- Alternativas (BE-003, regularização) — Tecnologia difícil lote 2: perguntas 26 a 50 do seed dificil_v1 (migration 036).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono: a resposta CERTA NÃO muda; só o texto das alternativas
-- ERRADAS é ajustado para ter tamanho e forma parecidos aos da certa. Tecnologia usa a faixa de migrations 300+.
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
    ('seed_tecnologia_dificil_v1', 'O que é machine learning supervisionado?', 0, 'Programa de edição', 'Modelo treinado utilizando dados sem classificação ou identificação prévia'),
    ('seed_tecnologia_dificil_v1', 'O que é machine learning supervisionado?', 2, 'Modelo sem qualquer dado', 'Modelo treinado utilizando recompensas e penalidades em um ambiente simulado'),
    ('seed_tecnologia_dificil_v1', 'O que é machine learning supervisionado?', 3, 'Sistema exclusivamente manual', 'Modelo treinado utilizando regras escritas manualmente por especialistas humanos'),
    ('seed_tecnologia_dificil_v1', 'O que é uma rede neural artificial?', 1, 'Sistema operacional', 'Modelo computacional inspirado em estruturas de redes físicas para transmitir dados'),
    ('seed_tecnologia_dificil_v1', 'O que é uma rede neural artificial?', 2, 'Banco de dados simples', 'Modelo estatístico inspirado em tabelas de bancos para organizar registros'),
    ('seed_tecnologia_dificil_v1', 'O que é uma rede neural artificial?', 3, 'Rede física de cabos', 'Modelo matemático inspirado em estruturas de árvores para ordenar elementos'),
    ('seed_tecnologia_dificil_v1', 'O que é deep learning?', 0, 'Método de compactação de arquivos', 'Subárea de segurança digital baseada em chaves criptográficas profundas'),
    ('seed_tecnologia_dificil_v1', 'O que é deep learning?', 1, 'Tipo de memória RAM', 'Subárea de machine learning baseada em árvores de decisão simples'),
    ('seed_tecnologia_dificil_v1', 'O que é deep learning?', 3, 'Sistema de pagamento', 'Subárea de análise de dados baseada em tabelas e gráficos extensos'),
    ('seed_tecnologia_dificil_v1', 'O que é processamento de linguagem natural (PLN)?', 0, 'Método de impressão', 'Área da IA que permite computadores reconhecerem e classificarem imagens humanas'),
    ('seed_tecnologia_dificil_v1', 'O que é processamento de linguagem natural (PLN)?', 2, 'Sistema de armazenamento', 'Área da IA que permite computadores aprenderem e executarem movimentos físicos'),
    ('seed_tecnologia_dificil_v1', 'O que é processamento de linguagem natural (PLN)?', 3, 'Tecnologia de bateria', 'Área da computação que permite computadores compactarem e transmitirem textos'),
    ('seed_tecnologia_dificil_v1', 'O que é visão computacional?', 0, 'Tipo de monitor', 'Área da IA que permite sistemas interpretarem informações sonoras de músicas e falas'),
    ('seed_tecnologia_dificil_v1', 'O que é visão computacional?', 1, 'Sistema operacional', 'Área da IA que permite sistemas gerarem informações textuais de livros e artigos'),
    ('seed_tecnologia_dificil_v1', 'O que é visão computacional?', 3, 'Melhoria física da visão humana', 'Área da saúde que permite pessoas melhorarem informações visuais de lentes e óculos'),
    ('seed_tecnologia_dificil_v1', 'O que é Big Data?', 0, 'Um aplicativo de mensagens', 'Grande volume de usuários que exige equipamentos específicos para conexão e acesso'),
    ('seed_tecnologia_dificil_v1', 'O que é Big Data?', 2, 'Um antivírus', 'Grande volume de arquivos que exige programas específicos para edição e impressão'),
    ('seed_tecnologia_dificil_v1', 'O que é Big Data?', 3, 'Um disco rígido maior', 'Grande capacidade de disco que exige cabos específicos para ligação e instalação'),
    ('seed_tecnologia_dificil_v1', 'O que significa análise de dados?', 0, 'Criação de vírus', 'Processo de copiar dados para obter cópias úteis e apoiar restaurações'),
    ('seed_tecnologia_dificil_v1', 'O que significa análise de dados?', 1, 'Instalação de hardware', 'Processo de apagar dados para obter espaço útil e apoiar instalações'),
    ('seed_tecnologia_dificil_v1', 'O que significa análise de dados?', 2, 'Exclusão de arquivos', 'Processo de criptografar dados para obter proteção útil e apoiar acessos'),
    ('seed_tecnologia_dificil_v1', 'O que é mineração de dados?', 1, 'Criar redes Wi-Fi', 'Processo de armazenar registros e informações antigas em grandes conjuntos de dados'),
    ('seed_tecnologia_dificil_v1', 'O que é mineração de dados?', 2, 'Extrair metais de computadores', 'Processo de proteger arquivos e informações sensíveis em grandes conjuntos de dados'),
    ('seed_tecnologia_dificil_v1', 'O que é mineração de dados?', 3, 'Apagar bancos de dados', 'Processo de transmitir mensagens e informações urgentes em grandes conjuntos de rede'),
    ('seed_tecnologia_dificil_v1', 'O que é blockchain em termos tecnológicos?', 0, 'Uma memória externa', 'Estrutura centralizada de registros organizados em tabelas conectadas e administradas por um servidor'),
    ('seed_tecnologia_dificil_v1', 'O que é blockchain em termos tecnológicos?', 1, 'Um navegador', 'Estrutura distribuída de arquivos organizados em pastas conectadas e protegidas por senhas'),
    ('seed_tecnologia_dificil_v1', 'O que é blockchain em termos tecnológicos?', 2, 'Um antivírus', 'Estrutura distribuída de mensagens organizadas em pacotes conectados e protegidos por firewalls'),
    ('seed_tecnologia_dificil_v1', 'O que é um contrato inteligente (smart contract)?', 1, 'Contrato impresso em papel', 'Documento assinado em uma plataforma que registra ações conforme regras definidas'),
    ('seed_tecnologia_dificil_v1', 'O que é um contrato inteligente (smart contract)?', 2, 'Senha digital', 'Programa executado em um servidor que realiza cópias conforme horários definidos'),
    ('seed_tecnologia_dificil_v1', 'O que é um contrato inteligente (smart contract)?', 3, 'Documento enviado por email', 'Aplicativo executado em um celular que realiza pagamentos conforme limites definidos'),
    ('seed_tecnologia_dificil_v1', 'O que é edge computing?', 0, 'Armazenamento apenas em servidores distantes', 'Armazenamento de dados distante do local onde eles são gerados'),
    ('seed_tecnologia_dificil_v1', 'O que é edge computing?', 1, 'Sistema operacional móvel', 'Processamento de dados centralizado no local onde eles são auditados'),
    ('seed_tecnologia_dificil_v1', 'O que é edge computing?', 2, 'Exclusão automática de dados', 'Transmissão de dados contínua para o local onde eles são exibidos'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem do edge computing?', 0, 'Impede análise de dados', 'Pode reduzir custos ao armazenar dados mais distantes do usuário ou dispositivo'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem do edge computing?', 1, 'Elimina toda necessidade de internet', 'Pode aumentar latência ao processar dados mais distantes do usuário ou dispositivo'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem do edge computing?', 2, 'Remove todos os servidores', 'Pode ampliar segurança ao criptografar dados mais antigos do usuário ou dispositivo'),
    ('seed_tecnologia_dificil_v1', 'O que é baixa latência?', 0, 'Baixa qualidade de imagem', 'Pequena perda de qualidade na imagem ou exibição de dados'),
    ('seed_tecnologia_dificil_v1', 'O que é baixa latência?', 2, 'Pouco espaço de armazenamento', 'Pequeno espaço de armazenamento no disco ou na nuvem'),
    ('seed_tecnologia_dificil_v1', 'O que é baixa latência?', 3, 'Pouca memória RAM', 'Pequeno número de usuários na rede ou no sistema'),
    ('seed_tecnologia_dificil_v1', 'O que é arquitetura de microsserviços?', 1, 'Sistema de impressão', 'Modelo onde uma aplicação é executada em um único bloco que concentra todas as funções'),
    ('seed_tecnologia_dificil_v1', 'O que é arquitetura de microsserviços?', 2, 'Tipo de teclado', 'Modelo onde uma aplicação é dividida em pequenas telas independentes que mudam entre si'),
    ('seed_tecnologia_dificil_v1', 'O que é arquitetura de microsserviços?', 3, 'Programa instalado em um único arquivo', 'Modelo onde uma aplicação é copiada em pequenos servidores idênticos que replicam entre si'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem dos microsserviços?', 1, 'Impedir alterações', 'Permitir desenvolvimento e teste sequencial de todas as partes de uma aplicação'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem dos microsserviços?', 2, 'Eliminar servidores', 'Permitir instalação e execução simultânea de diferentes versões de um aplicativo'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem dos microsserviços?', 3, 'Remover bancos de dados', 'Permitir armazenamento e consulta centralizada de diferentes dados de uma aplicação'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade em sistemas?', 0, 'Exclusão de dados', 'Capacidade de um sistema recuperar dados após falhas ou erros'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade em sistemas?', 1, 'Redução obrigatória de funções', 'Capacidade de um sistema reduzir custos com menos usuários ou demanda'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade em sistemas?', 3, 'Capacidade de desligar servidores', 'Capacidade de um sistema proteger acessos contra invasões ou ataques'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade horizontal?', 1, 'Aumentar apenas a memória de uma máquina', 'Aumentar a memória e a CPU de uma máquina já existente para ampliar capacidade'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade horizontal?', 2, 'Apagar serviços', 'Remover máquinas ou instâncias para reduzir capacidade'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade horizontal?', 3, 'Reduzir usuários', 'Copiar dados entre máquinas ou instâncias para preservar capacidade'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade vertical?', 1, 'Criar novos domínios', 'Adicionar máquinas a um grupo existente, como servidores ou instâncias'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade vertical?', 2, 'Adicionar novos usuários', 'Distribuir tráfego entre servidores existentes, como balanceadores ou proxies'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade vertical?', 3, 'Remover servidores', 'Reduzir recursos de uma máquina existente, como CPU ou memória'),
    ('seed_tecnologia_dificil_v1', 'O que é observabilidade em sistemas?', 0, 'Velocidade do teclado', 'Capacidade de proteger o acesso interno de um sistema através de itens como senhas, chaves e certificados'),
    ('seed_tecnologia_dificil_v1', 'O que é observabilidade em sistemas?', 2, 'Visualização da tela', 'Capacidade de ampliar o desempenho interno de um sistema através de ações como cache, filas e réplicas'),
    ('seed_tecnologia_dificil_v1', 'O que é observabilidade em sistemas?', 3, 'Qualidade da câmera', 'Capacidade de documentar o funcionamento interno de um sistema através de itens como manuais, diagramas e tutoriais'),
    ('seed_tecnologia_dificil_v1', 'O que são logs em sistemas?', 0, 'Arquivos de imagem', 'Cópias de arquivos e dados armazenados por aplicações ou sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que são logs em sistemas?', 2, 'Senhas públicas', 'Credenciais de usuários e contas utilizadas por aplicações ou sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que são logs em sistemas?', 3, 'Componentes físicos', 'Componentes de código e bibliotecas utilizados por aplicações ou sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que é uma vulnerabilidade de software?', 1, 'Uma melhoria de desempenho', 'Melhoria que pode permitir comportamentos esperados ou adoção por usuários'),
    ('seed_tecnologia_dificil_v1', 'O que é uma vulnerabilidade de software?', 2, 'Uma atualização normal', 'Atualização que pode permitir correções automáticas ou aplicação por administradores'),
    ('seed_tecnologia_dificil_v1', 'O que é uma vulnerabilidade de software?', 3, 'Um novo recurso', 'Recurso que pode permitir comportamentos novos ou personalização por usuários'),
    ('seed_tecnologia_dificil_v1', 'O que é teste de penetração (pentest)?', 0, 'Instalação de jogos', 'Avaliação de desempenho simulando acessos simultâneos para identificar gargalos'),
    ('seed_tecnologia_dificil_v1', 'O que é teste de penetração (pentest)?', 2, 'Teste de velocidade da internet', 'Monitoramento de rede registrando acessos contínuos para identificar intrusos'),
    ('seed_tecnologia_dificil_v1', 'O que é teste de penetração (pentest)?', 3, 'Formatação de computador', 'Auditoria de licenças verificando programas instalados para identificar pirataria'),
    ('seed_tecnologia_dificil_v1', 'O que é Zero Trust em segurança?', 0, 'Rede totalmente aberta', 'Modelo que assume que toda entidade interna deve ser automaticamente confiável após o login'),
    ('seed_tecnologia_dificil_v1', 'O que é Zero Trust em segurança?', 1, 'Sistema sem autenticação', 'Modelo que assume que nenhuma entidade precisa ser identificada em redes internas privadas'),
    ('seed_tecnologia_dificil_v1', 'O que é Zero Trust em segurança?', 3, 'Método de armazenamento', 'Modelo que assume que cada entidade deve ser confiável conforme o cargo na empresa'),
    ('seed_tecnologia_dificil_v1', 'O que é API Gateway?', 0, 'Um banco de dados físico', 'Componente que armazena e organiza dados de APIs em uma arquitetura de sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que é API Gateway?', 1, 'Um processador', 'Componente que executa e processa cálculos de APIs em uma arquitetura de sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que é API Gateway?', 3, 'Um antivírus', 'Componente que detecta e remove ameaças de APIs em uma arquitetura de sistemas'),
    ('seed_tecnologia_dificil_v1', 'Por que a segurança da informação é importante?', 0, 'Apenas para aumentar armazenamento', 'Para armazenar dados, sistemas e usuários em servidores internos, locais ou remotos'),
    ('seed_tecnologia_dificil_v1', 'Por que a segurança da informação é importante?', 2, 'Apenas para criar aplicativos', 'Para acelerar dados, sistemas e usuários em redes públicas, privadas ou híbridas'),
    ('seed_tecnologia_dificil_v1', 'Por que a segurança da informação é importante?', 3, 'Apenas para melhorar gráficos', 'Para organizar dados, sistemas e usuários em categorias simples, técnicas ou legais')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia difícil lote 2: perguntas 26 a 50 do seed dificil_v1 (migration 036): % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
