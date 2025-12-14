import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Review = sequelize.define('Review', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    user_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'profiles',
            key: 'id'
        }
    },
    dest_id: {
        type: DataTypes.UUID,
        allowNull: true,
        references: {
            model: 'destinations',
            key: 'id'
        }
    },
    event_id: {
        type: DataTypes.UUID,
        allowNull: true,
        references: {
            model: 'events',
            key: 'id'
        }
    },
    rating: {
        type: DataTypes.INTEGER,
        allowNull: false,
        validate: {
            min: 1,
            max: 5
        }
    },
    comment: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    sentiment: {
        type: DataTypes.ENUM('positive', 'negative', 'neutral'),
        allowNull: true,
        comment: 'AI sentiment analysis result'
    },
    images: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        defaultValue: []
    },
    helpful_count: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    is_verified_visit: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Người dùng đã check-in tại đây'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
}, {
    tableName: 'reviews',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['dest_id']
        },
        {
            fields: ['event_id']
        },
        {
            fields: ['rating']
        }
    ]
});

export default Review;

