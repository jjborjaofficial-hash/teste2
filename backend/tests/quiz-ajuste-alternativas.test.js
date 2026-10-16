/**
 * Teste de integração (PostgreSQL com migrations): ajustes de alternativas posteriores aos lotes
 * (migrations *_ajuste_alternativas_*.sql, BE-003). Garante que o texto novo está no banco, que a CERTA e a EXPLICAÇÃO não
 * mudaram, que as perguntas continuam com 4 alternativas e 1 correta, e que o validador já não as assinala.
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');
const { analyzeQuestion } = require('../src/modules/quiz/validation/alternativesValidator');
const { detectBias } = require('../src/modules/quiz/validation/biasDetector');

const dir = path.join(__dirname, '../database/migrations');
const files = fs.readdirSync(dir).filter((f) => /^\d+_ajuste_alternativas_.*\.sql$/.test(f)).sort();
const re = /^\s+\('(seed_[a-z_0-9]+)', '((?:[^']|'')+)', (\d), '((?:[^']|'')+)', '((?:[^']|'')+)'\),?$/gm;
const un = (s) => s.replace(/''/g, "'");
const adjustments = files.map((f) => {
  const sql = fs.readFileSync(path.join(dir, f), 'utf8');
  const expected = Number(/esperado: (\d+)/.exec(sql)[1]);
  const rows = [...sql.matchAll(re)].map((m) => ({ source: m[1], statement: un(m[2]), pos: Number(m[3]), oldLabel: un(m[4]), newLabel: un(m[5]) }));
  return { f, expected, rows };
});

// Se um ajuste posterior reescreveu a mesma alternativa, vale o texto mais recente.
const latest = new Map();
for (const a of adjustments) for (const r of a.rows) latest.set(`${r.source}|${r.statement}|${r.pos}`, r.newLabel);

// Certas e explicações que NÃO podem mudar (regra do dono), conferidas por texto.
const CORRECT = {
  'Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?': 'A margem de lucro pode diminuir',
  'O que é inflação esperada?': 'Previsão de aumento dos preços no futuro',
  'O que pode acontecer com o poder de compra quando os preços aumentam significativamente?': 'Pode diminuir',
  'Como uma taxa de juros alta pode afetar empréstimos?': 'Pode tornar o crédito mais caro',
  'O que é um conjunto de validação em Machine Learning?': 'Dados utilizados para avaliar e ajustar escolhas do modelo durante o desenvolvimento',
  'Em criptografia assimétrica, qual característica é correta?': 'Utiliza um par de chaves relacionadas, normalmente uma pública e uma privada',
  'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?': 'Regularização',
  'O que é computação em nuvem híbrida?': 'Modelo que combina infraestrutura local com serviços de nuvem',
  'O que é consistência eventual?': 'Modelo em que réplicas podem ficar temporariamente diferentes, mas tendem a convergir',
  'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?': 'A simétrica utiliza uma chave compartilhada para cifrar e decifrar, enquanto a assimétrica utiliza um par de chaves',
  'Qual é a principal finalidade de uma arquitetura de microsserviços?': 'Dividir uma aplicação grande em pequenos serviços independentes que comunicam entre si',
  "O que é balanço patrimonial?": "Relatório que apresenta ativos, passivos e patrimônio líquido",
  "Qual atitude representa consumo consciente?": "Avaliar necessidade, preço e qualidade antes da compra",
  "Qual é a principal finalidade de um orçamento pessoal?": "Controlar receitas e despesas",
  "Se um investimento cresce por capitalização composta, qual tende a ser o efeito de deixar os rendimentos investidos?": "Os rendimentos podem passar a gerar novos rendimentos",
  "Uma empresa aumenta suas vendas, mas seus custos crescem ainda mais rapidamente. O que pode acontecer?": "A margem de lucro pode diminuir",
  "Qual é a diferença entre taxa de juro fixa e taxa de juro variável?": "A fixa permanece igual durante o contrato; a variável pode mudar conforme condições de mercado",
  "Qual é uma vantagem de comparar preços antes de comprar?": "Pode ajudar a encontrar melhor custo-benefício",
  "Por que liquidez e rentabilidade podem entrar em conflito em algumas situações?": "Um investimento mais rentável pode exigir prazo maior ou apresentar menor facilidade de resgate",
  "O que é sustentabilidade financeira?": "Capacidade de manter equilíbrio financeiro ao longo do tempo",
  "O que caracteriza uma despesa variável?": "Pode mudar de valor de um período para outro",
  "O que é orçamento empresarial?": "Planejamento das receitas, despesas e investimentos de uma empresa",
  "O que acontece quando alguém atrasa um pagamento?": "Pode pagar juros ou multas",
  "O que é EBITDA?": "Indicador que mostra desempenho operacional antes de juros, impostos, depreciação e amortização",
  "O que é demonstração de resultados?": "Relatório que mostra receitas, custos e lucro ou prejuízo de uma empresa",
  "O que representa o valor do dinheiro no tempo?": "Uma quantia disponível hoje pode ter valor econômico diferente da mesma quantia recebida no futuro",
  "O que é derivativo financeiro?": "Instrumento cujo valor depende de outro ativo de referência",
  "O que é uma despesa fixa?": "Despesa que acontece regularmente com valor semelhante",
  "O que é um objetivo financeiro de curto prazo?": "Meta que pode ser alcançada em pouco tempo",
  "O que é deflação?": "Redução geral dos preços de produtos e serviços",
  "O que é análise fundamentalista de empresas?": "Avaliação de indicadores financeiros, resultados e perspectivas de uma empresa",
  "O que é renda variável?": "Investimento cujo retorno pode variar conforme o mercado",
  "O que é margem de lucro?": "Relação entre o lucro e a receita, geralmente expressa em percentual",
  "Qual destes é um exemplo de despesa fixa?": "Aluguel",
  "O que é renda fixa?": "Investimento com regras de remuneração definidas previamente",
  "Por que o cheque especial deve ser usado com cuidado?": "Porque geralmente possui juros elevados",
  "O que pode acontecer com o poder de compra quando os preços aumentam significativamente?": "Pode diminuir",
  "O que é análise de viabilidade financeira?": "Avaliação para saber se um projeto pode gerar resultados positivos",
  "O que é uma despesa variável?": "Gasto que pode mudar de valor conforme o período",
  "Por que um bom score de crédito é importante?": "Pode facilitar acesso a crédito em melhores condições",
  "Por que correlação entre ativos pode ser relevante na diversificação?": "Porque ativos com comportamentos diferentes podem reduzir a concentração do risco da carteira",
  "Por que manter um bom histórico de pagamentos pode ser importante?": "Pode facilitar a obtenção de crédito em condições melhores no futuro",
  "Qual é uma boa prática para melhorar a saúde financeira?": "Controlar gastos, criar reservas e planejar objetivos",
  "O que é recessão econômica?": "Período de redução significativa da atividade econômica",
  "O que é custo fixo?": "Custo que permanece relativamente constante independentemente da produção",
  "Qual é a relação entre risco e retorno em investimentos?": "Em geral, maiores retornos potenciais costumam estar associados a maiores riscos",
  "Qual é o efeito de uma taxa de juros sobre uma dívida?": "Pode aumentar o custo total do empréstimo",
  "O que é um ativo financeiro?": "Recurso que possui valor econômico e pode gerar retorno",
  "O que é uma ação?": "Pequena participação na propriedade de uma empresa",
  "O que é risco não sistêmico?": "Risco específico de uma empresa ou setor que pode ser reduzido pela diversificação",
  "O que pode acontecer quando uma pessoa toma decisões financeiras baseadas apenas em emoções?": "Pode aumentar a probabilidade de decisões impulsivas e inadequadas",
  "Qual é uma característica de uma decisão financeira bem fundamentada?": "Considera objetivos, custos, riscos, alternativas e capacidade financeira",
  "O que acontece quando uma pessoa gasta continuamente mais do que recebe?": "Pode acumular dívidas",
  "O que é o limite de crédito de um cartão?": "O valor máximo que pode ser utilizado através do cartão",
  "Qual é o efeito dos juros compostos em investimentos de longo prazo?": "Podem aumentar significativamente o crescimento do dinheiro",
  "O que significa diversificar investimentos?": "Distribuir recursos entre diferentes investimentos",
  "Por que é importante guardar comprovativos de pagamentos relevantes?": "Podem servir como evidência da transação",
  "O que é liquidez de um investimento?": "Facilidade e rapidez com que o investimento pode ser convertido em dinheiro sem perda significativa de valor, dependendo do mercado",
  "Por que uma reserva de emergência deve ser relativamente acessível?": "Porque pode ser necessária para despesas inesperadas",
  "O que é previsão financeira?": "Estimativa futura de receitas, despesas e resultados financeiros",
  "Por que a taxa de inflação é importante para decisões financeiras de longo prazo?": "Porque pode reduzir o poder de compra das quantias ao longo do tempo",
  "Qual destes pode ser considerado um gasto com transporte?": "Passagem de autocarro",
  "O que pode acontecer se uma pessoa ignora repetidamente suas obrigações financeiras?": "Pode acumular encargos, atrasos e outros problemas financeiros",
  "O que é gestão de risco financeiro?": "Processo de identificar, analisar e controlar riscos financeiros",
  "Como a inflação pode afetar o dinheiro?": "Pode reduzir o poder de compra",
  "O que é ponto de equilíbrio financeiro de uma atividade?": "Nível em que receitas são suficientes para cobrir determinados custos e despesas considerados",
  "Antes de contratar um empréstimo, é importante verificar:": "Taxas, prazo e custo total",
  "O que é um desejo financeiro?": "Algo que queremos, mas não é essencial",
  "O que é uma alucinação em um modelo generativo?": "Produção de conteúdo que parece plausível, mas contém informação incorreta ou inventada",
  "Para que pode ser usada uma IA generativa?": "Para criar conteúdos como textos, imagens, áudio ou código",
  "Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?": "Pode ajudar a identificar erros, justificar decisões e aumentar a confiança no sistema",
  "Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?": "O sistema baseado em regras depende de regras explicitamente definidas, enquanto o aprendizado de máquina pode aprender padrões a partir de dados",
  "Qual característica tende a melhorar um prompt?": "Instruções claras, contexto relevante e objetivo bem definido",
  "Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?": "O treinamento pode oscilar ou não encontrar uma solução adequada",
  "O que é um dataset?": "Conjunto organizado de dados utilizado para análise, treinamento ou avaliação",
  "Qual é uma limitação importante dos sistemas de IA?": "Podem produzir resultados incorretos ou inadequados",
  "O que é inferência em inteligência artificial?": "Utilização de um modelo treinado para produzir resultados a partir de novos dados",
  "O que é um filtro de spam baseado em IA?": "Sistema que utiliza padrões aprendidos para identificar e bloquear mensagens indesejadas",
  "Qual é uma limitação comum dos sistemas de IA?": "Podem produzir resultados incorretos",
  "O que é limpeza de dados?": "Processo de identificar e corrigir ou tratar problemas como erros, duplicações ou valores ausentes",
  "Por que código gerado por IA deve ser revisado?": "Pode conter erros, vulnerabilidades ou lógica inadequada",
  "O que é overfitting?": "Quando um modelo se adapta excessivamente aos dados de treinamento e pode ter desempenho pior em dados novos",
  "Por que a supervisão humana pode ser importante?": "Para identificar erros, riscos ou decisões inadequadas",
  "Por que fornecer contexto adequado a uma IA pode melhorar a resposta?": "Ajuda o modelo a compreender melhor o objetivo, as restrições e a situação",
  "O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?": "A qualidade dos resultados pode ser prejudicada",
  "Por que a qualidade dos dados é importante?": "Dados inadequados podem prejudicar o treinamento e o desempenho do modelo",
  "Uma IA pode cometer erros?": "Sim",
  "O que é automação inteligente?": "Combinação de automação com técnicas de IA para lidar com determinadas tarefas ou decisões",
  "Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?": "Compreender sua finalidade, limitações e regras de utilização",
  "Para que serve o reconhecimento de voz?": "Transformar comandos falados em informação que um sistema pode processar",
  "A IA consegue sempre fornecer respostas corretas?": "Não",
  "O que é recomendação baseada em IA?": "Sugestão de conteúdos, produtos ou ações com base em dados e padrões",
  "Por que os dados são importantes para muitos sistemas de IA?": "Podem ser usados para treinar, avaliar ou alimentar modelos",
  "Por que a tokenização é importante em modelos de linguagem?": "Converte texto em unidades que podem ser processadas pelo modelo",
  "O que é engenharia de características (feature engineering)?": "Processo de criar, transformar ou selecionar características úteis para um modelo",
  "Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?": "Possível overfitting",
  "Por que os dados são importantes para muitos sistemas de inteligência artificial?": "Podem fornecer exemplos e informações usados para identificar padrões e melhorar modelos",
  "O que é viés em IA?": "Tendência sistemática que pode influenciar resultados",
  "Qual é uma estratégia eficiente para lidar com tarefas recorrentes?": "Criar uma rotina, checklist ou automação quando apropriado",
  "O que significa planejar o dia?": "Definir antecipadamente as principais atividades e prioridades",
  "Qual é o risco de um planejamento excessivamente rígido?": "Pequenos imprevistos podem comprometer toda a programação",
  "Qual destas ações ajuda a reduzir distrações?": "Desativar notificações desnecessárias",
  "Qual é uma consequência direta de requisitos pouco claros?": "Aumento da probabilidade de retrabalho",
  "Qual é uma vantagem de manter o espaço de trabalho organizado?": "Facilita encontrar materiais",
  "Por que tarefas cognitivamente exigentes podem ser planejadas para períodos de maior energia?": "Porque a capacidade de concentração pode variar ao longo do dia",
  "O que é intenção de implementação?": "Planejamento no formato \"se acontecer X, então farei Y\"",
  "Por que sobrecarregar uma agenda pode reduzir a produtividade?": "Porque diminui a margem para imprevistos, aumenta pressão e pode gerar atrasos",
  "Por que rever premissas pode ser importante?": "Porque mudanças nas condições podem tornar o plano inadequado",
  "Qual atitude contribui para uma melhor gestão das tarefas?": "Definir o que fazer, quando fazer e qual a prioridade",
  "O que é princípio 80/20, também conhecido como princípio de Pareto?": "Ideia de que uma parcela relativamente pequena de causas pode responder por uma parcela significativa dos resultados em determinados contextos",
  "Qual é uma boa prática para organizar as tarefas do dia?": "Definir prioridades",
  "O que transforma um plano em um sistema de execução mais robusto?": "Responsáveis, prazos, prioridades e acompanhamento",
  "Como a Lei de Parkinson pode influenciar o planejamento?": "Prazos excessivamente longos podem favorecer a expansão desnecessária do trabalho",
  "Qual pergunta é adequada para uma retrospectiva de produtividade?": "\"O que posso mudar na próxima semana para trabalhar melhor?\"",
  "Qual é uma finalidade da revisão semanal?": "Analisar resultados, identificar pendências e planejar a próxima semana",
  "Um profissional quer reduzir o tempo gasto numa atividade repetitiva. Qual sequência é mais racional?": "Medir o processo, identificar desperdícios e depois automatizar quando apropriado",
  "O que significa limitar o trabalho em andamento?": "Controlar quantas tarefas podem estar simultaneamente em execução",
  "O que significa organizar informações?": "Estruturar dados de maneira que sejam mais fáceis de encontrar e utilizar",
  "Como o efeito Zeigarnik pode afetar a produtividade?": "Pendências mal organizadas podem continuar ocupando atenção mental",
  "O que significa priorizar?": "Definir quais atividades devem receber atenção primeiro",
  "O que é trabalho profundo?": "Período de concentração intensa em uma atividade cognitivamente exigente, com poucas distrações",
  "O que é uma tarefa de alto impacto?": "Uma atividade que pode produzir contribuição significativa para um objetivo importante",
  "O que é planejamento de capacidade?": "Avaliação de quanto trabalho pode ser realisticamente realizado com os recursos e tempo disponíveis",
  "Por que as prioridades devem ser revisadas periodicamente?": "Porque prazos, informações, recursos e objetivos podem mudar",
  "O que significa concentrar-se?": "Direcionar a atenção para determinada atividade",
  "O que é funil de vendas?": "Modelo que representa etapas pelas quais potenciais clientes podem passar até uma conversão",
  "O que é conteúdo no Marketing Digital?": "Material criado para informar, atrair ou envolver pessoas",
  "O que é Google?": "Um mecanismo de pesquisa online",
  "O que é métrica?": "Medida usada para avaliar resultados",
  "O que significa publicar conteúdo regularmente?": "Manter uma frequência planejada de publicação",
  "O que é prova social?": "Evidência de outras pessoas utilizando, recomendando ou avaliando positivamente uma solução",
  "O que é uma descrição de produto?": "Texto que apresenta características, benefícios ou informações sobre o produto",
  "Para que serve o perfil de uma empresa em uma rede social?": "Apresentar a marca, seus produtos, serviços ou conteúdos ao público",
  "O que é uma persona?": "Representação do cliente ideal de uma empresa",
  "Por que uma empresa cria conteúdos na internet?": "Para atrair, informar e criar relacionamento com o público",
  "Para que serve uma palavra-chave no marketing digital?": "Ajudar a representar termos que usuários podem pesquisar e orientar conteúdos ou campanhas",
  "O que é um blog?": "Plataforma de publicação de conteúdos",
  "Uma publicação viral garante lucro?": "Não",
  "O que é tráfego em marketing digital?": "Visitas ou acessos recebidos por um site, página ou canal digital",
  "O que é uma plataforma digital?": "Ambiente online que oferece serviços ou funcionalidades",
  "O que é email marketing?": "Uso de emails para comunicação, relacionamento ou promoção junto a contatos",
  "Qual é o principal objetivo do Marketing Digital?": "Atrair, comunicar e converter clientes pela internet",
  "O que é uma marca no Marketing Digital?": "Identidade que representa uma empresa, produto ou serviço",
};

afterAll(async () => {
  await db.pool.end();
});

test('existe pelo menos um ajuste', () => {
  expect(adjustments.length).toBeGreaterThan(0);
});

describe.each(adjustments)('ajuste $f', ({ expected, rows }) => {
  test('traz o número de trocas anunciado', () => {
    expect(rows.length).toBe(expected);
  });

  test('o texto novo está no banco, em alternativas erradas, na mesma posição', async () => {
    for (const r of rows) {
      const { rows: found } = await db.query(
        `SELECT a.label, a.is_correct FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 AND a.display_order = $3`,
        [r.source, r.statement, r.pos]
      );
      expect(found).toHaveLength(1);
      expect(found[0].label).toBe(latest.get(`${r.source}|${r.statement}|${r.pos}`));
      expect(found[0].is_correct).toBe(false);
    }
  });

  test('a certa não mudou, as perguntas mantêm 4 alternativas e 1 correta, e a explicação continua preenchida', async () => {
    const keys = [...new Set(rows.map((r) => `${r.source}|${r.statement}`))];
    for (const k of keys) {
      const [source, statement] = k.split('|');
      const { rows: alts } = await db.query(
        `SELECT a.label, a.is_correct, q.explanation FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 ORDER BY a.display_order`,
        [source, statement]
      );
      expect(alts).toHaveLength(4);
      expect(alts.filter((a) => a.is_correct)).toHaveLength(1);
      // Só confere o texto da certa quando ele está listado acima; nos demais (ex.: Produtividade, migration 290) o teste de
      // posição já garante que só mudaram alternativas ERRADAS (is_correct = false) e que continua a existir 1 só correta.
      if (CORRECT[statement]) expect(alts.find((a) => a.is_correct).label).toBe(CORRECT[statement]);
      expect(alts[0].explanation).toBeTruthy();
    }
  });

  test('o validador já não assinala estas perguntas e não há bloqueio de viés', async () => {
    const keys = [...new Set(rows.map((r) => `${r.source}|${r.statement}`))];
    for (const k of keys) {
      const [source, statement] = k.split('|');
      const { rows: alts } = await db.query(
        `SELECT a.label, a.is_correct FROM questions q JOIN question_alternatives a ON a.question_id = q.id
          WHERE q.source = $1 AND q.statement = $2 ORDER BY a.display_order`,
        [source, statement]
      );
      const q = { id: k, alternatives: alts };
      expect(analyzeQuestion(q).reasons).toEqual([]);
      expect(detectBias(q).blockers).toEqual([]);
    }
  });
});
