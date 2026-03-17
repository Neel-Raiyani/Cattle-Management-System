import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';
import logger from '@utils/logger.js';

const serviceAccountPath = path.resolve('src/config/serviceAccountKey.json');

if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    logger.info('[firebase]: Firebase Admin initialized successfully');
} else {
    logger.warn('[firebase]: serviceAccountKey.json not found. Push notifications will be disabled.');
}

export default admin;
