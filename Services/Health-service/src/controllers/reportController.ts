import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma } from '@prisma/client';
import { getPresignedViewUrl } from '@utils/s3.js';
import type { AuthRequest } from '@appTypes/express.js';

// ───────────────────────── Deworming Report ─────────────────────────
/**
 * Date-wise Deworming Dose report
 * Returns cowphoto, cowname, tagno, animal no., dose date, company name, Doctor name, last dose date, Next dose date, quantity, dose type
 */
export const getDewormingReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to, animalId } = req.query as { from?: string; to?: string; animalId?: string };
        const where: Prisma.DewormingRecordWhereInput = { gaushalaId };

        if (animalId) where.animalId = animalId;
        if (from || to) {
            where.doseDate = {};
            if (from) (where.doseDate as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.doseDate as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const records = await prisma.dewormingRecord.findMany({
            where,
            orderBy: { doseDate: 'desc' }
        });

        const animalIds = [...new Set(records.map(r => r.animalId))];
        const vetIds = [...new Set(records.map(r => r.vetId).filter(v => v !== null))] as string[];

        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const vets = await prisma.user.findMany({
            where: { id: { in: vetIds } },
            select: { id: true, name: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const vetMap = new Map(vets.map(v => [v.id, v.name]));

        const data = [];
        for (const r of records) {
            const animal = animalMap.get(r.animalId);
            const doctorName = r.vetId ? vetMap.get(r.vetId) : '-';

            // Calculate last dose date for this specific animal
            const lastDose = await prisma.dewormingRecord.findFirst({
                where: {
                    animalId: r.animalId,
                    doseDate: { lt: r.doseDate }
                },
                orderBy: { doseDate: 'desc' },
                select: { doseDate: true }
            });

            data.push({
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                animalNo: animal?.animalNumber || null,
                doseDate: r.doseDate,
                companyName: r.companyName || '-',
                doctorName: doctorName || '-',
                lastDoseDate: lastDose?.doseDate || null,
                nextDoseDate: r.nextDoseDate || null,
                quantity: r.quantity || '-',
                doseType: r.doseType
            });
        }

        res.json({ success: true, totalCount: records.length, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Dropdowns for Deworming Report ─────────────────────────
/**
 * Returns Cows or Bulls based on type
 * type: COW (Gender: FEMALE) or BULL (Gender: MALE)
 */
export const getDewormingDropdowns = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        const { type } = req.query as { type?: 'COW' | 'BULL' };

        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const where: any = { gaushalaId, status: 'ACTIVE' };
        if (type === 'COW') {
            where.gender = 'FEMALE';
        } else if (type === 'BULL') {
            where.gender = 'MALE';
        }

        const animals = await prisma.animal.findMany({
            where,
            select: { id: true, name: true, tagNumber: true, animalNumber: true }
        });

        res.json({ success: true, data: animals });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Medical Report ─────────────────────────
/**
 * Medical Report (Animal-wise, Date-wise, or Disease-wise)
 * Returns cowphoto, name, tagno, animal no., medical status, visit type, disease, doctor name, visit date
 */
export const getMedicalReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to, animalId, diseaseId } = req.query as { from?: string; to?: string; animalId?: string; diseaseId?: string };

        const where: Prisma.MedicalRecordWhereInput = { gaushalaId };

        if (animalId) where.animalId = animalId;
        if (diseaseId) where.diseaseId = diseaseId;
        if (from || to) {
            where.visitDate = {};
            if (from) (where.visitDate as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.visitDate as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const records = await prisma.medicalRecord.findMany({
            where,
            orderBy: { visitDate: 'desc' }
        });

        const animalIds = [...new Set(records.map(r => r.animalId))];
        const vetIds = [...new Set(records.map(r => r.vetId).filter(v => v !== null))] as string[];
        const dIds = [...new Set(records.map(r => r.diseaseId).filter(d => d !== null))] as string[];

        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const vets = await prisma.user.findMany({
            where: { id: { in: vetIds } },
            select: { id: true, name: true }
        });

        const diseases = await prisma.diseaseMaster.findMany({
            where: { id: { in: dIds } },
            select: { id: true, name: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const vetMap = new Map(vets.map(v => [v.id, v.name]));
        const diseaseMap = new Map(diseases.map(d => [d.id, d.name]));

        const data = records.map(r => {
            const animal = animalMap.get(r.animalId);
            const doctorName = r.vetId ? vetMap.get(r.vetId) : '-';
            const diseaseName = r.diseaseId ? diseaseMap.get(r.diseaseId) : 'N/A';

            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                animalNo: animal?.animalNumber || null,
                medicalStatus: r.medicalStatus,
                visitType: r.visitType,
                disease: diseaseName,
                doctorName: doctorName || '-',
                visitDate: r.visitDate
            };
        });

        res.json({ success: true, totalCount: records.length, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Vaccine Report ─────────────────────────
/**
 * Vaccine Report (Animal-wise, Date-wise, or Vaccine-wise)
 * Returns photo, name, tagno, animal no., vaccine, dose date, remark, dosetype
 */
export const getVaccineReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to, animalId, vaccineId } = req.query as { from?: string; to?: string; animalId?: string; vaccineId?: string };

        const where: Prisma.VaccinationRecordWhereInput = { gaushalaId };

        if (animalId) where.animalId = animalId;
        if (vaccineId) where.vaccineId = vaccineId;
        if (from || to) {
            where.doseDate = {};
            if (from) (where.doseDate as Prisma.DateTimeFilter).gte = new Date(from);
            if (to) (where.doseDate as Prisma.DateTimeFilter).lte = new Date(to);
        }

        const records = await prisma.vaccinationRecord.findMany({
            where,
            orderBy: { doseDate: 'desc' }
        });

        const animalIds = [...new Set(records.map(r => r.animalId))];
        const vIds = [...new Set(records.map(r => r.vaccineId).filter(v => v !== null))] as string[];

        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const vaccineMasters = await prisma.vaccineMaster.findMany({
            where: { id: { in: vIds } },
            select: { id: true, name: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const vaccineMap = new Map(vaccineMasters.map(v => [v.id, v.name]));

        const data = records.map(r => {
            const animal = animalMap.get(r.animalId);
            const vaccineName = r.vaccineId ? vaccineMap.get(r.vaccineId) : 'N/A';

            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                animalNo: animal?.animalNumber || null,
                vaccine: vaccineName,
                doseDate: r.doseDate,
                remark: r.remark || '-',
                dosetype: r.doseType
            };
        });

        res.json({ success: true, totalCount: records.length, data });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Lab Report ─────────────────────────
/**
 * Lab Report (Animal-wise, Date-wise, or Labtest-wise)
 * Returns photo, name, tagno, animal no., labtest name, sample date, result date, Remark
 */
export const getLabReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) return res.status(401).json({ message: 'Gaushala ID missing' });

        const { from, to, animalId, labtestId } = req.query as { from?: string; to?: string; animalId?: string; labtestId?: string };

        const where: any = { gaushalaId };

        if (animalId) where.animalId = animalId;
        if (labtestId) where.labtestId = labtestId;
        if (from || to) {
            where.sampleDate = {};
            if (from) where.sampleDate.gte = new Date(from);
            if (to) where.sampleDate.lte = new Date(to);
        }

        const records = await (prisma as any).labRecord.findMany({
            where,
            orderBy: { sampleDate: 'desc' }
        });

        const animalIds = [...new Set(records.map((r: any) => r.animalId))] as string[];
        const lIds = [...new Set(records.map((r: any) => r.labtestId))] as string[];

        const animals = await prisma.animal.findMany({
            where: { id: { in: animalIds } },
            select: { id: true, name: true, tagNumber: true, animalNumber: true, photoUrl: true }
        });

        const labtestMasters = await (prisma as any).labtestMaster.findMany({
            where: { id: { in: lIds } },
            select: { id: true, name: true }
        });

        const animalMap = new Map();
        for (const a of animals) {
            const photoUrl = a.photoUrl ? await getPresignedViewUrl('gaushala-media', a.photoUrl) : null;
            animalMap.set(a.id, { ...a, photoUrl });
        }

        const labtestMap = new Map(labtestMasters.map((l: any) => [l.id, l.name]));

        const data = records.map((r: any) => {
            const animal = animalMap.get(r.animalId);
            const labtestName = labtestMap.get(r.labtestId) || 'Unknown';

            return {
                photo: animal?.photoUrl || null,
                name: animal?.name || null,
                tagno: animal?.tagNumber || null,
                animalNo: animal?.animalNumber || null,
                labtestName,
                sampleDate: r.sampleDate,
                resultDate: r.resultDate,
                Remark: r.remark || '-'
            };
        });

        res.json({ success: true, totalCount: records.length, data });
    } catch (error) {
        next(error);
    }
};
