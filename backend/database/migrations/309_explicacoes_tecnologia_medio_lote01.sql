-- Explicações pedagógicas (BE-004) — Tecnologia médio lote 1: perguntas 1 a 25 do seed medio_v1 (migration 034).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e contexto, nível médio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 308. Só atualiza perguntas
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
    ('seed_tecnologia_medio_v1', 'O que é um sistema operacional?', 'O sistema operacional é o software que gerencia os recursos do computador, como a memória e o processador, e permite que os programas funcionem. Sem ele, nenhum aplicativo consegue rodar. Windows, Android e iOS são exemplos.'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um exemplo de sistema operacional?', 'Windows é um sistema operacional: gerencia os recursos do computador e permite executar programas. Google Chrome, YouTube e WhatsApp são aplicativos, que dependem do sistema operacional para funcionar.'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal função de um processador (CPU)?', 'O processador, ou CPU, executa as instruções dos programas e faz os cálculos de que o computador precisa para funcionar. Guardar arquivos é função do armazenamento, ligar à rede é da placa de rede e exibir imagens é da placa de vídeo e do monitor.'),
    ('seed_tecnologia_medio_v1', 'O que significa RAM?', 'RAM significa memória de acesso aleatório. É uma memória rápida onde o computador guarda, só por enquanto, os dados dos programas em uso. Não é a memória que guarda o sistema de forma permanente, que seria um tipo de armazenamento.'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal característica da memória RAM?', 'A RAM guarda dados temporariamente enquanto o dispositivo está em funcionamento, e por isso eles se perdem quando ele desliga. Armazenar de forma permanente é função do disco, e fazer cálculos é do processador.'),
    ('seed_tecnologia_medio_v1', 'O que é um SSD?', 'SSD é um dispositivo de armazenamento que usa memória flash, sem peças móveis, para guardar dados. O HD tradicional usa discos magnéticos. O mouse e o roteador são outros tipos de dispositivos, de entrada e de rede.'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem do SSD em relação ao HD tradicional?', 'A vantagem do SSD é a velocidade: como não tem peças móveis, lê e grava dados mais depressa que o HD, o que acelera a abertura do sistema e dos programas. Em contrapartida, costuma custar mais por gigabyte.'),
    ('seed_tecnologia_medio_v1', 'O que é hardware?', 'Hardware é a parte física do computador ou do dispositivo, como processador, memória, tela e teclado. A parte lógica, formada por programas e dados, chama-se software.'),
    ('seed_tecnologia_medio_v1', 'O que é software?', 'Software é o conjunto de programas e instruções que funcionam num dispositivo, como o sistema operacional e os aplicativos. Peças, cabos e telas fazem parte do hardware, a parte física.'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um exemplo de software?', 'Microsoft Word é um software: um programa para criar e editar textos. Placa de vídeo, disco rígido e memória RAM são hardware, ou seja, peças físicas do computador.'),
    ('seed_tecnologia_medio_v1', 'O que é uma placa-mãe?', 'A placa-mãe é o componente que liga o processador, a memória, o armazenamento e outras partes, permitindo que se comuniquem. O processador executa instruções, a fonte fornece energia e a memória guarda dados temporários: cada um tem outra função.'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma placa de vídeo?', 'A placa de vídeo processa as imagens e os gráficos que o computador exibe, aliviando o processador. É essencial em jogos e edição de vídeo. Sons, cálculos gerais e redes são tratados por outros componentes.'),
    ('seed_tecnologia_medio_v1', 'O que é uma rede de computadores?', 'Uma rede de computadores é um conjunto de dispositivos conectados para compartilhar informações e recursos, como arquivos e impressoras. A internet é a maior de todas, mas existem redes menores, como a de uma casa.'),
    ('seed_tecnologia_medio_v1', 'O que é internet?', 'A internet é a rede mundial que conecta computadores e dispositivos para a troca de informações. Difere de uma rede local, restrita a um lugar, e dos sites, que são apenas um dos serviços que funcionam sobre ela.'),
    ('seed_tecnologia_medio_v1', 'O que é Wi-Fi?', 'Wi-Fi é a tecnologia que permite a conexão sem fio a uma rede, geralmente por um roteador. A conexão por cabo é outra forma de acesso, e armazenar dados em servidores é função da nuvem.'),
    ('seed_tecnologia_medio_v1', 'O que é um navegador?', 'O navegador é o programa usado para acessar páginas e conteúdos na internet, como o Chrome. Criar páginas, guardar arquivos ou enviar mensagens são tarefas de outros tipos de programas.'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um navegador?', 'Google Chrome é um navegador, usado para abrir páginas e conteúdos da internet. Google Drive guarda arquivos na nuvem, Microsoft Word edita textos e Adobe Reader abre documentos PDF.'),
    ('seed_tecnologia_medio_v1', 'O que é armazenamento em nuvem?', 'O armazenamento em nuvem é o serviço que permite guardar e acessar arquivos pela internet, em servidores de uma empresa. Assim, os arquivos não ficam presos a um só aparelho. Não é impressão, edição ou envio de mensagens.'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem da nuvem?', 'A vantagem da nuvem é poder acessar os arquivos de diferentes dispositivos conectados, em qualquer lugar. Ela não aumenta a memória do computador, não substitui a segurança e depende da conexão para o acesso.'),
    ('seed_tecnologia_medio_v1', 'Por que fazer backup é importante?', 'O backup guarda uma cópia das informações, para que se possam recuperar se houver perda acidental, defeito ou roubo. Ele não acelera o computador, não bloqueia vírus e não atualiza programas.'),
    ('seed_tecnologia_medio_v1', 'O que é malware?', 'Malware é um software malicioso criado para causar danos ou realizar ações não autorizadas, como roubar dados ou travar o aparelho. Vírus, trojans e ransomware são tipos. O antivírus faz o contrário: protege.'),
    ('seed_tecnologia_medio_v1', 'O que é phishing?', 'Phishing é uma fraude em que o golpista usa mensagens ou páginas falsas, parecidas com as de empresas reais, para enganar a vítima e obter informações, como senhas. Não é uma técnica de proteção nem de pesquisa.'),
    ('seed_tecnologia_medio_v1', 'O que é uma senha forte?', 'Uma senha forte é difícil de adivinhar: é longa e mistura letras, números e símbolos. Nomes, datas e sequências repetidas são fáceis de descobrir e não devem ser usados, nem repetidos em vários serviços.'),
    ('seed_tecnologia_medio_v1', 'O que é autenticação de dois fatores (2FA)?', 'A autenticação de dois fatores é uma camada extra de segurança: além da senha, pede uma segunda confirmação, como um código enviado ao celular. Assim, mesmo que a senha vaze, o invasor não entra só com ela.'),
    ('seed_tecnologia_medio_v1', 'Qual é um exemplo de uso de inteligência artificial?', 'Assistentes virtuais que respondem perguntas usam inteligência artificial para entender o que a pessoa diz e responder. Planilhas, impressoras e câmeras simples executam funções fixas, sem aprender nem entender linguagem.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia médio lote 1: perguntas 1 a 25 do seed medio_v1 (migration 034): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
