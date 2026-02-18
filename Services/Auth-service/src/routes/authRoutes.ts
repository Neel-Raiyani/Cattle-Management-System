import express from 'express';
import { register, login, getProfile, sendOtp, verifyOtp, updateSettings, changePassword } from '@controllers/authController.js';
import { registerValidation, loginValidation, sendOtpValidation, verifyOtpValidation, updateSettingsValidation, changePasswordValidation } from '@validators/authValidators.js';
import { auth, role } from '@middlewares/auth.js';
import { otpLimit } from '@middlewares/rateLimiter.js';

const router = express.Router();

router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.get('/profile', auth, getProfile);

// Password Management
router.post('/forgot-password/send-otp', otpLimit, sendOtpValidation, sendOtp);
router.post('/forgot-password/verify', verifyOtpValidation, verifyOtp);
router.post('/change-password', auth, changePasswordValidation, changePassword);

// Settings
router.put('/settings', auth, role(['OWNER', 'MANAGER']), updateSettingsValidation, updateSettings);

export default router;
