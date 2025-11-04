import { DataTypes } from 'sequelize';
import sequelize from '../database/db.js';

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
    },
    usr_password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    usr_gender: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    usr_age: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    usr_job: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    usr_preferences: {
        type: DataTypes.ARRAY(DataTypes.TEXT),
        defaultValue: [],
    },
    usr_budget: {
        type: DataTypes.DECIMAL(12, 2),
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
    timestamps: false,
    tableName: 'profiles',
});

export default Profile;