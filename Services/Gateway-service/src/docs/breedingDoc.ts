/**
 * @swagger
 * tags:
 *   - name: Breeding Service
 *     description: Comprehensive breeding management including heat records, conception journeys, pregnancy tracking, dry-off periods, and offspring lineage.
 *
 * components:
 *   schemas:
 *     HeatRecord:
 *       type: object
 *       description: Record of an observed heat cycle for a female animal.
 *       properties:
 *         id:
 *           type: string
 *           description: Unique heat record identifier.
 *         animalId:
 *           type: string
 *           description: ID of the cow/heifer observed.
 *         date:
 *           type: string
 *           format: date-time
 *           description: Date and time when heat signs were first noted.
 *         breedingType:
 *           type: string
 *           enum: [NATURAL, AI]
 *           description: Planned method for insemination (Natural service or Artificial Insemination).
 *         note:
 *           type: string
 *           description: Optional remarks about the animal's behavior or health during heat.
 *
 *     DryOffRecord:
 *       type: object
 *       description: Record of a manual dry-off event (Not part of a pregnancy journey).
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           description: ID of the lactating cow being dried off.
 *         date:
 *           type: string
 *           format: date-time
 *           description: Official start date of the dry-off period.
 *         reason:
 *           type: string
 *           enum: [ILLNESS, LOW_YIELD, MEDICATED, OTHER]
 *           description: Justification for stopping milk production.
 *         remarks:
 *           type: string
 *
 *     ConceptionJourney:
 *       type: object
 *       description: End-to-end tracking of a pregnancy from insemination to delivery.
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           description: The female animal enrolled in the journey.
 *         status:
 *           type: string
 *           enum: [INITIATED, PREGNANT, DRY_OFF, COMPLETED, FAILED]
 *           description: Current state of the pregnancy journey.
 *         parity:
 *           type: integer
 *           description: The expected parity number this delivery will increment to.
 *         conceiveDate:
 *           type: string
 *           format: date-time
 *           description: Date of successful mating or insemination.
 *         pregnancyType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         bullId:
 *           type: string
 *           description: gaushala bull ID (If used).
 *         bullName:
 *           type: string
 *           description: Name of the bull (Internal or external).
 *         bullTag:
 *           type: string
 *         pdDate:
 *           type: string
 *           format: date-time
 *           description: Date of Pregnancy Detection (PD result).
 *         dryOffDate:
 *           type: string
 *           format: date-time
 *           description: Date marked for dry-off during pregnancy.
 *         deliveryDate:
 *           type: string
 *           format: date-time
 *           description: Recorded date of calf birth.
 *
 *     ParityRecord:
 *       type: object
 *       description: Historical data regarding an animal's past deliveries.
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         parityNo:
 *           type: integer
 *           description: Order of delivery (1st, 2nd, etc.).
 *         pregnancyType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         bullName:
 *           type: string
 *           description: Sire of the offspring.
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
 *     summary: Presigned URL for breeding photos
 *     description: Generates a temporary secure URL for uploading delivery or calf photos.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: fileName
 *         required: true
 *         example: delivery_photo_123.jpg
 *       - in: query
 *         name: fileType
 *         required: true
 *         example: image/jpeg
 *     responses:
 *       200:
 *         description: URL generated successfully.
 */

/**
 * @swagger
 * /api/breeding/heat:
 *   post:
 *     summary: Record a heat event
 *     description: Logs an observed heat cycle to help plan insemination.
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
 *         description: Heat record saved.
 *   get:
 *     summary: Get heat history
 *     description: Retrieves historical heat events with optional animal-specific filtering.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: animalId
 *         schema:
 *           type: string
 *         description: Filter records for a specific animal.
 *     responses:
 *       200:
 *         description: List of heat records.
 */

/**
 * @swagger
 * /api/breeding/heat/eligible:
 *   get:
 *     summary: Dropdown for Heat recording
 *     description: Returns only female animals (Lactating cows or Heifers) eligible for being in heat.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of eligible animal IDs and names.
 */

