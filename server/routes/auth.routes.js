/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           example: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *         usr_fullname:
 *           type: string
 *           example: "Hoang Minh Duc"
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "minhduc@example.com"
 *         usr_gender:
 *           type: string
 *           enum: [male, female, other]
 *           example: "male"
 *         usr_age:
 *           type: integer
 *           example: 25
 *         usr_job:
 *           type: string
 *           example: "Software Engineer"
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           example: ["biển", "núi", "ẩm thực"]
 *         usr_budget:
 *           type: number
 *           format: float
 *           example: 5000000.00
 *         usr_avatar:
 *           type: string
 *           nullable: true
 *           example: null
 *         usr_bio:
 *           type: string
 *           nullable: true
 *           example: null
 *         is_active:
 *           type: boolean
 *           example: true
 *         usr_created_at:
 *           type: string
 *           format: date-time
 *           example: "2024-01-15T10:30:00.000Z"
 *
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
 *           example: "Hoang Minh Duc"
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "minhduc@example.com"
 *         password:
 *           type: string
 *           minLength: 6
 *           example: "12345678"
 *         usr_gender:
 *           type: string
 *           enum: [male, female, other]
 *           example: "male"
 *         usr_age:
 *           type: integer
 *           minimum: 1
 *           maximum: 120
 *           example: 25
 *         usr_job:
 *           type: string
 *           example: "Software Engineer"
 *
 *     LoginRequest:
 *       type: object
 *       required:
 *         - usr_email
 *         - password
 *       properties:
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "minhduc@example.com"
 *         password:
 *           type: string
 *           example: "12345678"
 *
 *     PreferencesBudgetRequest:
 *       type: object
 *       properties:
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           example: ["biển", "núi", "ẩm thực"]
 *         usr_budget:
 *           type: number
 *           format: float
 *           minimum: 0
 *           example: 5000000.00
 *
 *     AuthResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Operation completed successfully"
 *         data:
 *           type: object
 *           properties:
 *             profile:
 *               $ref: '#/components/schemas/User'
 *             token:
 *               type: string
 *               example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *
 *     PreferencesBudgetResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Preferences and budget updated successfully"
 *         data:
 *           type: object
 *           properties:
 *             id:
 *               type: string
 *               format: uuid
 *               example: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *             usr_preferences:
 *               type: array
 *               items:
 *                 type: string
 *               example: ["biển", "núi", "ẩm thực"]
 *             usr_budget:
 *               type: number
 *               format: float
 *               example: 5000000.00
 *
 *     ErrorResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "error"
 *         message:
 *           type: string
 *           example: "Error description"
 *         errors:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               msg:
 *                 type: string
 *               param:
 *                 type: string
 *               location:
 *                 type: string
 *
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: User authentication and profile management APIs
 *   x-order: 1
 *
 * /auth/register:
 *   post:
 *     summary: Register a new user account
 *     description: Create a new user account with basic information. Preferences and budget can be set later.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *           examples:
 *             basicRegistration:
 *               summary: Basic registration
 *               value:
 *                 usr_fullname: "Hoang Minh Duc"
 *                 usr_email: "minhduc@example.com"
 *                 password: "12345678"
 *             fullRegistration:
 *               summary: Full registration
 *               value:
 *                 usr_fullname: "Hoang Minh Duc"
 *                 usr_email: "minhduc@example.com"
 *                 password: "12345678"
 *                 usr_gender: "male"
 *                 usr_age: 25
 *                 usr_job: "Software Engineer"
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *             examples:
 *               successResponse:
 *                 summary: Registration success
 *                 value:
 *                   status: "success"
 *                   message: "Profile registered successfully"
 *                   data:
 *                     profile:
 *                       id: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                       usr_fullname: "Hoang Minh Duc"
 *                       usr_email: "minhduc@example.com"
 *                       usr_gender: "male"
 *                       usr_age: 25
 *                       usr_job: "Software Engineer"
 *                       usr_preferences: []
 *                       usr_budget: null
 *                       usr_avatar: null
 *                       usr_bio: null
 *                       is_active: true
 *                       usr_created_at: "2024-01-15T10:30:00.000Z"
 *                     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Validation error - Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             examples:
 *               validationError:
 *                 summary: Validation failed
 *                 value:
 *                   status: "error"
 *                   message: "Validation failed"
 *                   errors:
 *                     - msg: "Valid email is required"
 *                       param: "usr_email"
 *                       location: "body"
 *                     - msg: "Password must be at least 6 characters"
 *                       param: "password"
 *                       location: "body"
 *       409:
 *         description: Conflict - Email already exists
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "error"
 *                 message:
 *                   type: string
 *                   example: "Email already exists"
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "error"
 *                 message:
 *                   type: string
 *                   example: "Something went wrong"
 *
 * /auth/login:
 *   post:
 *     summary: Login to user account
 *     description: Authenticate user with email and password to receive JWT token
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *           examples:
 *             loginExample:
 *               summary: Login credentials
 *               value:
 *                 usr_email: "minhduc@example.com"
 *                 password: "12345678"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *             examples:
 *               successResponse:
 *                 summary: Login success
 *                 value:
 *                   status: "success"
 *                   message: "Login successful"
 *                   data:
 *                     profile:
 *                       id: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                       usr_fullname: "Hoang Minh Duc"
 *                       usr_email: "minhduc@example.com"
 *                       usr_gender: "male"
 *                       usr_age: 25
 *                       usr_job: "Software Engineer"
 *                       usr_preferences: ["biển", "núi", "ẩm thực"]
 *                       usr_budget: 5000000.00
 *                       usr_avatar: null
 *                       usr_bio: null
 *                       is_active: true
 *                       usr_created_at: "2024-01-15T10:30:00.000Z"
 *                     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       401:
 *         description: Unauthorized - Invalid email or password
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "error"
 *                 message:
 *                   type: string
 *                   example: "Invalid email or password"
 *       500:
 *         description: Internal server error
 *
 * /auth/profile:
 *   get:
 *     summary: Get current user profile
 *     description: Retrieve authenticated user's profile information (requires JWT token)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *             examples:
 *               successResponse:
 *                 summary: Profile data
 *                 value:
 *                   status: "success"
 *                   data:
 *                     id: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                     usr_fullname: "Hoang Minh Duc"
 *                     usr_email: "minhduc@example.com"
 *                     usr_gender: "male"
 *                     usr_age: 25
 *                     usr_job: "Software Engineer"
 *                     usr_preferences: ["biển", "núi", "ẩm thực"]
 *                     usr_budget: 5000000.00
 *                     usr_avatar: null
 *                     usr_bio: null
 *                     is_active: true
 *                     usr_created_at: "2024-01-15T10:30:00.000Z"
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "error"
 *                 message:
 *                   type: string
 *                   example: "Access token is required"
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "error"
 *                 message:
 *                   type: string
 *                   example: "Profile not found"
 *       500:
 *         description: Internal server error
 *
 * /auth/preferences-budget:
 *   post:
 *     summary: Update user travel preferences and budget
 *     description: Set or update user's travel preferences and budget level for trips (requires JWT token)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/PreferencesBudgetRequest'
 *           examples:
 *             preferencesExample:
 *               summary: Update preferences and budget
 *               value:
 *                 usr_preferences: ["biển", "núi", "ẩm thực", "khám phá"]
 *                 usr_budget: 7000000.00
 *             preferencesOnly:
 *               summary: Update preferences only
 *               value:
 *                 usr_preferences: ["biển", "shopping", "văn hóa"]
 *             budgetOnly:
 *               summary: Update budget only
 *               value:
 *                 usr_budget: 3000000.00
 *     responses:
 *       200:
 *         description: Preferences and budget updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PreferencesBudgetResponse'
 *             examples:
 *               successResponse:
 *                 summary: Update success
 *                 value:
 *                   status: "success"
 *                   message: "Preferences and budget updated successfully"
 *                   data:
 *                     id: "71c9e45f-56ab-4f7b-93d7-fb19841e2b2b"
 *                     usr_preferences: ["biển", "núi", "ẩm thực"]
 *                     usr_budget: 5000000.00
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             examples:
 *               validationError:
 *                 summary: Invalid preferences format
 *                 value:
 *                   status: "error"
 *                   message: "Validation failed"
 *                   errors:
 *                     - msg: "Preferences must be an array"
 *                       param: "usr_preferences"
 *                       location: "body"
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */

