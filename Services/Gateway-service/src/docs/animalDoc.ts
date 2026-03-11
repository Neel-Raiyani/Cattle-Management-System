/**
 * @swagger
 * tags:
 *   - name: Animal Service
 *     description: Comprehensive cattle management including health profiles, birth records, disposal tracking, and specialized reporting.
 *
 * components:
 *   schemas:
 *     Animal:
 *       type: object
 *       description: Detailed profile of a bovine animal within the gaushala.
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12345'
 *           description: Unique internal identifier (MongoDB ObjectId).
 *         name:
 *           type: string
 *           minLength: 1
 *           example: 'Laxmi'
 *           description: Name assigned to the animal.
 *         tagNumber:
 *           type: string
 *           example: 'TAG123'
 *           description: Physical tag number attached to the animal for identification.
 *         animalNumber:
 *           type: string
 *           example: 'C001'
 *           description: Internal gaushala serial number or sequence.
 *         gender:
 *           type: string
 *           enum: [MALE, FEMALE]
 *           example: FEMALE
 *           description: Biological gender of the animal.
 *         cowBreed:
 *           type: string
 *           enum: [Gir, Sahiwal, Red_Sindhi, Tharparkar, Kankrej, Rathi, Punganur, Badri, Hallikar, Kangayam, Hariana, Mewati, Nagori, Nimadi, Malvi, Kherigarh, Amritmahal, Umblachery, Pulikulam, Bargur, Ongole, Red_Kandhari, Gaolao, Gangatiri, Siri, Motu, Vechur, Jersey, Holstein_Friesian, Brown_Swiss]
 *           example: Gir
 *           description: Breed designation.
 *         cowGroup:
 *           type: string
 *           example: 'Milk-Yielders'
 *           description: Logical group assignment for management purposes.
 *         birthDate:
 *           type: string
 *           format: date
 *           description: Mandatory birth date (ISO 8601). Crucial for age and maturity calculations.
 *         adultDate:
 *           type: string
 *           format: date
 *           description: Automatically calculated date (Birth date + 12 months) when treated as an adult.
 *         isPregnant:
 *           type: boolean
 *           description: Read-only; synced from Breeding service.
 *         isLactating:
 *           type: boolean
 *           description: Indicates if the cow is currently giving milk.
 *         isDryOff:
 *           type: boolean
 *           description: Indicates if the cow is in a dry period (not producing milk).
 *         isHeifer:
 *           type: boolean
 *           description: A young female cow that has not yet had a calf. Under 1 year OR no pregnancy history.
 *         isRetired:
 *           type: boolean
 *           description: Marks animals that are removed from breeding/production cycles.
 *         retiredDate:
 *           type: string
 *           format: date
 *           description: The date when the animal was officially retired.
 *         parity:
 *           type: integer
 *           minimum: 0
 *           description: Number of times the cow has given birth.
 *         bullView:
 *           type: string
 *           description: Specific breeding classification or characteristics for bulls.
 *         motherMilk:
 *           type: number
 *           minimum: 0
 *           description: Historical dairy performance of the animal's mother (in Liters).
 *         grandmotherMilk:
 *           type: number
 *           minimum: 0
 *           description: Historical dairy performance of the animal's grandmother (in Liters).
 *         isHandicapped:
 *           type: boolean
 *           description: Indicates physical impairment.
 *         handicapReason:
 *           type: string
 *           description: Brief explanation of the disability.
 *         isUdderClosedFL:
 *           type: boolean
 *           description: Front-Left udder quarter status.
 *         isUdderClosedFR:
 *           type: boolean
 *           description: Front-Right udder quarter status.
 *         isUdderClosedBL:
 *           type: boolean
 *           description: Back-Left udder quarter status.
 *         isUdderClosedBR:
 *           type: boolean
 *           description: Back-Right udder quarter status.
 *         acquisitionType:
 *           type: string
 *           enum: [BIRTH, PURCHASE, DONATION]
 *           example: PURCHASE
 *           description: Source of entry into the gaushala.
 *         purchaseDate:
 *           type: string
 *           format: date
 *           description: Required if acquired via PURCHASE (ISO 8601).
 *         purchasedFrom:
 *           type: string
 *           description: Vendor or location of purchase.
 *         purchasePrice:
 *           type: number
 *           minimum: 0
 *           example: 45000
 *           description: Financial cost in local currency.
 *         ownerName:
 *           type: string
 *           description: Previous owner's name for documentation.
 *         ownerMobile:
 *           type: string
 *           description: Contact number of the previous owner.
 *         motherName:
 *           type: string
 *           description: Name of the animal's mother (for lineage tracking).
 *         fatherName:
 *           type: string
 *           description: Name of the animal's father (for lineage tracking).
 *         motherId:
 *           type: string
 *           format: mongo-id
 *           description: Reference to the mother's profile (if registered in the system).
 *         fatherId:
 *           type: string
 *           format: mongo-id
 *           description: Reference to the father's profile (if registered in the system).
 *         status:
 *           type: string
 *           enum: [ACTIVE, SOLD, DEAD, DONATED]
 *           example: ACTIVE
 *           description: Lifecycle availability of the animal.
 *         photoUrl:
 *           type: string
 *           description: Internal storage key for the primary image.
 *         viewUrl:
 *           type: string
 *           format: url
 *           description: Secure temporary link for UI rendering.
 *
 *     AnimalSummary:
 *       type: object
 *       properties:
 *         cows:
 *           type: object
 *           properties:
 *             total: { type: integer }
 *             heifer: { type: integer }
 *             pregnant: { type: integer }
 *             lactating: { type: integer }
 *             dryOff: { type: integer }
 *             retired: { type: integer }
 *         bulls:
 *           type: object
 *           properties:
 *             total: { type: integer }
 *             calf: { type: integer }
 *             retired: { type: integer }
 *
 *     SellRecord:
 *       type: object
 *       required: [animalId, buyer, mobileNumber, amount]
 *       properties:
 *         animalId: { type: string, format: mongo-id }
 *         buyer: { type: string }
 *         mobileNumber: { type: string, example: '9988776655' }
 *         city: { type: string }
 *         amount: { type: number, minimum: 0 }
 *         referenceBy: { type: string }
 *         photoUrl: { type: string, format: binary }
 *         soldAt: { type: string, format: date }
 *
 *     DeathRecord:
 *       type: object
 *       required: [animalId, dateOfDeath, reason]
 *       properties:
 *         animalId: { type: string, format: mongo-id }
 *         dateOfDeath: { type: string, format: date }
 *         reason: { type: string }
 *         lastPhotoUrl: { type: string }
 *
 *     DonationRecord:
 *       type: object
 *       required: [animalId, gaushalaName, mobileNumber]
 *       properties:
 *         animalId: { type: string, format: mongo-id }
 *         gaushalaName: { type: string }
 *         mobileNumber: { type: string, example: '9988776655' }
 *         referenceBy: { type: string }
 *         photoUrl: { type: string, format: binary }
 *         donatedAt: { type: string, format: date }
 */

