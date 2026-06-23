import { MeasurementResult } from '../engine/outputFormatter';

const API_BASE = process.env.RENDER_API_URL ?? 'https://dk-parking-api.onrender.com';

/**
 * Anonymously logs a measurement result to the backend API → Supabase.
 *
 * Fire-and-forget: UI never waits for this. Failures are silently ignored.
 * No personal data, no images, no location — only the measurement outcome.
 */
export async function logMeasurement(result: MeasurementResult): Promise<void> {
  const payload = {
    device_type: 'android', // TODO: detect from Platform.OS
    app_version: result.appVersion,
    raw_distance_m: result.rawDistanceM,
    displayed_distance_m: result.displayedDistanceM,
    confidence_score: result.confidenceScore,
    decision_state: result.decision,
    plate_detected: result.plateDetected,
    camera_angle_deg: result.cameraAngleDeg,
  };

  await fetch(`${API_BASE}/log`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
}

/**
 * Fetches remote app config (feature flags, min_confidence override, etc.)
 */
export async function fetchAppConfig(): Promise<{
  min_confidence: number;
  safety_buffer_m: number;
  app_message: string | null;
}> {
  const res = await fetch(`${API_BASE}/config`);
  if (!res.ok) throw new Error('Config fetch failed');
  return res.json();
}
