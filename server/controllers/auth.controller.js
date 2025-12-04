import { StatusCodes } from 'http-status-codes';
import userService from '../services/user.service.js';

async function register(req, res, next) {
    try {
        const result = await userService.register(req.body);
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
        const result = await userService.login(req.body);
        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Login successful',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function logout(req, res, next) {
    try {
        const token = req.token; // Set by authenticate middleware
        const { profileId } = req.user; // Set by authenticate middleware

        const result = await userService.logout(token, profileId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message,
            data: {
                profileId,
                timestamp: new Date().toISOString()
            }
        });
    } catch (error) {
        next(error);
    }
}

async function logoutAllDevices(req, res, next) {
    try {
        const token = req.token; // Set by authenticate middleware
        const { profileId } = req.user; // Set by authenticate middleware

        const result = await userService.logoutAllDevices(profileId, token);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message,
            data: {
                profileId,
                timestamp: new Date().toISOString()
            }
        });
    } catch (error) {
        next(error);
    }
}

export default { register, login, logout, logoutAllDevices };
