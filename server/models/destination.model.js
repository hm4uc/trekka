import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Destination = sequelize.define('Destination', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    categoryId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'destination_categories',
            key: 'id'
        }
    },
    name: {
        type: DataTypes.STRING(255),
        allowNull: false,
        index: true // Thêm index để tìm kiếm nhanh
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    address: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    // Sử dụng PostGIS cho query không gian nâng cao
    lat: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    lng: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    // Thêm trường geometry cho PostGIS
    geom: {
        type: DataTypes.GEOMETRY('POINT'),
        allowNull: true,
    },
    avg_cost: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
    },
    rating: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
        validate: {min: 0, max: 5}
    },
    total_reviews: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    total_likes: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    total_checkins: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    tags: {
        type: DataTypes.ARRAY(DataTypes.TEXT),
        defaultValue: []
    },
    opening_hours: {
        type: DataTypes.JSONB,
        allowNull: true,
    },
    images: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        defaultValue: []
    },
    // Thêm các trường mới cho AI và gamification
    ai_summary: {
        type: DataTypes.TEXT,
        allowNull: true,
        comment: 'Tóm tắt AI về địa điểm'
    },
    best_time_to_visit: {
        type: DataTypes.STRING(100),
        allowNull: true,
        comment: 'Thời gian tốt nhất để ghé thăm'
    },
    recommended_duration: {
        type: DataTypes.INTEGER,
        defaultValue: 60,
        comment: 'Thời gian đề xuất (phút)'
    },
    is_hidden_gem: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Có phải là địa điểm ít người biết không'
    },
    challenge_tags: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        defaultValue: [],
        comment: 'Tag cho thử thách gamification'
    },
    seasonality: {
        type: DataTypes.JSONB,
        allowNull: true,
        comment: 'Thông tin mùa vụ: {summer: true, winter: false, ...}'
    },
    accessibility: {
        type: DataTypes.JSONB,
        allowNull: true,
        comment: 'Thông tin tiếp cận: {wheelchair: true, parking: true, ...}'
    },
    contact_info: {
        type: DataTypes.JSONB,
        allowNull: true,
        comment: 'Thông tin liên hệ: {phone: "...", website: "...", email: "..."}'
    },
    social_media: {
        type: DataTypes.JSONB,
        allowNull: true,
        comment: 'Mạng xã hội: {facebook: "...", instagram: "...", tiktok: "..."}'
    },
    is_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Đã được xác minh'
    },
    is_featured: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Địa điểm nổi bật'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    metadata: {
        type: DataTypes.JSONB,
        defaultValue: {},
        comment: 'Metadata cho AI và analytics'
    }
}, {
    tableName: 'destinations',
    timestamps: true,
    // Thêm hooks để tự động tạo geometry từ lat/lng
    hooks: {
        beforeCreate: async (destination, options) => {
            if (destination.lat && destination.lng) {
                destination.geom = sequelize.fn('ST_SetSRID',
                    sequelize.fn('ST_MakePoint', destination.lng, destination.lat),
                    4326
                );
            }
        },
        beforeUpdate: async (destination, options) => {
            if (destination.changed('lat') || destination.changed('lng')) {
                destination.geom = sequelize.fn('ST_SetSRID',
                    sequelize.fn('ST_MakePoint', destination.lng, destination.lat),
                    4326
                );
            }
        }
    }
});

export default Destination;