import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { AppError } from '@utils/AppError.js';

/**
 * Record a new vaccination.
 */
export const recordVaccination = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { animalId, doseDate, doseType, vaccineId, remark } = req.body;

        // Verify animal
        const animal = await prisma.animal.findFirst({
            where: { id: animalId, gaushalaId }
        });

        if (!animal) {
            throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
        }

        const vaccination = await prisma.vaccinationRecord.create({
            data: {
                animalId,
                gaushalaId,
                doseDate: new Date(doseDate),
                doseType,
                vaccineId,
                remark: remark || null
            }
        });

        res.status(201).json({
            success: true,
            message: 'Vaccination recorded successfully',
            data: vaccination
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update a vaccination record.
 */
export const updateVaccination = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { id } = req.params;
        const updateData: any = req.body;

        const existingRecord = await prisma.vaccinationRecord.findFirst({
            where: { id, gaushalaId }
        });

        if (!existingRecord) {
            throw new AppError('Vaccination record not found', 404, 'RECORD_NOT_FOUND');
        }

        delete updateData.animalId;
        delete updateData.gaushalaId;

        if (updateData.doseDate) updateData.doseDate = new Date(updateData.doseDate);

        const updatedRecord = await prisma.vaccinationRecord.update({
            where: { id },
            data: updateData
        });

        res.status(200).json({
            success: true,
            message: 'Vaccination record updated successfully',
            data: updatedRecord
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get vaccination history for an animal.
 */
export const getVaccinationHistoryByAnimal = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { animalId } = req.params;

        const history = await prisma.vaccinationRecord.findMany({
            where: { animalId, gaushalaId },
            orderBy: { doseDate: 'desc' }
        });

        res.status(200).json({
            success: true,
            data: history
        });
    } catch (error) {
        next(error);
    }
};
