import cron from 'node-cron';
import prisma from '@config/db.js';
import logger from './logger.js';
import { sendPushNotification } from './notification.js';

// Logic constants shared with alertController
const PD_CHECK_DAYS = 60;
const ADULT_LOWER_MONTHS = 12;
const ADULT_UPPER_MONTHS = 15;

const monthsAgo = (months: number): Date => {
    const d = new Date();
    d.setMonth(d.getMonth() - months);
    d.setHours(0, 0, 0, 0);
    return d;
};

const daysAgo = (days: number): Date => {
    const d = new Date();
    d.setDate(d.getDate() - days);
    d.setHours(0, 0, 0, 0);
    return d;
};

/**
 * Main routine to scan all gaushalas and send summarized alerts to owners/managers.
 */
export const runDailyAlertCheck = async () => {
    logger.info('[cron]: Starting daily alert notification scan');
    
    try {
        const gaushalas = await prisma.gaushala.findMany({
            include: {
                members: {
                    where: { role: { in: ['OWNER', 'MANAGER'] }, isActive: true },
                    include: { user: { select: { fcmToken: true } } }
                }
            }
        });

        for (const gaushala of gaushalas) {
            // Only notify OWNERS as requested
            const recipientTokens = gaushala.members
                .filter((m: any) => m.role === 'OWNER')
                .map((m: any) => m.user.fcmToken)
                .filter((token: string | null): token is string => !!token);

            if (recipientTokens.length === 0) continue;

            const gaushalaId = gaushala.id;

            // 1. Ear Tag Alerts
            const pendingTags = await prisma.animal.count({
                where: { gaushalaId, status: 'ACTIVE', isActive: true, OR: [{ tagNumber: null }, { tagNumber: '' }] }
            });

            if (pendingTags > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Ear Tag Alert", `${pendingTags} cows are pending for ear tagging. Please complete tagging.`);
                }
            }

            // 2. Adult Alerts (First Pregnancy)
            const adultAlerts = await prisma.animal.count({
                where: {
                    gaushalaId,
                    status: 'ACTIVE',
                    isActive: true,
                    gender: 'FEMALE',
                    birthDate: { lte: monthsAgo(ADULT_LOWER_MONTHS), gte: monthsAgo(ADULT_UPPER_MONTHS) }
                }
            });

            if (adultAlerts > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Adult (First Pregnancy) Alert", `${adultAlerts} cows have become adult. Plan for first pregnancy.`);
                }
            }

            // 3. Pregnancy Check (PD Due)
            const pdDue = await prisma.conceptionJourney.count({
                where: {
                    gaushalaId,
                    status: 'INITIATED',
                    pdDate: null,
                    conceiveDate: { lte: daysAgo(PD_CHECK_DAYS) }
                }
            });

            if (pdDue > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Pregnancy Check", `${pdDue} cow(s) need to be checked for pregnancy.`);
                }
            }

            // 4. Heat Alert
            const HEAT_CYCLE_DAYS = 21;
            const heatThreshold = daysAgo(HEAT_CYCLE_DAYS);
            const eligibleForHeat = await prisma.animal.findMany({
                where: { gaushalaId, gender: 'FEMALE', status: 'ACTIVE', isActive: true, isPregnant: false, isRetired: false, isHeifer: true },
                select: { id: true }
            });

            if (eligibleForHeat.length > 0) {
                const cowIds = eligibleForHeat.map(c => c.id);
                // Simple logic: cows with no heat record ever or last heat > 21 days ago
                const recentHeatRecords = await prisma.heatRecord.findMany({
                    where: { animalId: { in: cowIds }, date: { gte: heatThreshold } },
                    select: { animalId: true }
                });
                const cowIdsWithRecentHeat = new Set(recentHeatRecords.map(r => r.animalId));
                const inHeatCount = cowIds.filter(id => !cowIdsWithRecentHeat.has(id)).length;

                if (inHeatCount > 0) {
                    for (const token of recipientTokens) {
                        await sendPushNotification(token, "Heat Alert", `${inHeatCount} cows are in heat. Plan for pregnancy.`);
                    }
                }
            }

            // 5. Missing Parity Info Alert
            // Defined as adult cows (gender FEMALE, age > 12mo) where parity is null or 0 but they are not heifers
            const missingParity = await prisma.animal.count({
                where: {
                    gaushalaId,
                    gender: 'FEMALE',
                    status: 'ACTIVE',
                    isActive: true,
                    isHeifer: false, // Not a heifer anymore, so parity should be > 0
                    OR: [
                        { parity: null },
                        { parity: 0 }
                    ]
                }
            });

            if (missingParity > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Missing Parity Info Alert", `${missingParity} cows have no parity info entered. Please update records.`);
                }
            }
            
            // 6. Insemination Alert
            const INSEMINATION_WAIT_DAYS = 60;
            const deliveryWaitThreshold = daysAgo(INSEMINATION_WAIT_DAYS);
            const eligibleForInsemination = await prisma.animal.findMany({
                where: { gaushalaId, gender: 'FEMALE', status: 'ACTIVE', isActive: true, isHeifer: true, isPregnant: false, isRetired: false, isDryOff: false },
                select: { id: true, parity: true }
            });

            if (eligibleForInsemination.length > 0) {
                const cowIds = eligibleForInsemination.map(c => c.id);
                // Exclude cows with active conception journeys
                const activeJourneys = await prisma.conceptionJourney.findMany({
                    where: { gaushalaId, animalId: { in: cowIds }, status: { notIn: ['COMPLETED', 'FAILED'] } },
                    select: { animalId: true }
                });
                const toExclude = new Set(activeJourneys.map(j => j.animalId));

                // Check post-delivery wait
                const completedJourneys = await prisma.conceptionJourney.findMany({
                    where: { gaushalaId, animalId: { in: cowIds }, status: 'COMPLETED', deliveryDate: { gt: deliveryWaitThreshold } },
                    select: { animalId: true }
                });
                completedJourneys.forEach(j => toExclude.add(j.animalId));

                const inseminationCount = cowIds.filter(id => !toExclude.has(id)).length;
                if (inseminationCount > 0) {
                    for (const token of recipientTokens) {
                        await sendPushNotification(token, "Insemination Alert", `${inseminationCount} cows are eligible for insemination.`);
                    }
                }
            }

            // 7. Delivery Alert
            const DELIVERY_ALERT_DAYS = 250;
            const deliveryDueCount = await prisma.conceptionJourney.count({
                where: {
                    gaushalaId,
                    status: { in: ['INITIATED', 'PREGNANT', 'DRY_OFF'] },
                    deliveryDate: null,
                    conceiveDate: { lte: daysAgo(DELIVERY_ALERT_DAYS) }
                }
            });

            if (deliveryDueCount > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Delivery Alert", `${deliveryDueCount} cow(s) are nearing their expected delivery date.`);
                }
            }

            // 8. Deworming Alert
            const DEWORMING_ALERT_DAYS = 7;
            const d = new Date();
            d.setDate(d.getDate() + DEWORMING_ALERT_DAYS);
            const dewormingDueCount = await prisma.dewormingRecord.count({
                where: { gaushalaId, nextDoseDate: { lte: d } }
            });

            if (dewormingDueCount > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Deworming Alert", `${dewormingDueCount} animal(s) are due for deworming.`);
                }
            }

            // 9. Lab Test Alert
            const pendingLabs = await prisma.labRecord.count({
                where: { gaushalaId, result: null }
            });

            if (pendingLabs > 0) {
                for (const token of recipientTokens) {
                    await sendPushNotification(token, "Lab Test Alert", `${pendingLabs} lab test results are pending.`);
                }
            }
        }

        logger.info('[cron]: Daily alert notification scan completed');
    } catch (error) {
        logger.error('[cron]: Error in daily alert check:', error);
    }
};

// Schedule: 9:00 AM every day
export const setupAlertCron = () => {
    cron.schedule('0 9 * * *', runDailyAlertCheck);
    logger.info('[cron]: Alert notification job scheduled (09:00 AM daily)');
};
