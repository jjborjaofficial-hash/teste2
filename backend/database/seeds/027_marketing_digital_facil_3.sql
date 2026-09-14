-- Seed: conteúdo Marketing Digital, nível Fácil (34 perguntas)
-- Fonte: lote "MARKETING DIGITAL — FÁCIL (49
-- questões)" fornecido pelo proprietário do projeto, filtrado para conter
-- apenas perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-026).
--
-- Das 49 perguntas do lote original, 15 já existiam
-- palavra-por-palavra no banco (repetições de seeds anteriores de Marketing
-- Digital) — foram descartadas. As 34 restantes são genuinamente novas e
-- entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (66 — distinta das seeds 42 a 65 já
-- usadas nos seeds anteriores) e distribuição controlada entre A/B/C/D,
-- reprodutível — o conteúdo pedagógico permanece exatamente como enviado,
-- só a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v3'
    FROM (VALUES
      ('Qual é o principal objetivo do Marketing Digital?'),
      ('Qual destes é um canal de Marketing Digital?'),
      ('Qual destas plataformas é usada para Marketing Digital?'),
      ('O que é conteúdo no Marketing Digital?'),
      ('O que significa público-alvo?'),
      ('O que é anúncio online?'),
      ('O que é uma campanha digital?'),
      ('O que significa a sigla SEO?'),
      ('O que é Google?'),
      ('O que é uma página de vendas?'),
      ('O que é um cliente?'),
      ('O que é venda online?'),
      ('O que é promoção?'),
      ('O que é engajamento?'),
      ('O que é curtida em uma rede social?'),
      ('O que é influenciador digital?'),
      ('O que é CTA?'),
      ('Qual exemplo é uma CTA?'),
      ('O que é um lead?'),
      ('O que é hashtag?'),
      ('O que é marketing de conteúdo?'),
      ('O que é um blog?'),
      ('O que é uma persona?'),
      ('O que é análise de dados no Marketing Digital?'),
      ('O que é métrica?'),
      ('O que é uma agência digital?'),
      ('O que é comércio eletrônico?'),
      ('O que é uma plataforma digital?'),
      ('Por que empresas usam Marketing Digital?'),
      ('O que é presença digital?'),
      ('O que é conteúdo patrocinado?'),
      ('O que é uma publicação?'),
      ('O que é algoritmo das redes sociais?'),
      ('O que é estratégia digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil3 q
    JOIN (VALUES
      ('Qual é o principal objetivo do Marketing Digital?', 'Criar apenas imagens', FALSE, 0),
      ('Qual é o principal objetivo do Marketing Digital?', 'Desligar anúncios online', FALSE, 1),
      ('Qual é o principal objetivo do Marketing Digital?', 'Atrair, comunicar e converter clientes pela internet', TRUE, 2),
      ('Qual é o principal objetivo do Marketing Digital?', 'Substituir todos os vendedores', FALSE, 3),
      ('Qual destes é um canal de Marketing Digital?', 'Cartaz na rua', FALSE, 0),
      ('Qual destes é um canal de Marketing Digital?', 'Panfleto impresso', FALSE, 1),
      ('Qual destes é um canal de Marketing Digital?', 'Redes sociais', TRUE, 2),
      ('Qual destes é um canal de Marketing Digital?', 'Rádio tradicional', FALSE, 3),
      ('Qual destas plataformas é usada para Marketing Digital?', 'Bloco de notas', FALSE, 0),
      ('Qual destas plataformas é usada para Marketing Digital?', 'Calculadora', FALSE, 1),
      ('Qual destas plataformas é usada para Marketing Digital?', 'Instagram', TRUE, 2),
      ('Qual destas plataformas é usada para Marketing Digital?', 'BIOS', FALSE, 3),
      ('O que é conteúdo no Marketing Digital?', 'Material criado para informar, atrair ou envolver pessoas', TRUE, 0),
      ('O que é conteúdo no Marketing Digital?', 'Apenas arquivos apagados', FALSE, 1),
      ('O que é conteúdo no Marketing Digital?', 'Somente códigos de programação', FALSE, 2),
      ('O que é conteúdo no Marketing Digital?', 'Senhas de usuários', FALSE, 3),
      ('O que significa público-alvo?', 'Grupo de pessoas que uma empresa deseja alcançar', TRUE, 0),
      ('O que significa público-alvo?', 'Todos os computadores do mundo', FALSE, 1),
      ('O que significa público-alvo?', 'Apenas funcionários', FALSE, 2),
      ('O que significa público-alvo?', 'Concorrentes da empresa', FALSE, 3),
      ('O que é anúncio online?', 'Programa de computador', FALSE, 0),
      ('O que é anúncio online?', 'Mensagem privada sem objetivo', FALSE, 1),
      ('O que é anúncio online?', 'Arquivo pessoal', FALSE, 2),
      ('O que é anúncio online?', 'Divulgação paga de produtos ou serviços na internet', TRUE, 3),
      ('O que é uma campanha digital?', 'Conjunto de ações planejadas para alcançar um objetivo', TRUE, 0),
      ('O que é uma campanha digital?', 'Um banco de dados', FALSE, 1),
      ('O que é uma campanha digital?', 'Um jogo online', FALSE, 2),
      ('O que é uma campanha digital?', 'Um sistema operacional', FALSE, 3),
      ('O que significa a sigla SEO?', 'Search Email Organization', FALSE, 0),
      ('O que significa a sigla SEO?', 'Search Engine Optimization', TRUE, 1),
      ('O que significa a sigla SEO?', 'System Engine Online', FALSE, 2),
      ('O que significa a sigla SEO?', 'Social Electronic Operation', FALSE, 3),
      ('O que é Google?', 'Um mecanismo de pesquisa online', TRUE, 0),
      ('O que é Google?', 'Um antivírus', FALSE, 1),
      ('O que é Google?', 'Um processador', FALSE, 2),
      ('O que é Google?', 'Uma placa gráfica', FALSE, 3),
      ('O que é uma página de vendas?', 'Página criada para apresentar e vender um produto ou serviço', TRUE, 0),
      ('O que é uma página de vendas?', 'Página sem informação', FALSE, 1),
      ('O que é uma página de vendas?', 'Página para instalar sistema operacional', FALSE, 2),
      ('O que é uma página de vendas?', 'Página de jogos somente', FALSE, 3),
      ('O que é um cliente?', 'Servidor', FALSE, 0),
      ('O que é um cliente?', 'Programa de computador', FALSE, 1),
      ('O que é um cliente?', 'Pessoa que compra ou utiliza um produto ou serviço', TRUE, 2),
      ('O que é um cliente?', 'Anúncio online', FALSE, 3),
      ('O que é venda online?', 'Venda somente em mercados físicos', FALSE, 0),
      ('O que é venda online?', 'Instalação de aplicativos', FALSE, 1),
      ('O que é venda online?', 'Comercialização de produtos ou serviços pela internet', TRUE, 2),
      ('O que é venda online?', 'Troca de arquivos', FALSE, 3),
      ('O que é promoção?', 'Bloqueio de anúncios', FALSE, 0),
      ('O que é promoção?', 'Estratégia para aumentar interesse em um produto ou serviço', TRUE, 1),
      ('O que é promoção?', 'Formatação de computador', FALSE, 2),
      ('O que é promoção?', 'Exclusão de clientes', FALSE, 3),
      ('O que é engajamento?', 'Interação das pessoas com um conteúdo ou marca', TRUE, 0),
      ('O que é engajamento?', 'Número de computadores', FALSE, 1),
      ('O que é engajamento?', 'Memória do celular', FALSE, 2),
      ('O que é engajamento?', 'Velocidade da internet', FALSE, 3),
      ('O que é curtida em uma rede social?', 'Compra automática', FALSE, 0),
      ('O que é curtida em uma rede social?', 'Senha', FALSE, 1),
      ('O que é curtida em uma rede social?', 'Forma de interação com um conteúdo', TRUE, 2),
      ('O que é curtida em uma rede social?', 'Arquivo', FALSE, 3),
      ('O que é influenciador digital?', 'Administrador de banco', FALSE, 0),
      ('O que é influenciador digital?', 'Pessoa que possui influência sobre uma audiência online', TRUE, 1),
      ('O que é influenciador digital?', 'Criador de vírus', FALSE, 2),
      ('O que é influenciador digital?', 'Técnico de computador', FALSE, 3),
      ('O que é CTA?', 'Tipo de navegador', FALSE, 0),
      ('O que é CTA?', 'Sistema de pagamento', FALSE, 1),
      ('O que é CTA?', 'Banco de dados', FALSE, 2),
      ('O que é CTA?', 'Chamada para ação', TRUE, 3),
      ('Qual exemplo é uma CTA?', '"Computador desligado"', FALSE, 0),
      ('Qual exemplo é uma CTA?', '"Arquivo salvo"', FALSE, 1),
      ('Qual exemplo é uma CTA?', '"Compre agora"', TRUE, 2),
      ('Qual exemplo é uma CTA?', '"Senha alterada"', FALSE, 3),
      ('O que é um lead?', 'Funcionário interno', FALSE, 0),
      ('O que é um lead?', 'Pessoa que demonstrou interesse em um produto ou serviço', TRUE, 1),
      ('O que é um lead?', 'Servidor', FALSE, 2),
      ('O que é um lead?', 'Programa de edição', FALSE, 3),
      ('O que é hashtag?', 'Palavra ou termo usado para organizar conteúdos nas redes sociais', TRUE, 0),
      ('O que é hashtag?', 'Senha de acesso', FALSE, 1),
      ('O que é hashtag?', 'Tipo de banco', FALSE, 2),
      ('O que é hashtag?', 'Programa de computador', FALSE, 3),
      ('O que é marketing de conteúdo?', 'Criar hardware', FALSE, 0),
      ('O que é marketing de conteúdo?', 'Vender apenas presencialmente', FALSE, 1),
      ('O que é marketing de conteúdo?', 'Bloquear clientes', FALSE, 2),
      ('O que é marketing de conteúdo?', 'Criar conteúdo para atrair e envolver pessoas', TRUE, 3),
      ('O que é um blog?', 'Processador', FALSE, 0),
      ('O que é um blog?', 'Plataforma de publicação de conteúdos', TRUE, 1),
      ('O que é um blog?', 'Antivírus', FALSE, 2),
      ('O que é um blog?', 'Sistema operacional', FALSE, 3),
      ('O que é uma persona?', 'Um funcionário real', FALSE, 0),
      ('O que é uma persona?', 'Um aplicativo', FALSE, 1),
      ('O que é uma persona?', 'Um computador', FALSE, 2),
      ('O que é uma persona?', 'Representação do cliente ideal de uma empresa', TRUE, 3),
      ('O que é análise de dados no Marketing Digital?', 'Desligar anúncios', FALSE, 0),
      ('O que é análise de dados no Marketing Digital?', 'Criar vírus', FALSE, 1),
      ('O que é análise de dados no Marketing Digital?', 'Apagar informações', FALSE, 2),
      ('O que é análise de dados no Marketing Digital?', 'Avaliação de informações para tomar melhores decisões', TRUE, 3),
      ('O que é métrica?', 'Senha de usuário', FALSE, 0),
      ('O que é métrica?', 'Medida usada para avaliar resultados', TRUE, 1),
      ('O que é métrica?', 'Sistema operacional', FALSE, 2),
      ('O que é métrica?', 'Tipo de anúncio', FALSE, 3),
      ('O que é uma agência digital?', 'Empresa especializada em estratégias digitais', TRUE, 0),
      ('O que é uma agência digital?', 'Loja de computadores', FALSE, 1),
      ('O que é uma agência digital?', 'Banco físico', FALSE, 2),
      ('O que é uma agência digital?', 'Sistema operacional', FALSE, 3),
      ('O que é comércio eletrônico?', 'Rede interna', FALSE, 0),
      ('O que é comércio eletrônico?', 'Compra e venda realizada pela internet', TRUE, 1),
      ('O que é comércio eletrônico?', 'Venda somente em lojas físicas', FALSE, 2),
      ('O que é comércio eletrônico?', 'Sistema de arquivos', FALSE, 3),
      ('O que é uma plataforma digital?', 'Cabo de rede', FALSE, 0),
      ('O que é uma plataforma digital?', 'Placa de computador', FALSE, 1),
      ('O que é uma plataforma digital?', 'Ambiente online que oferece serviços ou funcionalidades', TRUE, 2),
      ('O que é uma plataforma digital?', 'Processador', FALSE, 3),
      ('Por que empresas usam Marketing Digital?', 'Para desligar sistemas', FALSE, 0),
      ('Por que empresas usam Marketing Digital?', 'Para alcançar clientes e aumentar oportunidades de negócio', TRUE, 1),
      ('Por que empresas usam Marketing Digital?', 'Para substituir internet', FALSE, 2),
      ('Por que empresas usam Marketing Digital?', 'Para criar vírus', FALSE, 3),
      ('O que é presença digital?', 'Velocidade da rede', FALSE, 0),
      ('O que é presença digital?', 'Presença física em loja', FALSE, 1),
      ('O que é presença digital?', 'Memória do computador', FALSE, 2),
      ('O que é presença digital?', 'Existência e atuação de uma marca na internet', TRUE, 3),
      ('O que é conteúdo patrocinado?', 'Arquivo do sistema', FALSE, 0),
      ('O que é conteúdo patrocinado?', 'Conteúdo divulgado através de investimento financeiro', TRUE, 1),
      ('O que é conteúdo patrocinado?', 'Conteúdo apagado', FALSE, 2),
      ('O que é conteúdo patrocinado?', 'Conteúdo privado', FALSE, 3),
      ('O que é uma publicação?', 'Hardware', FALSE, 0),
      ('O que é uma publicação?', 'Programa instalado', FALSE, 1),
      ('O que é uma publicação?', 'Senha', FALSE, 2),
      ('O que é uma publicação?', 'Conteúdo compartilhado em uma plataforma digital', TRUE, 3),
      ('O que é algoritmo das redes sociais?', 'Uma senha', FALSE, 0),
      ('O que é algoritmo das redes sociais?', 'Um computador físico', FALSE, 1),
      ('O que é algoritmo das redes sociais?', 'Um cabo de internet', FALSE, 2),
      ('O que é algoritmo das redes sociais?', 'Sistema que organiza e entrega conteúdos aos usuários', TRUE, 3),
      ('O que é estratégia digital?', 'Plano organizado para alcançar objetivos usando meios digitais', TRUE, 0),
      ('O que é estratégia digital?', 'Troca de peças do computador', FALSE, 1),
      ('O que é estratégia digital?', 'Criação de vírus', FALSE, 2),
      ('O que é estratégia digital?', 'Instalação de aplicativos', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil3;

    RAISE NOTICE '34 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v3).';
  END IF;
END $$;

COMMIT;
