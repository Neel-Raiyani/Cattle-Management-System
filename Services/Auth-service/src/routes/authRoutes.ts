import express from 'express';
import { register, login, getProfile, sendOtp, verifyOtp, updateSettings, changePassword } from '@controllers/authController.js';
import { createGaushala, getMyGaushalas } from '@controllers/gaushalaController.js';
import { registerValidation, loginValidation, sendOtpValidation, verifyOtpValidation, updateSettingsValidation, changePasswordValidation, createGaushalaValidation } from '@validators/authValidators.js';
import { auth } from '@middlewares/auth.js';
import { gaushalaAuth } from '@middlewares/gaushalaAuth.js';
import { otpLimit } from '@middlewares/rateLimiter.js';

const router = express.Router();

router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.get('/profile', auth, getProfile);

// Gaushala Management
router.post('/gaushala', auth, createGaushalaValidation, createGaushala);
router.get('/gaushala/my', auth, getMyGaushalas);

// Password Management
router.post('/forgot-password/send-otp', otpLimit, sendOtpValidation, sendOtp);
router.post('/forgot-password/verify', verifyOtpValidation, verifyOtp);
router.post('/change-password', auth, changePasswordValidation, changePassword);

// Settings (Now per-gaushala scoped)
router.put('/settings', auth, gaushalaAuth(['OWNER', 'MANAGER']), updateSettingsValidation, updateSettings);

export default router;
