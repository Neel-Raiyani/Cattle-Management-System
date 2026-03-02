/**
 * @swagger
 * tags:
 *   - name: Animal Service
 *     description: Comprehensive cattle management including health profiles, birth records, and disposal tracking via the Gateway.
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
 *           example: Gir
 *           description: Breed designation (e.g., Gir, Sahiwal, HL).
 *         cowGroup:
 *           type: string
 *           example: 'Milk-Yielders'
 *           description: Logical group assignment for management purposes.
 *         birthDate:
 *           type: string
 *           format: date-time
 *           description: Mandatory birth date. Crucial for age and maturity calculations.
 *         adultDate:
 *           type: string
 *           format: date-time
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
 *         parity:
 *           type: integer
 *           description: Number of times the cow has given birth (replaces lactationNumber).
 *         bullView:
 *           type: string
 *           description: Specific breeding classification or characteristics for bulls.
 *         motherMilk:
 *           type: number
 *           description: Historical dairy performance of the animal's mother (in Liters).
 *         grandmotherMilk:
 *           type: number
 *           description: Historical dairy performance of the animal's grandmother (in Liters).
 *         isHandicapped:
 *           type: boolean
 *           description: Indicates physical impairment.
 *         handicapReason:
 *           type: string
 *           description: Brief explanation of the disability.
 *         acquisitionType:
 *           type: string
 *           enum: [BIRTH, PURCHASE, DONATION]
 *           example: PURCHASE
 *           description: Source of entry into the gaushala.
 *         purchaseDate:
 *           type: string
 *           format: date-time
 *           description: Required if acquired via PURCHASE.
 *         purchasedFrom:
 *           type: string
 *           description: Vendor or location of purchase.
 *         purchasePrice:
 *           type: number
 *           example: 45000
 *           description: Financial cost in local currency.
 *         ownerName:
 *           type: string
 *           description: Previous owner's name for documentation.
 *         ownerMobile:
 *           type: string
 *           description: Contact number of the previous owner.
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
 *           description: Secure temporary link for UI rendering (Expires quickly).
 *
 *     SellRecord:
 *       type: object
 *       description: Record of a successful animal sale transaction.
 *       required: [animalId, buyer, mobileNumber, amount]
 *       properties:
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         buyer:
 *           type: string
 *           example: 'Ramesh Patel'
 *         mobileNumber:
 *           type: string
 *           example: '9888776655'
 *         amount:
 *           type: number
 *           example: 52000
 *         saleDate:
 *           type: string
 *           format: date-time
 *         note:
 *           type: string
 *
 *     DeathRecord:
 *       type: object
 *       description: Documentation for animal mortality.
 *       required: [animalId, deathDate, reason]
 *       properties:
 *         animalId:
 *           type: string
 *         deathDate:
 *           type: string
 *           format: date-time
 *         reason:
 *           type: string
 *           example: 'Natural causes / Age'
 *         note:
 *           type: string
 *
 *     DonationRecord:
 *       type: object
 *       description: Details regarding giving an animal away to another gaushala or person.
 *       required: [animalId, donee, mobileNumber]
 *       properties:
 *         animalId:
 *           type: string
 *         donee:
 *           type: string
 *           description: Recipient name.
 *         mobileNumber:
 *           type: string
 *           example: '9876543210'
 *         photoUrl:
 *           type: string
 *           description: Key for any donation documentation or ceremony photo.
 */

/**
 * @swagger
 * /api/animal/add:
 *   post:
 *     summary: Register a new cow or bull
 *     description: Adds a new entry to the gaushala inventory. Automatically calculates 'adultDate'.
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
 *         description: Successfully added.
 */

/**
 * @swagger
 * /api/animal/cows:
 *   get:
 *     summary: Advanced cow search and filtering
 *     description: Retrieves a list of female animals with status-based filtering (e.g., searching for all pregnant cows).
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, lactating, heifer, pregnant, dryoff, retired, calves]
 *         description: Lifecycle and production state filtering.
 *       - in: query
 *         name: search
 *         description: Partial match on name or tag number.
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
 *         description: Cow list with total meta.
 */

/**
 * @swagger
 * /api/animal/bulls:
 *   get:
 *     summary: List bulls by status
 *     description: Specialized endpoint for male animals with age and retirement filters.
 *     tags: [Animal Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, retired, calf]
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
 *         description: List of bulls.
 */

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
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Unique group name array.
 */

/**
 * @swagger
 * /api/animal/sell:
 *   post:
 *     summary: Sell an animal
 *     description: Records a sale transaction and updates the animal's status to 'SOLD'. Includes inventory removal.
 *     tags: [Animal Service]
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
 *             $ref: '#/components/schemas/SellRecord'
 *     responses:
 *       201:
 *         description: Sale recorded.
 */

/**
 * @swagger
 * /api/animal/death:
 *   post:
 *     summary: Mark animal as dead
 *     description: Finalizes an animal's profile with death records and updates status to 'DEAD'.
 *     tags: [Animal Service]
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
 *             $ref: '#/components/schemas/DeathRecord'
 *     responses:
 *       201:
 *         description: Mortality documented.
 */

/**
 * @swagger
 * /api/animal/donation:
 *   post:
 *     summary: Document donation
 *     description: Changes animal status to 'DONATED' and records the recipient.
 *     tags: [Animal Service]
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
 *             $ref: '#/components/schemas/DonationRecord'
 *     responses:
 *       201:
 *         description: Donation archived.
 */

/**
 * @swagger
 * /api/animal/disposal/{type}/{id}:
 *   patch:
 *     summary: Update disposal history
 *     description: Adjusts existing sale, death, or donation records.
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
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Updated.
 */

/**
 * @swagger
 * /api/animal/media/presigned-url:
 *   get:
 *     summary: Secure upload URL
 *     description: Retrieves a pre-authorized URL for uploading animal photos or disposal documentation directly to storage.
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
 *         description: Specific storage bucket/path.
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Upload instructions generated.
 */

/**
 * @swagger
 * /api/animal/{id}:
 *   get:
 *     summary: Full animal profile
 *     description: Retrieves all available data for a single animal by its primary ID.
 *     tags: [Animal Service]
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
 *         description: Multi-layered profile retrieved.
 */

/**
 * @swagger
 * /api/animal/update/{id}:
 *   patch:
 *     summary: Update profile markers
 *     description: Allows modification of name, tag, status booleans, and other descriptive fields.
 *     tags: [Animal Service]
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
 *             $ref: '#/components/schemas/Animal'
 *     responses:
 *       200:
 *         description: Profile updated.
 */
