import { DecisionState } from './decisionResolver';

/**
 * Final output contract — the shape returned to the UI layer.
 * Matches OUTPUT_CONTRACT.md exactly.
 */
export interface MeasurementResult {
  /** The final safety verdict */
  decision: DecisionState;

  /** Distance shown to user (after 2m buffer). Null when UNVERIFIABLE. */
  displayedDistanceM: number | null;

  /** Raw measured distance (before buffer). Not shown to user — for logging only. */
  rawDistanceM: number | null;

  /** Composite confidence score 0.0–1.0 */
  confidenceScore: number;

  /** Whether a license plate was detected */
  plateDetected: boolean;

  /** Camera tilt angle at time of measurement */
  cameraAngleDeg: number;

  /** ISO 8601 timestamp */
  timestamp: string;

  /** App version string */
  appVersion: string;
}

/**
 * Assembles the final MeasurementResult from all engine outputs.
 * This is the only object that crosses the engine→UI boundary.
 */
export function formatOutput(params: {
  decision: DecisionState;
  displayedDistanceM: number | null;
  rawDistanceM: number | null;
  confidenceScore: number;
  plateDetected: boolean;
  cameraAngleDeg: number;
  appVersion: string;
}): MeasurementResult {
  return {
    decision: params.decision,
    displayedDistanceM: params.decision === 'UNVERIFIABLE' ? null : params.displayedDistanceM,
    rawDistanceM: params.rawDistanceM,
    confidenceScore: params.confidenceScore,
    plateDetected: params.plateDetected,
    cameraAngleDeg: params.cameraAngleDeg,
    timestamp: new Date().toISOString(),
    appVersion: params.appVersion,
  };
}
