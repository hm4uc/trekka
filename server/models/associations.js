import Destination from './destination.model.js';
import DestinationCategory from './destinationCategory.model.js';

// Định nghĩa quan hệ
// 1 Category có nhiều Destination
DestinationCategory.hasMany(Destination, { foreignKey: 'categoryId', as: 'destinations' });

// 1 Destination thuộc về 1 Category
Destination.belongsTo(DestinationCategory, { foreignKey: 'categoryId', as: 'category' });

export { Destination, DestinationCategory };