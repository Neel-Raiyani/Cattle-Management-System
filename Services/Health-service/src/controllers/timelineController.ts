import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';

/**
 * Get a unified timeline of all health events for an animal.
 * Combines MedicalRecords, VaccinationRecords, and DewormingRecords.
 */
export const getHealthTimeline = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { animalId } = req.params;

        // Fetch all three types in parallel
        const [medical, vaccination, deworming] = await Promise.all([
            prisma.medicalRecord.findMany({ where: { animalId, gaushalaId } }),
            prisma.vaccinationRecord.findMany({ where: { animalId, gaushalaId } }),
            prisma.dewormingRecord.findMany({ where: { animalId, gaushalaId } })
        ]);

        // Merge and format
        const timeline = [
            ...medical.map((r: any) => ({ ...r, eventType: 'MEDICAL' })),
            ...vaccination.map((r: any) => ({ ...r, eventType: 'VACCINATION' })),
            ...deworming.map((r: any) => ({ ...r, eventType: 'DEWORMING' }))
        ];

        // Sort by date (descending)
        timeline.sort((a: any, b: any) => {
            const dateA = a.visitDate || a.doseDate;
            const dateB = b.visitDate || b.doseDate;
            return new Date(dateB).getTime() - new Date(dateA).getTime();
        });

        res.status(200).json({
            success: true,
            totalEvents: timeline.length,
            data: timeline
        });
    } catch (error) {
        next(error);
    }
};
