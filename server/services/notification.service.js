import {Notification, Profile} from '../models/associations.js';
import {Op} from 'sequelize';

// Get user notifications
async function getUserNotifications(userId, {page = 1, limit = 20, status, type}) {
    const offset = (page - 1) * limit;
    const whereClause = {user_id: userId};

    if (status) {
        whereClause.noti_status = status;
    }

    if (type) {
        whereClause.noti_type = type;
    }

    const {count, rows} = await Notification.findAndCountAll({
        where: whereClause,
        limit,
        offset,
        order: [['createdAt', 'DESC']]
    });

    return {
        total: count,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        data: rows
    };
}

// Create notification
async function createNotification(userId, {noti_type, noti_title, noti_message, noti_data, scheduled_at}) {
    const notification = await Notification.create({
        user_id: userId,
        noti_type,
        noti_title,
        noti_message,
        noti_data: noti_data || {},
        scheduled_at,
        noti_status: scheduled_at ? 'pending' : 'sent',
        sent_at: scheduled_at ? null : new Date()
    });

    return notification;
}

// Mark notification as read
async function markAsRead(notificationId, userId) {
    const notification = await Notification.findOne({
        where: {id: notificationId, user_id: userId}
    });

    if (!notification) {
        const error = new Error('Notification not found');
        error.statusCode = 404;
        throw error;
    }

    await notification.update({
        noti_status: 'read',
        read_at: new Date()
    });

    return notification;
}

// Mark all as read
async function markAllAsRead(userId) {
    await Notification.update(
        {
            noti_status: 'read',
            read_at: new Date()
        },
        {
            where: {
                user_id: userId,
                noti_status: {[Op.ne]: 'read'}
            }
        }
    );

    return {message: 'All notifications marked as read'};
}

// Delete notification
async function deleteNotification(notificationId, userId) {
    const notification = await Notification.findOne({
        where: {id: notificationId, user_id: userId}
    });

    if (!notification) {
        const error = new Error('Notification not found');
        error.statusCode = 404;
        throw error;
    }

    await notification.destroy();
    return {message: 'Notification deleted successfully'};
}

// Get unread count
async function getUnreadCount(userId) {
    const count = await Notification.count({
        where: {
            user_id: userId,
            noti_status: {[Op.ne]: 'read'}
        }
    });

    return {unreadCount: count};
}

// Send trip reminder (scheduled)
async function sendTripReminder(userId, tripId, tripTitle, scheduledTime) {
    return await createNotification(userId, {
        noti_type: 'reminder',
        noti_title: 'Nhắc nhở chuyến đi',
        noti_message: `Chuyến đi "${tripTitle}" của bạn sắp bắt đầu!`,
        noti_data: {trip_id: tripId},
        scheduled_at: scheduledTime
    });
}

// Send event reminder
async function sendEventReminder(userId, eventId, eventName, scheduledTime) {
    return await createNotification(userId, {
        noti_type: 'event',
        noti_title: 'Sự kiện sắp diễn ra',
        noti_message: `Sự kiện "${eventName}" sẽ bắt đầu trong 30 phút nữa!`,
        noti_data: {event_id: eventId},
        scheduled_at: scheduledTime
    });
}

// Send progress notification
async function sendProgressNotification(userId, message, data) {
    return await createNotification(userId, {
        noti_type: 'progress',
        noti_title: 'Tiến độ chuyến đi',
        noti_message: message,
        noti_data: data
    });
}

// Send social notification (new comment, invitation, etc.)
async function sendSocialNotification(userId, title, message, data) {
    return await createNotification(userId, {
        noti_type: 'social',
        noti_title: title,
        noti_message: message,
        noti_data: data
    });
}

export default {
    getUserNotifications,
    createNotification,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    getUnreadCount,
    sendTripReminder,
    sendEventReminder,
    sendProgressNotification,
    sendSocialNotification
};

