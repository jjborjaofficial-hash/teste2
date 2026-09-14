const { z } = require('zod');

const withdrawalSchema = z.object({
  amountMzn: z.number().positive('O valor do saque deve ser positivo.'),
  method: z.enum(['mpesa', 'emola'], {
    errorMap: () => ({ message: 'Método deve ser "mpesa" ou "emola".' }),
  }),
});

const conversionSchema = z.object({
  pointsAmount: z
    .number({ invalid_type_error: 'A quantidade de Pontos deve ser um número.' })
    .int('A quantidade de Pontos deve ser um número inteiro.')
    .positive('A quantidade de Pontos deve ser positiva.'),
});

module.exports = { withdrawalSchema, conversionSchema };
