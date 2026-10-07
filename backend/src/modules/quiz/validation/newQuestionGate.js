/**
 * Portão de qualidade para perguntas NOVAS ou REESCRITAS (BE-003, pedaço P13). Função pura.
 *
 * Decisão do dono (BE-003, passo 5): "as perguntas novas só entram se passarem no validador".
 * Junta os validadores (tamanho/estrutura, viés, duplicadas) e devolve:
 *   - blockers: a pergunta NÃO deve ser gravada (defeito claro);
 *   - warnings: sinais a rever; não bloqueiam, são devolvidos ao autor.
 *
 * Só é chamado quando o autor envia enunciado/alternativas. Editar só `isActive`, tempo ou XP não
 * passa por aqui, e as ~1.400 perguntas antigas que reprovam continuam a ser servidas.
 */
const { analyzeQuestion } = require('./alternativesValidator');
const { detectBias } = require('./biasDetector');
const { findDuplicateOf } = require('./duplicateQuestions');

const MESSAGES = {
  menos_de_2_alternativas: 'precisa de pelo menos 2 alternativas',
  corretas_0: 'precisa de uma alternativa correta',
  correta_mais_longa_destacada: 'a alternativa correta é bem mais longa que as erradas (denuncia a resposta); deixe as quatro com tamanho parecido',
  correta_muito_mais_curta: 'a alternativa correta é bem mais curta que as erradas (denuncia a resposta ao contrário); deixe as quatro com tamanho parecido',
  explicacao_embutida_na_correta: 'a correta traz explicação dentro (parênteses, dois-pontos, "porque", "ou seja"); a explicação vai no campo próprio',
  alternativas_duplicadas_ou_quase_iguais: 'há alternativas repetidas ou quase iguais',
  todas_ou_nenhuma_das_anteriores: 'não use "todas/nenhuma das anteriores"',
  pergunta_duplicada: 'já existe uma pergunta igual ou quase igual',
};

const msgFor = (code) => {
  if (MESSAGES[code]) return MESSAGES[code];
  if (/^corretas_\d+$/.test(code)) return 'precisa de exatamente 1 alternativa correta';
  return code;
};

/**
 * @param {{statement:string, alternatives:{label:string,isCorrect:boolean}[], existing?:{id:string,statement:string}[], ownId?:string}} input
 * @returns {{ok:boolean, blockers:{code:string,message:string}[], warnings:{code:string,message:string}[]}}
 */
function evaluateNewQuestion({ statement, alternatives, existing = [], ownId }) {
  const blockers = [];
  const warnings = [];
  const push = (list, code, message) => list.push({ code, message: message || msgFor(code) });

  if (Array.isArray(alternatives)) {
    const q = { id: ownId || 'nova', alternatives: alternatives.map((a) => ({ label: a.label, is_correct: !!a.isCorrect })) };
    analyzeQuestion(q).reasons.forEach((code) => push(blockers, code));
    detectBias(q).flags.forEach((f) => push(f.severity === 'block' ? blockers : warnings, f.code, f.message));
  }

  if (statement) {
    const dup = findDuplicateOf(statement, existing, { excludeId: ownId });
    if (dup) {
      push(blockers, 'pergunta_duplicada', `${msgFor('pergunta_duplicada')} (id ${dup.id}, ${dup.exact ? 'idêntica' : `semelhança ${Math.round(dup.similarity * 100)}%`})`);
    }
  }

  return { ok: blockers.length === 0, blockers, warnings };
}

/** Texto único para a resposta de erro (o painel admin mostra `message` tal como vem). */
function formatBlockers(blockers) {
  return `Pergunta não aprovada pelo validador: ${blockers.map((b) => b.message).join('; ')}.`;
}

module.exports = { evaluateNewQuestion, formatBlockers };
