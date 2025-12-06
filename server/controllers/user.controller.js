import { StatusCodes } from 'http-status-codes';
import userService from '../services/user.service.js';

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

async function updateProfile(req, res, next) {
    try {
        const {
            usr_fullname,
            usr_gender,
            usr_age_group,
            usr_avatar,
            usr_bio
        } = req.body;

        const updatedProfile = await userService.updateProfile(req.user.profileId, {
            usr_fullname,
            usr_gender,
            usr_age_group,
            usr_avatar,
            usr_bio
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Profile updated successfully',
            data: updatedProfile
        });
    } catch (error) {
        next(error);
    }
}

async function updateTravelSettings(req, res, next) {
    try {
        const { usr_age_group, usr_preferences, usr_budget } = req.body;
        const profileId = req.user.profileId;

        const result = await userService.updateTravelSettings(profileId, {
            usr_age_group,
            usr_preferences,
            usr_budget
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Travel settings updated successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function deleteProfile(req, res, next) {
    try {
        await userService.deleteProfile(req.user.profileId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Profile deleted successfully'
        });
    } catch (error) {
        next(error);
    }
}

// Thêm controller để lấy travel constants
async function getTravelConstants(req, res, next) {
    try {
        const constants = await userService.getTravelConstants();

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: constants
        });
    } catch (error) {
        next(error);
    }
}

export default {
    getProfile,
    updateProfile,
    updateTravelSettings,
    deleteProfile,
    getTravelConstants
};