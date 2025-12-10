/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: User authentication APIs
 *   x-order: 1
 */

/**
 * @swagger
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *       description: JWT token obtained from login endpoint
 *   schemas:
 *     RegisterRequest:
 *       type: object
 *       required:
 *         - usr_fullname
 *         - usr_email
 *         - password
 *       properties:
 *         usr_fullname:
 *           type: string
 *           minLength: 1
 *           maxLength: 100
 *           description: Full name of the user
 *           example: "Nguyen Van A"
 *         usr_email:
 *           type: string
 *           format: email
 *           description: Valid email address
 *           example: "example@gmail.com"
 *         password:
 *           type: string
 *           minLength: 6
 *           maxLength: 255
 *           description: User password (will be hashed)
 *           example: "12345678"
 *         usr_gender:
 *           type: string
 *           enum: [male, female, other]
 *           description: User gender (optional)
 *           example: "male"
 *         usr_age_group:
 *           type: string
 *           enum: ["15-25", "26-35", "36-50", "50+"]
 *           description: User age group (optional)
 *           example: "15-25"
 *         usr_age:
 *           type: integer
 *           minimum: 15
 *           maximum: 150
 *           description: User age (optional)
 *           example: 22
 *         usr_job:
 *           type: string
 *           enum: ["student", "teacher", "engineer", "doctor", "nurse", "accountant", "lawyer", "artist", "designer", "developer", "manager", "entrepreneur", "freelancer", "marketing", "sales", "consultant", "researcher", "writer", "chef", "photographer", "pilot"]
 *           description: User job (optional)
 *           example: "student"
 *     LoginRequest:
 *       type: object
 *       required:
 *         - usr_email
 *         - password
 *       properties:
 *         usr_email:
 *           type: string
 *           format: email
 *           description: User's registered email
 *           example: "example@gmail.com"
 *         password:
 *           type: string
 *           description: User's password
 *           example: "12345678"
 *
 *     UserObject:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: Unique user profile ID
 *           example: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *         usr_fullname:
 *           type: string
 *           description: User's full name
 *           example: "Nguyen Van A"
 *         usr_email:
 *           type: string
 *           format: email
 *           description: User's email address
 *           example: "example@gmail.com"
 *         usr_gender:
 *           type: string
 *           description: User's gender
 *           example: "male"
 *         usr_age_group:
 *           type: string
 *           description: User's age group
 *           example: "15-25"
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           description: User's travel style preferences
 *           example: ["nature", "culture_history"]
 *         usr_budget:
 *           type: number
 *           description: User's travel budget in VND
 *           example: 2000000
 *         usr_avatar:
 *           type: string
 *           description: User's avatar URL
 *           example: "https://example.com/avatar.jpg"
 *         usr_bio:
 *           type: string
 *           description: User's biography
 *           example: "Love traveling and exploring new cultures"
 *         is_active:
 *           type: boolean
 *           description: Whether the user account is active
 *           example: true
 *         usr_created_at:
 *           type: string
 *           format: date-time
 *           description: Account creation timestamp
 *         usr_updated_at:
 *           type: string
 *           format: date-time
 *           description: Last update timestamp
 *     AuthResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Login successful"
 *         data:
 *           type: object
 *           properties:
 *             token:
 *               type: string
 *               description: JWT authentication token (valid for 7 days)
 *               example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *             profile:
 *               $ref: '#/components/schemas/UserObject'
 *     RegisterResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Profile registered successfully"
 *         data:
 *           $ref: '#/components/schemas/AuthResponse/properties/data'
 *     ErrorResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "error"
 *         message:
 *           type: string
 *           description: Error message
 *           example: "An error occurred"
 *     ValidationErrorResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "error"
 *         message:
 *           type: string
 *           example: "Validation failed"
 *         errors:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               msg:
 *                 type: string
 *                 description: Validation error message
 *               param:
 *                 type: string
 *                 description: Field that failed validation
 *               location:
 *                 type: string
 *                 description: Location of the parameter (body, query, etc.)
 */

