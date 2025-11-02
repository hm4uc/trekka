const { Sequelize, DataTypes } = require('sequelize');
require('dotenv').config(); // Tải các biến từ file .env

// 1. Khởi tạo kết nối Sequelize
const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASS,
    {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        logging: console.log
    }
);

// sequelize.sync({ force: true });

module.exports = { sequelize };