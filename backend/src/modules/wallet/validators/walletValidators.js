const { z } = require('zod');

const withdrawalSchema = z.object({
  amountMzn: z.number().positive('O valor do saque deve ser positivo.'),
  method: z.enum(['mpesa', 'emola'], {
    errorMap: () => ({ message: 'Método deve ser "mpesa" ou "emola".' }),
  }),
});

module.exports = { withdrawalSchema };
