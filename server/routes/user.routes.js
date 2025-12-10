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
 *         usr_age_group:
 *           type: string
 *           example: "15-25"
 *         usr_age:
 *           type: integer
 *           example: 22
 *         usr_job:
 *           type: string
 *           example: "developer"
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
 *           example: ["nature", "adventure"]
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
 *           example: 23
 *         usr_job:
 *           type: string
 *           enum: [student, teacher, engineer, doctor, nurse, accountant, lawyer, artist, designer, developer, manager, entrepreneur, freelancer, marketing, sales, consultant, researcher, writer, chef, photographer, pilot, architect, civil_servant, military, retired, unemployed, other]
 *           example: "developer"
 *         usr_avatar:
 *           type: string
 *           example: "https://example.com/avatar.jpg"
 *         usr_bio:
 *           type: string
 *           example: "Love traveling and exploring new cultures"
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           description: User's travel style preferences (optional)
 *           example: ["nature", "food_drink", "adventure"]
 *         usr_budget:
 *           type: number
 *           description: User's travel budget in VND (optional)
 *           example: 5000000
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
 *     TravelSettingsRequest:
 *       type: object
 *       properties:
 *         usr_age_group:
 *           type: string
 *           description: User's age group (optional)
 *           example: "26-35"
 *         usr_preferences:
 *           type: array
 *           items:
 *             type: string
 *           description: User's travel style preferences (optional)
 *           example: ["nature", "food_drink", "adventure"]
 *         usr_budget:
 *           type: number
 *           description: User's travel budget in VND (optional)
 *           example: 3000000
 *
 *     TravelSettingsResponse:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           example: "success"
 *         message:
 *           type: string
 *           example: "Travel settings updated successfully"
 *         data:
 *           type: object
 *           properties:
 *             id:
 *               type: string
 *               format: uuid
 *             usr_age_group:
 *               type: string
 *             usr_preferences:
 *               type: array
 *               items:
 *                 type: string
 *             usr_budget:
 *               type: number
 *             meta:
 *               type: object
 *               properties:
 *                 travel_styles:
 *                   type: array
 *                   items:
 *                     type: object
 *                 budget_config:
 *                   type: object
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
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                   label:
 *                     type: string
 *                   icon:
 *                     type: string
 *                   description:
 *                     type: string
 *             budget_config:
 *               type: object
 *               properties:
 *                 MIN:
 *                   type: number
 *                 MAX:
 *                   type: number
 *                 STEP:
 *                   type: number
 *                 DEFAULT:
 *                   type: number
 *                 CURRENCY:
 *                   type: string
 *             age_groups:
 *               type: array
 *               items:
 *                 type: string
 *             jobs:
 *               type: array
 *               items:
 *                 type: string
 *               example: ["student", "teacher", "engineer", "doctor", "nurse", "accountant", "lawyer", "artist", "designer", "developer", "manager", "entrepreneur", "freelancer", "marketing", "sales", "consultant", "researcher", "writer", "chef", "photographer", "pilot", "architect", "civil_servant", "military", "retired", "unemployed", "other"]
 *             age_min:
 *               type: integer
 *               example: 15
 *             age_max:
 *               type: integer
 *               example: 150
 */
/**
 * @swagger
 * tags:
 *   name: User
 *   description: User profile management APIs
 *   x-order: 2
 */

import express from "express";
import {body, validationResult} from 'express-validator';
import userController from '../controllers/user.controller.js';
import {authenticate} from '../middleware/authenticate.js';
import {AGE_GROUPS, BUDGET_CONFIG, VALID_TRAVEL_STYLE_IDS, AGE_MIN, JOBS, AGE_MAX} from '../config/travelConstants.js';

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
    body('usr_fullname').optional().trim().isLength({min: 1, max: 100})
        .withMessage('Full name must be between 1 and 100 characters'),
    body('usr_gender').optional().isIn(['male', 'female', 'other'])
        .withMessage('Gender must be male, female or other'),
    body('usr_age').optional().isInt({min: AGE_MIN, max: AGE_MAX})  // <-- VALIDATION MỚI
        .withMessage(`Age must be between ${AGE_MIN} and ${AGE_MAX}`),
    body('usr_job').optional().isIn(JOBS)  // <-- VALIDATION MỚI
        .withMessage(`Job must be one of: ${JOBS.join(', ')}`),
    body('usr_avatar').optional().isURL()
        .withMessage('Avatar must be a valid URL'),
    body('usr_bio').optional().isLength({max: 500})
        .withMessage('Bio must not exceed 500 characters'),
    body('usr_preferences').optional().isArray()
        .withMessage('Preferences must be an array')
        .custom((value) => {
            if (value) {
                const invalidPreferences = value.filter(pref => !VALID_TRAVEL_STYLE_IDS.includes(pref));
                if (invalidPreferences.length > 0) {
                    throw new Error(`Invalid travel style IDs: ${invalidPreferences.join(', ')}. Valid styles: ${VALID_TRAVEL_STYLE_IDS.join(', ')}`);
                }
            }
            return true;
        }),
    body('usr_budget').optional()
        .isFloat({min: BUDGET_CONFIG.MIN, max: BUDGET_CONFIG.MAX})
        .withMessage(`Budget must be between ${BUDGET_CONFIG.MIN} and ${BUDGET_CONFIG.MAX}`),
];

const travelSettingsValidation = [
    body('usr_age_group').optional().isIn(AGE_GROUPS)
        .withMessage('Invalid age group'),
    body('usr_preferences').optional().isArray()
        .withMessage('Preferences must be an array')
        .custom((value) => {
            if (value) {
                const invalidPreferences = value.filter(pref => !VALID_TRAVEL_STYLE_IDS.includes(pref));
                if (invalidPreferences.length > 0) {
                    throw new Error(`Invalid travel style IDs: ${invalidPreferences.join(', ')}. Valid styles: ${VALID_TRAVEL_STYLE_IDS.join(', ')}`);
                }
            }
            return true;
        }),
    body('usr_budget').optional()
        .isFloat({min: BUDGET_CONFIG.MIN, max: BUDGET_CONFIG.MAX})
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
 * /user/travel-settings:
 *   post:
 *     summary: Create or update travel settings
 *     description: Update user's age group, travel preferences (must be from predefined list) and budget
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: "#/components/schemas/TravelSettingsRequest"
 *           examples:
 *             example1:
 *               summary: Update all travel settings
 *               value:
 *                 usr_age_group: "26-35"
 *                 usr_preferences: ["nature", "food_drink", "adventure"]
 *                 usr_budget: 5000000
 *             example2:
 *               summary: Update only age group and preferences
 *               value:
 *                 usr_age_group: "36-50"
 *                 usr_preferences: ["chill_relax", "luxury"]
 *             example3:
 *               summary: Update only budget
 *               value:
 *                 usr_budget: 3000000
 *     responses:
 *       200:
 *         description: Travel settings updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/TravelSettingsResponse"
 *       400:
 *         description: Validation error - Invalid age group, travel style or budget
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
router.post('/travel-settings', authenticate, validate(travelSettingsValidation), userController.updateTravelSettings);
router.get('/travel-constants', userController.getTravelConstants);

export default router;