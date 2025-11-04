/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: API cho đăng ký, đăng nhập và xác thực người dùng
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

// Cập nhật validation rules
const registerValidation = [
    body('usr_fullname').trim().isLength({ min: 1 }).withMessage('Full name is required'),
    body('usr_email').isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('usr_gender').optional().isIn(['male', 'female', 'other']).withMessage('Gender must be male, female or other'),
    body('usr_age').optional().isInt({ min: 1, max: 120 }).withMessage('Age must be between 1 and 120'),
    body('usr_budget').optional().isFloat({ min: 0 }).withMessage('Budget must be a positive number')
];

const loginValidation = [
    body('usr_email').isEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required')
];

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Đăng ký tài khoản người dùng mới
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - usr_fullname
 *               - usr_email
 *               - password
 *             properties:
 *               usr_fullname:
 *                 type: string
 *                 example: Hoang Minh Duc
 *               usr_email:
 *                 type: string
 *                 example: minhduc@example.com
 *               password:
 *                 type: string
 *                 example: 12345678
 *               usr_gender:
 *                 type: string
 *                 enum: [male, female, other]
 *                 example: male
 *               usr_age:
 *                 type: integer
 *                 example: 25
 *               usr_job:
 *                 type: string
 *                 example: Software Engineer
 *               usr_preferences:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["biển", "núi", "ẩm thực"]
 *               usr_budget:
 *                 type: number
 *                 format: float
 *                 example: 5000000.00
 *     responses:
 *       201:
 *         description: Tạo tài khoản thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: Profile registered successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     profile:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: string
 *                           example: 71c9e45f-56ab-4f7b-93d7-fb19841e2b2b
 *                         usr_fullname:
 *                           type: string
 *                           example: Hoang Minh Duc
 *                         usr_email:
 *                           type: string
 *                           example: minhduc@example.com
 *                         usr_gender:
 *                           type: string
 *                           example: male
 *                         usr_age:
 *                           type: integer
 *                           example: 25
 *                         usr_job:
 *                           type: string
 *                           example: Software Engineer
 *                         usr_preferences:
 *                           type: array
 *                           items:
 *                             type: string
 *                           example: ["biển", "núi", "ẩm thực"]
 *                         usr_budget:
 *                           type: number
 *                           format: float
 *                           example: 5000000.00
 *                         usr_avatar:
 *                           type: string
 *                           example: null
 *                         usr_bio:
 *                           type: string
 *                           example: null
 *                         is_active:
 *                           type: boolean
 *                           example: true
 *                         usr_created_at:
 *                           type: string
 *                           format: date-time
 *                     token:
 *                       type: string
 *                       example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *       400:
 *         description: Dữ liệu không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: error
 *                 message:
 *                   type: string
 *                   example: Validation failed
 *                 errors:
 *                   type: array
 *                   items:
 *                     type: object
 *       409:
 *         description: Email đã tồn tại
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: error
 *                 message:
 *                   type: string
 *                   example: Email already exists
 */

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Đăng nhập tài khoản
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - usr_email
 *               - password
 *             properties:
 *               usr_email:
 *                 type: string
 *                 example: minhduc@example.com
 *               password:
 *                 type: string
 *                 example: 12345678
 *     responses:
 *       200:
 *         description: Đăng nhập thành công và nhận token JWT
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     profile:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: string
 *                           example: 71c9e45f-56ab-4f7b-93d7-fb19841e2b2b
 *                         usr_fullname:
 *                           type: string
 *                           example: Hoang Minh Duc
 *                         usr_email:
 *                           type: string
 *                           example: minhduc@example.com
 *                     token:
 *                       type: string
 *                       example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *       401:
 *         description: Email hoặc mật khẩu sai
 */

/**
 * @swagger
 * /auth/profile:
 *   get:
 *     summary: Lấy thông tin người dùng hiện tại
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Trả về thông tin người dùng đã xác thực
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   example: 71c9e45f-56ab-4f7b-93d7-fb19841e2b2b
 *                 name:
 *                   type: string
 *                   example: Hoang Minh Duc
 *                 email:
 *                   type: string
 *                   example: minhduc@example.com
 *       401:
 *         description: Không có hoặc token không hợp lệ
 */

// Routes
router.post('/register', validate(registerValidation), authController.register);
router.post('/login', validate(loginValidation), authController.login);
router.get('/profile', authenticate, authController.getProfile);

export default router;