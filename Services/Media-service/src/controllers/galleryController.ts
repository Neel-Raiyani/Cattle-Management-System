import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import type { AuthRequest } from '../types/express.js';
import { AppError } from '@utils/AppError.js';
import { getPresignedUploadUrl, getPresignedViewUrl, deleteS3Object } from '@utils/s3.js';

/**
 * Get a presigned URL for uploading media.
 */
export const getUploadUrl = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const { fileName, fileType } = req.query;

        if (!fileName || !fileType) {
            throw new AppError('fileName and fileType (mimeType) are required', 400);
        }

        const { url, key } = await getPresignedUploadUrl(fileName as string, fileType as string);

        res.status(200).json({
            success: true,
            data: { uploadUrl: url, key }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Register an uploaded media item in the database.
 */
export const registerMediaItem = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { folderId, fileName, originalName, mimeType, size } = req.body;
        if (!folderId || !fileName || !originalName || !mimeType || !size) {
            throw new AppError('folderId, fileName, originalName, mimeType, and size are required', 400);
        }

        // Verify folder exists and belongs to gaushala
        const folder = await (prisma as any).folder.findFirst({
            where: { id: folderId, gaushalaId }
        });

        if (!folder) throw new AppError('Target folder not found', 404, 'FOLDER_NOT_FOUND');

        const item = await (prisma as any).galleryItem.create({
            data: {
                folderId,
                gaushalaId,
                fileName,
                originalName,
                mimeType,
                size: parseInt(size)
            }
        });

        res.status(201).json({
            success: true,
            message: 'Media item registered successfully',
            data: item
        });
    } catch (error) {
        next(error);
    }
};

/**
 * List items in a folder with temporary view URLs.
 */
export const getFolderItems = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { folderId } = req.params;

        const folder = await (prisma as any).folder.findFirst({
            where: { id: folderId, gaushalaId }
        });

        if (!folder) throw new AppError('Folder not found', 404, 'FOLDER_NOT_FOUND');

        const items = await (prisma as any).galleryItem.findMany({
            where: { folderId },
            orderBy: { createdAt: 'desc' }
        });

        const data = await Promise.all(items.map(async (item: any) => ({
            ...item,
            viewUrl: await getPresignedViewUrl(item.fileName)
        })));

        res.status(200).json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a media item.
 */
export const deleteMediaItem = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { id } = req.params;

        const item = await (prisma as any).galleryItem.findFirst({
            where: { id, gaushalaId }
        });

        if (!item) throw new AppError('Media item not found', 404, 'ITEM_NOT_FOUND');

        // Delete from S3
        await deleteS3Object(item.fileName);

        // Delete from DB
        await (prisma as any).galleryItem.delete({
            where: { id }
        });

        res.status(200).json({
            success: true,
            message: 'Media item deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};
