import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma } from '@prisma/client';
import { AppError } from '@utils/AppError.js';
import type { AuthRequest } from '@appTypes/express.js';

/**
 * Record a new medical visit (Illness/Checkup).
 */
export const recordMedicalVisit = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        const {
            animalId, visitType, visitDate, visitNumber,
            vetId, diseaseId, medicalStatus, symptoms, treatment
        } = req.body;

        // Verify animal exists in this gaushala
        const animal = await prisma.animal.findFirst({
            where: { id: animalId, gaushalaId, isActive: true }
        });

        if (!animal) {
            throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
        }

        const medicalRecord = await prisma.medicalRecord.create({
            data: {
                animalId,
                gaushalaId,
                visitType,
                visitDate: new Date(visitDate),
                visitNumber: visitNumber || null,
                vetId: vetId || null,
                diseaseId: diseaseId || null,
                medicalStatus,
                symptoms: symptoms || null,
                treatment: treatment || null
            }
        });

        res.status(201).json({
            success: true,
            message: 'Medical visit recorded successfully',
            data: medicalRecord
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update an existing medical record.
 */
export const updateMedicalRecord = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        const { id } = req.params;
        const updateData: Partial<Prisma.MedicalRecordUpdateInput> = req.body;

        // Ensure record exists and belongs to this gaushala
        const existingRecord = await prisma.medicalRecord.findFirst({
            where: { id: id as string, gaushalaId: gaushalaId as string }
        });

        if (!existingRecord) {
            throw new AppError('Medical record not found', 404, 'RECORD_NOT_FOUND');
        }

        // Prevent animalId or gaushalaId from being changed via update
        delete (updateData as any).animalId;
        delete (updateData as any).gaushalaId;

        if (updateData.visitDate) {
            updateData.visitDate = new Date(updateData.visitDate as any);
        }

        const updatedRecord = await prisma.medicalRecord.update({
            where: { id: id as string },
            data: updateData
        });

        res.status(200).json({
            success: true,
            message: 'Medical record updated successfully',
            data: updatedRecord
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all medical records for a specific animal.
 */
export const getMedicalHistoryByAnimal = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        const { animalId } = req.params;

        const animal = await prisma.animal.findFirst({
            where: { id: animalId as string, gaushalaId: gaushalaId as string, isActive: true }
        });

        if (!animal) {
            throw new AppError('Animal not found or inactive', 404, 'ANIMAL_NOT_FOUND');
        }

        const history = await prisma.medicalRecord.findMany({
            where: { animalId: animalId as string, gaushalaId: gaushalaId as string },
            orderBy: { visitDate: 'desc' }
        });

        res.status(200).json({
            success: true,
            data: history
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all animals currently marked as 'SICK' based on their latest medical record.
 */
export const getSickAnimals = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;

        // 1. Fetch all medical records for this gaushala, ordered by visitDate descending
        const allRecords = await prisma.medicalRecord.findMany({
            where: { gaushalaId },
            orderBy: { visitDate: 'desc' }
        });

        // 2. Identifying the latest record for each animal
        const latestRecordsMap = new Map<string, typeof allRecords[0]>();
        for (const record of allRecords) {
            if (!latestRecordsMap.has(record.animalId)) {
                latestRecordsMap.set(record.animalId, record);
            }
        }

        // 3. Filter for those whose latest status is 'SICK'
        const sickLatestRecords = Array.from(latestRecordsMap.values()).filter(
            r => r.medicalStatus === 'SICK'
        );

        if (sickLatestRecords.length === 0) {
            return res.status(200).json({
                success: true,
                count: 0,
                data: []
            });
        }

        // 4. Fetch Animal and Disease details for these records
        const animalIds = sickLatestRecords.map(r => r.animalId);
        const diseaseIds = sickLatestRecords.map(r => r.diseaseId).filter(id => id !== null) as string[];

        const [animals, diseases] = await Promise.all([
            prisma.animal.findMany({
                where: { id: { in: animalIds }, isActive: true },
                select: { id: true, name: true, tagNumber: true, photoUrl: true, animalNumber: true }
            }),
            prisma.diseaseMaster.findMany({
                where: { id: { in: diseaseIds } }
            })
        ]);

        const animalMap = new Map(animals.map(a => [a.id, a]));
        const diseaseMap = new Map(diseases.map(d => [d.id, d.name]));

        // 5. Build final response
        const result = sickLatestRecords.map(record => ({
            id: record.id,
            animal: animalMap.get(record.animalId) || null,
            visitDate: record.visitDate,
            visitType: record.visitType,
            disease: record.diseaseId ? (diseaseMap.get(record.diseaseId) || 'Unknown') : 'N/A',
            symptoms: record.symptoms,
            treatment: record.treatment,
            medicalStatus: record.medicalStatus
        })).filter(item => item.animal !== null); // Ensure we don't return records for deleted/inactive animals

        res.status(200).json({
            success: true,
            count: result.length,
            data: result
        });
    } catch (error) {
        next(error);
    }
};
