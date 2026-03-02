/**
 * @swagger
 * tags:
 *   - name: Breeding Service
 *     description: Animal breeding lifecycle management, including heat records, dry-off periods, and conception journeys.
 *
 * components:
 *   schemas:
 *     HeatRecord:
 *       type: object
 *       description: Documentation of an animal's heat event and breeding attempt.
 *       required: [animalId, date, breedingType]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           format: mongo-id
 *           description: ID of the cow in heat.
 *         date:
 *           type: string
 *           format: date-time
 *           description: Date and time when the heat was observed.
 *         breedingType:
 *           type: string
 *           enum: [NATURAL, AI]
 *           description: "AI: Artificial Insemination, NATURAL: Bull breeding."
 *         bullId:
 *           type: string
 *           format: mongo-id
 *           description: Reference to the bull (if internal).
 *
 *     DryOffRecord:
 *       type: object
 *       description: Record of when a cow stopped giving milk (Dry-off period).
 *       required: [animalId, date, reason]
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
 *       description: Master record for a single pregnancy lifecycle from conception to delivery.
 *       required: [animalId, conceiveDate, pregnancyType]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         conceiveDate:
 *           type: string
 *           format: date-time
 *           description: Starting date of the conception period.
 *         pregnancyType:
 *           type: string
 *           enum: [NATURAL, AI]
 *         currentStage:
 *           type: string
 *           enum: [INITIATED, PD_CONFIRMED, DRY_OFF, DELIVERED, ABORTED]
 *           description: Tracks the progress of the pregnancy.
 *         pdResult:
 *           type: boolean
 *           description: Result of the Pregnancy Diagnosis check.
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
 *       description: Historical record of a specific past parity (calving event).
 *       required: [animalId, parityNo, deliveryDate, pregnancyDate]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         parityNo:
 *           type: integer
 *           minimum: 1
 *           description: Sequence number of the birth (e.g. 1st calf, 2nd calf).
 *         pregnancyDate:
 *           type: string
 *           format: date-time
 *         deliveryDate:
 *           type: string
 *           format: date-time
 *         calfId:
 *           type: string
 *           format: mongo-id
 *           description: Link to the registered offspring profile.
 */

// ───────────────────────── Media ─────────────────────────

/**
 * @swagger
 * /api/breeding/media/presigned-url:
 *   get:
 *     summary: Get upload URL for breeding media
 *     description: Provides a temporary link for uploading pregnancy or delivery photos.
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
 *         description: Presigned URL generated.
 */

// ───────────────────────── Heat ─────────────────────────

/**
 * @swagger
 * /api/breeding/heat:
 *   post:
 *     summary: Record heat observation
 *     description: Registers a new heat event. Updates the animal's breeding status tokens.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/HeatRecord'
 *     responses:
 *       201:
 *         description: Event recorded.
 *       400:
 *         description: Validation error.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationErrorResponse'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *   get:
 *     summary: Animal heat history
 *     description: Lists all past heat records for a specific animal.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: List of records.
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */

/**
 * @swagger
 * /api/breeding/heat/eligible:
 *   get:
 *     summary: Animals ready for heat
 *     description: Returns a list of cows eligible for a new heat record.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: List of animals.
 */

/**
 * @swagger
 * /api/breeding/heat/{id}:
 *   patch:
 *     summary: Update heat entry
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/HeatRecord'
 *     responses:
 *       200:
 *         description: Updated.
 *       400:
 *         $ref: '#/components/schemas/ValidationErrorResponse'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *   delete:
 *     summary: Remove heat record
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Deleted.
 */

// ───────────────────────── Dry-Off ─────────────────────────

/**
 * @swagger
 * /api/breeding/dry-off:
 *   post:
 *     summary: Mark animal as Dry
 *     description: Records a dry-off period for a cow. Updates 'isLactating' to false.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DryOffRecord'
 *     responses:
 *       201:
 *         description: Status updated.
 *       400:
 *         $ref: '#/components/schemas/ValidationErrorResponse'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *   get:
 *     summary: Dry-off history
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: History retrieved.
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */

/**
 * @swagger
 * /api/breeding/dry-off/eligible:
 *   get:
 *     summary: Eligible for Dry-off
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Dropdown list.
 */

