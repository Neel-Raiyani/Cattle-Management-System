import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma } from '@prisma/client';
import logger from '@utils/logger.js';
import { AppError } from '@utils/AppError.js';
import type { AuthRequest } from '@appTypes/express.js';

// ───────────────────────── Record Sale ─────────────────────────
export const recordSell = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const {
            animalId, buyer, mobileNumber, city,
            amount, referenceBy, photoUrl, soldAt
        } = req.body;

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const animal = await tx.animal.findFirst({
                where: { id: animalId, gaushalaId }
            });

            if (!animal) {
                throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
            }
            if (animal.status !== 'ACTIVE') {
                throw new AppError(
                    `Cannot sell: Animal status is ${animal.status}`,
                    409,
                    'ANIMAL_NOT_ACTIVE'
                );
            }

            const sellRecord = await tx.sellRecord.create({
                data: {
                    animalId,
                    buyer,
                    mobileNumber,
                    city: city || null,
                    amount: Number(amount),
                    referenceBy: referenceBy || null,
                    photoUrl: photoUrl || null,
                    soldAt: soldAt ? new Date(soldAt) : new Date()
                }
            });

            await tx.animal.update({
                where: { id: animalId },
                data: { status: 'SOLD' }
            });

            return sellRecord;
        });

        logger.info(`Animal sold: ${animalId} in Gaushala ${gaushalaId}`);
        res.status(201).json({
            success: true,
            message: 'Sell record created successfully',
            record: result
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Record Death ─────────────────────────
export const recordDeath = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { animalId, dateOfDeath, reason, lastPhotoUrl } = req.body;

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const animal = await tx.animal.findFirst({
                where: { id: animalId, gaushalaId }
            });

            if (!animal) {
                throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
            }
            if (animal.status !== 'ACTIVE') {
                throw new AppError(
                    `Cannot record death: Animal status is ${animal.status}`,
                    409,
                    'ANIMAL_NOT_ACTIVE'
                );
            }

            const deathRecord = await tx.deathRecord.create({
                data: {
                    animalId,
                    dateOfDeath: new Date(dateOfDeath),
                    reason,
                    lastPhotoUrl: lastPhotoUrl || null
                }
            });

            await tx.animal.update({
                where: { id: animalId },
                data: { status: 'DEAD' }
            });

            return deathRecord;
        });

        logger.info(`Animal death recorded: ${animalId} in Gaushala ${gaushalaId}`);
        res.status(201).json({
            success: true,
            message: 'Death record created successfully',
            record: result
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Record Donation ─────────────────────────
export const recordDonation = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const {
            animalId, gaushalaName, mobileNumber,
            referenceBy, photoUrl, donatedAt
        } = req.body;

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const animal = await tx.animal.findFirst({
                where: { id: animalId, gaushalaId }
            });

            if (!animal) {
                throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
            }
            if (animal.status !== 'ACTIVE') {
                throw new AppError(
                    `Cannot donate: Animal status is ${animal.status}`,
                    409,
                    'ANIMAL_NOT_ACTIVE'
                );
            }

            const donationRecord = await tx.donationRecord.create({
                data: {
                    animalId,
                    gaushalaName,
                    mobileNumber,
                    referenceBy: referenceBy || null,
                    photoUrl: photoUrl || null,
                    donatedAt: donatedAt ? new Date(donatedAt) : new Date()
                }
            });

            await tx.animal.update({
                where: { id: animalId },
                data: { status: 'DONATED' }
            });

            return donationRecord;
        });

        logger.info(`Animal donated: ${animalId} in Gaushala ${gaushalaId}`);
        res.status(201).json({
            success: true,
            message: 'Donation record created successfully',
            record: result
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Disposal Record ─────────────────────────
export const updateDisposalRecord = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const type = req.params.type as string;
        const id = req.params.id as string;
        const data = req.body;

        if (Object.keys(data).length === 0) {
            throw new AppError('No fields provided for update', 400, 'NO_UPDATE_FIELDS');
        }

        // Prevent changing the animalId on disposal records
        delete data.animalId;

        const validTypes = ['sell', 'death', 'donation'];
        if (!validTypes.includes(type)) {
            throw new AppError(
                `Invalid disposal type '${type}'. Use: ${validTypes.join(', ')}`,
                400,
                'INVALID_DISPOSAL_TYPE'
            );
        }

        let result;
        switch (type) {
            case 'sell':
                result = await prisma.sellRecord.update({
                    where: { id },
                    data: {
                        buyer: data.buyer,
                        mobileNumber: data.mobileNumber,
                        city: data.city,
                        amount: data.amount !== undefined ? Number(data.amount) : undefined,
                        referenceBy: data.referenceBy,
                        photoUrl: data.photoUrl,
                        soldAt: data.soldAt ? new Date(data.soldAt) : undefined
                    }
                });
                break;
            case 'death':
                result = await prisma.deathRecord.update({
                    where: { id },
                    data: {
                        dateOfDeath: data.dateOfDeath ? new Date(data.dateOfDeath) : undefined,
                        reason: data.reason,
                        lastPhotoUrl: data.lastPhotoUrl
                    }
                });
                break;
            case 'donation':
                result = await prisma.donationRecord.update({
                    where: { id },
                    data: {
                        gaushalaName: data.gaushalaName,
                        mobileNumber: data.mobileNumber,
                        referenceBy: data.referenceBy,
                        photoUrl: data.photoUrl,
                        donatedAt: data.donatedAt ? new Date(data.donatedAt) : undefined
                    }
                });
                break;
        }

        logger.info(`Disposal record updated: ${type}/${id}`);
        res.status(200).json({
            success: true,
            message: 'Record updated successfully',
            record: result
        });
    } catch (error) {
        next(error);
    }
};
