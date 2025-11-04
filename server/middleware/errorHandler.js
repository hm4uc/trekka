import { StatusCodes } from 'http-status-codes';

export function errorHandler(err, req, res, next) {
    console.error('Error:', err);

    // Default error
    let statusCode = StatusCodes.INTERNAL_SERVER_ERROR;
    let message = 'Something went wrong';

    // Sequelize validation error
    if (err.name === 'SequelizeValidationError') {
        statusCode = StatusCodes.BAD_REQUEST;
        message = err.errors.map(e => e.message).join(', ');
    }

    // Sequelize unique constraint error
    if (err.name === 'SequelizeUniqueConstraintError') {
        statusCode = StatusCodes.CONFLICT;
        message = 'Record already exists';
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        statusCode = StatusCodes.UNAUTHORIZED;
        message = 'Invalid token';
    }

    if (err.name === 'TokenExpiredError') {
        statusCode = StatusCodes.UNAUTHORIZED;
        message = 'Token expired';
    }

    // Custom error with status code
    if (err.statusCode) {
        statusCode = err.statusCode;
        message = err.message;
    }

    res.status(statusCode).json({
        status: 'error',
        message: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
}