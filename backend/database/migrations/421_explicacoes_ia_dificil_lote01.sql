-- Explicações pedagógicas (BE-004) — IA difícil lote 1: as mesmas 25 perguntas da migration 420 (explicação curta e clara,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_ia_dificil_v1', 'O que é concept drift?', 'Concept drift é quando a relação entre os dados de entrada e o resultado esperado muda com o tempo, e o que o modelo aprendeu deixa de valer. Por isso os modelos em produção precisam de acompanhamento.'),
    ('seed_ia_dificil_v1', 'Qual é uma finalidade do RLHF?', 'RLHF é aprendizado por reforço com feedback humano: pessoas avaliam as respostas do modelo e ele é ajustado para se aproximar do que elas preferem. Serve para tornar o comportamento mais útil e seguro.'),
    ('seed_ia_dificil_v1', 'Por que concept drift é relevante em sistemas de IA em produção?', 'Em produção o mundo muda: hábitos, preços, linguagem. Um modelo treinado com dados do passado pode ficar menos preciso quando os padrões mudam, por isso é preciso monitorá-lo e, se for o caso, treiná-lo de novo.'),
    ('seed_ia_dificil_v1', 'Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 'Um modelo pode acertar muito nos testes e mesmo assim falhar no uso real: ser lento, caro, injusto com certos grupos ou frágil perante dados novos. Por isso se avaliam também segurança, robustez, justiça, custo e generalização.'),
    ('seed_ia_dificil_v1', 'O que caracteriza um embedding contextual?', 'Num embedding contextual a mesma palavra recebe vetores diferentes conforme a frase: "banco" de sentar e "banco" de dinheiro não ficam iguais. Os modelos modernos, como os Transformers, fazem isso.'),
    ('seed_ia_dificil_v1', 'O que é transfer learning?', 'No transfer learning, o que o modelo aprendeu numa tarefa serve de ponto de partida para outra. Poupa dados e tempo, porque não se começa do zero.'),
    ('seed_ia_dificil_v1', 'O que é quantização de um modelo de IA?', 'Quantizar é guardar os números do modelo com menos bits, por exemplo inteiros de 8 bits em vez de decimais de 32. O modelo fica menor e mais rápido, com uma pequena perda de qualidade.'),
    ('seed_ia_dificil_v1', 'Em um Transformer, por que são necessárias informações posicionais?', 'A atenção compara todos os tokens ao mesmo tempo e, sozinha, não sabe qual veio primeiro. As informações posicionais dizem ao modelo a ordem das palavras, que muda o sentido da frase.'),
    ('seed_ia_dificil_v1', 'Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 'Se 95% dos casos são de uma classe, um modelo que responde sempre essa classe tem 95% de acurácia mas não deteta nenhum caso da outra. Por isso se usam também métricas como recall e F1.'),
    ('seed_ia_dificil_v1', 'O que é exploração no contexto de aprendizado por reforço?', 'Exploração é o agente testar ações novas, mesmo sem saber se são boas, para descobrir as recompensas. Contrasta com aproveitar o que já se sabe (explotação), e é preciso equilibrar as duas coisas.'),
    ('seed_ia_dificil_v1', 'Uma perplexidade menor geralmente indica:', 'Perplexidade mede o quanto o modelo se surpreende com o texto: quanto menor, melhor ele prevê os tokens seguintes. A comparação só é justa se os modelos forem avaliados nas mesmas condições.'),
    ('seed_ia_dificil_v1', 'Por que modelos modernos utilizam embeddings?', 'Computadores trabalham com números, não com palavras. O embedding transforma cada token num vetor contínuo, onde tokens com sentidos próximos ficam perto uns dos outros.'),
    ('seed_ia_dificil_v1', 'O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 'No supervisionado o modelo aprende com exemplos que já têm a resposta (rótulo). No não supervisionado não há rótulos, e o modelo procura estruturas nos dados, como grupos parecidos.'),
    ('seed_ia_dificil_v1', 'Em aprendizado por reforço, o que representa a função de valor?', 'A função de valor estima quanta recompensa o agente espera acumular a partir de um estado (ou de um par estado-ação). Não é a recompensa imediata, e sim a expectativa do que vem a seguir.'),
    ('seed_ia_dificil_v1', 'Qual é uma possível vantagem da quantização?', 'Com números de menor precisão o modelo ocupa menos memória e, em alguns casos, corre mais depressa. Em troca, pode haver uma pequena perda de precisão.'),
    ('seed_ia_dificil_v1', 'Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 'Na retropropagação o gradiente passa por muitas camadas e pode ir encolhendo até quase zero. Assim as primeiras camadas quase não aprendem. Funções como a ReLU e conexões residuais ajudam a evitar isso.'),
    ('seed_ia_dificil_v1', 'O que é data leakage em aprendizado de máquina?', 'Há data leakage quando o modelo, no treino, tem acesso a informação que só existiria depois, como dados do conjunto de teste ou do futuro. As métricas ficam otimistas demais e o modelo falha no mundo real.'),
    ('seed_ia_dificil_v1', 'O que caracteriza aprendizado auto-supervisionado?', 'No auto-supervisionado o próprio dado fornece a "resposta": por exemplo, esconder uma palavra do texto e pedir ao modelo que a preveja. Assim se aprende com enormes quantidades de dados sem rótulos humanos.'),
    ('seed_ia_dificil_v1', 'O que é RAG (Retrieval-Augmented Generation)?', 'RAG junta busca e geração: primeiro recupera trechos relevantes de documentos ou bases externas e depois o modelo usa esse material para escrever a resposta. Ajuda a dar respostas mais atuais e fundamentadas.'),
    ('seed_ia_dificil_v1', 'Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 'Num sistema RAG os textos viram vetores (embeddings). Um banco vetorial guarda esses vetores e encontra depressa os mais parecidos com a pergunta, mesmo que as palavras não sejam iguais.'),
    ('seed_ia_dificil_v1', 'Qual é uma limitação importante do beam search em geração de texto?', 'O beam search segue várias sequências ao mesmo tempo e fica com as mais prováveis. Mas a mais provável nem sempre é a mais natural: o texto pode sair repetitivo ou sem graça.'),
    ('seed_ia_dificil_v1', 'Qual é o principal objetivo do algoritmo Q-learning?', 'Q-learning aprende uma função Q que diz quão boa é cada ação em cada estado. Com ela, o agente escolhe as ações de maior valor, sem precisar de um modelo do ambiente.'),
    ('seed_ia_dificil_v1', 'Em um sistema RAG, qual é a função do retriever?', 'O retriever é a parte que procura: dada a pergunta, devolve os documentos ou trechos mais relevantes. Depois, o gerador (o LLM) usa esse material para escrever a resposta.'),
    ('seed_ia_dificil_v1', 'Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 'Alucinação é o modelo inventar coisas com ar de certeza. Dar-lhe contexto confiável, deixá-lo consultar fontes e verificar o resultado reduz o risco.'),
    ('seed_ia_dificil_v1', 'O que é knowledge distillation?', 'Na destilação, um modelo grande (professor) ensina um modelo pequeno (aluno) a imitar as suas respostas. O aluno fica mais leve e rápido, com desempenho próximo ao do professor.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
