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
            usr_job,
            usr_preferences,
            usr_budget
        } = req.body;

        const result = await userService.register({
            usr_fullname,
            usr_email,
            password,
            usr_gender,
            usr_age,
            usr_job,
            usr_preferences,
            usr_budget
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

export default { register, login, getProfile };