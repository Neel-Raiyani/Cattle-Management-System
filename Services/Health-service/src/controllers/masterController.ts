import { Request, Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { AppError } from '@utils/AppError.js';
import { AuthRequest } from '@appTypes/express.js';

/**
 * Fetch all diseases for a specific gaushala.
 */
export const getAllDiseases = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const diseases = await prisma.diseaseMaster.findMany({
            where: { gaushalaId },
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
 * Add a new disease for a specific gaushala.
 */
export const addDisease = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const { name } = req.body;
        if (!name) throw new AppError('Disease name is required', 400);

        const disease = await prisma.diseaseMaster.create({
            data: { name, gaushalaId }
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
 * Fetch all vaccines for a specific gaushala.
 */
export const getAllVaccines = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const vaccines = await prisma.vaccineMaster.findMany({
            where: { gaushalaId },
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
 * Add a new vaccine for a specific gaushala.
 */
export const addVaccine = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
        if (!gaushalaId) throw new AppError('Gaushala ID is required', 400);

        const { name } = req.body;
        if (!name) throw new AppError('Vaccine name is required', 400);

        const vaccine = await prisma.vaccineMaster.create({
            data: { name, gaushalaId }
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
export const getLabTests = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
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
export const addLabTest = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.gaushala?.id as string;
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
export const deleteLabTest = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.gaushala?.id as string;

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


