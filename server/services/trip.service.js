import {Op} from 'sequelize';
import {Trip, TripDestination, TripEvent, Destination, Event, Profile} from '../models/associations.js';

// Get all trips of a user
async function getUserTrips(userId, {page = 1, limit = 10, status}) {
    const offset = (page - 1) * limit;
    const whereClause = {user_id: userId};

    if (status) {
        whereClause.trip_status = status;
    }

    const {count, rows} = await Trip.findAndCountAll({
        where: whereClause,
        include: [
            {
                model: TripDestination,
                as: 'tripDestinations',
                include: [
                    {
                        model: Destination,
                        as: 'destination',
                        attributes: ['id', 'name', 'images', 'lat', 'lng', 'avg_cost']
                    }
                ],
                order: [['visit_order', 'ASC']]
            },
            {
                model: TripEvent,
                as: 'tripEvents',
                include: [
                    {
                        model: Event,
                        as: 'event',
                        attributes: ['id', 'event_name', 'event_start', 'event_end', 'event_ticket_price']
                    }
                ],
                order: [['visit_order', 'ASC']]
            }
        ],
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

// Get single trip detail
async function getTripById(tripId, userId) {
    const trip = await Trip.findOne({
        where: {id: tripId},
        include: [
            {
                model: Profile,
                as: 'user',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
            },
            {
                model: TripDestination,
                as: 'tripDestinations',
                include: [
                    {
                        model: Destination,
                        as: 'destination'
                    }
                ],
                order: [['visit_order', 'ASC']]
            },
            {
                model: TripEvent,
                as: 'tripEvents',
                include: [
                    {
                        model: Event,
                        as: 'event'
                    }
                ],
                order: [['visit_order', 'ASC']]
            }
        ]
    });

    if (!trip) {
        const error = new Error('Trip not found');
        error.statusCode = 404;
        throw error;
    }

    // Check access permission
    if (trip.user_id !== userId && trip.visibility === 'private') {
        const error = new Error('Access denied');
        error.statusCode = 403;
        throw error;
    }

    return trip;
}

// Create new trip
async function createTrip(userId, data) {
    const trip = await Trip.create({
        ...data,
        user_id: userId
    });

    return trip;
}

// Update trip
async function updateTrip(tripId, userId, data) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    await trip.update(data);
    return trip;
}

// Delete trip
async function deleteTrip(tripId, userId) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    await trip.destroy();
    return {message: 'Trip deleted successfully'};
}

// Add destination to trip
async function addDestinationToTrip(tripId, userId, {destId, visitOrder, estimatedTime, visitDate, startTime, notes}) {
    // Check trip ownership
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    // Check destination exists
    const destination = await Destination.findOne({
        where: {id: destId, is_active: true}
    });

    if (!destination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if already added
    const existing = await TripDestination.findOne({
        where: {trip_id: tripId, dest_id: destId}
    });

    if (existing) {
        const error = new Error('Destination already added to this trip');
        error.statusCode = 400;
        throw error;
    }

    // If no visit order provided, add to end
    if (!visitOrder) {
        const maxOrder = await TripDestination.max('visit_order', {
            where: {trip_id: tripId}
        });
        visitOrder = (maxOrder || 0) + 1;
    }

    const tripDestination = await TripDestination.create({
        trip_id: tripId,
        dest_id: destId,
        visit_order: visitOrder,
        estimated_time: estimatedTime || destination.recommended_duration,
        visit_date,
        start_time,
        notes
    });

    return tripDestination;
}

// Remove destination from trip
async function removeDestinationFromTrip(tripId, userId, destId) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    const tripDestination = await TripDestination.findOne({
        where: {trip_id: tripId, dest_id: destId}
    });

    if (!tripDestination) {
        const error = new Error('Destination not found in trip');
        error.statusCode = 404;
        throw error;
    }

    await tripDestination.destroy();
    return {message: 'Destination removed from trip'};
}

// Reorder destinations
async function reorderDestinations(tripId, userId, destinationOrders) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    // destinationOrders = [{dest_id: 'xxx', visit_order: 1}, ...]
    for (const item of destinationOrders) {
        await TripDestination.update(
            {visit_order: item.visit_order},
            {where: {trip_id: tripId, dest_id: item.dest_id}}
        );
    }

    return {message: 'Destinations reordered successfully'};
}

// Add event to trip
async function addEventToTrip(tripId, userId, {eventId, visitOrder, notes}) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    const event = await Event.findOne({
        where: {id: eventId, is_active: true}
    });

    if (!event) {
        const error = new Error('Event not found');
        error.statusCode = 404;
        throw error;
    }

    const existing = await TripEvent.findOne({
        where: {trip_id: tripId, event_id: eventId}
    });

    if (existing) {
        const error = new Error('Event already added to this trip');
        error.statusCode = 400;
        throw error;
    }

    if (!visitOrder) {
        const maxOrder = await TripEvent.max('visit_order', {
            where: {trip_id: tripId}
        });
        visitOrder = (maxOrder || 0) + 1;
    }

    const tripEvent = await TripEvent.create({
        trip_id: tripId,
        event_id: eventId,
        visit_order: visitOrder,
        notes
    });

    return tripEvent;
}

// Remove event from trip
async function removeEventFromTrip(tripId, userId, eventId) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    const tripEvent = await TripEvent.findOne({
        where: {trip_id: tripId, event_id: eventId}
    });

    if (!tripEvent) {
        const error = new Error('Event not found in trip');
        error.statusCode = 404;
        throw error;
    }

    await tripEvent.destroy();
    return {message: 'Event removed from trip'};
}

// Change trip status
async function changeTripStatus(tripId, userId, status) {
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    await trip.update({trip_status: status});
    return trip;
}

export default {
    getUserTrips,
    getTripById,
    createTrip,
    updateTrip,
    deleteTrip,
    addDestinationToTrip,
    removeDestinationFromTrip,
    reorderDestinations,
    addEventToTrip,
    removeEventFromTrip,
    changeTripStatus
};

