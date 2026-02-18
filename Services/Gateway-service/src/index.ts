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

// Placeholder for future services
// app.use('/api/cattle', createProxyMiddleware({
//   target: process.env.CATTLE_SERVICE_URL || 'http://localhost:5002',
//   changeOrigin: true,
// }));

app.get('/health', (req, res) => {
    res.json({ status: 'Gateway is healthy' });
});

app.listen(port, () => {
    console.log(`[gateway-service]: Gateway is running at http://localhost:${port}`);
});
