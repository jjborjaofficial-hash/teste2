const { Router } = require('express');
const controller = require('../controllers/adminMissionsController');
const authenticate = require('../../../middleware/authenticate');
const requireAdminAccess = require('../../../middleware/requireAdminAccess');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const { createMissionSchema, updateMissionSchema } = require('../validators/adminMissionsValidators');

const router = Router();

router.use(authenticate);
router.use(requireAdminAccess);
router.use(requireRole('admin_suporte'));

router.get('/', controller.listMissions);
router.post('/', validate(createMissionSchema), controller.createMission);
router.post('/:missionId', validate(updateMissionSchema), controller.updateMission);

module.exports = router;
