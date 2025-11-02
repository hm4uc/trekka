const jwt = require('jsonwebtoken');
const { StatusCodes } = require('http-status-codes');

function authenticate(req, res, next) {
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
        req.user = payload;
        next();
    } catch (error) {
        return res.status(StatusCodes.UNAUTHORIZED).json({
            status: 'error',
            message: 'Invalid or expired token'
        });
    }
}

module.exports = { authenticate };