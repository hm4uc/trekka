import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const AIRequest = sequelize.define('AIRequest', {
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
    request_type: {
        type: DataTypes.ENUM('trip_plan', 'suggestion', 'summary', 'chat', 'vision'),
        allowNull: false,
    },
    payload: {
        type: DataTypes.JSONB,
        allowNull: false,
        comment: 'Input data: destination, days, budget, preferences...'
    },
    model_name: {
        type: DataTypes.STRING(100),
        allowNull: true,
        comment: 'Tên model được sử dụng'
    },
    req_created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    tableName: 'ai_requests',
    timestamps: false,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['request_type']
        },
        {
            fields: ['req_created_at']
        }
    ]
});

export default AIRequest;

