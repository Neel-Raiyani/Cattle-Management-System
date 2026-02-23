import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { AppError } from '@utils/AppError.js';
import logger from '@utils/logger.js';

/**
 * Get current feed inventory status for a Gaushala.
 * Returns the total quantity in Kg.
 */
export const getInventoryStatus = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;

        let inventory = await prisma.feedInventory.findUnique({
            where: { gaushalaId }
        });

        // Initialize if not exists
        if (!inventory) {
            inventory = await prisma.feedInventory.create({
                data: {
                    gaushalaId,
                    totalQuantity: 0
                }
            });
        }

        res.status(200).json({
            success: true,
            inventory
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update feed inventory (e.g., adding stock).
 * quantity is in Kg.
 * Ensures that the total quantity doesn't drop below 0.
 */
export const updateInventory = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { quantity, description } = req.body;

        if (quantity === undefined) {
            throw new AppError('Quantity is required', 400, 'MISSING_QUANTITY');
        }

        const updateVal = Number(quantity);
        if (isNaN(updateVal)) {
            throw new AppError('Quantity must be a valid number', 400, 'INVALID_QUANTITY');
        }

        const inventory = await prisma.$transaction(async (tx) => {
            const current = await tx.feedInventory.findUnique({
                where: { gaushalaId }
            });

            const currentTotal = current?.totalQuantity || 0;
            const newTotal = currentTotal + updateVal;

            if (newTotal < 0) {
                throw new AppError(
                    `Invalid operation. Resulting inventory would be negative (${newTotal} Kg). Current: ${currentTotal} Kg.`,
                    400,
                    'NEGATIVE_INVENTORY_NOT_ALLOWED'
                );
            }

            return await tx.feedInventory.upsert({
                where: { gaushalaId },
                update: {
                    totalQuantity: newTotal
                },
                create: {
                    gaushalaId,
                    totalQuantity: newTotal
                }
            });
        });

        logger.info(`Feed inventory updated for Gaushala ${gaushalaId}: ${updateVal > 0 ? 'Added' : 'Subtracted'} ${Math.abs(updateVal)} Kg. New Total: ${inventory.totalQuantity} Kg. ${description || ''}`);

        res.status(200).json({
            success: true,
            message: 'Inventory updated successfully',
            inventory
        });
    } catch (error) {
        next(error);
    }
};
