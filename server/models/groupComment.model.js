import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const GroupComment = sequelize.define('GroupComment', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    trip_share_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'trip_shares',
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
    comment: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    parent_comment_id: {
        type: DataTypes.UUID,
        allowNull: true,
        references: {
            model: 'group_comments',
            key: 'id'
        },
        comment: 'Cho phép reply comment'
    },
}, {
    tableName: 'group_comments',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['trip_share_id']
        },
        {
            fields: ['user_id']
        }
    ]
});

export default GroupComment;

