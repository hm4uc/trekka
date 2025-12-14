import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const Group = sequelize.define('Group', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    group_name: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    group_description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    created_by: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'profiles',
            key: 'id'
        }
    },
    group_avatar: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
}, {
    tableName: 'groups',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['created_by']
        }
    ]
});

export default Group;

