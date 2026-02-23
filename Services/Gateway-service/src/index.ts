import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger.js';
import { createProxyMiddleware } from 'http-proxy-middleware';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// Swagger Documentation
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Proxy Routes
app.use('/api/auth', createProxyMiddleware({
    target: process.env.AUTH_SERVICE_URL || 'http://localhost:5001',
    changeOrigin: true
}));

// Animal Service Proxy
app.use('/api/animal', createProxyMiddleware({
    target: process.env.ANIMAL_SERVICE_URL || 'http://localhost:5002',
    changeOrigin: true
}));

// Health Service Proxy
app.use('/api/health', createProxyMiddleware({
    target: process.env.HEALTH_SERVICE_URL || 'http://localhost:5003',
    changeOrigin: true
}));

// Production Service Proxy
app.use('/api/production', createProxyMiddleware({
    target: process.env.PRODUCTION_SERVICE_URL || 'http://localhost:5004',
    changeOrigin: true
}));


app.listen(port, () => {
    console.log(`[gateway-service]: Gateway is running at http://localhost:${port}`);
});
