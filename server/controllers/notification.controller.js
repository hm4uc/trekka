import {StatusCodes} from 'http-status-codes';
import notificationService from '../services/notification.service.js';

async function getNotifications(req, res, next) {
    try {
        const userId = req.user.profileId;
        const {page, limit, status, type} = req.query;

        const result = await notificationService.getUserNotifications(userId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 20,
            status,
            type
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function markAsRead(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await notificationService.markAsRead(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Notification marked as read',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function markAllAsRead(req, res, next) {
    try {
        const userId = req.user.profileId;

        const result = await notificationService.markAllAsRead(userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function deleteNotification(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await notificationService.deleteNotification(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function getUnreadCount(req, res, next) {
    try {
        const userId = req.user.profileId;

        const result = await notificationService.getUnreadCount(userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

export default {
    getNotifications,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    getUnreadCount
};

