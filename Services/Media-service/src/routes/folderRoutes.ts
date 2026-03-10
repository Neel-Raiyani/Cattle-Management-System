import { Router } from 'express';
import * as folderController from '@controllers/folderController.js';
import { auth } from '@middlewares/auth.js';
import { gaushalaAuth } from '@middlewares/gaushalaAuth.js';

const router = Router();

router.use(auth);
router.use(gaushalaAuth());

router.post('/', folderController.createFolder);
router.get('/', folderController.getFolders);
router.patch('/:id', folderController.renameFolder);
router.delete('/:id', folderController.deleteFolder);

export default router;
