/**
 * Rodada de quiz: ao abrir uma categoria, o utilizador responde no máximo
 * QUIZ_ROUND_SIZE perguntas seguidas. Terminada a rodada, para responder de novo
 * tem de abrir a categoria outra vez no Hub de Estudos.
 *
 * O progresso da rodada viaja no state da navegação (sobrevive a recarregar a
 * página, mas começa do zero quando a categoria é aberta de novo). O teto de
 * ganhos continua a ser imposto pelo servidor (teto diário de 7,20 MZN).
 */
export const QUIZ_ROUND_SIZE = 10;

export const EMPTY_ROUND = { answered: 0, correct: 0, xp: 0, points: 0 };

export function nextRound(round, result) {
  const base = round || EMPTY_ROUND;
  return {
    answered: base.answered + 1,
    correct: base.correct + (result?.isCorrect ? 1 : 0),
    xp: base.xp + (result?.xpAwarded || 0),
    points: base.points + (result?.pointsAwarded || 0),
  };
}
