import {Review, Destination, Event, Profile, ReviewHelpful} from '../models/associations.js';

// Create review
async function createReview(userId, {destId, eventId, rating, comment, images}) {
    // Convert empty strings to null
    const cleanDestId = destId && destId.trim() !== '' ? destId : null;
    const cleanEventId = eventId && eventId.trim() !== '' ? eventId : null;

    if (!cleanDestId && !cleanEventId) {
        const error = new Error('Either destId or eventId must be provided');
        error.statusCode = 400;
        throw error;
    }

    if (cleanDestId && cleanEventId) {
        const error = new Error('Cannot review both destination and event at once');
        error.statusCode = 400;
        throw error;
    }

    // Check if destination/event exists
    if (cleanDestId) {
        const destination = await Destination.findOne({where: {id: cleanDestId}});
        if (!destination) {
            const error = new Error('Destination not found');
            error.statusCode = 404;
            throw error;
        }
    }

    if (cleanEventId) {
        const event = await Event.findOne({where: {id: cleanEventId}});
        if (!event) {
            const error = new Error('Event not found');
            error.statusCode = 404;
            throw error;
        }
    }

    // TODO: Add sentiment analysis here
    const sentiment = analyzeSentiment(comment);

    const review = await Review.create({
        user_id: userId,
        dest_id: cleanDestId,
        event_id: cleanEventId,
        rating,
        comment,
        images: images || [],
        sentiment
    });

    // Update destination/event rating
    if (cleanDestId) {
        await updateDestinationRating(cleanDestId);
    }

    if (cleanEventId) {
        await updateEventRating(cleanEventId);
    }

    return review;
}

// Helper function for sentiment analysis (placeholder)
function analyzeSentiment(comment) {
    if (!comment) return 'neutral';

    // TODO: Integrate with AI sentiment analysis
    // For now, simple keyword-based detection
    const positiveWords = ['tuyệt', 'đẹp', 'ngon', 'tốt', 'hay', 'xuất sắc', 'tốt', 'thích'];
    const negativeWords = ['tệ', 'xấu', 'dở', 'kém', 'không tốt', 'thất vọng'];

    const lowerComment = comment.toLowerCase();

    const hasPositive = positiveWords.some(word => lowerComment.includes(word));
    const hasNegative = negativeWords.some(word => lowerComment.includes(word));

    if (hasPositive && !hasNegative) return 'positive';
    if (hasNegative && !hasPositive) return 'negative';
    return 'neutral';
}

// Update destination rating
async function updateDestinationRating(destId) {
    const reviews = await Review.findAll({
        where: {dest_id: destId, is_active: true}
    });

    if (reviews.length === 0) {
        await Destination.update(
            {
                rating: 0,
                total_reviews: 0
            },
            {where: {id: destId}}
        );
        return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const avgRating = totalRating / reviews.length;

    await Destination.update(
        {
            rating: avgRating,
            total_reviews: reviews.length
        },
        {where: {id: destId}}
    );
}

// Update event rating
async function updateEventRating(eventId) {
    const reviews = await Review.findAll({
        where: {event_id: eventId, is_active: true}
    });

    if (reviews.length === 0) {
        await Event.update(
            {
                rating: 0,
                total_reviews: 0
            },
            {where: {id: eventId}}
        );
        return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const avgRating = totalRating / reviews.length;

    await Event.update(
        {
            rating: avgRating,
            total_reviews: reviews.length
        },
        {where: {id: eventId}}
    );
}

// Get reviews for destination
async function getDestinationReviews(destId, {page = 1, limit = 10, sortBy = 'recent'}) {
    const offset = (page - 1) * limit;

    let orderClause = [['createdAt', 'DESC']];

    if (sortBy === 'rating_high') {
        orderClause = [['rating', 'DESC']];
    } else if (sortBy === 'rating_low') {
        orderClause = [['rating', 'ASC']];
    } else if (sortBy === 'helpful') {
        orderClause = [['helpful_count', 'DESC']];
    }

    const {count, rows} = await Review.findAndCountAll({
        where: {dest_id: destId, is_active: true},
        include: [
            {
                model: Profile,
                as: 'user',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
            }
        ],
        limit,
        offset,
        order: orderClause
    });

    return {
        total: count,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        data: rows
    };
}

// Get reviews for event
async function getEventReviews(eventId, {page = 1, limit = 10}) {
    const offset = (page - 1) * limit;

    const {count, rows} = await Review.findAndCountAll({
        where: {event_id: eventId, is_active: true},
        include: [
            {
                model: Profile,
                as: 'user',
                attributes: ['id', 'usr_fullname', 'usr_avatar']
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

// Get user reviews
async function getUserReviews(userId, {page = 1, limit = 10}) {
    const offset = (page - 1) * limit;

    const {count, rows} = await Review.findAndCountAll({
        where: {user_id: userId, is_active: true},
        include: [
            {
                model: Destination,
                as: 'destination',
                attributes: ['id', 'name', 'images']
            },
            {
                model: Event,
                as: 'event',
                attributes: ['id', 'event_name']
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

// Update review
async function updateReview(reviewId, userId, {rating, comment, images}) {
    const review = await Review.findOne({
        where: {id: reviewId, user_id: userId}
    });

    if (!review) {
        const error = new Error('Review not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    const sentiment = comment ? analyzeSentiment(comment) : review.sentiment;

    await review.update({
        rating: rating || review.rating,
        comment: comment || review.comment,
        images: images || review.images,
        sentiment
    });

    // Update rating if destination or event
    if (review.dest_id) {
        await updateDestinationRating(review.dest_id);
    }

    if (review.event_id) {
        await updateEventRating(review.event_id);
    }

    return review;
}

// Delete review
async function deleteReview(reviewId, userId) {
    const review = await Review.findOne({
        where: {id: reviewId, user_id: userId}
    });

    if (!review) {
        const error = new Error('Review not found or access denied');
        error.statusCode = 404;
        throw error;
    }

    const destId = review.dest_id;
    const eventId = review.event_id;

    await review.destroy();

    // Update rating if destination or event
    if (destId) {
        await updateDestinationRating(destId);
    }

    if (eventId) {
        await updateEventRating(eventId);
    }

    return {message: 'Review deleted successfully'};
}

// Mark review as helpful (toggle)
async function markReviewHelpful(reviewId, userId) {
    const review = await Review.findOne({where: {id: reviewId}});

    if (!review) {
        const error = new Error('Review not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user already marked this review as helpful
    const existingMark = await ReviewHelpful.findOne({
        where: {
            review_id: reviewId,
            user_id: userId
        }
    });

    if (existingMark) {
        // Remove the helpful mark (toggle off)
        await existingMark.destroy();
        await review.decrement('helpful_count');

        // Reload to get updated count
        await review.reload();

        return {
            message: 'Đã hủy đánh dấu hữu ích',
            isHelpful: false,
            helpfulCount: review.helpful_count
        };
    } else {
        // Add helpful mark (toggle on)
        await ReviewHelpful.create({
            review_id: reviewId,
            user_id: userId
        });
        await review.increment('helpful_count');

        // Reload to get updated count
        await review.reload();

        return {
            message: 'Đã đánh dấu là hữu ích',
            isHelpful: true,
            helpfulCount: review.helpful_count
        };
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

