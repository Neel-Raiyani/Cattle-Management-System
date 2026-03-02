import { Request, Response, NextFunction } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';
import logger from '@utils/logger.js';

const prisma = new PrismaClient();

export const createGaushala = async (req: any, res: Response, next: NextFunction) => {
    try {
        const userId = req.user.userId;
        const { name, city, state, totalCattle } = req.body;

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const gaushala = await tx.gaushala.create({
                data: {
                    name,
                    city,
                    state,
                    totalCattle: parseInt(totalCattle) || 0
                }
            });

            await tx.userGaushala.create({
                data: {
                    userId,
                    gaushalaId: gaushala.id,
                    role: 'OWNER'
                }
            });

            return gaushala;
        });

        logger.info(`New Gaushala created by user ${userId}: ${name}`);
        res.status(201).json({
            message: 'Gaushala created successfully',
            gaushala: result
        });
    } catch (error) {
        next(error);
    }
};

export const getMyGaushalas = async (req: any, res: Response, next: NextFunction) => {
    try {
        const userId = req.user.userId;
        const memberships = await prisma.userGaushala.findMany({
            where: { userId, isActive: true },
            include: { gaushala: true }
        });

        const gaushalas = memberships.map((m: any) => ({
            id: m.gaushala.id,
            name: m.gaushala.name,
            role: m.role,
            city: m.gaushala.city,
            totalCattle: m.gaushala.totalCattle
        }));

        res.status(200).json(gaushalas);
    } catch (error) {
        next(error);
    }
};
