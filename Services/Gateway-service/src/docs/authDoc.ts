/**
 * @swagger
 * tags:
 *   - name: Auth Service
 *     description: User authentication, registration, profile management, and Gaushala selection.
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
 *       description: Details of the authenticated user.
 *       properties:
 *         id:
 *           type: string
 *           description: Unique user identifier.
 *         mobileNumber:
 *           type: string
 *           description: Registered mobile number (Unique).
 *         name:
 *           type: string
 *           description: User's full name.
 *         city:
 *           type: string
 *           description: User's home city.
 *         language:
 *           type: string
 *           enum: [ENGLISH, GUJARATI, HINDI]
 *           description: User's preferred interface language.
 *         gaushalas:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/UserGaushala'
 *           description: List of gaushalas where the user has a registered role.
 *
 *     Gaushala:
 *       type: object
 *       description: Basic metadata of a Gaushala.
 *       properties:
 *         id:
 *           type: string
 *           description: Unique gaushala identifier.
 *         name:
 *           type: string
 *           description: Display name of the gaushala.
 *         city:
 *           type: string
 *           description: City where the gaushala is located.
 *         totalCattle:
 *           type: integer
 *           description: Total registered cattle count.
 *
 *     UserGaushala:
 *       type: object
 *       description: Representation of a user's membership and role within a specific gaushala.
 *       properties:
 *         id:
 *           type: string
 *           description: Gaushala ID.
 *         name:
 *           type: string
 *           description: Gaushala Name.
 *         role:
 *           type: string
 *           enum: [OWNER, MANAGER, STAFF, VETERINARIAN]
 *           description: User's designated role in this gaushala.
 *         city:
 *           type: string
 *           description: Gaushala City.
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new Gaushala Owner
 *     description: Creates a new user profile and their primary gaushala. The registering user is automatically assigned the 'OWNER' role.
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mobileNumber, password, name, city, gaushalaName]
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *                 description: Unique 10-digit mobile number.
 *               password:
 *                 type: string
 *                 format: password
 *                 example: Password@123
 *                 description: Secure password for login.
 *               name:
 *                 type: string
 *                 example: Neel Raiyani
 *               city:
 *                 type: string
 *                 example: Rajkot
 *               gaushalaName:
 *                 type: string
 *                 example: Gopal Gaushala
 *                 description: Name of the first gaushala to be created.
 *               totalCattle:
 *                 type: integer
 *                 example: 50
 *                 description: Estimated initial cattle count.
 *     responses:
 *       201:
 *         description: User and Gaushala registered successfully.
 *       400:
 *         description: Validation error or mobile number already registered.
 */

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login to the system
 *     description: Authenticates user credentials and returns a JWT token.
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mobileNumber, password]
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *               password:
 *                 type: string
 *                 format: password
 *                 example: Password@123
 *     responses:
 *       200:
 *         description: Login successful. Returns JWT.
 *       401:
 *         description: Invalid mobile number or password.
 */

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Get current user profile
 *     description: Retrieves the full user profile including their memberships across various gaushalas.
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile data retrieved.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       401:
 *         description: Missing or invalid token.
 */

/**
 * @swagger
 * /api/auth/gaushala:
 *   post:
 *     summary: Create an additional Gaushala
 *     description: Creates a new gaushala and links it to the current user as an 'OWNER'.
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, city]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Krishna Gaushala
 *               city:
 *                 type: string
 *                 example: Ahmedabad
 *               totalCattle:
 *                 type: integer
 *                 example: 20
 *     responses:
 *       201:
 *         description: Additional gaushala created.
 *       401:
 *         description: Unauthorized.
 */

/**
 * @swagger
 * /api/auth/gaushala/my:
 *   get:
 *     summary: Get user's gaushalas
 *     description: Returns a list of all gaushalas where the user holds a role (Owner, Manager, Staff, etc.).
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of gaushalas memberships.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/UserGaushala'
 */

/**
 * @swagger
 * /api/auth/forgot-password/send-otp:
 *   post:
 *     summary: Send OTP for password reset
 *     description: Sends a 4-digit verification code to the registered mobile number via SMS.
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mobileNumber]
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *     responses:
 *       200:
 *         description: OTP successfully dispatched.
 *       404:
 *         description: Mobile number not found.
 */

/**
 * @swagger
 * /api/auth/forgot-password/verify:
 *   post:
 *     summary: Verify OTP and Reset Password
 *     description: Validates the 4-digit code and applies the new password to the user account.
 *     tags: [Auth Service]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mobileNumber, otp, newPassword]
 *             properties:
 *               mobileNumber:
 *                 type: string
 *                 example: '9876543210'
 *               otp:
 *                 type: string
 *                 example: '1234'
 *               newPassword:
 *                 type: string
 *                 format: password
 *                 example: NewSecurePassword@123
 *     responses:
 *       200:
 *         description: Password reset complete.
 *       400:
 *         description: Invalid or expired OTP.
 */

/**
 * @swagger
 * /api/auth/change-password:
 *   post:
 *     summary: Force Change Password
 *     description: Securely updates user password by verifying the existing (old) password.
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [oldPassword, newPassword]
 *             properties:
 *               oldPassword:
 *                 type: string
 *                 format: password
 *                 example: Password@123
 *               newPassword:
 *                 type: string
 *                 format: password
 *                 example: ChangedPassword@789
 *     responses:
 *       200:
 *         description: Password updated.
 *       400:
 *         description: Old password verification failed.
 */

/**
 * @swagger
 * /api/auth/settings:
 *   put:
 *     summary: Update gaushala preferences
 *     description: Modifies gaushala-specific settings like default application language. Requires MANAGER or OWNER role.
 *     tags: [Auth Service]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: header
 *         name: gaushala-id
 *         required: true
 *         schema:
 *           type: string
 *         description: Target Gaushala ID.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               language:
 *                 type: string
 *                 example: GUJARATI
 *                 enum: [ENGLISH, GUJARATI, HINDI]
 *     responses:
 *       200:
 *         description: Settings saved.
 *       403:
 *         description: Permission denied for this gaushala.
 */
