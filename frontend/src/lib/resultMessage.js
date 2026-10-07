/**
 * Mensagens da tela de resultado: um TÍTULO e uma LINHA DE CONTEXTO.
 *
 * Objetivo: o utilizador sentir que a plataforma conhece a situação e o progresso dele.
 * - O título depende do que acabou de acontecer (acerto, erro, tempo esgotado, subida de
 *   nível, marco de ofensiva, fim da rodada) e do histórico recente (acertos/erros seguidos,
 *   primeira pergunta da rodada, recuperação depois de errar, fim de uma sequência).
 * - A linha de contexto usa números reais vindos do servidor (dias de ofensiva, acertos da
 *   rodada, quantas faltam) — nunca inventa dados.
 * - A mesma frase nunca sai duas vezes seguidas. Nunca afirma "domínio" por uma resposta só.
 */
const POOLS = {
  correct: [
    'Resposta certa! Muito bem.',
    'Acertou!',
    'É isso mesmo!',
    'Boa! Resposta correta.',
    'Certo! Continue assim.',
    'Mandou bem nessa!',
    'Era essa mesmo!',
    'Perfeito, acertou em cheio.',
    'Resposta correta, parabéns!',
    'Muito bem! Mais uma certa.',
  ],
  correctFirst: [
    'Começou bem! Primeira certa da rodada.',
    'Boa abertura, acertou logo a primeira!',
    'Primeira certa! Bom começo.',
    'Arrancou com o pé direito!',
    'Começo certeiro! Siga assim.',
  ],
  correctStreak: [
    'Mais uma certa! Está num bom ritmo.',
    'Acertos seguidos, continue!',
    'Está a acertar em sequência!',
    'Que sequência! Mantenha o foco.',
    'Já é a terceira certa seguida!',
    'Está a rolar bem. Não pare agora!',
    'Está concentrado, dá para ver!',
    'Sequência a crescer, continue!',
  ],
  correctStreakLong: [
    'Cinco certas seguidas, que sequência!',
    'Está imparável! Continue assim.',
    'Que concentração! Mais uma certa.',
    'Sequência de campeão, não pare!',
    'Está a voar! Acertos em cadeia.',
  ],
  correctCloseCall: [
    'Essa foi por pouco! Acertou mesmo em cima da hora.',
    'Por um fio! Acertou no último instante.',
    'Foi por pouco, mas acertou. Respondeu mesmo a tempo!',
    'Raspou no tempo e acertou! Boa.',
    'Coração a mil? Acertou quase no fim do tempo.',
  ],
  correctFast: [
    'Rápido e certo! Sabia bem essa.',
    'Respondeu num instante e acertou!',
    'Resposta veloz e correta, sabia bem esta.',
    'Nem precisou pensar muito, hein? Certinho!',
  ],
  correctAfterWrong: [
    'Esta foi certa! Deu a volta por cima.',
    'Agora sim! Acertou.',
    'Boa recuperação!',
    'Errar faz parte, e esta foi certa!',
    'Aprendeu com a anterior, e já acertou esta.',
    'Voltou ao caminho certo!',
    'Recuperou bem. Continue assim.',
  ],
  wrong: [
    'Não foi desta vez. Veja a explicação.',
    'Resposta errada, mas dá para aprender com ela.',
    'Errou esta. Leia a explicação e siga em frente.',
    'Ninguém acerta tudo de primeira. Veja o porquê.',
    'Esta escapou. A explicação ajuda a fixar.',
    'Não era essa. Leia o porquê com calma.',
    'Faz parte de aprender. Veja a resposta certa.',
    'Quase lá! Veja a explicação e tente a próxima.',
  ],
  wrongFirst: [
    'A primeira escapou, mas a rodada está só a começar.',
    'Começo difícil, mas ainda há muitas perguntas pela frente.',
    'Esta foi de aquecimento. Veja a explicação e siga.',
    'Não foi na primeira. Leia o porquê e continue.',
  ],
  wrongStreak: [
    'Esta também não. Leia a explicação com calma.',
    'Está difícil? Veja a explicação antes da próxima.',
    'Respire e tente a próxima com calma.',
    'Duas seguidas custam, mas a explicação ajuda a virar o jogo.',
    'Sem pressa: leia a explicação antes de seguir.',
    'Dias assim acontecem. Vá com calma na próxima.',
  ],
  wrongAfterStreak: [
    'A sequência acabou, mas o balanço continua bom.',
    'Uma escapou, mas vinha a acertar bem. Siga em frente.',
    'Parou a sequência, mas pode recomeçar já na próxima.',
    'Deslize pequeno depois de bons acertos. Veja o porquê.',
  ],
  timeExpired: [
    'O tempo acabou. Veja a resposta certa.',
    'Faltou tempo desta vez.',
    'Acabou o tempo! Na próxima, não demore tanto.',
    'O relógio venceu desta vez. Veja a explicação.',
    'Tempo esgotado. Leia o porquê e tente de novo.',
  ],
  levelUp: [
    'Subiu de nível! Parabéns!',
    'Novo nível alcançado! Muito bem.',
    'Nível novo desbloqueado, merecido!',
    'Evoluiu de nível, continue a subir!',
  ],
  milestone: [
    'Marco de ofensiva alcançado! Parabéns!',
    'Que dedicação! Marco de ofensiva atingido.',
    'Constância premiada: marco de ofensiva!',
  ],
  finished: {
    great: [
      'Rodada concluída com ótimo aproveitamento!',
      'Excelente rodada!',
      'Rodada de mestre, parabéns!',
      'Aproveitamento muito bom. Orgulhe-se!',
    ],
    ok: [
      'Rodada concluída. Bom trabalho!',
      'Rodada terminada. Veja o resumo.',
      'Rodada boa! Dá para melhorar ainda mais.',
      'Fechou a rodada. Confira o que pode rever.',
    ],
    low: [
      'Rodada concluída. Revise o que errou e tente de novo.',
      'Terminou a rodada. Revisar ajuda a fixar.',
      'Rodada difícil, mas cada tentativa ensina algo.',
      'Não desanime: veja o resumo e volte mais forte.',
    ],
  },
};

