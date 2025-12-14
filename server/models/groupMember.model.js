import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const GroupMember = sequelize.define('GroupMember', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    group_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'groups',
            key: 'id'
        },
        onDelete: 'CASCADE'
    },
    user_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'profiles',
            key: 'id'
        }
    },
    role: {
        type: DataTypes.ENUM('admin', 'member'),
        defaultValue: 'member',
    },
    joined_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    tableName: 'group_members',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['group_id']
        },
        {
            fields: ['user_id']
        },
        {
            unique: true,
            fields: ['group_id', 'user_id'],
            name: 'unique_group_member'
        }
    ]
});

export default GroupMember;

