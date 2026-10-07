/**
 * Mensagens da tela de resultado: um TÍTULO e uma LINHA DE CONTEXTO.
 *
 * Objetivo: o utilizador sentir que a plataforma conhece a situação e o progresso dele.
 * - O título depende do que acabou de acontecer (acerto, erro, tempo, ritmo de resposta,
 *   subida de nível, marco de ofensiva, fim da rodada) e do histórico recente (acertos/erros
 *   seguidos, primeira pergunta, meio e fim da rodada, recuperação, fim de uma sequência,
 *   comparação com a rodada anterior da mesma categoria).
 * - A linha de contexto usa só números reais (dias de ofensiva, acertos da rodada, segundos
 *   que sobraram) — nunca inventa dados.
 * - A mesma frase nunca sai duas vezes seguidas. Nunca afirma "domínio" por uma resposta só
 *   e nunca diz "por pouco" num erro (chegar tarde a uma resposta errada não é quase acertar).
 */
const POOLS = {
  // ---------- Acertos ----------
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
    'Na mosca! Era essa.',
    'Certinho! Raciocínio afiado.',
    'Bela escolha, estava certa.',
    'Está a ler bem as perguntas, acertou!',
  ],
  correctFirst: [
    'Começou bem! Primeira certa da rodada.',
    'Boa abertura, acertou logo a primeira!',
    'Primeira certa! Bom começo.',
    'Arrancou com o pé direito!',
    'Começo certeiro! Siga assim.',
    'Primeira pergunta e já pontuou. Vamos a mais!',
    'Entrou em campo a acertar. Continue!',
  ],
  correctHalf: [
    'Metade da rodada e a acertar. Siga firme!',
    'Chegou ao meio com o pé direito, continue!',
    'Está no meio da rodada e bem encaminhado.',
    'Mais uma certa na metade do caminho!',
  ],
  correctCloseCall: [
    'Essa foi por pouco! Acertou mesmo em cima da hora.',
    'Por um fio! Acertou no último instante.',
    'Foi por pouco, mas acertou. Respondeu mesmo a tempo!',
    'Raspou no tempo e acertou! Boa.',
    'Coração a mil? Acertou quase no fim do tempo.',
    'Quase que o relógio ganhava, mas acertou primeiro!',
    'No limite do tempo, e certeiro. Respire!',
    'Sob pressão e ainda assim acertou. Bom sinal.',
  ],
  correctFast: [
    'Rápido e certo! Sabia bem essa.',
    'Respondeu num instante e acertou!',
    'Resposta veloz e correta, sabia bem esta.',
    'Nem precisou pensar muito, hein? Certinho!',
    'Foi num piscar de olhos e acertou!',
    'Rapidez e precisão, boa combinação.',
    'Essa estava na ponta da língua!',
  ],
  correctThoughtful: [
    'Pensou bem e acertou. Vale a pena ter calma.',
    'Sem pressa e com cabeça: acertou!',
    'Usou o tempo com sabedoria e acertou.',
    'Raciocinou com calma e foi certeiro.',
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
    'Uma atrás da outra, está inspirado!',
  ],
  correctStreakLong: [
    'Cinco certas seguidas, que sequência!',
    'Está imparável! Continue assim.',
    'Que concentração! Mais uma certa.',
    'Sequência de campeão, não pare!',
    'Está a voar! Acertos em cadeia.',
    'Nem o erro espreita hoje. Que fase!',
    'Dia de ouro: acertos e mais acertos.',
  ],
  correctAfterWrong: [
    'Esta foi certa! Deu a volta por cima.',
    'Agora sim! Acertou.',
    'Boa recuperação!',
    'Errar faz parte, e esta foi certa!',
    'Aprendeu com a anterior, e já acertou esta.',
    'Voltou ao caminho certo!',
    'Recuperou bem. Continue assim.',
    'Levantou depois do tropeço. É assim que se aprende!',
    'A explicação anterior serviu: acertou esta.',
  ],
  correctAfterWrongStreak: [
    'Depois de uns erros, uma certa. A maré virou!',
    'Finalmente a certa! A persistência compensa.',
    'Não desistiu e acertou. É isso!',
    'Depois de uns tropeços, uma vitória. Respire e siga.',
  ],

  // ---------- Erros ----------
  wrong: [
    'Não foi desta vez. Veja a explicação.',
    'Resposta errada, mas dá para aprender com ela.',
    'Errou esta. Leia a explicação e siga em frente.',
    'Ninguém acerta tudo de primeira. Veja o porquê.',
    'Esta escapou. A explicação ajuda a fixar.',
    'Não era essa. Leia o porquê com calma.',
    'Faz parte de aprender. Veja a resposta certa.',
    'Quase lá! Veja a explicação e tente a próxima.',
    'Uma resposta errada ensina mais do que parece. Leia o porquê.',
    'Tudo bem errar. O importante é perceber o motivo.',
    'Não era essa, mas a próxima pode ser sua.',
  ],
  wrongFirst: [
    'A primeira escapou, mas a rodada está só a começar.',
    'Começo difícil, mas ainda há muitas perguntas pela frente.',
    'Esta foi de aquecimento. Veja a explicação e siga.',
    'Não foi na primeira. Leia o porquê e continue.',
    'A primeira nem sempre é a mais fácil. Há tempo para virar.',
  ],
  wrongFast: [
    'Foi rápido demais! Na próxima, leia o enunciado com calma.',
    'Respondeu num instante, mas errou. Vale a pena reler a pergunta.',
    'Pressa é inimiga da resposta certa. Veja a explicação.',
    'Resposta veloz, mas errada. Respire antes de escolher.',
  ],
  wrongStreak: [
    'Esta também não. Leia a explicação com calma.',
    'Está difícil? Veja a explicação antes da próxima.',
    'Respire e tente a próxima com calma.',
    'Duas seguidas custam, mas a explicação ajuda a virar o jogo.',
    'Sem pressa: leia a explicação antes de seguir.',
    'Dias assim acontecem. Vá com calma na próxima.',
  ],
  wrongStreakLong: [
    'Dia puxado, mas não desista. Leia a explicação com atenção.',
    'Já são vários erros seguidos. Uma pausa curta pode ajudar.',
    'Não se desanime: quem insiste, aprende. Veja o porquê.',
    'Quando tudo parece difícil, rever a explicação é o caminho.',
  ],
  wrongAfterStreak: [
    'A sequência acabou, mas o balanço continua bom.',
    'Uma escapou, mas vinha a acertar bem. Siga em frente.',
    'Parou a sequência, mas pode recomeçar já na próxima.',
    'Deslize pequeno depois de bons acertos. Veja o porquê.',
    'Mesmo quem vem a acertar tropeça. Leia o porquê e continue.',
  ],
  timeExpired: [
    'O tempo acabou. Veja a resposta certa.',
    'Faltou tempo desta vez.',
    'Acabou o tempo! Na próxima, não demore tanto.',
    'O relógio venceu desta vez. Veja a explicação.',
    'Tempo esgotado. Leia o porquê e tente de novo.',
    'O tempo correu mais depressa. Na próxima, decida com mais agilidade.',
  ],

  // ---------- Momentos especiais ----------
  levelUp: [
    'Subiu de nível! Parabéns!',
    'Novo nível alcançado! Muito bem.',
    'Nível novo desbloqueado, merecido!',
    'Evoluiu de nível, continue a subir!',
    'Que progresso! Mais um nível conquistado.',
  ],
  milestone: [
    'Marco de ofensiva alcançado! Parabéns!',
    'Que dedicação! Marco de ofensiva atingido.',
    'Constância premiada: marco de ofensiva!',
    'Dia após dia, chegou a um marco. Orgulhe-se!',
  ],

  // ---------- Fim da rodada ----------
  finishedPerfect: [
    'Rodada perfeita! Acertou todas.',
    'Sem nenhum erro! Que rodada!',
    'Cem por cento! Parabéns, rodada impecável.',
  ],
  finishedImproved: [
    'Rodada melhor que a anterior. Está a evoluir!',
    'Progresso à vista: foi melhor do que da última vez.',
    'Subiu o aproveitamento. O estudo está a dar frutos!',
    'Melhor que a rodada anterior, continue nesse caminho.',
  ],
  finishedGreat: [
    'Rodada concluída com ótimo aproveitamento!',
    'Excelente rodada!',
    'Rodada de mestre, parabéns!',
    'Aproveitamento muito bom. Orgulhe-se!',
    'Quase impecável. Muito bom trabalho!',
  ],
  finishedOk: [
    'Rodada concluída. Bom trabalho!',
    'Rodada terminada. Veja o resumo.',
    'Rodada boa! Dá para melhorar ainda mais.',
    'Fechou a rodada. Confira o que pode rever.',
    'Bom resultado, com espaço para crescer.',
  ],
  finishedLow: [
    'Rodada concluída. Revise o que errou e tente de novo.',
    'Terminou a rodada. Revisar ajuda a fixar.',
    'Rodada difícil, mas cada tentativa ensina algo.',
    'Não desanime: veja o resumo e volte mais forte.',
    'Hoje foi puxado. Rever o que errou muda o jogo.',
  ],
  finishedZero: [
    'Rodada difícil, mas terminou. Isso já conta! Revise com calma.',
    'Nenhuma certa desta vez, mas o resumo mostra o caminho.',
  ],
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
      return `Falta só 1 pergunta para fechar a rodada (${round.correctCount} ${plural(round.correctCount, 'certa', 'certas')} até agora).`;
    }
    if (left > 1 && round.answered >= 1) {
      return `${round.correctCount} ${plural(round.correctCount, 'certa', 'certas')} em ${round.answered} ${plural(round.answered, 'respondida', 'respondidas')}. Faltam ${left}.`;
    }
  }
  return '';
}

