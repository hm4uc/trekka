import express from "express";
import { StatusCodes } from "http-status-codes";

const router = express.Router();

router.get('/hello', (req, res) => {
    res.status(StatusCodes.OK).send({
        status: "success",
        message: "Hello World!",
        timestamp: new Date().toISOString(),
    });
});

export default router;