const KEY = 'quiz:resultMessageHistory';
const ROUNDS_KEY = 'quiz:lastRounds';

/** Última rodada concluída por categoria (guardada no navegador) para comparar "desta vez" com a anterior. */
function readLastRound(categoryId) {
  try {
    const all = JSON.parse(localStorage.getItem(ROUNDS_KEY) || '{}');
    const r = all[categoryId];
    return r && typeof r.correct === 'number' ? r : null;
  } catch {
    return null;
  }
}

function writeLastRound(categoryId, summary) {
  try {
    const all = JSON.parse(localStorage.getItem(ROUNDS_KEY) || '{}');
    const prev = all[categoryId];
    all[categoryId] = {
      correct: summary.correct,
      total: summary.total,
      best: Math.max(summary.correct, prev && typeof prev.best === 'number' ? prev.best : 0),
    };
    localStorage.setItem(ROUNDS_KEY, JSON.stringify(all));
  } catch {
    /* sem armazenamento: apenas não compara com a rodada anterior */
  }
}

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
    /* sem armazenamento: as mensagens funcionam, só não lembram o histórico */
  }
}

function pick(pool, last) {
  const options = pool.length > 1 ? pool.filter((m) => m !== last) : pool;
  return options[Math.floor(Math.random() * options.length)];
}

function plural(n, one, many) {
  return n === 1 ? one : many;
}

