/**
 * @swagger
 * tags:
 *   - name: Animal Service
 *     description: Animal management and disposal records (Animal-service via Gateway)
 *
 * components:
 *   schemas:
 *     Animal:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12345'
 *         name:
 *           type: string
 *           example: 'Laxmi'
 *         tagNumber:
 *           type: string
 *           example: 'TAG123'
 *         animalNumber:
 *           type: string
 *           example: 'C001'
 *         gender:
 *           type: string
 *           enum: [MALE, FEMALE]
 *           example: FEMALE
 *         cowBreed:
 *           type: string
 *           example: Gir
 *         cowGroup:
 *           type: string
 *           example: 'Milk-Yielders'
 *         birthDate:
 *           type: string
 *           format: date-time
 *           description: Mandatory birth date
 *         adultDate:
 *           type: string
 *           format: date-time
 *           description: Automatically calculated (birthDate + 12 months)
 *         age:
 *           type: string
 *           example: '2 years, 14 days'
 *           description: Calculated age string
 *         isPregnant:
 *           type: boolean
 *         isLactating:
 *           type: boolean
 *         isDryOff:
 *           type: boolean
 *         isHeifer:
 *           type: boolean
 *         isRetired:
 *           type: boolean
 *         parity:
 *           type: integer
 *           description: Number of deliveries (Replacing lactationNumber)
 *         bullView:
 *           type: string
 *         motherMilk:
 *           type: number
 *         grandmotherMilk:
 *           type: number
 *         isHandicapped:
 *           type: boolean
 *         handicapReason:
 *           type: string
 *         acquisitionType:
 *           type: string
 *           enum: [BIRTH, PURCHASE, DONATION]
 *           example: PURCHASE
 *         purchaseDate:
 *           type: string
 *           format: date-time
 *         purchasedFrom:
 *           type: string
 *         purchasePrice:
 *           type: number
 *           example: 45000
 *         ownerName:
 *           type: string
 *         ownerMobile:
 *           type: string
 *         status:
 *           type: string
 *           enum: [ACTIVE, SOLD, DEAD, DONATED]
 *           example: ACTIVE
 *         photoUrl:
 *           type: string
 *           description: The unique key/filename of the cattle photo stored in S3/MinIO
 *         viewUrl:
 *           type: string
 *           format: url
 *           description: Temporary secure link to view the animal photo
 *
 *     SellRecord:
 *       type: object
 *       required: [animalId, buyer, mobileNumber, amount]
 *       properties:
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         buyer:
 *           type: string
 *           example: 'Ramesh Bhai'
 *         mobileNumber:
 *           type: string
 *           example: '9876543210'
 *         amount:
 *           type: number
 *           example: 55000
 *         photoUrl:
 *           type: string
 *           description: Transfer/Receipt photo key
 *
 *     DeathRecord:
 *       type: object
 *       required: [animalId, dateOfDeath, reason]
 *       properties:
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         dateOfDeath:
 *           type: string
 *           format: date-time
 *         reason:
 *           type: string
 *           example: 'Natural Causes'
 *         lastPhotoUrl:
 *           type: string
 *           description: Photo of the animal at time of death
 *
 *     DonationRecord:
 *       type: object
 *       required: [animalId, gaushalaName, mobileNumber]
 *       properties:
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         gaushalaName:
 *           type: string
 *           example: 'Shree Krishna Gaushala'
 *         mobileNumber:
 *           type: string
 *           example: '9876543210'
 *         photoUrl:
 *           type: string
 *           description: Donation certificate/photo key
 */

/**
 * @swagger
 * /api/animal/add:
 *   post:
 *     summary: Register a new animal (Cow or Bull)
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Animal'
 *             required: [gender, birthDate, acquisitionType]
 *     responses:
 *       201:
 *         description: Animal registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 animal:
 *                   $ref: '#/components/schemas/Animal'
 *       400:
 *         description: Validation error
 */

/**
 * @swagger
 * /api/animal/cows:
 *   get:
 *     summary: Get specialized listing of cows with filters
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, lactating, heifer, pregnant, dryoff, retired, calves]
 *         description: Filter cows by production status
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search by name or tag number
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Paginated cow list retrieved
 */

/**
 * @swagger
 * /api/animal/bulls:
 *   get:
 *     summary: Get specialized listing of bulls with filters
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, retired, calf]
 *         description: Filter bulls by status
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search by name or tag number
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Paginated bull list retrieved
 */

/**
 * @swagger
 * /api/animal/groups:
 *   get:
 *     summary: Get list of cow groups (Names only)
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of group names retrieved
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 groups:
 *                   type: array
 *                   items:
 *                     type: string
 *                     example: 'Milk-Yielders'
 */


/**
 * @swagger
 * /api/animal/sell:
 *   post:
 *     summary: Record animal sale
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/SellRecord'
 *     responses:
 *       201:
 *         description: Sale recorded successfully
 */

/**
 * @swagger
 * /api/animal/death:
 *   post:
 *     summary: Record animal death
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DeathRecord'
 *     responses:
 *       201:
 *         description: Death recorded successfully
 */

/**
 * @swagger
 * /api/animal/donation:
 *   post:
 *     summary: Record animal donation
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DonationRecord'
 *     responses:
 *       201:
 *         description: Donation recorded successfully
 */

/**
 * @swagger
 * /api/animal/disposal/{type}/{id}:
 *   patch:
 *     summary: Update a disposal record
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
 *         schema:
 *           type: string
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Disposal record updated successfully
 */

/**
 * @swagger
 * /api/animal/media/presigned-url:
 *   get:
 *     summary: Generate a presigned URL for image upload
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: fileName
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: contentType
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: type
 *         required: false
 *         schema:
 *           type: string
 *           enum: [PHOTO, DISPOSAL, DOC]
 *         description: Defaults to PHOTO if not provided
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Presigned URL generated successfully
 */
/**
 * @swagger
 * /api/animal/{id}:
 *   get:
 *     summary: Get animal details by ID
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Animal details retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Animal'
 *       404:
 *         description: Animal not found
 */

/**
 * @swagger
 * /api/animal/update/{id}:
 *   patch:
 *     summary: Update animal details
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Animal'
 *     responses:
 *       200:
 *         description: Animal updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 animal:
 *                   $ref: '#/components/schemas/Animal'
 */
