import { StatusCodes } from 'http-status-codes';
import userService from '../services/user.service.js';

async function register(req, res, next) {
    try {
        const {
            usr_fullname,
            usr_email,
            password,
            usr_gender,
            usr_age,
            usr_job
            // Loại bỏ usr_preferences và usr_budget từ register
        } = req.body;

        const result = await userService.register({
            usr_fullname,
            usr_email,
            password,
            usr_gender,
            usr_age,
            usr_job
        });

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Profile registered successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function login(req, res, next) {
    try {
        const { usr_email, password } = req.body;

        const result = await userService.login({
            email: usr_email,
            password
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Login successful',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getProfile(req, res, next) {
    try {
        const profile = await userService.getProfileById(req.user.profileId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: profile
        });
    } catch (error) {
        next(error);
    }
}

// Thêm controller mới cho preferences và budget
async function updatePreferencesAndBudget(req, res, next) {
    try {
        const { usr_preferences, usr_budget } = req.body;
        const profileId = req.user.profileId; // Lấy từ middleware authenticate

        const result = await userService.updatePreferencesAndBudget(profileId, {
            usr_preferences,
            usr_budget
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Preferences and budget updated successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

export default { register, login, getProfile, updatePreferencesAndBudget };