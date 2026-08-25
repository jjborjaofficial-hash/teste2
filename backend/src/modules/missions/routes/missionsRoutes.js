const { Router } = require('express');
const controller = require('../controllers/missionsController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/', authenticate, controller.listMine);
router.post('/:userMissionId/claim', authenticate, controller.claimReward);

module.exports = router;
