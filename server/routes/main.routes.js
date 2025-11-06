import express from "express";
import { StatusCodes } from "http-status-codes";

const router = express.Router();

router.get('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'Travel API is running!',
        timestamp: new Date().toISOString()
    });
});

router.get('/health', (req, res) => {
    res.json({
        status: 'success',
        message: 'Server is healthy',
        timestamp: new Date().toISOString()
    });
});

export default router;