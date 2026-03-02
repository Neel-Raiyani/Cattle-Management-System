import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import { Prisma } from '@prisma/client';
import { AppError } from '@utils/AppError.js';
import logger from '@utils/logger.js';

/**
 * Record milk yields in bulk for a date and session.
 * Also deducts feed quantity from inventory.
 */
export const recordYields = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { date, session, entries } = req.body;

        if (!date || !session || !entries || !Array.isArray(entries)) {
            throw new AppError('Date, session, and entries array are required', 400, 'MISSING_DATA');
        }

        // Calculate total feed required
        const totalFeedRequired = entries.reduce((sum: number, entry: any) => sum + (Number(entry.feedQuantity) || 0), 0);

        const entriesToCreate = entries.map((entry: any) => ({
            animalId: entry.animalId,
            gaushalaId,
            date: new Date(date),
            session,
            quantity: Number(entry.quantity), // Milk in Liters
            feedQuantity: Number(entry.feedQuantity) // Feed in Kg
        }));

        // Use transaction to ensure records and inventory are updated together
        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // 1. Check Inventory
            const inventory = await tx.feedInventory.findUnique({
                where: { gaushalaId }
            });

            if (!inventory || inventory.totalQuantity < totalFeedRequired) {
                throw new AppError(
                    `Insufficient feed inventory. Required: ${totalFeedRequired} Kg, Available: ${inventory?.totalQuantity || 0} Kg`,
                    400,
                    'INSUFFICIENT_INVENTORY'
                );
            }

            // 2. Create Milk Records
            const createdRecords = await tx.milkRecord.createMany({
                data: entriesToCreate
            });

            // 3. Deduct Feed from Inventory
            await tx.feedInventory.update({
                where: { gaushalaId },
                data: {
                    totalQuantity: {
                        decrement: totalFeedRequired
                    }
                }
            });

            return createdRecords;
        });

        logger.info(`Recorded ${entries.length} milk yields for Gaushala ${gaushalaId} on ${date} (${session}). Total Feed deducted: ${totalFeedRequired} Kg.`);

        res.status(201).json({
            success: true,
            message: 'Milk yields recorded and feed inventory updated',
            count: result.count
        });
    } catch (error: any) {
        if (error.code === 'P2002') {
            return next(new AppError('One or more animals already have records for this date and session', 409, 'DUPLICATE_ENTRY'));
        }
        next(error);
    }
};

/**
 * Get milk yield entries for a specific date and session.
 */
export const getYieldEntries = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { date, session } = req.query;

        if (!date || !session) {
            throw new AppError('Date and session are required', 400, 'MISSING_PARAMS');
        }

        const entries = await prisma.milkRecord.findMany({
            where: {
                gaushalaId,
                date: new Date(date as string),
                session: session as any
            }
        });

        res.status(200).json({
            success: true,
            entries
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update a single milk yield entry.
 * Adjusts feed inventory by reversing old value and applying new one.
 */
export const updateYield = async (req: any, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { quantity, feedQuantity } = req.body;

        const existing = await prisma.milkRecord.findFirst({
            where: { id, gaushalaId }
        });

        if (!existing) {
            throw new AppError('Milk record not found', 404, 'RECORD_NOT_FOUND');
        }

        const newQuantity = quantity !== undefined ? Number(quantity) : (existing.quantity ?? 0);
        const newFeedQuantity = feedQuantity !== undefined ? Number(feedQuantity) : (existing.feedQuantity ?? 0);

        await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // 1. Calculate feed difference
            const oldFeed = existing.feedQuantity ?? 0;
            const diff = newFeedQuantity - oldFeed;

            if (diff !== 0) {
                // 2. Check Inventory if more feed is being used
                if (diff > 0) {
                    const inventory = await tx.feedInventory.findUnique({ where: { gaushalaId } });
                    if (!inventory || inventory.totalQuantity < diff) {
                        throw new AppError(
                            `Insufficient feed inventory to increase feed. Required additional: ${diff} Kg, Available: ${inventory?.totalQuantity || 0} Kg`,
                            400,
                            'INSUFFICIENT_INVENTORY'
                        );
                    }
                }

                // 3. Adjust Inventory
                await tx.feedInventory.update({
                    where: { gaushalaId },
                    data: {
                        totalQuantity: {
                            decrement: diff
                        }
                    }
                });
            }

            // 4. Update Milk Record
            await tx.milkRecord.update({
                where: { id },
                data: {
                    quantity: newQuantity,
                    feedQuantity: newFeedQuantity
                }
            });
        });

        logger.info(`Updated milk record ${id} for Gaushala ${gaushalaId}`);

        res.status(200).json({
            success: true,
            message: 'Milk record updated and inventory adjusted'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a milk yield entry.
 * Reverses feed inventory deduction.
 */
export const deleteYield = async (req: any, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.headers['gaushala-id'] as string;

        const existing = await prisma.milkRecord.findFirst({
            where: { id, gaushalaId }
        });

        if (!existing) {
            throw new AppError('Milk record not found', 404, 'RECORD_NOT_FOUND');
        }

        await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // 1. Delete Record
            await tx.milkRecord.delete({ where: { id } });

            // 2. Reverse Inventory (Add back consumed feed)
            if (existing.feedQuantity && existing.feedQuantity > 0) {
                const feedToReverse = existing.feedQuantity as number;
                await tx.feedInventory.update({
                    where: { gaushalaId },
                    data: {
                        totalQuantity: {
                            increment: feedToReverse
                        }
                    }
                });
            }
        });

        logger.info(`Deleted milk record ${id} for Gaushala ${gaushalaId}`);

        res.status(200).json({
            success: true,
            message: 'Milk record deleted and inventory reversed'
        });
    } catch (error) {
        next(error);
    }
};
