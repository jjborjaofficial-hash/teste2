-- Explicações pedagógicas (BE-004) — Tecnologia difícil lote 3: perguntas 1 a 25 do seed dificil_v2 (migration 056).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e relação entre conceitos, nível difícil, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 322. Só atualiza perguntas
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
    ('seed_tecnologia_dificil_v2', 'Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 'Em arquiteturas distribuídas, vários serviços independentes precisam se comunicar pela rede, manter os dados coerentes e continuar a funcionar mesmo quando algum falha. Esses três pontos, comunicação, consistência e tolerância a falhas, são os desafios principais. Padronizar interfaces ou reduzir código não é o centro do problema.'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza principalmente uma arquitetura de microsserviços?', 'A arquitetura de microsserviços divide a aplicação em serviços independentes e especializados, cada um responsável por uma função. É o oposto de módulos dependentes e compartilhados, como no monólito, e difere de camadas sequenciais ou de réplicas idênticas.'),
    ('seed_tecnologia_dificil_v2', 'Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 'Uma transação agrupa várias operações para que sejam tratadas de forma consistente: ou todas valem, ou nenhuma. Não serve para compactar tabelas, paralelizar consultas nem identificar usuários.'),
    ('seed_tecnologia_dificil_v2', 'O que significa ACID em bancos de dados?', 'ACID são as quatro propriedades de uma transação confiável: Atomicidade, Consistência, Isolamento e Durabilidade. Não são siglas de segurança nem de armazenamento, como Integridade e Disponibilidade, que pertencem a outros conceitos.'),
    ('seed_tecnologia_dificil_v2', 'Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?', 'A atomicidade garante que uma transação seja executada por inteiro ou não seja aplicada: sem resultados parciais. Isolamento trata da interferência entre transações, durabilidade de manter o resultado após confirmar e consistência de respeitar as regras do banco.'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um índice em um banco de dados?', 'O índice acelera determinadas consultas, como o índice de um livro que leva direto à página. Ele não armazena registros por si só, não protege tabelas nem replica colunas. Em troca da velocidade de leitura, usa espaço e custa escritas.'),
    ('seed_tecnologia_dificil_v2', 'Qual pode ser uma consequência do excesso de índices em uma tabela?', 'Cada índice precisa ser atualizado a cada inserção, atualização ou exclusão, por isso o excesso de índices aumenta o custo dessas operações e ocupa mais espaço. Não torna as escritas mais rápidas, não melhora a segurança e não reduz o espaço.'),
    ('seed_tecnologia_dificil_v2', 'O que é normalização em bancos de dados relacionais?', 'A normalização organiza os dados em tabelas para reduzir redundâncias e anomalias, evitando repetir a mesma informação. O contrário, duplicar dados para ganhar desempenho, é a desnormalização. Não é compactar nem proteger.'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma condição de corrida em sistemas concorrentes?', 'Na condição de corrida, o resultado depende da ordem imprevisível em que operações concorrentes são executadas, como duas threads que alteram o mesmo dado. Não é limite de memória, velocidade do processador nem erro de digitação.'),
    ('seed_tecnologia_dificil_v2', 'O que é um deadlock?', 'Num deadlock, dois ou mais processos ficam bloqueados, cada um esperando um recurso que outro mantém, e nenhum avança. Diferente de uma execução lenta ou de um processo encerrado, o sistema fica preso. Evita-se com ordem de aquisição e tempos limite.'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 'Para evitar condições de corrida usa-se um mutex ou outro mecanismo de sincronização, que garante que só uma execução por vez altere o dado compartilhado. Cache, proxy ou hash têm outros propósitos.'),
    ('seed_tecnologia_dificil_v2', 'O que é uma race condition?', 'Race condition é a situação em que o resultado depende do momento ou da ordem de execução de operações concorrentes, e por isso pode variar a cada execução. Não depende do formato de armazenamento, da rede ou de uma senha.'),
    ('seed_tecnologia_dificil_v2', 'Em redes, qual é a função principal do protocolo TCP?', 'O TCP fornece comunicação orientada à conexão, com entrega confiável e ordenada: confirma o recebimento, retransmite perdas e reordena pacotes. Entrega rápida sem garantia é o UDP, resolver nomes é o DNS e atribuir endereços é o DHCP.'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica fundamental do UDP em comparação com TCP?', 'O UDP não estabelece uma conexão tradicional e tem menor sobrecarga, por isso é mais leve e rápido, mas sem confirmação nem ordenação. Serve para vídeo e jogos. O TCP é que estabelece conexão e retransmite.'),
    ('seed_tecnologia_dificil_v2', 'Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?', 'O DNS é o protocolo usado para resolver nomes de domínio em endereços IP. FTP transfere arquivos, SMTP envia e-mails e SSH dá acesso remoto seguro.'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal do protocolo DHCP?', 'O DHCP atribui automaticamente as configurações de rede aos dispositivos, como endereço IP e gateway. Traduzir nomes é o DNS, transferir arquivos é o FTP e proteger conexões é o papel de outras soluções, como VPN.'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma rede baseada em IPv6?', 'O IPv6 usa endereços de 128 bits, bem mais longos que os 32 bits do IPv4. Isso permite um número enorme de endereços. Os 48 bits são o tamanho dos endereços MAC, outro conceito.'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante do IPv6?', 'A grande vantagem do IPv6 é o espaço de endereçamento muito maior que o do IPv4, resolvendo a escassez de endereços. Ele não é, por si só, mais rápido, não amplia o sinal sem fio e não reduz o custo dos equipamentos.'),
    ('seed_tecnologia_dificil_v2', 'O que é NAT em redes?', 'O NAT é a técnica que traduz endereços IP entre diferentes espaços de endereçamento, como de uma rede privada para a internet, permitindo que vários dispositivos partilhem um IP público. Não traduz nomes (DNS), não compacta pacotes e não criptografa.'),
    ('seed_tecnologia_dificil_v2', 'O que é uma CDN?', 'Uma CDN é uma rede distribuída de servidores que entrega conteúdos aos usuários a partir do ponto mais próximo, com menor latência. Não é uma rede centralizada, nem privada, e não serve para encaminhar pacotes entre usuários.'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um balanceador de carga?', 'O balanceador de carga distribui as requisições entre diferentes servidores ou instâncias, evitando sobrecarga em um só e melhorando a disponibilidade. Armazenar, traduzir ou criptografar requisições são outras funções.'),
    ('seed_tecnologia_dificil_v2', 'O que significa alta disponibilidade?', 'Alta disponibilidade é a capacidade de um sistema permanecer acessível durante grande parte do tempo, mesmo com algumas falhas, graças à redundância e ao failover. Proteção contra ataques, rapidez e atualização são outras qualidades.'),
    ('seed_tecnologia_dificil_v2', 'O que é redundância em infraestrutura?', 'Redundância é manter componentes ou recursos adicionais para aumentar a tolerância a falhas: se um falha, outro assume. Por isso custa mais, mas é a base da alta disponibilidade. Não é reduzir custos nem isolar para segurança.'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade de um mecanismo de failover?', 'Failover é o mecanismo que transfere o serviço para um recurso alternativo quando o principal falha, mantendo o sistema no ar. Distribuir carga é papel do balanceador, e copiar ou isolar são outras funções.'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica importante de sistemas distribuídos?', 'Num sistema distribuído, os componentes podem executar em máquinas diferentes e precisam coordenar suas operações pela rede, lidando com falhas parciais e atrasos. Não precisam estar no mesmo processo, nem dispensam a coordenação.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia difícil lote 3: perguntas 1 a 25 do seed dificil_v2 (migration 056): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
