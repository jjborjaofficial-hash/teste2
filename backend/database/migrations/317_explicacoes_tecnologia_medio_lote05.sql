-- Explicações pedagógicas (BE-004) — Tecnologia médio lote 5: perguntas 22 a 41 do seed medio_v3 (migration 060).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e contexto, nível médio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 316. Só atualiza perguntas
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
    ('seed_tecnologia_medio_v3', 'O que é largura de banda?', 'Largura de banda é a capacidade de transmissão de dados de uma rede, ou seja, quantos dados podem passar por segundo. É diferente da latência, que é o atraso, e do número de dispositivos ou da velocidade do computador.'),
    ('seed_tecnologia_medio_v3', 'O que é um servidor web?', 'Servidor web é o servidor responsável por disponibilizar páginas e aplicações web aos navegadores que as pedem. Servidores de e-mail, de segurança ou de nomes (DNS) têm outras funções.'),
    ('seed_tecnologia_medio_v3', 'O que é HTTP?', 'HTTP é o protocolo usado para a comunicação entre o navegador e os servidores web: o navegador faz o pedido e o servidor devolve a página. Não é o protocolo de e-mail, nem a linguagem das páginas, nem o sistema de nomes.'),
    ('seed_tecnologia_medio_v3', 'O que significa HTTPS?', 'HTTPS é a versão segura do HTTP, que usa criptografia para proteger os dados trocados entre o navegador e o site. É o cadeado que aparece no endereço. Não é versão antiga, nem de armazenamento, nem móvel.'),
    ('seed_tecnologia_medio_v3', 'O que é um cookie de navegador?', 'Cookie é um pequeno arquivo que o site guarda no navegador para armazenar informações sobre a navegação, como o login ou o carrinho de compras. Não é um programa de proteção, nem um vírus, nem um anúncio.'),
    ('seed_tecnologia_medio_v3', 'O que é uma licença de software?', 'A licença de software é o conjunto de regras sobre o uso e a distribuição de um programa, definindo o que o usuário pode ou não fazer. Não é um código de acesso, um conjunto de arquivos nem uma lista de funções.'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção preventiva?', 'Manutenção preventiva é o conjunto de ações realizadas para evitar problemas futuros, como limpar equipamentos e atualizar sistemas. A que corrige problemas existentes é a corretiva, e trocar ou registrar são outras coisas.'),
    ('seed_tecnologia_medio_v3', 'O que é manutenção corretiva?', 'Manutenção corretiva é a reparação realizada depois de ocorrer uma falha, para devolver o equipamento ao funcionamento. A que se faz antes, para evitar a falha, é a preventiva.'),
    ('seed_tecnologia_medio_v3', 'O que é monitoramento de sistemas?', 'Monitoramento de sistemas é acompanhar o funcionamento e o desempenho dos serviços, para detectar problemas cedo. Configurar permissões, criar cópias ou atualizar versões são atividades diferentes.'),
    ('seed_tecnologia_medio_v3', 'O que é JSON?', 'JSON é um formato leve de dados, fácil de ler por pessoas e máquinas, muito usado na troca de dados entre sistemas, por exemplo em APIs. Não é um protocolo de envio, nem uma linguagem de estilo, nem um banco de dados.'),
    ('seed_tecnologia_medio_v3', 'O que é XML?', 'XML é uma linguagem de marcação usada para estruturar dados, por meio de etiquetas. Não é uma linguagem de programação, de consulta nem um formato de compressão.'),
    ('seed_tecnologia_medio_v3', 'O que é Git?', 'Git é um sistema de controle de versões de código: guarda o histórico das alterações e permite voltar atrás e trabalhar em equipe. Não é um armazenamento em nuvem, um editor ou um gerenciador de bancos de dados.'),
    ('seed_tecnologia_medio_v3', 'Para que serve o GitHub?', 'O GitHub serve para hospedar e colaborar em projetos de código, usando o Git, com revisão e histórico das mudanças. Não serve para distribuir vídeos, guardar fotos ou proteger contra vírus.'),
    ('seed_tecnologia_medio_v3', 'O que é debug?', 'Debug é o processo de encontrar e corrigir erros, os chamados bugs, em um software, analisando o comportamento do programa. Não é instalar peças, copiar dados nem monitorar acessos.'),
    ('seed_tecnologia_medio_v3', 'O que é compilador?', 'O compilador é o programa que transforma o código-fonte, escrito por pessoas, em código executável pela máquina. Não compacta o código, não procura vírus nem é o navegador que interpreta páginas.'),
    ('seed_tecnologia_medio_v3', 'O que é algoritmo?', 'Algoritmo é uma sequência de instruções para resolver um problema, como uma receita passo a passo. É a base de todo programa. Não é um conjunto de peças, um grupo de linhas nem um sinal de conexão.'),
    ('seed_tecnologia_medio_v3', 'O que é inteligência artificial generativa?', 'A inteligência artificial generativa é capaz de criar novos conteúdos, como textos, imagens ou códigos, a partir do que aprendeu com muitos dados. Classificar, detectar ameaças ou prever resultados são outros usos da IA.'),
    ('seed_tecnologia_medio_v3', 'O que é computação de borda (Edge Computing)?', 'Na computação de borda, o processamento acontece mais perto da origem dos dados, em vez de em servidores distantes, o que reduz o atraso. É o contrário de centralizar tudo na nuvem.'),
    ('seed_tecnologia_medio_v3', 'O que é transformação digital?', 'Transformação digital é usar tecnologia para melhorar processos e negócios, e não apenas trocar equipamentos. Usar papel, comprar computadores ou divulgar nas redes sociais, sozinhos, não são transformação digital.'),
    ('seed_tecnologia_medio_v3', 'O que é governança de TI?', 'Governança de TI é a gestão dos recursos tecnológicos alinhada aos objetivos da organização, para que a tecnologia traga valor e controle riscos. Não é vender recursos, gerir pessoas ou apenas comprar.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia médio lote 5: perguntas 22 a 41 do seed medio_v3 (migration 060): % pergunta(s) atualizada(s) (esperado: 20).', v_updated;
END $$;
