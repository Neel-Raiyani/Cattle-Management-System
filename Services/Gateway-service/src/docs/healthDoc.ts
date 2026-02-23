/**
 * @swagger
 * tags:
 *   - name: Health Service
 *     description: Animal health management, medical records, vaccinations, and deworming (Health-service via Gateway)
 *
 * components:
 *   schemas:
 *     DiseaseMaster:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12345'
 *         name:
 *           type: string
 *           example: 'Foot and Mouth Disease'
 *
 *     VaccineMaster:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12346'
 *         name:
 *           type: string
 *           example: 'FMD Vaccine'
 *
 *     MedicalRecord:
 *       type: object
 *       required: [animalId, visitType, visitDate, medicalStatus]
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12347'
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         visitType:
 *           type: string
 *           enum: [ILLNESS, CHECKUP]
 *         visitDate:
 *           type: string
 *           format: date-time
 *         visitNumber:
 *           type: string
 *         vetId:
 *           type: string
 *           format: mongo-id
 *         diseaseId:
 *           type: string
 *           format: mongo-id
 *         medicalStatus:
 *           type: string
 *           enum: [SICK, HEALTHY]
 *         symptoms:
 *           type: string
 *         treatment:
 *           type: string
 *
 *     VaccinationRecord:
 *       type: object
 *       required: [animalId, doseDate, doseType, vaccineId]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         doseDate:
 *           type: string
 *           format: date-time
 *         doseType:
 *           type: string
 *           enum: [FIRST, BOOSTER, REPEAT]
 *         vaccineId:
 *           type: string
 *           format: mongo-id
 *         remark:
 *           type: string
 *
 *     DewormingRecord:
 *       type: object
 *       required: [animalId, doseDate, doseType]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         doseDate:
 *           type: string
 *           format: date-time
 *         doseType:
 *           type: string
 *           enum: [INJECTION, TABLET]
 *         companyName:
 *           type: string
 *         quantity:
 *           type: string
 *         vetId:
 *           type: string
 *           format: mongo-id
 *         nextDoseDate:
 *           type: string
 *           format: date-time
 */

// ───────────────────────── Master Lists ─────────────────────────

/**
 * @swagger
 * /api/health/master/diseases:
 *   get:
 *     summary: Get all disease master records
 *     tags: [Health Service]
 *     responses:
 *       200:
 *         description: List of diseases
 *   post:
 *     summary: Add a new disease to master list
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
 *     responses:
 *       201:
 *         description: Disease added
 */

/**
 * @swagger
 * /api/health/master/vaccines:
 *   get:
 *     summary: Get all vaccine master records
 *     tags: [Health Service]
 *     responses:
 *       200:
 *         description: List of vaccines
 *   post:
 *     summary: Add a new vaccine to master list
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
 *     responses:
 *       201:
 *         description: Vaccine added
 */

// ───────────────────────── Medical Records ─────────────────────────

/**
 * @swagger
 * /api/health/medical:
 *   post:
 *     summary: Record a medical visit
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
 *         description: Record created
 *   get:
 *     summary: Get medical history by animal
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of medical records
 */

/**
 * @swagger
 * /api/health/medical/{id}:
 *   patch:
 *     summary: Update a medical record
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/MedicalRecord'
 *     responses:
 *       200:
 *         description: Record updated
 */

// ───────────────────────── Vaccination ─────────────────────────

/**
 * @swagger
 * /api/health/vaccination:
 *   post:
 *     summary: Record a vaccination
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
 *         description: Record created
 *   get:
 *     summary: Get vaccination history by animal
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of vaccination records
 */

/**
 * @swagger
 * /api/health/vaccination/{id}:
 *   patch:
 *     summary: Update a vaccination record
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/VaccinationRecord'
 *     responses:
 *       200:
 *         description: Record updated
 */

// ───────────────────────── Deworming ─────────────────────────

/**
 * @swagger
 * /api/health/deworming:
 *   post:
 *     summary: Record a single deworming dose
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
 *         description: Record created
 *   get:
 *     summary: Get deworming history by animal
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: animalId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of deworming records
 */

/**
 * @swagger
 * /api/health/deworming/bulk:
 *   post:
 *     summary: Record deworming for multiple animals
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
 *         description: Bulk records created
 */

/**
 * @swagger
 * /api/health/deworming/list:
 *   get:
 *     summary: List deworming records for a gaushala (recent first)
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: List of recent deworming events
 */

/**
 * @swagger
 * /api/health/deworming/{id}:
 *   patch:
 *     summary: Update a deworming record
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DewormingRecord'
 *     responses:
 *       200:
 *         description: Record updated
 */

// ───────────────────────── Timeline ─────────────────────────

/**
 * @swagger
 * /api/health/timeline/{animalId}:
 *   get:
 *     summary: Get universal health feed for an animal
 *     tags: [Health Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: animalId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Merged timeline of medical, vaccination, and deworming records
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
 *         description: ID of the gaushala to scope the request
 */
