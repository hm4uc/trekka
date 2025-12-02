/**
 * @swagger
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *
 *   schemas:
 *
 *     User:
 *       type: object
 *       description: Full user profile information
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
 *           example: "duc@gmail.com"
 *         usr_gender:
 *           type: string
 *           example: "male"
 *         usr_age:
 *           type: integer
 *           example: 25
 *         usr_job:
 *           type: string
 *           example: "Mobile Developer"
 *         usr_avatar:
 *           type: string
 *           example: "https://example.com/avatar.png"
 *         usr_bio:
 *           type: string
 *           example: "Love exploring new places"
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           example: ["Du lịch khám phá", "Du lịch ẩm thực"]
 *         usr_budget:
 *           type: number
 *           example: 5000000
 *         is_active:
 *           type: boolean
 *           example: true
 *         usr_created_at:
 *           type: string
 *           format: date-time
 *         usr_updated_at:
 *           type: string
 *           format: date-time
 *
 *     UpdateProfileRequest:
 *       type: object
 *       properties:
 *         usr_fullname:
 *           type: string
 *           example: "Hoang Minh Duc Updated"
 *         usr_gender:
 *           type: string
 *           enum: [male, female, other]
 *           example: "male"
 *         usr_age:
 *           type: integer
 *           example: 26
 *         usr_job:
 *           type: string
 *           example: "Senior Software Engineer"
 *         usr_avatar:
 *           type: string
 *           example: "https://example.com/avatar.jpg"
 *         usr_bio:
 *           type: string
 *           example: "Love traveling and exploring new cultures"
 *
 *     DeleteProfileResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Profile deleted successfully"
 *
 *     PreferencesBudgetRequest:
 *       type: object
 *       properties:
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           example: ["Du lịch văn hóa", "Du lịch ẩm thực", "Du lịch sinh thái"]
 *         usr_budget:
 *           type: number
 *           example: 3000000
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
 *             usr_preferences:
 *               type: array
 *               items:
 *                 type: string
 *             usr_budget:
 *               type: number
 *             travel_styles:
 *               type: array
 *               items:
 *                 type: string
 *             budget_levels:
 *               type: object
 *
 *     TravelConstantsResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         data:
 *           type: object
 *           properties:
 *             travel_styles:
 *               type: array
 *               items:
 *                 type: string
 *               example: ["Du lịch nghỉ dưỡng", "Du lịch khám phá", "Du lịch mạo hiểm"]
 *             budget_levels:
 *               type: object
 *               properties:
 *                 LOW:
 *                   type: object
 *                   properties:
 *                     min:
 *                       type: number
 *                     max:
 *                       type: number
 *                     label:
 *                       type: string
 *                 MEDIUM:
 *                   type: object
 *                 HIGH:
 *                   type: object
 *                 LUXURY:
 *                   type: object
 */

/**
 * @swagger
 * tags:
 *   name: User
 *   description: User profile management APIs
 *   x-order: 2
 */

import express from "express";
import { body, validationResult } from 'express-validator';
import userController from '../controllers/user.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import {BUDGET_CONFIG, TRAVEL_STYLES} from '../config/travelConstants.js';

const router = express.Router();

// Validation middleware
const validate = (validations) => {
    return async (req, res, next) => {
        await Promise.all(validations.map(v => v.run(req)));

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                status: "error",
                message: "Validation failed",
                errors: errors.array()
            });
        }
        next();
    };
};

// Validation rules
const updateProfileValidation = [
    body('usr_fullname').optional().trim().isLength({ min: 1, max: 100 })
        .withMessage('Full name must be between 1 and 100 characters'),
    body('usr_gender').optional().isIn(['male', 'female', 'other'])
        .withMessage('Gender must be male, female or other'),
    body('usr_age').optional().isInt({ min: 1, max: 120 })
        .withMessage('Age must be between 1 and 120'),
    body('usr_job').optional().isLength({ max: 255 })
        .withMessage('Job must not exceed 255 characters'),
    body('usr_avatar').optional().isURL()
        .withMessage('Avatar must be a valid URL'),
    body('usr_bio').optional().isLength({ max: 500 })
        .withMessage('Bio must not exceed 500 characters'),
];

const preferencesBudgetValidation = [
    body('usr_preferences').optional().isArray()
        .withMessage('Preferences must be an array')
        .custom((value) => {
            if (value) {
                const invalidPreferences = value.filter(pref => !TRAVEL_STYLES.includes(pref));
                if (invalidPreferences.length > 0) {
                    throw new Error(`Invalid travel styles: ${invalidPreferences.join(', ')}`);
                }
            }
            return true;
        }),
    body('usr_budget').optional()
        .isFloat({ min: BUDGET_CONFIG.MIN, max: BUDGET_CONFIG.MAX })
        .withMessage(`Budget must be between ${BUDGET_CONFIG.MIN} and ${BUDGET_CONFIG.MAX}`),
];

/**
 * @swagger
 * /user/profile:
 *   get:
 *     summary: Get current user profile
 *     description: Retrieve authenticated user's profile (JWT required)
 *     tags: [User]
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
 *                   $ref: "#/components/schemas/User"
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 *
 *   put:
 *     summary: Update user profile
 *     description: Update authenticated user's profile (JWT required)
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/UpdateProfileRequest"
 *     responses:
 *       200:
 *         description: Profile updated successfully
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
 *                   example: "Profile updated successfully"
 *                 data:
 *                   $ref: "#/components/schemas/User"
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 *
 *   delete:
 *     summary: Delete user profile
 *     description: Permanently delete user account (JWT required)
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/DeleteProfileResponse"
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */

/**
 * @swagger
 * /user/preferences-budget:
 *   put:
 *     summary: Update travel preferences and budget
 *     description: Update user's travel preferences (must be from predefined list) and budget
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/PreferencesBudgetRequest"
 *           examples:
 *             example1:
 *               summary: Update preferences and budget
 *               value:
 *                 usr_preferences: ["Du lịch khám phá", "Du lịch ẩm thực", "Du lịch sinh thái"]
 *                 usr_budget: 5000000
 *             example2:
 *               summary: Update only preferences
 *               value:
 *                 usr_preferences: ["Du lịch nghỉ dưỡng", "Du lịch gia đình"]
 *     responses:
 *       200:
 *         description: Preferences and budget updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/PreferencesBudgetResponse"
 *       400:
 *         description: Validation error - Invalid travel style or budget
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */

/**
 * @swagger
 * /user/travel-constants:
 *   get:
 *     summary: Get available travel styles and budget levels
 *     description: Retrieve predefined list of travel styles and budget levels for UI dropdowns
 *     tags: [User]
 *     responses:
 *       200:
 *         description: Travel constants retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/TravelConstantsResponse"
 *       500:
 *         description: Internal server error
 */

// Routes
router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, validate(updateProfileValidation), userController.updateProfile);
router.delete('/profile', authenticate, userController.deleteProfile);
router.put('/preferences-budget', authenticate, validate(preferencesBudgetValidation), userController.updatePreferencesAndBudget);
router.get('/travel-constants', userController.getTravelConstants);

export default router;