/** Linha de contexto com números reais do progresso (ou '' quando não há nada útil a dizer). */
function buildDetail(result, correct, previousRound) {
  const round = result.round;
  const summary = result.roundSummary;

  if (summary) {
    const base = `Dessa vez acertou ${summary.correct} de ${summary.total} (${summary.accuracyPercent}%).`;
    const prev = previousRound;
    if (!prev) return base;
    if (summary.correct > prev.correct) {
      return `${base} Na anterior foram ${prev.correct}: melhorou!`;
    }
    if (summary.correct === prev.correct) {
      return `${base} Igual à rodada anterior.`;
    }
    if (prev.best > summary.correct && summary.correct === prev.best - 1) {
      return `${base} Por pouco não igualou o seu melhor (${prev.best}).`;
    }
    return `${base} Na anterior foram ${prev.correct}. Dá para recuperar!`;
  }
  if (correct && result.streakMilestoneReached) {
    return `${result.streakMilestoneReached.days} dias seguidos a estudar. A constância compensa!`;
  }
  if (correct && result.leveledUp && result.newLevel) {
    return `Agora está no nível ${result.newLevel}.`;
  }
  if (correct && result.streakIncreasedToday && result.streak) {
    const days = result.streak.currentStreakDays;
    const best = result.streak.longestStreakDays;
    if (days > 1 && days >= best) {
      return `${days} dias seguidos: é a sua melhor ofensiva até agora!`;
    }
    if (days > 1) {
      return `Já são ${days} dias seguidos a estudar.`;
    }
    return 'Ofensiva iniciada hoje. Volte amanhã para mantê-la!';
  }
  if (round && !round.finished && round.total > 0) {
    const left = round.total - round.answered;
    if (left === 1) {
      return `Falta só 1 pergunta para fechar a rodada (${round.correctCount} certas até agora).`;
    }
    if (left > 1 && round.answered >= 1) {
      return `${round.correctCount} ${plural(round.correctCount, 'certa', 'certas')} em ${round.answered} ${plural(round.answered, 'respondida', 'respondidas')}. Faltam ${left}.`;
    }
  }
  return '';
}

/**
 * Escolhe título e linha de contexto e atualiza o histórico.
 * Chamar uma vez por resultado exibido (a tela guarda o retorno num estado).
 */
export function buildResultMessage(result) {
  const h = readHistory();
  const correct = Boolean(result.isCorrect);
  const next = {
    correctRun: correct ? h.correctRun + 1 : 0,
    wrongRun: correct ? 0 : h.wrongRun + 1,
  };
  const answered = result.round?.answered || 0;
  const limitMs = (result.timeLimitSeconds || 0) * 1000;
  const ratio = limitMs > 0 && typeof result.responseTimeMs === 'number' ? result.responseTimeMs / limitMs : null;
  const secondsLeft = ratio === null ? null : Math.max(0, Math.round((limitMs - result.responseTimeMs) / 1000));
  const closeCall = ratio !== null && ratio >= 0.85 && !result.timeExpired;
  const fast = ratio !== null && ratio <= 0.25;
  const categoryId = result.roundSummary?.categoryId;
  const previousRound = categoryId ? readLastRound(categoryId) : null;

  let pool;
  if (result.roundSummary) {
    const pct = result.roundSummary.accuracyPercent;
    pool = pct >= 80 ? POOLS.finished.great : pct >= 50 ? POOLS.finished.ok : POOLS.finished.low;
  } else if (correct && result.leveledUp) pool = POOLS.levelUp;
  else if (correct && result.streakMilestoneReached) pool = POOLS.milestone;
  else if (correct && closeCall) pool = POOLS.correctCloseCall;
  else if (correct && next.correctRun >= 5) pool = POOLS.correctStreakLong;
  else if (correct && next.correctRun >= 3) pool = POOLS.correctStreak;
  else if (correct && h.wrongRun >= 1) pool = POOLS.correctAfterWrong;
  else if (correct && fast) pool = POOLS.correctFast;
  else if (correct && answered === 1) pool = POOLS.correctFirst;
  else if (correct) pool = POOLS.correct;
  else if (result.timeExpired) pool = POOLS.timeExpired;
  else if (next.wrongRun >= 2) pool = POOLS.wrongStreak;
  else if (h.correctRun >= 3) pool = POOLS.wrongAfterStreak;
  else if (answered === 1) pool = POOLS.wrongFirst;
  else pool = POOLS.wrong;

  const title = pick(pool, h.last);
  writeHistory({ ...next, last: title });
  let detail = buildDetail(result, correct, previousRound);
  if (correct && closeCall && !result.roundSummary && secondsLeft !== null) {
    detail = `Sobraram só ${secondsLeft} ${plural(secondsLeft, 'segundo', 'segundos')}.${detail ? ` ${detail}` : ''}`;
  }
  if (result.roundSummary && categoryId) writeLastRound(categoryId, result.roundSummary);
  return { title, detail };
}
