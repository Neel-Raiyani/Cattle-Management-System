import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma, PregnancyType } from '@prisma/client';
import logger from '@utils/logger.js';
import { AppError } from '@utils/AppError.js';
import type { AuthRequest } from '@appTypes/express.js';

interface ParityBody {
    animalId: string;
    parityNo: number;
    cowPhoto?: string;
    pregnancyType: PregnancyType;
    bullId?: string;
    bullName?: string;
    deliveryDate: string;
    pregnancyDate: string;
    dryOffDate?: string;
    note?: string;
}

// ───────────────────────── Add Parity Record ─────────────────────────
export const addParityRecord = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) {
            return res.status(401).json({ message: 'Gaushala ID missing' });
        }
        const {
            animalId, parityNo, cowPhoto, pregnancyType,
            bullId, bullName, deliveryDate, pregnancyDate,
            dryOffDate, note
        } = req.body as ParityBody;

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const record = await tx.parityRecord.create({
                data: {
                    animalId,
                    gaushalaId,
                    parityNo,
                    cowPhoto: cowPhoto || null,
                    pregnancyType,
                    bullId: bullId || null,
                    bullName: bullName || null,
                    deliveryDate: new Date(deliveryDate),
                    pregnancyDate: new Date(pregnancyDate),
                    dryOffDate: dryOffDate ? new Date(dryOffDate) : null,
                    note: note || null
                }
            });

            // Update animal status
            await tx.animal.update({
                where: { id: animalId },
                data: {
                    parity: parityNo,
                    isLactating: true,
                    isDryOff: false,
                    isPregnant: false
                }
            });

            return record;
        });

        logger.info(`Parity record added for animal ${animalId}, parity ${parityNo}. Animal status updated.`);
        res.status(201).json({
            success: true,
            message: 'Parity record added successfully and animal status updated',
            data: result
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Parity Records ─────────────────────────
export const getParityRecords = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) {
            return res.status(401).json({ message: 'Gaushala ID missing' });
        }
        const animalId = req.params.animalId as string;

        const records = await prisma.parityRecord.findMany({
            where: { animalId, gaushalaId },
            orderBy: { parityNo: 'desc' }
        });

        const animal = await prisma.animal.findUnique({
            where: { id: animalId },
            select: { name: true, tagNumber: true }
        });

        const data = records.map(r => ({
            name: animal?.name || null,
            tagno: animal?.tagNumber || null,
            parity: r.parityNo,
            pregnancyType: r.pregnancyType,
            deliverydate: r.deliveryDate,
            note: r.note,
            bullname: r.bullName,
            pregnancy_date: r.pregnancyDate
        }));

        res.status(200).json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Parity Record ─────────────────────────
export const updateParityRecord = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) {
            return res.status(401).json({ message: 'Gaushala ID missing' });
        }
        const id = req.params.id as string;
        const {
            parityNo, cowPhoto, pregnancyType,
            bullId, bullName, deliveryDate, pregnancyDate,
            dryOffDate, note
        } = req.body as Partial<ParityBody>;

        const record = await prisma.parityRecord.update({
            where: { id, gaushalaId },
            data: {
                ...(parityNo !== undefined && { parityNo: Number(parityNo) }),
                ...(cowPhoto !== undefined && { cowPhoto }),
                ...(pregnancyType !== undefined && { pregnancyType }),
                ...(bullId !== undefined && { bullId }),
                ...(bullName !== undefined && { bullName }),
                ...(deliveryDate && { deliveryDate: new Date(deliveryDate) }),
                ...(pregnancyDate && { pregnancyDate: new Date(pregnancyDate) }),
                ...(dryOffDate !== undefined && { dryOffDate: dryOffDate ? new Date(dryOffDate) : null }),
                ...(note !== undefined && { note })
            }
        });

        res.status(200).json({
            success: true,
            message: 'Parity record updated successfully',
            data: record
        });
    } catch (error) {
        next(error);
    }
};
