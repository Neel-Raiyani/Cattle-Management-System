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


