import { StatusCodes } from 'http-status-codes';
import userService from '../services/user.service.js';

async function register(req, res, next) {
    try {
        const { name, email, password } = req.body;

        const user = await userService.register({ name, email, password });

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'User registered successfully',
            data: user
        });
    } catch (error) {
        next(error);
    }
}

async function login(req, res, next) {
    try {
        const { email, password } = req.body;

        const result = await userService.login({ email, password });

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
        const user = await userService.getUserById(req.user.userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: user
        });
    } catch (error) {
        next(error);
    }
}

export default { register, login, getProfile };