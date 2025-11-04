// index.js
import express from "express";
import swaggerDocs from "./swagger.js";
import sequelize from "./database/db.js";
import mainRouter from "./routes/main.routes.js";
import authRoutes from "./routes/auth.routes.js";
import { errorHandler } from "./middleware/errorHandler.js";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

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

        app.listen(PORT, () => {
            console.log(`🚀 Server running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error("❌ Database connection error:", error);
    }
};

startServer();
