-- Alternativas (BE-003, regularização) — Marketing Digital fácil lote 3: 25 perguntas ativas seguintes (seed v3#2 a v3#27, saltando a v3#20 desativada).
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital usa a faixa de migrations 500+
-- (Finanças 144+, Produtividade 200+, Tecnologia 300+, IA 400+), para não colidir com as outras sessões.
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
    ('seed_marketing_digital_facil_v3', 'Qual destas plataformas é usada para Marketing Digital?', 3, 'BIOS', 'Excel'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 1, 'Apenas arquivos apagados', 'Material técnico guardado nos servidores da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 2, 'Somente códigos de programação', 'Conjunto de códigos de programação usados para construir um site ou aplicativo'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 3, 'Senhas de usuários', 'Dados de acesso dos usuários a uma plataforma'),
    ('seed_marketing_digital_facil_v3', 'O que significa público-alvo?', 1, 'Todos os computadores do mundo', 'Todas as pessoas que usam a internet no mundo inteiro'),
    ('seed_marketing_digital_facil_v3', 'O que significa público-alvo?', 2, 'Apenas funcionários', 'Equipe de funcionários que trabalha na empresa'),
    ('seed_marketing_digital_facil_v3', 'O que significa público-alvo?', 3, 'Concorrentes da empresa', 'Empresas que vendem produtos parecidos no mesmo mercado'),
    ('seed_marketing_digital_facil_v3', 'O que é anúncio online?', 0, 'Programa de computador', 'Programa instalado no computador para proteger contra vírus'),
    ('seed_marketing_digital_facil_v3', 'O que é anúncio online?', 1, 'Mensagem privada sem objetivo', 'Mensagem privada enviada a um único contato da lista'),
    ('seed_marketing_digital_facil_v3', 'O que é anúncio online?', 2, 'Arquivo pessoal', 'Arquivo guardado na nuvem para uso pessoal do usuário'),
    ('seed_marketing_digital_facil_v3', 'O que é uma campanha digital?', 1, 'Um banco de dados', 'Banco de dados onde a empresa guarda as informações dos clientes'),
    ('seed_marketing_digital_facil_v3', 'O que é uma campanha digital?', 2, 'Um jogo online', 'Jogo online em que a marca oferece prêmios aos participantes'),
    ('seed_marketing_digital_facil_v3', 'O que é uma campanha digital?', 3, 'Um sistema operacional', 'Sistema usado para controlar os computadores da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que significa a sigla SEO?', 2, 'System Engine Online', 'Site Engagement Operation'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 2, 'Um processador', 'Um componente que faz os cálculos do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 3, 'Uma placa gráfica', 'Uma placa que processa as imagens da tela'),
    ('seed_marketing_digital_facil_v3', 'O que é uma página de vendas?', 1, 'Página sem informação', 'Página com textos sobre a história da empresa e dos sócios'),
    ('seed_marketing_digital_facil_v3', 'O que é uma página de vendas?', 2, 'Página para instalar sistema operacional', 'Página usada para baixar e instalar atualizações do sistema'),
    ('seed_marketing_digital_facil_v3', 'O que é uma página de vendas?', 3, 'Página de jogos somente', 'Página onde os clientes enviam reclamações e pedidos de ajuda'),
    ('seed_marketing_digital_facil_v3', 'O que é um cliente?', 0, 'Servidor', 'Computador que armazena os dados de um site'),
    ('seed_marketing_digital_facil_v3', 'O que é um cliente?', 1, 'Programa de computador', 'Funcionário que atende as pessoas na empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é um cliente?', 3, 'Anúncio online', 'Anúncio pago publicado numa rede social'),
    ('seed_marketing_digital_facil_v3', 'O que é venda online?', 0, 'Venda somente em mercados físicos', 'Venda feita apenas em lojas e mercados físicos, com pagamento em dinheiro'),
    ('seed_marketing_digital_facil_v3', 'O que é venda online?', 1, 'Instalação de aplicativos', 'Instalação de programas e aplicativos no celular do cliente'),
    ('seed_marketing_digital_facil_v3', 'O que é venda online?', 3, 'Troca de arquivos', 'Troca de arquivos entre computadores da mesma rede'),
    ('seed_marketing_digital_facil_v3', 'O que é promoção?', 0, 'Bloqueio de anúncios', 'Bloqueio dos anúncios que aparecem durante a navegação'),
    ('seed_marketing_digital_facil_v3', 'O que é promoção?', 2, 'Formatação de computador', 'Limpeza e formatação do computador para melhorar o desempenho'),
    ('seed_marketing_digital_facil_v3', 'O que é promoção?', 3, 'Exclusão de clientes', 'Exclusão de clientes antigos da lista de contatos da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é engajamento?', 1, 'Número de computadores', 'Número de computadores ligados à rede da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é engajamento?', 2, 'Memória do celular', 'Capacidade de memória do celular usada para guardar fotos'),
    ('seed_marketing_digital_facil_v3', 'O que é engajamento?', 3, 'Velocidade da internet', 'Velocidade da internet disponível no local de trabalho'),
    ('seed_marketing_digital_facil_v3', 'O que é curtida em uma rede social?', 0, 'Compra automática', 'Compra feita de forma automática num site'),
    ('seed_marketing_digital_facil_v3', 'O que é curtida em uma rede social?', 1, 'Senha', 'Senha criada para entrar numa conta'),
    ('seed_marketing_digital_facil_v3', 'O que é curtida em uma rede social?', 3, 'Arquivo', 'Arquivo enviado por mensagem a outro usuário'),
    ('seed_marketing_digital_facil_v3', 'O que é influenciador digital?', 0, 'Administrador de banco', 'Profissional que administra os bancos de dados da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é influenciador digital?', 2, 'Criador de vírus', 'Pessoa que cria programas maliciosos para atacar sites'),
    ('seed_marketing_digital_facil_v3', 'O que é influenciador digital?', 3, 'Técnico de computador', 'Profissional que repara e configura computadores'),
    ('seed_marketing_digital_facil_v3', 'O que é CTA?', 0, 'Tipo de navegador', 'Tipo de navegador da internet'),
    ('seed_marketing_digital_facil_v3', 'O que é CTA?', 1, 'Sistema de pagamento', 'Sistema de pagamento online'),
    ('seed_marketing_digital_facil_v3', 'Qual exemplo é uma CTA?', 0, '"Computador desligado"', '"Computador desligado"'),
    ('seed_marketing_digital_facil_v3', 'Qual exemplo é uma CTA?', 1, '"Arquivo salvo"', '"Arquivo salvo"'),
    ('seed_marketing_digital_facil_v3', 'Qual exemplo é uma CTA?', 3, '"Senha alterada"', '"Senha alterada"'),
    ('seed_marketing_digital_facil_v3', 'O que é um lead?', 0, 'Funcionário interno', 'Funcionário responsável pelas vendas da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é um lead?', 2, 'Servidor', 'Servidor onde ficam guardadas as páginas do site'),
    ('seed_marketing_digital_facil_v3', 'O que é um lead?', 3, 'Programa de edição', 'Programa usado para editar imagens e vídeos'),
    ('seed_marketing_digital_facil_v3', 'O que é marketing de conteúdo?', 0, 'Criar hardware', 'Criar peças e equipamentos de computador para vender'),
    ('seed_marketing_digital_facil_v3', 'O que é marketing de conteúdo?', 1, 'Vender apenas presencialmente', 'Vender apenas de forma presencial, sem usar a internet'),
    ('seed_marketing_digital_facil_v3', 'O que é marketing de conteúdo?', 2, 'Bloquear clientes', 'Bloquear o acesso de clientes que não compram'),
    ('seed_marketing_digital_facil_v3', 'O que é um blog?', 0, 'Processador', 'Componente que executa as tarefas do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 0, 'Um funcionário real', 'Funcionário real que atende os clientes da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 1, 'Um aplicativo', 'Aplicativo de mensagens'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 2, 'Um computador', 'Computador usado pela equipe para gerir as redes sociais'),
    ('seed_marketing_digital_facil_v3', 'O que é análise de dados no Marketing Digital?', 0, 'Desligar anúncios', 'Desligar os anúncios que não vendem'),
    ('seed_marketing_digital_facil_v3', 'O que é análise de dados no Marketing Digital?', 1, 'Criar vírus', 'Criar programas para invadir contas de clientes'),
    ('seed_marketing_digital_facil_v3', 'O que é análise de dados no Marketing Digital?', 2, 'Apagar informações', 'Apagar as informações antigas dos clientes'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 0, 'Senha de usuário', 'Código usado pelo usuário para entrar na conta'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 3, 'Tipo de anúncio', 'Formato de anúncio usado nas redes sociais'),
    ('seed_marketing_digital_facil_v3', 'O que é uma agência digital?', 1, 'Loja de computadores', 'Loja que vende computadores e acessórios'),
    ('seed_marketing_digital_facil_v3', 'O que é uma agência digital?', 2, 'Banco físico', 'Banco com agências físicas em várias cidades'),
    ('seed_marketing_digital_facil_v3', 'O que é uma agência digital?', 3, 'Sistema operacional', 'Sistema que controla os programas do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é comércio eletrônico?', 0, 'Rede interna', 'Rede interna que liga os computadores de uma empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é comércio eletrônico?', 2, 'Venda somente em lojas físicas', 'Venda feita somente em lojas físicas'),
    ('seed_marketing_digital_facil_v3', 'O que é comércio eletrônico?', 3, 'Sistema de arquivos', 'Sistema que organiza os arquivos do computador')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital fácil lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 63).', v_updated;
END $$;
