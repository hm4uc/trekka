import {Op, fn, col, literal} from 'sequelize';
import {Destination, DestinationCategory, UserFeedback} from '../models/associations.js';
import {isValidTravelStyle} from '../config/travelConstants.js';

async function getAllDestinations({
                                      page = 1,
                                      limit = 10,
                                      search,
                                      categoryId,
                                      minPrice,
                                      maxPrice,
                                      lat,
                                      lng,
                                      radius = 5000,
                                      isOpenNow,
                                      context,
                                      sortBy = 'distance',
                                      hiddenGemsOnly = false
                                  }) {
    const offset = (page - 1) * limit;
    const whereClause = {is_active: true};

    // Tạo order clause dựa trên sortBy
    let orderClause = [['createdAt', 'DESC']];

    // Nếu có tọa độ, tính khoảng cách
    if (lat && lng) {
        // Thêm cột khoảng cách ảo
        whereClause.geom = {
            [Op.not]: null
        };

        // Tính distance bằng PostGIS
        const distanceLiteral = literal(
            `ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography)`
        );

        if (sortBy === 'distance') {
            orderClause = [[distanceLiteral, 'ASC']];
        }

        // Filter theo bán kính
        if (radius) {
            whereClause.geom = {
                [Op.and]: [
                    {[Op.not]: null},
                    literal(
                        `ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, ${radius})`
                    )
                ]
            };
        }
    }

    // Các sort options khác
    switch(sortBy) {
        case 'rating':
            orderClause = [['rating', 'DESC'], ['total_reviews', 'DESC']];
            break;
        case 'price_asc':
            orderClause = [['avg_cost', 'ASC']];
            break;
        case 'price_desc':
            orderClause = [['avg_cost', 'DESC']];
            break;
        case 'popularity':
            orderClause = [['total_likes', 'DESC'], ['total_checkins', 'DESC']];
            break;
    }

    // Filter theo tên (tìm kiếm tương đối)
    if (search) {
        whereClause.name = {[Op.iLike]: `%${search}%`};
    }

    // Filter theo danh mục
    if (categoryId) {
        whereClause.categoryId = categoryId;
    }

    // Filter theo khoảng giá
    if (minPrice !== undefined || maxPrice !== undefined) {
        whereClause.avg_cost = {};
        if (minPrice) whereClause.avg_cost[Op.gte] = minPrice;
        if (maxPrice) whereClause.avg_cost[Op.lte] = maxPrice;
    }

    // Filter theo hidden gems
    if (hiddenGemsOnly) {
        whereClause.is_hidden_gem = true;
    }

    // Filter theo context (thông qua category)
    let includeOptions = [
        {
            model: DestinationCategory,
            as: 'category',
            attributes: ['id', 'name', 'icon', 'context_tags', 'travel_style_id']
        }
    ];

    if (context) {
        includeOptions[0].where = {
            context_tags: {
                [Op.contains]: [context]
            }
        };
    }

    const {count, rows} = await Destination.findAndCountAll({
        where: whereClause,
        include: includeOptions,
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

async function getDestinationById(id) {
    const destination = await Destination.findOne({
        where: {id, is_active: true},
        include: [
            {
                model: DestinationCategory,
                as: 'category',
                attributes: ['id', 'name', 'icon', 'description', 'travel_style_id', 'context_tags']
            }
        ]
    });

    if (!destination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    return destination;
}

async function getNearbyDestinations(id, {limit = 5, radius = 2000}) {
    // Lấy destination hiện tại để lấy tọa độ
    const currentDestination = await Destination.findOne({
        where: {id, is_active: true},
        attributes: ['lat', 'lng', 'geom']
    });

    if (!currentDestination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    const {lat, lng} = currentDestination;

    const nearbyDestinations = await Destination.findAll({
        where: {
            id: {[Op.ne]: id},
            is_active: true,
            geom: literal(
                `ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, ${radius})`
            )
        },
        include: [
            {
                model: DestinationCategory,
                as: 'category',
                attributes: ['id', 'name', 'icon']
            }
        ],
        limit,
        order: [
            [literal(
                `ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography)`
            ), 'ASC']
        ]
    });

    return nearbyDestinations;
}

async function getAllCategories() {
    return await DestinationCategory.findAll({
        where: {is_active: true},
        order: [['name', 'ASC']]
    });
}

async function getCategoriesByTravelStyle(travelStyle) {
    // Validate travel style
    if (!isValidTravelStyle(travelStyle)) {
        const error = new Error('Invalid travel style');
        error.statusCode = 400;
        throw error;
    }

    return await DestinationCategory.findAll({
        where: {
            travel_style_id: travelStyle,
            is_active: true
        },
        order: [['popularity_score', 'DESC']]
    });
}

async function getAiPicks(userId, {lat, lng, limit = 10}) {
    // TODO: Implement AI recommendation logic based on:
    // 1. User preferences from profile
    // 2. User interaction history
    // 3. Current location and context
    // 4. Popular destinations

    // For now, return popular destinations near location
    const whereClause = {
        is_active: true,
        is_featured: true
    };

    let orderClause = [['total_likes', 'DESC'], ['rating', 'DESC']];

    if (lat && lng) {
        whereClause.geom = literal(
            `ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, 10000)`
        );
        orderClause = [
            [literal(
                `ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography)`
            ), 'ASC'],
            ['total_likes', 'DESC']
        ];
    }

    return await Destination.findAll({
        where: whereClause,
        include: [
            {
                model: DestinationCategory,
                as: 'category',
                attributes: ['id', 'name', 'icon']
            }
        ],
        limit,
        order: orderClause
    });
}

// Interaction functions
async function likeDestination(id, userId) {
    const destination = await Destination.findOne({
        where: {id, is_active: true}
    });

    if (!destination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if user already liked this destination
    const existingLike = await UserFeedback.findOne({
        where: {
            user_id: userId,
            target_id: id,
            feedback_target_type: 'destination',
            feedback_type: 'like'
        }
    });

    if (existingLike) {
        // Unlike - remove the feedback
        await existingLike.destroy();
        await destination.decrement('total_likes');

        return {
            ...destination.toJSON(),
            isLiked: false
        };
    } else {
        // Like - create new feedback
        await UserFeedback.create({
            user_id: userId,
            target_id: id,
            feedback_target_type: 'destination',
            feedback_type: 'like'
        });

        await destination.increment('total_likes');

        return {
            ...destination.toJSON(),
            isLiked: true
        };
    }
}

async function checkinDestination(id, userId) {
    const destination = await Destination.findOne({
        where: {id, is_active: true}
    });

    if (!destination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    // Check if already checked in
    const existingCheckin = await UserFeedback.findOne({
        where: {
            user_id: userId,
            target_id: id,
            feedback_target_type: 'destination',
            feedback_type: 'checkin'
        }
    });

    if (existingCheckin) {
        const error = new Error('Already checked in at this destination');
        error.statusCode = 400;
        throw error;
    }

    // Create check-in record
    await UserFeedback.create({
        user_id: userId,
        target_id: id,
        feedback_target_type: 'destination',
        feedback_type: 'checkin',
        metadata: {
            checkin_time: new Date(),
            lat: destination.lat,
            lng: destination.lng
        }
    });

    await destination.increment('total_checkins');

    return destination;
}

// Admin functions
async function createDestination(data) {
    // If lat/lng provided, create geom
    if (data.lat && data.lng) {
        data.geom = literal(`ST_SetSRID(ST_MakePoint(${data.lng}, ${data.lat}), 4326)`);
    }

    return await Destination.create(data);
}

async function updateDestination(id, data) {
    const destination = await Destination.findOne({
        where: {id}
    });

    if (!destination) {
        const error = new Error('Destination not found');
        error.statusCode = 404;
        throw error;
    }

    // Update geom if lat/lng changed
    if ((data.lat && data.lat !== destination.lat) ||
        (data.lng && data.lng !== destination.lng)) {
        data.geom = literal(`ST_SetSRID(ST_MakePoint(${data.lng || destination.lng}, ${data.lat || destination.lat}), 4326)`);
    }

    await destination.update(data);
    return destination;
}

export default {
    getAllDestinations,
    getDestinationById,
    getNearbyDestinations,
    getAllCategories,
    getCategoriesByTravelStyle,
    getAiPicks,
    likeDestination,
    checkinDestination,
    createDestination,
    updateDestination
};