// ───────────────────────── Groups ─────────────────────────

/**
 * @swagger
 * /api/animal/groups:
 *   get:
 *     summary: List logical groups
 *     description: Returns only the names of all unique logical groups currently in use within the gaushala.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Unique group name array.
 *   post:
 *     summary: Create new cow group
 *     description: Manually adds a new group name to the selection list.
 *     tags: [Animal Service]
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
 *             required: [name]
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 1
 *                 example: 'High Producers'
 */

/**
 * @swagger
 * /api/animal/groups/{id}:
 *   patch:
 *     summary: Rename group
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 1
 *   delete:
 *     summary: Delete group
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 */

// ───────────────────────── Reports ─────────────────────────

/**
 * @swagger
 * /api/animal/reports/summary:
 *   get:
 *     summary: Get gaushala status summary
 *     description: Returns counts of animals partitioned by various biological and production statuses (Heifer, Pregnant, etc.).
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Detailed counts summary.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AnimalSummary'
 */

/**
 * @swagger
 * /api/animal/reports/udder-close:
 *   get:
 *     summary: List cows with udder quarter issues
 *     description: Filters active cows based on the number of non-functional (closed) udder quarters. Returns minimized data.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: quarterCount
 *         schema:
 *           type: string
 *           enum: [all, 1, 2, 3, 4]
 *           default: all
 *         description: Number of closed quarters to filter by.
 *     responses:
 *       200:
 *         description: Filtered cow list.
 */

