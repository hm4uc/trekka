import {StatusCodes} from 'http-status-codes';
import reviewService from '../services/review.service.js';

async function createReview(req, res, next) {
    try {
        const userId = req.user.profileId;
        const data = req.body;

        const result = await reviewService.createReview(userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Review created successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getDestinationReviews(req, res, next) {
    try {
        const {destId} = req.params;
        const {page, limit, sortBy} = req.query;

        const result = await reviewService.getDestinationReviews(destId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
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

async function getEventReviews(req, res, next) {
    try {
        const {eventId} = req.params;
        const {page, limit} = req.query;

        const result = await reviewService.getEventReviews(eventId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getUserReviews(req, res, next) {
    try {
        const userId = req.user.profileId;
        const {page, limit} = req.query;

        const result = await reviewService.getUserReviews(userId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10
        });

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function updateReview(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await reviewService.updateReview(id, userId, data);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Review updated successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function deleteReview(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await reviewService.deleteReview(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function markReviewHelpful(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await reviewService.markReviewHelpful(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message,
            data: {
                isHelpful: result.isHelpful,
                helpfulCount: result.helpfulCount
            }
        });
    } catch (error) {
        next(error);
    }
}

export default {
    createReview,
    getDestinationReviews,
    getEventReviews,
    getUserReviews,
    updateReview,
    deleteReview,
    markReviewHelpful
};

