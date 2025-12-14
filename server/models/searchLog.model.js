import {DataTypes} from 'sequelize';
import sequelize from '../database/db.js';

const SearchLog = sequelize.define('SearchLog', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    user_id: {
        type: DataTypes.UUID,
        allowNull: true,
        references: {
            model: 'profiles',
            key: 'id'
        }
    },
    query: {
        type: DataTypes.STRING(500),
        allowNull: false,
    },
    context: {
        type: DataTypes.JSONB,
        defaultValue: {},
        comment: 'Weather, mood, transport, location...'
    },
    filters: {
        type: DataTypes.JSONB,
        defaultValue: {},
        comment: 'Category, price range, status...'
    },
    results: {
        type: DataTypes.ARRAY(DataTypes.UUID),
        defaultValue: [],
        comment: 'Danh sách dest_id trả về'
    },
    result_count: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    clicked_result_id: {
        type: DataTypes.UUID,
        allowNull: true,
        comment: 'ID của kết quả người dùng click vào'
    },
    clicked_position: {
        type: DataTypes.INTEGER,
        allowNull: true,
        comment: 'Vị trí trong kết quả (dùng tính CTR)'
    },
}, {
    tableName: 'search_logs',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['user_id']
        },
        {
            fields: ['query']
        }
    ]
});

export default SearchLog;

