import Destination from './destination.model.js';
import DestinationCategory from './destinationCategory.model.js';
import Profile from './profile.model.js';
import Event from './event.model.js';
import Review from './review.model.js';
import ReviewHelpful from './reviewHelpful.model.js';
import Trip from './trip.model.js';
import TripDestination from './tripDestination.model.js';
import TripEvent from './tripEvent.model.js';
import UserFeedback from './userFeedback.model.js';
import Notification from './notification.model.js';
import Group from './group.model.js';
import GroupMember from './groupMember.model.js';
import TripShare from './tripShare.model.js';
import GroupComment from './groupComment.model.js';
import AIRequest from './aiRequest.model.js';
import AIResponse from './aiResponse.model.js';
import SearchLog from './searchLog.model.js';

// ==================== DESTINATION & CATEGORY ====================
// 1 Category có nhiều Destination
DestinationCategory.hasMany(Destination, { foreignKey: 'categoryId', as: 'destinations' });
Destination.belongsTo(DestinationCategory, { foreignKey: 'categoryId', as: 'category' });

// ==================== PROFILE RELATIONSHIPS ====================
// Profile -> Reviews
Profile.hasMany(Review, { foreignKey: 'user_id', as: 'reviews' });
Review.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> Trips
Profile.hasMany(Trip, { foreignKey: 'user_id', as: 'trips' });
Trip.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> UserFeedback
Profile.hasMany(UserFeedback, { foreignKey: 'user_id', as: 'feedback' });
UserFeedback.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> Notifications
Profile.hasMany(Notification, { foreignKey: 'user_id', as: 'notifications' });
Notification.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> Groups (created)
Profile.hasMany(Group, { foreignKey: 'created_by', as: 'createdGroups' });
Group.belongsTo(Profile, { foreignKey: 'created_by', as: 'creator' });

// Profile -> AIRequests
Profile.hasMany(AIRequest, { foreignKey: 'user_id', as: 'aiRequests' });
AIRequest.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> SearchLogs
Profile.hasMany(SearchLog, { foreignKey: 'user_id', as: 'searchLogs' });
SearchLog.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// ==================== DESTINATION RELATIONSHIPS ====================
// Destination -> Reviews
Destination.hasMany(Review, { foreignKey: 'dest_id', as: 'reviews' });
Review.belongsTo(Destination, { foreignKey: 'dest_id', as: 'destination' });

// Destination -> TripDestinations
Destination.hasMany(TripDestination, { foreignKey: 'dest_id', as: 'tripDestinations' });
TripDestination.belongsTo(Destination, { foreignKey: 'dest_id', as: 'destination' });

// ==================== EVENT RELATIONSHIPS ====================
// Event -> Reviews
Event.hasMany(Review, { foreignKey: 'event_id', as: 'reviews' });
Review.belongsTo(Event, { foreignKey: 'event_id', as: 'event' });

// Event -> TripEvents
Event.hasMany(TripEvent, { foreignKey: 'event_id', as: 'tripEvents' });
TripEvent.belongsTo(Event, { foreignKey: 'event_id', as: 'event' });

// ==================== REVIEW HELPFUL RELATIONSHIPS ====================
// Review -> ReviewHelpful
Review.hasMany(ReviewHelpful, { foreignKey: 'review_id', as: 'helpfulMarks' });
ReviewHelpful.belongsTo(Review, { foreignKey: 'review_id', as: 'review' });

// Profile -> ReviewHelpful
Profile.hasMany(ReviewHelpful, { foreignKey: 'user_id', as: 'helpfulReviews' });
ReviewHelpful.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// ==================== TRIP RELATIONSHIPS ====================
// Trip -> TripDestinations
Trip.hasMany(TripDestination, { foreignKey: 'trip_id', as: 'tripDestinations' });
TripDestination.belongsTo(Trip, { foreignKey: 'trip_id', as: 'trip' });

// Trip -> TripEvents
Trip.hasMany(TripEvent, { foreignKey: 'trip_id', as: 'tripEvents' });
TripEvent.belongsTo(Trip, { foreignKey: 'trip_id', as: 'trip' });

// Trip -> TripShares
Trip.hasMany(TripShare, { foreignKey: 'trip_id', as: 'shares' });
TripShare.belongsTo(Trip, { foreignKey: 'trip_id', as: 'trip' });

// ==================== GROUP RELATIONSHIPS ====================
// Group -> GroupMembers
Group.hasMany(GroupMember, { foreignKey: 'group_id', as: 'members' });
GroupMember.belongsTo(Group, { foreignKey: 'group_id', as: 'group' });

// Group -> TripShares
Group.hasMany(TripShare, { foreignKey: 'group_id', as: 'sharedTrips' });
TripShare.belongsTo(Group, { foreignKey: 'group_id', as: 'group' });

// Profile -> GroupMembers (many-to-many through GroupMember)
Profile.hasMany(GroupMember, { foreignKey: 'user_id', as: 'groupMemberships' });
GroupMember.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// ==================== TRIP SHARE & COMMENTS ====================
// TripShare -> GroupComments
TripShare.hasMany(GroupComment, { foreignKey: 'trip_share_id', as: 'comments' });
GroupComment.belongsTo(TripShare, { foreignKey: 'trip_share_id', as: 'tripShare' });

// Profile -> GroupComments
Profile.hasMany(GroupComment, { foreignKey: 'user_id', as: 'comments' });
GroupComment.belongsTo(Profile, { foreignKey: 'user_id', as: 'user' });

// Profile -> TripShares (shared by)
Profile.hasMany(TripShare, { foreignKey: 'shared_by', as: 'sharedTrips' });
TripShare.belongsTo(Profile, { foreignKey: 'shared_by', as: 'sharedBy' });

// Self-referencing for GroupComment replies
GroupComment.hasMany(GroupComment, { foreignKey: 'parent_comment_id', as: 'replies' });
GroupComment.belongsTo(GroupComment, { foreignKey: 'parent_comment_id', as: 'parentComment' });

// ==================== AI RELATIONSHIPS ====================
// AIRequest -> AIResponse
AIRequest.hasMany(AIResponse, { foreignKey: 'req_id', as: 'responses' });
AIResponse.belongsTo(AIRequest, { foreignKey: 'req_id', as: 'request' });

export {
    Destination,
    DestinationCategory,
    Profile,
    Event,
    Review,
    ReviewHelpful,
    Trip,
    TripDestination,
    TripEvent,
    UserFeedback,
    Notification,
    Group,
    GroupMember,
    TripShare,
    GroupComment,
    AIRequest,
    AIResponse,
    SearchLog
};