/**
 * @swagger
 * /api/breeding/dry-off:
 *   post:
 *     summary: Record manual dry-off
 *     description: Records a dry-off event that is NOT linked to an active pregnancy journey (e.g., due to illness or yields).
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
 *         description: Dry-off recorded.
 *   get:
 *     summary: List dry-off records
 *     description: Combined feed of manual dry-off records and those triggered by conception journeys.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Unified list of dried-off cows.
 */

/**
 * @swagger
 * /api/breeding/dry-off/eligible:
 *   get:
 *     summary: Dropdown for Manual Dry-Off
 *     description: Returns lactating cows who ARE NOT currently in a pregnancy journey.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of eligible cows.
 */

/**
 * @swagger
 * /api/breeding/bulls/eligible:
 *   get:
 *     summary: Dropdown for Insemination Bulls
 *     description: Returns only adult, non-retired bulls from the gaushala for use in breeding.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of adult bulls.
 */

/**
 * @swagger
 * /api/breeding/journey/initiate:
 *   post:
 *     summary: Start a Conception Journey
 *     description: Primary entry point for starting a pregnancy tracking journey after mating or AI. Initial status will be 'INITIATED'.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ConceptionJourney'
 *             required: [animalId, conceiveDate, pregnancyType]
 *     responses:
 *       201:
 *         description: Journey started successfully.
 */

/**
 * @swagger
 * /api/breeding/journey/list:
 *   get:
 *     summary: List all pregnancy journeys
 *     description: Returns all active and historical conception journeys for the gaushala.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Collection of all journeys.
 */

/**
 * @swagger
 * /api/breeding/journey/eligible-cows:
 *   get:
 *     summary: Dropdown for starting Pregnancy
 *     description: Returns female animals (Status ACTIVE, non-retired) that are not currently in an active pregnancy or dry-off period.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of cows ready for conception.
 */

/**
 * @swagger
 * /api/breeding/journey/eligible-dry-off:
 *   get:
 *     summary: Dropdown for Pregnancy Dry-off
 *     description: Returns cows currently in a 'PREGNANT' journey state who are now ready to be dried off.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pregnant cows.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}:
 *   get:
 *     summary: Pregnancy journey details
 *     description: Get the complete timeline and data for a specific pregnancy journey.
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     responses:
 *       200:
 *         description: Full journey model.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/confirm:
 *   patch:
 *     summary: Pregnancy Detection (PD Result)
 *     description: Post-insemination check. If pdResult is true, status moves to 'PREGNANT'. If false, journey ends as 'FAILED'.
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
 *             required: [pdResult, pdDate]
 *             properties:
 *               pdResult:
 *                 type: boolean
 *                 description: true if confirmed pregnant, false otherwise.
 *               pdDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: PD result updated.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/dry-off:
 *   patch:
 *     summary: Mark Journey Dry-Off
 *     description: Marks the pregnant cow as dried off within the context of the journey. Status moves to 'DRY_OFF'.
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
 *             required: [dryOffDate]
 *             properties:
 *               dryOffDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: Cow dried off for final pregnancy stage.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/deliver:
 *   patch:
 *     summary: Record Delivery (Atomic)
 *     description: "CRITICAL: Records calf birth, completes journey, increments mother's parity, and automatically registers the new calf in Animal-service."
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
 *             required: [deliveryDate, calfStatus, calfGender]
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
 *                 description: Required if ALIVE.
 *               calfTag:
 *                 type: string
 *                 description: Required if ALIVE and tag exists.
 *     responses:
 *       200:
 *         description: Atomic delivery process completed.
 */

/**
 * @swagger
 * /api/breeding/parity/{animalId}:
 *   get:
 *     summary: Mother's Birth History
 *     description: Retrieves all parity/delivery records for a specific cow, ordered by parity number.
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: Parity history retrieved successfully.
 */

/**
 * @swagger
 * /api/breeding/lineage/{id}:
 *   get:
 *     summary: Animal Offspring (Children)
 *     description: Identifies all animals in the gaushala where the given ID is recorded as either fatherId or motherId.
 *     tags: [Breeding Service]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: Host animal ID.
 *     responses:
 *       200:
 *         description: List of offspring.
 */
