import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma } from '@prisma/client';
import { getPresignedViewUrl } from '@utils/s3.js';
import type { AuthRequest } from '@appTypes/express.js';

// ───────────────────────── Heat Report ─────────────────────────
export const getHeatReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to, animalId } = req.query as { from?: string; to?: string; animalId?: string };
        const where: Prisma.HeatRecordWhereInput = { gaushalaId };

        if (animalId) where.animalId = animalId;
        if (from || to) {
            where.date = {};
            if (from) (where.date as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.date as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const records = await prisma.heatRecord.findMany({
            where,
            orderBy: { date: 'desc' }
        });

        const animalIds = [...new Set(records.map(r => r.animalId))];
        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const bucket = process.env.S3_BUCKET_NAME || 'breeding-media';
        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const data = records.map(r => {
            const animal = animalMap.get(r.animalId);
            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                cowNo: animal?.animalNumber || null,
                date: r.date,
                pregnancyType: r.breedingType,
                parity: r.parity,
                note: r.note || null
            };
        });

        res.json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Pregnancy Report ─────────────────────────
export const getPregnancyReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to } = req.query as { from?: string; to?: string };
        const where: Prisma.ConceptionJourneyWhereInput = {
            gaushalaId,
            status: { in: ['PREGNANT', 'DRY_OFF'] }
        };

        if (from || to) {
            where.conceiveDate = {};
            if (from) (where.conceiveDate as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.conceiveDate as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const journeys = await prisma.conceptionJourney.findMany({
            where,
            orderBy: { conceiveDate: 'desc' }
        });

        const animalIds = [...new Set(journeys.map(j => j.animalId))];
        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const data = journeys.map(j => {
            const animal = animalMap.get(j.animalId);
            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                cowNo: animal?.animalNumber || null,
                parity: j.parity,
                pregnantDate: j.conceiveDate,
                deliveryDate: j.deliveryDate || null,
                totalDays: j.deliveryDate ? Math.floor((new Date(j.deliveryDate).getTime() - new Date(j.conceiveDate).getTime()) / (1000 * 60 * 60 * 24)) : 0,
                totalMilk: 0,
                calfStatus: j.calfStatus || null,
                calfGender: j.calfGender || null
            };
        });

        res.json({ success: true, totalCount: journeys.length, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Delivery Report ─────────────────────────
export const getDeliveryReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to } = req.query as { from?: string; to?: string };
        const where: Prisma.ConceptionJourneyWhereInput = {
            gaushalaId,
            status: 'COMPLETED'
        };

        if (from || to) {
            where.deliveryDate = {};
            if (from) (where.deliveryDate as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.deliveryDate as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const journeys = await prisma.conceptionJourney.findMany({
            where,
            orderBy: { deliveryDate: 'desc' }
        });

        const animalIds = [...new Set(journeys.map(j => j.animalId))];
        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const data = journeys.map(j => {
            const animal = animalMap.get(j.animalId);
            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                cowNo: animal?.animalNumber || null,
                parity: j.parity,
                pregnantDate: j.conceiveDate,
                deliveryDate: j.deliveryDate,
                totalDays: j.deliveryDate ? Math.floor((new Date(j.deliveryDate).getTime() - new Date(j.conceiveDate).getTime()) / (1000 * 60 * 60 * 24)) : 0,
                totalMilk: 0,
                calfStatus: j.calfStatus,
                calfGender: j.calfGender
            };
        });

        res.json({ success: true, totalCount: journeys.length, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Dropdown for Parity Report ─────────────────────────
export const getAnimalsForParityDropdown = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const animals = await prisma.animal.findMany({
            where: { gaushalaId, gender: 'FEMALE', status: 'ACTIVE' },
            select: { id: true, name: true, tagNumber: true }
        });

        res.json({ success: true, data: animals });
    } catch (error) {
        next(error);
    }
};
