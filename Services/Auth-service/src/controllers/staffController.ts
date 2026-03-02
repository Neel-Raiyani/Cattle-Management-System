import { Response, NextFunction } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';
import logger from '@utils/logger.js';

const prisma = new PrismaClient();

// ───────────────────────── Add Staff ─────────────────────────
export const addStaff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { name, mobileNumber, role, city } = req.body;

        // Explicitly block OWNER role assignment
        if (role === 'OWNER') {
            return res.status(403).json({
                success: false,
                errorCode: 'OWNER_ASSIGNMENT_RESTRICTED',
                message: 'The OWNER role can only be assigned during registration or gaushala creation.'
            });
        }

        // Check if mobile already exists as a user
        let user = await prisma.user.findUnique({
            where: { mobileNumber }
        });

        if (user) {
            // Check if already a member of this gaushala
            const existingMembership = await prisma.userGaushala.findUnique({
                where: {
                    userId_gaushalaId: { userId: user.id, gaushalaId }
                }
            });

            if (existingMembership) {
                return res.status(409).json({
                    success: false,
                    errorCode: 'DUPLICATE_MEMBER',
                    message: 'This user is already a member of this Gaushala'
                });
            }
        }

        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            // Create user if not exists (no password — Phase 1)
            if (!user) {
                user = await tx.user.create({
                    data: {
                        name,
                        mobileNumber,
                        city: city || null,
                        password: null   // No credentials in Phase 1
                    }
                });
            }

            // Link user to gaushala with the specified role
            const membership = await tx.userGaushala.create({
                data: {
                    userId: user.id,
                    gaushalaId,
                    role
                }
            });

            return { user, membership };
        });

        logger.info(`Staff added: ${result.user.id} as ${role} to Gaushala ${gaushalaId}`);
        res.status(201).json({
            success: true,
            message: 'Staff member added successfully',
            staff: {
                id: result.user.id,
                name: result.user.name,
                mobileNumber: result.user.mobileNumber,
                city: result.user.city,
                role: result.membership.role,
                gaushalaId: result.membership.gaushalaId
            }
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Staff List ─────────────────────────
export const getStaffList = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { role } = req.query;

        const where: any = { gaushalaId, isActive: true };
        if (role) where.role = role;

        const members = await prisma.userGaushala.findMany({
            where,
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        mobileNumber: true,
                        city: true
                    }
                }
            },
            orderBy: { joinedAt: 'desc' }
        });

        const staff = members.map((m: any) => ({
            id: m.user.id,
            name: m.user.name,
            mobileNumber: m.user.mobileNumber,
            city: m.user.city,
            role: m.role,
            joinedAt: m.joinedAt
        }));

        res.status(200).json({
            success: true,
            staff,
            total: staff.length
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Staff ─────────────────────────
export const updateStaff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { userId } = req.params;
        const { name, city, role } = req.body;

        // Explicitly block OWNER role assignment
        if (role === 'OWNER') {
            return res.status(403).json({
                success: false,
                errorCode: 'OWNER_ASSIGNMENT_RESTRICTED',
                message: 'The OWNER role cannot be manually assigned.'
            });
        }

        // Check membership exists
        const membership = await prisma.userGaushala.findUnique({
            where: {
                userId_gaushalaId: { userId, gaushalaId }
            }
        });

        if (!membership) {
            return res.status(404).json({
                success: false,
                errorCode: 'MEMBER_NOT_FOUND',
                message: 'Staff member not found in this Gaushala'
            });
        }

        // Prevent changing the OWNER role
        if (membership.role === 'OWNER') {
            return res.status(403).json({
                success: false,
                errorCode: 'CANNOT_MODIFY_OWNER',
                message: 'Cannot modify the owner of this Gaushala'
            });
        }

        // Update user details and role in a transaction
        const result = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
            const updateData: Record<string, any> = {};
            if (name !== undefined) updateData.name = name;
            if (city !== undefined) updateData.city = city;

            let updatedUser;
            if (Object.keys(updateData).length > 0) {
                updatedUser = await tx.user.update({
                    where: { id: userId },
                    data: updateData
                });
            }

            let updatedMembership;
            if (role !== undefined) {
                updatedMembership = await tx.userGaushala.update({
                    where: { userId_gaushalaId: { userId, gaushalaId } },
                    data: { role }
                });
            }

            return {
                user: updatedUser || await tx.user.findUnique({ where: { id: userId } }),
                membership: updatedMembership || membership
            };
        });

        logger.info(`Staff updated: ${userId} in Gaushala ${gaushalaId}`);
        res.status(200).json({
            success: true,
            message: 'Staff member updated successfully',
            staff: {
                id: result.user!.id,
                name: result.user!.name,
                mobileNumber: result.user!.mobileNumber,
                city: result.user!.city,
                role: result.membership.role
            }
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Remove Staff ─────────────────────────
export const removeStaff = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { userId } = req.params;

        const membership = await prisma.userGaushala.findUnique({
            where: {
                userId_gaushalaId: { userId, gaushalaId }
            }
        });

        if (!membership) {
            return res.status(404).json({
                success: false,
                errorCode: 'MEMBER_NOT_FOUND',
                message: 'Staff member not found in this Gaushala'
            });
        }

        if (membership.role === 'OWNER') {
            return res.status(403).json({
                success: false,
                errorCode: 'CANNOT_REMOVE_OWNER',
                message: 'Cannot remove the owner of this Gaushala'
            });
        }

        // Soft-delete: set isActive = false
        await prisma.userGaushala.update({
            where: { userId_gaushalaId: { userId, gaushalaId } },
            data: { isActive: false }
        });

        logger.info(`Staff removed: ${userId} from Gaushala ${gaushalaId}`);
        res.status(200).json({
            success: true,
            message: 'Staff member removed successfully'
        });
    } catch (error) {
        next(error);
    }
};