import express from "express";
import { body, validationResult } from 'express-validator';
import authController from '../controllers/auth.controller.js';
import { AGE_GROUPS, JOBS, AGE_MAX, AGE_MIN } from "../config/travelConstants.js";
import { authenticate } from "../middleware/authenticate.js";

const router = express.Router();

// Validation middleware
const validate = (validations) => {
    return async (req, res, next) => {
        await Promise.all(validations.map(v => v.run(req)));

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                status: 'error',
                message: 'Validation failed',
                errors: errors.array()
            });
        }
        next();
    };
};

// Validation rules
const registerValidation = [
    body('usr_fullname').trim().isLength({ min: 1, max: 100 }),
    body('usr_email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6, max: 255 }),
    body('usr_gender').optional().isIn(['male', 'female', 'other']),
    body('usr_age_group').optional().isIn(AGE_GROUPS).withMessage('Invalid age group'),
    body('usr_age').optional().isInt({
        min: AGE_MIN,
        max: AGE_MAX
    }).withMessage(`Age must be between ${AGE_MIN} and ${AGE_MAX}`),
    body('usr_job').optional().isIn(JOBS).withMessage(`Job must be one of: ${JOBS.join(', ')}`)
];

const loginValidation = [
    body('usr_email').isEmail().normalizeEmail(),
    body('password').notEmpty()
];

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user account
 *     description: |
 *       Create a new user account with basic information.
 *       Upon successful registration, returns user profile and JWT token.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *           examples:
 *             basicUser:
 *               summary: Basic user registration
 *               value:
 *                 usr_fullname: "Nguyen Van A"
 *                 usr_email: "example@gmail.com"
 *                 password: "12345678"
 *             fullUser:
 *               summary: User with all fields
 *               value:
 *                 usr_fullname: "Nguyen Thi B"
 *                 usr_email: "user@example.com"
 *                 password: "securePassword123"
 *                 usr_gender: "female"
 *                 usr_age_group: "26-35"
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RegisterResponse'
 *       400:
 *         description: Validation failed - Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationErrorResponse'
 *       409:
 *         description: Conflict - Email already exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/register', validate(registerValidation), authController.register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login to user account
 *     description: |
 *       Authenticate user with email and password to receive JWT token.
 *       The JWT token should be included in the Authorization header
 *       for subsequent authenticated requests as 'Bearer {token}'.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *           examples:
 *             validLogin:
 *               summary: Valid login credentials
 *               value:
 *                 usr_email: "example@gmail.com"
 *                 password: "12345678"
 *     responses:
 *       200:
 *         description: Login successful - Returns JWT token and user profile
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Validation failed - Invalid input format
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationErrorResponse'
 *       401:
 *         description: Unauthorized - Invalid email or password
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/login', validate(loginValidation), authController.login);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout from current device
 *     description: |
 *       Invalidates the current JWT token by adding it to a blacklist.
 *       The token will no longer be accepted for authentication.
 *       Requires a valid JWT token in the Authorization header.
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logged out successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Logged out successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     profileId:
 *                       type: string
 *                       format: uuid
 *                       example: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                     timestamp:
 *                       type: string
 *                       format: date-time
 *                       example: "2025-12-04T10:30:00.000Z"
 *       401:
 *         description: Unauthorized - Invalid, expired, or missing token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @swagger
 * /auth/logout-all-devices:
 *   post:
 *     summary: Logout from all devices
 *     description: |
 *       Invalidates the current JWT token and marks the account for security logout.
 *       This is useful when a user wants to log out from all devices for security reasons.
 *       Note: Due to the stateless nature of JWT, this only blacklists the current token.
 *       For complete security, consider implementing refresh token rotation or reducing token expiration time.
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logged out from all devices successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Logged out from all devices successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     profileId:
 *                       type: string
 *                       format: uuid
 *                       example: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                     timestamp:
 *                       type: string
 *                       format: date-time
 *                       example: "2025-12-04T10:30:00.000Z"
 *       401:
 *         description: Unauthorized - Invalid, expired, or missing token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/logout-all-devices', authenticate, authController.logoutAllDevices);

export default router;