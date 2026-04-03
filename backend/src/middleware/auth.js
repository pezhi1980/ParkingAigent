// src/middleware/auth.js — API key validation
// Mobile apps send X-API-Key header with each request.
// Key is stored in MOBILE_API_KEY env var on Render.

function requireApiKey(req, res, next) {
  const key = req.headers['x-api-key'];
  const expected = process.env.MOBILE_API_KEY;

  if (!expected) {
    // No key configured — allow (development mode)
    return next();
  }

  if (!key || key !== expected) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  next();
}

module.exports = { requireApiKey };
