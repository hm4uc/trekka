import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const TripEvent = sequelize.define('TripEvent', {
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
    event_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'events',
            key: 'id'
        }
    },
    visit_order: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    },
    notes: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    is_completed: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    reminder_sent: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
}, {
    tableName: 'trip_events',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['trip_id']
        },
        {
            fields: ['event_id']
        }
    ]
});

export default TripEvent;

