import {StatusCodes} from 'http-status-codes';
import groupService from '../services/group.service.js';

async function createGroup(req, res, next) {
    try {
        const userId = req.user.profileId;
        const data = req.body;

        const result = await groupService.createGroup(userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Group created successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getUserGroups(req, res, next) {
    try {
        const userId = req.user.profileId;

        const result = await groupService.getUserGroups(userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getGroupById(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await groupService.getGroupById(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function updateGroup(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await groupService.updateGroup(id, userId, data);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: 'Group updated successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function deleteGroup(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await groupService.deleteGroup(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function addMember(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;
        const data = req.body;

        const result = await groupService.addMemberToGroup(id, userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Member added successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function removeMember(req, res, next) {
    try {
        const {id, memberId} = req.params;
        const userId = req.user.profileId;

        const result = await groupService.removeMemberFromGroup(id, userId, memberId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            message: result.message
        });
    } catch (error) {
        next(error);
    }
}

async function shareTrip(req, res, next) {
    try {
        const userId = req.user.profileId;
        const data = req.body;

        const result = await groupService.shareTripToGroup(userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Trip shared successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getSharedTrips(req, res, next) {
    try {
        const {id} = req.params;
        const userId = req.user.profileId;

        const result = await groupService.getGroupSharedTrips(id, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function addComment(req, res, next) {
    try {
        const userId = req.user.profileId;
        const data = req.body;

        const result = await groupService.addComment(userId, data);

        res.status(StatusCodes.CREATED).json({
            status: 'success',
            message: 'Comment added successfully',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

async function getComments(req, res, next) {
    try {
        const {tripShareId} = req.params;
        const userId = req.user.profileId;

        const result = await groupService.getComments(tripShareId, userId);

        res.status(StatusCodes.OK).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        next(error);
    }
}

export default {
    createGroup,
    getUserGroups,
    getGroupById,
    updateGroup,
    deleteGroup,
    addMember,
    removeMember,
    shareTrip,
    getSharedTrips,
    addComment,
    getComments
};

