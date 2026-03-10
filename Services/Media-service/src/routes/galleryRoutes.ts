import { Router } from 'express';
import * as galleryController from '@controllers/galleryController.js';
import { auth } from '@middlewares/auth.js';
import { gaushalaAuth } from '@middlewares/gaushalaAuth.js';

const router = Router();

router.use(auth);
router.use(gaushalaAuth());

router.get('/upload-url', galleryController.getUploadUrl);
router.post('/items', galleryController.registerMediaItem);
router.get('/folders/:folderId/items', galleryController.getFolderItems);
router.delete('/items/:id', galleryController.deleteMediaItem);

export default router;
