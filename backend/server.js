// server.js — DK Parking Engine Backend
// Deployed on Render. Connects to Supabase.
// Handles: telemetry ingestion (SS-10) + dataset delivery (SS-04)
// Legal evaluation runs entirely on-device. This server NEVER touches the legal decision path.

require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const telemetryRoutes = require('./src/routes/telemetry');
const datasetRoutes = require('./src/routes/dataset');

const app = express();
const PORT = process.env.PORT || 3000;

// Security headers
app.use(helmet());

// CORS — allow iOS/Android app origin
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'X-API-Key']
}));

// Body parsing
app.use(express.json({ limit: '256kb' }));

// Rate limiting — protect telemetry endpoint
const telemetryLimiter = rateLimit({
  windowMs: 60 * 1000,   // 1 minute
  max: 120,               // 120 requests per minute per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'rate_limit_exceeded' }
});

const datasetLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'rate_limit_exceeded' }
});

// Health check — required by Render
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'dk-parking-backend',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/v1/telemetry', telemetryLimiter, telemetryRoutes);
app.use('/api/v1/dataset', datasetLimiter, datasetRoutes);

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'not_found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('[ERROR]', err.message);
  res.status(500).json({ error: 'internal_server_error' });
});

app.listen(PORT, () => {
  console.log(`[dk-parking-backend] running on port ${PORT}`);
});
