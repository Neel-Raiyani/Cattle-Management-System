import twilio from 'twilio';
import logger from './logger.js';

let client: any = null;

/**
 * Sends an SMS message using Twilio.
 * In development, if MOCK_SMS is true, it logs to console instead.
 */
export const sendSMS = async (to: string, message: string): Promise<boolean> => {
    if (process.env.MOCK_SMS === 'true') {
        logger.info(`[MOCK SMS] To: ${to} | Message: ${message}`);
        return true;
    }

    try {
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const fromNumber = process.env.TWILIO_PHONE_NUMBER;

        if (!accountSid || !authToken || !fromNumber) {
            throw new Error('Twilio credentials missing in environment variables');
        }

        if (!client) {
            client = twilio(accountSid, authToken);
        }

        const response = await client.messages.create({
            body: message,
            to: to.startsWith('+') ? to : `+91${to}`, // Default to India prefix if missing
            from: fromNumber
        });

        logger.info(`SMS sent successfully to ${to}. SID: ${response.sid}`);
        return true;
    } catch (error: any) {
        logger.error(`Failed to send SMS to ${to}: ${error.message}`);
        return false;
    }
};
