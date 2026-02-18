import { body, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

export const validate = (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            errors: errors.array().map((err: any) => ({
                message: err.msg
            }))
        });
    }
    next();
};

export const registerValidation = [
    body('mobileNumber')
        .isMobilePhone('en-IN').withMessage('Valid Indian mobile number is required'),
    body('name')
        .notEmpty().withMessage('Name is required'),
    body('password')
        .isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
    body('city')
        .notEmpty().withMessage('City is required'),
    body('gaushalaName')
        .notEmpty().withMessage('Gaushala name is required'),
    body('totalCattle')
        .isInt({ min: 0 }).withMessage('Total cattle must be a positive number'),
    body('role')
        .optional()
        .isIn(['OWNER', 'MANAGER', 'STAFF', 'VETERINARIAN', 'VIEWER']).withMessage('Invalid role'),
    validate
];

export const loginValidation = [
    body('mobileNumber')
        .isMobilePhone('en-IN').withMessage('Valid Indian mobile number is required'),
    body('password')
        .notEmpty().withMessage('Password is required'),
    validate
];

export const sendOtpValidation = [
    body('mobileNumber')
        .isMobilePhone('en-IN').withMessage('Valid Indian mobile number is required'),
    validate
];

export const verifyOtpValidation = [
    body('mobileNumber')
        .isMobilePhone('en-IN').withMessage('Valid Indian mobile number is required'),
    body('otp')
        .isLength({ min: 4, max: 6 }).withMessage('Invalid OTP format'),
    body('newPassword')
        .isLength({ min: 6 }).withMessage('New password must be at least 6 characters long'),
    validate
];

export const updateSettingsValidation = [
    body('languagePreference')
        .optional()
        .isIn(['EN', 'GU', 'HI']).withMessage('Invalid language preference'),
    body('unitPreference')
        .optional()
        .isIn(['Ltr', 'Kg']).withMessage('Invalid unit preference'),
    validate
];

export const changePasswordValidation = [
    body('oldPassword')
        .notEmpty().withMessage('Old password is required'),
    body('newPassword')
        .isLength({ min: 6 }).withMessage('New password must be at least 6 characters long'),
    validate
];
