-- DK Parking Engine — Supabase Schema
-- Project: qnvgtkxcdbirzoeceltt
-- Run this in Supabase dashboard → SQL Editor

-- ============================================================
-- TABLE: telemetry_events
-- Stores all structured telemetry events from iOS + Android apps.
-- Per privacy_and_telemetry_spec.md §3 — no PII, no images, no GPS.
-- ============================================================

CREATE TABLE IF NOT EXISTS telemetry_events (
  id                          BIGSERIAL PRIMARY KEY,
  received_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Event identification
  event_type                  TEXT NOT NULL CHECK (event_type IN (
                                'evaluation_completed',
                                'session_started',
                                'session_ended',
                                'refusal_explainer_shown'
                              )),

  -- Correlation IDs (non-personal UUIDs)
  evaluation_id               UUID,
  session_id                  UUID,
  timestamp_utc               TIMESTAMPTZ,

  -- Evaluation result fields (evaluation_completed only)
  decision_state              TEXT,
  refusal_reasons             TEXT[],
  rule_family                 TEXT,
  confidence_score            NUMERIC(5,4),
  measured_distance_m         NUMERIC(8,4),
  signed_margin_m             NUMERIC(8,4),
  total_estimated_error_m     NUMERIC(6,4),
  boundary_provenance         TEXT,
  ar_metric_scale_score       NUMERIC(5,4),
  ar_plane_stability_score    NUMERIC(5,4),
  in_near_threshold_zone      BOOLEAN,

  -- Version references (all events)
  sdk_version                 TEXT,
  policy_version              TEXT,
  dataset_version             TEXT,
  dataset_region_id           TEXT,
  model_version               TEXT,
  platform                    TEXT CHECK (platform IN ('ios', 'android')),
  os_version                  TEXT,

  -- Session summary fields (session_ended only)
  evaluation_count            INTEGER,
  refusal_count               INTEGER
);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_telemetry_event_type     ON telemetry_events (event_type);
CREATE INDEX IF NOT EXISTS idx_telemetry_received_at    ON telemetry_events (received_at DESC);
CREATE INDEX IF NOT EXISTS idx_telemetry_decision_state ON telemetry_events (decision_state);
CREATE INDEX IF NOT EXISTS idx_telemetry_rule_family    ON telemetry_events (rule_family);
CREATE INDEX IF NOT EXISTS idx_telemetry_platform       ON telemetry_events (platform);
CREATE INDEX IF NOT EXISTS idx_telemetry_dataset_region ON telemetry_events (dataset_region_id);

-- RLS: only service role can insert/select (no anon access)
ALTER TABLE telemetry_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "service_role_only" ON telemetry_events
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');


-- ============================================================
-- TABLE: dataset_regions
-- Stores metadata for each regional dataset bundle.
-- Per SYSTEM_ARCHITECTURE.md SS-04 and launch_scope_register.md.
-- ============================================================

CREATE TABLE IF NOT EXISTS dataset_regions (
  id                          BIGSERIAL PRIMARY KEY,
  region_id                   TEXT NOT NULL UNIQUE,   -- e.g. "REG-DK-001"
  display_name                TEXT NOT NULL,          -- e.g. "Copenhagen city centre"
  version                     TEXT NOT NULL,          -- e.g. "REG-DK-001-v1.0.0"
  is_active                   BOOLEAN NOT NULL DEFAULT false,
  valid_until                 DATE NOT NULL,          -- dataset expiry date
  bundle_size_bytes           BIGINT,
  checksum_sha256             TEXT,                   -- integrity check
  storage_path                TEXT,                   -- Supabase Storage path
  policy_version              TEXT,                   -- matching policy version
  legal_source_baseline_date  DATE,                  -- per LEGAL_THRESHOLDS.md
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed the V1 launch region (Copenhagen city centre)
INSERT INTO dataset_regions (
  region_id,
  display_name,
  version,
  is_active,
  valid_until,
  policy_version,
  legal_source_baseline_date
) VALUES (
  'REG-DK-001',
  'Copenhagen city centre',
  'REG-DK-001-STUB-v1.0.0',
  false,   -- set to true only after dataset bundle is uploaded and verified
  '2026-09-25',
  'policy-v1.0.0',
  '2026-03-25'
) ON CONFLICT (region_id) DO NOTHING;

-- RLS
ALTER TABLE dataset_regions ENABLE ROW LEVEL SECURITY;

-- Service role: full access
CREATE POLICY "service_role_full" ON dataset_regions
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- Anon / mobile app: can read active regions only (via server — but just in case)
CREATE POLICY "anon_read_active" ON dataset_regions
  FOR SELECT
  USING (is_active = true);


-- ============================================================
-- STORAGE BUCKET: dataset-bundles
-- Run separately in Supabase dashboard → Storage → New bucket
-- Or via SQL:
-- ============================================================
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('dataset-bundles', 'dataset-bundles', false)
-- ON CONFLICT DO NOTHING;
