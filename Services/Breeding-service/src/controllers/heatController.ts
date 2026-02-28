import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import logger from '@utils/logger.js';
import { AppError } from '@utils/AppError.js';

// ───────────────────────── Record Heat ─────────────────────────
export const recordHeat = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { animalId, date, breedingType, note } = req.body;

        // Auto-fetch parity from the animal's parity field
        const animal = await prisma.animal.findUnique({
            where: { id: animalId }
        });

        if (!animal) {
            throw new AppError('Animal not found', 404, 'ANIMAL_NOT_FOUND');
        }

        const parity = animal.parity || 0;

        const record = await prisma.heatRecord.create({
            data: {
                animalId,
                gaushalaId,
                date: new Date(date),
                parity,
                breedingType,
                note: note || null
            }
        });

        logger.info(`Heat record created for animal ${animalId}`);
        res.status(201).json({ success: true, message: 'Heat record added successfully', data: record });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Heat Records ─────────────────────────
export const getHeatRecords = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { from, to, animalId } = req.query;

        const where: any = { gaushalaId };

        if (animalId) where.animalId = animalId as string;

        if (from || to) {
            where.date = {};
            if (from) where.date.gte = new Date(from as string);
            if (to) where.date.lte = new Date(to as string);
        }

        const records = await prisma.heatRecord.findMany({
            where,
            orderBy: { date: 'desc' }
        });

        const animalIds = [...new Set(records.map((r: any) => r.animalId))];
        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } }
        });
        const animalMap = new Map(animals.map((a: any) => [a.id, a]));

        const formattedRecords = records.map((r: any) => {
            const animalData = animalMap.get(r.animalId) as any;
            return {
                animalName: animalData?.name || null,
                tagNumber: animalData?.tagNumber || null,
                parity: r.parity,
                breedingType: r.breedingType,
                date: r.date,
                note: (r as any).note || null
            };
        });

        res.json({ success: true, data: formattedRecords });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Heat Record ─────────────────────────
export const updateHeatRecord = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { id } = req.params;
        const { date, parity, note } = req.body;

        const record = await prisma.heatRecord.update({
            where: { id, gaushalaId },
            data: {
                ...(date && { date: new Date(date) }),
                ...(parity !== undefined && { parity: Number(parity) }),
                ...(note !== undefined && { note })
            }
        });

        res.json({ success: true, message: 'Heat record updated successfully', data: record });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Delete Heat Record ─────────────────────────
export const deleteHeatRecord = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { id } = req.params;

        await prisma.heatRecord.delete({ where: { id, gaushalaId } });

        logger.info(`Heat record ${id} deleted`);
        res.json({ success: true, message: 'Heat record deleted successfully' });
    } catch (error) {
        next(error);
    }
};
// ───────────────────────── Get Eligible Animals for Heat Dropdown ─────────────────────────
export const getEligibleForHeat = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;

        // Cows that are lactating OR heifers are eligible for heat
        const animals = await prisma.animal.findMany({
            where: {
                gaushalaId,
                OR: [
                    { isLactating: true },
                    { isHeifer: true }
                ]
            },
            select: {
                id: true,
                tagNumber: true,
                name: true
            }
        });

        res.json({ success: true, data: animals });
    } catch (error) {
        next(error);
    }
};
// ───────────────────────── Get Bulls for Breeding Dropdown ─────────────────────────
export const getBullsForDropdown = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;

        const now = new Date();
        const twelveMonthsAgo = new Date(now);
        twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

        // Bulls that are MALE, NOT retired, and NOT calves (>= 12 months)
        const bulls = await prisma.animal.findMany({
            where: {
                gaushalaId,
                gender: 'MALE',
                isRetired: false,
                birthDate: { lte: twelveMonthsAgo }
            },
            select: {
                id: true,
                tagNumber: true,
                name: true
            }
        });

        res.json({ success: true, data: bulls });
    } catch (error) {
        next(error);
    }
};
