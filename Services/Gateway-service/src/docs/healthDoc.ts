/**
 * @swagger
 * tags:
 *   - name: Health Service
 *     description: Animal health lifecycle management, including disease tracking, vaccinations, medical history, and deworming.
 *
 * components:
 *   schemas:
 *     DiseaseMaster:
 *       type: object
 *       description: Reference record for a known bovine disease.
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12345'
 *         name:
 *           type: string
 *           example: 'Foot and Mouth Disease'
 *           description: Common name of the illness.
 *
 *     VaccineMaster:
 *       type: object
 *       description: Reference record for available vaccines.
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12346'
 *         name:
 *           type: string
 *           example: 'FMD Vaccine'
 *           description: Commercial or scientific name of the vaccine.
 *
 *     MedicalRecord:
 *       type: object
 *       description: Detailed entry for a veterinary visit or health check.
 *       required: [animalId, visitType, visitDate, medicalStatus]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           format: mongo-id
 *           description: Host animal ID.
 *         visitType:
 *           type: string
 *           enum: [ILLNESS, CHECKUP]
 *           description: Reason for the veterinary interaction.
 *         visitDate:
 *           type: string
 *           format: date-time
 *           description: Precise date of the visit.
 *         visitNumber:
 *           type: string
 *           description: Internal visit sequence or token.
 *         vetId:
 *           type: string
 *           format: mongo-id
 *           description: ID of the attending veterinarian (Managed in Auth/Gaushala).
 *         diseaseId:
 *           type: string
 *           format: mongo-id
 *           description: diagnosed disease (if visitType is ILLNESS).
 *         medicalStatus:
 *           type: string
 *           enum: [SICK, HEALTHY]
 *           description: Resulting health status after the visit.
 *         symptoms:
 *           type: string
 *           description: Observed signs of illness.
 *         treatment:
 *           type: string
 *           description: Prescribed medications or actions.
 *
 *     VaccinationRecord:
 *       type: object
 *       description: Documentation for a single vaccine dose administration.
 *       required: [animalId, doseDate, doseType, vaccineId]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         doseDate:
 *           type: string
 *           format: date-time
 *           description: Date of administration.
 *         doseType:
 *           type: string
 *           enum: [FIRST, BOOSTER, REPEAT]
 *           description: Placement in the vaccination cycle.
 *         vaccineId:
 *           type: string
 *           format: mongo-id
 *           description: Reference to VaccineMaster.
 *         remark:
 *           type: string
 *
 *     DewormingRecord:
 *       type: object
 *       description: Tracking for internal parasite treatments.
 *       required: [animalId, doseDate, doseType]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *         doseDate:
 *           type: string
 *           format: date-time
 *         doseType:
 *           type: string
 *           enum: [INJECTION, TABLET]
 *           description: Mode of administration.
 *         companyName:
 *           type: string
 *           description: Manufacturer of the dewormer.
 *         quantity:
 *           type: string
 *           example: '500mg'
 *         vetId:
 *           type: string
 *           format: mongo-id
 *         nextDoseDate:
 *           type: string
 *           format: date-time
 *           description: Scheduled date for followup.
 */

// ───────────────────────── Master Lists ─────────────────────────

/**
 * @swagger
 * /api/health/master/diseases:
 *   get:
 *     summary: List all cataloged diseases
 *     description: Retrieves the global master list of diseases for selection in records.
 *     tags: [Health Service]
 *     responses:
 *       200:
 *         description: Disease array.
 *   post:
 *     summary: Add to disease catalog
 *     description: Creates a new disease master record for use across the platform.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Lumpy Skin Disease
 *     responses:
 *       201:
 *         description: Master entry created.
 */

/**
 * @swagger
 * /api/health/master/vaccines:
 *   get:
 *     summary: List all vaccines
 *     description: Retrieves the global master list of available vaccinations.
 *     tags: [Health Service]
 *     responses:
 *       200:
 *         description: Vaccine array.
 *   post:
 *     summary: Add to vaccine catalog
 *     description: Creates a new vaccine master entry.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Brucellosis Vaccine
 *     responses:
 *       201:
 *         description: Master entry created.
 */

