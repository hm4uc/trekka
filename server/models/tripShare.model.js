import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const TripShare = sequelize.define('TripShare', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    trip_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'trips',
            key: 'id'
        },
        onDelete: 'CASCADE'
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
    shared_by: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'profiles',
            key: 'id'
        }
    },
    shared_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    message: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
}, {
    tableName: 'trip_shares',
    timestamps: false,
    underscored: true,
    indexes: [
        {
            fields: ['trip_id']
        },
        {
            fields: ['group_id']
        },
        {
            unique: true,
            fields: ['trip_id', 'group_id'],
            name: 'unique_trip_share'
        }
    ]
});

export default TripShare;

