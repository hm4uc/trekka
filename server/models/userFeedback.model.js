import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const UserFeedback = sequelize.define('UserFeedback', {
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
    feedback_target_type: {
        type: DataTypes.ENUM('destination', 'event'),
        allowNull: false,
    },
    target_id: {
        type: DataTypes.UUID,
        allowNull: false,
        comment: 'ID của destination hoặc event'
    },
    feedback_type: {
        type: DataTypes.ENUM('like', 'checkin'),
        allowNull: false,
    },
    metadata: {
        type: DataTypes.JSONB,
        defaultValue: {},
        comment: 'Thông tin bổ sung: thời gian check-in, vị trí...'
    },
}, {
    tableName: 'user_feedback',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['target_id']
        },
        {
            fields: ['feedback_type']
        },
        {
            unique: true,
            fields: ['user_id', 'target_id', 'feedback_type'],
            name: 'unique_user_feedback'
        }
    ]
});

export default UserFeedback;

