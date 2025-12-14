import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Notification = sequelize.define('Notification', {
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
    noti_type: {
        type: DataTypes.ENUM('reminder', 'progress', 'social', 'system', 'event'),
        allowNull: false,
    },
    noti_title: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    noti_message: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    noti_status: {
        type: DataTypes.ENUM('pending', 'sent', 'read'),
        defaultValue: 'pending',
    },
    noti_data: {
        type: DataTypes.JSONB,
        defaultValue: {},
        comment: 'Dữ liệu bổ sung: trip_id, event_id, link...'
    },
    scheduled_at: {
        type: DataTypes.DATE,
        allowNull: true,
        comment: 'Thời gian dự kiến gửi'
    },
    sent_at: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    read_at: {
        type: DataTypes.DATE,
        allowNull: true,
    },
}, {
    tableName: 'notifications',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['noti_status']
        },
        {
            fields: ['noti_type']
        }
    ]
});

export default Notification;

