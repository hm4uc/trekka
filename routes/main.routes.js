const express = require("express");
const { StatusCodes } = require("http-status-codes");

const router = express.Router();

router.get('/hello', (req, res) => {
    res.status(StatusCodes.OK).send({
        status: "success",
        message: "Hello World!",
        timestamp: new Date().toISOString(),
    });
});

module.exports = router;