/**
 * @swagger
 * tags:
 *   - name: Alert Service
 *     description: System-driven reminders for animal management.
 */

/**
 * @swagger
 * /api/alert/ear-tag:
 *   get:
 *     summary: Ear Tag alerts
 *     description: Active animals missing a tag number.
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of animals without ear tags.
 */

/**
 * @swagger
 * /api/alert/heat:
 *   get:
 *     summary: Heat alerts
 *     description: Adult cows not observed in heat for 21+ days.
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of cows due for heat observation.
 */

/**
 * @swagger
 * /api/alert/pregnancy-check:
 *   get:
 *     summary: Pregnancy checking alerts
 *     description: Conception journeys past 60 days without a PD check.
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of journeys needing pregnancy diagnosis.
 */

/**
 * @swagger
 * /api/alert/insemination:
 *   get:
 *     summary: Insemination alerts
 *     description: Adult cows ready for breeding (not pregnant, not dried off, no active journey, 60+ days post-delivery).
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of cows eligible for insemination.
 */

/**
 * @swagger
 * /api/alert/delivery:
 *   get:
 *     summary: Delivery alerts
 *     description: Conception journeys approaching 280-day gestation (alerts from day 250).
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of journeys with expected delivery dates.
 */

/**
 * @swagger
 * /api/alert/deworming:
 *   get:
 *     summary: Deworming alerts
 *     description: Animals with nextDoseDate within 7 days or overdue.
 *     tags: [Alert Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of animals due for deworming.
 */

export { };
