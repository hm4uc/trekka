import {StatusCodes} from 'http-status-codes';
import eventService from '../services/event.service.js';

async function getAllEvents(req, res, next) {
    try {
        const {page, limit, search, eventType, lat, lng, radius, startDate, endDate, minPrice, maxPrice, sortBy} = req.query;

        const result = await eventService.getAllEvents({
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
            search,
            eventType,
            lat: lat ? parseFloat(lat) : undefined,
            lng: lng ? parseFloat(lng) : undefined,
            radius: radius ? parseFloat(radius) : undefined,
            startDate,
            endDate,
            minPrice: minPrice ? parseFloat(minPrice) : undefined,
            maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
            sortBy
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getEventById(req, res, next) {
    try {
        const {id} = req.params;
        const result = await eventService.getEventById(id);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getUpcomingEvents(req, res, next) {
    try {
        const {lat, lng, radius, limit} = req.query;

        const result = await eventService.getUpcomingEvents({
            lat: lat ? parseFloat(lat) : undefined,
            lng: lng ? parseFloat(lng) : undefined,
            radius: radius ? parseFloat(radius) : undefined,
            limit: limit ? parseInt(limit) : 10
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function likeEvent(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await eventService.likeEvent(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.isLiked ? 'Đã like sự kiện' : 'Đã bỏ like sự kiện',
            data: {
                isLiked: result.isLiked,
                total_likes: result.total_likes
            }
        });
    } catch (error) {
        next(error);
    }
}

async function createEvent(req, res, next) {
    try {
        const data = req.body;
        const result = await eventService.createEvent(data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function updateEvent(req, res, next) {
    try {
        const {id} = req.params;
        const data = req.body;

        const result = await eventService.updateEvent(id, data);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function checkinEvent(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await eventService.checkinEvent(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Đã check-in tại sự kiện',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

export default {
    getAllEvents,
    getEventById,
    getUpcomingEvents,
    likeEvent,
    createEvent,
    updateEvent,
    checkinEvent
};

