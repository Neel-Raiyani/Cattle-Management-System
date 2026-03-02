/**
 * @swagger
 * tags:
 *   - name: Production Service
 *     description: Management of milk yields, distribution categories, and feed inventory tracking.
 *
 * components:
 *   schemas:
 *     MilkDistributionCategory:
 *       type: object
 *       description: Destination category for milk distribution (e.g. Sales, Home, Staff).
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
 *       description: Live stock level for animal feed.
 *       properties:
 *         gaushalaId:
 *           type: string
 *         totalQuantity:
 *           type: number
 *           description: Current remaining stock (Kg).
 *           example: 500.5
 *
 *     MilkRecord:
 *       type: object
 *       description: Individual milking event for a cow and session.
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
 *           description: Date of milking.
 *         session:
 *           type: string
 *           enum: [MORNING, EVENING]
 *         quantity:
 *           type: number
 *           description: Milk produced (Liters).
 *         feedQuantity:
 *           type: number
 *           description: Feed consumed during this milking (Kg).
 *
 *     DistributionRecord:
 *       type: object
 *       description: Documentation of milk allocation from the gaushala pool.
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
 *           description: ID of target category (e.g., Sales).
 *         quantity:
 *           type: number
 *           description: Total milk allocated (Liters).
 */

// ───────────────────────── Categories ─────────────────────────

/**
 * @swagger
 * /api/production/categories:
 *   get:
 *     summary: List distribution destinations
 *     description: Retrieves all categories defined for milk allocation in the gaushala.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Category collection.
 *   post:
 *     summary: Define new allocation category
 *     description: Creates a new logical destination for milk distribution.
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
 *                 example: Local Market Sales
 *     responses:
 *       201:
 *         description: Category created.
 */

/**
 * @swagger
 * /api/production/categories/{id}:
 *   patch:
 *     summary: Rename category
 *     tags: [Production Service]
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
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *     responses:
 *       200:
 *         description: Updated.
 *   delete:
 *     summary: Remove category
 *     description: "Warning: Only categories without historical data should be deleted."
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Category removed.
 */

// ───────────────────────── Inventory ─────────────────────────

/**
 * @swagger
 * /api/production/inventory:
 *   get:
 *     summary: Current Feed Situation
 *     description: Returns the total current quantity of feed available in the gaushala warehouse.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Inventory snapshot in Kg.
 */

/**
 * @swagger
 * /api/production/inventory/update:
 *   post:
 *     summary: Refill Feed Stock
 *     description: Adds or corrects the current feed inventory level.
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
 *                 description: Amount in Kg (Decimal supported).
 *               description:
 *                 type: string
 *                 example: New procurement from ABC Mills.
 *     responses:
 *       200:
 *         description: Stock level updated.
 */

// ───────────────────────── Yields / Production ─────────────────────────

/**
 * @swagger
 * /api/production/yields:
 *   post:
 *     summary: Batch Milk & Feed Entry
 *     description: Efficiency-focused endpoint to record yields for multiple animals at once. Automatically deducts the entered feedQuantity from FeedInventory.
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
 *                       description: Milk in Liters.
 *                     feedQuantity:
 *                       type: number
 *                       description: Feed in Kg consumed by this cow during milking.
 *     responses:
 *       201:
 *         description: Session yields recorded.
 *   get:
 *     summary: List session yields
 *     description: Retrieves all individual milk entries for a specific gaushala on a given date and session.
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
 *         description: Production list.
 */

/**
 * @swagger
 * /api/production/yields/{id}:
 *   patch:
 *     summary: Correct yield entry
 *     tags: [Production Service]
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
 *             type: object
 *             properties:
 *               quantity:
 *                 type: number
 *               feedQuantity:
 *                 type: number
 *     responses:
 *       200:
 *         description: Re-saved and inventory adjusted.
 *   delete:
 *     summary: Remove yield record
 *     description: Deletes record and reverses the inventory deduction.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Deleted.
 */

// ───────────────────────── Distribution ─────────────────────────

/**
 * @swagger
 * /api/production/distribution:
 *   post:
 *     summary: Allocate produced milk
 *     description: Records the usage or sale of accumulated milk into specific categories.
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
 *         description: Distribution archived.
 *   get:
 *     summary: Filter distribution records
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: date
 *       - in: query
 *         name: session
 *     responses:
 *       200:
 *         description: Allocation list.
 */

// ───────────────────────── Reports ─────────────────────────

/**
 * @swagger
 * /api/production/reports/daily:
 *   get:
 *     summary: Session performance summary
 *     description: Returns gaushala-wide totals for production vs consumption for a specific day.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: date
 *         required: true
 *     responses:
 *       200:
 *         description: Daily totals.
 */

/**
 * @swagger
 * /api/production/reports/monthly:
 *   get:
 *     summary: Monthly dashboard data
 *     description: Aggregates gaushala production totals daily for an entire month (Calendar view data).
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: year
 *         required: true
 *       - in: query
 *         name: month
 *         required: true
 *     responses:
 *       200:
 *         description: Monthly aggregation data.
 */

/**
 * @swagger
 * /api/production/reports/cow/{animalId}:
 *   get:
 *     summary: Cow performance history
 *     description: Provides a detailed 30-day performance view for a single cow within the specified month.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: animalId
 *         in: path
 *         required: true
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: year
 *         required: true
 *       - in: query
 *         name: month
 *         required: true
 *     responses:
 *       200:
 *         description: Individual performance data.
 */

/**
 * @swagger
 * /api/production/reports/distribution:
 *   get:
 *     summary: Distribution breakdown
 *     description: Aggregates distribution records by category over a date range.
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *       - in: query
 *         name: startDate
 *       - in: query
 *         name: endDate
 *     responses:
 *       200:
 *         description: Summary report.
 */

/**
 * @swagger
 * /api/production/reports/parity:
 *   get:
 *     summary: Parity Correlation Report
 *     description: Analyzes milk yield trends against animal parity numbers (e.g. comparing 1st vs 3rd lactation yields).
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - $ref: '#/components/parameters/GaushalaIdHeader'
 *     responses:
 *       200:
 *         description: Parity performance metrics.
 */
