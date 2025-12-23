import { StatusCodes } from 'http-status-codes';
import destinationService from '../services/destination.service.js';

async function getDestinations(req, res, next) {
    try {
        const {
            page, limit, search, categoryId, minPrice, maxPrice,
            lat, lng, radius, isOpenNow, context, sortBy, hiddenGemsOnly
        } = req.query;

        const result = await destinationService.getAllDestinations({
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
            search,
            categoryId,
            minPrice: minPrice ? parseFloat(minPrice) : undefined,
            maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
            lat: lat ? parseFloat(lat) : undefined,
            lng: lng ? parseFloat(lng) : undefined,
            radius: radius ? parseFloat(radius) : undefined,
            isOpenNow: isOpenNow === 'true',
            context,
            sortBy,
            hiddenGemsOnly: hiddenGemsOnly === 'true'
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getDestinationDetail(req, res, next) {
    try {
        const { id } = req.params;
        const userId = req.user?.profileId; // Optional from optionalAuthenticate middleware
        const result = await destinationService.getDestinationById(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getNearbyDestinations(req, res, next) {
    try {
        const { id } = req.params;
        const { limit, radius } = req.query;

        const result = await destinationService.getNearbyDestinations(id, {
            limit: parseInt(limit) || 5,
            radius: parseFloat(radius) || 2000
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getCategories(req, res, next) {
    try {
        const result = await destinationService.getAllCategories();
        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getCategoriesByTravelStyle(req, res, next) {
    try {
        const { travelStyle } = req.params;
        const result = await destinationService.getCategoriesByTravelStyle(travelStyle);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getAiPicks(req, res, next) {
    try {
        const { limit, lat, lng } = req.query;
        const userId = req.user.profileId;

        const result = await destinationService.getAiPicks(userId, {
            limit: parseInt(limit) || 10,
            lat: lat ? parseFloat(lat) : undefined,
            lng: lng ? parseFloat(lng) : undefined
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function likeDestination(req, res, next) {
    try {
        const { id } = req.params;
        const userId = req.user.profileId;

        const result = await destinationService.likeDestination(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.isLiked ? 'Đã like địa điểm' : 'Đã bỏ like địa điểm',
            data: {
                isLiked: result.isLiked,
                total_likes: result.total_likes
            }
        });
    } catch (error) {
        next(error);
    }
}

async function checkinDestination(req, res, next) {
    try {
        const { id } = req.params;
        const userId = req.user.profileId;

        const result = await destinationService.checkinDestination(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Đã check-in thành công',
            data: {
                total_checkins: result.total_checkins
            }
        });
    } catch (error) {
        next(error);
    }
}

async function createDestination(req, res, next) {
    try {
        const data = req.body;
        const result = await destinationService.createDestination(data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function updateDestination(req, res, next) {
    try {
        const { id } = req.params;
        const data = req.body;

        const result = await destinationService.updateDestination(id, data);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

export default {
    getDestinations,
    getDestinationDetail,
    getNearbyDestinations,
    getCategories,
    getCategoriesByTravelStyle,
    getAiPicks,
    likeDestination,
    checkinDestination,
    createDestination,
    updateDestination
};