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
