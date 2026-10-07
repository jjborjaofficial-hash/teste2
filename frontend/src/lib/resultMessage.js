/**
 * Mensagem de título da tela de resultado. Varia conforme o que aconteceu
 * (acerto, erro, tempo esgotado, subida de nível, marco de ofensiva, fim da rodada)
 * e conforme o histórico recente do usuário (sequência de acertos/erros seguidos),
 * e nunca repete a mesma frase duas vezes seguidas.
 * Nunca afirma "domínio" de um assunto por uma única resposta.
 */
const POOLS = {
  correct: [
    'Resposta certa! Muito bem.',
    'Acertou!',
    'É isso mesmo!',
    'Boa! Resposta correta.',
    'Certo! Continue assim.',
    'Mandou bem nessa!',
  ],
  correctStreak: [
    'Mais uma certa! Está num bom ritmo.',
    'Acertos seguidos, continue!',
    'Está a acertar em sequência!',
    'Que sequência! Mantenha o foco.',
  ],
  correctAfterWrong: [
    'Esta foi certa! Deu a volta por cima.',
    'Agora sim! Acertou.',
    'Boa recuperação!',
  ],
  wrong: [
    'Não foi desta vez. Veja a explicação.',
    'Resposta errada, mas dá para aprender com ela.',
    'Errou esta. Leia a explicação e siga em frente.',
    'Ninguém acerta tudo de primeira. Veja o porquê.',
  ],
  wrongStreak: [
    'Esta também não. Leia a explicação com calma.',
    'Está difícil? Veja a explicação antes da próxima.',
    'Respire e tente a próxima com calma.',
  ],
  timeExpired: ['O tempo acabou. Veja a resposta certa.', 'Faltou tempo desta vez.'],
  levelUp: ['Subiu de nível! Parabéns!', 'Novo nível alcançado! Muito bem.'],
  milestone: ['Marco de ofensiva alcançado! Parabéns!'],
  finished: {
    great: ['Rodada concluída com ótimo aproveitamento!', 'Excelente rodada!'],
    ok: ['Rodada concluída. Bom trabalho!', 'Rodada terminada. Veja o resumo.'],
    low: [
      'Rodada concluída. Revise o que errou e tente de novo.',
      'Terminou a rodada. Revisar ajuda a fixar.',
    ],
  },
};

const KEY = 'quiz:resultMessageHistory';

function readHistory() {
  try {
    const raw = JSON.parse(sessionStorage.getItem(KEY) || '{}');
    return {
      correctRun: Number(raw.correctRun) || 0,
      wrongRun: Number(raw.wrongRun) || 0,
      last: typeof raw.last === 'string' ? raw.last : '',
    };
  } catch {
    return { correctRun: 0, wrongRun: 0, last: '' };
  }
}

function writeHistory(h) {
  try {
    sessionStorage.setItem(KEY, JSON.stringify(h));
  } catch {
    /* sem armazenamento: a mensagem funciona, só não lembra o histórico */
  }
}

function pick(pool, last) {
  const options = pool.length > 1 ? pool.filter((m) => m !== last) : pool;
  return options[Math.floor(Math.random() * options.length)];
}

/** Escolhe a mensagem e atualiza o histórico. Chamar uma vez por resultado exibido. */
export function buildResultMessage(result) {
  const h = readHistory();
  const correct = Boolean(result.isCorrect);
  const next = {
    correctRun: correct ? h.correctRun + 1 : 0,
    wrongRun: correct ? 0 : h.wrongRun + 1,
  };

  let pool;
  if (result.roundSummary) {
    const pct = result.roundSummary.accuracyPercent;
    pool = pct >= 80 ? POOLS.finished.great : pct >= 50 ? POOLS.finished.ok : POOLS.finished.low;
  } else if (correct && result.leveledUp) pool = POOLS.levelUp;
  else if (correct && result.streakMilestoneReached) pool = POOLS.milestone;
  else if (correct && next.correctRun >= 3) pool = POOLS.correctStreak;
  else if (correct && h.wrongRun >= 1) pool = POOLS.correctAfterWrong;
  else if (correct) pool = POOLS.correct;
  else if (result.timeExpired) pool = POOLS.timeExpired;
  else if (next.wrongRun >= 2) pool = POOLS.wrongStreak;
  else pool = POOLS.wrong;

  const message = pick(pool, h.last);
  writeHistory({ ...next, last: message });
  return message;
}
