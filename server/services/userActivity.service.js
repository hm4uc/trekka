import {UserFeedback, Destination, Event} from '../models/associations.js';

// Get liked destinations and events by user
async function getLikedItems(userId, {page = 1, limit = 10, type}) {
    const offset = (page - 1) * limit;
    const whereClause = {
        user_id: userId,
        feedback_type: 'like'
    };

    if (type) {
        whereClause.feedback_target_type = type;
    }

    const {count, rows} = await UserFeedback.findAndCountAll({
        where: whereClause,
        limit,
        offset,
        order: [['created_at', 'DESC']]
    });

    // Fetch destination and event details
    const items = await Promise.all(
        rows.map(async (feedback) => {
            if (feedback.feedback_target_type === 'destination') {
                const destination = await Destination.findOne({
                    where: {id: feedback.target_id, is_active: true}
                });
                return destination ? {
                    type: 'destination',
                    liked_at: feedback.created_at,
                    ...destination.toJSON()
                } : null;
            } else if (feedback.feedback_target_type === 'event') {
                const event = await Event.findOne({
                    where: {id: feedback.target_id, is_active: true}
                });
                return event ? {
                    type: 'event',
                    liked_at: feedback.created_at,
                    ...event.toJSON()
                } : null;
            }
            return null;
        })
    );

    // Filter out null items (deleted destinations/events)
    const filteredItems = items.filter(item => item !== null);

    return {
        total: count,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        data: filteredItems
    };
}

// Get checked-in destinations and events by user
async function getCheckedInItems(userId, {page = 1, limit = 10, type}) {
    const offset = (page - 1) * limit;
    const whereClause = {
        user_id: userId,
        feedback_type: 'checkin'
    };

    if (type) {
        whereClause.feedback_target_type = type;
    }

    const {count, rows} = await UserFeedback.findAndCountAll({
        where: whereClause,
        limit,
        offset,
        order: [['created_at', 'DESC']]
    });

    // Fetch destination and event details
    const items = await Promise.all(
        rows.map(async (feedback) => {
            if (feedback.feedback_target_type === 'destination') {
                const destination = await Destination.findOne({
                    where: {id: feedback.target_id, is_active: true}
                });
                return destination ? {
                    type: 'destination',
                    checkin_at: feedback.created_at,
                    checkin_metadata: feedback.metadata,
                    ...destination.toJSON()
                } : null;
            } else if (feedback.feedback_target_type === 'event') {
                const event = await Event.findOne({
                    where: {id: feedback.target_id, is_active: true}
                });
                return event ? {
                    type: 'event',
                    checkin_at: feedback.created_at,
                    checkin_metadata: feedback.metadata,
                    ...event.toJSON()
                } : null;
            }
            return null;
        })
    );

    // Filter out null items (deleted destinations/events)
    const filteredItems = items.filter(item => item !== null);

    return {
        total: count,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        data: filteredItems
    };
}

export default {
    getLikedItems,
    getCheckedInItems
};

