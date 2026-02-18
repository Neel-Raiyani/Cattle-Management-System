/**
 * @swagger
 * tags:
 *   - name: Auth Service
 *     description: User authentication and management (Auth-service via Gateway)
 *
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         mobileNumber:
 *           type: string
 *         name:
 *           type: string
 *         city:
 *           type: string
 *         gaushalaName:
 *           type: string
 *         totalCattle:
 *           type: integer
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new Gaushala Owner
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *               password:
 *                 type: string
 *                 example: Password@123
 *               name:
 *                 type: string
 *                 example: Neel Raiyani
 *               city:
 *                 type: string
 *                 example: Rajkot
 *               gaushalaName:
 *                 type: string
 *                 example: Gopal Gaushala
 *               totalCattle:
 *                 type: integer
 *                 example: 50
 *     responses:
 *       201:
 *         description: User registered successfully
 *       400:
 *         description: Bad request / User already exists
 */

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login to the system
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *               password:
 *                 type: string
 *                 example: Password@123
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Get current user profile
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile retrieved successfully
 *       401:
 *         description: Unauthorized
 */

/**
 * @swagger
 * /api/auth/forgot-password/send-otp:
 *   post:
 *     summary: Send 4-digit OTP for password reset
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *     responses:
 *       200:
 *         description: OTP sent successfully
 */

/**
 * @swagger
 * /api/auth/forgot-password/verify:
 *   post:
 *     summary: Verify OTP and reset password
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *               otp:
 *                 type: string
 *                 example: '1234'
 *               newPassword:
 *                 type: string
 *                 example: NewSecurePassword@123
 *     responses:
 *       200:
 *         description: Password reset successful
 *       400:
 *         description: Invalid/Expired OTP
 */

/**
 * @swagger
 * /api/auth/change-password:
 *   post:
 *     summary: Change password for logged-in user
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               oldPassword:
 *                 type: string
 *                 example: Password@123
 *               newPassword:
 *                 type: string
 *                 example: ChangedPassword@789
 *     responses:
 *       200:
 *         description: Password changed successfully
 *       400:
 *         description: Incorrect old password
 */

/**
 * @swagger
 * /api/auth/settings:
 *   put:
 *     summary: Update user settings (Language/Units)
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               languagePreference:
 *                 type: string
 *                 example: GU
 *                 enum: [EN, GU, HI]
 *               unitPreference:
 *                 type: string
 *                 example: Kg
 *                 enum: [Ltr, Kg]
 *     responses:
 *       200:
 *         description: Settings updated successfully
 *       403:
 *         description: Forbidden (Role mismatch)
 */
