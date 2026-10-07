-- Alternativas (BE-003, regularização) — Tecnologia médio lote 5: perguntas 22 a 41 do seed medio_v3 (migration 060).
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
    ('seed_tecnologia_medio_v3', 'O que é largura de banda?', 1, 'Espaço do teclado', 'Tempo de atraso na comunicação de dados em uma rede'),
    ('seed_tecnologia_medio_v3', 'O que é largura de banda?', 2, 'Tamanho do monitor', 'Quantidade de dispositivos conectados em uma rede'),
    ('seed_tecnologia_medio_v3', 'O que é largura de banda?', 3, 'Número de usuários', 'Velocidade de processamento de dados em um computador'),
    ('seed_tecnologia_medio_v3', 'O que é um servidor web?', 0, 'Um teclado especial', 'Servidor responsável por armazenar e-mails e mensagens dos usuários'),
    ('seed_tecnologia_medio_v3', 'O que é um servidor web?', 2, 'Um antivírus', 'Servidor responsável por proteger redes e bloquear acessos indevidos'),
    ('seed_tecnologia_medio_v3', 'O que é um servidor web?', 3, 'Uma placa gráfica', 'Servidor responsável por converter nomes de sites em endereços IP'),
    ('seed_tecnologia_medio_v3', 'O que é HTTP?', 0, 'Tipo de processador', 'Protocolo usado para envio de e-mails entre servidores de correio'),
    ('seed_tecnologia_medio_v3', 'O que é HTTP?', 2, 'Sistema operacional', 'Linguagem usada para criação de páginas e estruturas web'),
    ('seed_tecnologia_medio_v3', 'O que é HTTP?', 3, 'Banco de dados', 'Sistema usado para tradução de nomes e endereços na web'),
    ('seed_tecnologia_medio_v3', 'O que significa HTTPS?', 0, 'Linguagem de programação', 'Versão antiga do HTTP usando compressão'),
    ('seed_tecnologia_medio_v3', 'O que significa HTTPS?', 1, 'Memória externa', 'Versão rápida do HTTP usando armazenamento'),
    ('seed_tecnologia_medio_v3', 'O que significa HTTPS?', 3, 'Sistema operacional', 'Versão móvel do HTTP usando aplicativos'),
    ('seed_tecnologia_medio_v3', 'O que é um cookie de navegador?', 0, 'Vírus obrigatório', 'Pequeno programa usado para proteger informações sobre navegação'),
    ('seed_tecnologia_medio_v3', 'O que é um cookie de navegador?', 2, 'Tipo de hardware', 'Pequeno vírus usado para espalhar informações sobre navegação'),
    ('seed_tecnologia_medio_v3', 'O que é um cookie de navegador?', 3, 'Programa de edição', 'Pequeno anúncio usado para exibir informações sobre navegação'),
    ('seed_tecnologia_medio_v3', 'O que é uma licença de software?', 1, 'Tipo de vírus', 'Conjunto de códigos sobre acesso e proteção de um programa'),
    ('seed_tecnologia_medio_v3', 'O que é uma licença de software?', 2, 'Cabo de rede', 'Conjunto de arquivos sobre instalação e atualização de um programa'),
    ('seed_tecnologia_medio_v3', 'O que é uma licença de software?', 3, 'Senha do computador', 'Conjunto de funções sobre edição e criação de um programa'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção preventiva?', 0, 'Apenas reparar equipamentos quebrados', 'Ações realizadas para corrigir problemas existentes'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção preventiva?', 2, 'Apagar arquivos', 'Ações realizadas para substituir equipamentos antigos'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção preventiva?', 3, 'Instalar jogos', 'Ações realizadas para registrar problemas passados'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção corretiva?', 0, 'Monitoramento de rede', 'Verificação realizada antes de ocorrer uma falha'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção corretiva?', 1, 'Atualização automática', 'Atualização realizada durante o uso do sistema'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção corretiva?', 3, 'Criação de backup', 'Instalação realizada ao comprar um equipamento'),
    ('seed_tecnologia_medio_v3', 'O que é monitoramento de sistemas?', 1, 'Instalação de jogos', 'Configuração de permissões e acessos de usuários dos serviços'),
    ('seed_tecnologia_medio_v3', 'O que é monitoramento de sistemas?', 2, 'Criação de vídeos', 'Criação de cópias e arquivos de segurança de serviços'),
    ('seed_tecnologia_medio_v3', 'O que é monitoramento de sistemas?', 3, 'Exclusão de usuários', 'Atualização de versões e recursos de serviços'),
    ('seed_tecnologia_medio_v3', 'O que é JSON?', 0, 'Rede social', 'Protocolo seguro usado para envio de dados entre sistemas'),
    ('seed_tecnologia_medio_v3', 'O que é JSON?', 1, 'Sistema antivírus', 'Linguagem visual usada para estilo de páginas e sistemas'),
    ('seed_tecnologia_medio_v3', 'O que é JSON?', 3, 'Hardware', 'Banco leve usado para guardar dados dentro de sistemas'),
    ('seed_tecnologia_medio_v3', 'O que é XML?', 1, 'Processador', 'Linguagem de programação usada para executar comandos'),
    ('seed_tecnologia_medio_v3', 'O que é XML?', 2, 'Sistema operacional', 'Linguagem de consulta usada para pesquisar dados'),
    ('seed_tecnologia_medio_v3', 'O que é XML?', 3, 'Banco físico', 'Formato de compressão usado para reduzir arquivos'),
    ('seed_tecnologia_medio_v3', 'O que é Git?', 0, 'Antivírus', 'Sistema de armazenamento de arquivos em nuvem'),
    ('seed_tecnologia_medio_v3', 'O que é Git?', 1, 'Sistema operacional', 'Sistema de edição de código para programadores'),
    ('seed_tecnologia_medio_v3', 'O que é Git?', 2, 'Navegador', 'Sistema de gerenciamento de bancos de dados'),
    ('seed_tecnologia_medio_v3', 'Para que serve o GitHub?', 0, 'Editar imagens', 'Hospedar e distribuir vídeos e músicas online'),
    ('seed_tecnologia_medio_v3', 'Para que serve o GitHub?', 2, 'Aumentar memória', 'Armazenar e sincronizar fotos e documentos pessoais'),
    ('seed_tecnologia_medio_v3', 'Para que serve o GitHub?', 3, 'Criar computadores', 'Testar e proteger computadores contra vírus'),
    ('seed_tecnologia_medio_v3', 'O que é debug?', 0, 'Instalar hardware', 'Processo de instalar e configurar peças em hardware'),
    ('seed_tecnologia_medio_v3', 'O que é debug?', 1, 'Apagar banco de dados', 'Processo de copiar e restaurar dados em software'),
    ('seed_tecnologia_medio_v3', 'O que é debug?', 3, 'Criar vírus', 'Processo de proteger e monitorar acessos em software'),
    ('seed_tecnologia_medio_v3', 'O que é compilador?', 1, 'Sistema de armazenamento', 'Programa que compacta código-fonte em arquivos menores'),
    ('seed_tecnologia_medio_v3', 'O que é compilador?', 2, 'Firewall', 'Programa que verifica código-fonte em busca de vírus'),
    ('seed_tecnologia_medio_v3', 'O que é compilador?', 3, 'Navegador', 'Programa que executa código-fonte em páginas da web'),
    ('seed_tecnologia_medio_v3', 'O que é algoritmo?', 0, 'Tipo de computador', 'Conjunto de peças para montar um computador'),
    ('seed_tecnologia_medio_v3', 'O que é algoritmo?', 1, 'Arquivo de imagem', 'Conjunto de linhas para escrever um programa'),
    ('seed_tecnologia_medio_v3', 'O que é algoritmo?', 3, 'Rede sem fio', 'Sequência de sinais para conectar um dispositivo'),
    ('seed_tecnologia_medio_v3', 'O que é inteligência artificial generativa?', 1, 'Sistema de armazenamento', 'IA capaz de classificar conteúdos como textos, imagens ou sons'),
    ('seed_tecnologia_medio_v3', 'O que é inteligência artificial generativa?', 2, 'Cabo de conexão', 'IA capaz de detectar ameaças como vírus, golpes ou invasões'),
    ('seed_tecnologia_medio_v3', 'O que é inteligência artificial generativa?', 3, 'Memória física', 'IA capaz de prever resultados como vendas, preços ou demanda'),
    ('seed_tecnologia_medio_v3', 'O que é computação de borda (Edge Computing)?', 0, 'Exclusão de dados', 'Processamento de dados mais distante da origem onde são gerados'),
    ('seed_tecnologia_medio_v3', 'O que é computação de borda (Edge Computing)?', 1, 'Bloqueio de internet', 'Armazenamento de dados mais seguro no local onde são gerados'),
    ('seed_tecnologia_medio_v3', 'O que é computação de borda (Edge Computing)?', 3, 'Uso apenas de servidores distantes', 'Compressão de dados mais eficiente na origem onde são gerados'),
    ('seed_tecnologia_medio_v3', 'O que é transformação digital?', 0, 'Impressão de documentos', 'Uso de papel para organizar processos e negócios'),
    ('seed_tecnologia_medio_v3', 'O que é transformação digital?', 1, 'Troca de computadores somente', 'Compra de computadores para renovar equipamentos e escritórios'),
    ('seed_tecnologia_medio_v3', 'O que é transformação digital?', 3, 'Exclusão de sistemas', 'Uso de redes sociais para divulgar produtos e negócios'),
    ('seed_tecnologia_medio_v3', 'O que é governança de TI?', 0, 'Venda de computadores', 'Venda de recursos tecnológicos alinhada aos objetivos do mercado'),
    ('seed_tecnologia_medio_v3', 'O que é governança de TI?', 1, 'Instalação de jogos', 'Gestão de recursos humanos alinhada aos objetivos da organização'),
    ('seed_tecnologia_medio_v3', 'O que é governança de TI?', 3, 'Criação de redes sociais', 'Compra de recursos tecnológicos alinhada aos preços do fornecedor')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia médio lote 5: perguntas 22 a 41 do seed medio_v3 (migration 060): % alternativa(s) errada(s) atualizada(s) (esperado: 60).', v_updated;
END $$;
