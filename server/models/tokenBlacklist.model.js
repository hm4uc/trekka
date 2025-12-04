import { DataTypes } from 'sequelize';
import sequelize from '../database/db.js';

/**
 * Token Blacklist Model
 * Stores invalidated JWT tokens to prevent reuse after logout
 */
const TokenBlacklist = sequelize.define('TokenBlacklist', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    token: {
        type: DataTypes.TEXT,
        allowNull: false,
        unique: true,
        comment: 'The blacklisted JWT token'
    },
    profileId: {
        type: DataTypes.UUID,
        allowNull: false,
        comment: 'User profile ID associated with the token'
    },
    reason: {
        type: DataTypes.STRING(50),
        allowNull: true,
        defaultValue: 'logout',
        comment: 'Reason for blacklisting (logout, security, etc.)'
    },
    expiresAt: {
        type: DataTypes.DATE,
        allowNull: false,
        comment: 'When the token would have expired naturally'
    },
    blacklistedAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
        comment: 'When the token was blacklisted'
    }
}, {
    timestamps: false,
    tableName: 'token_blacklist',
    indexes: [
        {
            fields: ['token'],
            unique: true
        },
        {
            fields: ['profileId']
        },
        {
            fields: ['expiresAt']
        }
    ]
});

export default TokenBlacklist;