// ───────────────────────── Medical Records ─────────────────────────

/**
 * @swagger
 * /api/health/medical:
 *   post:
 *     summary: Record medical encounter
 *     description: Documents a physical checkup or illness treatment. Updates the animal's internal health flags.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/MedicalRecord'
 *     responses:
 *       201:
 *         description: Encounter archived.
 *   get:
 *     summary: Animal health history
 *     description: Retrieves all medical/encounter records for a specific animal.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *         description: Target animal ID.
 *     responses:
 *       200:
 *         description: Multi-entry history.
 */

/**
 * @swagger
 * /api/health/medical/{id}:
 *   patch:
 *     summary: Update medical record
 *     description: Modifies symptoms, treatment, or vet details for an existing record.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/MedicalRecord'
 *     responses:
 *       200:
 *         description: Changes saved.
 */

// ───────────────────────── Vaccination ─────────────────────────

/**
 * @swagger
 * /api/health/vaccination:
 *   post:
 *     summary: Log a vaccination dose
 *     description: Registers a specific dose against an animal and the global vaccine catalog.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/VaccinationRecord'
 *     responses:
 *       201:
 *         description: Dose documented.
 *   get:
 *     summary: Vaccination timeline
 *     description: Retrieves all doses and booster shots recorded for an animal.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: Timeline array.
 */

/**
 * @swagger
 * /api/health/vaccination/{id}:
 *   patch:
 *     summary: Adjust vaccination record
 *     description: Updates dose type or remarks for an existing vaccination entry.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/VaccinationRecord'
 *     responses:
 *       200:
 *         description: Updated.
 */

// ───────────────────────── Deworming ─────────────────────────

/**
 * @swagger
 * /api/health/deworming:
 *   post:
 *     summary: Individual deworming
 *     description: Records a single deworming treatment for one animal.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DewormingRecord'
 *     responses:
 *       201:
 *         description: Dose recorded.
 *   get:
 *     summary: Deworming history
 *     description: Lists past deworming doses for an animal, including upcoming scheduled doses.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *     responses:
 *       200:
 *         description: History retrieved.
 */

/**
 * @swagger
 * /api/health/deworming/bulk:
 *   post:
 *     summary: Batch deworming
 *     description: Efficiently records a shared deworming event for a group of animals.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [animalIds, doseDate, doseType]
 *             properties:
 *               animalIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Subset of animal IDs treated.
 *               doseDate:
 *                 type: string
 *                 format: date-time
 *               doseType:
 *                 type: string
 *                 enum: [INJECTION, TABLET]
 *               companyName:
 *                 type: string
 *               quantity:
 *                 type: string
 *               vetId:
 *                 type: string
 *               nextDoseDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: All individual records created atomically.
 */

/**
 * @swagger
 * /api/health/deworming/list:
 *   get:
 *     summary: Gaushala-wide deworming feed
 *     description: Returns the latest deworming events across all animals in the gaushala.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Paginated deworming log.
 */

/**
 * @swagger
 * /api/health/deworming/{id}:
 *   patch:
 *     summary: Update deworming dose
 *     description: Modifies quantity, company, or next dose date for a record.
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DewormingRecord'
 *     responses:
 *       200:
 *         description: Updated.
 */

// ───────────────────────── Timeline ─────────────────────────

/**
 * @swagger
 * /api/health/timeline/{animalId}:
 *   get:
 *     summary: Integrated Health Passport
 *     description: "Returns a chronological merged feed of ALL health interactions: Medical visits, Vaccinations, and Deworming doses."
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: animalId
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Full chronological health timeline.
 */

/**
 * @swagger
 * components:
 *   parameters:
 *     GaushalaIdHeader:
 *       in: header
 *       name: gaushala-id
 *       required: true
 *       schema:
 *         type: string
 *         description: Multi-tenant scope identifier for the gaushala.
 */
