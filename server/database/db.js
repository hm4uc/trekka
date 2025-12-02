import { Sequelize, DataTypes } from 'sequelize';
import dotenv from "dotenv"; // Tải các biến từ file .env
dotenv.config();

const isProduction = process.env.NODE_ENV === 'production';
// Kiểm tra xem có đang deploy trên Render không
const isRender = process.env.RENDER === 'true' || isProduction;
// Kiểm tra xem host có phải là Neon không (để bật SSL khi chạy local)
const isNeon = process.env.DB_HOST && process.env.DB_HOST.includes('neon.tech');

// 1. Khởi tạo kết nối Sequelize
const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASS,
    {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'postgres',
        logging: isProduction ? false : console.log,
        dialectOptions: (isRender || isNeon) // ⚠️ Bật SSL nếu là Render HOẶC Neon
            ? {
                ssl: {
                    require: true,
                    rejectUnauthorized: false, // Chấp nhận chứng chỉ tự ký của Neon
                },
            }
            : {},
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000,
        },
    }
);

// sequelize.sync({ force: true });

export default sequelize;