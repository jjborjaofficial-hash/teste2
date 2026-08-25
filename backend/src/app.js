const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const compression = require('compression');

const corsOptions = require('./config/cors');
const { defaultRateLimiter } = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const { NotFoundError } = require('./common/errors/AppError');

const authRoutes = require('./modules/auth/routes/authRoutes');
const userRoutes = require('./modules/users/routes/userRoutes');
const gamificationRoutes = require('./modules/gamification/routes/gamificationRoutes');
const quizRoutes = require('./modules/quiz/routes/quizRoutes');
const missionsRoutes = require('./modules/missions/routes/missionsRoutes');
const walletRoutes = require('./modules/wallet/routes/walletRoutes');
const trustScoreRoutes = require('./modules/trustscore/routes/trustScoreRoutes');
const rankingRoutes = require('./modules/ranking/routes/rankingRoutes');
const notificationsRoutes = require('./modules/notifications/routes/notificationsRoutes');
const referralsRoutes = require('./modules/referrals/routes/referralsRoutes');
const adminRoutes = require('./modules/admin/routes/adminRoutes');
const legalRoutes = require('./modules/legal/routes/legalRoutes');
const adminLegalRoutes = require('./modules/legal/routes/adminLegalRoutes');
const shopRoutes = require('./modules/shop/routes/shopRoutes');
const adminShopRoutes = require('./modules/shop/routes/adminShopRoutes');
const inventoryRoutes = require('./modules/shop/routes/inventoryRoutes');
const adminQuizRoutes = require('./modules/quiz/routes/adminQuizRoutes');
const adminMissionsRoutes = require('./modules/missions/routes/adminMissionsRoutes');

const app = express();

// Segurança por padrão (Manual Parte 3: Security by Design)
app.use(helmet());
// CORS restrito às origens oficiais (CORS_ALLOWED_ORIGINS) — nunca "*" em
// produção; `credentials: true` necessário para o cookie httpOnly do refresh
// token viajar nas requisições do frontend.
app.use(cors(corsOptions));
app.use(compression());
app.use(express.json({ limit: '1mb' }));
app.use(cookieParser());
app.use(defaultRateLimiter);

// Healthcheck (usado por Render e por monitoramento externo)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'aprenda-e-ganhe-backend' });
});

// Rotas versionadas (Manual Parte 5: RESTful versionado /api/v1)
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/gamification', gamificationRoutes);
app.use('/api/v1/quiz', quizRoutes);
app.use('/api/v1/missions', missionsRoutes);
app.use('/api/v1/wallet', walletRoutes);
app.use('/api/v1/trust-score', trustScoreRoutes);
app.use('/api/v1/ranking', rankingRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/referrals', referralsRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/legal', legalRoutes);
app.use('/api/v1/admin/legal', adminLegalRoutes);
app.use('/api/v1/shop', shopRoutes);
app.use('/api/v1/admin/shop', adminShopRoutes);
app.use('/api/v1/inventory', inventoryRoutes);
app.use('/api/v1/admin/quiz', adminQuizRoutes);
app.use('/api/v1/admin/missions', adminMissionsRoutes);

// 404 para qualquer rota não mapeada
app.use((req, res, next) => {
  next(new NotFoundError(`Rota ${req.method} ${req.originalUrl} não existe.`));
});

// Handler central de erros — deve ser sempre o último middleware
app.use(errorHandler);

module.exports = app;
