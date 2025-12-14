import {Op, literal} from 'sequelize';
import {Event, UserFeedback, Profile} from '../models/associations.js';

// Get all events
async function getAllEvents({
                                page = 1,
                                limit = 10,
                                search,
                                eventType,
                                lat,
                                lng,
                                radius = 5000,
                                startDate,
                                endDate,
                                minPrice,
                                maxPrice,
                                sortBy = 'date'
                            }) {
    const offset = (page - 1) * limit;
    const whereClause = {is_active: true};

    let orderClause = [['event_start', 'ASC']];

    // Filter by search
    if (search) {
        whereClause.event_name = {[Op.iLike]: `%${search}%`};
    }

    // Filter by event type
    if (eventType) {
        whereClause.event_type = eventType;
    }

    // Filter by date range
    if (startDate || endDate) {
        whereClause.event_start = {};
        if (startDate) whereClause.event_start[Op.gte] = startDate;
        if (endDate) whereClause.event_start[Op.lte] = endDate;
    }

    // Filter by price
    if (minPrice !== undefined || maxPrice !== undefined) {
        whereClause.event_ticket_price = {};
        if (minPrice) whereClause.event_ticket_price[Op.gte] = minPrice;
        if (maxPrice) whereClause.event_ticket_price[Op.lte] = maxPrice;
    }

    // Filter by location
    if (lat && lng) {
        whereClause.geom = {
            [Op.and]: [
                {[Op.not]: null},
                literal(
                    `ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, ${radius})`
                )
            ]
        };

        if (sortBy === 'distance') {
            const distanceLiteral = literal(
                `ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography)`
            );
            orderClause = [[distanceLiteral, 'ASC']];
        }
    }

    switch (sortBy) {
        case 'popularity':
            orderClause = [['total_likes', 'DESC']];
            break;
        case 'price_asc':
            orderClause = [['event_ticket_price', 'ASC']];
            break;
        case 'price_desc':
            orderClause = [['event_ticket_price', 'DESC']];
            break;
    }

    const {count, rows} = await Event.findAndCountAll({
        where: whereClause,
        limit,
        offset,
        order: orderClause
    });

    return {
        total: count,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        data: rows
    };
}

// Get event by ID
async function getEventById(id) {
    const event = await Event.findOne({
        where: {id, is_active: true}
    });

    if (!event) {
        const error = new Error('Event not found');
        error.statusCode = 404;
        throw error;
    }

    return event;
}

// Get upcoming events near location
async function getUpcomingEvents({lat, lng, radius = 5000, limit = 10}) {
    const whereClause = {
        is_active: true,
        event_start: {[Op.gte]: new Date()}
    };

    if (lat && lng) {
        whereClause.geom = literal(
            `ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, ${radius})`
        );
    }

    const events = await Event.findAll({
        where: whereClause,
        limit,
        order: [['event_start', 'ASC']]
    });

    return events;
}

// Like event
async function likeEvent(id, userId) {
    const event = await Event.findOne({
        where: {id, is_active: true}
    });

    if (!event) {
        const error = new Error('Event not found');
        error.statusCode = 404;
        throw error;
    }

    const existingLike = await UserFeedback.findOne({
        where: {
            user_id: userId,
            target_id: id,
            feedback_target_type: 'event',
            feedback_type: 'like'
        }
    });

    if (existingLike) {
        await existingLike.destroy();
        await event.decrement('total_likes');
        await Profile.decrement('total_likes', {where: {id: userId}});

        return {
            ...event.toJSON(),
            isLiked: false
        };
    } else {
        await UserFeedback.create({
            user_id: userId,
            target_id: id,
            feedback_target_type: 'event',
            feedback_type: 'like'
        });

        await event.increment('total_likes');
        await Profile.increment('total_likes', {where: {id: userId}});

        return {
            ...event.toJSON(),
            isLiked: true
        };
    }
}

// Create event (Admin)
async function createEvent(data) {
    if (data.lat && data.lng) {
        data.geom = literal(`ST_SetSRID(ST_MakePoint(${data.lng}, ${data.lat}), 4326)`);
    }

    return await Event.create(data);
}

// Update event (Admin)
async function updateEvent(id, data) {
    const event = await Event.findOne({where: {id}});

    if (!event) {
        const error = new Error('Event not found');
        error.statusCode = 404;
        throw error;
    }

    if ((data.lat && data.lat !== event.lat) || (data.lng && data.lng !== event.lng)) {
        data.geom = literal(`ST_SetSRID(ST_MakePoint(${data.lng || event.lng}, ${data.lat || event.lat}), 4326)`);
    }

    await event.update(data);
    return event;
}

export default {
    getAllEvents,
    getEventById,
    getUpcomingEvents,
    likeEvent,
    createEvent,
    updateEvent
};