function chooseFinishedPool(summary, previousRound) {
  const pct = summary.accuracyPercent;
  if (summary.total > 0 && summary.correct === summary.total) return POOLS.finishedPerfect;
  if (summary.correct === 0) return POOLS.finishedZero;
  if (previousRound && summary.correct > previousRound.correct) return POOLS.finishedImproved;
  if (pct >= 80) return POOLS.finishedGreat;
  if (pct >= 50) return POOLS.finishedOk;
  return POOLS.finishedLow;
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
  const round = result.round;
  const answered = round?.answered || 0;
  const halfway = round?.total > 0 && answered === Math.round(round.total / 2);

  const limitMs = (result.timeLimitSeconds || 0) * 1000;
  const ratio = limitMs > 0 && typeof result.responseTimeMs === 'number' ? result.responseTimeMs / limitMs : null;
  const secondsLeft = ratio === null ? null : Math.max(0, Math.round((limitMs - result.responseTimeMs) / 1000));
  const closeCall = ratio !== null && ratio >= 0.85 && !result.timeExpired;
  const fast = ratio !== null && ratio <= 0.25;
  const thoughtful = ratio !== null && ratio >= 0.55 && ratio < 0.85;

  const categoryId = result.roundSummary?.categoryId;
  const previousRound = categoryId ? readLastRound(categoryId) : null;

  let pool;
  if (result.roundSummary) pool = chooseFinishedPool(result.roundSummary, previousRound);
  else if (correct && result.leveledUp) pool = POOLS.levelUp;
  else if (correct && result.streakMilestoneReached) pool = POOLS.milestone;
  else if (correct && closeCall) pool = POOLS.correctCloseCall;
  else if (correct && next.correctRun >= 5) pool = POOLS.correctStreakLong;
  else if (correct && next.correctRun >= 3) pool = POOLS.correctStreak;
  else if (correct && h.wrongRun >= 3) pool = POOLS.correctAfterWrongStreak;
  else if (correct && h.wrongRun >= 1) pool = POOLS.correctAfterWrong;
  else if (correct && fast) pool = POOLS.correctFast;
  else if (correct && answered === 1) pool = POOLS.correctFirst;
  else if (correct && halfway) pool = POOLS.correctHalf;
  else if (correct && thoughtful) pool = POOLS.correctThoughtful;
  else if (correct) pool = POOLS.correct;
  else if (result.timeExpired) pool = POOLS.timeExpired;
  else if (next.wrongRun >= 4) pool = POOLS.wrongStreakLong;
  else if (next.wrongRun >= 2) pool = POOLS.wrongStreak;
  else if (h.correctRun >= 3) pool = POOLS.wrongAfterStreak;
  else if (fast) pool = POOLS.wrongFast;
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
