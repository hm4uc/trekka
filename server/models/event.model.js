import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Event = sequelize.define('Event', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    event_name: {
        type: DataTypes.STRING(255),
        allowNull: false,
        index: true
    },
    event_description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    event_location: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    lat: {
        type: DataTypes.FLOAT,
        allowNull: true,
    },
    lng: {
        type: DataTypes.FLOAT,
        allowNull: true,
    },
    geom: {
        type: DataTypes.GEOMETRY('POINT'),
        allowNull: true,
    },
    event_start: {
        type: DataTypes.DATE,
        allowNull: false
    },
    event_end: {
        type: DataTypes.DATE,
        allowNull: false
    },
    event_ticket_price: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
    },
    event_type: {
        type: DataTypes.STRING(100),
        allowNull: true,
        comment: 'Loại sự kiện: concert, exhibition, festival, workshop...'
    },
    event_organizer: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    event_capacity: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    event_tags: {
        type: DataTypes.ARRAY(DataTypes.TEXT),
        defaultValue: []
    },
    images: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        defaultValue: []
    },
    contact_info: {
        type: DataTypes.JSONB,
        allowNull: true,
    },
    total_attendees: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    total_likes: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    rating: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
    },
    total_reviews: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    is_featured: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
}, {
    tableName: 'events',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['event_start', 'event_end']
        },
        {
            fields: ['lat', 'lng']
        }
    ]
});

export default Event;

