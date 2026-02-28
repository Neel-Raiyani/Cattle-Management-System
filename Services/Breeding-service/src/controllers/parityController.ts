import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import logger from '@utils/logger.js';
import { AppError } from '@utils/AppError.js';

// ───────────────────────── Add Parity Record ─────────────────────────
export const addParityRecord = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const {
            animalId, parityNo, cowPhoto, pregnancyType,
            bullId, bullName, deliveryDate, pregnancyDate,
            dryOffDate, note
        } = req.body;

        const record = await prisma.parityRecord.create({
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

        logger.info(`Parity record added for animal ${animalId}, parity ${parityNo}`);
        res.status(201).json({
            success: true,
            message: 'Parity record added successfully',
            data: record
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Parity Records ─────────────────────────
export const getParityRecords = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { animalId } = req.params;

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
export const updateParityRecord = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { id } = req.params;
        const {
            parityNo, cowPhoto, pregnancyType,
            bullId, bullName, deliveryDate, pregnancyDate,
            dryOffDate, note
        } = req.body;

        const record = await prisma.parityRecord.update({
            where: { id, gaushalaId },
            data: {
                ...(parityNo !== undefined && { parityNo }),
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
