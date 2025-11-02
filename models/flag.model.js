const {DataTypes} = require("sequelize");
const { sequelize } = require("sequelize");

const Flag = sequelize.define('Flag', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    image_id: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    reason: {
        type: DataTypes.TEXT,
    },
    safe_score: {
        type: DataTypes.REAL,
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
    action_taken: {
        type: DataTypes.ENUM('none', 'auto_quarantine', 'auto_remove', 'manual_review'),
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    timestamps: false,
    tableName: 'flags',
    indexes: [
        { fields: ['image_id'] }
    ]
});

module.exports = Flag;