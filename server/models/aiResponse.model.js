import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const AIResponse = sequelize.define('AIResponse', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    req_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'ai_requests',
            key: 'id'
        }
    },
    response_json: {
        type: DataTypes.JSONB,
        allowNull: false,
        comment: 'Output từ AI model'
    },
    model_version: {
        type: DataTypes.STRING(100),
        allowNull: true,
    },
    latency_ms: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Thời gian xử lý (ms)'
    },
    success: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    error_message: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    res_created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    tableName: 'ai_responses',
    timestamps: false,
    underscored: true,
    indexes: [
        {
            fields: ['req_id']
        },
        {
            fields: ['success']
        }
    ]
});

export default AIResponse;