/**
 * @swagger
 * /api/animal/reports/eligible-retirement:
 *   get:
 *     summary: Get animals ready for retirement
 *     description: Returns a list of all active cows and bulls that are NOT yet retired and do NOT have an active pregnancy journey. Lactating cows ARE included.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: gender
 *         schema:
 *           type: string
 *           enum: [MALE, FEMALE]
 *     responses:
 *       200:
 *         description: Dropdown data list.
 */

/**
 * @swagger
 * /api/animal/reports/retire:
 *   post:
 *     summary: Officially retire an animal
 *     description: Marks an animal as retired. Updates 'isRetired' to true, records the retirement date, and resets production/pregnancy flags.
 *     tags: [Animal Service]
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
 *             required: [animalId, retiredDate]
 *             properties:
 *               animalId:
 *                 type: string
 *                 format: mongo-id
 *               retiredDate:
 *                 type: string
 *                 format: date
 *     responses:
 *       200:
 *         description: Animal status updated to retired.
 */

// ───────────────────────── Disposal ─────────────────────────

/**
 * @swagger
 * /api/animal/sell:
 *   post:
 *     summary: Sell an animal
 *     description: Records a sale and marks the animal status as SOLD.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/SellRecord'
 *     responses:
 *       201:
 *         description: Record saved.
 */

/**
 * @swagger
 * /api/animal/death:
 *   post:
 *     summary: Mark animal as dead
 *     description: Records the death and marks the animal status as DEAD.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DeathRecord'
 *     responses:
 *       201:
 *         description: Record saved.
 */

/**
 * @swagger
 * /api/animal/donation:
 *   post:
 *     summary: Document donation
 *     description: Records a donation and marks the animal status as DONATED.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DonationRecord'
 *     responses:
 *       201:
 *         description: Record saved.
 */

/**
 * @swagger
 * /api/animal/disposal/{type}/{id}:
 *   patch:
 *     summary: Update disposal history
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: type
 *         required: true
 *         schema:
 *           type: string
 *           enum: [sell, death, donation]
 *       - in: path
 *         name: id
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Record updated.
 */

// ───────────────────────── Animals ─────────────────────────

/**
 * @swagger
 * /api/animal/add:
 *   post:
 *     summary: Register a new cow or bull
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Animal'
 */

/**
 * @swagger
 * /api/animal/cows:
 *   get:
 *     summary: Advanced cow search and filtering
 *     description: "Retrieves female animals. Note: Returns minimized data per item (name, tagNo, parity, cowNo, birthDate, adultDate, photoUrl)."
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, lactating, heifer, pregnant, dryoff, retired, handicapped, calves]
 *         description: Lifecycle and production state filtering.
 *       - in: query
 *         name: search
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 */

/**
 * @swagger
 * /api/animal/bulls:
 *   get:
 *     summary: List bulls by status
 *     description: "Note: Returns minimized data per item (name, tagNo, birthDate, adultDate, photoUrl)."
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, retired, calf]
 *       - in: query
 *         name: search
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 */

/**
 * @swagger
 * /api/animal/media/presigned-url:
 *   get:
 *     summary: Secure upload URL
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: fileName
 *         required: true
 *       - in: query
 *         name: contentType
 *         required: true
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [PHOTO, DISPOSAL, DOC]
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 */

/**
 * @swagger
 * /api/animal/{id}:
 *   get:
 *     summary: Full animal profile
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 */

/**
 * @swagger
 * /api/animal/update/{id}:
 *   patch:
 *     summary: Update profile markers
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Animal'
 */
