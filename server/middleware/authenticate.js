import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';

export function authenticate(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(StatusCodes.UNAUTHORIZED).json({
            status: 'error',
            message: 'Access token is required'
        });
    }

    const token = authHeader.split(' ')[1];

    try {
        const payload = jwt.verify(token, process.env.JWT_SECRET);
        req.user = { profileId: payload.profileId, usr_email: payload.usr_email };
        next();
    } catch (error) {
        console.error('JWT verification error:', error);
        return res.status(StatusCodes.UNAUTHORIZED).json({
            status: 'error',
            message: 'Invalid or expired token'
        });
    }
}