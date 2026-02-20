import { body, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

/**
 * Validation middleware — collects all validation errors and returns them
 * in a structured format with field names for easy frontend consumption.
 */
export const validate = (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(422).json({
            success: false,
            errorCode: 'VALIDATION_FAILED',
            message: 'Request validation failed',
            errors: errors.array().map((err: any) => ({
                field: err.path || err.param,
                message: err.msg
            }))
        });
    }
    next();
};

// ───────────────────────── Animal Registration ─────────────────────────
export const registerAnimalValidation = [
    body('species')
        .isIn(['COW', 'BUFFALO']).withMessage('Species must be COW or BUFFALO'),
    body('gender')
        .isIn(['MALE', 'FEMALE']).withMessage('Gender must be MALE or FEMALE'),
    body('tagNumber')
        .optional()
        .isString().withMessage('Tag number must be a string'),
    body('acquisitionType')
        .isIn(['BIRTH', 'PURCHASE', 'DONATION']).withMessage('Acquisition type must be BIRTH, PURCHASE, or DONATION'),
    body('cowBreed')
        .optional()
        .isString().withMessage('Cow breed must be a string'),
    body('buffaloBreed')
        .optional()
        .isString().withMessage('Buffalo breed must be a string'),
    body('birthDate')
        .optional()
        .isISO8601().withMessage('Birth date must be a valid ISO 8601 date'),
    body('adultDate')
        .optional()
        .isISO8601().withMessage('Adult date must be a valid ISO 8601 date'),
    body('purchasePrice')
        .optional()
        .isFloat({ min: 0 }).withMessage('Purchase price must be a positive number'),
    body('purchaseDate')
        .optional()
        .isISO8601().withMessage('Purchase date must be a valid ISO 8601 date'),
    body('isUdderClosedFL').optional().isBoolean().withMessage('isUdderClosedFL must be a boolean'),
    body('isUdderClosedFR').optional().isBoolean().withMessage('isUdderClosedFR must be a boolean'),
    body('isUdderClosedBL').optional().isBoolean().withMessage('isUdderClosedBL must be a boolean'),
    body('isUdderClosedBR').optional().isBoolean().withMessage('isUdderClosedBR must be a boolean'),
    body('motherName').optional().isString().withMessage('Mother name must be a string'),
    body('fatherName').optional().isString().withMessage('Father name must be a string'),
    body('motherId').optional().isMongoId().withMessage('Mother ID must be a valid Mongo ID'),
    body('fatherId').optional().isMongoId().withMessage('Father ID must be a valid Mongo ID'),
    validate
];

// ───────────────────────── Animal Update ─────────────────────────
export const updateAnimalValidation = [
    body('name').optional().isString().withMessage('Name must be a string'),
    body('tagNumber').optional().isString().withMessage('Tag number must be a string'),
    body('isPregnant').optional().isBoolean().withMessage('isPregnant must be a boolean'),
    body('isLactating').optional().isBoolean().withMessage('isLactating must be a boolean'),
    body('isDryOff').optional().isBoolean().withMessage('isDryOff must be a boolean'),
    body('isHeifer').optional().isBoolean().withMessage('isHeifer must be a boolean'),
    body('isRetired').optional().isBoolean().withMessage('isRetired must be a boolean'),
    body('isHandicapped').optional().isBoolean().withMessage('isHandicapped must be a boolean'),
    body('lactationNumber').optional().isInt({ min: 0 }).withMessage('Lactation number must be a non-negative integer'),
    body('cowGroup').optional().isString().withMessage('Cow group must be a string'),
    body('birthDate').optional().isISO8601().withMessage('Birth date must be a valid ISO 8601 date'),
    body('adultDate').optional().isISO8601().withMessage('Adult date must be a valid ISO 8601 date'),
    body('motherMilk').optional().isFloat({ min: 0 }).withMessage('Mother milk must be a positive number'),
    body('grandmotherMilk').optional().isFloat({ min: 0 }).withMessage('Grandmother milk must be a positive number'),
    body('isUdderClosedFL').optional().isBoolean().withMessage('isUdderClosedFL must be a boolean'),
    body('isUdderClosedFR').optional().isBoolean().withMessage('isUdderClosedFR must be a boolean'),
    body('isUdderClosedBL').optional().isBoolean().withMessage('isUdderClosedBL must be a boolean'),
    body('isUdderClosedBR').optional().isBoolean().withMessage('isUdderClosedBR must be a boolean'),
    body('motherName').optional().isString().withMessage('Mother name must be a string'),
    body('fatherName').optional().isString().withMessage('Father name must be a string'),
    body('motherId').optional().isMongoId().withMessage('Mother ID must be a valid Mongo ID'),
    body('fatherId').optional().isMongoId().withMessage('Father ID must be a valid Mongo ID'),
    validate
];

// ───────────────────────── Sell Record ─────────────────────────
export const sellRecordValidation = [
    body('animalId').isMongoId().withMessage('A valid animal ID is required'),
    body('buyer').notEmpty().withMessage('Buyer name is required'),
    body('mobileNumber').isMobilePhone('en-IN').withMessage('A valid Indian mobile number is required'),
    body('amount').isFloat({ min: 0 }).withMessage('Amount must be a positive number'),
    body('soldAt').optional().isISO8601().withMessage('Sold date must be a valid ISO 8601 date'),
    validate
];

// ───────────────────────── Death Record ─────────────────────────
export const deathRecordValidation = [
    body('animalId').isMongoId().withMessage('A valid animal ID is required'),
    body('dateOfDeath').isISO8601().withMessage('Date of death must be a valid ISO 8601 date'),
    body('reason').notEmpty().withMessage('Reason for death is required'),
    validate
];

// ───────────────────────── Donation Record ─────────────────────────
export const donationRecordValidation = [
    body('animalId').isMongoId().withMessage('A valid animal ID is required'),
    body('gaushalaName').notEmpty().withMessage('Receiving gaushala name is required'),
    body('mobileNumber').isMobilePhone('en-IN').withMessage('A valid Indian mobile number is required'),
    body('donatedAt').optional().isISO8601().withMessage('Donated date must be a valid ISO 8601 date'),
    validate
];
