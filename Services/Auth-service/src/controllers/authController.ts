import { Request, Response, NextFunction } from 'express';
import { hashPassword, comparePassword } from '@utils/password.js';
import { generateToken } from '@utils/jwt.js';
import { sendSMS } from '@utils/sms.js';
import { PrismaClient } from '@prisma/client';
import logger from '@utils/logger.js';

const prisma = new PrismaClient();

export const register = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { mobileNumber, password, name, city, gaushalaName, totalCattle, role } = req.body;

        const existingUser = await prisma.user.findUnique({ where: { mobileNumber } });
        if (existingUser) {
            return res.status(400).json({ message: 'User with this mobile number already exists' });
        }

        const hashedPassword = await hashPassword(password);
        const user = await prisma.user.create({
            data: {
                mobileNumber,
                password: hashedPassword,
                name,
                city,
                gaushalaName,
                totalCattle: parseInt(totalCattle) || 0,
                role: role || 'OWNER'
            }
        });

        logger.info(`User registered successfully: ${mobileNumber}`);
        res.status(201).json({ message: 'User registered successfully', userId: user.id });
    } catch (error) {
        next(error);
    }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { mobileNumber, password } = req.body;

        const user = await prisma.user.findUnique({ where: { mobileNumber } });
        if (!user || !user.isActive) {
            return res.status(401).json({ message: 'Invalid credentials or account inactive' });
        }

        const isMatch = await comparePassword(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = generateToken({
            userId: user.id,
            role: user.role,
            mobileNumber: user.mobileNumber,
            name: user.name
        });

        logger.info(`User logged in: ${mobileNumber}`);
        res.status(200).json({ message: 'Login successful', token });
    } catch (error) {
        next(error);
    }
};

export const getProfile = async (req: any, res: Response, next: NextFunction) => {
    try {
        const userId = req.user.userId;
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                mobileNumber: true,
                city: true,
                gaushalaName: true,
                totalCattle: true,
                role: true,
                languagePreference: true,
                unitPreference: true,
                isActive: true,
                createdAt: true
            }
        });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json(user);
    } catch (error) {
        next(error);
    }
};

export const sendOtp = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { mobileNumber } = req.body;
        const user = await prisma.user.findUnique({ where: { mobileNumber } });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Generate 4-digit OTP (Mocked for now)
        const otp = Math.floor(1000 + Math.random() * 9000).toString();
        const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

        await prisma.user.update({
            where: { mobileNumber },
            data: { otp, otpExpires }
        });

        const message = `Your Smart Gaushala verification code is: ${otp}. Valid for 10 minutes.`;
        const smsSent = await sendSMS(mobileNumber, message);

        if (!smsSent) {
            return res.status(500).json({ message: 'Failed to send SMS' });
        }

        logger.info(`OTP generated and sent to ${mobileNumber}`);
        res.status(200).json({ message: 'OTP sent successfully' });
    } catch (error) {
        next(error);
    }
};

export const verifyOtp = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { mobileNumber, otp, newPassword } = req.body;
        const user = await prisma.user.findUnique({ where: { mobileNumber } });

        if (!user || user.otp !== otp || !user.otpExpires || user.otpExpires < new Date()) {
            return res.status(400).json({ message: 'Invalid or expired OTP' });
        }

        const hashedPassword = await hashPassword(newPassword);
        await prisma.user.update({
            where: { mobileNumber },
            data: {
                password: hashedPassword,
                otp: null,
                otpExpires: null
            }
        });

        logger.info(`Password reset successfully for ${mobileNumber}`);
        res.status(200).json({ message: 'Password reset successfully' });
    } catch (error) {
        next(error);
    }
};

export const updateSettings = async (req: any, res: Response, next: NextFunction) => {
    try {
        const userId = req.user.userId;
        const { languagePreference, unitPreference } = req.body;

        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: {
                ...(languagePreference && { languagePreference }),
                ...(unitPreference && { unitPreference })
            },
            select: { languagePreference: true, unitPreference: true }
        });

        logger.info(`Settings updated for user ${userId}`);
        res.status(200).json({ message: 'Settings updated successfully', settings: updatedUser });
    } catch (error) {
        next(error);
    }
};

export const changePassword = async (req: any, res: Response, next: NextFunction) => {
    try {
        const userId = req.user.userId;
        const { oldPassword, newPassword } = req.body;

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const isMatch = await comparePassword(oldPassword, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Incorrect old password' });
        }

        const hashedPassword = await hashPassword(newPassword);
        await prisma.user.update({
            where: { id: userId },
            data: { password: hashedPassword }
        });

        logger.info(`Password changed successfully for user ${userId}`);
        res.status(200).json({ message: 'Password changed successfully' });
    } catch (error) {
        next(error);
    }
};
