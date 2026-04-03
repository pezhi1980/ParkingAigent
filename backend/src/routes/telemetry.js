// src/routes/telemetry.js
// POST /api/v1/telemetry/batch — receives structured telemetry events from iOS/Android
// Per privacy_and_telemetry_spec.md: no camera, no GPS, no user identifiers.
// Legal evaluation runs on-device. This endpoint only stores structured metadata.

const express = require('express');
const router = express.Router();
const supabase = require('../lib/supabase');
const { requireApiKey } = require('../middleware/auth');

// Allowed event types per privacy_and_telemetry_spec.md §3
const ALLOWED_EVENT_TYPES = new Set([
  'evaluation_completed',
  'session_started',
  'session_ended',
  'refusal_explainer_shown'
]);

// Forbidden fields — must never be stored
const FORBIDDEN_FIELDS = [
  'camera_frame', 'image', 'frame_data', 'ar_point_cloud', 'ar_mesh',
  'gps', 'latitude', 'longitude', 'location', 'coordinates',
  'device_id', 'idfa', 'idfv', 'serial', 'user_id', 'email'
];

function stripForbiddenFields(payload) {
  const cleaned = { ...payload };
  for (const field of FORBIDDEN_FIELDS) {
    delete cleaned[field];
  }
  return cleaned;
}

function validateEvent(event) {
  if (!event || typeof event !== 'object') return false;
  if (!ALLOWED_EVENT_TYPES.has(event.event_type)) return false;
  if (!event.timestamp_utc) return false;
  return true;
}

// POST /api/v1/telemetry/batch
// Body: { events: [...], sdk_version: string, platform: string }
router.post('/batch', requireApiKey, async (req, res) => {
  const { events, sdk_version, platform } = req.body;

  if (!Array.isArray(events) || events.length === 0) {
    return res.status(400).json({ error: 'events array required' });
  }
  if (events.length > 50) {
    return res.status(400).json({ error: 'batch too large (max 50)' });
  }

  const rows = [];
  const rejected = [];

  for (const event of events) {
    if (!validateEvent(event)) {
      rejected.push(event.event_type ?? 'unknown');
      continue;
    }
    const cleaned = stripForbiddenFields(event);
    rows.push({
      event_type:         cleaned.event_type,
      evaluation_id:      cleaned.evaluation_id ?? null,
      session_id:         cleaned.session_id ?? null,
      timestamp_utc:      cleaned.timestamp_utc,
      decision_state:     cleaned.decision_state ?? null,
      refusal_reasons:    cleaned.refusal_reasons ?? null,
      rule_family:        cleaned.rule_family ?? null,
      confidence_score:   cleaned.confidence_score ?? null,
      measured_distance_m:    cleaned.measured_distance_m ?? null,
      signed_margin_m:        cleaned.signed_margin_m ?? null,
      total_estimated_error_m: cleaned.total_estimated_error_m ?? null,
      boundary_provenance:    cleaned.boundary_provenance ?? null,
      ar_metric_scale_score:  cleaned.ar_metric_scale_score ?? null,
      ar_plane_stability_score: cleaned.ar_plane_stability_score ?? null,
      in_near_threshold_zone: cleaned.in_near_threshold_zone ?? null,
      sdk_version:        cleaned.sdk_version ?? sdk_version ?? null,
      policy_version:     cleaned.policy_version ?? null,
      dataset_version:    cleaned.dataset_version ?? null,
      dataset_region_id:  cleaned.dataset_region_id ?? null,
      model_version:      cleaned.model_version ?? null,
      platform:           cleaned.platform ?? platform ?? null,
      os_version:         cleaned.os_version ?? null,
      evaluation_count:   cleaned.evaluation_count ?? null,
      refusal_count:      cleaned.refusal_count ?? null,
      received_at:        new Date().toISOString()
    });
  }

  if (rows.length === 0) {
    return res.status(400).json({ error: 'no valid events', rejected });
  }

  const { error } = await supabase.from('telemetry_events').insert(rows);
  if (error) {
    console.error('[telemetry] insert error:', error.message);
    return res.status(500).json({ error: 'storage_failed' });
  }

  res.json({
    accepted: rows.length,
    rejected: rejected.length,
    rejected_types: rejected
  });
});

// GET /api/v1/telemetry/health — lightweight check
router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

module.exports = router;
