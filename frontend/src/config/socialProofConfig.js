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
  intervaloAtualizacaoMsMin: 4000, // cada "passo" ocorre entre 4s e 8s (jitter, para não parecer robótico)
  intervaloAtualizacaoMsMax: 8000,
  passoMaximoPercentual: 0.03, // cada passo move no máx. 3% do intervalo [min,max] — mantém a variação "suave"
  duracaoTransicaoMs: 900, // velocidade da troca visual do número
};
