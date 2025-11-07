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
 *           example: "Nguyen Van A"
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "example@gmail.com"
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
 *           example: 22
 *         usr_job:
 *           type: string
 *           example: "Software Engineer"
 *     LoginRequest:
 *       type: object
 *       required:
 *         - usr_email
 *         - password
 *       properties:
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "example@gmail.com"
 *         password:
 *           type: string
 *           example: "12345678"
 *
 *     UserObject:
 *       type: object
 *       properties:
 *         usr_id:
 *           type: integer
 *           example: 1
 *         usr_fullname:
 *           type: string
 *           example: "Nguyen Van A"
 *         usr_email:
 *           type: string
 *           format: email
 *           example: "example@gmail.com"
 *         usr_gender:
 *           type: string
 *           example: "male"
 *         usr_age:
 *           type: integer
 *           example: 22
 *         usr_job:
 *           type: string
 *           example: "Designer"
 *         usr_travel_style:
 *           type: array
 *           items:
 *             type: string
 *           example: ["adventure", "culture"]
 *         usr_budget:
 *           type: integer
 *           example: 2000000
 *     AuthResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Login successful"
 *         token:
 *           type: string
 *           description: JWT token
 *         user:
 *           $ref: '#/components/schemas/UserObject'
 */

import express from "express";
import { body, validationResult } from 'express-validator';
import authController from '../controllers/auth.controller.js';

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
    body('usr_age').optional().isInt({ min: 1, max: 120 }),
    body('usr_job').optional().isLength({ max: 255 })
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
 *     description: Create a new user account with basic information.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Validation failed
 *       409:
 *         description: Email already exists
 *       500:
 *         description: Internal server error
 */
router.post('/register', validate(registerValidation), authController.register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login to user account
 *     description: Authenticate user with email and password to receive JWT token.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Validation failed
 *       401:
 *         description: Invalid email or password
 *       500:
 *         description: Internal server error
 */
router.post('/login', validate(loginValidation), authController.login);

export default router;
