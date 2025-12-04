import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import TokenBlacklist from '../models/tokenBlacklist.model.js';

export async function authenticate(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(StatusCodes.UNAUTHORIZED).json({
            status: 'error',
            message: 'Access token is required'
        });
    }

    const token = authHeader.split(' ')[1];

    try {
        // Verify JWT signature and expiration
        const payload = jwt.verify(token, process.env.JWT_SECRET);

        // Check if token is blacklisted
        const blacklistedToken = await TokenBlacklist.findOne({
            where: { token }
        });

        if (blacklistedToken) {
            console.warn(`⚠️ Attempt to use blacklisted token by profile ${payload.profileId}`);
            return res.status(StatusCodes.UNAUTHORIZED).json({
                status: 'error',
                message: 'Token has been revoked. Please login again.'
            });
        }

        // Attach user info to request
        req.user = {
            profileId: payload.profileId,
            usr_email: payload.usr_email
        };
        req.token = token; // Store token for potential blacklisting

        next();
    } catch (error) {
        console.error('JWT verification error:', error);

        let message = 'Invalid or expired token';
        if (error.name === 'TokenExpiredError') {
            message = 'Token has expired. Please login again.';
        } else if (error.name === 'JsonWebTokenError') {
            message = 'Invalid token. Please login again.';
        }

        return res.status(StatusCodes.UNAUTHORIZED).json({
            status: 'error',
            message
        });
    }
}