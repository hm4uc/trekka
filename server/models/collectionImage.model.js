const {DataTypes} = require('sequelize');
const {sequelize} = require('../database/db');

// Bảng CollectionImages (Bảng nối Many-to-Many)
// Sequelize sẽ tự tạo bảng này khi dùng 'belongsToMany'
// Chúng ta không cần định nghĩa model cho nó trừ khi có thêm cột (ví dụ: 'added_at')
// Tuy nhiên, để bám sát schema, chúng ta sẽ định nghĩa nó rõ ràng
const CollectionImage = sequelize.define('CollectionImage', {
    collection_id: {
        type: DataTypes.UUID,
        primaryKey: true,
    },
    image_id: {
        type: DataTypes.UUID,
        primaryKey: true,
    },
}, {
    timestamps: false,
    tableName: 'collection_images',
});

module.exports = CollectionImage;