-- Explicações pedagógicas (BE-004) — Marketing Digital médio lote 1: 25 primeiras perguntas ativas do seed médio v1 (v1#2 a v1#26).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta, com raciocínio e relação entre conceitos (nível médio,
-- conforme docs/quiz-v2-rodadas-e-feedback.md). Só atualiza perguntas que ainda NÃO têm explicação, então é idempotente e
-- nunca sobrescreve texto já escrito. Não altera perguntas nem alternativas. Se alguma pergunta já não existir,
-- é simplesmente ignorada (nunca falha, para não impedir o arranque do backend: as migrations correm no deploy).
-- O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_marketing_digital_medio_v1', 'Por que criar uma persona pode ajudar no marketing?', 'Uma persona é um perfil fictício do cliente ideal, construído a partir de dados reais. Ao saber quem é, o que precisa e como decide, a equipe pode criar mensagens e ofertas mais relevantes. Isso melhora as chances de resultado, mas não as garante.'),
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 'O funil de vendas representa as etapas pelas quais um potencial cliente pode passar, da primeira descoberta até a conversão, como a compra. Ele ajuda a ver em que etapa as pessoas desistem e a ajustar a comunicação para cada fase.'),
    ('seed_marketing_digital_medio_v1', 'Qual pode ser uma etapa inicial de um funil?', 'No início do funil a pessoa ainda não conhece a marca nem o problema que ela resolve: é a fase de descoberta ou conscientização. Só depois vêm a consideração, a decisão e, por fim, a compra e o pós-venda.'),
    ('seed_marketing_digital_medio_v1', 'O que é conversão?', 'Conversão é a realização da ação definida como objetivo da campanha ou da página, como comprar, cadastrar-se ou pedir um orçamento. Curtidas, impressões e visitas mostram interesse, mas só contam como conversão se forem o objetivo definido.'),
    ('seed_marketing_digital_medio_v1', 'Qual destas pode ser uma conversão?', 'Uma compra é uma conversão porque é a ação final que muitas campanhas de venda procuram. Ver um anúncio, abrir o navegador ou receber uma notificação são passos anteriores, que não completam o objetivo.'),
    ('seed_marketing_digital_medio_v1', 'O que é taxa de conversão?', 'A taxa de conversão compara quantas pessoas realizaram a ação desejada com o total considerado: 20 compras em 1.000 visitas dão 2%. Ela mostra a eficiência da página ou da campanha, independentemente de quantas pessoas chegaram.'),
    ('seed_marketing_digital_medio_v1', 'O que é CTR?', 'CTR é a taxa de cliques: divide os cliques pelas impressões. Um CTR alto indica que o anúncio ou o elemento chamou a atenção, mas não diz se houve compra, que é medida por outras métricas, como a taxa de conversão.'),
    ('seed_marketing_digital_medio_v1', 'Se um anúncio recebe muitos cliques, mas poucas compras, o que pode ser investigado?', 'Muitos cliques e poucas compras sugerem que o anúncio atrai gente, mas o resto do caminho falha. Vale investigar a página de destino, a oferta, o público escolhido e se o anúncio prometeu o mesmo que o produto entrega.'),
    ('seed_marketing_digital_medio_v1', 'O que é CPC?', 'CPC é o custo por clique: quanto se paga, em média, cada vez que alguém clica no anúncio. Ajuda a comparar o custo de atrair visitas, mas um clique barato não significa venda, e por isso deve ser lido junto da conversão.'),
    ('seed_marketing_digital_medio_v1', 'O que é CPM?', 'CPM é o custo por mil impressões: quanto se paga para o anúncio ser exibido mil vezes. É útil quando o objetivo é alcance e reconhecimento da marca, porque o pagamento é pela exibição e não pelo clique.'),
    ('seed_marketing_digital_medio_v1', 'O que é CPA?', 'CPA é o custo por aquisição ou ação, conforme o objetivo definido na campanha, como uma compra, um cadastro ou uma instalação. Mostra quanto custa gerar o resultado que interessa, e não apenas cliques ou exibições.'),
    ('seed_marketing_digital_medio_v1', 'O que é CAC?', 'CAC é o custo de aquisição de cliente: quanto a empresa gasta, em marketing e vendas, para conquistar um novo cliente. Só compensa se o cliente gerar mais receita ao longo do tempo do que esse custo.'),
    ('seed_marketing_digital_medio_v1', 'O que é ROI em marketing?', 'ROI compara o retorno obtido com o investimento realizado. Se foram investidos 100 e o retorno foi 150, o ganho foi de 50, ou seja, 50% sobre o investido. Mede se a ação deu mais do que custou, e não apenas se teve atividade.'),
    ('seed_marketing_digital_medio_v1', 'O que é segmentação de público?', 'Segmentar o público é dividi-lo em grupos com características ou comportamentos semelhantes, como idade, interesses ou histórico de compra. Assim cada grupo recebe uma comunicação mais adequada, em vez de uma mensagem igual para todos.'),
    ('seed_marketing_digital_medio_v1', 'Por que segmentar campanhas?', 'Segmentar permite tentar apresentar mensagens mais relevantes a cada grupo, o que pode melhorar o desempenho. Não garante um resultado fixo, e por isso se acompanha a conversão de cada segmento.'),
    ('seed_marketing_digital_medio_v1', 'O que é remarketing?', 'Remarketing é a estratégia de alcançar de novo pessoas que já interagiram com a marca ou a oferta, por exemplo quem visitou a página e não comprou. Como já conhecem a marca, tendem a responder melhor do que um público totalmente novo.'),
    ('seed_marketing_digital_medio_v1', 'O que é teste A/B?', 'O teste A/B compara duas versões de um elemento, como um título ou um botão, para ver qual tem melhor desempenho segundo uma métrica escolhida. Muda-se uma coisa de cada vez, para saber o que causou a diferença.'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de teste A/B?', 'Comparar duas versões de um título de landing page é um teste A/B típico: muda-se só o título e mede-se qual gera mais conversões. Publicar sem medir não é teste, porque não permite concluir nada.'),
    ('seed_marketing_digital_medio_v1', 'O que é copywriting?', 'Copywriting é a técnica de escrever textos com o objetivo de comunicar, persuadir ou estimular uma ação, como clicar, comprar ou cadastrar-se. Não é programação nem edição: o foco é a palavra certa para o público certo.'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 'Prova social é a evidência de que outras pessoas usam, recomendam ou avaliam bem uma solução. As pessoas tendem a confiar mais no que outros já aprovaram, e por isso depoimentos e avaliações ajudam na decisão de compra.'),
    ('seed_marketing_digital_medio_v1', 'Qual é um exemplo de prova social?', 'O depoimento de um cliente é um exemplo de prova social, porque mostra que alguém real usou e aprovou a solução. Um anúncio da própria marca ou uma tabela de preços vêm da empresa e não funcionam como evidência de terceiros.'),
    ('seed_marketing_digital_medio_v1', 'O que é autoridade de marca?', 'Autoridade de marca é a percepção de que a marca tem conhecimento, credibilidade ou experiência num assunto. Constrói-se com conteúdo útil e resultados ao longo do tempo, e não com o tamanho da estrutura da empresa.'),
    ('seed_marketing_digital_medio_v1', 'O que é marketing de influência?', 'No marketing de influência, a marca usa pessoas com audiência ou influência para comunicar um produto ou serviço. A confiança que o público tem no influenciador ajuda a divulgar a marca, desde que o perfil combine com o público dela.'),
    ('seed_marketing_digital_medio_v1', 'O que é conteúdo viral?', 'Conteúdo viral é o que se espalha rapidamente entre muitas pessoas, sobretudo por compartilhamentos. A viralização depende do público e do momento e não pode ser garantida, mesmo com um bom conteúdo.'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 'Não. Uma publicação viral gera muito alcance, mas alcance não é lucro: o resultado depende de a oferta, o preço e a conversão fazerem sentido. Visualizações e curtidas não pagam custos.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND (q.explanation IS NULL OR btrim(q.explanation) = '');

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Marketing Digital médio lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
