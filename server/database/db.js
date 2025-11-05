import { Sequelize, DataTypes } from 'sequelize';
import dotenv from "dotenv"; // Tải các biến từ file .env
dotenv.config();

const isRender = process.env.RENDER === 'true' || process.env.NODE_ENV === 'production';

// 1. Khởi tạo kết nối Sequelize
const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASS,
    {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        logging: console.log,
        dialectOptions: isRender
            ? {
                ssl: {
                    require: true,
                    rejectUnauthorized: false, // ⚠️ bắt buộc cho Render
                },
            }
            : {},
    }
);

// sequelize.sync({ force: true });

export default sequelize;