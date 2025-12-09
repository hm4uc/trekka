import { DataTypes } from 'sequelize';
import sequelize from '../database/db.js';

const TokenBlacklist = sequelize.define('TokenBlacklist', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    token: {
        type: DataTypes.TEXT,
        allowNull: false,
        comment: 'The blacklisted JWT token'
    },
    expiresAt: {
        type: DataTypes.DATE,
        allowNull: false,
        comment: 'When the token expires'
    },
    profileId: {
        type: DataTypes.UUID,
        allowNull: true,
        comment: 'User who owns this token (if available)'
    }
}, {
    tableName: 'token_blacklist',
    timestamps: true,
    indexes: [
        {
            unique: true,
            fields: ['token']
        },
        {
            fields: ['expiresAt']
        }
    ]
});

export default TokenBlacklist;