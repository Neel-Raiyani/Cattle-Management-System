/**
 * @swagger
 * tags:
 *   - name: Breeding Service
 *     description: Heat records, conception journeys, delivery, and lineage (Breeding-service via Gateway)
 *
 * components:
 *   schemas:
 *     HeatRecord:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         date:
 *           type: string
 *           format: date-time
 *         breedingType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         note:
 *           type: string
 *
 *     DryOffRecord:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         date:
 *           type: string
 *           format: date-time
 *         reason:
 *           type: string
 *           enum: [ILLNESS, LOW_YIELD, MEDICATED, OTHER]
 *         remarks:
 *           type: string
 *
 *     ConceptionJourney:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         status:
 *           type: string
 *           enum: [INITIATED, PREGNANT, DRY_OFF, COMPLETED, FAILED]
 *         parity:
 *           type: integer
 *         conceiveDate:
 *           type: string
 *           format: date-time
 *         pregnancyType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         bullId:
 *           type: string
 *         bullName:
 *           type: string
 *         bullTag:
 *           type: string
 *         pdDate:
 *           type: string
 *           format: date-time
 *         dryOffDate:
 *           type: string
 *           format: date-time
 *         deliveryDate:
 *           type: string
 *           format: date-time
 *
 *     ParityRecord:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         parityNo:
 *           type: integer
 *         pregnancyType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         bullName:
 *           type: string
 *         deliveryDate:
 *           type: string
 *           format: date-time
 *         pregnancyDate:
 *           type: string
 *           format: date-time
 *         note:
 *           type: string
 */

/**
 * @swagger
 * /api/breeding/media/presigned-url:
 *   get:
 *     summary: Get presigned URL for breeding media
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: fileName
 *         required: true
 *       - in: query
 *         name: fileType
 *         required: true
 *     responses:
 *       200:
 *         description: Presigned URL generated
 */

/**
 * @swagger
 * /api/breeding/heat:
 *   post:
 *     summary: Record a heat event
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/HeatRecord'
 *     responses:
 *       201:
 *         description: Heat record created
 *   get:
 *     summary: Get heat records with filters
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: animalId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of heat records
 */

/**
 * @swagger
 * /api/breeding/heat/eligible:
 *   get:
 *     summary: Get animals eligible for heat (Lactating cows & heifers)
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of eligible animals
 */

/**
 * @swagger
 * /api/breeding/dry-off:
 *   post:
 *     summary: Record a manual dry-off event (Non-journey)
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DryOffRecord'
 *     responses:
 *       201:
 *         description: Dry-off record created
 *   get:
 *     summary: Get all dry-off records
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of records
 */

/**
 * @swagger
 * /api/breeding/dry-off/eligible:
 *   get:
 *     summary: Get animals eligible for dry-off dropdown
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of eligible animals
 */

/**
 * @swagger
 * /api/breeding/bulls/eligible:
 *   get:
 *     summary: Get bulls eligible for breeding dropdown (Adult & Not Retired)
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of adult bulls
 */

/**
 * @swagger
 * /api/breeding/journey/initiate:
 *   post:
 *     summary: Initiate a conception journey
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ConceptionJourney'
 *     responses:
 *       201:
 *         description: Journey initiated
 */

/**
 * @swagger
 * /api/breeding/journey/list:
 *   get:
 *     summary: List all conception journeys
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of journeys
 */

/**
 * @swagger
 * /api/breeding/journey/eligible-dry-off:
 *   get:
 *     summary: Get pregnant animals eligible for dry-off marking
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of animals
 */

/**
 * @swagger
 * /api/breeding/journey/{id}:
 *   get:
 *     summary: Get full details of a specific journey
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     responses:
 *       200:
 *         description: Journey details
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/confirm:
 *   patch:
 *     summary: Confirm pregnancy (PD Result)
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               pdResult:
 *                 type: boolean
 *               pdDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: Pregnancy status updated
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/dry-off:
 *   patch:
 *     summary: Mark dry-off in conception journey
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               dryOffDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: Journey status updated to DRY_OFF
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/deliver:
 *   patch:
 *     summary: Record delivery (Atomic operation creating calf and updating parity)
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               deliveryDate:
 *                 type: string
 *                 format: date-time
 *               calfStatus:
 *                 type: string
 *                 enum: [ALIVE, DEAD, ABORTED]
 *               calfGender:
 *                 type: string
 *                 enum: [MALE, FEMALE]
 *               calfName:
 *                 type: string
 *               calfTag:
 *                 type: string
 *     responses:
 *       200:
 *         description: Delivery recorded successfully
 */

/**
 * @swagger
 * /api/breeding/parity/{animalId}:
 *   get:
 *     summary: Get parity history for a cow
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: Parity history retrieved
 */

/**
 * @swagger
 * /api/breeding/lineage/{id}:
 *   get:
 *     summary: Get children of an animal (Lineage)
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: Parent animal ID
 *     responses:
 *       200:
 *         description: List of offspring
 */
