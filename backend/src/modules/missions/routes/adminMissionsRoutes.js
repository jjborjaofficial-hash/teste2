const { Router } = require('express');
const controller = require('../controllers/adminMissionsController');
const authenticate = require('../../../middleware/authenticate');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const { createMissionSchema, updateMissionSchema } = require('../validators/adminMissionsValidators');

const router = Router();

router.use(authenticate);
router.use(requireRole('admin_suporte'));

router.get('/', controller.listMissions);
router.post('/', validate(createMissionSchema), controller.createMission);
router.post('/:missionId', validate(updateMissionSchema), controller.updateMission);

module.exports = router;
