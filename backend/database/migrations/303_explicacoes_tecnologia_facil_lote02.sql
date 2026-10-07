-- Explicações pedagógicas (BE-004) — Tecnologia fácil lote 2: perguntas 26 a 50 do seed v1 (migration 033).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 302. Só atualiza perguntas
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
    ('seed_tecnologia_facil_v1', 'O que é email?', 'O e-mail é um serviço para enviar e receber mensagens eletrônicas, com texto e anexos, usando um endereço próprio. Não é um programa para navegar, nem um serviço para guardar arquivos, nem uma chamada por vídeo.'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um serviço de email?', 'Gmail é um serviço de e-mail, usado para enviar e receber mensagens. HDMI e Bluetooth são formas de ligar aparelhos, e Windows é um sistema operacional: nenhum deles envia e-mails.'),
    ('seed_tecnologia_facil_v1', 'O que é uma mensagem instantânea?', 'A mensagem instantânea é uma comunicação enviada e recebida quase na hora, por meio de aplicativos como o WhatsApp. Difere da carta, que é lenta, e da chamada de vídeo, que é uma conversa em tempo real com imagem.'),
    ('seed_tecnologia_facil_v1', 'Qual aplicativo é conhecido por mensagens instantâneas?', 'WhatsApp é um aplicativo de mensagens instantâneas: permite conversar por texto, voz e vídeo. O Photoshop edita imagens, o Excel faz planilhas e o Spotify toca música.'),
    ('seed_tecnologia_facil_v1', 'O que é uma chamada de vídeo?', 'Na chamada de vídeo, duas ou mais pessoas conversam com áudio e imagem em tempo real pela internet. Já a mensagem de texto só envia escrita, e a chamada comum de voz usa a rede telefônica, sem imagem.'),
    ('seed_tecnologia_facil_v1', 'O que é inteligência artificial?', 'Inteligência artificial é a tecnologia que permite a sistemas realizarem tarefas que normalmente exigiriam inteligência humana, como entender a fala ou recomendar conteúdos. Guardar dados, conectar-se sem fios ou usar a nuvem são outras tecnologias.'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de inteligência artificial?', 'Assistentes virtuais, que entendem pedidos de voz, e sistemas de recomendação, que sugerem vídeos ou produtos, usam inteligência artificial para aprender com dados. Planilhas, câmeras e impressoras executam funções fixas, sem aprender.'),
    ('seed_tecnologia_facil_v1', 'O que é uma atualização de aplicativo?', 'Uma atualização é uma nova versão do aplicativo, criada para corrigir erros, melhorar o funcionamento ou trazer novidades. Não é uma cópia de segurança, nem uma conta nova, nem a compra de outro aparelho.'),
    ('seed_tecnologia_facil_v1', 'Por que atualizar aplicativos?', 'Atualizar os aplicativos traz melhorias e, principalmente, correções de segurança que fecham falhas por onde os vírus entram. Não serve para liberar espaço nem para acelerar a internet.'),
    ('seed_tecnologia_facil_v1', 'O que é um vírus de computador?', 'Vírus de computador é um programa malicioso que pode danificar o aparelho, apagar arquivos ou roubar informações, muitas vezes sem o usuário perceber. Um programa de segurança faz o contrário: detecta e remove ameaças.'),
    ('seed_tecnologia_facil_v1', 'O que é antivírus?', 'O antivírus é um programa usado para detectar e remover ameaças digitais, como vírus, e proteger o aparelho. Não organiza arquivos, não escreve textos e não espalha ameaças, que é o papel de programas maliciosos.'),
    ('seed_tecnologia_facil_v1', 'O que é backup?', 'Backup é uma cópia de segurança de informações importantes, guardada num lugar separado, como um pen drive ou a nuvem. Se o original se perder, a cópia permite recuperá-lo. Não é uma atualização, nem uma proteção por senha.'),
    ('seed_tecnologia_facil_v1', 'Por que fazer backup?', 'Fazemos backup para poder recuperar os dados se houver perda, defeito, roubo ou erro no aparelho. A cópia não acelera o computador, não libera espaço e não bloqueia ataques.'),
    ('seed_tecnologia_facil_v1', 'O que é nuvem (cloud)?', 'A nuvem (cloud) é um serviço que guarda dados em servidores na internet, e por isso eles podem ser acessados de qualquer aparelho com conexão. Não é um serviço de mensagens, um navegador ou um pen drive.'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de armazenamento em nuvem?', 'Google Drive é um serviço de armazenamento em nuvem: guarda arquivos na internet e permite acessá-los de vários aparelhos. O Mozilla Firefox é um navegador, o Microsoft Word edita textos e o Adobe Reader abre documentos.'),
    ('seed_tecnologia_facil_v1', 'O que é Bluetooth?', 'Bluetooth é a tecnologia de comunicação sem fio entre aparelhos próximos, como o celular e um fone de ouvido. Não usa cabo, não serve para acessar a internet a longa distância e não localiza aparelhos por satélite.'),
    ('seed_tecnologia_facil_v1', 'O que é GPS?', 'O GPS é um sistema que usa satélites para descobrir onde o aparelho está, e serve para localização e navegação, como nos mapas do celular. Não serve para mensagens, cópias de dados ou pesquisas na internet.'),
    ('seed_tecnologia_facil_v1', 'O que é QR Code?', 'O QR Code é um código de quadradinhos que câmeras e aparelhos conseguem ler para abrir um site, um pagamento ou outras informações. Não é uma senha digitada, nem um programa instalado, nem um cabo.'),
    ('seed_tecnologia_facil_v1', 'O que é uma rede social?', 'Rede social é uma plataforma onde as pessoas compartilham conteúdos, como fotos e textos, e interagem entre si por curtidas e comentários. Guardar arquivos, comprar produtos e pesquisar sites são outras finalidades.'),
    ('seed_tecnologia_facil_v1', 'Qual destes é uma rede social?', 'Instagram é uma rede social, onde as pessoas compartilham fotos e vídeos e interagem. Google Drive guarda arquivos, Microsoft Word edita textos e Android é um sistema operacional.'),
    ('seed_tecnologia_facil_v1', 'O que é download?', 'Download é baixar arquivos da internet para o seu dispositivo, como uma foto ou um aplicativo. O caminho inverso, do aparelho para a internet, chama-se upload, e abrir sem guardar não é download.'),
    ('seed_tecnologia_facil_v1', 'O que é upload?', 'Upload é enviar arquivos do seu dispositivo para um serviço online, como postar uma foto ou subir um documento para a nuvem. O contrário, baixar da internet para o aparelho, chama-se download.'),
    ('seed_tecnologia_facil_v1', 'O que é segurança digital?', 'Segurança digital é a proteção de dispositivos, dados e informações contra ameaças, como vírus, golpes e acessos indevidos. Organizar arquivos, acelerar a internet ou criar aplicativos não protege ninguém.'),
    ('seed_tecnologia_facil_v1', 'Qual atitude aumenta a segurança online?', 'Senhas fortes, difíceis de adivinhar, e o cuidado de evitar links suspeitos protegem contas e dados de golpes. Repetir a mesma senha, abrir mensagens estranhas ou instalar programas de origem desconhecida deixam o usuário exposto.'),
    ('seed_tecnologia_facil_v1', 'Por que a tecnologia é importante atualmente?', 'A tecnologia é importante porque facilita a comunicação, o trabalho, a aprendizagem e o acesso à informação, aproximando pessoas e poupando tempo. Ela não funciona sem energia nem garante proteção total, e não dispensa o esforço das pessoas.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia fácil lote 2: perguntas 26 a 50 do seed v1 (migration 033): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
