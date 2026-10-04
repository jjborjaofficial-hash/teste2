/**
 * Rodada de quiz: EXATAMENTE 10 perguntas. O progresso da rodada (respondidas, acertos,
 * checkpoint técnico aos 5, conclusão aos 10) é calculado e guardado pelo SERVIDOR e
 * viaja com a pergunta (`question.round`) e com o resultado (`result.round`); recarregar
 * a página retoma a rodada. Esta constante só serve de valor de reserva para o contador.
 */
export const QUIZ_ROUND_SIZE = 10;