/**
 * @swagger
 * /api/breeding/dry-off/{id}:
 *   patch:
 *     summary: Correct dry-off record
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DryOffRecord'
 *     responses:
 *       200:
 *         description: Corrected.
 *       400:
 *         $ref: '#/components/schemas/ValidationErrorResponse'
 *   delete:
 *     summary: Remove dry-off record
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Record removed.
 */

// ───────────────────────── Parity ─────────────────────────

/**
 * @swagger
 * /api/breeding/parity:
 *   post:
 *     summary: Add historical parity
 *     description: Manually adds a past birth record for historical tracking.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ParityRecord'
 *     responses:
 *       201:
 *         description: Record added.
 */

/**
 * @swagger
 * /api/breeding/parity/{animalId}:
 *   get:
 *     summary: Full birth history
 *     description: Retrieves all recorded calving events for an animal.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: animalId
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Parity timeline.
 */

/**
 * @swagger
 * /api/breeding/parity/{id}:
 *   patch:
 *     summary: Update parity record
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ParityRecord'
 *     responses:
 *       200:
 *         description: Parity entry updated.
 */

// ───────────────────────── Conception Journey ─────────────────────────

/**
 * @swagger
 * /api/breeding/journey/initiate:
 *   post:
 *     summary: Start a new pregnancy lifecycle
 *     description: "Initializes a journey. Updates cow status to 'isPregnant: true' and 'isHeifer: false'."
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ConceptionJourney'
 *             required: [animalId, conceiveDate, pregnancyType]
 *     responses:
 *       201:
 *         description: Journey started.
 *       400:
 *         description: Cow already in an active journey or validation error.
 */

/**
 * @swagger
 * /api/breeding/journey/list:
 *   get:
 *     summary: List all active journeys
 *     description: Returns a global view of current pregnancies in the gaushala.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Progress list.
 */

/**
 * @swagger
 * /api/breeding/journey/eligible-cows:
 *   get:
 *     summary: Get Eligible Cows for Journeys
 *     description: Returns cows that are currently NOT in an active pregnancy journey and are of breeding age.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: List of cows.
 */

/**
 * @swagger
 * /api/breeding/journey/eligible-dry-off:
 *   get:
 *     summary: Get Cows for Journey Dry-off
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Eligible cows list.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}:
 *   get:
 *     summary: Journey Status Details
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Multi-stage breakdown.
 *   put:
 *     summary: Correct initiation details
 *     description: Allows fixing date/type after a journey has started.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ConceptionJourney'
 *     responses:
 *       200:
 *         description: Corrected.
 *   delete:
 *     summary: Cancel pregnancy journey
 *     description: Removes the journey record and resets cow's pregnancy status.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Journey terminated.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/confirm:
 *   patch:
 *     summary: Confirm pregnancy (PD)
 *     description: Documents the results of the Pregnancy Diagnosis. If `pdResult` is false, the journey ends as ABORTED.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
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
 *               pdDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: Result saved.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/dry-off:
 *   patch:
 *     summary: Record journey dry-off
 *     description: Links a dry-off date to the active pregnancy journey.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
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
 *         description: Stage updated to DRY_OFF.
 */

/**
 * @swagger
 * /api/breeding/journey/{id}/deliver:
 *   patch:
 *     summary: Record birth and close journey
 *     description: "CRITICAL: This atomic operation records the delivery outcome, increments the cow's parity, updates isPregnant/isLactating, and automatically registers the new calf in the Animal service."
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - in: header
 *         name: gaushala-id
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
 *               calfTagNumber:
 *                 type: string
 *               calfBreed:
 *                 type: string
 *               calfGroup:
 *                 type: string
 *               calfAppearance:
 *                 type: string
 *               calfWeight:
 *                 type: number
 *               deliveryPhoto:
 *                 type: string
 *               calfPhoto:
 *                 type: string
 *     responses:
 *       201:
 *         description: Delivery recorded and calf registered successfully.
 */

// ───────────────────────── Lineage / Helpers ─────────────────────────

/**
 * @swagger
 * /api/breeding/bulls/eligible:
 *   get:
 *     summary: Get Breeding Bulls
 *     description: Returns a list of bulls available for NATUAL breeding selection.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: List of bulls for dropdown.
 */

/**
 * @swagger
 * /api/breeding/lineage/{id}:
 *   get:
 *     summary: Get children list
 *     description: Retrieves all registered calves birthed by the specified animal.
 *     tags: [Breeding Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     responses:
 *       200:
 *         description: Children profiles.
 */
