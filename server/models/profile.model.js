import { DataTypes } from 'sequelize';
import sequelize from '../database/db.js';
import {AGE_GROUPS} from "../config/travelConstants.js";

const Profile = sequelize.define('Profile', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    usr_fullname: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    usr_email: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true
        }
    },
    usr_password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    usr_gender: {
        type: DataTypes.TEXT, // Postgres hỗ trợ TEXT tốt
        allowNull: true,
    },
    usr_age_group: {
        type: DataTypes.ENUM(...AGE_GROUPS),
        allowNull: true,
    },
    reset_password_token: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    reset_password_expires: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    usr_preferences: {
        type: DataTypes.ARRAY(DataTypes.TEXT), // Mảng text cho Postgres
        defaultValue: [],
    },
    usr_budget: {
        type: DataTypes.DECIMAL(12, 2), // Số tiền lớn cần chính xác
        allowNull: true,
    },
    usr_avatar: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    usr_bio: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    usr_created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    usr_updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    timestamps: false, // Vì ta đã tự định nghĩa usr_created_at/updated_at
    tableName: 'profiles',
    hooks: {
        beforeUpdate: (profile) => {
            profile.usr_updated_at = new Date();
        }
    }
});

export default Profile;