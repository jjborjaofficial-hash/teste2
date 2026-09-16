/**
 * Configuração centralizada da Prova Social (SocialProofActivity).
 * Alterar aqui reflete automaticamente nos dois locais onde o
 * componente é usado (Onboarding e Dashboard).
 *
 * Nesta primeira versão, o "utilizadores ativos agora" é simulado
 * localmente (não vem do banco de dados) — variação suave dentro dos
 * limites abaixo, como pedido. Ponto de conexão futuro com dados reais:
 * o endpoint já existe e está testado em
 * backend/src/modules/platformStats (GET /api/v1/platform-stats) e em
 * frontend/src/components/LivePlatformStats.jsx — quando quiser trocar
 * a simulação por dados reais, é só usar esse componente/API no lugar
 * deste, ou fazer este componente consumi-lo como fonte do valor inicial.
 */
export const socialProofConfig = {
  // Linhas fixas da prova social (mantidas propositalmente sem ligação
  // ao banco de dados, por pedido explícito do produto).
  totalAtivosTexto: '12.000',
  totalRecompensasTexto: '46.000 MZN',

  // Contador "ativos agora" — simulado.
  ativacaoVariacao: true, // false = mostra só valorInicial, fixo, sem oscilar
  valorInicial: 1250,
  valorMinimo: 1100,
  valorMaximo: 1400,
  intervaloAtualizacaoMsMin: 2500, // cada "passo" ocorre entre 2,5s e 5s — frequente o suficiente para parecer vivo, sem ser irritante
  intervaloAtualizacaoMsMax: 5000,
  passoMaximoPercentual: 0.012, // passos pequenos e frequentes parecem mais reais do que saltos grandes e raros
  duracaoTransicaoMs: 900, // duração da animação de "subir/descer contando", não uma troca instantânea

  // Viés de tendência: a esmagadora maioria dos passos deve ser de
  // crescimento (ou neutro/estável) — uma plataforma "viva" perdendo
  // usuários visivelmente transmite a sensação errada (desmotiva quem
  // está decidindo se cria conta). Quedas continuam acontecendo (para
  // não parecer uma contagem artificialmente só-sobe), mas raras e
  // sempre bem menores que os aumentos.
  chanceDePassoPositivo: 0.78, // ~78% dos passos sobem ou ficam estáveis
  passoNegativoFatorReducao: 0.35, // quando desce, desce no máx. 35% do passo máximo normal
};
