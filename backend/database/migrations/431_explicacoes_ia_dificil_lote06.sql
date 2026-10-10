-- Explicações pedagógicas (BE-004) — IA difícil lote 6: as mesmas 10 perguntas da migration 430 (explicação curta e clara,
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
    ('seed_ia_dificil_v2', 'O que é auditoria de algoritmos?', 'Auditar algoritmos é examinar os modelos para encontrar problemas e riscos, como viés ou falhas, e verificar se cumprem as regras e normas aplicáveis.'),
    ('seed_ia_dificil_v2', 'Como reduzir alucinações em modelos de linguagem?', 'Para reduzir alucinações ajuda usar dados melhores, dar instruções claras ao modelo e ter sistemas que verifiquem as respostas, por exemplo consultando fontes.'),
    ('seed_ia_dificil_v2', 'O que é compressão de modelos?', 'Comprimir modelos é reduzir o seu tamanho e o custo de os executar, com técnicas como quantização, poda e destilação, para correrem em equipamentos mais modestos.'),
    ('seed_ia_dificil_v2', 'O que representa o peso em uma rede neural?', 'O peso é um número associado a cada ligação entre neurônios: quanto maior, mais essa ligação influencia o resultado. É o que o modelo ajusta ao aprender.'),
    ('seed_ia_dificil_v2', 'Qual é um dos maiores desafios atuais da Inteligência Artificial?', 'Um grande desafio é garantir que a IA seja segura, ética, transparente e usada de forma responsável, à medida que se torna mais poderosa e presente no dia a dia.'),
    ('seed_ia_dificil_v2', 'O que é aprendizado contínuo?', 'No aprendizado contínuo o sistema vai aprendendo à medida que recebe dados novos, sem ter de recomeçar o treino do zero. Permite acompanhar mudanças ao longo do tempo.'),
    ('seed_ia_dificil_v2', 'O que é aprendizado por transferência (Transfer Learning)?', 'No aprendizado por transferência usa-se um modelo já treinado numa tarefa como ponto de partida para outra tarefa parecida. Poupa tempo e dados.'),
    ('seed_ia_dificil_v2', 'O que é IA embarcada?', 'IA embarcada é a IA que corre dentro do próprio dispositivo ou equipamento, como um telemóvel, um carro ou uma câmara, sem depender sempre de servidores na nuvem.'),
    ('seed_ia_dificil_v2', 'O que é aprendizagem profunda (Deep Learning)?', 'Deep learning é a área da IA que usa redes neurais com muitas camadas. Cada camada aprende características cada vez mais abstratas, o que permite reconhecer padrões complexos em imagens, voz e texto.'),
    ('seed_ia_dificil_v2', 'O que é learning rate?', 'O learning rate (taxa de aprendizagem) define o tamanho de cada passo ao atualizar os parâmetros. Se for grande demais, o modelo oscila; se for pequeno demais, aprende devagar.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 6: % pergunta(s) atualizada(s) (esperado: 10).', v_updated;
END $$;
