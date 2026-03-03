import { Request, Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { AppError } from '@utils/AppError.js';

/**
 * Fetch all global diseases for dropdowns.
 */
export const getAllDiseases = async (_req: Request, res: Response, next: NextFunction) => {
    try {
        const diseases = await prisma.diseaseMaster.findMany({
            orderBy: { name: 'asc' }
        });
        res.status(200).json({
            success: true,
            data: diseases
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Add a new global disease.
 */
export const addDisease = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { name } = req.body;
        if (!name) throw new AppError('Disease name is required', 400);

        const disease = await prisma.diseaseMaster.create({
            data: { name }
        });

        res.status(201).json({
            success: true,
            message: 'Disease added successfully',
            data: disease
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Fetch all global vaccines for dropdowns.
 */
export const getAllVaccines = async (_req: Request, res: Response, next: NextFunction) => {
    try {
        const vaccines = await prisma.vaccineMaster.findMany({
            orderBy: { name: 'asc' }
        });
        res.status(200).json({
            success: true,
            data: vaccines
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Add a new global vaccine.
 */
export const addVaccine = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { name } = req.body;
        if (!name) throw new AppError('Vaccine name is required', 400);

        const vaccine = await prisma.vaccineMaster.create({
            data: { name }
        });

        res.status(201).json({
            success: true,
            message: 'Vaccine added successfully',
            data: vaccine
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Fetch all lab tests for a specific gaushala.
 */
export const getLabTests = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const labTests = await (prisma as any).labtestMaster.findMany({
            where: { gaushalaId },
            orderBy: { name: 'asc' }
        });

        res.status(200).json({
            success: true,
            data: labTests
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Add a new lab test for a specific gaushala.
 */
export const addLabTest = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const { name } = req.body;
        if (!name) throw new AppError('Lab test name is required', 400);

        const labTest = await (prisma as any).labtestMaster.create({
            data: {
                name,
                gaushalaId
            }
        });

        res.status(201).json({
            success: true,
            message: 'Lab test added successfully',
            data: labTest
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a lab test master.
 */
export const deleteLabTest = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.headers['gaushala-id'] as string;

        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const labTest = await (prisma as any).labtestMaster.findFirst({
            where: { id, gaushalaId }
        });

        if (!labTest) throw new AppError('Lab test not found or unauthorized', 404);

        await (prisma as any).labtestMaster.delete({
            where: { id }
        });

        res.status(200).json({
            success: true,
            message: 'Lab test deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};


