import { Router } from 'express';
import { auth } from '@middlewares/auth.js';
import { gaushalaAuth } from '@middlewares/gaushalaAuth.js';
import {
    getEarTagAlerts,
    getHeatAlerts,
    getPregnancyCheckAlerts,
    getInseminationAlerts,
    getDeliveryAlerts,
    getDewormingAlerts,
    getAdultAlerts,
    getLabAlerts
} from '@controllers/alertController.js';

const router = Router();

// All alert routes require authentication and gaushala membership
router.use(auth);
router.use(gaushalaAuth());

// Individual alert endpoints
router.get('/ear-tag', getEarTagAlerts);
router.get('/heat', getHeatAlerts);
router.get('/pregnancy-check', getPregnancyCheckAlerts);
router.get('/insemination', getInseminationAlerts);
router.get('/delivery', getDeliveryAlerts);
router.get('/deworming', getDewormingAlerts);
router.get('/adult', getAdultAlerts);
router.get('/lab-test', getLabAlerts);

export default router;
