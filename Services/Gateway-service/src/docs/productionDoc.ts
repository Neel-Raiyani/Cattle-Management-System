/**
 * @swagger
 * tags:
 *   - name: Production Service
 *     description: Milk production, feed inventory, and distribution management (Production-service via Gateway)
 *
 * components:
 *   schemas:
 *     MilkDistributionCategory:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           example: '65d1234567890abcdef12111'
 *         name:
 *           type: string
 *           example: 'Home Consumption'
 *
 *     FeedInventory:
 *       type: object
 *       properties:
 *         gaushalaId:
 *           type: string
 *         totalQuantity:
 *           type: number
 *           description: Current feed stock in Kg
 *           example: 500.5
 *
 *     MilkRecord:
 *       type: object
 *       required: [animalId, date, session, quantity]
 *       properties:
 *         id:
 *           type: string
 *         animalId:
 *           type: string
 *           format: mongo-id
 *         date:
 *           type: string
 *           format: date
 *         session:
 *           type: string
 *           enum: [MORNING, EVENING]
 *         quantity:
 *           type: number
 *           description: Milk in Liters
 *         feedQuantity:
 *           type: number
 *           description: Feed consumed in Kg
 *
 *     DistributionRecord:
 *       type: object
 *       required: [date, session, categoryId, quantity]
 *       properties:
 *         id:
 *           type: string
 *         date:
 *           type: string
 *           format: date
 *         session:
 *           type: string
 *           enum: [MORNING, EVENING]
 *         categoryId:
 *           type: string
 *           format: mongo-id
 *         quantity:
 *           type: number
 *           description: Milk in Liters
 */

// ───────────────────────── Categories ─────────────────────────

/**
 * @swagger
 * /api/production/categories:
 *   get:
 *     summary: Get all milk distribution categories
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: List of categories
 *   post:
 *     summary: Create a new distribution category
 *     tags: [Production Service]
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
 *     responses:
 *       201:
 *         description: Category created
 */

/**
 * @swagger
 * /api/production/categories/{id}:
 *   patch:
 *     summary: Update a category
 *     tags: [Production Service]
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
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *     responses:
 *       200:
 *         description: Category updated
 *   delete:
 *     summary: Delete a category
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Category deleted
 */

// ───────────────────────── Inventory ─────────────────────────

/**
 * @swagger
 * /api/production/inventory:
 *   get:
 *     summary: Get current feed inventory status
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Current stock level in Kg
 */

/**
 * @swagger
 * /api/production/inventory/update:
 *   post:
 *     summary: Update feed inventory (add/correct stock)
 *     tags: [Production Service]
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
 *             required: [quantity]
 *             properties:
 *               quantity:
 *                 type: number
 *                 description: Quantity to add (positive) or subtract (negative) in Kg
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Inventory updated
 */

// ───────────────────────── Yields / Production ─────────────────────────

/**
 * @swagger
 * /api/production/yields:
 *   post:
 *     summary: Record milk yields in bulk
 *     description: Records yields and automatically deducts feed from inventory.
 *     tags: [Production Service]
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
 *             required: [date, session, entries]
 *             properties:
 *               date:
 *                 type: string
 *                 format: date
 *               session:
 *                 type: string
 *                 enum: [MORNING, EVENING]
 *               entries:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [animalId, quantity]
 *                   properties:
 *                     animalId:
 *                       type: string
 *                     quantity:
 *                       type: number
 *                       description: Milk in Liters
 *                     feedQuantity:
 *                       type: number
 *                       description: Feed in Kg
 *     responses:
 *       201:
 *         description: Yields recorded
 *   get:
 *     summary: Get yield records for a date and session
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: session
 *         required: true
 *         schema:
 *           type: string
 *           enum: [MORNING, EVENING]
 *     responses:
 *       200:
 *         description: List of yields
 */

/**
 * @swagger
 * /api/production/yields/{id}:
 *   patch:
 *     summary: Update a yield record
 *     tags: [Production Service]
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
 *             type: object
 *             properties:
 *               quantity:
 *                 type: number
 *               feedQuantity:
 *                 type: number
 *     responses:
 *       200:
 *         description: Record updated
 *   delete:
 *     summary: Delete a yield record
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Record deleted
 */

// ───────────────────────── Distribution ─────────────────────────

/**
 * @swagger
 * /api/production/distribution:
 *   post:
 *     summary: Record milk distribution
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DistributionRecord'
 *     responses:
 *       201:
 *         description: Distribution recorded
 *   get:
 *     summary: Get distribution records
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: session
 *         schema:
 *           type: string
 *           enum: [MORNING, EVENING]
 *     responses:
 *       200:
 *         description: List of distribution records
 */

// ───────────────────────── Reports ─────────────────────────

/**
 * @swagger
 * /api/production/reports/daily:
 *   get:
 *     summary: Daily Milk Report
 *     description: Detailed feed vs milk for all recorded animals for a specific date.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *     responses:
 *       200:
 *         description: Daily report data
 */

/**
 * @swagger
 * /api/production/reports/monthly:
 *   get:
 *     summary: Monthly Milk Report
 *     description: Aggregated gaushala-wide totals per day for a month.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: year
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: month
 *         required: true
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 12
 *     responses:
 *       200:
 *         description: Monthly aggregation
 */

/**
 * @swagger
 * /api/production/reports/cow/{animalId}:
 *   get:
 *     summary: Cow Monthly Report
 *     description: Detailed 30-day view for a specific animal.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: animalId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: year
 *         required: true
 *       - in: query
 *         name: month
 *         required: true
 *     responses:
 *       200:
 *         description: Animal performance history
 */

/**
 * @swagger
 * /api/production/reports/distribution:
 *   get:
 *     summary: Distribution Summary
 *     description: Breakdown of milk allocation by category for a period.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *     responses:
 *       200:
 *         description: Allocation summary
 */

/**
 * @swagger
 * /api/production/reports/parity:
 *   get:
 *     summary: Parity Report
 *     description: Yield trends indexed by lactation stats.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Parity performance data
 */
