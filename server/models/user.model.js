import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const User = sequelize.define('User', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4, // Tự động tạo UUID
        primaryKey: true,
    },
    name: {
        type: DataTypes.STRING(255),
    },
    email: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
    },
    password_hash: { // FIELD FOR AUTHENTICATION
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    avatar_url: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    timestamps: false, // Tắt 'createdAt' và 'updatedAt' tự động của Sequelize
    tableName: 'users',
});

export default {User};