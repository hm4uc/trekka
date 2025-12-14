import {StatusCodes} from 'http-status-codes';
import tripService from '../services/trip.service.js';

async function getUserTrips(req, res, next) {
    try {
        const userId = req.user.profileId;
        const {page, limit, status} = req.query;

        const result = await tripService.getUserTrips(userId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
            status
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getTripById(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await tripService.getTripById(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function createTrip(req, res, next) {
    try {
        const userId = req.user.profileId;
        const data = req.body;

        const result = await tripService.createTrip(userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Trip created successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function updateTrip(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await tripService.updateTrip(id, userId, data);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Trip updated successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function deleteTrip(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await tripService.deleteTrip(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function addDestinationToTrip(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await tripService.addDestinationToTrip(id, userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Destination added to trip',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function removeDestinationFromTrip(req, res, next) {
    try {
        const {id, destId} = req.params;
        const userId = req.user.profileId;

        const result = await tripService.removeDestinationFromTrip(id, userId, destId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function reorderDestinations(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const {destinationOrders} = req.body;

        const result = await tripService.reorderDestinations(id, userId, destinationOrders);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function addEventToTrip(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await tripService.addEventToTrip(id, userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Event added to trip',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function removeEventFromTrip(req, res, next) {
    try {
        const {id, eventId} = req.params;
        const userId = req.user.profileId;

        const result = await tripService.removeEventFromTrip(id, userId, eventId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function changeTripStatus(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const {status} = req.body;

        const result = await tripService.changeTripStatus(id, userId, status);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Trip status updated',
            data: result
        });
    } catch (error) {
        next(error);
    }
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

