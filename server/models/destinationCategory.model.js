import { DataTypes } from 'sequelize';
import sequelize from '../database/db.js';

const DestinationCategory = sequelize.define('DestinationCategory', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    name: {
        type: DataTypes.STRING(100),
        allowNull: false,
        unique: true,
        comment: 'Tên danh mục: Cafe, Museum, Park...'
    },
    icon: {
        type: DataTypes.STRING(50),
        allowNull: true,
        comment: 'Icon name (font awesome) hoặc url icon'
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    travel_style_id: {
        type: DataTypes.STRING(50),
        allowNull: true,
        comment: 'Liên kết với travel style trong travelConstants.js'
    },
    context_tags: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        defaultValue: [],
        comment: 'Phù hợp với ngữ cảnh: solo, couple, family, friends'
    },
    popularity_score: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
        comment: 'Điểm đánh giá độ phổ biến'
    },
    avg_visit_duration: {
        type: DataTypes.INTEGER,
        defaultValue: 60,
        comment: 'Thời gian tham quan trung bình (phút)'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, {
    tableName: 'destination_categories',
    timestamps: true,
    underscored: true
});

export default DestinationCategory;