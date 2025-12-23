import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const ReviewHelpful = sequelize.define('ReviewHelpful', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    review_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'reviews',
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
        },
        onDelete: 'CASCADE'
    }
}, {
    tableName: 'review_helpful',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            unique: true,
            fields: ['review_id', 'user_id']
        },
        {
            fields: ['user_id']
        },
        {
            fields: ['review_id']
        }
    ]
});

export default ReviewHelpful;

