import { Response, NextFunction } from 'express';
import prisma from '@config/db.js';
import logger from '@utils/logger.js';
import { AppError } from '@utils/AppError.js';
import { getPresignedUploadUrl, getPresignedViewUrl } from '@utils/s3.js';

// ───────────────────────── Register Animal ─────────────────────────
export const registerAnimal = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;

        const {
            name, tagNumber, animalNumber, species, gender,
            cowBreed, buffaloBreed, cowGroup, birthDate, adultDate,
            isPregnant, lactationNumber, isLactating, isDryOff, isHeifer, isRetired,
            bullView, motherMilk, grandmotherMilk, isHandicapped, handicapReason,
            acquisitionType, purchaseDate, purchasedFrom, purchasePrice, ownerName, ownerMobile,
            photoUrl,
            isUdderClosedFL, isUdderClosedFR, isUdderClosedBL, isUdderClosedBR,
            motherName, fatherName, motherId, fatherId
        } = req.body;

        // Duplicate tag check within same gaushala
        if (tagNumber) {
            const existing = await prisma.animal.findUnique({
                where: { tagNumber_gaushalaId: { tagNumber, gaushalaId } }
            });
            if (existing) {
                throw new AppError('Tag number already exists in this Gaushala', 409, 'DUPLICATE_TAG');
            }
        }

        const animal = await prisma.animal.create({
            data: {
                name,
                tagNumber,
                animalNumber,
                species,
                gender,
                gaushalaId,
                cowBreed: cowBreed || null,
                buffaloBreed: buffaloBreed || null,
                cowGroup: cowGroup || null,
                birthDate: birthDate ? new Date(birthDate) : null,
                adultDate: adultDate ? new Date(adultDate) : null,
                isPregnant: isPregnant ?? false,
                lactationNumber: lactationNumber ?? null,
                isLactating: isLactating ?? false,
                isDryOff: isDryOff ?? false,
                isHeifer: isHeifer ?? false,
                isRetired: isRetired ?? false,
                bullView: bullView || null,
                motherMilk: motherMilk ?? null,
                grandmotherMilk: grandmotherMilk ?? null,
                isHandicapped: isHandicapped ?? false,
                handicapReason: handicapReason || null,
                acquisitionType,
                purchaseDate: purchaseDate ? new Date(purchaseDate) : null,
                purchasedFrom: purchasedFrom || null,
                purchasePrice: purchasePrice ?? null,
                ownerName: ownerName || null,
                ownerMobile: ownerMobile || null,
                photoUrl: photoUrl || null,
                isUdderClosedFL: isUdderClosedFL ?? false,
                isUdderClosedFR: isUdderClosedFR ?? false,
                isUdderClosedBL: isUdderClosedBL ?? false,
                isUdderClosedBR: isUdderClosedBR ?? false,
                motherName: motherName || null,
                fatherName: fatherName || null,
                motherId: motherId || null,
                fatherId: fatherId || null,
                status: 'ACTIVE'
            }
        });

        logger.info(`Animal registered: ${animal.id} in Gaushala ${gaushalaId}`);
        res.status(201).json({
            success: true,
            message: 'Animal registered successfully',
            animal
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Animals (Paginated) ─────────────────────────
export const getAnimals = async (req: any, res: Response, next: NextFunction) => {
    try {
        const gaushalaId = req.headers['gaushala-id'] as string;
        const { species, status, gender, search, page = '1', limit = '20' } = req.query;

        const pageNum = Math.max(1, parseInt(page as string) || 1);
        const limitNum = Math.min(100, Math.max(1, parseInt(limit as string) || 20));
        const skip = (pageNum - 1) * limitNum;

        const where: any = { gaushalaId };
        if (species) where.species = species;
        if (status) where.status = status;
        if (gender) where.gender = gender;
        if (search) {
            where.OR = [
                { name: { contains: search as string, mode: 'insensitive' } },
                { tagNumber: { contains: search as string, mode: 'insensitive' } }
            ];
        }

        const [animalsList, total] = await Promise.all([
            prisma.animal.findMany({
                where,
                skip,
                take: limitNum,
                orderBy: { createdAt: 'desc' }
            }),
            prisma.animal.count({ where })
        ]);

        // Enrich with security-signed view URLs
        const bucket = process.env.S3_BUCKET_CATTLE_PHOTOS || 'cattle-photos';
        const animals = await Promise.all(animalsList.map(async (animal) => {
            if (animal.photoUrl) {
                try {
                    return {
                        ...animal,
                        viewUrl: await getPresignedViewUrl(bucket, animal.photoUrl)
                    };
                } catch (err) {
                    logger.error(`Error generating view URL for animal ${animal.id}:`, err);
                    return animal;
                }
            }
            return animal;
        }));

        res.status(200).json({
            success: true,
            animals,
            pagination: {
                page: pageNum,
                limit: limitNum,
                total,
                totalPages: Math.ceil(total / limitNum)
            }
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Get Animal By ID ─────────────────────────
export const getAnimalById = async (req: any, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.headers['gaushala-id'] as string;

        const animal = await prisma.animal.findFirst({
            where: { id, gaushalaId },
            include: {
                sellRecord: true,
                deathRecord: true,
                donationRecord: true
            }
        });

        if (!animal) {
            throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
        }

        // Enrich with security-signed view URL
        let viewUrl = null;
        if (animal.photoUrl) {
            try {
                const bucket = process.env.S3_BUCKET_CATTLE_PHOTOS || 'cattle-photos';
                viewUrl = await getPresignedViewUrl(bucket, animal.photoUrl);
            } catch (err) {
                logger.error(`Error generating view URL for animal ${id}:`, err);
            }
        }

        res.status(200).json({
            success: true,
            animal: { ...animal, viewUrl }
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Update Animal ─────────────────────────
export const updateAnimal = async (req: any, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const gaushalaId = req.headers['gaushala-id'] as string;

        // Verify animal exists and belongs to this gaushala
        const existingAnimal = await prisma.animal.findFirst({
            where: { id, gaushalaId }
        });

        if (!existingAnimal) {
            throw new AppError('Animal not found in this Gaushala', 404, 'ANIMAL_NOT_FOUND');
        }

        const {
            name, tagNumber, animalNumber,
            cowGroup, birthDate, adultDate,
            isPregnant, lactationNumber, isLactating, isDryOff, isHeifer, isRetired,
            bullView, motherMilk, grandmotherMilk,
            isHandicapped, handicapReason,
            photoUrl,
            isUdderClosedFL, isUdderClosedFR, isUdderClosedBL, isUdderClosedBR,
            motherName, fatherName, motherId, fatherId
        } = req.body;

        // Duplicate tag check — only if tagNumber is changing
        if (tagNumber !== undefined && tagNumber !== existingAnimal.tagNumber) {
            const duplicate = await prisma.animal.findUnique({
                where: { tagNumber_gaushalaId: { tagNumber, gaushalaId } }
            });
            if (duplicate) {
                throw new AppError('Tag number already exists in this Gaushala', 409, 'DUPLICATE_TAG');
            }
        }

        // Build update object — only include fields that were actually sent
        const updateData: Record<string, any> = {};
        if (name !== undefined) updateData.name = name;
        if (tagNumber !== undefined) updateData.tagNumber = tagNumber;
        if (animalNumber !== undefined) updateData.animalNumber = animalNumber;
        if (cowGroup !== undefined) updateData.cowGroup = cowGroup;
        if (birthDate !== undefined) updateData.birthDate = birthDate ? new Date(birthDate) : null;
        if (adultDate !== undefined) updateData.adultDate = adultDate ? new Date(adultDate) : null;
        if (isPregnant !== undefined) updateData.isPregnant = isPregnant;
        if (lactationNumber !== undefined) updateData.lactationNumber = lactationNumber;
        if (isLactating !== undefined) updateData.isLactating = isLactating;
        if (isDryOff !== undefined) updateData.isDryOff = isDryOff;
        if (isHeifer !== undefined) updateData.isHeifer = isHeifer;
        if (isRetired !== undefined) updateData.isRetired = isRetired;
        if (bullView !== undefined) updateData.bullView = bullView;
        if (motherMilk !== undefined) updateData.motherMilk = motherMilk;
        if (grandmotherMilk !== undefined) updateData.grandmotherMilk = grandmotherMilk;
        if (isHandicapped !== undefined) updateData.isHandicapped = isHandicapped;
        if (handicapReason !== undefined) updateData.handicapReason = handicapReason;
        if (photoUrl !== undefined) updateData.photoUrl = photoUrl;
        if (isUdderClosedFL !== undefined) updateData.isUdderClosedFL = isUdderClosedFL;
        if (isUdderClosedFR !== undefined) updateData.isUdderClosedFR = isUdderClosedFR;
        if (isUdderClosedBL !== undefined) updateData.isUdderClosedBL = isUdderClosedBL;
        if (isUdderClosedBR !== undefined) updateData.isUdderClosedBR = isUdderClosedBR;
        if (motherName !== undefined) updateData.motherName = motherName;
        if (fatherName !== undefined) updateData.fatherName = fatherName;
        if (motherId !== undefined) updateData.motherId = motherId;
        if (fatherId !== undefined) updateData.fatherId = fatherId;

        if (Object.keys(updateData).length === 0) {
            throw new AppError('No valid fields provided for update', 400, 'NO_UPDATE_FIELDS');
        }

        const animal = await prisma.animal.update({
            where: { id },
            data: updateData
        });

        logger.info(`Animal updated: ${id} in Gaushala ${gaushalaId}`);
        res.status(200).json({
            success: true,
            message: 'Animal updated successfully',
            animal
        });
    } catch (error) {
        next(error);
    }
};

// ───────────────────────── Generate Pre-signed Upload URL ─────────────────────────
export const generateUploadUrl = async (req: any, res: Response, next: NextFunction) => {
    try {
        const { fileName, contentType, type } = req.query;

        if (!fileName || !contentType) {
            throw new AppError('fileName and contentType query params are required', 400, 'MISSING_PARAMS');
        }

        const bucketMap: Record<string, string | undefined> = {
            PHOTO: process.env.S3_BUCKET_CATTLE_PHOTOS,
            DISPOSAL: process.env.S3_BUCKET_DISPOSAL_MEDIA,
            DOC: process.env.S3_BUCKET_CATTLE_DOCS
        };

        const bucket = bucketMap[(type as string) || 'PHOTO'];
        if (!bucket) {
            throw new AppError('Invalid upload type. Use PHOTO, DISPOSAL, or DOC', 400, 'INVALID_UPLOAD_TYPE');
        }

        const result = await getPresignedUploadUrl(bucket, fileName as string, contentType as string);
        res.status(200).json({
            success: true,
            ...result
        });
    } catch (error) {
        next(error);
    }
};
