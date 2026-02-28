import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import logger from '@utils/logger.js';

// ───────────────────────── Add Dry-Off Record ─────────────────────────
export const addDryOff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { animalId, date, reason, remarks } = req.body;

        const record = await prisma.dryOffRecord.create({
            data: {
                animalId,
                gaushalaId,
                date: new Date(date),
                reason,
                remarks: remarks || null
            }
        });

        logger.info(`Dry-off record created for animal ${animalId} - reason: ${reason}`);
        res.status(201).json({ success: true, message: 'Dry-off record added successfully', data: record });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Dry-Off Records ─────────────────────────
export const getDryOffRecords = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { filter } = req.query; // filter: 'all', 'pregnant', 'other'

        let regularDryOffs: any[] = [];
        let pregnantDryOffs: any[] = [];

        // 1. Fetch from regular DryOffRecord
        if (!filter || filter === 'all' || filter === 'other') {
            regularDryOffs = await prisma.dryOffRecord.findMany({
                where: {
                    gaushalaId,
                },
                orderBy: { date: 'desc' }
            });
        }

        // 2. Fetch from ConceptionJourney (status DRY_OFF)
        if (!filter || filter === 'all' || filter === 'pregnant') {
            pregnantDryOffs = await prisma.conceptionJourney.findMany({
                where: {
                    gaushalaId,
                    status: 'DRY_OFF',
                },
                orderBy: { dryOffDate: 'desc' }
            });
        }

        // 3. Collect unique animal IDs to fetch names and tag numbers
        const animalIds = [...new Set([
            ...regularDryOffs.map(r => r.animalId),
            ...pregnantDryOffs.map(r => r.animalId)
        ])];

        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } }
        });
        const animalMap = new Map(animals.map((a: any) => [a.id, a]));

        // 4. Format and Combine
        const formattedRegular = regularDryOffs.map(r => {
            const animal = animalMap.get(r.animalId) as any;
            return {
                animalName: animal?.name || null,
                date: r.date,
                tagNumber: animal?.tagNumber || null
            };
        });

        const formattedPregnant = pregnantDryOffs.map(p => {
            const animal = animalMap.get(p.animalId) as any;
            return {
                animalName: animal?.name || null,
                date: p.dryOffDate,
                tagNumber: animal?.tagNumber || null
            };
        });

        const combined = [...formattedRegular, ...formattedPregnant].sort((a, b) =>
            new Date(b.date).getTime() - new Date(a.date).getTime()
        );

        res.json({ success: true, data: combined });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Dry-Off Record ─────────────────────────
export const updateDryOff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { id } = req.params;
        const { date, reason, remarks } = req.body;

        const record = await prisma.dryOffRecord.update({
            where: { id, gaushalaId },
            data: {
                ...(date && { date: new Date(date) }),
                ...(reason && { reason }),
                ...(remarks !== undefined && { remarks })
            }
        });

        res.json({ success: true, message: 'Dry-off record updated successfully', data: record });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Delete Dry-Off Record ─────────────────────────
export const deleteDryOff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;
        const { id } = req.params;

        await prisma.dryOffRecord.delete({ where: { id, gaushalaId } });

        logger.info(`Dry-off record ${id} deleted — animal now eligible for conception`);
        res.json({ success: true, message: 'Dry-off record removed. Animal is now eligible for conception.' });
    } catch (error) {
        next(error);
    }
};

// ──────────────────────── Get Eligible Cows for Dry-Off Dropdown (Non-Pregnancy) ────────────────────────
export const getEligibleForDryOffDropdown = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala.id as string;

        // Only lactating cows that are NOT pregnant are eligible for regular dry-off
        const animals = await prisma.animal.findMany({
            where: {
                gaushalaId,
                isLactating: true
            },
            select: {
                id: true,
                tagNumber: true,
                name: true
            }
        });

        // Filter out those with active pregnancy journeys
        const activeJourneys = await prisma.conceptionJourney.findMany({
            where: { gaushalaId, status: { notIn: ['COMPLETED', 'FAILED'] } },
            select: { animalId: true }
        });
        const pregnantIds = new Set(activeJourneys.map((j: any) => j.animalId));

        const eligibleAnimals = animals.filter(a => !pregnantIds.has(a.id));

        res.json({ success: true, data: eligibleAnimals });
    } catch (error) {
        next(error);
    }
};
