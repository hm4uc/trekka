import swaggerJsDoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";

const options = {
    definition: {
        openapi: "3.0.0",
        info: {
            title: "Trekka API Docs",
            version: "1.0.0",
            description: "API documentation for Trekka backend",
        },
        servers: [
            {
                url: "http://localhost:3000",
                description: "Local Dev Server",
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: "http",
                    scheme: "bearer",
                    bearerFormat: "JWT",
                },
            },
        },
    },
    apis: ["./routes/*.js"], // nơi bạn viết mô tả endpoint bằng comment Swagger
};

const swaggerSpec = swaggerJsDoc(options);

export default function swaggerDocs(app) {
    app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
    console.log("📘 Swagger UI running at: http://localhost:3000/api-docs");
}
