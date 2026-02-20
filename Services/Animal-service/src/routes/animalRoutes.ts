import express from 'express';
import { registerAnimal, getAnimals, getAnimalById, updateAnimal, generateUploadUrl } from '@controllers/animalController.js';
import { recordSell, recordDeath, recordDonation, updateDisposalRecord } from '@controllers/disposalController.js';
import { registerAnimalValidation, updateAnimalValidation, sellRecordValidation, deathRecordValidation, donationRecordValidation } from '@validators/animalValidators.js';
import { auth } from '@middlewares/auth.js';
import { gaushalaAuth } from '@middlewares/gaushalaAuth.js';

const router = express.Router();

router.get('/media/presigned-url', auth, gaushalaAuth(), generateUploadUrl);

router.post('/add', auth, gaushalaAuth(['OWNER', 'MANAGER', 'STAFF']), registerAnimalValidation, registerAnimal);
router.get('/', auth, gaushalaAuth(), getAnimals);

router.post('/sell', auth, gaushalaAuth(['OWNER', 'MANAGER']), sellRecordValidation, recordSell);
router.post('/death', auth, gaushalaAuth(['OWNER', 'MANAGER']), deathRecordValidation, recordDeath);
router.post('/donation', auth, gaushalaAuth(['OWNER', 'MANAGER']), donationRecordValidation, recordDonation);
router.patch('/disposal/:type/:id', auth, gaushalaAuth(['OWNER', 'MANAGER']), updateDisposalRecord);

router.patch('/update/:id', auth, gaushalaAuth(['OWNER', 'MANAGER', 'STAFF']), updateAnimalValidation, updateAnimal);
router.get('/:id', auth, gaushalaAuth(), getAnimalById);

export default router;