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

// Dynamic CORS configuration
const isProduction = process.env.NODE_ENV === 'production';

// Thêm CORS middleware
app.use(cors({
    origin: function(origin, callback) {
        // Allow requests with no origin (like mobile apps, Postman, or server-to-server)
        if (!origin) return callback(null, true);

        const allowedOrigins = [
            'http://localhost:3000',
            'http://localhost:3001',
            'http://10.0.2.2:3000',
            'http://127.0.0.1:3000',
            'http://localhost:5173',
            'https://trekka-server.onrender.com', // Your Render domain
            'https://your-frontend-domain.com' // Add your frontend domain if you have one
        ];

        if (allowedOrigins.indexOf(origin) !== -1 || isProduction) {
            callback(null, true);
        } else {
            console.log('Blocked by CORS:', origin);
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
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

        app.listen(PORT, () => {
            console.log(`🚀 Server running on port ${PORT}`);
            console.log(`🏠 Environment: ${process.env.NODE_ENV || 'development'}`);
            console.log(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
        });
    } catch (error) {
        console.error("❌ Database connection error:", error);
    }
};

startServer();
