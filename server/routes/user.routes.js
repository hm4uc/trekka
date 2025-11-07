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
 *         usr_id:
 *           type: integer
 *           example: 1
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
 *           example: ["adventure", "nature"]
 *         usr_budget:
 *           type: number
 *           example: 5000000
 *         created_at:
 *           type: string
 *           format: date-time
 *         updated_at:
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
 *       required:
 *         - usr_preferences
 *         - usr_budget
 *       properties:
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           example: ["culture", "food", "nature"]
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
 *           example: "Preferences and budget updated"
 *         data:
 *           $ref: "#/components/schemas/User"
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
    body('usr_fullname').optional().trim().isLength({ min: 1, max: 100 }),
    body('usr_gender').optional().isIn(['male', 'female', 'other']),
    body('usr_age').optional().isInt({ min: 1, max: 120 }),
    body('usr_job').optional().isLength({ max: 255 }),
    body('usr_avatar').optional().isURL(),
    body('usr_bio').optional().isLength({ max: 500 }),
];

const preferencesBudgetValidation = [
    body('usr_preferences').optional().isArray(),
    body('usr_budget').optional().isFloat({ min: 0 }),
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
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/PreferencesBudgetRequest"
 *     responses:
 *       200:
 *         description: Preferences and budget updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/PreferencesBudgetResponse"
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */

// Routes
router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, validate(updateProfileValidation), userController.updateProfile);
router.delete('/profile', authenticate, userController.deleteProfile);
router.put('/preferences-budget', authenticate, validate(preferencesBudgetValidation), userController.updatePreferencesAndBudget);

export default router;