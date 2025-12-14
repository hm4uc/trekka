import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const TripDestination = sequelize.define('TripDestination', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    trip_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'trips',
            key: 'id'
        },
        onDelete: 'CASCADE'
    },
    dest_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'destinations',
            key: 'id'
        }
    },
    visit_order: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    },
    estimated_time: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Thời gian ước tính tại địa điểm (phút)'
    },
    actual_time: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Thời gian thực tế (phút)'
    },
    visit_date: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    start_time: {
        type: DataTypes.TIME,
        allowNull: true,
    },
    notes: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    is_completed: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    travel_distance: {
        type: DataTypes.FLOAT,
        allowNull: true,
        comment: 'Khoảng cách từ điểm trước (km)'
    },
    travel_duration: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Thời gian di chuyển từ điểm trước (phút)'
    },
}, {
    tableName: 'trip_destinations',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['trip_id']
        },
        {
            fields: ['dest_id']
        },
        {
            fields: ['visit_order']
        }
    ]
});

export default TripDestination;

