import {StatusCodes} from 'http-status-codes';
import userActivityService from '../services/userActivity.service.js';

async function getLikedItems(req, res, next) {
    try {
        const userId = req.user.profileId;
        const {page, limit, type} = req.query;

        const result = await userActivityService.getLikedItems(userId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
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

async function getCheckedInItems(req, res, next) {
    try {
        const userId = req.user.profileId;
        const {page, limit, type} = req.query;

        const result = await userActivityService.getCheckedInItems(userId, {
            page: parseInt(page) || 1,
            limit: parseInt(limit) || 10,
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

export default {
    getLikedItems,
    getCheckedInItems
};

