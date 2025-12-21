import {Op} from 'sequelize';
import {Trip, TripDestination, TripEvent, Destination, Event, Profile} from '../models/associations.js';

// Helper function to validate trip_type and participant_count consistency
function validateTripTypeAndParticipantCount(tripType, participantCount) {
    const rules = {
        'solo': { min: 1, max: 1 },
        'couple': { min: 2, max: 2 },
        'family': { min: 3, max: null },
        'friends': { min: 2, max: null },
        'group': { min: 3, max: null }
    };

    const rule = rules[tripType];

    if (!rule) {
        const error = new Error(`Invalid trip_type: ${tripType}. Must be one of: solo, couple, family, friends, group`);
        error.statusCode = 400;
        throw error;
    }

    if (participantCount < rule.min) {
        const error = new Error(`Invalid participant_count for trip_type "${tripType}". Must be at least ${rule.min}`);
        error.statusCode = 400;
        throw error;
    }

    if (rule.max !== null && participantCount > rule.max) {
        const error = new Error(`Invalid participant_count for trip_type "${tripType}". Must be exactly ${rule.max}`);
        error.statusCode = 400;
        throw error;
    }
}

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
    // Validate trip_type and participant_count
    if (data.trip_type && data.participant_count !== undefined) {
        validateTripTypeAndParticipantCount(data.trip_type, data.participant_count);
    } else if (data.trip_type && data.participant_count === undefined) {
        // Auto-set participant_count based on trip_type
        const defaultCounts = {
            'solo': 1,
            'couple': 2,
            'family': 3,
            'friends': 2,
            'group': 3
        };
        data.participant_count = defaultCounts[data.trip_type] || 1;
    } else if (!data.trip_type && data.participant_count !== undefined) {
        // Auto-set trip_type based on participant_count
        if (data.participant_count === 1) data.trip_type = 'solo';
        else if (data.participant_count === 2) data.trip_type = 'couple';
        else data.trip_type = 'group';
    }

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

    // Validate trip_type and participant_count if either is being updated
    const newTripType = data.trip_type || trip.trip_type;
    const newParticipantCount = data.participant_count !== undefined ? data.participant_count : trip.participant_count;

    validateTripTypeAndParticipantCount(newTripType, newParticipantCount);

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
        visit_date: visitDate,
        start_time: startTime,
        notes: notes
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

    // destinationOrders = [{destId: 'xxx', visitOrder: 1}, ...]
    for (const item of destinationOrders) {
        await TripDestination.update(
            {visit_order: item.visitOrder},
            {where: {trip_id: tripId, dest_id: item.destId}}
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
        notes: notes
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

