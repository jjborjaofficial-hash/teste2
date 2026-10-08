-- Alternativas (BE-003, regularização) — IA fácil lote 1: 22 perguntas ativas do seed v1 (migration 040; a 040#10 está desativada, migration 390) e as 3 primeiras do seed v2 (migration 053).
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
    ('seed_ia_facil_v1', 'O que é um chatbot?', 0, 'Um dispositivo para carregar telemóveis', 'Programa capaz de editar fotografias e vídeos para os usuários'),
    ('seed_ia_facil_v1', 'O que é um chatbot?', 1, 'Um tipo de banco', 'Sistema capaz de guardar arquivos dos usuários em servidores remotos'),
    ('seed_ia_facil_v1', 'O que é um chatbot?', 3, 'Um antivírus físico', 'Aplicativo capaz de enviar e-mails em massa para os contactos dos usuários'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 1, 'Apenas para fazer chamadas telefónicas', 'Para aumentar a velocidade da conexão com a internet'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 2, 'Apenas para calcular impostos', 'Para consertar aparelhos eletrônicos que estão estragados'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 3, 'Somente para armazenar arquivos', 'Para guardar cópias de segurança dos arquivos do computador'),
    ('seed_ia_facil_v1', 'O que é um comando ou prompt para uma IA?', 0, 'Uma senha bancária', 'Resposta ou resultado devolvido pelo sistema'),
    ('seed_ia_facil_v1', 'O que é um comando ou prompt para uma IA?', 1, 'Um cabo USB', 'Programa usado para treinar o sistema de IA'),
    ('seed_ia_facil_v1', 'O que é um comando ou prompt para uma IA?', 3, 'Um tipo de vírus', 'Erro ou falha mostrada pelo sistema ao usuário'),
    ('seed_ia_facil_v1', 'O que é reconhecimento de voz?', 1, 'Um sistema de pagamento', 'Tecnologia capaz de transformar ou interpretar texto escrito em informação sonora'),
    ('seed_ia_facil_v1', 'O que é reconhecimento de voz?', 2, 'Tecnologia para aumentar o volume de um aparelho', 'Tecnologia capaz de aumentar ou reduzir o volume da fala humana durante chamadas'),
    ('seed_ia_facil_v1', 'O que é reconhecimento de voz?', 3, 'Um editor de fotografias', 'Tecnologia capaz de transformar ou interpretar imagens em informação processável'),
    ('seed_ia_facil_v1', 'Qual destas é uma aplicação comum de IA?', 1, 'Cadernos de papel', 'Calculadoras simples'),
    ('seed_ia_facil_v1', 'Qual destas é uma aplicação comum de IA?', 2, 'Mesas de madeira', 'Impressoras comuns'),
    ('seed_ia_facil_v1', 'Qual destas é uma aplicação comum de IA?', 3, 'Canetas', 'Cabos de rede'),
    ('seed_ia_facil_v1', 'O que é reconhecimento facial?', 0, 'Ferramenta para aumentar o brilho do ecrã', 'Tecnologia que analisa características de vozes em chamadas ou gravações'),
    ('seed_ia_facil_v1', 'O que é reconhecimento facial?', 1, 'Sistema para reconhecer documentos financeiros', 'Tecnologia que analisa características de impressões digitais em sensores'),
    ('seed_ia_facil_v1', 'O que é reconhecimento facial?', 2, 'Programa para editar planilhas', 'Tecnologia que analisa características de textos em documentos ou mensagens'),
    ('seed_ia_facil_v1', 'O que é automação?', 0, 'Desligar computadores', 'Uso de sistemas para guardar documentos com proteção contra perda de dados'),
    ('seed_ia_facil_v1', 'O que é automação?', 2, 'Fazer todas as tarefas manualmente', 'Uso de pessoas para executar tarefas repetidas com muita supervisão humana direta'),
    ('seed_ia_facil_v1', 'O que é automação?', 3, 'Apagar dados', 'Uso de sistemas para comunicar com várias pessoas ao mesmo tempo pela internet'),
    ('seed_ia_facil_v1', 'Qual é uma vantagem potencial da automação?', 0, 'Eliminar todos os empregos automaticamente', 'Aumentar o número de erros'),
    ('seed_ia_facil_v1', 'Qual é uma vantagem potencial da automação?', 1, 'Garantir que nunca haverá erros', 'Reduzir a velocidade das tarefas'),
    ('seed_ia_facil_v1', 'Qual é uma vantagem potencial da automação?', 3, 'Impedir o uso de computadores', 'Aumentar o custo de cada tarefa'),
    ('seed_ia_facil_v1', 'O que é um dado?', 1, 'Apenas uma senha', 'Programa que pode ser instalado ou atualizado'),
    ('seed_ia_facil_v1', 'O que é um dado?', 2, 'Apenas um número', 'Equipamento que pode ser ligado ou desligado'),
    ('seed_ia_facil_v1', 'O que é um dado?', 3, 'Apenas uma imagem', 'Instrução que pode ser escrita ou executada'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 0, 'Porque tornam qualquer sistema infalível', 'Permitem que o modelo funcione sem precisar de algoritmos'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 1, 'Porque eliminam algoritmos', 'Servem para aumentar a velocidade da internet durante o treino'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 2, 'Porque substituem eletricidade', 'Ajudam a escolher o computador mais barato para cada modelo'),
    ('seed_ia_facil_v1', 'O que é uma imagem gerada por IA?', 0, 'Fotografia obrigatoriamente tirada por uma câmara', 'Imagem capturada por uma câmara de segurança ou por um telemóvel'),
    ('seed_ia_facil_v1', 'O que é uma imagem gerada por IA?', 2, 'Captura de ecrã sem alterações', 'Imagem editada ou retocada manualmente por um designer em um programa'),
    ('seed_ia_facil_v1', 'O que é uma imagem gerada por IA?', 3, 'Documento bancário', 'Imagem impressa ou digitalizada por um scanner ou por uma fotocopiadora'),
    ('seed_ia_facil_v1', 'O que é tradução automática?', 0, 'Conversão de moedas', 'Uso de sistemas computacionais para converter valores de uma moeda para outra'),
    ('seed_ia_facil_v1', 'O que é tradução automática?', 1, 'Compressão de arquivos', 'Uso de sistemas computacionais para converter arquivos de um formato para outro'),
    ('seed_ia_facil_v1', 'O que é tradução automática?', 2, 'Criação de senhas', 'Uso de sistemas computacionais para converter textos escritos em áudio falado'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 0, 'Uma ordem obrigatória', 'Pedido de produtos feito pelo próprio usuário com base em listas de preços'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 2, 'Um pagamento automático', 'Cobrança de valores por serviços usados com base em planos e contratos'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 3, 'Um tipo de vírus', 'Alerta de segurança enviado ao usuário com base em listas de ameaças conhecidas'),
    ('seed_ia_facil_v1', 'Onde podemos encontrar sistemas de recomendação?', 0, 'Apenas em calculadoras', 'Calculadoras, máquinas de escrever e outros aparelhos simples'),
    ('seed_ia_facil_v1', 'Onde podemos encontrar sistemas de recomendação?', 1, 'Apenas em impressoras', 'Livros impressos, jornais de papel e outros materiais físicos'),
    ('seed_ia_facil_v1', 'Onde podemos encontrar sistemas de recomendação?', 2, 'Apenas em relógios', 'Eletrodomésticos básicos, lâmpadas e outros aparelhos sem internet'),
    ('seed_ia_facil_v1', 'O que é aprendizado de máquina?', 0, 'Um curso de programação', 'Método em que pessoas aprendem a operar máquinas em cursos para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'O que é aprendizado de máquina?', 1, 'Aprendizagem exclusivamente feita por livros', 'Método em que sistemas copiam padrões de outros equipamentos para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'O que é aprendizado de máquina?', 3, 'Um sistema operacional', 'Método em que engenheiros escrevem todas as regras à mão para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'O que é um modelo de IA?', 0, 'Uma fotografia', 'Sistema eletrônico ou mecânico montado ou instalado para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'O que é um modelo de IA?', 1, 'Um documento fiscal', 'Conjunto de dados ou documentos organizados para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'O que é um modelo de IA?', 3, 'Um modelo de roupa', 'Aplicativo instalado ou atualizado no telemóvel para realizar determinadas tarefas'),
    ('seed_ia_facil_v1', 'A IA consegue sempre fornecer respostas corretas?', 0, 'Apenas durante o dia', 'Quase sempre'),
    ('seed_ia_facil_v1', 'A IA consegue sempre fornecer respostas corretas?', 2, 'Apenas quando está conectada à internet', 'Sim, em temas simples'),
    ('seed_ia_facil_v1', 'A IA consegue sempre fornecer respostas corretas?', 3, 'Sim, sem exceção', 'Sim'),
    ('seed_ia_facil_v1', 'Por que devemos verificar informações produzidas por IA?', 1, 'Porque IA nunca processa dados', 'Porque sistemas de IA costumam repetir a mesma resposta para perguntas diferentes'),
    ('seed_ia_facil_v1', 'Por que devemos verificar informações produzidas por IA?', 2, 'Porque a verificação é impossível', 'Porque sistemas de IA costumam apagar as informações que já foram pesquisadas'),
    ('seed_ia_facil_v1', 'Por que devemos verificar informações produzidas por IA?', 3, 'Porque toda IA é sempre falsa', 'Porque sistemas de IA costumam cobrar uma taxa por cada informação verificada'),
    ('seed_ia_facil_v1', 'O que é um assistente virtual?', 0, 'Um trabalhador contratado fisicamente', 'Pessoa contratada que pode ajudar o usuário a realizar determinadas tarefas por meio de comandos'),
    ('seed_ia_facil_v1', 'O que é um assistente virtual?', 1, 'Um computador sem software', 'Sistema físico que pode ajudar o usuário a realizar determinadas tarefas por meio de ferramentas'),
    ('seed_ia_facil_v1', 'O que é um assistente virtual?', 3, 'Um dispositivo exclusivamente de armazenamento', 'Sistema digital que pode armazenar os dados do usuário para realizar determinadas cópias de segurança'),
    ('seed_ia_facil_v1', 'O que é geração de texto por IA?', 0, 'Digitalização de papel', 'Digitalização automática de texto a partir de folhas ou documentos fornecidos ao scanner'),
    ('seed_ia_facil_v1', 'O que é geração de texto por IA?', 2, 'Impressão de documentos', 'Impressão automática de texto a partir de arquivos ou documentos enviados à impressora'),
    ('seed_ia_facil_v1', 'O que é geração de texto por IA?', 3, 'Conversão de texto em moeda', 'Tradução automática de texto a partir de línguas ou idiomas indicados ao sistema'),
    ('seed_ia_facil_v1', 'O que significa ética em IA?', 1, 'Apenas programação', 'Regras técnicas usadas para orientar a velocidade e o desempenho dos sistemas de IA'),
    ('seed_ia_facil_v1', 'O que significa ética em IA?', 2, 'Apenas segurança física', 'Normas comerciais usadas para orientar a venda e a publicidade de sistemas de IA'),
    ('seed_ia_facil_v1', 'O que significa ética em IA?', 3, 'Apenas marketing', 'Técnicas usadas para orientar a escrita e a organização do código de sistemas de IA'),
    ('seed_ia_facil_v2', 'O que é um prompt?', 0, 'Um antivírus', 'Resposta ou resultado devolvido por um sistema de IA'),
    ('seed_ia_facil_v2', 'O que é um prompt?', 1, 'Uma senha bancária', 'Modelo ou programa treinado dentro de um sistema de IA'),
    ('seed_ia_facil_v2', 'O que é um prompt?', 3, 'Uma placa de vídeo', 'Erro ou aviso mostrado ao usuário por um sistema de IA'),
    ('seed_ia_facil_v2', 'Por que prompts específicos podem produzir respostas melhores?', 0, 'Eliminam qualquer possibilidade de erro', 'Reduzem o tamanho do modelo usado pelo sistema'),
    ('seed_ia_facil_v2', 'Por que prompts específicos podem produzir respostas melhores?', 2, 'Mudam o hardware', 'Trocam o modelo por outro ainda mais rápido'),
    ('seed_ia_facil_v2', 'Por que prompts específicos podem produzir respostas melhores?', 3, 'Aumentam automaticamente a velocidade da internet', 'Aumentam a quantidade de dados guardados no sistema'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 0, 'Apenas quando está offline', 'Depende do tipo de computador'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 1, 'Apenas em computadores antigos', 'Quase nunca erra'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 2, 'Não, nunca', 'Não')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA fácil lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
