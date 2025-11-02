const {DataTypes} = require('sequelize');
const {sequelize} = require('../database/db');

const Image = sequelize.define('Image', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    uploader_id: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    image_url: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    description: {
        type: DataTypes.TEXT,
    },
    safe_score: {
        type: DataTypes.REAL, // Kiểu 'real' trong SQL
    },
    risk_level: {
        type: DataTypes.ENUM('low', 'medium', 'high'),
    },
    adult_level: {
        type: DataTypes.ENUM('UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY'),
    },
    violence_level: {
        type: DataTypes.ENUM('UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY'),
    },
    racy_level: {
        type: DataTypes.ENUM('UNKNOWN', 'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY'),
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    total_views: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    total_likes: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    status: {
        type: DataTypes.ENUM('pending', 'public', 'quarantined', 'removed'),
        defaultValue: 'pending',
    },
}, {
    timestamps: false,
    tableName: 'images',
    indexes: [ // Thêm index như trong schema
        {fields: ['uploader_id']}
    ]
});

module.exports = Image;