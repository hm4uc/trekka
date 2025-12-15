import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Trip = sequelize.define('Trip', {
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
    trip_title: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    trip_description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    trip_start_date: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    trip_end_date: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    trip_budget: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
    },
    trip_actual_cost: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
    },
    trip_status: {
        type: DataTypes.ENUM('draft', 'active', 'completed', 'cancelled'),
        defaultValue: 'draft',
    },
    trip_transport: {
        type: DataTypes.ENUM('walking', 'bike', 'motorbike', 'car', 'bus', 'taxi', 'mixed'),
        defaultValue: 'walking',
    },
    trip_type: {
        type: DataTypes.ENUM('solo', 'couple', 'family', 'friends', 'group'),
        defaultValue: 'solo',
    },
    participant_count: {
        type: DataTypes.INTEGER,
        defaultValue: 1,
        validate: {
            min: 1
        },
        comment: 'Số lượng người tham gia chuyến đi'
    },
    visibility: {
        type: DataTypes.ENUM('private', 'friends', 'public'),
        defaultValue: 'private',
    },
    cover_image: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    tags: {
        type: DataTypes.ARRAY(DataTypes.TEXT),
        defaultValue: []
    },
    ai_generated: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Lịch trình được tạo bởi AI'
    },
    ai_request_id: {
        type: DataTypes.UUID,
        allowNull: true,
        comment: 'Liên kết với bảng ai_requests'
    },
    is_template: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        comment: 'Có phải template để dùng lại không'
    },
    total_distance: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
        comment: 'Tổng quãng đường (km)'
    },
    total_duration: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        comment: 'Tổng thời gian (phút)'
    },
    metadata: {
        type: DataTypes.JSONB,
        defaultValue: {},
    },
}, {
    tableName: 'trips',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['trip_status']
        },
        {
            fields: ['trip_start_date', 'trip_end_date']
        }
    ]
});

export default Trip;

