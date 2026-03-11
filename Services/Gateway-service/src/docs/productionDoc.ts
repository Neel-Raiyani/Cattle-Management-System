/**
 * @swagger
 * tags:
 *   - name: Production Service
 *     description: Milk production tracking, inventory management, and allocation via the Gateway.
 *
 * components:
 *   schemas:
 *     MilkDistributionCategory:
 *       type: object
 *       description: Logical category for milk allocation (e.g., Home, Sell, Calf).
 *       required: [name]
 *       properties:
 *         id:
 *           type: string
 *         name:
 *           type: string
 *           minLength: 1
 *           example: 'Commercial Sale'
 *
 *     FeedInventory:
 *       type: object
 *       description: Tracking of cattle feed stock levels.
 *       required: [feedName, quantity, unit]
 *       properties:
 *         id:
 *           type: string
 *         feedName:
 *           type: string
 *           minLength: 1
 *           example: 'Maize Silage'
 *         quantity:
 *           type: number
 *           minimum: 0
 *           example: 500
 *         unit:
 *           type: string
 *           enum: [KG, TON, BAG]
 *           example: KG
 *         lastUpdated:
 *           type: string
 *           format: date
 *
 *     MilkRecord:
 *       type: object
 *       description: Daily milk yield entry for an individual animal.
 *       required: [animalId, date, morning, evening]
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
 *           minimum: 0
 *           description: Yield in Liters.
 *         feedQuantity:
 *           type: number
 *           minimum: 0
 *           description: Feed consumed in Kg.
 *         total:
 *           type: number
 *           description: Read-only; calculated sum.
 *
 *     DistributionRecord:
 *       type: object
 *       description: Allocation of daily milk yield to a specific category.
 *       required: [categoryId, date, amount]
 *       properties:
 *         id:
 *           type: string
 *         categoryId:
 *           type: string
 *           format: mongo-id
 *         date:
 *           type: string
 *           format: date
 *         amount:
 *           type: number
 *           minimum: 0
 *           description: Amount allocated in Liters.
 *         remarks:
 *           type: string
 */

// ───────────────────────── Categories ─────────────────────────

/**
 * @swagger
 * /api/production/categories:
 *   get:
 *     summary: List distribution categories
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Category list.
 *   post:
 *     summary: Create milk category
 *     tags: [Production Service]
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
 *             $ref: '#/components/schemas/MilkDistributionCategory'
 *     responses:
 *       201:
 *         description: Category added.
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
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 1
 *     responses:
 *       200:
 *         description: Category updated.
 *   delete:
 *     summary: Remove distribution category
 *     tags: [Production Service]
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

// ───────────────────────── Inventory ─────────────────────────

/**
 * @swagger
 * /api/production/inventory:
 *   get:
 *     summary: View feed stock
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Inventory list.
 */

/**
 * @swagger
 * /api/production/inventory/update:
 *   post:
 *     summary: Add/Update feed stock
 *     description: Upserts feed inventory based on name.
 *     tags: [Production Service]
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
 *             $ref: '#/components/schemas/FeedInventory'
 *     responses:
 *       201:
 *         description: Stock updated.
 */

// ───────────────────────── Milking / Production ─────────────────────────

/**
 * @swagger
 * /api/production/yields:
 *   get:
 *     summary: List daily yields
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
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
 *         description: History retrieved.
 */

/**
 * @swagger
 * /api/production/yields/bulk:
 *   post:
 *     summary: Bulk milk logging
 *     description: Records yields for multiple animals for a specific date.
 *     tags: [Production Service]
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
 *             type: object
 *             required: [date, session, entries]
 *             properties:
 *               date:
 *                 type: string
 *                 format: date
 *               session:
 *                 type: string
 *                 enum: [MORNING, EVENING]
 *                 description: Milking session identifier.
 *               entries:
 *                 type: array
 *                 minItems: 1
 *                 items:
 *                   type: object
 *                   required: [animalId, quantity, feedQuantity]
 *                   properties:
 *                     animalId:
 *                       type: string
 *                       format: mongo-id
 *                     quantity:
 *                       type: number
 *                       minimum: 0
 *                       description: Milk yield in Liters.
 *                     feedQuantity:
 *                       type: number
 *                       minimum: 0
 *                       description: Feed consumed in Kg.
 *     responses:
 *       201:
 *         description: Records saved.
 */

/**
 * @swagger
 * /api/production/yields/{id}:
 *   patch:
 *     summary: Update yield entry
 *     tags: [Production Service]
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
 *         description: Updated.
 *   delete:
 *     summary: Remove yield entry
 *     tags: [Production Service]
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

// ───────────────────────── Distribution ─────────────────────────

/**
 * @swagger
 * /api/production/distribution:
 *   post:
 *     summary: Allocate milk
 *     description: Assigns a quantity of the day's total harvest to a specific purpose.
 *     tags: [Production Service]
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
 *             $ref: '#/components/schemas/DistributionRecord'
 *     responses:
 *       201:
 *         description: Allocation saved.
 *   get:
 *     summary: List allocations
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: List retrieved.
 */

/**
 * @swagger
 * /api/production/distribution/{id}:
 *   patch:
 *     summary: Correct allocation
 *     tags: [Production Service]
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
 *             properties:
 *               amount:
 *                 type: number
 *               remarks:
 *                 type: string
 *     responses:
 *       200:
 *         description: Updated.
 *   delete:
 *     summary: Remove allocation
 *     tags: [Production Service]
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
 *         description: Removed.
 */

// ───────────────────────── Reports ─────────────────────────

/**
 * @swagger
 * /api/production/reports/daily:
 *   get:
 *     summary: Daily production summary
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *     responses:
 *       200:
 *         description: Totals for the day.
 */

/**
 * @swagger
 * /api/production/reports/monthly:
 *   get:
 *     summary: Monthly production trends
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: month
 *         required: true
 *         description: Month number (1-12)
 *       - in: query
 *         name: year
 *         required: true
 *     responses:
 *       200:
 *         description: Monthly aggregate data.
 */

/**
 * @swagger
 * /api/production/reports/cow/{animalId}:
 *   get:
 *     summary: Individual production history
 *     tags: [Production Service]
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
 *         description: Animal-wise yield data.
 */

/**
 * @swagger
 * /api/production/reports/distribution:
 *   get:
 *     summary: Allocation breakdown report
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *       - in: query
 *         name: startDate
 *       - in: query
 *         name: endDate
 *     responses:
 *       200:
 *         description: Category-wise distribution totals.
 */

/**
 * @swagger
 * /api/production/reports/parity:
 *   get:
 *     summary: Yield by parity report
 *     description: Compares milk production performance based on the cow's parity (1st calf vs 5th calf).
 *     tags: [Production Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *     responses:
 *       200:
 *         description: Parity performance metrics.
 */