import express from "express";
import { body, validationResult} from 'express-validator';
import authController from '../controllers/auth.controller.js';
import { authenticate } from '../middleware/authenticate.js';

const router = express.Router();

// Validation middleware
const validate = (validations) => {
    return async (req, res, next) => {
        await Promise.all(validations.map(validation => validation.run(req)));

        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        }

        res.status(400).json({
            status: 'error',
            message: 'Validation failed',
            errors: errors.array()
        });
    };
};

// Validation rules for register (basic info only)
const registerValidation = [
    body('usr_fullname')
        .trim()
        .isLength({ min: 1 })
        .withMessage('Full name is required')
        .isLength({ max: 100 })
        .withMessage('Full name must not exceed 100 characters'),

    body('usr_email')
        .isEmail()
        .withMessage('Valid email is required')
        .normalizeEmail(),

    body('password')
        .isLength({ min: 6 })
        .withMessage('Password must be at least 6 characters')
        .isLength({ max: 255 })
        .withMessage('Password must not exceed 255 characters'),

    body('usr_gender')
        .optional()
        .isIn(['male', 'female', 'other'])
        .withMessage('Gender must be male, female or other'),

    body('usr_age')
        .optional()
        .isInt({ min: 1, max: 120 })
        .withMessage('Age must be between 1 and 120'),

    body('usr_job')
        .optional()
        .isLength({ max: 255 })
        .withMessage('Job must not exceed 255 characters')
];

// Validation rules for login
const loginValidation = [
    body('usr_email')
        .isEmail()
        .withMessage('Valid email is required')
        .normalizeEmail(),

    body('password')
        .notEmpty()
        .withMessage('Password is required')
];

// Validation rules for preferences and budget
const preferencesBudgetValidation = [
    body('usr_preferences')
        .optional()
        .isArray()
        .withMessage('Preferences must be an array'),

    body('usr_budget')
        .optional()
        .isFloat({ min: 0 })
        .withMessage('Budget must be a positive number')
];

// Routes
router.post('/register', validate(registerValidation), authController.register);
router.post('/login', validate(loginValidation), authController.login);
router.get('/profile', authenticate, authController.getProfile);
router.post('/preferences-budget', authenticate, validate(preferencesBudgetValidation), authController.updatePreferencesAndBudget);

export default router;