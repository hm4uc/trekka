import {Group, GroupMember, TripShare, GroupComment, Trip, Profile} from '../models/associations.js';

// Create group
async function createGroup(userId, {group_name, group_description, group_avatar}) {
    const group = await Group.create({
        group_name,
        group_description,
        group_avatar,
        created_by: userId
    });

    // Auto-add creator as admin
    await GroupMember.create({
        group_id: group.id,
        user_id: userId,
        role: 'admin'
    });

    return group;
}

// Get user's groups
async function getUserGroups(userId) {
    const groupMemberships = await GroupMember.findAll({
        where: {user_id: userId},
        include: [
            {
                model: Group,
                as: 'group',
                where: {is_active: true},
                include: [
                    {
                        model: Profile,
                        as: 'creator',
                        attributes: ['id', 'usr_fullname', 'usr_avatar']
                    }
                ]
            }
        ]
    });

    return groupMemberships.map(gm => ({
        ...gm.group.toJSON(),
        userRole: gm.role
    }));
}

// Get group detail
async function getGroupById(groupId, userId) {
    const group = await Group.findOne({
        where: {id: groupId, is_active: true},
        include: [
            {
                model: Profile,
                as: 'creator',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
            },
            {
                model: GroupMember,
                as: 'members',
                include: [
                    {
                        model: Profile,
                        as: 'user',
                        attributes: ['id', 'usr_fullname', 'usr_avatar']
                    }
                ]
            }
        ]
    });

    if (!group) {
        const error = new Error('Group not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is member
    const isMember = group.members.some(m => m.user_id === userId);

    if (!isMember) {
        const error = new Error('You are not a member of this group');
        error.statusCode = 403;
        throw error;
    }

    return group;
}

// Update group
async function updateGroup(groupId, userId, {group_name, group_description, group_avatar}) {
    const group = await Group.findOne({
        where: {id: groupId, is_active: true}
    });

    if (!group) {
        const error = new Error('Group not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is admin
    const member = await GroupMember.findOne({
        where: {group_id: groupId, user_id: userId, role: 'admin'}
    });

    if (!member) {
        const error = new Error('Only group admin can update group');
        error.statusCode = 403;
        throw error;
    }

    await group.update({
        group_name: group_name || group.group_name,
        group_description: group_description || group.group_description,
        group_avatar: group_avatar || group.group_avatar
    });

    return group;
}

// Delete group
async function deleteGroup(groupId, userId) {
    const group = await Group.findOne({
        where: {id: groupId, created_by: userId}
    });

    if (!group) {
        const error = new Error('Group not found or you are not the creator');
        error.statusCode = 404;
        throw error;
    }

    await group.update({is_active: false});
    return {message: 'Group deleted successfully'};
}

// Add member to group
async function addMemberToGroup(groupId, userId, {memberEmail}) {
    // Check if user is admin
    const adminMember = await GroupMember.findOne({
        where: {group_id: groupId, user_id: userId, role: 'admin'}
    });

    if (!adminMember) {
        const error = new Error('Only admin can add members');
        error.statusCode = 403;
        throw error;
    }

    // Find user by email
    const newUser = await Profile.findOne({
        where: {usr_email: memberEmail}
    });

    if (!newUser) {
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if already member
    const existing = await GroupMember.findOne({
        where: {group_id: groupId, user_id: newUser.id}
    });

    if (existing) {
        const error = new Error('User is already a member');
        error.statusCode = 400;
        throw error;
    }

    const groupMember = await GroupMember.create({
        group_id: groupId,
        user_id: newUser.id,
        role: 'member'
    });

    return groupMember;
}

// Remove member from group
async function removeMemberFromGroup(groupId, userId, memberId) {
    const group = await Group.findOne({
        where: {id: groupId, is_active: true}
    });

    if (!group) {
        const error = new Error('Group not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is admin or creator
    const isCreator = group.created_by === userId;
    const adminMember = await GroupMember.findOne({
        where: {group_id: groupId, user_id: userId, role: 'admin'}
    });

    if (!isCreator && !adminMember) {
        const error = new Error('Only admin or creator can remove members');
        error.statusCode = 403;
        throw error;
    }

    const memberToRemove = await GroupMember.findOne({
        where: {group_id: groupId, user_id: memberId}
    });

    if (!memberToRemove) {
        const error = new Error('Member not found in group');
        error.statusCode = 404;
        throw error;
    }

    // Cannot remove creator
    if (group.created_by === memberId) {
        const error = new Error('Cannot remove group creator');
        error.statusCode = 400;
        throw error;
    }

    await memberToRemove.destroy();
    return {message: 'Member removed successfully'};
}

// Share trip to group
async function shareTripToGroup(userId, {tripId, groupId, message}) {
    // Check if user owns the trip
    const trip = await Trip.findOne({
        where: {id: tripId, user_id: userId}
    });

    if (!trip) {
        const error = new Error('Trip not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is member of group
    const isMember = await GroupMember.findOne({
        where: {group_id: groupId, user_id: userId}
    });

    if (!isMember) {
        const error = new Error('You are not a member of this group');
        error.statusCode = 403;
        throw error;
    }

    // Check if already shared
    const existing = await TripShare.findOne({
        where: {trip_id: tripId, group_id: groupId}
    });

    if (existing) {
        const error = new Error('Trip already shared to this group');
        error.statusCode = 400;
        throw error;
    }

    const tripShare = await TripShare.create({
        trip_id: tripId,
        group_id: groupId,
        shared_by: userId,
        message
    });

    return tripShare;
}

// Get shared trips in group
async function getGroupSharedTrips(groupId, userId) {
    // Check if user is member
    const isMember = await GroupMember.findOne({
        where: {group_id: groupId, user_id: userId}
    });

    if (!isMember) {
        const error = new Error('You are not a member of this group');
        error.statusCode = 403;
        throw error;
    }

    const sharedTrips = await TripShare.findAll({
        where: {group_id: groupId},
        include: [
            {
                model: Trip,
                as: 'trip'
            },
            {
                model: Profile,
                as: 'sharedBy',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
            }
        ],
        order: [['shared_at', 'DESC']]
    });

    return sharedTrips;
}

// Add comment to shared trip
async function addComment(userId, {tripShareId, comment, parentCommentId}) {
    const tripShare = await TripShare.findOne({
        where: {id: tripShareId},
        include: [
            {
                model: Group,
                as: 'group'
            }
        ]
    });

    if (!tripShare) {
        const error = new Error('Shared trip not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is member
    const isMember = await GroupMember.findOne({
        where: {group_id: tripShare.group_id, user_id: userId}
    });

    if (!isMember) {
        const error = new Error('You are not a member of this group');
        error.statusCode = 403;
        throw error;
    }

    const groupComment = await GroupComment.create({
        trip_share_id: tripShareId,
        user_id: userId,
        comment,
        parent_comment_id: parentCommentId
    });

    return groupComment;
}

// Get comments for shared trip
async function getComments(tripShareId, userId) {
    const tripShare = await TripShare.findOne({
        where: {id: tripShareId}
    });

    if (!tripShare) {
        const error = new Error('Shared trip not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user is member
    const isMember = await GroupMember.findOne({
        where: {group_id: tripShare.group_id, user_id: userId}
    });

    if (!isMember) {
        const error = new Error('You are not a member of this group');
        error.statusCode = 403;
        throw error;
    }

    const comments = await GroupComment.findAll({
        where: {trip_share_id: tripShareId, parent_comment_id: null},
        include: [
            {
                model: Profile,
                as: 'user',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
            },
            {
                model: GroupComment,
                as: 'replies',
                include: [
                    {
                        model: Profile,
                        as: 'user',
                        attributes: ['id', 'usr_fullname', 'usr_avatar']
                    }
                ]
            }
        ],
        order: [['createdAt', 'DESC']]
    });

    return comments;
}

export default {
    createGroup,
    getUserGroups,
    getGroupById,
    updateGroup,
    deleteGroup,
    addMemberToGroup,
    removeMemberFromGroup,
    shareTripToGroup,
    getGroupSharedTrips,
    addComment,
    getComments
};

