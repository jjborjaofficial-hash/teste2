-- Explicações pedagógicas (BE-004) — Tecnologia difícil lote 1: perguntas 1 a 25 do seed dificil_v1 (migration 036).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e relação entre conceitos, nível difícil, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 318. Só atualiza perguntas
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
    ('seed_tecnologia_dificil_v1', 'O que é computação em nuvem?', 'Computação em nuvem é o modelo em que recursos computacionais, como servidores, armazenamento e programas, são acessados remotamente pela internet, em vez de ficarem instalados localmente. É a base de modelos como SaaS, PaaS e IaaS, e difere da instalação local e da simples rede interna.'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma característica da computação em nuvem?', 'Uma característica central da nuvem é a escalabilidade: os recursos aumentam ou diminuem conforme a necessidade, e se paga pelo que se usa. Por isso não há custo fixo independente do uso, ela depende de conexão e os equipamentos pertencem ao provedor.'),
    ('seed_tecnologia_dificil_v1', 'O que significa SaaS em tecnologia?', 'SaaS significa Software como Serviço: o provedor oferece a aplicação pronta, acessada pela internet, sem o cliente instalar ou manter nada. Difere do IaaS, que fornece infraestrutura, e do PaaS, que fornece uma plataforma de desenvolvimento.'),
    ('seed_tecnologia_dificil_v1', 'Qual exemplo representa um modelo SaaS?', 'Um e-mail acessado pelo navegador é SaaS: a aplicação pronta fica no provedor e o usuário só a usa. Uma máquina virtual configurada é IaaS, um ambiente de desenvolvimento é PaaS, e um servidor físico na empresa nem é nuvem.'),
    ('seed_tecnologia_dificil_v1', 'O que é IaaS?', 'IaaS é o modelo que fornece infraestrutura, como servidores, armazenamento e redes, pela nuvem, e o cliente instala e gere sistemas e aplicações sobre ela. Aplicações prontas são SaaS, e ambientes de desenvolvimento são PaaS.'),
    ('seed_tecnologia_dificil_v1', 'O que é PaaS?', 'PaaS oferece uma plataforma com ambiente para desenvolver e executar aplicações, sem o desenvolvedor cuidar de servidores. Fica entre o IaaS, que dá a infraestrutura, e o SaaS, que dá a aplicação pronta.'),
    ('seed_tecnologia_dificil_v1', 'O que é virtualização?', 'Virtualização é a tecnologia que cria versões virtuais de recursos físicos, como máquinas ou servidores, permitindo que um equipamento execute vários ambientes. É a base da nuvem e das máquinas virtuais. Não é digitalizar documentos, criar redes nem desenhar interfaces.'),
    ('seed_tecnologia_dificil_v1', 'O que é uma máquina virtual?', 'Uma máquina virtual é um ambiente criado por software que funciona como um computador independente, com o seu próprio sistema operacional, sobre o hardware de outra máquina. Quem a cria e gerencia é o hipervisor, e não depende de hardware dedicado.'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função de um hipervisor?', 'O hipervisor gerencia máquinas virtuais num ambiente virtualizado: divide os recursos físicos entre elas e as isola. Proteger redes, distribuir tráfego ou armazenar arquivos são funções de outros sistemas.'),
    ('seed_tecnologia_dificil_v1', 'O que é contêiner em tecnologia?', 'Contêiner é um ambiente isolado que executa uma aplicação com as suas dependências, compartilhando o sistema operacional do host, por isso é mais leve do que uma máquina virtual. Não é um servidor físico nem um navegador.'),
    ('seed_tecnologia_dificil_v1', 'Qual tecnologia é muito utilizada para gerenciamento de contêineres?', 'O Kubernetes é a ferramenta muito usada para orquestrar e gerenciar contêineres: distribui, escala e reinicia aplicações. Bluetooth é uma tecnologia de conexão, o Photoshop edita imagens e o Wireshark analisa tráfego de rede.'),
    ('seed_tecnologia_dificil_v1', 'O que é DevOps?', 'DevOps é a cultura e o conjunto de práticas que aproximam o desenvolvimento de software e as operações, para entregar mais rápido e com mais qualidade. Não separa as equipes, não as substitui e não é uma linguagem.'),
    ('seed_tecnologia_dificil_v1', 'O que significa CI/CD?', 'CI/CD reúne práticas de integração contínua e de entrega ou implantação contínua de software: o código é integrado, testado e publicado de forma automática e frequente. Faz parte da cultura DevOps. Não é criptografia, compilação manual nem documentação.'),
    ('seed_tecnologia_dificil_v1', 'O que é uma API REST?', 'Uma API REST é uma interface que permite a comunicação entre sistemas seguindo os princípios da arquitetura REST, em geral por HTTP. Não compartilha arquivos em disco, não é design visual e não é uma biblioteca de interfaces.'),
    ('seed_tecnologia_dificil_v1', 'O que significa HTTP?', 'HTTP é o protocolo usado para a comunicação e a transferência de informações na web, entre navegadores e servidores. Não é o protocolo de e-mail, a linguagem das páginas nem o sistema de nomes. O HTTPS é a sua versão segura.'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função do HTTPS?', 'O HTTPS adiciona uma camada de segurança, a criptografia, à comunicação web, protegendo os dados contra interceptação. Não serve para acelerar, guardar histórico ou traduzir nomes de sites, que são tarefas de compressão, cookies e DNS.'),
    ('seed_tecnologia_dificil_v1', 'O que é DNS?', 'O DNS é o sistema que traduz nomes de domínio, fáceis de lembrar, em endereços IP, que as máquinas usam. Atribuir IPs a dispositivos é papel do DHCP, filtrar conexões é do firewall e cifrar dados é da criptografia.'),
    ('seed_tecnologia_dificil_v1', 'O que acontece quando um usuário acessa um site pelo domínio?', 'Ao acessar um site pelo domínio, o DNS ajuda a localizar o servidor associado a ele, traduzindo o nome em endereço IP, e só depois o navegador pede a página. O DNS não copia nem instala servidores, e nem o firewall ou o roteador os escolhem.'),
    ('seed_tecnologia_dificil_v1', 'O que é firewall?', 'O firewall controla e filtra as conexões de rede com base em regras definidas, permitindo ou bloqueando o tráfego. Não armazena contas, não traduz nomes nem acelera conexões. Por isso é uma peça central da segurança de redes.'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função principal de um firewall?', 'A função principal do firewall é ajudar a proteger redes contra acessos não autorizados, filtrando o tráfego por regras. Não acelera a rede, não limpa arquivos infectados, que é do antivírus, e não liga locais distantes.'),
    ('seed_tecnologia_dificil_v1', 'O que é criptografia assimétrica?', 'Na criptografia assimétrica, usam-se duas chaves diferentes: uma cifra e a outra decifra. Na simétrica, a mesma chave faz as duas coisas. É a base de certificados digitais e do HTTPS. Não é compressão nem assinatura de cópias.'),
    ('seed_tecnologia_dificil_v1', 'O que é uma chave pública em criptografia assimétrica?', 'A chave pública pode ser compartilhada, porque sozinha não permite decifrar o que foi cifrado com ela: quem a tem pode cifrar mensagens ou verificar assinaturas. A chave privada é que deve ser mantida em segredo.'),
    ('seed_tecnologia_dificil_v1', 'O que é engenharia social?', 'Engenharia social é a manipulação psicológica de pessoas para obter informações ou levá-las a realizar ações indevidas, explorando confiança e pressa. Ataca o fator humano, e não falhas técnicas. Por isso o treino dos usuários é uma defesa.'),
    ('seed_tecnologia_dificil_v1', 'Qual é um exemplo de engenharia social?', 'Alguém fingir ser uma instituição para pedir dados confidenciais é engenharia social: usa a confiança da vítima, e não uma falha técnica. Atualizar sistemas e fazer backup são medidas de proteção, o oposto.'),
    ('seed_tecnologia_dificil_v1', 'O que é autenticação biométrica?', 'A autenticação biométrica verifica a identidade por características físicas, como a digital ou o rosto, ou comportamentais, como o jeito de digitar. Senhas e perguntas pessoais são algo que se sabe, e cartões e tokens são algo que se tem.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia difícil lote 1: perguntas 1 a 25 do seed dificil_v1 (migration 036): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
