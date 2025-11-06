// index.js
import express from "express";
import swaggerDocs from "./swagger.js";
import sequelize from "./database/db.js";
import mainRouter from "./routes/main.routes.js";
import authRoutes from "./routes/auth.routes.js";
import { errorHandler } from "./middleware/errorHandler.js";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Thêm CORS middleware
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://10.0.2.2:3000',
    'http://127.0.0.1:3000',
    'http://localhost:5173'
  ],
  credentials: true
}));

app.use(express.json());

// Routes
app.use("/", mainRouter);
app.use("/auth", authRoutes);

// Swagger (⚠️ thêm trước app.listen)
swaggerDocs(app);

// Error handler (đặt cuối cùng)
app.use(errorHandler);

// --- Start Server ---
const startServer = async () => {
    try {
        await sequelize.authenticate();
        console.log("✅ Connected to PostgreSQL");

        await sequelize.sync({ alter: false });
        console.log("✅ Models synced");

        app.listen(PORT, '0.0.0.0', () => {
                    console.log(`🚀 Server running on http://localhost:${PORT}`);
                    console.log(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
                });
    } catch (error) {
        console.error("❌ Database connection error:", error);
    }
};

startServer();
